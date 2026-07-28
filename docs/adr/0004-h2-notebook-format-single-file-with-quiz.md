# ADR 0004: Hands-on 2 — Single Notebook with Quiz Comments over Two-File Student/Solutions

**Status:** Decided

## Context

Hands-on 1 ships two generated notebooks (student + solutions) from a single `make_notebooks.py` source, using S() and SM() cells to differ the two. This design prevents drift but requires two files and two links. Hands-on 2's scope and pedagogy are different enough that a single format was reconsidered.

The trade-off:
- **Two files (H1 model):** Prevents hand-maintenance drift; `verify_notebooks.py` can assert student file *halts* at stubs; solutions remain offline until class ends.
- **One file with collapsed answers:** Simpler to ship; inline `# quiz:` comments let the teaching ride on working code; students choose to read answers or attempt stubs.

## Decision

**Single notebook with:**
- All code runs and produces output end-to-end (students will not be blocked by stubs).
- 3 genuine stubs that are pedagogically worth withholding (Ψ⁽¹⁾ formula, eigenvalue count logic, full δ₂ 2LPT tensor).
- Solution cells **overwrite** (not replace) the stubs: students see `...` on first read, run the cell with the TODO, see the failure, then optionally run the solution cell below to proceed.
- `# quiz:` comments at every decision point, phrased as interrogation not explanation. Example: *`"24% of ∫dk P lives below k_f; which of these two numbers confirms the finite-box effect?"`*
- No collapsed metadata or cell hiding; plain markdown and code cells that any Jupyter renders.

## Consequences

- **Simplicity:** One link, one notebook, no build complexity beyond `make_notebooks.py:M()/C()/S()`.
- **Accessibility:** Works offline (no solutions file to fetch); no two-file sync to break.
- **Stubs are real but not blocking:** A student who attempts the exercise sees a clear failure ("...the solution cell overwrites it"); optional, not mandatory.
- **Format matches your existing notebooks** (CCCC2025, cosmopower-jax): working code with inline questions, not a teaching scaffolding framework.
- **Loss of the "halts at TODO" check:** H2 cannot verify stubs by running the student file — it runs to completion either way. Verification instead deletes solution cells, confirms checkpoints fail, and rebuilds.

## Alternatives Considered

- **Stick with H1's two-file model:** More faithful to what H1 does; but H1 withholds a *number* (the payoff), whereas H2's payoff is an *image* (the web). Blocking visibility of the cosmic web fails the very students who need it most.
- **Jupyter hiding via HTML metadata:** Non-standard; breaks in nbconvert, Colab's rendering, and many editors. Avoids a third cell, but introduces rendering fragility.
- **Markdown stubs, not code stubs:** `"TODO: write the Ψ formula"` in a markdown cell before the compute cell. Cleaner notebooks, but students cannot see their error immediately (code cell executes with undefined `psi_1d` and fails silently in the next cell).

## Rationale

H2 is a walkthrough with calculated quiz points, not an exercise with graded checkpoints. The cosmic web is the thing students are here to see; the stubs are the thing they're here to think about. The format supports both by making the web always reachable and the stubs always interrogatable.
