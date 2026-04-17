# EFTwithFFT

`EFTwithFFT.wl` is a Mathematica package for building and validating one-loop EFT power-spectrum ingredients in real space and redshift space, with a notebook driver in `EFTwithFFT.nb`.

This README summarizes the implementation structure and the main heavy-lifting functions, not the theory derivation.

## Files

- [EFTwithFFT.wl](/Users/nguyenmn/Library/Mobile%20Documents/com~apple~CloudDocs/Mathematica/EFTwithFFT.wl): package code
- [EFTwithFFT.nb](/Users/nguyenmn/Library/Mobile%20Documents/com~apple~CloudDocs/Mathematica/EFTwithFFT.nb): notebook driver and plots
- [Plin.dat](/Users/nguyenmn/Library/Mobile%20Documents/com~apple~CloudDocs/Mathematica/Plin.dat): linear input spectrum used by the notebook

## High-Level Pipeline

The package is organized as a staged pipeline:

1. Build symbolic kernels and validate them against `ps_1loop_jax` references.
2. Load the linear spectrum and split it into no-wiggle and wiggle pieces.
3. FFTLog-decompose the linear spectrum on the internal power-law basis.
4. Cache raw `M13`/`M22` contractions on the internal FFTLog grid.
5. Assemble real-space or redshift-space spectra from those raw cached pieces.
6. Apply IR resummation and EFT counterterms.
7. Project `P(k,\mu)` to multipoles.

The design goal is to separate:

- symbolic kernel derivation
- FFTLog reduction and contraction
- spectrum assembly
- plotting and notebook presentation

## Major Implementation Blocks

### 1. Kernel Corpus and Validation

These functions define and validate the analytic kernels.

- `BuildK13Sector[sector]`
- `BuildK22Sector[sector]`
- `BuildKernelCorpus[kind]`
- `ClassifyKernelMismatches[kind]`
- `CanonicalizeKernelForReference[file, expr]`
- `GetIndependentKernel[name]`

What they do:

- `BuildK13Sector` and `BuildK22Sector` construct symbolic redshift-space kernels sector by sector from the filename metadata.
- `GetIndependentKernel` loads the real-space independent kernels directly from the `ps_1loop_jax` reference text files.
- `BuildKernelCorpus` builds the requested corpus:
  - `"RealSpace"`
  - `"M13"`
  - `"M22"`
- For redshift-space kernels, `BuildKernelCorpus` canonicalizes to the exact reference expression by default.
- `ClassifyKernelMismatches` compares the raw, non-canonicalized corpus against the reference files and classifies each kernel as:
  - exact text match
  - canonicalization-only mismatch
  - formula mismatch

Important internal operations:

- parsing kernel text into Mathematica expressions with symbol normalization
- exact serialization through `KernelString`
- symbolic equivalence tests using `Cancel @ Together` and `FullSimplify`
- numeric spot checks through `ValidateAgainstReference`

### 2. Linear Spectrum Loading and Wiggle/No-Wiggle Split

Relevant functions:

- `LoadLinearSpectrum[path]`
- `BuildNoWiggleSpectrum[linAssoc, opts]`
- `SplitNoWiggleSpectrum[linAssoc, width]`
- `MakeIRResummedSpectrum[splitAssoc, sigma]`
- `GetSigma2[split, kS, rBAO]`
- `GetDeltaSigma2[split, kS, rBAO]`
- `BuildIRDampingFactor[pars, sigma2, dsigma2]`

What they do:

- `LoadLinearSpectrum` imports a 2-column `k, P(k)` table, log-extrapolates it, and builds a smooth interpolant.
- `BuildNoWiggleSpectrum` constructs:
  - `Pnw`
  - `Pw = P - Pnw`
- The default split path is aligned to `ps_1loop_jax`; there is also a fallback smoothing path.
- `GetSigma2` and `GetDeltaSigma2` compute the isotropic and anisotropic BAO damping integrals from `Pnw`.
- `BuildIRDampingFactor` packages the anisotropic Gaussian damping model used later in `P(k,\mu)`.

Heavy-lifting operations here:

- log-space extrapolation of `P(k)`
- external-compatible no-wiggle split
- numerical BAO damping integrals

### 3. FFTLog Decomposition

Relevant functions:

- `FFTLogDecompose[plin, {kmin, kmax}, n, bias]`
- `ClearFFTLogCache[]`
- `Ps1LoopNuBiases[]`

What they do:

- `FFTLogDecompose` builds the internal FFTLog basis:
  - internal `kSample`
  - complex power-law exponents
  - FFTLog coefficients
  - cached sample values
- `Ps1LoopNuBiases[]` returns the bias choices used to match `ps_1loop_jax`:
  - real-space matter
  - real-space bias terms
  - redshift-space Gaussian terms
- `ClearFFTLogCache[]` clears the cached sampled kernels, matrix contractions, and linear-spectrum integrals.

This is one of the core numerical backends of the package.

### 4. Cached Kernel Sampling and Raw Contractions

Relevant functions:

- `BuildCachedM13SectorMatrices[fftAssoc]`
- `BuildCachedM22SectorMatrices[fftAssoc]`
- `EvaluateM13Contribution[expr, fftAssoc, k, plin]`
- `EvaluateM22Contribution[expr, fftAssoc, k]`
- `EvaluateM22ContributionComponents[expr, fftAssoc, k]`
- `BuildPkmu13UV[kgrid, linAssoc, pars, mu]`
- `GetLinearSpectrumIntegral[linAssoc, ...]`

What they do:

- `BuildCachedM13SectorMatrices` samples every `M13` kernel on the FFTLog exponent grid.
- `BuildCachedM22SectorMatrices` samples every `M22` kernel on the 2D exponent grid, including the loop prefactor.
- `EvaluateM13Contribution` and `EvaluateM22Contribution` contract one symbolic kernel against the FFTLog basis at a single `k`.
- `EvaluateM22ContributionComponents` separates:
  - loop term
  - `k -> 0` subtraction
  - total
- `BuildPkmu13UV` and `GetLinearSpectrumIntegral` build the UV subtraction used for the `13_dd` channel.

Heavy-lifting operations here:

- evaluation of symbolic kernels on complex FFTLog exponent grids
- 1D and 2D matrix contractions
- UV subtraction for `13_dd`
- `k -> 0` limit subtraction for `22`-type pieces

### 5. Raw Sector Cache Construction

Relevant functions:

- `BuildRawOneLoopSectorCache[fftAssoc, plin]`
- `BuildRawRealSpaceSectorCache[fftMatterAssoc, fftBiasAssoc, linAssoc]`
- `SubtractRawOneLoopSectorCaches[full, nw]`

What they do:

- `BuildRawOneLoopSectorCache` constructs and stores the mu-independent redshift-space raw sector spectra on the internal FFTLog grid.
- `BuildRawRealSpaceSectorCache` does the same for the real-space basis terms, combining:
  - matter FFT object
  - bias FFT object
- `SubtractRawOneLoopSectorCaches` builds wiggle-only raw caches as `full - no-wiggle`, sector by sector.

Each raw cache contains the internal-grid arrays for:

- `PlinInternal`
- `P13UVBaseInternal`
- `M13BySectorRawInternal`
- `M22BySectorRawInternal`
- total raw `P13`, `P22`, and `P1Loop`

This cache layer is central to performance because it avoids repeating kernel sampling and contraction inside later assembly loops.

### 6. Real-Space Assembly

Relevant functions:

- `AssembleRealSpaceFromRawCache[kgrid, rawCache, model, pars]`

Supported models:

- `"Basis"`
- `"Matter"`
- `"GG"`
- `"GM"`

What it does:

- interpolates the internal-grid cached basis terms onto the requested output grid
- builds physically assembled spectra from the basis terms

Important details:

- `"Basis"` returns interpolated basis terms like:
  - `P_lin`
  - `13_dd`
  - `22_dd`
  - `I_d2`
  - `I_G2`
  - `I_d2_d2`
  - `I_d2_G2`
  - `I_G2_G2`
  - `I_d2_v`
  - `F_G2`
- `"Matter"` builds:
  - tree
  - 1-loop
  - counterterm
  - total
- `"GG"` builds the real-space galaxy auto-spectrum from the basis terms and nuisance parameters.
- `"GM"` builds the real-space galaxy-matter cross-spectrum.

Implementation note:

- the direct output-grid linear spectrum is preserved when available, instead of unnecessarily reconstructing it from the FFTLog internal grid
- the current `GG` counterterm follows the CLASS-PT wrapper normalization used in the notebook workflow

### 7. Redshift-Space `P(k,\mu)` Assembly

Relevant functions:

- `AssembleOneLoopFromRawSectorCache[kgrid, rawCache, pars, mu]`
- `BuildPkmu1LoopRaw[kgrid, fftAssoc, pars, mu, plin]`
- `BuildPkmuTree[kgrid, linAssoc, pars, mu]`
- `BuildPkmuTreeIRResummed[kgrid, linAssoc, splitAssoc, pars, mu, dampAssoc]`
- `BuildPkmuCounterterms[kgrid, mu, plinValues, pars]`
- `BuildPkmuStochastic[kgrid, mu, pars]`
- `AssemblePkmuRaw[treeAssoc, oneLoopAssoc, ctrs, stoch]`
- `AssemblePkmuIRResummed[treeIRAssoc, oneLoopNW, oneLoopW, dampAssoc, ctrs, stoch]`

What they do:

- `AssembleOneLoopFromRawSectorCache` applies the sector coefficient map at fixed `\mu` and sums the weighted raw sectors into `P13`, `P22`, and `P1Loop`.
- `BuildPkmuTree` builds the raw tree-level redshift-space spectrum.
- `BuildPkmuTreeIRResummed` builds the IR-resummed tree spectrum with `Pnw`, `Pw`, and the anisotropic damping factor.
- `BuildPkmuCounterterms` builds the Gaussian EFT counterterms:
  - `k^2` term from `c0`, `c2`, `c4`
  - optional `k^4` FoG-like term from `cfog`
- `BuildPkmuStochastic` adds shot-noise and optional higher-order stochastic pieces.
- `AssemblePkmuRaw` and `AssemblePkmuIRResummed` combine tree, loop, counterterm, and stochastic pieces into final `P(k,\mu)`.

This is the main redshift-space heavy-lifting block.

### 8. Multipole Projection

Relevant functions:

- `ProjectPkmuToMultipoles[kgrid, pkmuFnOrGrid, muSamples]`
- `BuildMultipoleTablesFromPkmu[kgrid, pkmuFnOrGrid, muSamples]`
- `BuildMultipoleTables[kgrid, fftAssoc, pars, plin, muSamples]`

What they do:

- `ProjectPkmuToMultipoles` is the main multipole projector.
- It supports either:
  - a precomputed `P(k,\mu)` grid
  - a callable builder `mu -> Association`
- It uses Gaussian-Legendre quadrature on `\mu in [0,1]`.
- It returns the `\ell = 0, 2, 4` multipoles.

Internal heavy-lifting operations:

- Gauss-Legendre rule construction
- repeated `P(k,\mu)` evaluation over the mu grid
- weighted Legendre projection

### 9. Validation and Debug Utilities

Relevant functions:

- `ValidateKernelText`
- `ValidateAgainstReference`
- `ExportAllM13Kernels`
- `ExportAllM22Kernels`
- `ValidateExportedKernels`
- `GetPs1LoopSectorReference`
- `GetPs1LoopContractionReference`
- `CompareFFTLogContractionsWithPs1Loop`
- `GetM13ContractionIngredients`
- `GetM22ContractionIngredients`
- `GetPs1LoopM13ContractionIngredients`
- `GetPs1LoopM22ContractionIngredients`
- `CompareSingleM13ContractionWithPs1Loop`
- `CompareSingleM22ContractionWithPs1Loop`
- `CompareM13M22WithPs1Loop`

What they do:

- validate exact-text and symbolic kernel agreement
- export kernels in the exact serialized format expected by downstream references
- compare full FFTLog contractions against `ps_1loop_jax`
- inspect one sector at a time when debugging matrix orientation, coefficient vectors, or UV subtraction

These are the core debugging tools when the final spectra disagree but the symbolic kernels appear correct.

## Caching and Parallelism

The package uses several caches to avoid recomputation:

- parsed reference kernels
- FFTLog kernel samples
- FFTLog sector contractions
- linear-spectrum integrals

Parallel control flags:

- `$UseParallelForKernels`
- `$UseParallelForMuIntegration`
- `$UseParallelForMultipole`

Helper:

- `SetupParallelKernels[n]`

The notebook currently defaults these flags to `False` for deterministic debugging.

## Practical Notebook Flow

The notebook `EFTwithFFT.nb` currently uses the package in this order:

1. kernel validation
2. linear spectrum load and split
3. FFTLog decomposition
4. raw cache construction
5. real-space assembly
6. anisotropic `P(k,\mu)` assembly
7. multipole projection
8. plotting

The plotting layer is intentionally downstream of all heavy numerical work, so plots can be rerun without rebuilding the expensive FFTLog and raw-cache objects.

## Current Scope

The package is strongest in:

- symbolic kernel bookkeeping
- FFTLog-based contraction and caching
- real-space basis assembly
- redshift-space Gaussian one-loop assembly
- notebook-side diagnostics against `ps_1loop_jax`

It should be read as a Mathematica implementation of the same computational pipeline, not just a plotting notebook around precomputed arrays.
