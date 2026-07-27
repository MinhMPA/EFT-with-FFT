"""Figure 5: one-loop EFT galaxy multipoles in redshift space.

This one is NOT self-contained. It drives ps_1loop_jax (the FFTLog-based
implementation in /Users/nguyenmn/ps_1loop_jax-for-pfs, cross-checked against
CLASS-PT's public real-space API) rather than reimplementing the Z_3 kernel
here. The linear input and the covariance come from ptlib, so the cosmology
matches the other figures.

Run make_figs.py first (it writes the other three figures); this script only
rewrites multipoles.pdf.
"""
import sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.integrate import simpson
import ptlib

PT_REPO = "/Users/nguyenmn/ps_1loop_jax-for-pfs"
sys.path.insert(0, PT_REPO + "/src")
import jax
jax.config.update("jax_enable_x64", True)
import jax.numpy as jnp
import ps_1loop_jax

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "lines.linewidth": 1.3, "font.family": "serif",
})
OUT = "../figs/"

# ---- cosmology and linear input, same as the other figures
c = ptlib.Cosmo()
z = 0.5
D = c.growth(z)
f = c.f_growth(z)
kg = np.logspace(-4, 2.0, 700)
pk_lin = c.pk_lin(kg) * D**2
pk_data = {"k": jnp.array(kg), "pk": jnp.array(pk_lin)}

# ---- nuisance parameters, the set tabulated in the notes
b1 = 2.0
bias = {"b1": b1,
        "b2": -0.6,                       # simulation-calibrated at b1 ~ 2
        "bG2": -2.0 / 7.0 * (b1 - 1.0),   # coevolution
        "bGamma3": 23.0 / 42.0 * (b1 - 1.0)}
ctr = {"c0": 5.0, "c2": 15.0, "c4": -5.0, "cfog": 100.0}
stoch = {"P_shot": 0.0, "a0": 0.0, "a2": 0.0}   # 1/nbar handled below
nbar = 3.0e-4
params = {"h": c.h, "f": f, "bias": bias, "ctr": ctr, "stoch": stoch,
          "k_nl": 0.45, "ndens": nbar}

model = ps_1loop_jax.PowerSpectrum1Loop(do_irres=True, rbao=110.0, ks=0.2)

kb = np.linspace(0.01, 0.30, 30)
dk = kb[1] - kb[0]
P0 = np.asarray(model.get_pk_ell(jnp.array(kb), 0, pk_data, params)) + 1.0 / nbar
P2 = np.asarray(model.get_pk_ell(jnp.array(kb), 2, pk_data, params))
print(f"f(z={z}) = {f:.4f}, D = {D:.4f}, b1 = {b1}")
print("P_0:", np.array2string(P0[::6], precision=1))
print("P_2:", np.array2string(P2[::6], precision=1))

# ---- Gaussian covariance (same expression as make_figs.py, FKP-checked)
# P(k,mu) is even in mu and the model tabulates mu in [0,1], so fold the
# angular integrals: int_-1^1 dmu (even) = 2 int_0^1 dmu.
mu = np.linspace(0.0, 1.0, 201)
K, M = np.meshgrid(kb, mu, indexing="ij")
pkmu = np.asarray(model.get_pkmu(jnp.array(kb), jnp.array(mu), pk_data, params))
Ptot = pkmu + 1.0 / nbar
V = 6.0e9                                  # (Mpc/h)^3
Nk = V * 4 * np.pi * kb**2 * dk / (2 * np.pi)**3

def sigma_ell(ell):
    L = np.ones_like(M) if ell == 0 else 0.5 * (3 * M**2 - 1)
    var = (2 * ell + 1)**2 * 2.0 * simpson(Ptot**2 * L**2, x=mu, axis=1)
    return np.sqrt(var / Nk)

s0, s2 = sigma_ell(0), sigma_ell(2)
print(f"  sigma_0/P_0 at k={kb[0]:.2f}: {s0[0]/P0[0]:.4f} "
      f"(FKP {np.sqrt(2/Nk[0]):.4f})")

# ---- two-loop error envelope, Chudaykin & Ivanov (2019) Eq. (4.10).
# Now the appropriate estimate: the plotted model really is one loop.
def tree_ell(ell):
    Kais = (b1 + f * M**2)**2
    L = np.ones_like(M) if ell == 0 else 0.5 * (3 * M**2 - 1)
    plin2d = np.tile((c.pk_lin(kb) * D**2)[:, None], (1, mu.size))
    return (2 * ell + 1) * simpson(Kais * plin2d * L, x=mu, axis=1)

E0 = D**4 * np.abs(tree_ell(0)) * (kb / 0.45)**3.3
E2 = D**4 * np.abs(tree_ell(2)) * (kb / 0.45)**3.3
icross = np.argmax((E0 / s0) > 1)
print(f"monopole: two-loop estimate crosses the statistical error at "
      f"k = {kb[icross]:.3f} h/Mpc")

# ---- plot
rng = np.random.default_rng(7)
fig, axes = plt.subplots(1, 2, figsize=(6.8, 2.9))
for ax, Pl, sl, El, ell in [(axes[0], P0, s0, E0, 0), (axes[1], P2, s2, E2, 2)]:
    data = Pl + rng.normal(size=kb.size) * sl
    ax.fill_between(kb, kb * (Pl - El), kb * (Pl + El), color="C0", alpha=0.30,
                    lw=0, zorder=1, label="two-loop error estimate")
    ax.plot(kb, kb * Pl, color="C3", lw=1.1, zorder=2, label="one-loop EFT")
    ax.errorbar(kb, kb * data, yerr=kb * sl, fmt="o", ms=2.4, color="k",
                elinewidth=0.7, capsize=1.4, zorder=3, label="synthetic data")
    ax.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
    ax.set_ylabel(rf"$k\,P_{ell}(k)\ [(\mathrm{{Mpc}}/h)^2]$")
    ax.text(0.045, 0.90, rf"$\ell={ell}$", transform=ax.transAxes)
    ax.set_xlim(0.0, 0.31)
    sel = kb > 0.03
    lo = min((kb * (Pl - El))[sel].min(), (kb * Pl)[sel].min())
    hi = max((kb * (Pl + El))[sel].max(), (kb * Pl)[sel].max())
    ax.set_ylim(0.80 * lo, 1.10 * hi)
axes[0].legend(frameon=False, loc="lower center", fontsize=6.5)
fig.tight_layout()
fig.savefig(OUT + "multipoles.pdf")
print("wrote multipoles.pdf (one-loop EFT via ps_1loop_jax)")
