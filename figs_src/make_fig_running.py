"""Figure 6: cutoff dependence of the bare loop, and its cancellation.

Left panel:  one-loop SPT computed with the loop integrals cut off at several
             Lambda. The prediction moves around -- that is the disease.
Right panel: the same curves after adding -2 c_s^2(Lambda) k^2 P_L with one
             c_s^2 fitted per cutoff. They collapse -- that is renormalization.

The cutoff is imposed on the *input spectrum* rather than on the quadrature
range, so that both legs of P_22 (which carry P(q) and P(|k-q|)) are cut
consistently. A steep power-law suppression (1+(q/Lambda)^12)^-1 is used rather
than a step: it kills the spectrum above Lambda but stays strictly positive, so
the log-log interpolant in ptlib remains finite.

Self-contained: uses ptlib only. Writes ../figs/cutoff_running.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.optimize import minimize_scalar
from scipy.integrate import simpson
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 7.5,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "lines.linewidth": 1.3, "font.family": "serif",
})
OUT = "../figs/"

c = ptlib.Cosmo()
z = 0.0
D = c.growth(z)

# no-wiggle input, as in Fig. 3, so BAO do not clutter a broadband comparison
kg = np.logspace(-4, 3.0, 3000)
pl_full = c.pk_lin(kg, nowiggle=True) * D**2

kk = np.unique(np.concatenate([np.logspace(np.log10(0.02), np.log10(0.30), 26),
                               [0.25]]))
P11 = c.pk_lin(kk, nowiggle=True) * D**2
Pnl, ksig, neff = ptlib.halofit(kk, kg, pl_full, c.Om, 1 - c.Om)

LAMBDAS = [0.50, 1.00, 2.00, 4.00]
fitsel = (kk > 0.10) & (kk < 0.25)

def cut(pk, Lam, p=12):
    """Steep but strictly positive cutoff at Lam."""
    return pk / (1.0 + (kg / Lam) ** p)

rows = []
for Lam in LAMBDAS:
    plc = cut(pl_full, Lam)
    P22 = ptlib.p22(kk, kg, plc)
    # ptlib.p13 multiplies by P_L(k) taken from the spectrum it is handed. Only
    # the loop should be regulated, not the external leg, so undo that factor.
    P11_cut = ptlib._make_interp(kg, plc)(kk)
    P13 = ptlib.p13(kk, kg, plc) * (P11 / P11_cut)
    Pspt = P11 + P22 + P13
    # sigma_v^2 with the same weighting, for the running check
    sv2 = simpson(plc, x=kg) / (6 * np.pi**2)

    def chi2(cs2):
        m = Pspt[fitsel] - 2 * cs2 * kk[fitsel]**2 * P11[fitsel]
        return np.sum(((m - Pnl[fitsel]) / Pnl[fitsel])**2)
    cs2 = minimize_scalar(chi2, bounds=(-20, 20), method="bounded").x
    Peft = Pspt - 2 * cs2 * kk**2 * P11
    rows.append((Lam, Pspt, Peft, cs2, sv2))
    print(f"  Lambda={Lam:4.2f}: sigma_v^2={sv2:7.3f}  fitted c_s^2={cs2:+6.2f}  "
          f"SPT/lin at k=0.25: {(Pspt/P11)[np.argmin(abs(kk-0.25))]:.3f}")

# does the fitted coefficient run as -(61/210) sigma_v^2 + const?
sv = np.array([r[4] for r in rows]); cs = np.array([r[3] for r in rows])
print(f"\n  predicted running slope  d c_s^2 / d sigma_v^2 = -61/210 = {-61/210:+.4f}")
for i in range(len(rows)-1):
    sl = (cs[i+1]-cs[i])/(sv[i+1]-sv[i])
    print(f"    Lambda {LAMBDAS[i]:.1f} -> {LAMBDAS[i+1]:.1f}:  measured {sl:+.4f}"
          f"   ({100*(sl/(-61/210)-1):+.1f}%)")
A = np.polyfit(sv, cs, 1)
print(f"    overall least-squares slope: {A[0]:+.4f}")
# how well do the renormalized curves actually collapse?
E = np.array([r[2]/P11 for r in rows])
spread = (E.max(axis=0)-E.min(axis=0))
B = np.array([r[1]/P11 for r in rows]); bspread = B.max(axis=0)-B.min(axis=0)
for lab, sel in [("inside fit range (k<0.25)", kk <= 0.25), ("beyond it (k>0.25)", kk > 0.25)]:
    print(f"  {lab:28s}: bare {bspread[sel].max()*100:5.2f}  renormalized {spread[sel].max()*100:5.2f}"
          "   (percentage points of P_L)")
i25 = np.argmin(abs(kk-0.25))
print(f"  at k=0.25 exactly: one-loop correction is {(B[-1][i25]-1)*100:.1f}% of P_L,"
      f" cutoff ambiguity {bspread[i25]*100:.2f} points of P_L"
      f"  -> {100*bspread[i25]/(B[-1][i25]-1):.0f}% of the correction")

fig, axes = plt.subplots(1, 2, figsize=(6.9, 3.0), sharey=True)
cols = plt.cm.viridis(np.linspace(0.05, 0.72, len(LAMBDAS)))
dashes = [(None, None), (4, 1.5), (1.6, 1.4), (5, 1.4, 1.4, 1.4)]

def spread_at(curves, kt=0.25):
    i = np.argmin(abs(kk - kt))
    v = np.array([cu[i] for cu in curves])
    return 100 * (v.max() - v.min())

for ax, which, title in [
        (axes[0], 1, r"bare one-loop SPT, cut off at $\Lambda$"),
        (axes[1], 2, r"after fitting one $c_s^2(\Lambda)$ per cutoff")]:
    ax.plot(kk, Pnl / P11, color="k", lw=1.6, zorder=2,
            label="nonlinear reference")
    curves = []
    for (Lam, Pspt, Peft, cs2, sv2), col, dsh in zip(rows, cols, dashes):
        y = (Pspt if which == 1 else Peft) / P11
        curves.append(y)
        lab = (rf"$\Lambda={Lam:.1f}$" if which == 1
               else rf"$\Lambda={Lam:.1f}$, $c_s^2={cs2:.2f}$")
        ln, = ax.plot(kk, y, color=col, lw=1.25, label=lab, zorder=3)
        if dsh[0] is not None:
            ln.set_dashes(list(dsh))
    ax.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
    ax.set_title(title, fontsize=8.5)
    ax.set_xlim(0.02, 0.30)
    ax.set_ylim(0.955, 1.68)
    ax.legend(frameon=False, loc="upper left", handlelength=2.1,
              labelspacing=0.32, borderpad=0.2)
    ax.text(0.97, 0.05,
            "spread at $k=0.25$:  %.1f points of $P_{\\rm L}$" % spread_at(curves),
            transform=ax.transAxes, ha="right", va="bottom", fontsize=7.5,
            bbox=dict(boxstyle="round,pad=0.28", fc="white", ec="0.8", lw=0.6))
axes[0].set_ylabel(r"$P(k)\,/\,P_{\rm L}(k)$")
fig.tight_layout()
fig.savefig(OUT + "cutoff_running.pdf")
print("wrote cutoff_running.pdf")
