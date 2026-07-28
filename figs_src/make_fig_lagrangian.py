"""Figure: the Lagrangian map, x = q + Psi, and the Jacobian that follows.

Left  -- a regular grid of Lagrangian labels q, each with an arrow to where the
         Zel'dovich displacement puts it. The labels never move; the matter does.
Right -- the same cells drawn as the quadrilaterals they become, shaded by
         1/J = 1 + delta. Cells that shrink are overdense; cells that expand are
         underdense. This is eq. (2.3) with nothing hidden.

Real field, not a schematic: same spectrum, box and seed as the other figures,
projected to two dimensions.

Self-contained: uses ptlib only. Writes ../figs/lagrangian_map.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8,
    "xtick.labelsize": 8, "ytick.labelsize": 8,
    "figure.dpi": 200, "savefig.bbox": "tight", "axes.linewidth": 0.7,
    "font.family": "serif",
})
OUT = "../figs/"
N, L, SEED = 512, 250.0, 1234       # 2D grid, box in Mpc/h
NG = 14                              # Lagrangian grid points per side, drawn
SUB = 120.0                          # sub-region shown, Mpc/h

c = ptlib.Cosmo()
kf = 2*np.pi/L
kx = np.fft.fftfreq(N, d=1.0/N)*kf
KX, KY = np.meshgrid(kx, np.fft.rfftfreq(N, d=1.0/N)*kf, indexing="ij")
K2 = KX**2 + KY**2
K2[0, 0] = 1.0

# A 2D field with the 3D linear spectrum is not a physical 2D universe, but it
# has the right correlation structure for a picture. Amplitude set so that the
# rms displacement is a visible fraction of a cell.
P = c.pk_lin(np.sqrt(K2).ravel()).reshape(K2.shape)
P[0, 0] = 0.0
rng = np.random.default_rng(SEED)
dk = np.fft.rfftn(rng.standard_normal((N, N))) * np.sqrt(P * N**2 / L**2)
dk[0, 0] = 0.0

# Zel'dovich displacement in 2D: Psi(k) = i k / k^2 delta(k)
psi_x = np.fft.irfftn(1j*KX/K2*dk, s=(N, N))
psi_y = np.fft.irfftn(1j*KY/K2*dk, s=(N, N))
# A 3D P(k) imposed on a 2D field has the wrong variance, so the raw amplitude
# is meaningless here (and shell-crosses everything). Rescale so the typical
# displacement is a set fraction of the drawn cell -- this figure illustrates the
# map, and the caption says the amplitude is chosen for legibility.
spacing = SUB/(NG-1)
rms_raw = np.sqrt((psi_x**2 + psi_y**2).mean())
scale = 0.46*spacing/rms_raw
psi_x, psi_y = psi_x*scale, psi_y*scale
print(f"  rms displacement set to {0.46*spacing:.2f} Mpc/h "
      f"= 0.46 cells (raw was {rms_raw:.1f}, rescaled by {scale:.4f})")

# sample the displacement on the drawn Lagrangian grid
g = np.linspace(0, SUB, NG)
QX, QY = np.meshgrid(g, g, indexing="ij")
ix = (QX/L*N).astype(int) % N
iy = (QY/L*N).astype(int) % N
PX, PY = psi_x[ix, iy], psi_y[ix, iy]
XX, XY = QX + PX, QY + PY

fig, ax = plt.subplots(1, 2, figsize=(9.6, 4.5))

# ---- LEFT: the map ---------------------------------------------------------
for i in range(NG):
    ax[0].plot(QX[i, :], QY[i, :], color="0.86", lw=0.6, zorder=0)
    ax[0].plot(QX[:, i], QY[:, i], color="0.86", lw=0.6, zorder=0)
ax[0].quiver(QX, QY, PX, PY, angles="xy", scale_units="xy", scale=1.0,
             width=0.0035, color="#e07a5f", zorder=3)
ax[0].plot(QX, QY, ".", color="0.55", ms=2.5, zorder=2)
ax[0].plot(XX, XY, ".", color="#1d3557", ms=3.6, zorder=4)

# one element called out
i0, j0 = NG//2, NG//2 - 3
ax[0].annotate("", xy=(XX[i0, j0], XY[i0, j0]), xytext=(QX[i0, j0], QY[i0, j0]),
               arrowprops=dict(arrowstyle="-|>", color="k", lw=1.5, mutation_scale=13),
               zorder=6)
ax[0].plot([QX[i0, j0]], [QY[i0, j0]], "o", color="0.35", ms=5.5, zorder=7)
ax[0].plot([XX[i0, j0]], [XY[i0, j0]], "o", color="#1d3557", ms=5.5, zorder=7)
bb = dict(fc="white", ec="none", alpha=0.85, pad=1.0)
ax[0].text(QX[i0, j0]-8.5, QY[i0, j0]-7.5, r"$\mathbf{q}$", fontsize=12,
           color="0.2", bbox=bb, zorder=8)
ax[0].text(XX[i0, j0]+4.0, XY[i0, j0]+4.5, r"$\mathbf{x}$", fontsize=12,
           color="#1d3557", bbox=bb, zorder=8)
ax[0].text(0.5*(QX[i0, j0]+XX[i0, j0])+5.5, 0.5*(QY[i0, j0]+XY[i0, j0])-2.0,
           r"$\mathbf{\Psi}$", fontsize=12, color="k", bbox=bb, zorder=8)
ax[0].text(0.5, 0.015, "grey grid and dots: the labels $q$, which never move.  "
           "blue dots: where the matter went.",
           transform=ax[0].transAxes, ha="center", fontsize=7, color="0.4")
ax[0].set_title(r"$\mathbf{x}(\mathbf{q},\tau) = \mathbf{q} + \mathbf{\Psi}(\mathbf{q},\tau)$", fontsize=10)

# ---- RIGHT: the Jacobian ---------------------------------------------------
polys, vals = [], []
for i in range(NG-1):
    for j in range(NG-1):
        quad = [(XX[i, j], XY[i, j]), (XX[i+1, j], XY[i+1, j]),
                (XX[i+1, j+1], XY[i+1, j+1]), (XX[i, j+1], XY[i, j+1])]
        qx4 = np.array([p[0] for p in quad]); qy4 = np.array([p[1] for p in quad])
        A = 0.5*abs(np.dot(qx4, np.roll(qy4, -1)) - np.dot(qy4, np.roll(qx4, -1)))
        A0 = (SUB/(NG-1))**2
        polys.append(quad); vals.append(A0/A)          # 1/J = 1 + delta
vals = np.array(vals)
pc = PolyCollection(polys, array=vals, cmap="RdBu_r", edgecolors="0.4",
                    linewidths=0.4, norm=plt.Normalize(0.3, 1.7))
ax[1].add_collection(pc)
cb = fig.colorbar(pc, ax=ax[1], fraction=0.046, pad=0.03)
cb.set_label(r"$1/J = 1+\delta$", fontsize=9)
ax[1].set_title(r"cells that shrink are overdense: $1+\delta = 1/J$", fontsize=10)
print(f"  cell 1/J ranges {vals.min():.2f} to {vals.max():.2f}")

for a in ax:
    a.set_xlim(-8, SUB+8); a.set_ylim(-8, SUB+8); a.set_aspect("equal")
    a.set_xlabel(r"comoving $[\,h^{-1}\mathrm{Mpc}\,]$")
ax[0].set_ylabel(r"comoving $[\,h^{-1}\mathrm{Mpc}\,]$")
fig.tight_layout()
fig.savefig(OUT + "lagrangian_map.pdf")
print("wrote lagrangian_map.pdf")
