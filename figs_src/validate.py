"""Validate the reduced one-loop formulas in ptlib against direct integration
with kernels built from the recursion relations (Eqs. 1.18-1.19 of the notes)."""
import numpy as np
from itertools import permutations
import ptlib

# ---- kernels straight from the recursion, symmetrised (independent of ptlib)
def alpha(a, b): return np.dot(a + b, a) / np.dot(a, a)
def beta(a, b):
    ab = a + b
    return np.dot(ab, ab) * np.dot(a, b) / (2 * np.dot(a, a) * np.dot(b, b))
def F2u(a, b): return (5 * alpha(a, b) + 2 * beta(a, b)) / 7
def G2u(a, b): return (3 * alpha(a, b) + 4 * beta(a, b)) / 7
def F3u(a, b, c):
    t1 = 7 * alpha(a, b + c) * F2u(b, c) + 2 * beta(a, b + c) * G2u(b, c)
    t2 = G2u(a, b) * (7 * alpha(a + b, c) + 2 * beta(a + b, c))
    return (t1 + t2) / 18
def F2s(a, b): return 0.5 * (F2u(a, b) + F2u(b, a))
def F3s(a, b, c): return sum(F3u(*p) for p in permutations([a, b, c])) / 6

print("=" * 68)
print("1. Angle-averaged F3 vs the reduced P13 kernel")
print("=" * 68)
# P13 = (3/pi^2) P(k) k^3 int dr r^2 <F3> P(kr)  and the reduced form implies
#       <F3>(r) = K(r) / (3024 r^2)
nodes, weights = np.polynomial.legendre.leggauss(200)
def F3_avg(r, eps=1e-7):
    k = np.array([0.0, 0.0, 1.0])
    tot = 0.0
    for x, w in zip(nodes, weights):
        q = r * np.array([np.sqrt(max(0.0, 1 - x * x)), 0.0, x])
        qm = -q + eps * np.array([0.31, 0.72, 0.62])
        tot += w * F3s(k, q, qm)
    return 0.5 * tot
def Kred(r):
    return (12 / r**2 - 158 + 100 * r**2 - 42 * r**4
            + 3 / r**3 * (r**2 - 1)**3 * (7 * r**2 + 2)
            * np.log(abs((1 + r) / (1 - r))))
print(f"{'r':>8} {'<F3> direct':>15} {'K(r)/3024r^2':>15} {'ratio':>10}")
ok = True
for r in [0.05, 0.2, 0.5, 0.8, 1.3, 2.0, 5.0, 20.0]:
    a, b = F3_avg(r), Kred(r) / (3024 * r**2)
    ok &= abs(a / b - 1) < 2e-4
    print(f"{r:8.2f} {a:15.6e} {b:15.6e} {a/b:10.6f}")
print("PASS" if ok else "FAIL")

print()
print("=" * 68)
print("2. Reduced P22 kernel vs symmetrised F2 from the recursion")
print("=" * 68)
# reduced integrand uses F2^2 = (3r+7x-10rx^2)^2 / (14 r (1+r^2-2rx))^2 * ... ;
# check F2s(q, k-q) equals (3r+7x-10rx^2)/(14 r (1+r^2-2rx)) with q=kr
ok2 = True
print(f"{'r':>8} {'x':>7} {'F2 direct':>14} {'F2 reduced':>14} {'ratio':>10}")
for r, x in [(0.3, 0.4), (0.7, -0.6), (1.5, 0.2), (3.0, 0.9), (0.1, -0.95)]:
    k = np.array([0.0, 0.0, 1.0])
    q = r * np.array([np.sqrt(1 - x * x), 0.0, x])
    a = F2s(q, k - q)
    b = (3 * r + 7 * x - 10 * r * x**2) / (14 * r * (1 + r**2 - 2 * r * x))
    ok2 &= abs(a / b - 1) < 1e-10
    print(f"{r:8.2f} {x:7.2f} {a:14.6e} {b:14.6e} {a/b:10.6f}")
print("PASS" if ok2 else "FAIL")

print()
print("=" * 68)
print("3. Grid independence on a scale-free spectrum")
print("=" * 68)
# NOTE: this does NOT test the IR cancellation. _make_interp extrapolates the
# input as a power law below the tabulated range, so the effective lower limit
# of the loop integrals is set by rmin inside p22/p13, not by the grid. What
# this checks is that the answer does not depend on how the input is tabulated.
# The IR cancellation itself is verified analytically in the solutions manual
# (Exercise 1.3) and numerically via the soft limits in test 1.
kk = np.array([0.1])
for eps in [1e-3, 1e-4, 1e-5]:
    kg = np.logspace(np.log10(eps), 3, 3000)
    pg = 1.0 * kg ** -2.0
    a = ptlib.p22(kk, kg, pg)[0]
    b = ptlib.p13(kk, kg, pg)[0]
    print(f"  grid from {eps:8.1e}:  P22 = {a: .6e}  P13 = {b: .6e}  "
          f"sum = {a+b: .6e}")
print("  (all three rows should agree)")

print()
print("=" * 68)
print("4. Sanity: sigma8 normalisation and BAO wiggle amplitude")
print("=" * 68)
c = ptlib.Cosmo()
kg = np.logspace(-4, 2, 800)
pl = c.pk_lin(kg)
pnw = c.pk_lin(kg, nowiggle=True)
from scipy.integrate import simpson
W = 3 * (np.sin(kg * 8) - kg * 8 * np.cos(kg * 8)) / (kg * 8) ** 3
s8 = np.sqrt(simpson(kg ** 3 * pl * W ** 2 / (2 * np.pi ** 2), x=np.log(kg)))
sel = (kg > 0.05) & (kg < 0.3)
print(f"  sigma8 recovered  = {s8:.4f}  (target 0.8100)")
print(f"  max |P_w/P_nw - 1| in 0.05-0.3 h/Mpc = "
      f"{np.max(np.abs(pl[sel]/pnw[sel]-1)):.3f}  (expect ~0.05-0.10)")
print(f"  D(z=0.5) = {c.growth(0.5):.4f},  f(z=0.5) = {c.f_growth(0.5):.4f}")
