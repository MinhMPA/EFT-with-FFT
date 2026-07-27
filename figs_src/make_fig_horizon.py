"""Figure: the comoving Hubble radius, and when modes enter the horizon.

The engine of Section 1.5. Modes are horizontal lines -- a fixed comoving 1/k
that never changes -- while 1/H moves past them. Where a line meets the curve,
that mode enters the horizon. The mode entering exactly at equality defines
k_eq, which is where the turnover in P_L(k) comes from.

Self-contained: uses ptlib only. Writes ../figs/horizon_crossing.pdf
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
C_KMS = 299792.458

c = ptlib.Cosmo()
Om, OL, h = c.Om, 1.0 - c.Om, c.h
Ogam = 2.47e-5 / h**2
Onu = Ogam * 3 * (7.0 / 8.0) * (4.0 / 11.0) ** (4.0 / 3.0)
Or = Ogam + Onu
a_eq = Or / Om

def Hc(a):                       # comoving Hubble rate, h/Mpc
    return (100.0 / C_KMS) * a * np.sqrt(Or / a**4 + Om / a**3 + OL)

k_eq = Hc(a_eq)
print(f"  Omega_r = {Or:.3e}   a_eq = {a_eq:.3e}  (z_eq = {1/a_eq-1:.0f})")
print(f"  k_eq = script-H(a_eq) = {k_eq:.4f} h/Mpc")

a = np.logspace(-6, 0, 3000)
R = 1.0 / Hc(a)                                   # comoving Hubble radius, Mpc/h

fig, ax = plt.subplots(figsize=(6.2, 3.6))

ax.plot(a, R, color="k", lw=1.8, zorder=4, label=r"comoving Hubble radius $1/\mathcal{H}$")
ax.axvline(a_eq, color="0.75", lw=0.8, ls=":", zorder=0)
ax.text(a_eq * 1.3, 6.5e3, r"$a_{\rm eq}$", fontsize=8, color="0.4")

modes = [(0.005, "#3b6ea5"), (k_eq, "#c8622d"), (0.05, "#4c9a5e")]
for k, col in modes:
    ax.axhline(1.0 / k, color=col, lw=1.0, alpha=0.85, zorder=2)
    j = np.argmin(np.abs(R[a < 0.5] - 1.0 / k))
    ax.plot(a[j], R[j], "o", color=col, ms=6, mec="white", mew=0.9, zorder=5)
    lab = (rf"$k_{{\rm eq}}={k:.3f}$" if abs(k - k_eq) < 1e-6 else rf"$k={k:.3f}$")
    ax.text(1.35e-6, 1.0 / k * 1.13, lab + r"$\ h\,$Mpc$^{-1}$",
            color=col, fontsize=7.5, va="bottom")

ax.annotate("enters the horizon", xy=(a[np.argmin(np.abs(R[a < 0.5] - 1 / 0.05))], 1 / 0.05),
            xytext=(2.2e-4, 5.2), fontsize=7.5, color="0.3",
            arrowprops=dict(arrowstyle="->", color="0.5", lw=0.7))
ax.text(0.62, 5.2e3, r"$\Lambda$ takes over," "\n" r"$1/\mathcal{H}$ turns around",
        fontsize=7, color="0.45", ha="center")
ax.text(1.3e-6, 1.15e3, "before this, during inflation,\n"
        r"$1/\mathcal{H}$ ran downhill and modes $\it{exited}$",
        fontsize=7, color="0.45", ha="left", va="center")

ax.set_xscale("log"); ax.set_yscale("log")
ax.set_xlim(1e-6, 1.5); ax.set_ylim(3.0, 1.2e4)
ax.set_xlabel(r"scale factor $a$")
ax.set_ylabel(r"comoving scale $[\,h^{-1}\mathrm{Mpc}\,]$")
ax.legend(frameon=False, loc="lower right", fontsize=7.5)
fig.tight_layout()
fig.savefig(OUT + "horizon_crossing.pdf")
print("wrote horizon_crossing.pdf")
