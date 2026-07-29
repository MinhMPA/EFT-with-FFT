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

if not any(p is ... for p in psi1_k):   # skips quietly until you fill the dots
    psi1 = [np.fft.irfftn(p, s=(N, N, N)) for p in psi1_k]
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

M(r'''
## Step 3 — Project a slab

Every particle starts on the grid at $\boldsymbol{q}$ and moves to
$\boldsymbol{x} = \boldsymbol{q} + D_1(z)\,\boldsymbol{\Psi}^{(1)}(\boldsymbol{q})$.
Below, that displacement is applied at two epochs — $z=49$, close to the
initial conditions, and $z=0$, today — and a thin slab of each is projected
onto the plane.
''')

C(r'''
q = (np.arange(N) + 0.5)*(L/N)
Q = np.meshgrid(q, q, q, indexing="ij")

pos49 = [(Q[i] + D1(49)*psi1[i]).ravel() % L for i in range(3)]
pos0  = [(Q[i] + D1(0) *psi1[i]).ravel() % L for i in range(3)]
''')

C(r'''
TH = 15.0     # h^-1 Mpc slab thickness
fig, ax = plt.subplots(1, 2, figsize=(9, 4.2))
for a, pos, z in zip(ax, (pos49, pos0), (49, 0)):
    sel = pos[2] < TH
    Hc, _, _ = np.histogram2d(pos[0][sel], pos[1][sel], bins=400, range=[[0, L], [0, L]])
    a.imshow(np.log10(Hc.T + 1), origin="lower", extent=[0, L, 0, L],
             cmap="bone_r", interpolation="nearest")
    a.set_title(f"z = {z}")
    a.set_xlabel(r"$x\ [h^{-1}\,{\rm Mpc}]$")
    a.set_ylabel(r"$y\ [h^{-1}\,{\rm Mpc}]$")
plt.tight_layout()
plt.show()

# quiz: the left panel looks like a faint grid, the right like a web.
#       rms displacement is 0.07 cells at z=49 and 2.8 cells at z=0.
#       What sets the scale of the pattern you see in each panel?
''')

M(r'''
At $z=49$ the displacement is about a fifteenth of a cell, so the picture is
just the Lagrangian grid, barely perturbed. At $z=0$ the web has appeared —
sheets, filaments, knots — and step 4 asks what kind of place each particle
landed in.
''')

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

M(r'''
## Step 5 — Colour the slab

Each particle was classified back at its Lagrangian position $\boldsymbol{q}$
(step 4) and then displaced to $z=0$ (step 3). Below is the same slab as
before, but now every particle is drawn in the colour of its class.
''')

C(r'''
sel = pos0[2] < 15.0
sub = np.random.default_rng(1).permutation(np.flatnonzero(sel))[:400000]
cls = npos.ravel()[sub]

cols = ["#d9d9d9", "#7fbf8f", "#2f6ea5", "#e8590c"]     # void, sheet, filament, knot
labs = ["void", "sheet", "filament", "knot"]

fig, ax = plt.subplots(figsize=(6, 6))
for n, (cl, sz) in enumerate(zip(cols, [0.20, 0.28, 0.35, 0.55])):
    m = cls == n
    ax.scatter(pos0[0][sub][m], pos0[1][sub][m], c=cl, s=sz, marker=".",
               linewidths=0, rasterized=True, zorder=2 + n)

ax.set_xlim(0, L)
ax.set_ylim(0, L)
ax.set_aspect("equal")
ax.set_xlabel(r"$x\ [h^{-1}\,{\rm Mpc}]$")
ax.set_ylabel(r"$y\ [h^{-1}\,{\rm Mpc}]$")

handles = [plt.Line2D([0], [0], marker="s", linestyle="", color=cols[n],
                       label=f"{labs[n]} ({frac[n]:.0f}%)") for n in range(4)]
ax.legend(handles=handles, loc="upper right", fontsize=8, facecolor="white")
plt.tight_layout()
plt.show()

# quiz: the knots sit at the nodes where filaments meet, and the filaments
#       connect them. Nothing in step 4 knew about positions -- the classes
#       came from the INITIAL field. Why does the geometry come out right anyway?
''')

M(r'''
Nothing in step 4 knew about positions — the classes were assigned before
anything moved. Yet the knots land on the nodes and the filaments trace the
strands, because the tidal field that classifies a region is the same field
that later collapses it: $\Psi$ and $D_{ij}$ come from the same $\delta(k)$.
This is the Lecture 2 figure, built here from your own code, and step 6
sharpens it further.
''')


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    emit(CELLS, os.path.join(here, "H2_cosmic_web.ipynb"))


if __name__ == "__main__":
    main()
