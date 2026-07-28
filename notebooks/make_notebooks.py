"""Generate the Hands-on 1 notebooks.

Single source of truth for both the student notebook and the solutions
notebook. Cells are declared once, below, in reading order:

    M(text)             a markdown cell, identical in both
    C(code)             a code cell, identical in both (given to students)
    S(solution, stub)   a code cell that differs: students get `stub`
    SM(answer, bait)    a markdown cell that differs: students get `bait`

Both notebooks always have the same number of cells, so a passage meant only
for the solutions still occupies a cell in the student notebook -- SM is how a
worked answer is withheld while leaving a question in its place.

Run this file to write notebooks/H1_gaussian_field.ipynb and
notebooks/H1_gaussian_field_solutions.ipynb. Never edit the .ipynb by hand.
"""
import json
import os

CELLS = []


def M(src):
    """Markdown cell, same in both notebooks."""
    CELLS.append(("markdown", src, src))


def C(src):
    """Code cell, same in both notebooks -- i.e. given to the students."""
    CELLS.append(("code", src, src))


def S(solution, stub):
    """Code cell the students write. `stub` is what they start from."""
    CELLS.append(("code", solution, stub))


def SM(answer, bait):
    """Markdown cell that differs: the solutions get `answer`, students `bait`."""
    CELLS.append(("markdown", answer, bait))


def _source(text):
    """LaTeX-free, trailing-newline-correct source list for nbformat v4."""
    lines = text.strip("\n").split("\n")
    return [ln + "\n" for ln in lines[:-1]] + [lines[-1]]


def _cell(kind, text, idx):
    base = {"id": f"c{idx:03d}", "metadata": {}, "source": _source(text)}
    if kind == "markdown":
        return {"cell_type": "markdown", **base}
    return {"cell_type": "code", "execution_count": None, "outputs": [], **base}


def build(which):
    """which in {'student', 'solutions'} -> an nbformat v4 notebook dict."""
    assert which in ("student", "solutions"), which
    return {
        "cells": [_cell(kind, sol if which == "solutions" else stu, i)
                  for i, (kind, sol, stu) in enumerate(CELLS)],
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "language": "python",
                           "name": "python3"},
            "language_info": {"name": "python", "version": "3.10"},
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    for which, name in (("student", "H1_gaussian_field.ipynb"),
                        ("solutions", "H1_gaussian_field_solutions.ipynb")):
        path = os.path.join(here, name)
        with open(path, "w") as fh:
            json.dump(build(which), fh, indent=1)
            fh.write("\n")
        print(f"wrote {name}  ({len(CELLS)} cells)")


M(r'''
# Hands-on 1 — From a cosmology to a density field

Code a linear power spectrum, then draw a three-dimensional Gaussian
realization of it. That field is where Session 2 starts.

| # | step | ~min |
|---|---|---|
| 1 | Eisenstein & Hu transfer function `T(k)` | 15 |
| 2 | assemble and normalise `P_L(k)` | 10 |
| 3 | the full `T(k)`, and the BAO | 10 |
| 4 | draw the field on a 128³ grid | 25 |
| 5 | look at it; change the cosmology | 15 |
| 6 | check it against a Boltzmann code | 15 |

Cells marked `# TODO` are yours; each is followed by a checkpoint that asserts.
The seed is fixed, so every difference in step 5 is physics, not luck.
''')

C(r"""
import numpy as np
import matplotlib.pyplot as plt

# Fixed for the whole course. These match the lecture notes and the Sandbox.
Om, Ob, h, ns, sigma8, Tcmb = 0.31, 0.048, 0.676, 0.965, 0.81, 2.7255

# The grid. 250 Mpc/h is big enough to hold the BAO scale (~100 Mpc/h) and
# small enough that 128^3 resolves a few Mpc.
N, L, SEED = 128, 250.0, 1234

k_f   = 2*np.pi/L      # fundamental mode: the longest wave the box holds
k_Nyq = np.pi*N/L      # Nyquist: the shortest the grid can represent

print(f"box {L:.0f} Mpc/h, grid {N}^3")
print(f"k_f   = {k_f:.4f} h/Mpc   (lambda = {2*np.pi/k_f:.0f} Mpc/h)")
print(f"k_Nyq = {k_Nyq:.4f} h/Mpc   (lambda = {2*np.pi/k_Nyq:.1f} Mpc/h)")
""")

M(r'''
### Step 1 — The transfer function

Lecture 1 gave the shape, $T \propto (k_{\rm eq}/k)^2$, but not a number. For
that everyone uses the **Eisenstein & Hu (1998)** fit. Code their no-wiggle
version, eqs (26)–(31), with $\Theta = T_{\rm CMB}/2.7$, $f_b = \Omega_b/\Omega_m$,
and **$k$ in $\mathrm{Mpc}^{-1}$** — convert first:

$$s = \frac{44.5 \ln(9.83/\Omega_m h^2)}{\sqrt{1 + 10 (\Omega_b h^2)^{3/4}}}\ \mathrm{Mpc}$$

$$\alpha = 1 - 0.328 \ln(431\,\Omega_m h^2)\, f_b + 0.38 \ln(22.3\,\Omega_m h^2)\, f_b^2$$

$$\Gamma = \Omega_m h \left[\alpha + \frac{1-\alpha}{1 + (0.43\,k s)^4}\right]$$

$$q = \frac{k\,\Theta^2}{\Gamma h}, \qquad L_0 = \ln(2e + 1.8 q), \qquad C_0 = 14.2 + \frac{731}{1 + 62.5 q}$$

$$\boxed{T(k) = \frac{L_0}{L_0 + C_0\, q^2}}$$
''')

S(solution=r'''
def T_nowiggle(k, Om=Om, Ob=Ob, h=h, Tcmb=Tcmb):
    """Eisenstein & Hu (1998) no-wiggle transfer function.

    k is in h/Mpc. Returns an array, normalised so that T -> 1 as k -> 0.
    """
    omh2, obh2, fb = Om*h*h, Ob*h*h, Ob/Om
    Theta = Tcmb/2.7
    k = np.atleast_1d(k)*h                                     # h/Mpc -> 1/Mpc

    s     = 44.5*np.log(9.83/omh2)/np.sqrt(1 + 10*obh2**0.75)
    alpha = 1 - 0.328*np.log(431*omh2)*fb + 0.38*np.log(22.3*omh2)*fb**2
    Gamma = Om*h*(alpha + (1 - alpha)/(1 + (0.43*k*s)**4))
    q     = k*Theta**2/(Gamma*h)
    L0    = np.log(2*np.e + 1.8*q)
    C0    = 14.2 + 731.0/(1 + 62.5*q)
    return L0/(L0 + C0*q**2)
''', stub=r'''
def T_nowiggle(k, Om=Om, Ob=Ob, h=h, Tcmb=Tcmb):
    """Eisenstein & Hu (1998) no-wiggle transfer function.

    k is in h/Mpc. Returns an array, normalised so that T -> 1 as k -> 0.
    """
    omh2, obh2, fb = Om*h*h, Ob*h*h, Ob/Om
    Theta = Tcmb/2.7
    k = np.atleast_1d(k)*h                                     # h/Mpc -> 1/Mpc

    # TODO (6 lines) -- s, alpha, Gamma, q, L0, C0, then return L0/(L0 + C0 q^2).
    # Take them straight off the markdown cell above, in that order.
    # Watch two things: k is already in 1/Mpc by the line above, and `np.e` is
    # Euler's number (the formula wants 2e, not 2*10).
    raise NotImplementedError("write T_nowiggle")
''')

C(r"""
# --- checkpoint 1 -------------------------------------------------------
T_large = float(T_nowiggle(1e-4)[0])
T_keq   = float(T_nowiggle(0.0153)[0])
kk      = np.logspace(np.log10(0.5), np.log10(5.0), 400)
slope_T = float(np.polyfit(np.log(kk), np.log(T_nowiggle(kk)), 1)[0])

# Print first, then assert: if one of these fails you still get to see all
# three measurements, which is what tells you which way it went wrong.
print(f"T -> {T_large:.4f}  as k -> 0")
print(f"T(k_eq = 0.0153)  = {T_keq:.4f}")
print(f"d ln T / d ln k   = {slope_T:.3f}   over 0.5 < k < 5 h/Mpc")

assert abs(T_large - 1.0) < 2e-3,   f"T should -> 1 on large scales, got {T_large:.4f}"
assert abs(T_keq - 0.6745) < 0.005, f"T(k_eq) should be 0.675, got {T_keq:.4f}"
assert abs(slope_T + 1.670) < 0.02, f"slope over 0.5<k<5 should be -1.67, got {slope_T:.3f}"
""")

M(r'''
The board said $-2$; you measured $-1.67$. The gap is the **Mészáros effect** —
cold dark matter creeps up logarithmically while the potential decays, softening
the falloff to $T \propto k^{-2}\ln k$. Exercise 1.5 of the notes works it out.
''')

M(r'''
### Step 2 — The linear power spectrum

$$P_{\rm L}(k, z) = A\, k^{n_s}\, T^2(k)\, D_+^2(z)$$

At $z=0$, $D_+ = 1$. The shape cannot tell you $A$; fix it with $\sigma_8$,
notes eq. (1.9):

$$\sigma_R^2 = \int \frac{k^3 P(k)}{2\pi^2}\, |W(kR)|^2\, {\rm d}\ln k,
\qquad W(x) = \frac{3(\sin x - x\cos x)}{x^3}, \qquad R = 8\,h^{-1}{\rm Mpc}.$$

Integrate in $\ln k$ — $P$ spans decades.
''')

C(r'''
def logint(f, a, b, n=4000):
    """Integral of f over d ln k from a to b, as a sum on a uniform log grid.

    Crude on purpose: no scipy, and for smooth integrands like these it is
    accurate to far better than the 1% we care about. Check it if you like by
    doubling n.
    """
    lnk = np.linspace(np.log(a), np.log(b), n)
    return float(np.sum(f(np.exp(lnk))) * (lnk[1] - lnk[0]))
''')

S(solution=r'''
def sigma_R(P, R=8.0):
    """rms of the field smoothed on radius R [Mpc/h]. Notes eq. (1.9)."""
    def integrand(k):
        x = k*R
        W = 3*(np.sin(x) - x*np.cos(x))/x**3
        return k**3 * P(k) * W**2 / (2*np.pi**2)
    return np.sqrt(logint(integrand, 1e-5, 1e2))


def make_pk_lin(T, ns=ns, sigma8=sigma8):
    """P_L(k) = A k^ns T^2(k), with A fixed so that sigma_8 comes out right.

    Returns a callable k -> P(k) in (Mpc/h)^3, k in h/Mpc.
    """
    def unnorm(k):
        return np.atleast_1d(k)**ns * T(k)**2
    A = (sigma8/sigma_R(unnorm))**2
    return lambda k: A*unnorm(k)


pk_nw = make_pk_lin(T_nowiggle)
''', stub=r'''
def sigma_R(P, R=8.0):
    """rms of the field smoothed on radius R [Mpc/h]. Notes eq. (1.9)."""
    def integrand(k):
        # TODO (3 lines): x = kR; the top-hat window W; return k^3 P W^2 / 2pi^2
        raise NotImplementedError
    return np.sqrt(logint(integrand, 1e-5, 1e2))


def make_pk_lin(T, ns=ns, sigma8=sigma8):
    """P_L(k) = A k^ns T^2(k), with A fixed so that sigma_8 comes out right.

    Returns a callable k -> P(k) in (Mpc/h)^3, k in h/Mpc.
    """
    def unnorm(k):
        # TODO (1 line): the shape, k^ns T^2(k), with no amplitude yet
        raise NotImplementedError

    # TODO (1 line): sigma_R scales as sqrt(A), so solve for A that lands on sigma8
    A = ...
    return lambda k: A*unnorm(k)


pk_nw = make_pk_lin(T_nowiggle)
''')

C(r'''
# --- checkpoint 2 -------------------------------------------------------
s8_out   = sigma_R(pk_nw)
kg       = np.logspace(-4, 2, 6000)
turnover = float(kg[np.argmax(pk_nw(kg))])
slope_P  = float(np.polyfit(np.log(kk), np.log(pk_nw(kk)), 1)[0])

print(f"sigma_8 recovered = {s8_out:.4f}")
print(f"turnover at k     = {turnover:.4f} h/Mpc   (k_eq = 0.0153)")
print(f"d ln P / d ln k   = {slope_P:.3f}   over 0.5 < k < 5 h/Mpc")
print(f"consistency: 2 x {slope_T:.3f} + {ns} = {2*slope_T + ns:.3f}")

assert abs(s8_out - 0.81) < 1e-3,      f"sigma_8 should come back at 0.81, got {s8_out:.4f}"
assert 0.012 < turnover < 0.020,       f"turnover should sit near k_eq = 0.015, got {turnover:.4f}"
assert abs(slope_P + 2.375) < 0.03,    f"slope over 0.5<k<5 should be -2.38, got {slope_P:.3f}"
''')

M(r'''
Since $P_{\rm L} \propto k^{n_s}T^2$, the two slopes are locked:
$2 \times (-1.670) + 0.965 = -2.375$. Fudging `T_nowiggle` past checkpoint 1
fails here.
''')

C(r'''
kplot = np.logspace(-4, 1, 500)
fig, ax = plt.subplots(1, 2, figsize=(10, 3.8))

ax[0].loglog(kplot, kplot**ns / kplot[0]**ns, label=r"$A\,k^{n_s}$ (inflation)")
ax[0].loglog(kplot, T_nowiggle(kplot)**2,     label=r"$T^2(k)$ (processing)")
ax[0].set_ylabel("the two factors (arbitrary scale)")
ax[0].legend(fontsize=8)

ax[1].loglog(kplot, pk_nw(kplot), color="k")
ax[1].axvline(0.0153, ls=":", c="0.5")
ax[1].text(0.0165, 3e2, r"$k_{\rm eq}$", fontsize=9)
ax[1].set_ylabel(r"$P_{\rm L}(k)\ [(\mathrm{Mpc}/h)^3]$")
ax[1].set_title("the product")

for a in ax:
    a.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
fig.tight_layout()
plt.show()
''')


M(r'''
### Step 3 — Baryons, and the wiggles they leave

Baryons are a sixth of the matter and rang with the photons until
recombination, which froze the wave at the sound horizon
$r_d \simeq 100\,h^{-1}$Mpc. That leaves a few-percent oscillation in
$P_{\rm L}(k)$ — the **baryon acoustic oscillations**. The full EH formula has
them; it is given, so run it and move on.
''')

C(r'''
def T_full(k, Om=Om, Ob=Ob, h=h, Tcmb=Tcmb):
    """Eisenstein & Hu (1998) transfer function with baryon wiggles.

    Their eqs (1)-(24). Given -- do not type this. k in h/Mpc.
    """
    Theta = Tcmb/2.7
    omh2, obh2 = Om*h*h, Ob*h*h
    fb = Ob/Om
    k = np.atleast_1d(k)*h                                     # h/Mpc -> 1/Mpc

    zeq  = 2.50e4*omh2*Theta**-4
    keq  = 7.46e-2*omh2*Theta**-2
    b1   = 0.313*omh2**-0.419*(1 + 0.607*omh2**0.674)
    b2   = 0.238*omh2**0.223
    zd   = 1291*omh2**0.251/(1 + 0.659*omh2**0.828)*(1 + b1*obh2**b2)
    Req  = 31.5*obh2*Theta**-4*(1e3/zeq)
    Rd   = 31.5*obh2*Theta**-4*(1e3/zd)
    s    = 2.0/(3*keq)*np.sqrt(6.0/Req)*np.log(
        (np.sqrt(1 + Rd) + np.sqrt(Rd + Req))/(1 + np.sqrt(Req)))
    ksilk = 1.6*obh2**0.52*omh2**0.73*(1 + (10.4*omh2)**-0.95)

    q  = k/(13.41*keq)
    a1 = (46.9*omh2)**0.670*(1 + (32.1*omh2)**-0.532)
    a2 = (12.0*omh2)**0.424*(1 + (45.0*omh2)**-0.582)
    alpha_c = a1**(-fb)*a2**(-fb**3)
    bb1 = 0.944/(1 + (458*omh2)**-0.708)
    bb2 = (0.395*omh2)**-0.0266
    beta_c = 1.0/(1 + bb1*((1 - fb)**bb2 - 1))

    def Tt(ac, bc):
        C = 14.2/ac + 386.0/(1 + 69.9*q**1.08)
        return np.log(np.e + 1.8*bc*q)/(np.log(np.e + 1.8*bc*q) + C*q**2)

    f  = 1.0/(1 + (k*s/5.4)**4)
    Tc = f*Tt(1.0, beta_c) + (1 - f)*Tt(alpha_c, beta_c)

    y  = (1 + zeq)/(1 + zd)
    Gy = y*(-6*np.sqrt(1 + y) + (2 + 3*y)*np.log(
        (np.sqrt(1 + y) + 1)/(np.sqrt(1 + y) - 1)))
    alpha_b   = 2.07*keq*s*(1 + Rd)**-0.75*Gy
    beta_b    = 0.5 + fb + (3 - 2*fb)*np.sqrt((17.2*omh2)**2 + 1)
    beta_node = 8.41*omh2**0.435
    st = s/(1 + (beta_node/(k*s))**3)**(1.0/3.0)

    Tb = (Tt(1.0, 1.0)/(1 + (k*s/5.2)**2)
          + alpha_b/(1 + (beta_b/(k*s))**3)*np.exp(-(k/ksilk)**1.4)
          )*np.sinc(k*st/np.pi)
    return fb*Tb + (1 - fb)*Tc


pk_lin = make_pk_lin(T_full)     # everything from here on uses this one
''')

C(r'''
# --- checkpoint 3 -------------------------------------------------------
kb    = np.logspace(np.log10(0.02), np.log10(0.5), 2000)
ratio = pk_lin(kb)/pk_nw(kb)
band  = (kb > 0.03) & (kb < 0.12)
kpeak = float(kb[band][np.argmax(ratio[band])])
rpeak = float(ratio[band].max())

print(f"first BAO peak at k = {kpeak:.4f} h/Mpc  ->  lambda = {2*np.pi/kpeak:.0f} Mpc/h")
print(f"amplitude at that peak: {100*(rpeak-1):+.1f}%")
print(f"full range of the ratio: {ratio.min():.3f} to {ratio.max():.3f}")

plt.figure(figsize=(6, 3.4))
plt.semilogx(kb, ratio, color="#e8590c")
plt.axhline(1.0, color="0.6", lw=0.8)
plt.xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
plt.ylabel(r"$P_{\rm L}/P_{\rm nw}$")
plt.title("the baryon acoustic oscillations")
plt.tight_layout(); plt.show()

# Asserted after the plot, so a failure still leaves you the picture to read.
assert 0.06 < kpeak < 0.09,           f"first BAO peak should sit near k=0.078, got {kpeak:.4f}"
assert 1.04 < rpeak < 1.10,           f"peak should be a few percent, got {rpeak:.4f}"
assert ratio.min() > 0.93,            f"wiggles should not dominate, got min {ratio.min():.4f}"
''')

M(r'''
The first peak sits at $\lambda \simeq 80$ Mpc/h — the sound horizon seen
through the harmonic structure, and the standard ruler surveys measure. A few
percent tall, which is why Figure 3 of the notes plots it as a ratio.

**Use `pk_lin` from here on.**
''')


M(r'''
### Step 4 — Draw a universe

Three lines, from §1.3 of the notes: draw each mode with variance
$P_{\rm L}(k)$, impose reality, inverse transform. `rfftn` on real white noise
makes the second free.

**The trap is the normalisation, and it is silent.** Converting
$\langle\delta^2\rangle = \int {\rm d}^3k/(2\pi)^3 P(k)$ to a finite grid needs
factors of $N$ and $L$ that do not announce themselves; get them wrong and the
field still looks right while every number is off. Figure 4 of the notes was
first built with this exact bug — $\delta_{\rm rms} = 0.005$ instead of 2.5.

So the line is given. Your job is to **check** it:

```
delta_k = np.fft.rfftn(white) * np.sqrt(P_grid * N**3 / L**3)
```
''')

C(r'''
# The wavevector grid. rfftn drops the redundant half of the last axis, so the
# last dimension runs over N//2+1 non-negative frequencies.
kx = np.fft.fftfreq(N, d=1.0/N)*k_f          # signed, for the two full axes
kz = np.fft.rfftfreq(N, d=1.0/N)*k_f         # non-negative, for the rfft axis
KX, KY, KZ = np.meshgrid(kx, kx, kz, indexing="ij")

K2 = KX**2 + KY**2 + KZ**2
K2[0, 0, 0] = 1.0        # placeholder: avoids 0/0, and the mode is zeroed below

P_grid = pk_lin(np.sqrt(K2).ravel()).reshape(K2.shape)
P_grid[0, 0, 0] = 0.0    # Derivation 1: the mean is not a fluctuation

print(f"grid shape {K2.shape},  |k| from {np.sqrt(K2)[0,0,1]:.4f} to {np.sqrt(K2).max():.3f} h/Mpc")
''')

M(r'''
The largest $|k|$ is **2.79**, not $k_{\rm Nyq} = 1.61$: the grid is a cube, and
its corners reach $\sqrt{3}\,k_{\rm Nyq}$. That comes back in a moment.

`P_grid[0,0,0] = 0` is Derivation 1 made concrete — the $\boldsymbol{k}=0$ mode
is the mean density, which is not a fluctuation.
''')

S(solution=r'''
rng   = np.random.default_rng(SEED)
white = rng.standard_normal((N, N, N))       # unit-variance real white noise

delta_k = np.fft.rfftn(white) * np.sqrt(P_grid * N**3 / L**3)
delta_k[0, 0, 0] = 0.0
delta_x = np.fft.irfftn(delta_k, s=(N, N, N))

print(f"delta_k {delta_k.shape} {delta_k.dtype},  delta_x {delta_x.shape} {delta_x.dtype}")
''', stub=r'''
rng   = np.random.default_rng(SEED)
white = rng.standard_normal((N, N, N))       # unit-variance real white noise

# TODO (3 lines):
#   delta_k -- transform the white noise and scale it by sqrt(P N^3 / L^3)
#   then zero the k=0 mode
#   delta_x -- inverse transform back to real space, with s=(N, N, N)
raise NotImplementedError("draw the field")

print(f"delta_k {delta_k.shape} {delta_k.dtype},  delta_x {delta_x.shape} {delta_x.dtype}")
''')

C(r'''
# --- checkpoint 4: the one that matters ---------------------------------
rms_grid = float(np.std(delta_x))
rms_cont = np.sqrt(logint(lambda k: k**3*pk_lin(k)/(2*np.pi**2), k_f, k_Nyq, 3000))

print(f"realized rms delta            = {rms_grid:.3f}")
print(f"continuum, k_f to k_Nyq       = {rms_cont:.3f}")
print(f"ratio                         = {rms_grid/rms_cont:.3f}")
print(f"mean of delta                 = {delta_x.mean():.2e}   (should be ~0)")
print(f"range                         = {delta_x.min():.1f} to {delta_x.max():.1f}")

assert abs(rms_grid - 2.516) < 0.02,      f"rms should be 2.516, got {rms_grid:.3f}"
assert 1.05 < rms_grid/rms_cont < 1.12,   f"grid/continuum should be ~1.086, got {rms_grid/rms_cont:.3f}"
assert abs(delta_x.mean()) < 1e-10,       f"mean should vanish, got {delta_x.mean():.2e}"
''')

M(r'''
**The normalisation is right:** 2.516 against 2.317 from the continuum
integral. Dropping $N^3/L^3$ would have missed by a factor of thousands, not 9%.

**The 9% is geometry** — the corner modes reach past where the integral stopped,
so the realized value runs high. Which way would that go if you halved the box
at fixed $N$?
''')


M(r'''
### Step 5 — Look at it

You have a universe. Slice it.
''')

C(r'''
fig, ax = plt.subplots(1, 2, figsize=(10, 4.2))

sl = delta_x[:, :, N//2]
im = ax[0].imshow(sl.T, origin="lower", extent=[0, L, 0, L], cmap="RdBu_r",
                  vmin=-4, vmax=4, interpolation="nearest")
ax[0].set_title(r"a slice through $\delta$, one cell thick")
fig.colorbar(im, ax=ax[0], label=r"$\delta$", fraction=0.046)

ax[1].hist(delta_x.ravel(), bins=200, density=True, color="0.7")
g = np.linspace(-10, 10, 400)
ax[1].plot(g, np.exp(-g**2/(2*rms_grid**2))/np.sqrt(2*np.pi*rms_grid**2), "k-", lw=1.2,
           label=f"Gaussian, sigma = {rms_grid:.2f}")
ax[1].set_xlim(-10, 10); ax[1].set_xlabel(r"$\delta$"); ax[1].legend(fontsize=8)
ax[1].set_title("and its one-point distribution")

for a in (ax[0],):
    a.set_xlabel(r"$x\ [h^{-1}\mathrm{Mpc}]$"); a.set_ylabel(r"$y\ [h^{-1}\mathrm{Mpc}]$")
fig.tight_layout(); plt.show()
''')

M(r'''
The histogram is Gaussian because we built it that way — that is all "Gaussian
initial conditions" means. Lecture 2 is what gravity does to that symmetry.

Note that $\delta$ reaches $\pm 12$, well past the $|\delta| \ll 1$ of
assumption A4. Linear theory has already broken on the smallest scales here.
''')

C(r'''
# The five cosmologies we will compare. The table below reuses this list.
VARIANTS = [("fiducial",  {},            ns),
            ("ns = 1.10", {},            1.10),
            ("ns = 0.85", {},            0.85),
            ("Om = 0.20", {"Om": 0.20},  ns),
            ("Om = 0.45", {"Om": 0.45},  ns)]

kv = np.logspace(-3.5, 0.7, 400)
fig, ax = plt.subplots(1, 2, figsize=(10.5, 4.0))
P_fid = None
for label, kw, ns_ in VARIANTS:
    P = make_pk_lin(lambda k: T_full(k, **kw), ns=ns_)
    Pv = P(kv)
    if P_fid is None:
        P_fid = Pv
    style = dict(lw=2.0, color="k") if label == "fiducial" else dict(lw=1.2)
    ax[0].loglog(kv, Pv, label=label, **style)
    ax[1].semilogx(kv, Pv/P_fid, **style)

ax[0].set_ylabel(r"$P_{\rm L}(k)\ [(\mathrm{Mpc}/h)^3]$")
ax[0].set_title("five universes, all with $\\sigma_8 = 0.81$")
ax[0].legend(fontsize=8)
ax[1].axhline(1.0, color="0.6", lw=0.8)
ax[1].axvline(2*np.pi/8.0, color="0.6", ls=":", lw=0.8)
ax[1].text(2*np.pi/8.0*1.1, 0.35, r"$k = 2\pi/8\,h\,\mathrm{Mpc}^{-1}$", fontsize=7, color="0.4")
ax[1].set_ylabel(r"$P_{\rm L}/P_{\rm L}^{\rm fiducial}$")
ax[1].set_ylim(0.3, 2.2)
ax[1].set_title("the same, divided by the fiducial")
for a in ax:
    a.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
fig.tight_layout(); plt.show()
''')

M(r'''
**Read the right-hand panel.** Every curve is pinned near $8\,h^{-1}$Mpc, where
$\sigma_8$ is defined, so none of this is amplitude — it is shape.

$n_s$ pivots the spectrum about that scale. $\Omega_m$ slides the turnover
instead, because $k_{\rm eq}$ moves with when matter overtook radiation.
''')

C(r'''
def realize(T_of_k, ns_=ns, seed=SEED):
    """Re-draw the field for a different cosmology, same seed. -> (rms, turnover)."""
    P = make_pk_lin(T_of_k, ns=ns_)
    Pg = P(np.sqrt(K2).ravel()).reshape(K2.shape); Pg[0, 0, 0] = 0.0
    r = np.random.default_rng(seed)
    dk = np.fft.rfftn(r.standard_normal((N, N, N)))*np.sqrt(Pg*N**3/L**3)
    dk[0, 0, 0] = 0.0
    kg_ = np.logspace(-4, 2, 4000)
    return float(np.std(np.fft.irfftn(dk, s=(N, N, N)))), float(kg_[np.argmax(P(kg_))])


print(f"{'variant':12s} {'k_eq':>8s} {'turnover':>10s} {'rms delta':>10s}")
for label, kw, ns_ in VARIANTS:
    Om_ = kw.get("Om", Om)
    keq_ = 7.46e-2*(Om_*h*h)*(Tcmb/2.7)**-2/h
    rms_, turn_ = realize(lambda k: T_full(k, **kw), ns_=ns_)
    print(f"{label:12s} {keq_:8.4f} {turn_:10.4f} {rms_:10.3f}")
''')

M(r'''
**$\sigma_8$ is renormalised to 0.81 in every row**, so these are shape
differences only.

Raising $n_s$ tilts power to small scales: the grid rms goes 2.52 → 2.80 with
$\sigma_8$ pinned. Raising $\Omega_m$ moves $k_{\rm eq}$ right, since equality
comes earlier with more matter — the one scale the early universe stamps on the
spectrum, and you just moved it. Same seed throughout.
''')
M(r'''
### Step 6 — Is that fitting formula any good?

**CAMB** solves the Boltzmann–Einstein system mode by mode, and is what the fit
was fit to. The cell below installs it (~40 s); if that fails, the next falls
back to a shipped CAMB table.
''')

C(r'''
# ~40 s on Colab. Skipped entirely if camb is already present.
try:
    import camb
    print("camb", camb.__version__, "already available")
except ImportError:
    import subprocess, sys
    print("installing camb ...")
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "camb"], check=False)
    try:
        import camb
        print("camb", camb.__version__, "installed")
    except ImportError:
        camb = None
        print("camb unavailable -- the next cell will use the shipped table instead")
''')

C(r'''
def T_boltzmann():
    """CAMB's transfer function, normalised to T -> 1 as k -> 0.

    Returns (k, T). Computes from CAMB when it is importable; otherwise reads
    the tabulated result shipped alongside this notebook.
    """
    if camb is not None:
        pars = camb.CAMBparams()
        pars.set_cosmology(H0=100*h, ombh2=Ob*h*h, omch2=(Om - Ob)*h*h,
                           mnu=0.0, omk=0, num_massive_neutrinos=0)
        pars.InitPower.set_params(ns=ns, As=2.1e-9)
        pars.set_matter_power(redshifts=[0.0], kmax=40.0)
        pars.NonLinear = camb.model.NonLinear_none
        kh, _, pk = camb.get_results(pars).get_matter_power_spectrum(
            minkh=1e-4, maxkh=30.0, npoints=1024)
        T = np.sqrt(pk[0]/kh**ns)
        return kh, T/T[0], "computed with CAMB"

    import urllib.request
    url = ("https://raw.githubusercontent.com/MinhMPA/EFT-with-FFT/"
           "master/notebooks/T_camb_fiducial.txt")
    try:
        tab = np.loadtxt("T_camb_fiducial.txt")
    except OSError:
        urllib.request.urlretrieve(url, "T_camb_fiducial.txt")
        tab = np.loadtxt("T_camb_fiducial.txt")
    return tab[:, 0], tab[:, 1], "from the shipped CAMB table"


kb, T_ref, provenance = T_boltzmann()
ratio_T = T_full(kb)/T_ref

grid = (kb >= k_f) & (kb <= np.sqrt(3)*k_Nyq)
worst = int(np.argmax(np.abs(ratio_T - 1)))

print(f"reference {provenance}")
print(f"max deviation over the whole range   : {100*np.abs(ratio_T-1).max():.2f}%  at k = {kb[worst]:.4f}")
print(f"max deviation over your grid's k band: {100*np.abs(ratio_T[grid]-1).max():.2f}%")

assert np.abs(ratio_T - 1).max() < 0.05, \
    f"EH should track CAMB to a few percent, got {100*np.abs(ratio_T-1).max():.1f}%"
assert abs(T_ref[0] - 1.0) < 1e-3, "reference T should be normalised to 1 at k -> 0"

plt.figure(figsize=(7, 3.6))
plt.semilogx(kb, ratio_T, color="#2f6ea5")
plt.axhline(1.0, color="0.6", lw=0.8)
plt.axhspan(0.99, 1.01, color="0.85", zorder=0)
plt.axvspan(k_f, np.sqrt(3)*k_Nyq, color="#e8590c", alpha=0.08, zorder=0)
plt.text(0.03, 1.022, "your grid's k range", fontsize=7, color="#e8590c")
plt.xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
plt.ylabel(r"$T_{\rm EH}/T_{\rm CAMB}$")
plt.title("a twelve-line fit against a Boltzmann code")
plt.tight_layout(); plt.show()
''')

M(r'''
**Under a percent nearly everywhere** — the grey band is $\pm1\%$ — with the
worst excursion, 2.7%, near $k \simeq 0.09\,h\,{\rm Mpc}^{-1}$.

That is a baryon acoustic peak, and no accident: the broadband shape follows
from the horizon argument and the fit captures it, while the wiggles come from
the plasma's acoustic history, which a dozen coefficients can only approximate.

The error *oscillates*. Two failures would do that; the cell below separates
them.
''')

C(r'''
# Divide each transfer function by the SAME smooth reference, so what is left
# is the wiggles alone and the two are directly comparable.
w_eh  = T_full(kb)/T_nowiggle(kb) - 1
w_ref = T_ref/T_nowiggle(kb) - 1

band = (kb > 0.03) & (kb < 0.45)
amp_eh, amp_ref = float(np.ptp(w_eh[band])), float(np.ptp(w_ref[band]))
away = (kb < 0.02) | (kb > 0.5)

assert 0.9 < amp_eh/amp_ref < 1.1, \
    f"the two wiggle amplitudes should be within 10%, got {amp_eh/amp_ref:.3f}"
print(f"wiggle amplitude, peak to peak over 0.03 < k < 0.45")
print(f"   Eisenstein & Hu : {amp_eh:.4f}")
print(f"   CAMB            : {amp_ref:.4f}")
print(f"   ratio           : {amp_eh/amp_ref:.3f}")
print(f"error away from the BAO band (k < 0.02 or k > 0.5): "
      f"{100*np.abs(ratio_T[away]-1).max():.2f}%")

fig, ax = plt.subplots(1, 2, figsize=(10.5, 3.6))
ax[0].semilogx(kb[band], w_ref[band], color="k", lw=1.4, label="CAMB")
ax[0].semilogx(kb[band], w_eh[band], color="#e8590c", lw=1.2, label="Eisenstein & Hu")
ax[0].axhline(0.0, color="0.6", lw=0.8)
ax[0].set_ylabel(r"$T/T_{\rm nw} - 1$")
ax[0].set_title("the wiggles, side by side")
ax[0].legend(fontsize=8)

ax[1].semilogx(kb[band], (w_eh - w_ref)[band], color="#2f6ea5")
ax[1].axhline(0.0, color="0.6", lw=0.8)
ax[1].set_ylabel("EH $-$ CAMB")
ax[1].set_title("what is left over")
for a in ax:
    a.set_xlabel(r"$k\ [h\,\mathrm{Mpc}^{-1}]$")
fig.tight_layout(); plt.show()
''')

SM(answer=r'''
**Both are present, and neither dominates.**

*Amplitude.* The EH oscillation is 0.978 of CAMB's, about 2% too shallow. Alone
that would leave a residual in phase with the wiggle — largest at the peaks.

*Phase.* The acoustic scale is displaced by roughly 1% in $k$. The formula uses
a $\mathrm{sinc}(k\tilde{s})$ whose argument approximates
$s = \int c_s\,{\rm d}\tau$, and a small error in $s$ misplaces every node. A
pure phase error leaves the *derivative* of the wiggle — largest at its zeros.

The right-hand panel is the sum, which is why it peaks at neither.

*And a floor under both.* Away from the BAO band the error is still 1.8%, so
the 2.7% is broadband error with wiggle error stacked on top.

The real acoustic solution is a driven, damped oscillator with a time-dependent
sound speed, decoupling over a finite interval. That is not a $\mathrm{sinc}$,
and no dozen coefficients make it one — which is why EH survives mainly as the
*no-wiggle* spectrum, where it is excellent and this failure cannot arise.
''', bait=r'''
**Which is it?** Two failures would each make the error oscillate.

A wrong wiggle *amplitude* leaves a residual peaking where the wiggles peak. A
wrong acoustic *phase* — the sound horizon setting where the nodes fall —
leaves one shaped like the derivative of the wiggle, largest at its zeros.

Decide which the right-hand panel shows. Then check the printed amplitude ratio
and the error away from the BAO band, and ask whether either alone accounts for
the 2.7%.
''')

M(r'''
### What you built

- a transfer function whose $-1.67$ slope you measured against the board's $-2$;
- $P_{\rm L}(k)$ with a turnover at $k_{\rm eq}$ and few-percent wiggles;
- a 128³ realization whose variance you checked rather than trusted;
- one seed run five ways, showing shape follows the contents of the universe;
- and how far twelve lines sit from a Boltzmann code, including how they fail.

**Nothing to save** — Session 2 rebuilds this field from the same seed.
''')


if __name__ == "__main__":
    main()
