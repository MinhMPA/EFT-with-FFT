"""Figure: how P_L(k) is built -- primordial spectrum times transfer function.

Left: the two factors of P_L = A k^{n_s} T^2(k). The primordial power law has no
scale in it; every feature in the product is put there by T.
Right: the product itself, with k_eq marked, and the no-wiggle version showing
which part of the shape the baryons are responsible for.

Self-contained: uses ptlib only. Writes ../figs/pk_construction.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 7.5,
    "xtick.labelsize": 8, "ytick.labelsize": 8, "figure.dpi": 200,
    "savefig.bbox": "tight", "axes.linewidth": 0.7, "lines.linewidth": 1.3,
    "font.family": "serif",
})
OUT = "../figs/"
K_EQ = 0.0153

c = ptlib.Cosmo()
k = np.logspace(-4, 1, 900)
P, Pnw = c.pk_lin(k), c.pk_lin(k, nowiggle=True)
prim = k ** c.ns                      # primordial, arbitrary normalisation
T2 = P / prim
T2 /= T2[0]                           # T -> 1 on large scales
prim *= P[0] / prim[0]                # line them up at the left edge

fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.0))

ax[0].loglog(k, prim, color="#3b6ea5", lw=1.5, label=r"$A\,k^{n_s}$  (inflation)")
ax[0].loglog(k, T2, color="#c8622d", lw=1.5, label=r"$T^2(k)$  (processing)")
ax[0].axvline(K_EQ, color="0.75", lw=0.8, ls=":")
ax[0].text(K_EQ * 1.35, 3e-8, r"$k_{\rm eq}$", fontsize=8, color="0.4")
ax[0].set_ylim(1e-9, 1e6); ax[0].set_xlim(1e-4, 10)
ax[0].set_ylabel("the two factors (arbitrary scale)")
ax[0].legend(frameon=False, loc="lower left")

ax[1].loglog(k, P, color="k", lw=1.6, label="linear $P_{\\rm L}(k)$")
ax[1].loglog(k, Pnw, color="0.6", lw=1.0, ls="--", label="no-wiggle (no baryons)")
ax[1].axvline(K_EQ, color="0.75", lw=0.8, ls=":")
ax[1].text(K_EQ * 1.35, 2.0e3, r"$k_{\rm eq}$", fontsize=8, color="0.4")
ax[1].annotate(r"$\propto k^{-2}\ln k$", xy=(0.9, np.interp(0.9, k, P)),
               xytext=(0.9, 1.1e4), fontsize=7.5, color="0.35",
               arrowprops=dict(arrowstyle="->", color="0.5", lw=0.7))
ax[1].set_xlim(1e-4, 10); ax[1].set_ylim(1e1, 6e4)
# the wiggles are a few percent and invisible here, so show them as a ratio
ins = ax[1].inset_axes([0.09, 0.10, 0.42, 0.30])
m = (k > 0.02) & (k < 0.4)
ins.plot(k[m], (P/Pnw)[m], color="#c8622d", lw=1.0)
ins.axhline(1.0, color="0.8", lw=0.6)
ins.set_xscale("log"); ins.set_xlim(0.02, 0.4); ins.set_ylim(0.90, 1.10)
ins.set_xticks([0.03, 0.1, 0.3]); ins.set_xticklabels(["0.03","0.1","0.3"], fontsize=6)
ins.set_yticks([0.95, 1.05]); ins.tick_params(labelsize=6, length=2)
ins.set_ylabel(r"$P_{\rm L}/P_{\rm nw}$", fontsize=6.5, labelpad=1)
for sp in ins.spines.values(): sp.set_linewidth(0.5)
ax[1].set_ylabel(r"$P_{\rm L}(k)\ [(\mathrm{Mpc}/h)^3]$")
ax[1].legend(frameon=False, loc="upper left", fontsize=7)
for a in ax:
    a.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
fig.tight_layout()
fig.savefig(OUT + "pk_construction.pdf")
print(f"  T(k_eq)^2/T(0)^2 = {np.interp(K_EQ,k,T2):.3f}")
print("wrote pk_construction.pdf")
