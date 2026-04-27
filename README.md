# 1-loop PT and EFTofLSS calculations with FFTLog

This repository contains a pedagogical note on 1-loop perturbation theory (PT) and Effective Field Theory of Large-Scale Structure (EFTofLSS) calculations using `FFTLog`.

The note re-derives the formalism and loop integrals needed for 1-loop power spectrum and bispectrum calculations in PT and EFTofLSS, following the `FFTLog` decomposition and factorization approach introduced in Simonović et al. and Chudaykin et al. The emphasis is on making the derivation explicit and readable, including intermediate steps that are often skipped in the literature.

These loop integrals are key ingredients for modeling matter clustering, biased tracers such as galaxies, Lyman-alpha forest observables, and real- or redshift-space statistics.

A central organizing theme is the hierarchy

```text
scalar master integrals
        ↓
tensor master integrals
        ↓
line-of-sight (LOS) master integrals
        ↓
coefficient functions for specific observables
```

This structure provides a unified way to treat matter, galaxy, and Lyman-alpha calculations in both real and redshift space.

## Scope

The note focuses on the derivation and organization of loop integrals rather than on presenting a production-ready numerical pipeline. It is intended as a transparent reference for readers who want to understand how `FFTLog`-based loop calculations are built from the ground up.

## Contents

- 1-loop PT and EFTofLSS setup
- `FFTLog` decomposition of linear power spectra
- factorization of loop integrals
- scalar master integrals
- tensor master integrals
- line-of-sight master integrals
- applications to matter, galaxy, and Lyman-alpha observables
- real-space and redshift-space loop calculations

## References

This note follows and builds on the `FFTLog` approach developed in:

```bibtex
@article{Simonovic:2017mhp,
  author = {Simonovi{\'c}, Marko and Baldauf, Tobias and Zaldarriaga, Matias and Carrasco, John Joseph M. and Kollmeier, Juna A.},
  title = {Cosmological perturbation theory using the FFTLog: formalism and connection to QFT loop integrals},
  journal = {JCAP},
  volume = {04},
  pages = {030},
  year = {2018},
  eprint = {1708.08130},
  archivePrefix = {arXiv},
  primaryClass = {astro-ph.CO}
}

@article{Chudaykin:2020aoj,
  author = {Chudaykin, Anton and Ivanov, Mikhail M. and Philcox, Oliver H. E. and Simonovi{\'c}, Marko},
  title = {Nonlinear perturbation theory extension of the Boltzmann code CLASS},
  journal = {Phys. Rev. D},
  volume = {102},
  number = {6},
  pages = {063533},
  year = {2020},
  eprint = {2004.10607},
  archivePrefix = {arXiv},
  primaryClass = {astro-ph.CO}
}
```

## Citation

If you use this note or repository, please cite the original `FFTLog`-based loop-calculation papers listed above. A dedicated citation entry for this repository can be added once a public release, Zenodo DOI, or paper version is available.
