# Structure formation school — hands-on sessions

Two 90-minute Colab notebooks following two 65-minute lectures, taking students
from a cosmology to a cosmic web. H1 builds a linear power spectrum and draws a
Gaussian field; H2 displaces that field and classifies what it becomes.

## Language

### The field

**Fiducial field**:
The 128³ density contrast drawn from seed 1234 in a 250 Mpc/h box, the one
realisation every student works with.
_Avoid_: the initial conditions, the density field, delta

**Fiducial cosmology**:
Flat ΛCDM with `Om=0.31, Ob=0.048, h=0.676, ns=0.965, sigma8=0.81, Tcmb=2.7255`.
_Avoid_: the Planck cosmology, our cosmology

**Fundamental mode** (`k_f = 0.0251 h/Mpc`):
The longest wave the box holds, `2π/L`.

**Nyquist frequency** (`k_Nyq = 1.608 h/Mpc`):
The shortest wave the grid represents, `πN/L`.

**Corner modes**:
Grid modes between `k_Nyq` and `√3·k_Nyq = 2.786`, which a cube holds but a
sphere of radius `k_Nyq` does not.

### Displacement

**Zel'dovich displacement** (`Ψ⁽¹⁾`):
The first-order Lagrangian displacement `Ψ⁽¹⁾(k) = (ik/k²)δ(k)`, equivalently
the unique curl-free field satisfying `∇·Ψ⁽¹⁾ = −δ`.
_Avoid_: the displacement, first-order LPT, ZA

**Second-order displacement** (`Ψ⁽²⁾`):
`(3/7)D₂ ∇∇⁻²δ₂` with `δ₂ = Σ_{i<j}[φ_,ii φ_,jj − φ_,ij²]` and `∇²φ = δ`.
_Avoid_: the 2LPT term, the correction

**2LPT**:
The sum `Ψ⁽¹⁾ + Ψ⁽²⁾`, not the second-order piece alone.

**EdS coefficient** (`3/7`):
The Einstein–de Sitter value of the second-order growth ratio, used in place of
the exact `D₂/D₁²`.

### The web

**Deformation tensor** (`D_ij`):
`k_i k_j δ(k)/k²`, always built from the **fiducial field**, never from the
displaced one.

**Web class**:
One of void, sheet, filament, knot, set by how many eigenvalues of the
**deformation tensor** are positive (0, 1, 2, 3).
_Avoid_: environment, morphology, T-web type

**Doroshkevich fractions** (`8/42/42/8`):
The volume fractions of the four **web classes** for a Gaussian field.

### Verification

**Checkpoint**:
A cell that measures a quantity the students just computed and asserts it, so a
wrong implementation announces itself.
_Avoid_: test, validation, sanity check

**Benchmark**:
The closing comparison of the students' `Ψ⁽¹⁾` and `Ψ⁽²⁾` against `jaxpm.lpt`,
run with `gradient_order=0` so only the growth convention differs.

## Relationships

- The **fiducial cosmology** fixes a `P_L(k)`, which with seed 1234 fixes the **fiducial field**.
- The **fiducial field** produces both the **Zel'dovich displacement** and the **deformation tensor**.
- A particle's **web class** is set at its Lagrangian position and carried to wherever **2LPT** puts it — classified first, moved second.
- **Ψ⁽¹⁾** scales as `D₁`; **Ψ⁽²⁾** scales as `D₂ ∝ D₁²`. So both epochs come from one set of FFTs and two scalars.

## Example dialogue

> **Dev:** "For the web classification, do I use the displaced field? That's the
> one that looks like a web."
> **Domain expert:** "No — the **deformation tensor** comes from the **fiducial
> field**. The `8/42/42/8` split is a theorem about *Gaussian* fields, and
> displacing destroys Gaussianity. Build the tensor first, classify each particle
> at its Lagrangian position, then draw it wherever the displacement put it."
> **Dev:** "So the picture is classified-then-moved."
> **Domain expert:** "Right. Classify the evolved field instead and you get
> `13.9/54.5/28.0/3.6` — which is a real number about a real field, just not
> Doroshkevich's."

## Flagged ambiguities

- **"Checkpoint" vs "the number to expect."** `rms Ψ_x ≈ 5.2` was specified as a
  checkpoint but cannot serve as one: it is unchanged by a sign error
  (`−ik/k²` gives 5.202, identical to correct code) and varies ±12% across axes
  for identical correct code. Resolved: the **checkpoint** is `∇·Ψ = −δ`; the
  5.2 is an *observation* used to discuss finite-box effects.

- **"Simulation."** H2 runs no N-body step. LPT displacement only; the word
  simulation is avoided for what is an analytic displacement of a grid.

- **Which `P_L(k)`.** H1 uses Eisenstein & Hu (`rms δ = 2.516`); H2 uses CAMB
  (`rms δ = 2.5305`). Both are correct for their own session and the 0.6%
  difference is not an error.

- **Redshift.** LPT is valid at `z=49`, where displacements are 0.07 cells and
  nothing is visible; the web needs `z=0`, where Zel'dovich is far past shell
  crossing. Resolved: benchmark at `z=49`, picture at `z=0`, and say so.
