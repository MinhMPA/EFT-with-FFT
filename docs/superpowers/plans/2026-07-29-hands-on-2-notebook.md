# Hands-on Session 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Colab notebook for Hands-on Session 2, in which students displace H1's density field with Zel'dovich and 2LPT, watch a cosmic web appear, classify it, discover that two-thirds of it has shell-crossed, and benchmark their second-order source against FlowPM.

**Architecture:** H2 is a **single** notebook of working code, teaching through inline `# quiz:` comments, with three stubs whose collapsed solution cells *overwrite* them so Run-All always produces the web. This departs from H1's two-file split deliberately — see `docs/adr/0002-h2-departs-from-h1-and-runs-at-two-redshifts.md`. The cell-emitting DSL is extracted from `make_notebooks.py` into `nbbuild.py` so both generators share it.

**Tech Stack:** numpy, matplotlib, CAMB (installed, with a shipped table as fallback), and FlowPM (one pip line) for the closing benchmark only.

## Global Constraints

- **Fiducial cosmology:** `Om=0.31, Ob=0.048, h=0.676, ns=0.965, sigma8=0.81, Tcmb=2.7255`. Grid `N=128`, box `L=250.0` Mpc/h, `SEED=1234`.
- **H2's `P_L(k)` comes from CAMB**, not Eisenstein & Hu. H1 stays EH. The two sessions therefore have different `rms δ` (2.516 vs 2.5305) and that is correct, not a bug.
- **Two epochs.** Benchmark at `z=49`; draw the web at `z=0`. `Ψ⁽¹⁾ ∝ D₁` and `Ψ⁽²⁾ ∝ D₁²`, so compute the FFTs once and scale.
- **The deformation tensor is built from the fiducial (linear) field**, never the displaced one. Classify first, move second.
- **Every checkpoint prints before it asserts** (H1's convention, unified in `e415071`).
- **Three stubs only:** `Ψ⁽¹⁾`, the positive-eigenvalue count, `δ₂`. Everything else is given, working code.
- **Solution cells overwrite stubs.** Stubs use `...`, never `raise`, so Run-All never blocks.
- Students must never be pointed at `figs_src/ptlib.py` or `figs_src/make_fig_web.py`.

### Measured reference values

Every number below was produced by running the reference implementation against **CAMB's** `P_L(k)` normalised to `σ₈ = 0.81`. Use these exact values; do not re-derive.

| quantity | value |
|---|---|
| `σ₈` recovered from the CAMB table | 0.8100 |
| `rms δ` on the 128³ grid | **2.5305** |
| `∇·Ψ` vs `−δ`, max relative | **0.0278** (tolerance 0.05) |
| `rms Ψ` per axis (x, y, z) | 5.203, 4.828, **6.091** |
| web fractions void/sheet/filament/knot | **8.0 / 42.1 / 42.0 / 8.0** |
| `rms Ψ⁽¹⁾` at z=49 / z=0 | 0.138 / **5.400** Mpc/h |
| `(3/7)·rms Ψ⁽²⁾` at z=49 / z=0 | 0.001 / **0.977** Mpc/h |
| `Ψ⁽²⁾/Ψ⁽¹⁾` at z=49 / z=0 | 0.005 / **0.181** |
| shell-crossed fraction at z=49 / z=0 | 0.00% / **63.86%** |
| first shell crossing | `D₁ = 0.1633`, i.e. z ≈ 6.9 |
| cell size `L/N` | 1.953 Mpc/h |
| `k_f` / `k_Nyq` / `√3·k_Nyq` | 0.0251 / 1.608 / 2.786 |

Continuum comparisons for the step-2 observation (not a checkpoint):

| | all k | `k_f`→`k_Nyq` | realized |
|---|---|---|---|
| `rms Ψ_x` | 5.833 | 5.039 | 5.203 |
| `rms δ` | 6.603 | 2.331 | 2.531 |
| fraction of `∫dk P` below `k_f` | **24.2%** | | |
| fraction of `∫dk k²P` below `k_f` | **0.01%** | | |

---

## File Structure

```
notebooks/
  nbbuild.py                    # NEW: the cell DSL, extracted from make_notebooks.py
  make_notebooks.py             # H1, refactored to import from nbbuild
  make_h2.py                    # NEW: H2's cells
  H1_gaussian_field.ipynb
  H1_gaussian_field_solutions.ipynb
  H2_cosmic_web.ipynb           # NEW: single file
  pk_lin_fiducial.txt           # REGENERATED from CAMB
  T_camb_fiducial.txt
  verify_notebooks.py           # gains H2's two-pass check
```

---

## Task 1: Extract the DSL, add the solution-overwrite primitive

**Files:**
- Create: `notebooks/nbbuild.py`
- Modify: `notebooks/make_notebooks.py` (import from `nbbuild`, delete the moved code)

**Interfaces produced:** `M`, `C`, `S`, `SM`, `SC`, `emit(cells, path, title)`.

The refactor's correctness criterion: **H1's two notebooks must be byte-identical afterwards.**

- [ ] **Step 1: Create `notebooks/nbbuild.py`**

Move `M`, `C`, `S`, `SM`, `_source`, `_cell`, `build`, and the notebook metadata out of `make_notebooks.py`. Make the cell list explicit rather than module-global, so two generators can coexist:

```python
"""Cell-emitting primitives shared by the hands-on notebook generators.

A generator builds a list of (kind, solution, student) triples and calls emit().
For a single-notebook generator the two sides are identical except where SC()
inserts a solution cell.
"""
import json


def _source(text):
    lines = text.strip("\n").split("\n")
    return [ln + "\n" for ln in lines[:-1]] + [lines[-1]]


def _cell(kind, text, idx):
    base = {"id": f"c{idx:03d}", "metadata": {}, "source": _source(text)}
    if kind == "markdown":
        return {"cell_type": "markdown", **base}
    return {"cell_type": "code", "execution_count": None, "outputs": [], **base}


def _solution_cell(text, idx):
    """A collapsed code cell. Colab honours #@title; Jupyter honours the metadata."""
    c = _cell("code", text, idx)
    c["metadata"] = {"cellView": "form", "jupyter": {"source_hidden": True},
                     "tags": ["solution"]}
    return c


def build(cells, which):
    """cells: list of (kind, solution, student). which in {'student','solutions'}."""
    assert which in ("student", "solutions"), which
    out = []
    for i, (kind, sol, stu) in enumerate(cells):
        text = sol if which == "solutions" else stu
        out.append(_solution_cell(text, i) if kind == "solution"
                   else _cell(kind, text, i))
    return {"cells": out,
            "metadata": {"kernelspec": {"display_name": "Python 3",
                                        "language": "python", "name": "python3"},
                         "language_info": {"name": "python", "version": "3.10"}},
            "nbformat": 4, "nbformat_minor": 5}


def emit(cells, path, which="solutions"):
    with open(path, "w") as fh:
        json.dump(build(cells, which), fh, indent=1)
        fh.write("\n")
    print(f"wrote {path.split('/')[-1]}  ({len(cells)} cells)")
```

Note `_cell` must remain **exactly** as it is in `make_notebooks.py` today, including the `c{idx:03d}` ids, or H1's notebooks change.

- [ ] **Step 2: Refactor `make_notebooks.py` to use it**

Replace its DSL definitions with `from nbbuild import build, emit` plus its own `CELLS` list and `M`/`C`/`S`/`SM` closures appending to it. Keep every `M(...)`/`C(...)`/`S(...)`/`SM(...)` call byte-identical.

- [ ] **Step 3: Prove the refactor changed nothing**

```bash
cd notebooks && cp H1_gaussian_field.ipynb /tmp/h1a.ipynb && \
cp H1_gaussian_field_solutions.ipynb /tmp/h1b.ipynb && \
python3 make_notebooks.py && \
diff -q /tmp/h1a.ipynb H1_gaussian_field.ipynb && \
diff -q /tmp/h1b.ipynb H1_gaussian_field_solutions.ipynb && \
echo "BYTE-IDENTICAL — refactor is safe"; cd ..
```

Expected: `BYTE-IDENTICAL`. If not, stop — the refactor altered H1 and must be corrected before proceeding.

- [ ] **Step 4: Run the existing suite**

`python3 notebooks/verify_notebooks.py` — 19/19 PASS, exit 0.

- [ ] **Step 5: Commit**

```bash
git add notebooks/nbbuild.py notebooks/make_notebooks.py
git commit -m "Extract the notebook cell DSL into nbbuild.py

H2 needs a single-file notebook with collapsed solution cells, which the H1
generator's two-file build cannot express. Both notebooks regenerate
byte-identical after the move."
```

---

## Task 2: Regenerate the fiducial spectrum from CAMB, retarget its pin

**Files:**
- Modify: `notebooks/pk_lin_fiducial.txt` (regenerate)
- Modify: `notebooks/verify_notebooks.py` (the pin at ~line 155)

**Why:** H2's input is CAMB. The shipped fallback must be the *same* spectrum as the live path, or the two disagree by 0.58% in `rms δ`. Nothing in H1 reads this file.

- [ ] **Step 1: Regenerate from CAMB**

```bash
python3 - <<'EOF'
import numpy as np, camb
Om, Ob, h, ns, s8 = 0.31, 0.048, 0.676, 0.965, 0.81
def sig8(k, P):
    x = k*8.0; W = 3*(np.sin(x) - x*np.cos(x))/x**3
    return np.sqrt(np.trapz(k**3*P*W**2/(2*np.pi**2), np.log(k)))
pars = camb.CAMBparams()
pars.set_cosmology(H0=100*h, ombh2=Ob*h*h, omch2=(Om-Ob)*h*h,
                   mnu=0.0, omk=0, num_massive_neutrinos=0)
pars.InitPower.set_params(ns=ns, As=2.1e-9)
pars.set_matter_power(redshifts=[0.0], kmax=60.0)
pars.NonLinear = camb.model.NonLinear_none
kh, _, pk = camb.get_results(pars).get_matter_power_spectrum(
    minkh=1e-4, maxkh=50.0, npoints=1024)
pk = pk[0]*(s8/sig8(kh, pk[0]))**2
np.savetxt("notebooks/pk_lin_fiducial.txt", np.column_stack([kh, pk]),
           header="Linear P(k) at z=0 from CAMB, normalised to sigma_8 = 0.81\n"
                  "Om=0.31 Ob=0.048 h=0.676 ns=0.965, no massive neutrinos\n"
                  "k [h/Mpc]    P(k) [(Mpc/h)^3]", fmt="%.8e")
print("sigma_8 =", round(float(sig8(kh, pk)), 4))
EOF
wc -l notebooks/pk_lin_fiducial.txt
```

Expected: `sigma_8 = 0.81`, 1027 lines.

- [ ] **Step 2: Retarget the pin**

`verify_notebooks.py`'s check currently compares this table to H1's EH `pk_lin` at `2e-3`; that now fails by ~5%. Replace it with a comparison against **live CAMB**, in the same style as the `T_camb_fiducial.txt` check, tolerance `1e-2`. Update the comment: the table is H2's input, and nothing in H1 reads it.

- [ ] **Step 3: Verify, and prove the new pin can fail**

Run the suite (expect all PASS). Then scale the table's second column by 1.05, re-run, confirm that check FAILs and exit is nonzero, restore with `git checkout`, confirm PASS.

- [ ] **Step 4: Commit**

```bash
git add notebooks/pk_lin_fiducial.txt notebooks/verify_notebooks.py
git commit -m "Regenerate the fiducial spectrum from CAMB for H2

H2's live path uses CAMB, so its fallback table must be the same spectrum or
the two disagree by 0.58% in rms delta. H1 is unaffected -- it reads this file
nowhere and stays Eisenstein & Hu."
```

---

## Task 3: H2 scaffolding, step 1 — rebuild the field

**Files:**
- Create: `notebooks/make_h2.py`

**Interfaces produced:** notebook-scope `Om, Ob, h, ns, sigma8, Tcmb, N, L, SEED, k_f, k_Nyq, D1, pk_lin, KX, KY, KZ, K2, delta_k, delta_x`.

- [ ] **Step 1: Create the generator skeleton**

```python
"""Generate the Hands-on 2 notebook (single file, collapsed solutions).

    M(text)              markdown
    C(code)              code, given to students and always run
    SC(stub, solution)   TWO cells: a stub with a TODO, then a collapsed
                         solution cell that OVERWRITES it, so Run-All works

Run this file to write notebooks/H2_cosmic_web.ipynb.
"""
import os
from nbbuild import emit

CELLS = []
M = lambda s: CELLS.append(("markdown", s, s))
C = lambda s: CELLS.append(("code", s, s))


def SC(stub, solution):
    CELLS.append(("code", stub, stub))
    CELLS.append(("solution", solution, solution))


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    emit(CELLS, os.path.join(here, "H2_cosmic_web.ipynb"))
```

- [ ] **Step 2: Title and step 1**

```python
M(r'''
# Hands-on 2 — From a density field to the cosmic web

Displace H1's field, watch a web appear, classify it, and find out how much of
it Zel'dovich had no business describing.

| # | step | ~min |
|---|---|---|
| 1 | rebuild the field from CAMB | 10 |
| 2 | the Zel'dovich displacement | 12 |
| 3 | project a slab — the web appears | 15 |
| 4 | classify it, and check the approximation | 16 |
| 5 | colour the slab | 10 |
| 6 | second order: 2LPT | 15 |
| 7 | benchmark against FlowPM | 10 |

Cells marked `# TODO` are yours. The cell below each one holds the answer and
is collapsed — expand it if you want it. Everything runs either way.
''')

M(r'''#### Cosmology, grid, and the linear spectrum''')

C(r'''
import numpy as np
import matplotlib.pyplot as plt

Om, Ob, h, ns, sigma8, Tcmb = 0.31, 0.048, 0.676, 0.965, 0.81, 2.7255
N, L, SEED = 128, 250.0, 1234
k_f, k_Nyq = 2*np.pi/L, np.pi*N/L

try:
    import camb
except ImportError:
    import subprocess, sys
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "camb"], check=False)
    try:
        import camb
    except ImportError:
        camb = None


def pk_from_camb():
    pars = camb.CAMBparams()
    pars.set_cosmology(H0=100*h, ombh2=Ob*h*h, omch2=(Om - Ob)*h*h,
                       mnu=0.0, omk=0, num_massive_neutrinos=0)
    pars.InitPower.set_params(ns=ns, As=2.1e-9)
    pars.set_matter_power(redshifts=[0.0], kmax=60.0)
    pars.NonLinear = camb.model.NonLinear_none
    kk, _, pp = camb.get_results(pars).get_matter_power_spectrum(
        minkh=1e-4, maxkh=50.0, npoints=1024)
    return kk, pp[0]


def sigma_R(k, P, R=8.0):
    x = k*R
    W = 3*(np.sin(x) - x*np.cos(x))/x**3
    return np.sqrt(np.trapz(k**3*P*W**2/(2*np.pi**2), np.log(k)))


if camb is not None:
    ktab, ptab = pk_from_camb()
    source = "computed with CAMB"
else:
    import urllib.request
    url = ("https://raw.githubusercontent.com/MinhMPA/EFT-with-FFT/"
           "master/notebooks/pk_lin_fiducial.txt")
    try:
        tab = np.loadtxt("pk_lin_fiducial.txt")
    except OSError:
        urllib.request.urlretrieve(url, "pk_lin_fiducial.txt")
        tab = np.loadtxt("pk_lin_fiducial.txt")
    ktab, ptab = tab[:, 0], tab[:, 1]
    source = "from the shipped CAMB table"

ptab = ptab*(sigma8/sigma_R(ktab, ptab))**2      # normalise to sigma_8 = 0.81
pk_lin = lambda q: np.exp(np.interp(np.log(q), np.log(ktab), np.log(ptab)))
print(f"P_L(k) {source};  sigma_8 = {sigma_R(ktab, ptab):.4f}")
''')

M(r'''
#### The same field H1 drew

Same seed, same box, same recipe — so this is H1's field, rebuilt rather than
loaded. Nothing you did in H1 needs to have worked.
''')

C(r'''
kx = np.fft.fftfreq(N, d=1.0/N)*k_f
kz = np.fft.rfftfreq(N, d=1.0/N)*k_f
KX, KY, KZ = np.meshgrid(kx, kx, kz, indexing="ij")
K2 = KX**2 + KY**2 + KZ**2
K2[0, 0, 0] = 1.0

P_grid = pk_lin(np.sqrt(K2).ravel()).reshape(K2.shape)
P_grid[0, 0, 0] = 0.0

rng     = np.random.default_rng(SEED)
delta_k = np.fft.rfftn(rng.standard_normal((N, N, N)))*np.sqrt(P_grid*N**3/L**3)
delta_k[0, 0, 0] = 0.0
delta_x = np.fft.irfftn(delta_k, s=(N, N, N))

print(f"rms delta = {np.std(delta_x):.4f}")     # quiz: H1 got 2.516 with Eisenstein & Hu.
                                                #       Why is this one different?
assert 2.50 < np.std(delta_x) < 2.56, f"expected ~2.53, got {np.std(delta_x):.4f}"
''')

M(r'''
#### Growth factors

`Ψ⁽¹⁾ ∝ D₁` and `Ψ⁽²⁾ ∝ D₁²`, so one set of FFTs serves both epochs.
''')

C(r'''
from scipy.integrate import quad          # only for the growth integral


def D1(z):
    """Linear growth, normalised to D1(0) = 1."""
    def integrand(a):
        return 1.0/(a*np.sqrt(Om/a**3 + (1 - Om)))**3
    def D(a):
        E = np.sqrt(Om/a**3 + (1 - Om))
        return 2.5*Om*E*quad(integrand, 1e-8, a, limit=200)[0]
    return D(1.0/(1 + z))/D(1.0)


for z in (49, 9, 1, 0):
    print(f"  z = {z:3d}   D1 = {D1(z):.4f}")
''')
```

**Note on scipy:** H1 forbade it; H2 uses it for one growth integral. Either import it as above, or reuse H1's `logint` pattern — the implementer may choose, but say which in the report.

- [ ] **Step 3: Generate and execute**

```bash
python3 notebooks/make_h2.py && cd notebooks && \
jupyter nbconvert --to notebook --execute --stdout H2_cosmic_web.ipynb > /dev/null && \
echo "H2 executes clean"; cd ..
```

Expected: `rms delta = 2.5305`, `D1(0) = 1.0000`, `D1(49) = 0.0255`.

- [ ] **Step 4: Commit** — `git add notebooks/make_h2.py notebooks/H2_cosmic_web.ipynb`

---

## Task 4: Step 2 — the Zel'dovich displacement (stub 1)

- [ ] **Step 1: Markdown and the stub**

```python
M(r'''
## Step 2 — The Zel'dovich displacement

Notes §2.2: every particle starts on a grid point $\boldsymbol{q}$ and moves to

$$\boldsymbol{x} = \boldsymbol{q} + D_1(z)\,\boldsymbol{\Psi}^{(1)}(\boldsymbol{q}),
\qquad \boldsymbol{\Psi}^{(1)}(\boldsymbol{k}) = \frac{i\boldsymbol{k}}{k^2}\,\delta(\boldsymbol{k}).$$

That is the unique curl-free field with $\nabla\cdot\boldsymbol{\Psi}^{(1)} = -\delta$,
which is what the checkpoint tests.
''')

SC(stub=r'''
# TODO: Psi^(1)(k) = i k / k^2 * delta(k), for each of the three axes.
# Watch the sign: getting it backwards makes matter flow OUT of overdensities,
# and the rms will not tell you.
psi1_k = [...,  ...,  ...]
psi1   = [np.fft.irfftn(p, s=(N, N, N)) for p in psi1_k]
''', solution=r'''#@title Solution — Psi^(1)
psi1_k = [1j*Ki/K2*delta_k for Ki in (KX, KY, KZ)]
psi1   = [np.fft.irfftn(p, s=(N, N, N)) for p in psi1_k]
''')

C(r'''
# --- checkpoint: div Psi = -delta ---------------------------------------
F = np.fft.rfftn
div = np.fft.irfftn(1j*(KX*F(psi1[0]) + KY*F(psi1[1]) + KZ*F(psi1[2])), s=(N, N, N))
err = np.abs(div + delta_x).max()/np.abs(delta_x).max()

print(f"max |div.Psi + delta| / max|delta| = {err:.4f}")
print(f"rms Psi per axis at z=0            = "
      f"{[round(float(np.std(p)), 3) for p in psi1]}")

assert err < 0.05, f"div.Psi should equal -delta; got {err:.3f}"
''')

M(r'''
The residual is **0.028**, not machine zero, and that is the **Nyquist plane**:
for even $N$ the mode at $k_{\rm Nyq}$ appears once with an ambiguous sign, so
$ik$ is not exactly antisymmetric there.

Note the three axes give **5.20, 4.83, 6.09** — a ±12% spread on identical
correct code, because $\Psi$ is dominated by the few longest modes the box holds.
''')
```

- [ ] **Step 2: The finite-box observation (not a checkpoint)**

```python
M(r'''#### What a finite box costs you''')

C(r'''
kk = np.logspace(-5, np.log10(50), 4000)
allk = np.sqrt(np.trapz(pk_lin(kk), kk)/(6*np.pi**2))
kb   = np.logspace(np.log10(k_f), np.log10(k_Nyq), 4000)
box  = np.sqrt(np.trapz(pk_lin(kb), kb)/(6*np.pi**2))
below = np.trapz(pk_lin(kk[kk < k_f]), kk[kk < k_f])/np.trapz(pk_lin(kk), kk)
below2 = (np.trapz(kk[kk < k_f]**2*pk_lin(kk[kk < k_f]), kk[kk < k_f])
          / np.trapz(kk**2*pk_lin(kk), kk))

print(f"rms Psi_x   realized            {np.std(psi1[0]):.3f} Mpc/h")
print(f"            continuum, all k    {allk:.3f}   -> you are {100*(1-np.std(psi1[0])/allk):.0f}% LOW")
print(f"            continuum, k_f..kNy {box:.3f}   -> you are {100*(np.std(psi1[0])/box-1):.0f}% HIGH")
print(f"\nfraction of int dk P     below k_f: {100*below:5.1f}%")
print(f"fraction of int dk k^2 P below k_f: {100*below2:5.2f}%")
# quiz: Psi = delta/k, so the displacement integral has no k-weighting and the
#       density integral has k^2. Which of the two numbers above explains the 10%?
''')

M(r'''
$\langle\Psi_x^2\rangle = \frac{1}{6\pi^2}\int{\rm d}k\,P(k)$ has **no
$k$-weighting**; $\langle\delta^2\rangle$ carries $k^2$. So the box throws away
**24%** of what makes displacements and **0.01%** of what makes density
contrast. Displacement is the quantity that notices a finite box.
''')
```

- [ ] **Step 3: Regenerate, execute, verify** the printed values match `0.0278`, `[5.203, 4.828, 6.091]`, `24.2%`, `0.01%`.
- [ ] **Step 4: Commit**

---

## Task 5: Step 3 — project a slab, the web appears

Given code, no stub. Follow `figs_src/make_fig_web.py:69-77` for the projection: displaced positions `(q + D1*psi) % L`, select `pos[2] < 15.0`, `np.histogram2d` into 400 bins, `imshow(log10(H.T+1), cmap="bone_r")`.

- [ ] **Step 1** Add the markdown (`## Step 3 — Project a slab`), the position cell, and the plot cell. Draw **both** epochs side by side: z=49 (featureless) and z=0 (the web), with a `# quiz:` asking why the left panel looks like a grid.
- [ ] **Step 2** Execute; confirm the z=0 panel shows filamentary structure and the z=49 panel does not.
- [ ] **Step 3** Commit.

---

## Task 6: Step 4 — classify, and check the approximation (stub 2)

- [ ] **Step 1: The deformation tensor (given) and the eigenvalue count (stub)**

```python
M(r'''
## Step 4 — What kind of place is each particle in?

Notes §2.3. The deformation tensor is
$D_{ij}(\boldsymbol{k}) = k_ik_j\,\delta(\boldsymbol{k})/k^2$, and the sign of
its three eigenvalues says whether a fluid element is collapsing along that
axis. Count the collapsing axes and you get void, sheet, filament, knot.

**Build it from the field you started with, not the displaced one.**
Doroshkevich's `8/42/42/8` is a theorem about *Gaussian* fields, and displacing
destroys Gaussianity. Classify first, move second — each particle carries its
label to wherever $\Psi$ puts it.
''')

C(r'''
ks = (KX, KY, KZ)
Mt = np.empty((N**3, 3, 3), dtype=np.float32)
for i in range(3):
    for j in range(i, 3):
        Mt[:, i, j] = Mt[:, j, i] = np.fft.irfftn(
            ks[i]*ks[j]/K2*delta_k, s=(N, N, N)).ravel()
lam = np.linalg.eigvalsh(Mt)          # ascending: lam[:,0] <= lam[:,1] <= lam[:,2]
del Mt
print(f"eigenvalues: {lam.shape},  lam_max over the box = {lam[:,2].max():.2f}")
''')

SC(stub=r'''
# TODO: how many of the three eigenvalues are positive, per particle?
# 0 -> void, 1 -> sheet, 2 -> filament, 3 -> knot.
npos = ...
''', solution=r'''#@title Solution — count the collapsing axes
npos = (lam > 0).sum(axis=1)
''')

C(r'''
# --- checkpoint: Doroshkevich ------------------------------------------
frac = [100*(npos == n).mean() for n in range(4)]
for n, lab in enumerate(["void", "sheet", "filament", "knot"]):
    print(f"  {n} collapsing axes   {lab:9s} {frac[n]:5.1f}%")
print("  Doroshkevich (1970):            8.0  42.0  42.0   8.0")

for n, want in enumerate((8.0, 42.0, 42.0, 8.0)):
    assert abs(frac[n] - want) < 1.5, f"{n}: expected {want}, got {frac[n]:.1f}"
# quiz: 25/25/25/25 means a sign convention is wrong; 0/0/0/100 means you
#       dropped the k^2. What would classifying the *displaced* field give?
''')
```

- [ ] **Step 2: Shell crossing, free from the same eigenvalues**

```python
M(r'''
#### Was any of this legitimate?

Zel'dovich assumes streams never cross. The Jacobian of
$\boldsymbol{q}\mapsto\boldsymbol{x}$ is $\prod_i(1 - D_1\lambda_i)$, so a
particle has shell-crossed once $D_1\lambda_{\max} > 1$.
''')

C(r'''
print("   z     D1      shell-crossed")
for z in (49, 9, 1, 0):
    d = D1(z)
    print(f"  {z:3d}  {d:.4f}      {100*(d*lam[:, 2] > 1).mean():6.2f}%")
Dc = 1.0/lam[:, 2].max()
print(f"\nfirst crossing anywhere in the box at D1 = {Dc:.4f}")
# quiz: two thirds of the box has shell-crossed by z=0. Why plot it anyway?
#       And what does an N-body code do that Zel'dovich cannot?
''')

M(r'''
**63.9% by z = 0**, and the first crossing at $D_1 = 0.163$, about z ≈ 6.9. The
picture in step 3 is one where the approximation has failed across most of the
volume — which is §2.4 of the notes, arriving as a measurement rather than a
claim. It is also why 2LPT will sharpen the filaments and then overshoot.
''')
```

- [ ] **Step 3** Execute; confirm `8.0 / 42.1 / 42.0 / 8.0`, `63.86%`, `D1 = 0.1633`.
- [ ] **Step 4** Commit.

---

## Task 7: Step 5 — colour the slab

Given code. Follow `make_fig_web.py:78-92`: `ListedColormap(["#d9d9d9", "#7fbf8f", "#2f6ea5", "#e8590c"])`, draw in order of increasing collapse so knots land on top, subsample with `permutation(...)[:400000]`, legend with the measured percentages.

- [ ] **Step 1** Add the cell, at z=0 only. `# quiz:` asking where the knots sit relative to the filaments.
- [ ] **Step 2** Execute, confirm the figure resembles `figs/cosmic_web.pdf`.
- [ ] **Step 3** Commit.

---

## Task 8: Step 6 — second order (stub 3)

- [ ] **Step 1: The 2LPT source**

```python
M(r'''
## Step 6 — Second order

Notes §2.5. The second-order displacement is sourced by

$$\delta^{(2)} = \sum_{i<j}\left[\varphi_{,ii}\varphi_{,jj} - \varphi_{,ij}^2\right],
\qquad \nabla^2\varphi = \delta,$$

and then $\boldsymbol{\Psi}^{(2)} = \tfrac{3}{7}D_1^2\,\nabla\nabla^{-2}\delta^{(2)}$.
The $3/7$ is the Einstein–de Sitter value of the second-order growth ratio.
''')

C(r'''
phi_k = -delta_k/K2                      # lap phi = delta
phi = {}
for i in range(3):
    for j in range(i, 3):
        phi[(i, j)] = np.fft.irfftn(-ks[i]*ks[j]*phi_k, s=(N, N, N))
''')

SC(stub=r'''
# TODO: delta2 = sum over i<j of [ phi_,ii * phi_,jj  -  phi_,ij^2 ]
# phi[(i,j)] holds phi_,ij for i <= j.
delta2 = np.zeros((N, N, N))
...
''', solution=r'''#@title Solution — the second-order source
delta2 = np.zeros((N, N, N))
for i in range(3):
    for j in range(i + 1, 3):
        delta2 += phi[(i, i)]*phi[(j, j)] - phi[(i, j)]**2
''')

C(r'''
delta2_k = np.fft.rfftn(delta2)
psi2 = [np.fft.irfftn(-1j*ks[i]/K2*delta2_k, s=(N, N, N)) for i in range(3)]

r1 = np.sqrt(sum(np.var(p) for p in psi1)/3)
r2 = np.sqrt(sum(np.var(p) for p in psi2)/3)
print("   z     |Psi1|    (3/7)|Psi2|   ratio")
for z in (49, 0):
    d = D1(z)
    print(f"  {z:3d}   {d*r1:7.3f}   {3/7*d**2*r2:9.3f}   {3/7*d**2*r2/(d*r1):6.3f}")

assert abs(3/7*r2/r1 - 0.181) < 0.02, "2LPT/1LPT at z=0 should be ~0.18"
# quiz: the ratio is 0.5% at z=49 and 18% at z=0. Which epoch is LPT for?
''')
```

- [ ] **Step 2** Add the z=0 comparison figure: Zel'dovich slab beside Zel'dovich+2LPT, same colour scale, with a `# quiz:` on whether the filaments are sharper and whether "sharper" is trustworthy given step 4's 63.9%.
- [ ] **Step 3** Execute; confirm `0.005` and `0.181`.
- [ ] **Step 4** Commit.

---

## Task 9: Step 7 — benchmark against FlowPM

**Why FlowPM and not JaxPM or fastpm.** `~/fastpm` is the C code (`CC ?= mpicc`,
needing MPI/PFFT/bigfile/chealpix/kdcount) — not viable on Colab. JaxPM pulls
`jaxdecomp` and `jax-healpy`, neither needed here, and is untested on Colab.
FlowPM installs with one pip line, is already proven in a Colab teaching
notebook, and — decisively — `flowpm.tfpm.lpt2_source` computes *exactly the
quantity the students hand-code*:

```python
source = sum_d phi_,[D1] phi_,[D2]  -  sum_d (phi_,ij)^2      # D1=[1,2,0], D2=[2,0,1]
source *= 3.0/7.
```

i.e. `(3/7)·Σ_{i<j}[φ_,iiφ_,jj − φ_,ij²]` — our `δ₂` with the `3/7` folded in.
So the benchmark compares the same object, not a downstream displacement.

**The gradient convention must be matched, not compared.** FlowPM's
`gradient_kernel` defaults to the fastpm 4th-order finite difference and
`lpt2_source` calls it with no `order` argument, so there is no switch to
spectral. Its `laplace_kernel`, however, uses the exact `sum(ki**2)`. Matching
therefore needs one substitution in the benchmark cell only:

```
ik_i   ->   1j * (8*sin(w_i) - sin(2*w_i)) / 6
```

**Be honest in the markdown about what this validates.** The students' own `δ₂`
uses the spectral gradient the lecture derives. The benchmark re-computes `δ₂`
with FlowPM's kernel so that only the *2LPT algebra* is compared. It validates
the algorithm, not their exact array. Say so; do not claim "your code matches
FlowPM" when what matches is a convention-matched re-run.

- [ ] **Step 1: Install and confirm the interface**

```bash
pip install -q tensorflow tensorflow_probability tf-keras flowpm
python3 -c "
from flowpm.tfpm import lpt2_source
from flowpm.kernels import fftk, gradient_kernel, laplace_kernel
print('flowpm lpt2_source available')
"
```

Report the wall-clock install time. If it exceeds ~4 minutes or fails, stop and
report — do not silently fall back.

- [ ] **Step 2: Feed FlowPM our field, matching conventions**

The real risk is FFT normalisation, not physics. FlowPM uses
`r2c3d(x, norm=nc**3)` / `c2r3d(x, norm=nc**3)` and `fftk(nc, symmetric=False)`
returns `kvec` in **grid units** (`w = 2πn/N`, dimensionless), whereas our `KX`
carries `h/Mpc`. Resolve both by experiment before trusting any number:

1. round-trip a known array through `r2c3d`/`c2r3d` and confirm it returns unchanged;
2. confirm `lpt2_source` of a field whose `δ₂` you know reproduces it.

Then compare, in real space, our convention-matched `(3/7)·δ₂` against
`c2r3d(lpt2_source(dlin_k))`.

- [ ] **Step 3: Measure, then set the tolerance**

These numbers are **unmeasured** — FlowPM is not installed in the authoring
environment. Measure the agreement first, quote it in the report, and set the
assert from what you observe. **Do not invent a tolerance.**

For calibration only: JaxPM's `test_against_fpm.py` asserts `rtol=1e-4`,
`atol=1e-3` between its LPT and fastpm-python's — two independent
implementations sharing the same FD gradient. Convention-matched, ours should
land in that neighbourhood; if it does not, the discrepancy is the finding and
must be reported rather than absorbed into a loose tolerance.

- [ ] **Step 4: Commit**

```bash
git add notebooks/
git commit -m "Hands-on 2 step 7: benchmark delta_2 against FlowPM

flowpm.tfpm.lpt2_source computes the same quantity the students write, so the
comparison is direct. Its gradient kernel is the fastpm finite difference and
is not switchable, so the benchmark cell matches that convention rather than
comparing against it -- what is validated is the 2LPT algebra."
```

---

## Task 10: Two-pass verification and the closing recap

- [ ] **Step 1: Add H2's checks to `verify_notebooks.py`**

```
A  H2 is valid nbformat, and has exactly 3 cells tagged "solution"
B  H2 executes clean, all checkpoints pass
C  H2 with the "solution"-tagged cells REMOVED -> checkpoints FAIL
D  the three stub cells contain "TODO"
```

Check C is the point: it proves the stubs are load-bearing and the solutions are what fix them. Removing a solution cell must leave a stub whose `...` propagates to an assertion failure — verify that it does, since `...` is a legal object and some operations on it do not raise.

- [ ] **Step 2** Add the closing recap markdown to `make_h2.py`, mirroring H1's "What you built".
- [ ] **Step 3** Run the whole suite; report the count.
- [ ] **Step 4** Re-run the document checks per `CLAUDE.md`: `pdflatex` ×3 with `grep -c '^!'`, `check_lectured_refs.py`, `lecture_timing.py`. This plan changes no `.tex`, so all must be unchanged.
- [ ] **Step 5** Update `HANDS_ON_SPEC.md`'s H2 table to the seven steps actually built, and commit.

---

## Self-Review

**Spec coverage.** All six specced H2 steps appear, plus the benchmark as step 7. Three specced items changed deliberately and are recorded in ADR 0002: the step-2 checkpoint (`rms Ψ` → `∇·Ψ = −δ`), the redshift (one epoch → two), and the format (two files → one). The spec's step-1 checkpoint `rms δ = 2.516` becomes **2.5305** because H2 uses CAMB.

**Unmeasured numbers.** Every checkpoint in Tasks 3–8 is a measured value from this session. **Task 9's are not** — JaxPM is not installed here, so the agreement between our `Ψ⁽²⁾` and its `lpt(order=2)` is genuinely unknown. That task is written to measure first and set tolerances second, and flagged as such. This is the one place the plan cannot anchor itself, and the implementer must not invent a tolerance.

**Known risks.** (1) FlowPM's install (`tensorflow tensorflow_probability tf-keras flowpm`) is proven in a Colab teaching notebook but untimed here; Task 9 Step 1 times it before committing. (2) FlowPM's FFT normalisation (`r2c3d`/`c2r3d` with `norm=nc**3`) and its `fftk` grid-unit wavevectors must be resolved by round-trip experiment, not assumed — this is the likeliest source of a wrong benchmark number. (3) The `...` stubs must actually propagate to a failure when the solution cell is removed; Task 10 Step 1 verifies rather than assumes it. (4) scipy enters H2 for one growth integral, which H1 forbade; the implementer chooses and reports.
