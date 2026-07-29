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

A linear power spectrum they coded from scratch, a 3D Gaussian realization of
it, and a measurement of how far their hand-rolled transfer function sits from
a Boltzmann code.

### Steps

| # | ~min | task | checkpoint |
|---|---|---|---|
| 1 | 15 | Code the **no-wiggle** Eisenstein & Hu transfer function `T(k)` | `T → 1` as `k → 0`; `T(0.0153) ≈ 0.675`; log-slope of `T` `≈ −1.67` over `0.5 < k < 5` |
| 2 | 10 | Build `P_L(k) = A k^{n_s} T²(k)`, normalise to `σ₈ = 0.81` | turnover at `k_eq ≈ 0.016 h/Mpc`; log-slope of `P_L` `≈ −2.38` over `0.5 < k < 5` |
| 3 | 10 | Swap in the **full** `T(k)` (supplied) and plot the ratio | BAO wiggles appear, few percent, first peak near `k ≈ 0.07` |
| 4 | 25 | Draw a Gaussian realization on a 128³ grid | `rms δ = 2.516` on this grid — see note below |
| 5 | 15 | Slice it, look at it, vary `n_s` and `Ω_m` with the seed fixed | larger `n_s` → more small-scale structure |
| 6 | 15 | Install CAMB, compare `T(k)` against it, decompose the disagreement | `T_EH/T_CAMB` within 1% on the broadband, **2.67% at `k ≈ 0.09`**; wiggle amplitude ratio `0.978` |

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
is shipped, and H1 saves nothing: H2's step 1 regenerates the field
deterministically from that table and the fixed seed (1234) rather than
restoring a blob. **H2 must not depend on H1 having gone well.** The rebuild
depends on no student-written name, so anyone whose H1 code was broken — or
who never ran H1 — starts H2 from the same field as everyone else.

That is also why H1 no longer ends on a save step. Once the rebuild is
deterministic, the file it would have written is one nothing reads.

---

## H2 — From a density field to the cosmic web

**Runs after Lecture 2. Target 90 min.**

Shipped as a single notebook, `H2_cosmic_web.ipynb`, not a student/solutions
pair like H1: the three solution cells sit inline, collapsed, so `Run All`
reproduces every number below either way (ADR 0002).

### What students end up with

The figure on the front of Lecture 2, made by their own code: a slab through a
Zel'dovich-displaced field, the same particles classified into void, sheet,
filament and knot, a 2LPT correction on top of it, and that correction checked
against `flowpm.tfpm.lpt2_source`, a production N-body code.

### Steps

| # | ~min | task | checkpoint |
|---|---|---|---|
| 1 | 10 | Rebuild H1's field, live from CAMB (fallback: `pk_lin_fiducial.txt`), seed 1234 | `rms δ = 2.5305` — not H1's `2.516`; CAMB's `T(k)` differs from the hand-rolled Eisenstein & Hu |
| 2 | 12 | Compute `Ψ⁽¹⁾(k) = (ik/k²)δ(k)`, transform, displace | `\|∇·Ψ + δ\|/\|δ\| = 0.028`, well under the `0.05` bound — the unique curl-free field with `∇·Ψ = −δ` |
| 3 | 15 | Project a `15 h⁻¹Mpc` slab at `z=49` and `z=0` | at `z=49` it's still the barely-perturbed Lagrangian grid; **the web appears at `z=0`** — this is the moment |
| 4 | 16 | Build the deformation tensor `D_ij(k) = k_i k_j δ(k)/k²` from the *undisplaced* field, get eigenvalues, count how many are positive; check shell-crossing | volume fractions `8 / 42 / 42 / 8` per cent; **63.9%** of the box has shell-crossed by `z=0`, first crossing at `z ≈ 6.9` |
| 5 | 10 | Colour the slab by class | knots on the nodes, filaments on the strands |
| 6 | 15 | Add 2LPT: `δ⁽²⁾ = Σ_{i<j}[φ,ii φ,jj − φ,ij²]`, `Ψ⁽²⁾ = (3/7)D₁²∇∇⁻²δ⁽²⁾` | `(3/7)\|Ψ⁽²⁾\|/\|Ψ⁽¹⁾\|` is `0.005` at `z=49`, `0.181` at `z=0` — 2LPT is trustworthy where that ratio is small, i.e. early, not today |
| 7 | 10 | Benchmark `δ⁽²⁾` against `flowpm.tfpm.lpt2_source`, both sides on FlowPM's finite-difference gradient | `max\|ours − FlowPM\|/max\|FlowPM\|` measured `~5×10⁻⁷`, asserted `< 1×10⁻⁴` |

### Why 3D, and not 2D

**In two dimensions there are no filaments.** The deformation tensor is 2×2, so
there are only two eigenvalues and three classes — the sheet/filament
distinction does not exist. A 2D version cannot produce the object the lecture is
about. 128³ is a handful of numpy FFTs and runs in seconds; the only real cost is
rendering, and a slab projection handles that in three lines.

### Checkpoints worth stopping on

- **Step 2**: displacements come out ~11% *low* against the continuum
  `⟨Ψ²⟩ = (1/6π²)∫dk P(k)`, because a 250 Mpc/h box has no power below
  `k_f = 0.025 h/Mpc` — that missing power is 24% of `∫dk P(k)` but only 0.01%
  of `∫dk k²P(k)`, which is why density is fine and displacement is not.
  Physical, not a bug — and a good five-minute discussion of what a finite box
  costs you. The checkpoint itself is `∇·Ψ = −δ`, not the rms of `Ψ`: the three
  axes individually disagree by ±12% on identical correct code (the box's
  longest modes dominate `Ψ` and there are few of them), so only the identity
  that must hold *by construction* is worth asserting on.
- **Step 4**: the `8/42/42/8` split is Doroshkevich's result, and students get it
  from their own realization, classified on the *initial*, undisplaced field —
  classifying the displaced field instead breaks Gaussianity and the theorem
  with it. The split is robust to the two classic bugs: a wrong sign
  (`−k_ik_jδ/k²`) measures `8.0/42.0/42.1/8.0`, the same palindrome with every
  label silently swapped, because a zero-mean Gaussian field is symmetric
  under `δ→−δ`; a dropped `k²` measures `8.2/41.9/41.8/8.2`, because the
  fourth moment of `k̂` fixes the angular structure and the radial weight only
  rescales the variance, which the fractions do not see. The fractions
  certify statistics, not physics — the coloured slab in step 5 is what
  certifies that the knots landed on the nodes. The same cell measures that
  **63.9%** of the box has already shell-crossed by `z=0`,
  which is the honest verdict on step 3's picture: Zel'dovich assumes streams
  never cross, and by today most of the volume has.
- **Step 7**: the win isn't that FlowPM matches CAMB and this notebook agree —
  it's that FlowPM's gradient convention (a hardcoded finite difference, not
  spectral) has to be reproduced by hand before the comparison means anything.
  Skip it and you get a package-vs-package number that's actually just a
  discretisation artifact.

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
