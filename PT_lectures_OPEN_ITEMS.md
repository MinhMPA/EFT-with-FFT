# PT_lectures — status and remaining open items

Draft v9. `PT_lectures.pdf` (28 pp) and `PT_lectures_solutions.pdf` (8 pp) both
compile clean with zero warnings.

**This file and everything it describes are untracked in git.** Twenty-eight
pages through four rounds of correction plus a full structural reorder, with no
version history. The reorder verification could not check what a caption trim
had removed, because there was no prior version to diff. Worth committing.

## Current structure (after the 2026-07-27 reorder)

The lectures were re-cut so the hands-on session, which follows Lecture 1 in a
fixed slot, has the material it needs: linear `P(k)`, LPT, 2LPT.

| | |
|---|---|
| **L1** Linear evolution, the matter power spectrum, and the Zel'dovich picture | 1.1 Newtonian regime · 1.2 pressureless fluid and linear growth · 1.3 Gaussian fields and `P(k)` · 1.4 the linear matter `P(k)` · 1.5 Lagrangian picture and ZA · 1.6 2LPT and initial conditions |
| *hands-on* | uses §1.4 and §§1.5–1.6 |
| **L2** From displacements to loops, and where they fail | 2.1 Wick's theorem · 2.2 Eulerian PT · 2.3 contact with the Lagrangian picture · 2.4 one-loop `P(k)` · 2.5 why bare SPT is incomplete · 2.6 EFT |
| **L3** Galaxies in redshift space at one loop | unchanged |

Each plan block is now 65 min at the board + 25 for questions, and each carries
an explicit **read, not lectured** list. Total content ~164 min against 195
available. The balance is uneven by word count (L1 ~40, L2 ~71, L3 ~53) but word
count misleads: L1 is derivation-heavy and slower per word than L2's discursive
EFT prose. §2.6 is the section whose written detail most exceeds its allocation,
which its plan block now states outright.

Two design points worth keeping:

- **The old §1.3 was split.** What a power spectrum *is* (homogeneity → the
  delta function, isotropy → `P(|k|)`, and how to draw a realization) stays in
  L1, where `P_L` needs it and where the hands-on needs it. Wick's theorem moves
  to L2, where it is used within twelve minutes rather than forty.
- **The `F_2`/LPT contact became a payoff.** In the old order §2.2 pointed
  forwards to a kernel not yet defined; now §2.3 opens by noting the ingredients
  were already in place in Lecture 1, in Lagrangian dress.

Exercises were redistributed: L1 has 1.1 geodesic, 1.2 `D_2`, 1.3 1D-ZA; L2 has
2.1 `F_2`, 2.2 IR cancellation, 2.3 LPT reproduces `F_2`, 2.4 `c_s^2` running,
2.5 stochastic `k^4`. L3 unchanged. The solutions file was reordered to match.

### What the reorder broke, and what caught it

A programmatic check confirmed **zero equation references cross a lecture
boundary forwards** — the check compilation cannot do, since a `\eqref` to
something fifteen pages later compiles perfectly. Adversarial review then found
five prose problems the reorder created:

- **A false ordering claim.** "Two structural features set the agenda for the
  rest of this lecture" was true when Lecture 2 held both LPT and the EFT. After
  the re-cut only the UV half is answered there; the IR half is answered
  backwards in L1 and forwards in L3.
- An antecedent stranded a section and a half from its referent ("the Comment
  above"), `P_L` effectively defined twice in the reversed order, "the closure"
  now pointing across a lecture boundary, and a Lecture-1 solution depending on
  `F_2`, which is now a Lecture-2 object.
- My own new §2.3 opener overstated: it claimed students had already built `F_2`,
  when Lecture 1 supplies the ingredients but not the expansion that yields it.
- "The hands-on session" was referred to three times with the definite article
  and never introduced. Now named in the front matter.

All fixed. Prose seams, exercise/solution correspondence, plan-block accuracy,
and byte-level preservation across both cuts verified clean.

## The expert review (2026-07-26)

An external expert review (`PT_lecture_expert_review.pdf`, 19 pp, 120 numbered
items) returned "not ready to teach or distribute unchanged" with twelve
mandatory corrections. I verified all twelve against the source before acting:
ten were correct, two were overstated, and one was already superseded by the
multipoles-figure replacement made the previous day. **All twelve have been applied.**

Genuinely wrong physics it caught, and that is now fixed:

- **IR cancellation vs BAO smearing.** The notes said the cancellation "is exact
  for smooth broadband power but not for sharp features". Wrong: the strict
  q→0 cancellation is exact for *any* shape of the spectrum, BAO included. What
  survives is the *finite* remainder from modes soft relative to k but with
  q/k_osc of order unity. Rewritten in Lecture 1, Section 3.3, Exercise 1.3 and
  its solution.
- **`f_2 = dln D_2/dln a`** with the convention `D_2 < 0`. A real logarithm of a
  negative number. Now `dln|D_2|/dln a`.
- **Appendix B was missing `a^-2`** on the gravitational stress. Confirmed
  independently: with the comoving Poisson equation, `(1/rho) d_j tau_ij` only
  has the dimensions of `grad Phi` if the factor is there. The appendix now also
  gives the exact kinetic term (smoothed flux minus flux of the mass-weighted
  long velocity) rather than the schematic `rho u_s u_s`.
- **The higher-derivative bias operator carried no free coefficient.** Symmetry
  fixes the operator, not its amplitude or its sign. Now `b_{grad^2 delta}`.
- **"SPT has no expansion parameter"** contradicted the notes' own power
  counting two sections earlier. Section 2.3 is rewritten around the accurate
  statement: the expansion in the *external* momentum is fine; the problem is
  that loops integrate over *internal* momenta where the dust equations are
  invalid, so part of the coefficient is not predicted. Also removed
  "cutoff-dependent in any case", which is false for spectral index n < -1.

Where I did not simply follow the review: its item 2 is graded "must fix" but
the notes already said "second-order *amplitude*", so that was a tightening, not
an error; and its item 10 recommends replacing claims about `f` with `f sigma_8`
in the BAO/RSD-compression framing, whereas EFT full-shape analyses report
`sigma_8` directly. The replacement text says the narrower, defensible thing.

One departure worth recording: Baumann et al. (2010) states that virialized
scales "decouple completely ... at all orders", which is what the notes
originally paraphrased. The revised text says the effect is suppressed by powers
of k/k_NL and by multipole structure — decoupling, not exactly zero. That is the
more careful statement and is compatible with the source's meaning, but it is a
deliberate divergence from its wording.

## What the review prompted beyond the errata

- **The notes are now framed as a pre-read**, not a lecture transcript. All three
  "Plan" blocks are rewritten as 80 minutes of content plus 10 for questions,
  naming which derivations go to the board and which are reading. This addresses
  both the review's largest structural complaint and the pacing concern already
  recorded here from the undergraduate reader.
- **A Scope box** in the front matter lists the assumptions in force (Gaussian
  adiabatic ICs, single pressureless fluid, EdS kernels, plane-parallel, one
  tracer, one effective redshift).
- **The Goal was downgraded from "compute" to "derive the anatomy of, and
  evaluate with a supplied code".** The appendices do not give `Z_3`, and
  pretending otherwise was an overpromise.
- **New Appendix E** on the survey measurement operator: binning, the window
  matrix and multipole mixing, integral constraints, fibre collisions,
  effective-redshift and covariance approximations. High level by choice.
  Step 5 of the recipe (now six steps) points at it.
- **Two new exercises**: the cutoff running of `c_s^2` (the review's point that
  half of Lecture 2 is EFT but none of the exercises tested it), and why matter
  stochasticity starts at `k^4`. Exercise 3.2 now asks for the full `Z_2`
  derivation, and the solution does it term by term instead of classifying.
- **Bibliography**: Baumann Cargèse now has a year (2018) and a URL — that open
  item is closed. Added the DESI EFT model comparison (2404.07272), DESI 2024 V
  (2411.12021), and the DESI DR1 reanalysis (2507.13433); all three arXiv IDs
  verified against the abstracts, not taken from the review on trust.

## Verification performed

Numerically, before accepting the new material:

- The angle-averaged hard-pair limit of `F_3` reproduces `-61/1890` to 8 digits
  against kernels built independently from the recursion relations, and composes
  to exactly `61/105` for the `P_13` UV limit. This is what the new `c_s^2`
  running exercise rests on.
- The counterterm cancellation is cutoff-independent to all printed digits over
  `Lambda = 1` to `30 h/Mpc`.
- The `Z_2` identity in the new solution matches Eq. (C.1) to machine precision
  over random configurations, via `k mu = k_1 mu_1 + k_2 mu_2`.

An independent agent re-derived the whole solutions file from scratch and
confirmed the `Z_2` derivation step by step, the exercise renumbering (Lecture 2
is now 2.1–2.5), and that no solution still claims the full shape by itself
measures `f`.

### The verification earned its keep: one fix was wrong

An adversarial pass over the twelve corrections found that **my** new Table 1
caption was wrong. It claimed `b_{grad^2 delta} R_*^2` and `c_0` "produce the
same shape, so only their sum is measurable". Two errors: even in real space the
combination carries a `b_1` weight, and in redshift space the higher-derivative
bias enters through the linear kernel, `Z_1 = b_1 + f mu^2 - b R_*^2 k^2`, so
squaring gives `-2(b_1 + f mu^2) b R_*^2 k^2 P_L`. Confirmed symbolically: it
shifts `c_0` by `b_1 b R_*^2` **and** `c_2` by `b R_*^2`. The degeneracy is with
a *direction* in counterterm space, not with `c_0` alone. Now stated correctly.

Three further overstatements in the new material, all corrected:

- **Appendix B said "exact".** It smooths the *pressureless-fluid* equations, in
  which `sigma_ij = 0` by construction, so what it derives is the coarse-graining
  remainder. Starting from the second Vlasov moment (`rho u_i u_j + rho
  sigma_ij`) would add `[rho sigma_ij]_Lambda`. The two play the same role but
  are not the same object; the appendix now says so.
- **Section 3.3 said `q/k_osc` is "of order unity".** Wrong momenta. Checked
  numerically against the notes' own `Sigma^2` kernel: 10/50/90% of the damping
  accumulates by `q/k_osc = 1.9 / 4.6 / 15.6`. The point is that `q/k_osc` is
  *not small*, generically several times unity. (The small-`x` kernel goes as
  `0.3 x^2`, verified to three digits, which is why the truly soft modes
  contribute almost nothing.)
- **The new `c_s^2` exercise said the cancellation is "exact".** It holds at
  order `k^2 P_L`, using the UV limit of `P_13`; the full `P_13` has finite
  pieces of other shapes.

Also corrected: the integral constraint in Appendix E was written as a fixed
additive offset, when it is linear in the model and is folded into the window
matrix in practice; and the Bernardeau `Omega^(-2/63)` number is quoted for the
open (`Omega_Lambda = 0`) case, which the text now says.

A separate internal-consistency sweep found twelve propagation failures,
including a false claim I had introduced in the new Scope box, an orphaned
equation label, and a multipoles-figure caption that credited the computation to the
companion *note* rather than to the code that produced it. All fixed.

## Second pass: the non-mandatory review items

A filtered pass over the ~108 items outside the mandatory twelve, prioritising
the two remaining "must fix" entries in the detailed audit, the items that serve
the stated audience (rising junior/senior undergraduates, with Wick's theorem to
be made clear), and the two appendix gaps.

**New Figure 6, `figs/cutoff_running.pdf`.** The review argued a cutoff-running
figure "would teach renormalization more directly than a single halofit
comparison", and it was right. Left panel: one-loop SPT with the loop integrals
cut off at `Lambda = 0.5, 1, 2, 4 h/Mpc` — four different predictions, spread by
6.2% at `k = 0.25`. Right panel: the same four after fitting one `c_s^2` per
cutoff — spread 0.17%. It is also an independent numerical confirmation of the
new exercise: the measured running converges to `dc_s^2/dsigma_v^2 = -0.2901`
against the analytic `-61/210 = -0.2905`, agreement improving with scale
separation (-5.2%, -0.6%, -0.1% across the three cutoff pairs). The fitted
`c_s^2 -> 1.12` at the largest cutoff, consistent with the 1.1 quoted for
Fig. 3. Generated by `figs_src/make_fig_running.py`, self-contained.

Two remaining "must fix" items from the detailed audit, both real:

- **The transfer-function paragraph contradicted the gauge Comment above it.**
  It said large-scale modes "grow as `a` throughout matter domination", which is
  false in the Newtonian gauge for a mode still outside the horizon — the same
  gauge subtlety the Comment had just made. Rewritten.
- **Homogeneity and isotropy were conflated.** The delta function follows from
  homogeneity; `P` depending on `|k|` follows from isotropy. Now separated, with
  the reality-condition caveat on "modes of different wavevector are
  uncorrelated".

For the undergraduate audience specifically:

- **A finite-volume box** now precedes the Wick material: discrete modes, an
  ordinary Kronecker delta, and the counting visible before any Dirac deltas.
- **One complete contraction is displayed** with every delta function shown, and
  the bookkeeping spelled out (Wick deltas remove the primed integrals, `F_2` is
  even, the leftover delta is stripped in defining `P`).
- The `k=0` self-contraction is now named a **zero-mode/tadpole subtraction**,
  and said to be removed by construction rather than neglected.
- Exercise 1.2 gains the check `F_2(q,-q) = 0` — verified to machine precision —
  as mass conservation made concrete.

Also: a **notation table** in the front matter, flagging the `G_n` (velocity
kernel) vs `G_2` (bias operator) typeface collision explicitly; `D_A` replaced by
the comoving `D_M` throughout the AP discussion, with the volume Jacobian stated
as part of the model rather than a parenthetical; a note that counterterms
absorb only shapes in the retained basis, so missing non-analytic physics is
mismodelled rather than absorbed; and Appendix D now states what it does *not*
give you — the convergence strip and analytic continuation of the Gamma-function
formula, tilt/padding/windowing choices, and a numerical-validation checklist.

### Verification of the second pass: another fix was wrong

The same adversarial treatment applied to the second round, and again earned it.

**The tadpole sentence I added was wrong, and self-contradictory.** I wrote that
the `k=0` self-contraction "shifts the mean density" and is "removed by
construction". But that term is proportional to `F_2(q,-q)`, which the same page
states is zero — the exercise I had *just added* proves it. For matter the term
vanishes outright; there is nothing to subtract. The tadpole framing is imported
from the biased-tracer case, where `b_2<delta^2>/2` genuinely is nonzero and
genuinely is renormalized away. Both statements are now made, in the right
places. Worth noting the failure mode: two correct additions, made minutes
apart, that contradicted each other.

**Figure 4 claimed more than it showed.** Four corrections:

- "An ambiguity of the same size as the correction being computed" was off by
  9x. At `k = 0.25` the one-loop correction is 57% of `P_L`; the cutoff spread
  is 6.5 percentage points, so about a *tenth* of the correction.
- The "6%" and "0.2%" were percentage points *of `P_L`*, the plotted quantity,
  not fractional spreads of the prediction. Now labelled as such, in the caption
  and on the figure itself.
- **The collapse was measured inside the fit range, so it is partly
  guaranteed.** A one-parameter fit to a common target over `0.10-0.25` forces
  agreement there whether or not the `Lambda` dependence has the `k^2 P_L`
  shape. The honest number is the one outside: beyond `k = 0.25` the spread is
  2.0 points against 7.8 bare. Still a factor of four, and that part is real.
  The caption now gives both.
- The running was quoted from the single best cutoff pair. All three are now
  given (`-0.275, -0.289, -0.290`), with the asymptotic trend identified as the
  result rather than the four-digit agreement of the last pair.

The method itself survived: the smooth window `1/(1+(q/Lambda)^12)` reproduces
the sharp-cutoff `sigma_v^2` to better than 0.1%, and because the loops and
`sigma_v^2` use the same weighted spectrum, the extracted running is
self-consistent. The fitted `c_s^2` is affine in `P_SPT`, so *differences*
between cutoffs are exactly independent of halofit — the running measurement is
not contaminated by the reference. Two code inconsistencies were fixed anyway:
`p13`'s external `P_L(k)` leg was being regulated along with the loop, and the
quoted `k=0.25` was really grid point 0.2416.

**An Appendix D claim was simply false.** I had written that `P_22` and `P_13`
suffer a catastrophic low-`k` cancellation against each other. They do not — for
LCDM the totals do not cancel, `P_13` just dominates. What cancels is the
*soft-region piece* of each, `±k^2 sigma_v^2 P_L`. And an "IR-safe combined
integrand" is direct-quadrature advice that does not apply to FFTLog, which
contracts precomputed matrices with no integrand to combine. Rewritten, with the
scale-free `n <= -1` case distinguished from LCDM.

Also corrected: kernel property 1 attributed `F_n ∝ k^2` to momentum
conservation alone, when the `k^0` term is killed by mass conservation and only
the `k^1` term by momentum — inconsistent with the new `ex:stoch`, which had it
right; a reality-condition sentence that read as if reality caused the `k'=-k`
exception, when homogeneity does; "non-analytic or linearly independent" (the
first is a special case of the second); five notation-table entries; and an
Appendix D passage that presented as a gap something the appendix already said
while leaving the tilt constraint unquantified — it now gives the window
`-3 < nu < -3/2`, which I re-derived from the pole locations.

### Third verification round: two more, both mine

**An Appendix D claim my own equation forbade.** I wrote that the soft-region
piece `k^2 sigma_v^2 P_L` is "far larger at low k than either total" of `P_22`
and `P_13`. True for `P_22` (35x at k=0.005, since its total is O(k^4)).
Impossible for `P_13`: by `eq:P13_UV`, quoted three pages earlier in the same
document, the soft piece *is* the low-k total up to the fixed factor 105/61.
Verified directly — the ratio runs 1.77, 1.74, 1.69, 1.53 at
k = 0.005, 0.01, 0.02, 0.05, converging on 1.7213 from above. Rewritten to say
which term the test actually bites on.

**The AP-Jacobian bullet was backwards.** I wrote that omitting it "biases the
inferred distances rather than merely rescaling a nuisance parameter". The
opposite: the Jacobian is independent of `k` and `mu`, so it is nearly
degenerate with the free amplitude. Omitting it damages `b_1 sigma_8` and
`f sigma_8`, and reaches the distance parameters only through the loop terms'
different `sigma_8` scaling. That degeneracy is precisely why it is easy to
drop. Corrected in both the solutions bullet and the main-text sentence.

Also: the Fig. 3 softening had over-claimed at one number — Takahashi et al.
quote ~5% accuracy for halofit here, so SPT's 8% excess at k = 0.20 is only
~1.5x that, and only the 13% and 27% failures carry the argument. The figure
caption regained the identity of the black curve and the fit target, units on
`Lambda`, and a note that `P_13`'s external leg is deliberately left
unregulated.

Everything else in the round verified clean: the corrected tadpole passage and
its cross-reference, kernel property 1's conservation-law split, the
reality-condition rewrite, all eleven Vocabulary entries, the tilt window
`-3 < nu < -3/2`, every number in the Fig. 4 caption against the script's actual
output, and six of the seven "Errors worth recognising" bullets.

### The pattern

Three rounds of corrections, three rounds in which a correction introduced a new
error, each caught by adversarial checking and not by compiling, re-reading, or
self-review. Treat that as the standing cost of editing this document rather
than as something now finished. Any future substantive edit deserves the same
treatment.

## Figures

Computed from scratch in `figs_src/`; the loop integrator is validated in
`figs_src/validate.py` against independently-built recursion kernels (agreement
to 1 part in 10^6).

- **Fig. 1** diagrams (tree, P22, P13) — TikZ.
- **Fig. 2** the Zel'dovich eigenvalue sequence — TikZ. Caption and surrounding
  text rewritten: only the first crossing is dynamics, the final object is a
  knot in the deformation map and is no longer called a halo.
- **Fig. 3** EFT vs SPT vs halofit at z=0, as a ratio to linear theory.
  `c_s^2 = 1.1 (Mpc/h)^2` fitted over `0.10 < k < 0.25`.
- **Fig. 4** cutoff running and its cancellation (new this round).
- **Fig. 5** BAO damping from IR resummation at z=0.5, `Sigma = 4.15 Mpc/h`.
- **Fig. 6** the one-loop EFT galaxy multipoles in redshift space, computed by
  driving `ps_1loop_jax` from `/Users/nguyenmn/ps_1loop_jax-for-pfs`. The one
  figure script that is not self-contained (`figs_src/make_fig_multipoles.py`).

(Figure numbering in the PDF: 1 diagrams, 2 collapse, 3 cutoff running,
4 EFT vs SPT, 5 BAO damping, 6 multipoles.)

**Still open on figures:** the nonlinear reference in Fig. 3 is halofit, a
fitting formula good only to a few percent on these scales, not a direct N-body
measurement; and the points in Fig. 6 are a synthetic realisation, not a real
BOSS data vector. Both are labelled as such. Point me at a simulation output or
a public BOSS/DESI data vector and I will swap them in.

## Remaining open items

1. **The companion FFTLog note** is cited as "distributed with these lectures".
   Students need a link or an attached PDF. This is the last unresolved
   bibliography item.
2. **Lecture pacing still needs a clock.** The 80+10 schedules are the review's
   recommendation plus my own judgement; neither is a dry run. Lecture 3 remains
   the densest.
3. **The remaining non-mandatory review items.** The highest-value subset has
   now been done (see the second pass above): the notation map, the
   cutoff-running figure, the finite-volume Wick framing, the displayed
   contraction, and both leftover "must fix" entries. What is left is mostly
   pedantry, plus a handful of judgement calls I did not make unilaterally —
   common-error callout boxes in the solutions, a two-page prerequisite primer,
   and simulation- or HOD-informed nuisance priors as an alternative to broad
   top-hats. Say the word if you want any of those.
4. **A dozen terms are still used without definition** — transfer function,
   Boltzmann code, N-body simulation, window function, fingers of God, tracer,
   Meszaros effect, band powers. The notation table added this round covers
   symbols, not vocabulary. A short glossary would be cheaper than inline
   definitions. The review independently flagged the prerequisites as
   insufficient for the pace.
5. **Fig. 3's main-text claim** that EFT "tracks the reference to a few percent"
   is a quantitative statement made against halofit. The caption hedges it; the
   text does not. Worth aligning if you want the review's item 65 closed.
