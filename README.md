# 1-loop PT and EFTofLSS calculations with FFTLog

This repository contains a pedagogical note on 1-loop perturbation theory (PT) and Effective Field Theory of Large-Scale Structure (EFTofLSS) calculations using `FFTLog`, together with a set of lecture notes built on it.

## Lecture notes

Two courses, sharing the figure pipeline in `figs_src/`.

### From Quantum Seeds to the Cosmic Web

`PT_lectures.tex` — two 90-minute lectures (65 min at the board, 25 for
questions) alternating with two hands-on sessions:

```
L1  primordial fluctuations -> linear matter power spectrum P_L(k)
H1  code the transfer function, build P_L, draw a Gaussian realization
L2  Zel'dovich and LPT -> the cosmic web; linear bias as a bridge
H2  displace the H1 field in 3D; sheets, filaments, knots
```

Each practical consumes the lecture before it, and the two chain: H1 produces
the field H2 moves. The design and its trade-offs are recorded in
[`docs/adr/0001`](docs/adr/0001-narrow-school-to-linear-theory-and-zeldovich.md).

The [Cosmic Web Sandbox](https://minhmpa.github.io/lss-lab/cosmic-web-sandbox/)
runs the same pipeline in the browser — Eisenstein & Hu transfer function, LPT,
T-web eigenvalue classification — and serves as the live demonstration in both
lectures and as the target for H2.

### Cosmological Perturbation Theory from Matter to Galaxies

`EFT_lectures.tex` — the longer course, for a different school: Eulerian and
Lagrangian perturbation theory, the one-loop matter power spectrum, the EFT of
large-scale structure, galaxy bias, redshift-space distortions, IR resummation,
and the end-to-end comparison with survey data. Incorporates an external
technical review (`PT_lecture_expert_review.pdf`); `PT_lectures_OPEN_ITEMS.md`
records how each finding was resolved.

Both have companion solutions files. `figs_src/` generates the computed figures:
`ptlib.py` implements the linear spectrum (Eisenstein & Hu), the reduced
one-loop integrals and halofit; `validate.py` checks the loop integrals against
kernels built independently from the recursion relations, agreeing to 1 part in
10^6.

## FFTLog note

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
