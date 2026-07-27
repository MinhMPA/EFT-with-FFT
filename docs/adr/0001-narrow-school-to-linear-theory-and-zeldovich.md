# 1. Narrow the school to linear theory and the Zel'dovich picture

Date: 2026-07-27
Status: Accepted

## Context

The notes were written for a stated endpoint of the one-loop EFT galaxy power
spectrum in redshift space, across three 90-minute lectures. Measurement during
review found:

- content ran ~236 minutes of board time against ~195 available;
- the linear matter power spectrum — the input every later lecture consumes —
  received **2.5 minutes**, while Section 1.1, which only licenses the
  framework, received 22;
- the hands-on session had a fixed slot that conflicted with the logical order
  of the material, forcing a reorder of the notes.

Three options were weighed. Keeping the full scope leaves it ~40 min over and
requires the hardest material to be shown rather than derived. Narrowing to
linear theory across three lectures leaves it ~135 min *under*, needing more new
writing than it preserves. The third is to narrow the scope and the format
together.

## Decision

Narrow the school to: **primordial perturbations → linear matter power spectrum
→ Zel'dovich and LPT → cosmic web → linear galaxy bias as a bridge.**

Deliver as **two 90-minute lectures (65 min at the board, 25 for questions)
alternating with two hands-on sessions**: L1 → H1 → L2 → H2.

The EFT of large-scale structure, nonlinear galaxy bias, redshift-space
distortions and the one-loop machinery fork into a second document for a
different school.

## Consequences

**Good.** Every lecture is followed by a practical that consumes it, and the two
practicals chain: H1 builds `P_L(k)` from a transfer function the students code,
then draws a Gaussian realization; H2 displaces that realization into a cosmic
web. The scope's payoff — a web rather than spheres — is built by students
rather than described to them. Everything in the course is derivable at the
level of the audience. The Cosmic Web Sandbox
(github.com/MinhMPA/lss-lab/cosmic-web-sandbox) runs the same pipeline —
Eisenstein & Hu transfer function, LPT, T-web eigenvalue classification — so it
serves as a live demonstration in both lectures and as H2's target.

**Accepted costs.** ~117 minutes of written material, three figures and eight
exercises leave this document. Board time drops from 195 to 130 minutes.
Section 1.1 trims from 22 to ~10 minutes, undoing depth added during review. Two
documents must be kept in sync where they share linear theory. H2 depends on H1
succeeding, mitigated by shipping a tabulated `P_L(k)` fallback.

**Neutral.** Wick's theorem leaves with the loops; it exists in the current notes
only to generate loop integrals.

## Alternatives rejected

- **Three lectures, one hands-on (L1 → L2 → H1 → L3).** More board time, but the
  cosmic web is never built — it arrives in the final lecture with no practical
  after it, so the stated learning outcome ("students know `P_L(k)` can be used
  as input to run N-body via Zel'dovich or LPT") is asserted rather than
  delivered.
- **Keeping the EFT material as an unlectured final chapter.** Preserves
  everything at zero risk, but leaves a 30-page document for a two-lecture
  school.
- **Deleting the EFT material, recovering from git.** Cleanest result, but the
  second school would start from archaeology against a rotted baseline.
