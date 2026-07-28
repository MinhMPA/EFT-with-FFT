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
fig, ax = plt.subplots(1, 2, figsize=(9.8, 4.0))

# LEFT: a 2D slice. A 1D cut cannot show "more regions" -- it holds too few.
# Here every cell above threshold is drawn, in two colours: those that were
# already above without the long mode, and those the long mode pushed over.
sl   = dR[:, :, N//3]
xs   = np.arange(N)*(L/N)
lm2d = 0.30*np.sin(2*np.pi*xs/L)[:, None]*np.ones((1, N))

was  = sl > DELTA_CR                       # above without the long mode
now_ = (sl + lm2d) > DELTA_CR              # above with it
new  = now_ & ~was
lost = was & ~now_
print(f"  2D slice: {was.sum()} cells above threshold -> {now_.sum()} "
      f"({new.sum()} gained, {lost.sum()} lost)")

ax[0].imshow(lm2d.T, origin="lower", extent=[0, L, 0, L], cmap="RdBu_r",
             vmin=-0.9, vmax=0.9, interpolation="bilinear", zorder=0)
ys, xs2 = np.nonzero(was)
ax[0].plot(xs2*(L/N), ys*(L/N), "s", color="0.15", ms=1.4, mew=0,
           label=f"above threshold already ({was.sum()})", zorder=3)
ys, xs2 = np.nonzero(new)
ax[0].plot(xs2*(L/N), ys*(L/N), "s", color="#e8590c", ms=1.4, mew=0,
           label=f"pushed over by $\\delta_L$ (+{new.sum()})", zorder=4)
ax[0].set_xlim(0, L); ax[0].set_ylim(0, L)
ax[0].set_xlabel(r"$q_x\ [h^{-1}\mathrm{Mpc}]$")
ax[0].set_ylabel(r"$q_y\ [h^{-1}\mathrm{Mpc}]$")
ax[0].set_title(r"where the long mode is positive, more regions cross",
                fontsize=9)
leg = ax[0].legend(loc="upper right", frameon=True, fontsize=7,
                   markerscale=4, framealpha=0.9)
leg.get_frame().set_edgecolor("none")

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
