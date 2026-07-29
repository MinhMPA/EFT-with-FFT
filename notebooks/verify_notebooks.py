"""Verify the hands-on 1 and hands-on 2 notebooks.

H1 -- five checks:
  1. both notebooks are valid nbformat and have the same cell count;
  2. the student notebook's differing cells contain stubs, the solutions' do not;
  3. the solutions notebook executes with every assert passing;
  4. the shipped data tables are present and correctly shaped;
  5. the notebook's standalone T(k) and P_L(k) agree with figs_src/ptlib.py,
     and the shipped T_camb_fiducial.txt agrees with the notebook's T_full.

Note check 3 and check 5 both run the optional CAMB section, which takes ~20 s
when camb is importable. That is expected, not a hang.

Check 5 is the one that matters over time: the notebook deliberately duplicates
the Eisenstein & Hu code so it can run in Colab with no repo checkout, and this
is what stops the two copies drifting apart. It also pins the shipped CAMB
table, the offline path's only unverified input.

H2 -- unlike H1's student/solutions pair, H2 is a single file with the three
solutions collapsed inline (ADR 0002), so its checks are shaped differently:
  A. valid nbformat; exactly 3 cells tagged "solution"; exactly 3 stub cells
     containing "# TODO";
  B. the full notebook, plain --execute, exits 0 with every checkpoint assert
     passing;
  C. for each of the 3 solution cells individually removed, execution exits 1
     -- proving each stub is load-bearing on its own, not just when all three
     are missing (stripping all three fails at the earliest stub and never
     exercises the other two);
  D. regenerating from make_h2.py is a no-op against the committed files;
  E. every code cell ships with no baked-in outputs or execution_count.

H2-B (and each of H2-C's three sub-runs) execute CAMB (~20 s) and, where
TensorFlow/FlowPM are installed, that import (~40 s) too -- expect this
section to roughly double the suite's total runtime.

Run from the repo root:  python3 notebooks/verify_notebooks.py
"""
import json
import nbformat
import os
import shutil
import subprocess
import sys
import tempfile

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NOTEBOOKS = os.path.join(ROOT, "notebooks")
STUDENT = os.path.join(NOTEBOOKS, "H1_gaussian_field.ipynb")
SOLUTIONS = os.path.join(NOTEBOOKS, "H1_gaussian_field_solutions.ipynb")
H2 = os.path.join(NOTEBOOKS, "H2_cosmic_web.ipynb")

failures = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"  --  {detail}" if detail else ""))
    if not ok:
        failures.append(name)


def cells(path):
    return json.load(open(path))["cells"]


print("1. structure")
for p in (STUDENT, SOLUTIONS):
    try:
        nbformat.validate(nbformat.read(p, as_version=4))
        check(f"{os.path.basename(p)} is valid nbformat", True)
    except Exception as exc:
        check(f"{os.path.basename(p)} is valid nbformat", False, str(exc)[:80])

s, v = cells(STUDENT), cells(SOLUTIONS)
check("same cell count", len(s) == len(v), f"{len(s)} vs {len(v)}")

print("2. stub orientation")
differing = [i for i, (a, b) in enumerate(zip(s, v)) if a["source"] != b["source"]]
check("some cells differ", len(differing) > 0, f"{len(differing)} cells")
stu_txt = "".join("".join(s[i]["source"]) for i in differing)
sol_txt = "".join("".join(v[i]["source"]) for i in differing)
check("student side has TODOs", "TODO" in stu_txt)
check("solutions side has none", "TODO" not in sol_txt)
check("student side raises", "NotImplementedError" in stu_txt)
check("solutions side does not", "NotImplementedError" not in sol_txt)

print("3. execution")
res = subprocess.run(
    ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--stdout", SOLUTIONS],
    cwd=NOTEBOOKS, capture_output=True, text=True)
check("solutions execute clean", res.returncode == 0,
      res.stderr.strip().splitlines()[-1][:100] if res.returncode else "")

res = subprocess.run(
    ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--stdout", STUDENT],
    cwd=NOTEBOOKS, capture_output=True, text=True)
check("student notebook stops at a TODO", res.returncode != 0,
      "it ran to completion, so the stubs are not stubs" if res.returncode == 0 else "")

print("4. shipped data files")
for name, rows in (("pk_lin_fiducial.txt", 1024), ("T_camb_fiducial.txt", 1024)):
    path = os.path.join(NOTEBOOKS, name)
    ok = os.path.exists(path)
    check(f"{name} present", ok)
    if ok:
        tab = np.loadtxt(path)
        check(f"{name} has {rows} rows and 2 columns", tab.shape == (rows, 2), str(tab.shape))

print("5. agreement with figs_src/ptlib.py")
sys.path.insert(0, os.path.join(ROOT, "figs_src"))
import matplotlib
matplotlib.use("Agg")           # headless: the plotting cells must still run
import ptlib

# Rebuild the notebook's namespace by running every code cell in order. This
# runs in notebooks/ (the save cell writes delta_k_128.npz there, and the
# fallback cells read pk_lin_fiducial.txt / T_camb_fiducial.txt by bare
# filename). Nothing is filtered and nothing is swallowed: a cell that raises
# here is a real failure, and the traceback is the diagnostic.
ns_ = {"__name__": "__notebook__"}
cwd = os.getcwd()
os.chdir(NOTEBOOKS)               # pk_lin_fiducial.txt lives here
try:
    for n, cell in enumerate(v):
        if cell["cell_type"] != "code":
            continue
        try:
            exec("".join(cell["source"]), ns_)
        except Exception as exc:
            check(f"solutions cell {n} runs under exec", False,
                  f"{type(exc).__name__}: {exc}")
            break
finally:
    os.chdir(cwd)
    # check 3 (nbconvert) and this exec both leave delta_k_128.npz behind;
    # clean up once here so the suite leaves no residue.
    leftover = os.path.join(NOTEBOOKS, "delta_k_128.npz")
    if os.path.exists(leftover):
        os.remove(leftover)

cosmo = ptlib.Cosmo()
kt = np.logspace(-3, 1, 60)
if "T_full" in ns_:
    rel = float(np.abs(ns_["T_full"](kt)/cosmo._eh_full(kt) - 1).max())
    check("notebook T_full matches ptlib._eh_full", rel < 1e-10, f"max rel {rel:.2e}")
else:
    check("notebook T_full matches ptlib._eh_full", False, "T_full not found")

if "T_nowiggle" in ns_:
    rel = float(np.abs(ns_["T_nowiggle"](kt)/cosmo._eh_nw(kt) - 1).max())
    check("notebook T_nowiggle matches ptlib._eh_nw", rel < 1e-10, f"max rel {rel:.2e}")
else:
    check("notebook T_nowiggle matches ptlib._eh_nw", False, "T_nowiggle not found")

if "pk_lin" in ns_:
    rel = float(np.abs(ns_["pk_lin"](kt)/cosmo.pk_lin(kt) - 1).max())
    check("notebook pk_lin matches ptlib.pk_lin", rel < 1e-3, f"max rel {rel:.2e}")
else:
    check("notebook pk_lin matches ptlib.pk_lin", False, "pk_lin not found")

# T_camb_fiducial.txt is the offline path's only source of truth for T(k) --
# nothing else compares its values to anything, so a table drifted from the
# fiducial cosmology (e.g. via a CAMB re-run with the wrong params) would pass
# every other check here and only fail in a classroom with no internet.
if "T_full" in ns_:
    tab = np.loadtxt(os.path.join(NOTEBOOKS, "T_camb_fiducial.txt"))
    k_tab, T_tab = tab[:, 0], tab[:, 1]
    rel = float(np.abs(ns_["T_full"](k_tab)/T_tab - 1).max())
    check("shipped CAMB table matches the notebook's T_full", rel < 0.04,
          f"max rel {rel:.2e}")
else:
    check("shipped CAMB table matches the notebook's T_full", False, "T_full not found")

# pk_lin_fiducial.txt is H2's input, not H1's: nothing in this notebook reads
# it any more, so no EH-based check here would notice it drifting. H2's live
# path calls CAMB directly, so the shipped fallback must track a fresh CAMB
# run at this same fiducial cosmology, or the two paths disagree silently.
try:
    import camb

    def _sig8(k, P):
        x = k * 8.0
        W = 3 * (np.sin(x) - x * np.cos(x)) / x**3
        return np.sqrt(np.trapz(k**3 * P * W**2 / (2 * np.pi**2), np.log(k)))

    Om, Ob, h_, ns_camb, s8 = 0.31, 0.048, 0.676, 0.965, 0.81
    pars = camb.CAMBparams()
    pars.set_cosmology(H0=100 * h_, ombh2=Ob * h_ * h_, omch2=(Om - Ob) * h_ * h_,
                       mnu=0.0, omk=0, num_massive_neutrinos=0)
    pars.InitPower.set_params(ns=ns_camb, As=2.1e-9)
    pars.set_matter_power(redshifts=[0.0], kmax=60.0)
    pars.NonLinear = camb.model.NonLinear_none
    kh_camb, _, pk_camb = camb.get_results(pars).get_matter_power_spectrum(
        minkh=1e-4, maxkh=50.0, npoints=1024)
    pk_camb = pk_camb[0] * (s8 / _sig8(kh_camb, pk_camb[0])) ** 2

    tab = np.loadtxt(os.path.join(NOTEBOOKS, "pk_lin_fiducial.txt"))
    k_tab, p_tab = tab[:, 0], tab[:, 1]
    lk, lp = np.log(kh_camb), np.log(pk_camb)
    p_ref = np.exp(np.interp(np.log(k_tab), lk, lp))
    rel = float(np.abs(p_tab / p_ref - 1).max())
    check("shipped P_L table matches live CAMB", rel < 1e-2, f"max rel {rel:.2e}")
except Exception as exc:
    check("shipped P_L table matches live CAMB", False, f"{type(exc).__name__}: {exc}")

print()
print("H2 -- full pipeline (CAMB, and TensorFlow/FlowPM where installed): "
      "expect this section to roughly double the suite's runtime.")

print("\nH2-A. structure")
try:
    nbformat.validate(nbformat.read(H2, as_version=4))
    check("H2_cosmic_web.ipynb is valid nbformat", True)
except Exception as exc:
    check("H2_cosmic_web.ipynb is valid nbformat", False, str(exc)[:80])

h2_cells = cells(H2)
sol_idx = [i for i, c in enumerate(h2_cells)
           if "solution" in c.get("metadata", {}).get("tags", [])]
check("exactly 3 cells tagged \"solution\"", len(sol_idx) == 3, f"{len(sol_idx)}: {sol_idx}")

stub_idx = [i for i, c in enumerate(h2_cells)
            if c["cell_type"] == "code" and "# TODO" in "".join(c["source"])]
check("exactly 3 stub cells containing \"# TODO\"", len(stub_idx) == 3, f"{len(stub_idx)}: {stub_idx}")

print("\nH2-B. full notebook, plain --execute")
res = subprocess.run(
    ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--stdout", H2],
    cwd=NOTEBOOKS, capture_output=True, text=True)
check("H2 executes clean, all checkpoints pass", res.returncode == 0,
      res.stderr.strip().splitlines()[-1][:100] if res.returncode else "")

print("\nH2-C. per-stub strip: each solution cell removed alone must fail")
# Stripping all three at once fails at the earliest stub (psi1) and never
# exercises the other two -- so each of the 3 is stripped INDIVIDUALLY, in a
# fresh copy of the full notebook, from a temp dir outside the repo. cwd is
# still NOTEBOOKS so the offline CAMB-fallback path (if camb is unavailable)
# still finds pk_lin_fiducial.txt by its bare relative name.
tmpdir = tempfile.mkdtemp(prefix="verify_h2_strip_")
try:
    full = json.load(open(H2))
    for n, idx in enumerate(sol_idx):
        variant = dict(full)
        variant["cells"] = [c for i, c in enumerate(full["cells"]) if i != idx]
        vpath = os.path.join(tmpdir, f"variant_{n}.ipynb")
        json.dump(variant, open(vpath, "w"))
        res = subprocess.run(
            ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--stdout", vpath],
            cwd=NOTEBOOKS, capture_output=True, text=True)
        check(f"removing solution cell {idx} (stub {n + 1}/3) fails execution",
              res.returncode != 0,
              "ran to completion -- the stub is not load-bearing" if res.returncode == 0 else "")
finally:
    shutil.rmtree(tmpdir, ignore_errors=True)

print("\nH2-D. regeneration is a no-op")
res = subprocess.run(["python3", "make_h2.py"], cwd=NOTEBOOKS, capture_output=True, text=True)
check("make_h2.py runs clean", res.returncode == 0, res.stderr.strip()[:100] if res.returncode else "")
res = subprocess.run(
    ["git", "diff", "--quiet", "HEAD", "--", "notebooks/H2_cosmic_web.ipynb", "notebooks/make_h2.py"],
    cwd=ROOT)
check("regenerating H2 leaves the committed files unchanged (git diff --quiet HEAD)",
      res.returncode == 0)

print("\nH2-E. no baked-in execution artifacts")
h2_code = [c for c in cells(H2) if c["cell_type"] == "code"]
check("every H2 code cell has outputs: []",
      all(c.get("outputs", None) == [] for c in h2_code))
check("every H2 code cell has execution_count: null",
      all(c.get("execution_count", "MISSING") is None for c in h2_code))

print()
if failures:
    print(f"{len(failures)} FAILED: " + ", ".join(failures))
    sys.exit(1)
print("all checks passed")
