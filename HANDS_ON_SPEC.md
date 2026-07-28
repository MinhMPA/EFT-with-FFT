# Hands-on sessions — specification

Two sessions, each following the lecture it consumes, and **chained**: H1
produces the field H2 moves.

```
L1  primordial fluctuations -> P_L(k)        L2  Zel'dovich, LPT, the cosmic web
H1  build P_L, draw a realization            H2  displace it; sheets, filaments, knots
```

Conventions throughout match the notes, `figs_src/ptlib.py`, and the
[Cosmic Web Sandbox](https://minhmpa.github.io/lss-lab/cosmic-web-sandbox/), so
students can compare all three: Eisenstein & Hu transfer function, flat ΛCDM,
`δ(k) = ∫d³x e^{−ik·x}δ(x)` with `(2π)⁻³` on `d³k`, box **250 Mpc/h**, grid
**128³**, **fixed seed**.

Fixing the seed matters pedagogically: change a parameter and every difference
you see is physics, not luck. Say this out loud in both sessions.

---

## H1 — From a cosmology to a density field

**Runs after Lecture 1. Target 90 min.**

### What students end up with

A linear power spectrum they coded from scratch, and a 3D Gaussian realization
of it saved to disk — the input to H2.

### Steps

| # | ~min | task | checkpoint |
|---|---|---|---|
| 1 | 15 | Code the **no-wiggle** Eisenstein & Hu transfer function `T(k)` | `T → 1` as `k → 0`; `T(0.0153) ≈ 0.675`; log-slope of `T` `≈ −1.67` over `0.5 < k < 5` |
| 2 | 10 | Build `P_L(k) = A k^{n_s} T²(k)`, normalise to `σ₈ = 0.81` | turnover at `k_eq ≈ 0.016 h/Mpc`; log-slope of `P_L` `≈ −2.38` over `0.5 < k < 5` |
| 3 | 10 | Swap in the **full** `T(k)` (supplied) and plot the ratio | BAO wiggles appear, few percent, first peak near `k ≈ 0.07` |
| 4 | 25 | Draw a Gaussian realization on a 128³ grid | `rms δ = 2.516` on this grid — see note below |
| 5 | 15 | Slice it, look at it, vary `n_s` and `Ω_m` with the seed fixed | larger `n_s` → more small-scale structure |
| 6 | 15 | Save `δ(k)` and `P_L(k)` for H2 | file loads cleanly in a fresh kernel |

### The step that will eat the session

**Step 4, the FFT normalization.** Getting `⟨δ²⟩ = ∫d³k/(2π)³ P(k)` right on a
discrete grid is where everyone loses time, and a wrong normalization is silent
— the field looks plausible and every downstream number is wrong. I made exactly
this mistake building the figure for these notes: `δ_rms` came out at 0.005
instead of 2.5, and nothing about the picture looked odd.

Give them the check, not the answer:

```
delta_k = rfftn(white_noise) * sqrt(P * N**3 / L**3)
```
and have them verify `np.std(irfftn(delta_k))` against a numerical
`∫d³k/(2π)³ P(k)` out to `k_Nyquist = πN/L = 1.61 h/Mpc`. The two agree to about
10%, and the residual is itself worth a minute: the grid carries corner modes
beyond `k_Nyq`, so the realized value runs slightly **high**.

### Fallback

Ship `notebooks/pk_lin_fiducial.txt` — a tabulated `P_L(k)`. No `delta_k_128.npy`
is shipped; the fallback regenerates the field deterministically from that
table and the fixed seed (1234) rather than restoring a blob. **H2 must not
depend on H1 having gone well.** Anyone behind reruns the fallback — it depends
on no student-written name — and proceeds.

---

## H2 — From a density field to the cosmic web

**Runs after Lecture 2. Target 90 min.**

### What students end up with

The figure on the front of Lecture 2, made by their own code: a slab through a
Zel'dovich-displaced field, and the same particles classified into void, sheet,
filament and knot.

### Steps

| # | ~min | task | checkpoint |
|---|---|---|---|
| 1 | 10 | Load H1's `δ(k)` (or the fallback) | `rms δ` matches what H1 reported |
| 2 | 20 | Compute `Ψ⁽¹⁾(k) = (ik/k²)δ(k)`, transform, displace | rms displacement `≈ 5.2 Mpc/h` per axis |
| 3 | 15 | Project a `15 h⁻¹Mpc` slab and plot | **a cosmic web appears** — this is the moment |
| 4 | 20 | Build the deformation tensor `D_ij(k) = k_i k_j δ(k)/k²`, get eigenvalues, count how many are positive | volume fractions `8 / 42 / 42 / 8` per cent |
| 5 | 15 | Colour the slab by class | knots on the nodes, filaments on the strands |
| 6 | 10 | Add 2LPT and compare | filaments visibly sharper |

### Why 3D, and not 2D

**In two dimensions there are no filaments.** The deformation tensor is 2×2, so
there are only two eigenvalues and three classes — the sheet/filament
distinction does not exist. A 2D version cannot produce the object the lecture is
about. 128³ is a handful of numpy FFTs and runs in seconds; the only real cost is
rendering, and a slab projection handles that in three lines.

### Checkpoints worth stopping on

- **Step 2**: displacements come out ~10% *low* against the continuum
  `⟨Ψ²⟩ = (1/6π²)∫dk P(k)`, because a 250 Mpc/h box has no power below
  `k_f = 0.025 h/Mpc`. Physical, not a bug — and a good five-minute discussion of
  what a finite box costs you.
- **Step 4**: the `8/42/42/8` split is Doroshkevich's result, and students get it
  from their own realization. If they get `25/25/25/25` they have used the wrong
  sign convention; if they get `0/0/0/100` they have forgotten `k²` in the
  denominator.

### Suggested closing

Put the [Sandbox](https://minhmpa.github.io/lss-lab/cosmic-web-sandbox/) on the
projector next to their output. Same transfer function, same LPT, same
classification, 3D and interactive. The point to land: *you just built this.*

---

## Notes for whoever implements these

- `figs_src/ptlib.py` already has the E&H transfer function (`_eh_full`,
  `_eh_nw`), the `σ₈` normalization and the growth factor, all verified.
- `figs_src/make_fig_web.py` is a working reference implementation of H2's
  steps 2–5 and produces the Lecture 2 figure. Do not hand it to students, but
  do check their output against it.
- Both sessions want a fixed seed of **1234** so their pictures match the notes.
- Budget an extra 15 minutes in H1 for installs. There is no way around it.
