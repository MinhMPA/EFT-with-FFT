"""Minimal PT toolkit for the lecture-note figures.

Everything is self-contained (no CAMB/CLASS): the linear spectrum comes from the
Eisenstein & Hu (1998) fitting formulae, which also supply the no-wiggle
spectrum needed for the wiggle/no-wiggle split; the nonlinear reference is
halofit (Takahashi et al. 2012), a fit calibrated to N-body simulations.

One-loop integrals use the standard reduced forms (Makino, Sasaki & Suto 1992;
Jain & Bertschinger 1994), validated in validate.py against direct numerical
integration of the recursion-generated kernels.
"""
import numpy as np
from scipy.integrate import quad, simpson
from scipy.interpolate import CubicSpline

# ---------------------------------------------------------------- cosmology
class Cosmo:
    def __init__(self, Om=0.31, Ob=0.048, h=0.676, ns=0.965, sigma8=0.81, Tcmb=2.7255):
        self.Om, self.Ob, self.h, self.ns, self.s8, self.Tcmb = Om, Ob, h, ns, sigma8, Tcmb
        self.Onu = 0.0
        self._norm = None

    # --- Eisenstein & Hu 1998, full transfer function with baryon wiggles
    def _eh_full(self, k):
        """k in h/Mpc -> T(k). Follows EH98 eqs (1)-(24)."""
        Om, Ob, h, T = self.Om, self.Ob, self.h, self.Tcmb / 2.7
        omh2, obh2 = Om * h * h, Ob * h * h
        fb = Ob / Om
        k = np.atleast_1d(k) * h            # convert to 1/Mpc

        zeq = 2.50e4 * omh2 * T ** -4
        keq = 7.46e-2 * omh2 * T ** -2
        b1 = 0.313 * omh2 ** -0.419 * (1 + 0.607 * omh2 ** 0.674)
        b2 = 0.238 * omh2 ** 0.223
        zd = 1291 * omh2 ** 0.251 / (1 + 0.659 * omh2 ** 0.828) * (1 + b1 * obh2 ** b2)
        Req = 31.5 * obh2 * T ** -4 * (1e3 / zeq)
        Rd = 31.5 * obh2 * T ** -4 * (1e3 / zd)
        s = 2.0 / (3 * keq) * np.sqrt(6.0 / Req) * np.log(
            (np.sqrt(1 + Rd) + np.sqrt(Rd + Req)) / (1 + np.sqrt(Req)))
        ksilk = 1.6 * obh2 ** 0.52 * omh2 ** 0.73 * (1 + (10.4 * omh2) ** -0.95)

        q = k / (13.41 * keq)
        a1 = (46.9 * omh2) ** 0.670 * (1 + (32.1 * omh2) ** -0.532)
        a2 = (12.0 * omh2) ** 0.424 * (1 + (45.0 * omh2) ** -0.582)
        alpha_c = a1 ** (-fb) * a2 ** (-fb ** 3)
        bb1 = 0.944 / (1 + (458 * omh2) ** -0.708)
        bb2 = (0.395 * omh2) ** -0.0266
        beta_c = 1.0 / (1 + bb1 * ((1 - fb) ** bb2 - 1))

        def Tt(kk, ac, bc):
            C = 14.2 / ac + 386.0 / (1 + 69.9 * q ** 1.08)
            return np.log(np.e + 1.8 * bc * q) / (
                np.log(np.e + 1.8 * bc * q) + C * q ** 2)

        f = 1.0 / (1 + (k * s / 5.4) ** 4)
        Tc = f * Tt(k, 1.0, beta_c) + (1 - f) * Tt(k, alpha_c, beta_c)

        y = (1 + zeq) / (1 + zd)
        Gy = y * (-6 * np.sqrt(1 + y) + (2 + 3 * y) *
                  np.log((np.sqrt(1 + y) + 1) / (np.sqrt(1 + y) - 1)))
        alpha_b = 2.07 * keq * s * (1 + Rd) ** -0.75 * Gy
        beta_b = 0.5 + fb + (3 - 2 * fb) * np.sqrt((17.2 * omh2) ** 2 + 1)
        beta_node = 8.41 * omh2 ** 0.435
        st = s / (1 + (beta_node / (k * s)) ** 3) ** (1.0 / 3.0)

        Tb = (Tt(k, 1.0, 1.0) / (1 + (k * s / 5.2) ** 2)
              + alpha_b / (1 + (beta_b / (k * s)) ** 3) * np.exp(-(k / ksilk) ** 1.4)
              ) * np.sinc(k * st / np.pi)
        return fb * Tb + (1 - fb) * Tc

    # --- EH98 "no-wiggle" (smooth) transfer function, eqs (26)-(31)
    def _eh_nw(self, k):
        Om, Ob, h, T = self.Om, self.Ob, self.h, self.Tcmb / 2.7
        omh2, obh2 = Om * h * h, Ob * h * h
        fb = Ob / Om
        k = np.atleast_1d(k) * h
        s = 44.5 * np.log(9.83 / omh2) / np.sqrt(1 + 10 * obh2 ** 0.75)
        alpha = (1 - 0.328 * np.log(431 * omh2) * fb
                 + 0.38 * np.log(22.3 * omh2) * fb ** 2)
        Gamma = Om * h * (alpha + (1 - alpha) / (1 + (0.43 * k * s) ** 4))
        q = k * T ** 2 / (Gamma * h)
        L0 = np.log(2 * np.e + 1.8 * q)
        C0 = 14.2 + 731.0 / (1 + 62.5 * q)
        return L0 / (L0 + C0 * q ** 2)

    def _pk_unnorm(self, k, nowiggle=False):
        T = self._eh_nw(k) if nowiggle else self._eh_full(k)
        return k ** self.ns * T ** 2

    def _sigma8_unnorm(self):
        def integrand(lnk):
            k = np.exp(lnk)
            x = k * 8.0
            W = 3 * (np.sin(x) - x * np.cos(x)) / x ** 3
            return k ** 3 * self._pk_unnorm(k)[0] * W ** 2 / (2 * np.pi ** 2)
        val, _ = quad(integrand, np.log(1e-5), np.log(1e2), limit=200)
        return np.sqrt(val)

    def pk_lin(self, k, nowiggle=False):
        """Linear P(k) at z=0 in (Mpc/h)^3, k in h/Mpc."""
        if self._norm is None:
            self._norm = (self.s8 / self._sigma8_unnorm()) ** 2
        return self._norm * self._pk_unnorm(k, nowiggle)

    def growth(self, z):
        """Linear growth factor normalised to D(0)=1 (flat LCDM)."""
        def integrand(a):
            E = np.sqrt(self.Om / a ** 3 + (1 - self.Om))
            return 1.0 / (a * E) ** 3
        def D(a):
            E = np.sqrt(self.Om / a ** 3 + (1 - self.Om))
            val, _ = quad(integrand, 1e-8, a, limit=200)
            return 2.5 * self.Om * E * val
        return D(1.0 / (1 + z)) / D(1.0)

    def f_growth(self, z):
        a = 1.0 / (1 + z)
        Oma = self.Om / a ** 3 / (self.Om / a ** 3 + 1 - self.Om)
        return Oma ** (5.0 / 9.0)


# ------------------------------------------------------- one-loop integrals
def _make_interp(k, pk):
    """Log-log cubic spline with power-law extrapolation."""
    lk, lp = np.log(k), np.log(pk)
    spl = CubicSpline(lk, lp)
    nlo = (lp[1] - lp[0]) / (lk[1] - lk[0])
    nhi = (lp[-1] - lp[-2]) / (lk[-1] - lk[-2])
    def P(q):
        q = np.atleast_1d(np.asarray(q, dtype=float))
        out = np.zeros_like(q)
        lo, hi = q < k[0], q > k[-1]
        mid = ~(lo | hi)
        out[mid] = np.exp(spl(np.log(q[mid])))
        out[lo] = pk[0] * (q[lo] / k[0]) ** nlo
        out[hi] = pk[-1] * (q[hi] / k[-1]) ** nhi
        return out
    return P


def p13(kout, k, pk, rmax=200.0, nr=800):
    """P_13 via the reduced 1D integral (Makino+92; Jain & Bertschinger 94)."""
    P = _make_interp(k, pk)
    lr = np.linspace(np.log(1e-4), np.log(rmax), nr)
    r = np.exp(lr)
    out = np.empty_like(kout)
    for i, kk in enumerate(kout):
        rr = r.copy()
        # kernel: analytic angle average of 6 F3(k,q,-q)
        with np.errstate(divide='ignore', invalid='ignore'):
            ker = (12.0 / rr ** 2 - 158.0 + 100.0 * rr ** 2 - 42.0 * rr ** 4
                   + 3.0 / rr ** 3 * (rr ** 2 - 1.0) ** 3 * (7.0 * rr ** 2 + 2.0)
                   * np.log(np.abs((1.0 + rr) / (1.0 - rr))))
        # regularise the integrable r->1 point
        bad = ~np.isfinite(ker)
        if bad.any():
            ker[bad] = np.interp(rr[bad], rr[~bad], ker[~bad])
        integ = P(kk * rr) * ker * rr          # extra r from d(ln r)
        out[i] = kk ** 3 * P(np.array([kk]))[0] / (252.0 * 4 * np.pi ** 2) * \
            simpson(integ, x=lr)
    return out


def p22(kout, k, pk, rmax=1e3, nr=1200, ny=300):
    """P_22 via the reduced 2D integral.

    Uses the second momentum y = |k-q|/k as the inner variable instead of the
    angle. With x = (1+r^2-y^2)/(2r) and dx = -(y/r) dy the integrand is smooth
    everywhere (the kernel numerator vanishes fast enough to kill the 1/y^3),
    which the (r,x) form does not achieve for a LCDM input.
    """
    P = _make_interp(k, pk)
    lr = np.linspace(np.log(1e-5), np.log(rmax), nr)
    r = np.exp(lr)
    t, wt = np.polynomial.legendre.leggauss(ny)      # nodes on [-1,1]
    t = 0.5 * (t + 1.0)                              # map to [0,1]
    wt = 0.5 * wt
    ylo = np.abs(1.0 - r)[:, None]
    yhi = (1.0 + r)[:, None]
    Y = ylo + (yhi - ylo) * t[None, :]               # (nr, ny)
    W = (yhi - ylo) * wt[None, :]
    R = r[:, None]
    X = (1.0 + R ** 2 - Y ** 2) / (2.0 * R)
    num = (3.0 * R + 7.0 * X - 10.0 * R * X ** 2) ** 2
    out = np.empty_like(kout)
    for i, kk in enumerate(kout):
        f = (P((kk * R).ravel()).reshape(R.shape)
             * P((kk * Y).ravel()).reshape(Y.shape)
             * num / (R * Y ** 3))
        inner = np.sum(f * W, axis=1)                # integral over y
        out[i] = kk ** 3 / (98.0 * 4 * np.pi ** 2) * simpson(inner * r, x=lr)
    return out


# ------------------------------------------- halofit (Takahashi et al. 2012)
def halofit(kout, k, pk, Om_z, Ode_z):
    """Nonlinear P(k) from halofit as recalibrated by Takahashi et al. (2012).

    Om_z, Ode_z are the matter and dark-energy density parameters at the
    redshift of the input spectrum. w = -1 is assumed, so the (1+w) terms drop.
    """
    P = _make_interp(k, pk)
    lnk = np.linspace(np.log(1e-5), np.log(1e3), 6000)
    kk = np.exp(lnk)
    D2 = kk ** 3 * P(kk) / (2 * np.pi ** 2)

    # sigma^2(R) = 1 defines the nonlinear scale
    def sig2(R):
        return simpson(D2 * np.exp(-(kk * R) ** 2), x=lnk)
    lo, hi = 1e-4, 1e4
    for _ in range(300):
        mid = np.sqrt(lo * hi)
        if sig2(mid) > 1.0:
            lo = mid
        else:
            hi = mid
    R = np.sqrt(lo * hi)
    ksig = 1.0 / R

    y2 = (kk * R) ** 2
    w = D2 * np.exp(-y2)
    S = simpson(w, x=lnk)
    A = simpson(w * y2, x=lnk) / S          # <y^2>
    B = simpson(w * y2 ** 2, x=lnk) / S     # <y^4>
    n = -3.0 + 2.0 * A                      # effective slope
    C = 4.0 * A ** 2 + 4.0 * A - 4.0 * B    # effective curvature

    an = 10 ** (1.5222 + 2.8553*n + 2.3706*n**2 + 0.9903*n**3
                + 0.2250*n**4 - 0.6038*C)
    bn = 10 ** (-0.5642 + 0.5864*n + 0.5716*n**2 - 1.5474*C)
    cn = 10 ** (0.3698 + 2.0404*n + 0.8161*n**2 + 0.5869*C)
    gam = 0.1971 - 0.0843*n + 0.8460*C
    alp = np.abs(6.0835 + 1.3373*n - 0.1959*n**2 - 5.5274*C)
    bet = (2.0379 - 0.7354*n + 0.3157*n**2 + 1.2490*n**3
           + 0.3980*n**4 - 0.1682*C)
    mu = 0.0
    nu = 10 ** (5.2105 + 3.6902*n)
    f1 = Om_z ** -0.0307
    f2 = Om_z ** -0.0585
    f3 = Om_z ** 0.0743

    y = kout / ksig
    D2L = kout ** 3 * P(kout) / (2 * np.pi ** 2)
    D2Q = D2L * ((1 + D2L) ** bet / (1 + alp * D2L)) * np.exp(-(y / 4 + y**2 / 8))
    D2Hp = an * y ** (3 * f1) / (1 + bn * y ** f2 + (cn * f3 * y) ** (3 - gam))
    D2H = D2Hp / (1 + mu / y + nu / y ** 2)
    return (D2Q + D2H) * 2 * np.pi ** 2 / kout ** 3, ksig, n
