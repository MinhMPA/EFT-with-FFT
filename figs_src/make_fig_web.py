"""Figure: the cosmic web from a Zel'dovich displacement.

Left  -- projected density of a Zel'dovich-displaced field.
Right -- every particle classified by how many eigenvalues of the deformation
         tensor are collapsing: void, sheet, filament, knot. The same T-web
         classification the Cosmic Web Sandbox uses, and the same conventions:
         Eisenstein & Hu transfer function, 250 Mpc/h box, fixed seed.

Self-contained: uses ptlib only. Writes ../figs/cosmic_web.pdf
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, BoundaryNorm
import ptlib

plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "figure.dpi": 200,
    "savefig.bbox": "tight", "axes.linewidth": 0.7, "font.family": "serif",
})
OUT = "../figs/"
N, L, SEED, Z = 128, 250.0, 1234, 0.0          # grid, box (Mpc/h), seed, redshift

c = ptlib.Cosmo(); D = c.growth(Z)
rng = np.random.default_rng(SEED)

kf = 2*np.pi/L
kx = np.fft.fftfreq(N, d=1.0/N)*kf
KX, KY, KZ = np.meshgrid(kx, kx, np.fft.rfftfreq(N, d=1.0/N)*kf, indexing="ij")
K2 = KX**2+KY**2+KZ**2; K2[0,0,0] = 1.0
P = c.pk_lin(np.sqrt(K2).ravel()).reshape(K2.shape)*D**2
P[0,0,0] = 0.0

# white noise in real space -> correct-variance modes
# Var(delta) = int d^3k/(2pi)^3 P(k) requires dk = rfftn(w) sqrt(P N^3 / L^3)
wn = rng.standard_normal((N,N,N))
dk = np.fft.rfftn(wn) * np.sqrt(P * N**3 / L**3)
dk[0,0,0] = 0.0
print(f"  rms of delta on this grid: {np.std(np.fft.irfftn(dk, s=(N,)*3)):.2f}"
      f"   (expected 2.32 for k_Nyq = 1.61 h/Mpc)")

# Zel'dovich displacement  Psi(k) = i k / k^2  delta(k)
q = (np.arange(N)+0.5)*(L/N)
Q = np.meshgrid(q, q, q, indexing="ij")
pos = []
for i, Ki in enumerate((KX, KY, KZ)):
    psi = np.fft.irfftn(1j*Ki/K2*dk, s=(N,)*3)
    pos.append((Q[i] + psi).ravel() % L)
print(f"  rms displacement per axis: {np.std(np.fft.irfftn(1j*KX/K2*dk, s=(N,)*3)):.2f} Mpc/h   (expected 5.78)")

# deformation tensor  D_ij(k) = k_i k_j delta(k) / k^2 ; count positive eigenvalues
comp = {}
ks = (KX, KY, KZ)
for i in range(3):
    for j in range(i, 3):
        comp[(i,j)] = np.fft.irfftn(ks[i]*ks[j]/K2*dk, s=(N,)*3).ravel()
M = np.empty((N**3, 3, 3), dtype=np.float32)
for i in range(3):
    for j in range(i, 3):
        M[:, i, j] = M[:, j, i] = comp[(i,j)]
npos = (np.linalg.eigvalsh(M) > 0).sum(axis=1)
del M, comp
frac = [100*(npos == n).mean() for n in range(4)]
print("  web-type volume fractions from this realization:")
for n, lab in enumerate(["void","sheet","filament","knot"]):
    print(f"    {n} collapsing axes  {lab:9s} {frac[n]:5.1f}%   (Gaussian expectation 8/42/42/8)")

# --- slab projection
TH = 15.0
sel = pos[2] < TH
fig, ax = plt.subplots(1, 2, figsize=(6.9, 3.5))
H, xe, ye = np.histogram2d(pos[0][sel], pos[1][sel], bins=400, range=[[0,L],[0,L]])
ax[0].imshow(np.log10(H.T+1), origin="lower", extent=[0,L,0,L], cmap="bone_r",
             interpolation="nearest")
ax[0].set_title(f"projected density, {TH:.0f}" + r"$\,h^{-1}$Mpc slab", fontsize=8.5)

cols = ["#d9d9d9", "#7fbf8f", "#2f6ea5", "#e8590c"]   # void recedes, knots pop
cmap = ListedColormap(cols); norm = BoundaryNorm([-.5,.5,1.5,2.5,3.5], 4)
# draw in order of increasing collapse so knots end up on top
sub = np.random.default_rng(1).permutation(np.flatnonzero(sel))[:400000]
cls = npos.ravel()[sub]
for n, (cl, sz) in enumerate(zip(cols, [0.20, 0.28, 0.35, 0.55])):
    m = cls == n
    ax[1].scatter(pos[0][sub][m], pos[1][sub][m], c=cl, s=sz, marker=".",
                  linewidths=0, rasterized=True, zorder=2+n)
ax[1].set_xlim(0,L); ax[1].set_ylim(0,L); ax[1].set_aspect("equal")
ax[1].set_title("classified by collapsing axes", fontsize=8.5)
for n,(lab,cl) in enumerate(zip(["void","sheet","filament","knot"], cols)):
    ax[1].scatter([],[],c=cl,s=14,marker="s",label=f"{lab} ({frac[n]:.0f}%)")
ax[1].legend(frameon=True, loc="upper right", fontsize=6.2, labelspacing=0.25,
             handletextpad=0.3, facecolor="white", edgecolor="0.8", framealpha=0.9)
for a in ax:
    a.set_xlabel(r"$x\ [h^{-1}\mathrm{Mpc}]$")
ax[0].set_ylabel(r"$y\ [h^{-1}\mathrm{Mpc}]$")
fig.tight_layout()
fig.savefig(OUT + "cosmic_web.pdf", dpi=220)
print("wrote cosmic_web.pdf")
