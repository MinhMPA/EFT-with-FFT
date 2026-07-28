"""Verify the hands-on 1 notebooks.

Five checks:
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

Run from the repo root:  python3 handson/verify_notebooks.py
"""
import json
import os
import subprocess
import sys

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HANDSON = os.path.join(ROOT, "handson")
STUDENT = os.path.join(HANDSON, "H1_gaussian_field.ipynb")
SOLUTIONS = os.path.join(HANDSON, "H1_gaussian_field_solutions.ipynb")

failures = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"  --  {detail}" if detail else ""))
    if not ok:
        failures.append(name)


def cells(path):
    return json.load(open(path))["cells"]


print("1. structure")
import nbformat
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
    cwd=HANDSON, capture_output=True, text=True)
check("solutions execute clean", res.returncode == 0,
      res.stderr.strip().splitlines()[-1][:100] if res.returncode else "")

res = subprocess.run(
    ["jupyter", "nbconvert", "--to", "notebook", "--execute", "--stdout", STUDENT],
    cwd=HANDSON, capture_output=True, text=True)
check("student notebook stops at a TODO", res.returncode != 0,
      "it ran to completion, so the stubs are not stubs" if res.returncode == 0 else "")

print("4. shipped data files")
for name, rows in (("pk_lin_fiducial.txt", 1024), ("T_camb_fiducial.txt", 1024)):
    path = os.path.join(HANDSON, name)
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
# runs in handson/ (the save cell writes delta_k_128.npz there, and the
# fallback cells read pk_lin_fiducial.txt / T_camb_fiducial.txt by bare
# filename). Nothing is filtered and nothing is swallowed: a cell that raises
# here is a real failure, and the traceback is the diagnostic.
ns_ = {"__name__": "__notebook__"}
cwd = os.getcwd()
os.chdir(HANDSON)               # pk_lin_fiducial.txt lives here
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
    leftover = os.path.join(HANDSON, "delta_k_128.npz")
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
    tab = np.loadtxt(os.path.join(HANDSON, "T_camb_fiducial.txt"))
    k_tab, T_tab = tab[:, 0], tab[:, 1]
    rel = float(np.abs(ns_["T_full"](k_tab)/T_tab - 1).max())
    check("shipped CAMB table matches the notebook's T_full", rel < 0.04,
          f"max rel {rel:.2e}")
else:
    check("shipped CAMB table matches the notebook's T_full", False, "T_full not found")

print()
if failures:
    print(f"{len(failures)} FAILED: " + ", ".join(failures))
    sys.exit(1)
print("all checks passed")
