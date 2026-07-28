# 2. H2 departs from H1's format and runs at two redshifts

Date: 2026-07-29
Status: Accepted

## Context

H1 ships two notebooks generated from one `make_notebooks.py`: a student file
with `# TODO` stubs that halts at `NotImplementedError`, and a solutions file.
`verify_notebooks.py` proves the stubs are real by checking that the student
notebook *fails*.

H2 was specified in `HANDS_ON_SPEC.md` as six steps ending in 2LPT, with a
`rms Ψ_x ≈ 5.2 Mpc/h` checkpoint on the displacement, and a benchmark against a
public LPT code added later. Designing it surfaced three problems that only
appear when the numbers are measured rather than assumed.

## Decision

**H2 is a single notebook of working code**, teaching through inline `# quiz:`
comments in the style of the school's other notebooks, with three stubs —
`Ψ⁽¹⁾`, the positive-eigenvalue count, and the 2LPT source `δ₂` — whose
collapsed solution cells *overwrite* them, so Run-All always produces the web.

**H2 displaces at two epochs.** The benchmark against `flowpm` runs at
z = 49; the cosmic web is drawn at z = 0. Since `Ψ⁽¹⁾ ∝ D₁` and `Ψ⁽²⁾ ∝ D₁²`,
both come from one set of FFTs and two scalars.

**The step-2 checkpoint is `∇·Ψ = −δ`,** not the specified rms.

## Why

**On format.** H1's payoff is a printed number; H2's is an image. Gating the
cosmic web behind a student's correct `rfftn` indexing fails the students who
most need to see it, and the closing benchmark cannot run against half a room's
`NotImplementedError`. The `# quiz:` model shifts the work from *writing* code
to *interrogating* it, which suits a session whose content is three formulae and
one picture.

**On redshift.** Measured on the fiducial field:

| z | D₁ | rms Ψ⁽¹⁾ | in cells | shell-crossed | Ψ⁽²⁾/Ψ⁽¹⁾ |
|---|---|---|---|---|---|
| 49 | 0.0255 | 0.137 | 0.07 | 0.00% | 0.5% |
| 0 | 1.0000 | 5.394 | 2.76 | 63.6% | 18% |

At z = 49 — where LPT is used in practice and what these codes are built for —
particles move a fifteenth of a cell and there is nothing to see. At z = 0 the
web appears, and two thirds of the box has shell-crossed; the first crossing is
at z = 6.8. Neither epoch alone is honest. Splitting them lets the benchmark run
where LPT holds and the picture be drawn where it is visible, with the
violation stated rather than hidden. The shell-crossing fraction is free: it
comes from the same eigenvalues step 4 already computes for the web classes.

**On the checkpoint.** `rms Ψ_x ≈ 5.2` cannot serve as a checkpoint. Measured:

| what the student wrote | rms Ψ_x | ∇·Ψ vs −δ |
|---|---|---|
| correct, `i k/k²` | 5.202 | 0.028 |
| missing the `i` | 4.588 | 1.52 |
| **wrong sign, `−i k/k²`** | **5.202** | 2.00 |

A sign error gives *exactly* the expected value while building a universe where
matter flows out of overdensities. The rms is invariant under `Ψ → −Ψ`, so it
can never see it. The value is also unstable across axes — 5.202, 4.827, 6.075
for the three components of the same correct field — because `Ψ` is dominated by
the few longest modes the box holds. `∇·Ψ = −δ` is what `Ψ = (ik/k²)δ` means,
and it separates all three cases.

## Consequences

- `verify_notebooks.py` gains a second execution pass: with the solution cells
  removed, H2's checkpoints must **fail**. That is the property H1's halt-check
  protected, restated for a single-file notebook.
- H1 and H2 now use different `P_L(k)` — Eisenstein & Hu (`rms δ = 2.516`) and
  CAMB (`rms δ = 2.5305`). Both are correct for their own session; the 0.6%
  difference is not an error and `notebooks/pk_lin_fiducial.txt` is regenerated
  from CAMB for H2's fallback.
- The benchmark uses **FlowPM**, not JaxPM: one pip line, already proven in a
  Colab teaching notebook, and `flowpm.tfpm.lpt2_source` computes exactly the
  `δ₂` the students write. Its gradient kernel is the fastpm finite difference
  and is not switchable, so the benchmark cell *matches* that convention rather
  than comparing against it — the gradient scheme is deliberately not part of
  the comparison.
- `Ψ⁽²⁾` is compared on its own, not inside the total. At z = 49 it is 0.5% of
  the displacement, so a broken 2LPT would pass a total-displacement check.
- What the benchmark validates is the 2LPT *algebra*, not the students' exact
  array: their `δ₂` uses the spectral gradient the lecture derives, and the
  comparison re-computes it with FlowPM's kernel. The notebook must say so.

## Alternatives rejected

- **Keeping H1's two-file split.** Consistent, and reuses the build unchanged.
  Rejected because the web is the session's whole reward and the benchmark
  requires working code by definition.
- **z = 0 throughout.** One epoch, simpler narrative. Rejected because it
  benchmarks LPT against a reference in a regime where 63% of the box violates
  the approximation, which tests the codes' agreement on nonsense.
- **Dropping the classification to make room for the benchmark.** Rejected: the
  `8/42/42/8` split is what answers §2.3, "Why a web, and not a collection of
  spheres." The benchmark was cut to a 10-minute closing demo instead.
