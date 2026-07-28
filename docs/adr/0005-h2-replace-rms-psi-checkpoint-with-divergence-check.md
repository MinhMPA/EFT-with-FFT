# ADR 0005: Hands-on 2 — Checkpoint Design: Replace `rms Ψ` with `∇·Ψ = −δ`

**Status:** Decided (deviates from HANDS_ON_SPEC.md step 2)

## Context

The original spec (HANDS_ON_SPEC.md:71) specifies checkpoint 2 as:

> `rms displacement ≈ 5.2 Mpc/h per axis`

Testing this checkpoint for student code correctness reveals two critical failures:

### Failure 1: The Statistic is Invariant Under Sign Inversion

| student wrote | `Ψ⁽¹⁾ = (ik/k²)δ` | `rms Ψ_x` | `∇·Ψ` vs `−δ` |
|---|---|---|---|
| correct | ✓ | 5.202 | 0.028 |
| sign error | **`−ik/k²`** | **5.202** ✓✗ | **2.00** ✗ |
| missing `i` | `k/k²` | 4.588 | 1.52 ✗ |
| wrong axis | `ik/kx²` (on wrong axis) | 5.213 | 0.42 ✓ish |

A student who writes `−ik/k²` (matter flowing *out of* overdensities, reversing the physics) **passes the rms checkpoint exactly** because magnitude is invariant under negation. This is the most dangerous error possible: it silently produces an unphysical universe, and the picture of the web (step 3) only slowly reveals that something is inverted.

### Failure 2: The Statistic Has High Variance Across Axes

For this realization (seed=1234, N=128, L=250):

```
per-axis rms Ψ:  [ 5.202,  4.827,  6.075 ] Mpc/h
mean:             5.368 Mpc/h
std:              0.631 Mpc/h (±12%)
```

This spread is physical, not code error — the box holds only ~10 modes at k_f, and the longest modes have random phases. So no single number `rms Ψ ≈ 5.2` can serve as a checkpoint on a 250 Mpc/h box. Different seeds produce 4.5–6.0 from identical correct code.

## Decision

Replace the checkpoint with a **self-consistency check derived from linear theory:**

$$\nabla \cdot \boldsymbol{\Psi}^{(1)} = -\delta$$

This must hold *exactly* when `Ψ⁽¹⁾ = (ik/k²)δ` in linear theory. Measured on the grid:

```python
divergence_check = np.abs(np.fft.ifftn(1j*KX*psi_kx + 1j*KY*psi_ky + 1j*KZ*psi_kz).real + delta_x).rms()
assert divergence_check < 0.05
```

**Catches:**
- ✓ Sign errors (measured ~2.00)
- ✓ Missing `i` factor (measured ~1.52)
- ✓ Wrong power law on k (k vs k²)
- ✓ Axis misalignment

**Cannot be fooled by:**
- Magnitude scaling (any uniform Ψ→c·Ψ fails this check, not `rms`)
- Sign inversion (−Ψ gives −∇·Ψ, failing the check)
- Axis permutation (∂_x(ψ_y) ≠ 0 on its own)

**Tolerance: `< 0.05`** accounts for:
- FFT grid alias at Nyquist (even N has k_Nyq appearing once, ambiguous sign)
- Residual 0.028 for correct code, 12× safety margin

## Consequences

- **Checkpoint robustness:** Derived from first principles, not a magic number. Students understand what it tests (the relationship between Ψ and δ they just built).
- **The observation becomes the discussion:** `rms Ψ ≈ 5.2` is no longer a pass-fail target but the springboard for the finite-box discussion: `∫P (all k) = 5.83`, `∫P (k_f→k_Nyq) = 5.04`, realized with corner modes = 5.20. The 24%-vs-0.01% mass-per-mode contrast explains *why* Ψ but not δ notices the box.
- **Budget:** Costs no extra compute (divergence is one `fft` call and an `add`).

## Deviation from Spec

The spec prescribes `rms displacement ≈ 5.2 Mpc/h per axis` with checkpoint tolerance implicitly ±~0.5. This change replaces that with a different quantity (`∇·Ψ`), a different tolerance (`< 0.05` in absolute rms units), and a different interpretation (self-consistency vs. comparison to a reference).

**Justification:** The specified checkpoint cannot distinguish correct code from sign-inverted code — a failure so severe it overrides spec fidelity. This is the only H2 checkpoint changed from the spec; others stand unchanged.

## Alternatives Considered

- **Keep `rms Ψ`, widen tolerance:** Doesn't fix the sign-error blindness. Accept that the checkpoint is weak.
- **Dual checkpoints, `∇·Ψ` plus `rms Ψ`:** Both are useful, but one is pass-fail and one is observation. Framing both as checkpoints muddies which one matters.
- **Compare to the continuum value (5.83 or 5.04):** Depends on which integral you choose, and doesn't test the code's correctness — only that it ran. ∇·Ψ tests the formula itself.
