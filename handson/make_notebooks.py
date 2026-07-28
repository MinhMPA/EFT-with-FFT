"""Generate the Hands-on 1 notebooks.

Single source of truth for both the student notebook and the solutions
notebook. Cells are declared once, below, in reading order:

    M(text)             a markdown cell, identical in both
    C(code)             a code cell, identical in both (given to students)
    S(solution, stub)   a code cell that differs: students get `stub`

Run this file to write handson/H1_gaussian_field.ipynb and
handson/H1_gaussian_field_solutions.ipynb. Never edit the .ipynb by hand.
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


M(r"""
# Hands-on 1 — From a cosmology to a density field

By the end of this session you will have coded a linear power spectrum from
scratch and drawn a three-dimensional Gaussian realization of it. That field is
where Session 2 starts.

Six steps, roughly 90 minutes:

| # | what | ~min |
|---|---|---|
| 1 | the no-wiggle Eisenstein & Hu transfer function `T(k)` | 15 |
| 2 | assemble `P_L(k) = A k^{n_s} T²(k)` and normalise it | 10 |
| 3 | swap in the full `T(k)` and find the BAO | 10 |
| 4 | draw a Gaussian realization on a 128³ grid | 25 |
| 5 | look at it, and change the cosmology | 15 |
| 6 | save it for Session 2 | 15 |

**The seed is fixed.** Everyone's field is the same field, and it is the one in
Figure 3 of the notes. So when you change `n_s` in step 5 and the picture
changes, that difference is physics — not a different roll of the dice.

Cells marked **you write this** have a `# TODO`. Every one is followed by a
checkpoint cell that either prints a number or raises `AssertionError`. A wrong
normalisation is silent — the field looks perfectly plausible and every
downstream number is wrong — so the checkpoints are not decoration.
""")

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

M(r"""
---
## Step 1 — The transfer function

Lecture 1 derived what `T(k)` *does*: a mode that enters the horizon during
radiation domination watches its potential decay while it waits for equality,
so

$$T(k) \sim \left(\frac{a_{\rm enter}}{a_{\rm eq}}\right)^{2} \propto \left(\frac{k_{\rm eq}}{k}\right)^{2},$$

flat below $k_{\rm eq} \simeq 0.015\,h\,{\rm Mpc}^{-1}$ and falling as $k^{-2}$ above it.

That is the physics, and it is all the physics. What it does not give you is a
number. For that everyone uses **Eisenstein & Hu (1998)**, a fitting formula —
tuned to reproduce a Boltzmann code, not derived from anything. Here is the
smooth ("no-wiggle") version, their eqs (26)–(31). Type it; there is nothing to
understand in it, and having typed it is what makes the checks below mean
something.

With $\Theta = T_{\rm CMB}/2.7$, $f_b = \Omega_b/\Omega_m$, and **$k$ in
$\mathrm{Mpc}^{-1}$** (not $h\,\mathrm{Mpc}^{-1}$ — convert first):

$$s = \frac{44.5 \ln(9.83/\Omega_m h^2)}{\sqrt{1 + 10 (\Omega_b h^2)^{3/4}}}\ \mathrm{Mpc}$$

$$\alpha = 1 - 0.328 \ln(431\,\Omega_m h^2)\, f_b + 0.38 \ln(22.3\,\Omega_m h^2)\, f_b^2$$

$$\Gamma = \Omega_m h \left[\alpha + \frac{1-\alpha}{1 + (0.43\,k s)^4}\right]$$

$$q = \frac{k\,\Theta^2}{\Gamma h}, \qquad L_0 = \ln(2e + 1.8 q), \qquad C_0 = 14.2 + \frac{731}{1 + 62.5 q}$$

$$\boxed{T(k) = \frac{L_0}{L_0 + C_0\, q^2}}$$
""")

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

assert abs(T_large - 1.0) < 2e-3,   f"T should -> 1 on large scales, got {T_large:.4f}"
assert abs(T_keq - 0.6745) < 0.005, f"T(k_eq) should be 0.675, got {T_keq:.4f}"
assert abs(slope_T + 1.670) < 0.02, f"slope over 0.5<k<5 should be -1.67, got {slope_T:.3f}"

print(f"T -> {T_large:.4f}  as k -> 0")
print(f"T(k_eq = 0.0153)  = {T_keq:.4f}")
print(f"d ln T / d ln k   = {slope_T:.3f}   over 0.5 < k < 5 h/Mpc")
""")

M(r"""
**Stop on that last number.** The board said $T \propto k^{-2}$ above
$k_{\rm eq}$, so you expected $-2$. You measured $-1.67$.

The gap is the **Mészáros effect**: cold dark matter is not quite frozen while
the potential decays — it creeps up logarithmically — which softens the falloff
to $T \propto k^{-2}\ln k$. Exercise 1.3 in the notes works it out. You have
just measured it, in a fitting formula that knows nothing about the derivation.
""")

M(r'''
---
## Step 2 — The linear power spectrum

Equation (1.11) of the notes, the boxed one:

$$P_{\rm L}(k, z) = A\, k^{n_s}\, T^2(k)\, D_+^2(z)$$

Three factors, three pieces of physics. Inflation supplies $k^{n_s}$;
$T^2(k)$ is everything that happened between then and now, which you just
coded; $D_+^2(z)$ carries the time dependence. We work at $z = 0$, where
$D_+ = 1$, so it drops.

That leaves $A$ — an amplitude, which the shape cannot tell you. It is fixed by
one measured number, conventionally $\sigma_8$: the rms of the density field
smoothed with a top-hat sphere of radius $8\,h^{-1}$Mpc, notes eq. (1.9),

$$\sigma_8^2 = \int \frac{{\rm d}^3k}{(2\pi)^3}\, P_{\rm L}(k)\, |W(kR)|^2, \qquad
W(x) = \frac{3(\sin x - x\cos x)}{x^3}, \qquad R = 8\,h^{-1}{\rm Mpc}.$$

For an isotropic $P$ that angular integral is trivial, and it is worth writing
the form you will actually use — with $\mathrm{d}\ln k$, because $P$ spans
decades and a linear grid would waste all its points at large $k$:

$$\sigma_R^2 = \int \frac{k^3 P(k)}{2\pi^2}\, |W(kR)|^2\, {\rm d}\ln k.$$

The integrand $k^3P/2\pi^2$ is $\Delta^2(k)$, the variance per logarithmic
interval — the quantity Figure 1 of the notes used to argue that small scales
carry more.
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

assert abs(s8_out - 0.81) < 1e-3,      f"sigma_8 should come back at 0.81, got {s8_out:.4f}"
assert 0.012 < turnover < 0.020,       f"turnover should sit near k_eq = 0.015, got {turnover:.4f}"
assert abs(slope_P + 2.375) < 0.03,    f"slope over 0.5<k<5 should be -2.38, got {slope_P:.3f}"

print(f"sigma_8 recovered = {s8_out:.4f}")
print(f"turnover at k     = {turnover:.4f} h/Mpc   (k_eq = 0.0153)")
print(f"d ln P / d ln k   = {slope_P:.3f}   over 0.5 < k < 5 h/Mpc")
print(f"consistency: 2 x {slope_T:.3f} + {ns} = {2*slope_T + ns:.3f}")
''')

M(r'''
The last line is the point. Since $P_{\rm L} \propto k^{n_s} T^2$, the two
slopes are locked together: $2 \times (-1.670) + 0.965 = -2.375$. If you fudged
`T_nowiggle` into passing checkpoint 1, checkpoint 2 catches it.

Now plot it. This is Figure 3 of the notes, right-hand panel, from your code.
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


if __name__ == "__main__":
    main()
