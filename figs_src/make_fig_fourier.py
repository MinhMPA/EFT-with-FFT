"""Prelude figure: the same field, held two ways.

Left  -- three plane waves of different comoving wavelength, summed into a lumpy
         density field delta(x). The decomposition, in position space.
Right -- where those three modes sit on the linear power spectrum. The amplitude
         of a single mode falls as sqrt(P(k)), so the long wave is the tall one.

The point of the right panel is that "amplitude versus k" is not a new object
invented later: it *is* the power spectrum the course spends three lectures
computing. Same colours identify the same mode across the two panels.

Self-contained: uses ptlib only. Writes ../figs/fourier_decomposition.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "lines.linewidth": 1.3, "font.family": "serif",
})
OUT = "../figs/"

c = ptlib.Cosmo()
kg = np.logspace(-3.3, 0.3, 600)
pk = c.pk_lin(kg)

# three modes, well separated in scale
KS = np.array([0.02, 0.06, 0.18])                 # h/Mpc
LAM = 2 * np.pi / KS                              # Mpc/h
AMP = np.sqrt(c.pk_lin(KS))                       # single-mode amplitude ~ sqrt(P)
AMP = AMP / AMP[0]                                # normalise to the longest wave
PHI = np.array([0.0, 2.1, 4.3])                   # arbitrary phases
COL = ["#3b6ea5", "#c8622d", "#4c9a5e"]

print("  mode    k [h/Mpc]   lambda [Mpc/h]    P(k)        relative amplitude")
for k, lam, a in zip(KS, LAM, AMP):
    print(f"          {k:6.3f}      {lam:7.1f}      {c.pk_lin(np.array([k]))[0]:9.1f}      {a:.2f}")

L = 400.0                                          # box side, Mpc/h
x = np.linspace(0, L, 2000)
waves = [a * np.cos(k * x + p) for k, a, p in zip(KS, AMP, PHI)]
total = np.sum(waves, axis=0)

fig = plt.figure(figsize=(6.9, 3.1))
gs = fig.add_gridspec(1, 2, width_ratios=[1.35, 1.0], wspace=0.28)
axL = fig.add_subplot(gs[0, 0])
axR = fig.add_subplot(gs[0, 1])

# ---- left: the decomposition, stacked
STEP = 2.6
for i, (w, k, lam, col) in enumerate(zip(waves, KS, LAM, COL)):
    y0 = -i * STEP
    axL.axhline(y0, color="0.85", lw=0.5, zorder=0)
    axL.plot(x, w + y0, color=col, zorder=2)
    # name the modes rather than pricing them: the numbers are set by the box
    # size, which is arbitrary, but lambda_1 > lambda_2 > lambda_3 is not
    axL.text(L * 1.015, y0, rf"$\lambda_{i+1}$", color=col,
             va="center", ha="left", fontsize=8.5)
    if i < len(waves) - 1:
        axL.text(-L * 0.055, y0 - STEP / 2, "+", ha="center", va="center",
                 fontsize=13, color="0.35")
y0 = -len(waves) * STEP
axL.text(-L * 0.055, y0 + STEP / 2, "=", ha="center", va="center",
         fontsize=13, color="0.35")
axL.axhline(y0, color="0.85", lw=0.5, zorder=0)
axL.plot(x, total + y0, color="k", lw=1.5, zorder=3)
axL.text(L * 1.015, y0, r"$\delta(x)$", va="center", ha="left", fontsize=8.5)

axL.set_xlim(-L * 0.09, L * 1.20)
axL.set_ylim(y0 - 2.6, STEP - 0.6)
axL.set_xlabel(r"comoving position $x\ [\mathrm{Mpc}/h]$")
axL.set_yticks([])
for sp in ("left", "right", "top"):
    axL.spines[sp].set_visible(False)

# ---- right: where those modes live on P(k)
axR.loglog(kg, pk, color="0.25", lw=1.4, zorder=2)
for i, (k, a, col) in enumerate(zip(KS, AMP, COL)):
    P = c.pk_lin(np.array([k]))[0]
    axR.plot([k, k], [1e1, P], color=col, lw=1.0, ls=":", zorder=1)
    axR.plot(k, P, "o", color=col, ms=6, mec="white", mew=0.8, zorder=3)
    axR.annotate(rf"$k_{i+1}$", (k, P), textcoords="offset points",
                 xytext=(9, -9), color=col, fontsize=8.5, zorder=4)
axR.set_xlim(1e-3, 1.0)
axR.set_ylim(2e2, 6e4)
axR.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
axR.set_ylabel(r"$P_{\rm L}(k)\ [(\mathrm{Mpc}/h)^3]$")
axR.text(0.96, 0.94, r"$k = 2\pi/\lambda$", transform=axR.transAxes,
         ha="right", va="top", fontsize=9)

fig.savefig(OUT + "fourier_decomposition.pdf")
# the caption must not leave the impression that large scales dominate lumpiness
D2 = KS**3 * c.pk_lin(KS) / (2*np.pi**2)
print("\n  single-mode amplitude falls with k, but power per log interval rises:")
for k, a, d in zip(KS, AMP, D2):
    print(f"    k={k:5.2f}:  amplitude {a:.2f},  Delta^2 = k^3 P/2pi^2 = {d:.3f}")
print("wrote fourier_decomposition.pdf")
