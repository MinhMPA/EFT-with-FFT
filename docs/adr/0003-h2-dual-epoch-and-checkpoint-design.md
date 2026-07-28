# ADR 0003: Hands-on 2 — Dual Epoch Strategy and Checkpoint Design

**Status:** Decided

## Context

Hands-on 2 displaces particles using Zel'dovich (1st order) and 2LPT (2nd order), comparing against JaxPM. Two tensions arose:

1. **When to run the benchmark?** LPT is valid only at early times (z≫1, displacements <0.2 cells). But the cosmic web becomes visible only at z=0, where displacements exceed 2.7 cells and shell crossing is pervasive (64% of the volume). Running the benchmark at z=49 produces an invisible grid; running at z=0 tests code outside its domain of validity.

2. **How to validate displacements?** The spec's checkpoint was `rms Ψ_x ≈ 5.2 Mpc/h`. But this statistic is invariant under `Ψ → −Ψ`, so it passes a sign error that inverts the physics — matter flowing out of overdensities instead of into them. Additionally, because the box holds only ~10 modes near k_f, the per-axis rms fluctuates by ±12% across identical correct code (realized 5.202 / 4.827 / 6.075 Mpc/h). No single number can serve as a checkpoint.

## Decision

1. **Compute and display both epochs.** 
   - At z=49 (a=0.02): run the benchmark against JaxPM. Zel'dovich is 5–10σ accurate; 2LPT is 0.5% of the total and buried in noise. This tests 1st-order implementation cleanly.
   - At z=0: display the cosmic web. Shell crossing is 64%, Zel'dovich is invalid, but this is exactly what §2.4 of the lecture examines. The picture is the payoff; its invalidity is the lesson.

2. **Replace the `rms Ψ_x` checkpoint with `∇·Ψ = −δ`.**
   - Derived from the governing equation: `Ψ⁽¹⁾ = (ik/k²)δ` implies `∇·Ψ = −δ` exactly in linear theory.
   - Catches sign errors (measured 2.00), missing `i` (1.52), wrong `k²`, and axis misalignment — all at once.
   - Tolerance: `|∇·Ψ + δ|_rms < 0.05` (residual is the Nyquist singularity for even N, ~0.028).
   - The observation `rms Ψ_x ≈ 5.2` becomes a springboard for finite-box discussion, not a pass-fail.

## Consequences

- **Teaching:** The dual-epoch display connects z=49 (where approximations are safe) to z=0 (where they fail visibly). Students see both sides of the validity boundary, not as an abstract claim but as a measurement.
- **Checkpoint robustness:** A self-consistency check derived from first principles catches more bugs and cannot be fooled by symmetries of a scalar statistic.
- **Budget:** Running two epochs costs negligible extra time (FFTs evaluated at two growth values). Shell-crossing validity folded into step 4 (~4 min, free from eigenvalues already computed). Total H2 ≈88 min.

## Alternatives Considered

- **Single epoch at z=49:** Invisible to students. No cosmic web, no shell crossing, no §2.4. Weak pedagogically and makes the benchmark pointless (why compute something you can't see?).
- **Single epoch at z=0:** Benchmark is invalid; hard to know if disagreement with JaxPM is code or physics. Easier to implement but loses the clean-code validation.
- **Keep `rms Ψ_x` checkpoint, accept it passes sign errors:** Catches most mistakes but not the sign. A web flowing backward is hard to spot on the first look, and the error propagates into 2LPT. Not acceptable.
