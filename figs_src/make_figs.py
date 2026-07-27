"""Generate the lecture-note figures. All curves are computed here; nothing is
traced from a published plot."""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.integrate import simpson
from scipy.optimize import minimize_scalar
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "lines.linewidth": 1.3, "font.family": "serif",
})
OUT = "../figs/"
import os; os.makedirs(OUT, exist_ok=True)

c = ptlib.Cosmo()
kg = np.logspace(-4, 2.3, 900)
pl0 = c.pk_lin(kg)
pnw0 = c.pk_lin(kg, nowiggle=True)

# =====================================================================
# Figure: BAO damping from IR resummation
# =====================================================================
z = 0.5
D = c.growth(z); f = c.f_growth(z)
pl = pl0 * D**2
pnw = pnw0 * D**2
pw = pl - pnw

kosc = 1.0 / 110.0                      # BAO wavenumber, h/Mpc
kS = 0.2
sel = kg < kS
q = kg[sel]
j0 = np.sinc(q / kosc / np.pi)
x = q / kosc
j2 = (3.0 / x**2 - 1.0) * np.sin(x) / x - 3.0 * np.cos(x) / x**2
Sig2 = simpson(pnw[sel] * (1 - j0 + 2 * j2), x=q) / (6 * np.pi**2)
dSig2 = simpson(pnw[sel] * j2, x=q) / (2 * np.pi**2)
print(f"Sigma^2(z={z}) = {Sig2:.2f} (Mpc/h)^2  ->  Sigma = {np.sqrt(Sig2):.2f} Mpc/h")

kp = np.logspace(np.log10(0.02), np.log10(0.42), 500)
plp = c.pk_lin(kp) * D**2
pnwp = c.pk_lin(kp, nowiggle=True) * D**2
pwp = plp - pnwp
damp = np.exp(-kp**2 * Sig2)

fig, ax = plt.subplots(figsize=(5.0, 2.9))
ax.plot(kp, plp / pnwp, color="0.55", lw=1.0, label=r"linear (no resummation)")
ax.plot(kp, 1 + damp * pwp / pnwp, color="C3",
        label=r"IR-resummed, $e^{-k^2\Sigma^2}$")
ax.axhline(1, color="k", lw=0.5, ls=":")
ax.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
ax.set_ylabel(r"$P/P_{\rm nw}$")
ax.set_xlim(0.02, 0.42); ax.set_ylim(0.90, 1.10)
ax.legend(frameon=False, loc="upper right")
ax.text(0.025, 0.915, rf"$z={z}$,  $\Sigma={np.sqrt(Sig2):.1f}\ h^{{-1}}$Mpc",
        fontsize=8)
fig.savefig(OUT + "bao_damping.pdf")
print("wrote bao_damping.pdf")

# =====================================================================
# Figure: one-loop matter power spectrum, SPT vs EFT vs nonlinear reference
# =====================================================================
z = 0.0
D = c.growth(z)
kk = np.logspace(np.log10(0.01), np.log10(0.6), 70)
# use the no-wiggle spectrum here: the BAO feature is damped differently in each
# curve, and its residual wiggles would obscure the broadband comparison
pl_in = c.pk_lin(kg, nowiggle=True) * D**2
P11 = c.pk_lin(kk, nowiggle=True) * D**2
P22 = ptlib.p22(kk, kg, pl_in)
P13 = ptlib.p13(kk, kg, pl_in)
Pspt = P11 + P22 + P13
Pnl, ksig, neff = ptlib.halofit(kk, kg, pl_in, c.Om, 1 - c.Om)
print(f"halofit: k_sigma = {ksig:.3f} h/Mpc, n_eff = {neff:.2f}")

# Fit the single EFT counterterm. Restrict to k > 0.1 h/Mpc: halofit's
# quasi-linear damping makes the reference dip ~1.7% below linear near
# k ~ 0.04, which is a known limitation of the fitting formula rather than
# physics, and including that region biases the fit.
fitsel = (kk > 0.10) & (kk < 0.25)
def chi2(cs2):
    model = Pspt[fitsel] - 2 * cs2 * kk[fitsel]**2 * P11[fitsel]
    return np.sum(((model - Pnl[fitsel]) / Pnl[fitsel])**2)
res = minimize_scalar(chi2, bounds=(0.0, 20.0), method="bounded")
cs2 = res.x
Peft = Pspt - 2 * cs2 * kk**2 * P11
print(f"fitted c_s^2 = {cs2:.2f} (Mpc/h)^2  at z={z} (fit on 0.10-0.25)")
for kt in (0.10, 0.15, 0.20, 0.25):
    i = np.argmin(abs(kk - kt))
    print(f"   k={kt:.2f}: linear/nl={P11[i]/Pnl[i]:.3f}  "
          f"SPT/nl={Pspt[i]/Pnl[i]:.3f}  EFT/nl={Peft[i]/Pnl[i]:.3f}")

# Plot ratios to LINEAR theory, as in Baumann's Cargese figure: this keeps the
# nonlinear reference as a visible curve rather than hiding it in a denominator,
# so the reader can see how far each approximation tracks it.
fig, ax = plt.subplots(figsize=(5.2, 3.3))
ax.axhline(1, color="k", lw=0.6, ls=":")
ax.plot(kk, Pnl / P11, color="k", lw=1.6, label="nonlinear reference (halofit)")
ax.plot(kk, Pspt / P11, color="C0", ls="--", label="1-loop SPT")
ax.plot(kk, Peft / P11, color="C3",
        label=rf"1-loop EFT, $c_s^2={cs2:.1f}\,(\mathrm{{Mpc}}/h)^2$")
ax.axvline(ksig, color="0.55", lw=0.7, ls=":")
ax.text(ksig * 1.04, 1.03, r"$k_\sigma$", fontsize=8, color="0.35")
ax.set_xlim(0.02, 0.5); ax.set_ylim(0.94, 2.0)
ax.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
ax.set_ylabel(r"$P(k)\,/\,P_{\rm L}(k)$")
ax.legend(frameon=False, loc="upper left", fontsize=7.5)
ax.text(0.26, 1.86, r"$z=0$, no-wiggle input", fontsize=7.5)
fig.savefig(OUT + "eft_vs_spt.pdf")
print("wrote eft_vs_spt.pdf")

# =====================================================================
# Figure: Kaiser multipoles with BOSS-like errors and the theory-error envelope
# =====================================================================
z = 0.5
D = c.growth(z); f = c.f_growth(z)
b1 = 2.0
nbar = 3.0e-4                 # (h/Mpc)^3
V = 6.0                       # (Gpc/h)^3
Vh = V * 1e9                  # (Mpc/h)^3
kb = np.linspace(0.01, 0.30, 30)
dk = kb[1] - kb[0]

pl_z = c.pk_lin(kb) * D**2
pnw_z = c.pk_lin(kb, nowiggle=True) * D**2
pw_z = pl_z - pnw_z

mu = np.linspace(-1, 1, 401)
K, M = np.meshgrid(kb, mu, indexing="ij")
Sig2tot = (1 + f * M**2 * (2 + f)) * Sig2 + f**2 * M**2 * (M**2 - 1) * dSig2
dampM = np.exp(-K**2 * Sig2tot)
Pnw2 = np.tile(pnw_z[:, None], (1, mu.size))
Pw2 = np.tile(pw_z[:, None], (1, mu.size))
Pkmu = (b1 + f * M**2)**2 * (Pnw2 + dampM * (1 + K**2 * Sig2tot) * Pw2)

def multipole(P2d, ell):
    if ell == 0: L = np.ones_like(M)
    elif ell == 2: L = 0.5 * (3 * M**2 - 1)
    elif ell == 4: L = (35 * M**4 - 30 * M**2 + 3) / 8
    return (2 * ell + 1) / 2 * simpson(P2d * L, x=mu, axis=1)

P0 = multipole(Pkmu, 0) + 1.0 / nbar
P2 = multipole(Pkmu, 2)

# Gaussian covariance for multipoles (Feldman-Kaiser-Peacock style)
Ptot = Pkmu + 1.0 / nbar
Nk = Vh * 4 * np.pi * kb**2 * dk / (2 * np.pi)**3
def sigma_ell(ell):
    # Gaussian diagonal: Var(P_l) = (2l+1)^2 / N_k * int_-1^1 dmu P_tot^2 L_l^2.
    # Check: for l=0 with no mu dependence this is 2P^2/N_k, the textbook
    # Feldman-Kaiser-Peacock result sigma_P/P = sqrt(2/N_k). (An earlier version
    # of this function carried a spurious 1/2, making the errors sqrt(2) small.)
    if ell == 0: L = np.ones_like(M)
    elif ell == 2: L = 0.5 * (3 * M**2 - 1)
    var = (2 * ell + 1)**2 * simpson(Ptot**2 * L**2, x=mu, axis=1)
    return np.sqrt(var / Nk)
s0, s2 = sigma_ell(0), sigma_ell(2)
# sanity check against FKP in the no-RSD limit
print(f"  covariance check: sigma_0/P_0 at k={kb[0]:.2f} is "
      f"{s0[0]/P0[0]:.4f}; FKP sqrt(2/N_k) gives {np.sqrt(2/Nk[0]):.4f}")

# The curve above is TREE LEVEL (Kaiser + IR resummation). The band below is an
# estimate of the one-loop term it is missing, taken as b_1^2 times the matter
# one-loop spectrum, projected with the Kaiser weights. This is an order-of-
# magnitude stand-in for the full Z_n loops, not a substitute for them.
pl_z_grid = c.pk_lin(kg) * D**2
L22 = ptlib.p22(kb, kg, pl_z_grid)
L13 = ptlib.p13(kb, kg, pl_z_grid)
loop_m = L22 + L13
Kais = (b1 + f * M**2)**2
w0 = multipole(Kais, 0) / (b1**2 + 2 * b1 * f / 3 + f**2 / 5)   # ~1
E0 = np.abs(b1**2 * loop_m) * w0
E2 = np.abs(b1**2 * loop_m) * np.abs(multipole(Kais, 2)) / multipole(Kais, 0)
print(f"  one-loop estimate / P_0 at k=0.1, 0.2: "
      f"{E0[np.argmin(abs(kb-0.1))]/P0[np.argmin(abs(kb-0.1))]:.3f}, "
      f"{E0[np.argmin(abs(kb-0.2))]/P0[np.argmin(abs(kb-0.2))]:.3f}")

rng = np.random.default_rng(7)
fig, axes = plt.subplots(1, 2, figsize=(6.8, 2.9))
for ax, Pl, sl, El, ell in [(axes[0], P0, s0, E0, 0), (axes[1], P2, s2, E2, 2)]:
    data = Pl + rng.normal(size=kb.size) * sl        # synthetic realisation
    ax.fill_between(kb, kb * (Pl - El), kb * (Pl + El), color="C0", alpha=0.30,
                    lw=0, zorder=1, label="size of the missing one-loop term")
    ax.plot(kb, kb * Pl, color="C3", lw=1.1, zorder=2,
            label="tree level (Kaiser, IR-resummed)")
    ax.errorbar(kb, kb * data, yerr=kb * sl, fmt="o", ms=2.4, color="k",
                elinewidth=0.7, capsize=1.4, zorder=3, label="synthetic data")
    ax.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
    ax.set_ylabel(rf"$k\,P_{ell}(k)\ [(\mathrm{{Mpc}}/h)^2]$")
    ax.text(0.045, 0.90, rf"$\ell={ell}$", transform=ax.transAxes)
    ax.set_xlim(0.0, 0.31)
    lo = min((kb * (Pl - El))[kb > 0.03].min(), (kb * Pl)[kb > 0.03].min())
    hi = max((kb * (Pl + El)).max(), (kb * Pl).max())
    ax.set_ylim(0.75 * lo, 1.12 * hi)
axes[0].legend(frameon=False, loc="lower center", fontsize=6.5)
fig.tight_layout()
fig.savefig(OUT + "multipoles.pdf")
print("wrote multipoles.pdf")

# where does the missing one-loop term exceed the statistical error?
icross = np.argmax((E0 / s0) > 1)
print(f"monopole: missing one-loop term exceeds the statistical error at "
      f"k = {kb[icross]:.3f} h/Mpc")
