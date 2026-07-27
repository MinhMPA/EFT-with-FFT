# 1-loop PT and EFTofLSS calculations with FFTLog

This repository contains a pedagogical note on 1-loop perturbation theory (PT) and Effective Field Theory of Large-Scale Structure (EFTofLSS) calculations using `FFTLog`, together with a set of lecture notes built on it.

## Lecture notes

`PT_lectures.tex` is a self-contained course, *Cosmological Perturbation Theory from Matter to Galaxies*, in three 90-minute sessions (65 min at the board, 25 for questions). It starts from linear relativistic perturbation theory and ends at the 1-loop EFT galaxy power spectrum in redshift space and how it is compared with survey data:

1. **Linear evolution, the matter power spectrum, and the Zel'dovich picture.** From the SVT decomposition to the linearized Newtonian equations, the pressureless fluid and linear growth, Gaussian random fields and what a power spectrum is, the transfer function, then the Lagrangian picture: displacement, the Zel'dovich approximation, shell crossing, and 2LPT.
2. **From displacements to loops, and where they fail.** Wick's theorem, the Eulerian kernels, the same `F_2` recovered from the displacement map, the one-loop matter power spectrum and its diagrams, why bare single-stream loops are UV-incomplete, and the EFT of large-scale structure.
3. **Galaxies in redshift space at one loop.** Galaxy bias, redshift-space distortions and the `Z_n` kernels, IR resummation, multipoles and Alcock–Paczynski, and an end-to-end recipe from Boltzmann code to posterior.

The notes are written as a **pre-read**, not a lecture transcript: each lecture opens with a timed plan naming what goes on the board and what is left to read. A hands-on session follows Lecture 1 and uses its linear spectrum and displacement maps directly, which is why the Lagrangian material sits there rather than in Lecture 2.

Companion files:

- `PT_lectures_solutions.tex` — worked solutions to all eleven exercises, plus a list of recurring errors worth recognising.
- `figs_src/` — the code generating the computed figures. `ptlib.py` implements the linear spectrum (Eisenstein & Hu), the reduced one-loop integrals, and halofit; `validate.py` checks the loop integrals against kernels built independently from the recursion relations (agreement to 1 part in 10⁶); `make_figs.py`, `make_fig_running.py` and `make_fig_multipoles.py` produce the figures. All are self-contained except the last, which drives an external `ps_1loop_jax`.
- `PT_lecture_expert_review.pdf` — an external technical review of an earlier draft, and `PT_lectures_OPEN_ITEMS.md`, which records how each of its findings was resolved and what remains open.

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
