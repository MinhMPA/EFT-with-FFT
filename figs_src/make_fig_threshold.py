"""Figure: how a long mode biases the count of regions above threshold.

The picture Desjacques, Jeong & Schmidt draw as their Fig. 3, but from our own
field and our own seed, so the numbers in the caption are measurable rather
than illustrative.

Left  -- a 1D cut of the linear field smoothed on R = 5 Mpc/h, with and without
         a long-wavelength mode added. The threshold is a fixed horizontal line;
         what changes is how much of the curve pokes above it.
Right -- the abundance n(delta_L) = (1/2) erfc[(delta_cr - delta_L)/(sqrt2 sigma)]
         against the measured counts, with the slope at the origin -- which is
         b_1 -- drawn as a tangent.

Self-contained: uses ptlib only. Writes ../figs/threshold_bias.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy.special import erfc
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "lines.linewidth": 1.3, "font.family": "serif",
})
OUT = "../figs/"
N, L, SEED = 256, 500.0, 1234          # bigger box: we want many independent peaks
R_SMOOTH = 5.0                          # Mpc/h, the proto-halo filter scale
DELTA_CR = 1.686

c = ptlib.Cosmo()
kf = 2*np.pi/L
kx = np.fft.fftfreq(N, d=1.0/N)*kf
KX, KY, KZ = np.meshgrid(kx, kx, np.fft.rfftfreq(N, d=1.0/N)*kf, indexing="ij")
K2 = KX**2 + KY**2 + KZ**2
K2[0, 0, 0] = 1.0
kmag = np.sqrt(K2)

P = c.pk_lin(kmag.ravel()).reshape(K2.shape)
P[0, 0, 0] = 0.0

rng = np.random.default_rng(SEED)
dk = np.fft.rfftn(rng.standard_normal((N, N, N))) * np.sqrt(P * N**3 / L**3)
dk[0, 0, 0] = 0.0

# Gaussian filter on R_SMOOTH: this is the "proto-halo" scale
W = np.exp(-0.5 * (kmag * R_SMOOTH)**2)
dR = np.fft.irfftn(dk * W, s=(N, N, N))
sigma = float(dR.std())
nu_c = DELTA_CR / sigma
print(f"  R = {R_SMOOTH} Mpc/h  ->  sigma(R) = {sigma:.4f},  nu_c = {nu_c:.3f}")

# --- the exact and predicted abundance -------------------------------------
n_of_dL = lambda dL: 0.5*erfc((DELTA_CR - dL)/(np.sqrt(2)*sigma))
b1_pred = (np.sqrt(2/np.pi)*np.exp(-nu_c**2/2)
           / (sigma*erfc(nu_c/np.sqrt(2))))
print(f"  predicted b1 = {b1_pred:.3f}    (rare limit delta_cr/sigma^2 = "
      f"{DELTA_CR/sigma**2:.3f})")

# --- measure it: add a uniform shift, recount ------------------------------
# b_1 is the tangent at delta_L = 0. Fitting across a wide range gives a secant
# of a convex curve and overestimates it -- 5.1 instead of 4.3 at |dL| < 0.35 --
# so measure narrow, and plot wide.
n0 = float((dR > DELTA_CR).mean())
narrow = np.linspace(-0.02, 0.02, 9)
b1_meas = float(np.polyfit(narrow,
                np.array([(dR + s > DELTA_CR).mean() for s in narrow])/n0, 1)[0])
shifts = np.linspace(-0.35, 0.35, 15)
frac = np.array([(dR + s > DELTA_CR).mean() for s in shifts])
resid = np.abs((frac/n0)/(n_of_dL(shifts)/n_of_dL(0.0)) - 1).max()
print(f"  measured   b1 = {b1_meas:.3f}   (tangent, |delta_L| < 0.02)")
print(f"  n_bar: measured {n0:.4e}, predicted {n_of_dL(0.0):.4e}")
print(f"  counted points sit on the erfc curve to {100*resid:.1f}% over the plotted range")

# ---------------------------------------------------------------- figure ---
fig, ax = plt.subplots(1, 2, figsize=(9.8, 3.6))

# LEFT: the mechanism, on a short cut where individual peaks are resolved.
# This panel does NOT carry the statistics -- at this rarity a line crosses the
# threshold about once per 1600 Mpc/h, so no honest cut shows a count changing.
# The right panel does the counting. Here we only show what the long mode does,
# using the move the derivation makes: lifting the field by delta_L is the same
# as lowering the cut to delta_cr - delta_L, so draw one field and two lines.
JC, KC, S0, WIN = 242, 62, 32, 64
cut  = dR[S0:S0+WIN, JC, KC]
qcut = (np.arange(S0, S0+WIN))*(L/N)
DL   = 0.30
lo   = DELTA_CR - DL

ax[0].axhspan(lo, DELTA_CR, color="#e8590c", alpha=0.13, zorder=0)
ax[0].axhline(DELTA_CR, color="0.15", lw=1.2, zorder=3)
ax[0].axhline(lo,       color="#e8590c", lw=1.2, ls="--", zorder=3)
ax[0].plot(qcut, cut, color="#1d3557", lw=1.5, zorder=4)

pk   = (cut[1:-1] > cut[:-2]) & (cut[1:-1] > cut[2:])
qp, vp = qcut[1:-1][pk], cut[1:-1][pk]
sel_a = vp > DELTA_CR
sel_b = (vp > lo) & (vp <= DELTA_CR)
ax[0].plot(qp[sel_a], vp[sel_a], "o", color="0.15", ms=7, zorder=6,
           label=f"already a halo ({sel_a.sum()})")
ax[0].plot(qp[sel_b], vp[sel_b], "o", color="#e8590c", ms=7, zorder=6,
           label=f"becomes one ({sel_b.sum()})")
print(f"  cut shown: {sel_a.sum()} peaks above, {sel_b.sum()} inside the band")

ax[0].text(qcut[1], DELTA_CR + 0.055, r"$\delta_{\rm cr}$", color="0.15", fontsize=9)
ax[0].text(qcut[1], lo - 0.15, r"$\delta_{\rm cr} - \delta_L$",
           color="#e8590c", fontsize=9)
ax[0].set_xlim(qcut[0], qcut[-1]); ax[0].set_ylim(-0.75, 2.62)
ax[0].set_xlabel(r"Lagrangian position $q\ [h^{-1}\mathrm{Mpc}]$")
ax[0].set_ylabel(r"$\delta_R$, smoothed on $R = 5\,h^{-1}$Mpc")
ax[0].set_title(r"a long mode lowers the cut, it does not move the field",
                fontsize=9)
ax[0].legend(loc="lower left", frameon=False, fontsize=7.5)

# RIGHT: abundance vs long mode, measured against predicted
dL = np.linspace(-0.45, 0.45, 300)
ax[1].plot(dL, n_of_dL(dL)/n_of_dL(0.0), color="#1d3557", lw=1.4,
           label=r"$\frac{1}{2}\mathrm{erfc}\!\left[\frac{\delta_{\rm cr}-\delta_L}{\sqrt{2}\sigma}\right]$")
ax[1].plot(shifts, frac/n0, "o", color="#e07a5f", ms=4.5, mec="white", mew=0.7,
           label="counted from the field", zorder=5)
ax[1].plot(dL, 1 + b1_pred*dL, color="0.45", ls=":", lw=1.2,
           label=rf"slope $b_1 = {b1_pred:.2f}$")
ax[1].axhline(1.0, color="0.8", lw=0.7); ax[1].axvline(0.0, color="0.8", lw=0.7)
ax[1].set_xlim(-0.45, 0.45); ax[1].set_ylim(0.15, 3.0)
ax[1].set_xlabel(r"long-wavelength mode $\delta_L$")
ax[1].set_ylabel(r"$n(\delta_L)\,/\,\bar n$")
ax[1].legend(loc="upper left", frameon=False, fontsize=7.5)
ax[1].set_title("but it moves the count a lot", fontsize=9)

fig.tight_layout()
fig.savefig(OUT + "threshold_bias.pdf")
print("wrote threshold_bias.pdf")
