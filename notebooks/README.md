# Hands-on sessions

## Session 1 — From a cosmology to a density field

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/MinhMPA/EFT-with-FFT/blob/master/notebooks/H1_gaussian_field.ipynb)

Nothing to install. Click the badge, sign in with any Google account, and run
the first cell. If you would rather work locally you need only numpy and
matplotlib; the notebook has no other dependencies and no Colab-only code
outside one clearly marked download cell.

At the end of the session, run the last cell. It downloads
`delta_k_128.npz` — the density field you built — which Session 2 begins from.
Keep it. If you lose it, Session 2 opens with a cell that regenerates the
identical field from the same seed, so nothing is lost either way.

**The seed is fixed at 1234 on purpose.** Every student's field is the same
field, and the one in the lecture notes. When you change a cosmological
parameter, every difference you see is physics, not luck.

## Editing these notebooks

`make_notebooks.py` is the source of truth. Both `.ipynb` files are generated:

```bash
python3 notebooks/make_notebooks.py   # regenerate both notebooks
python3 notebooks/verify_notebooks.py # execute both, cross-check against ptlib
```

Never hand-edit the `.ipynb` files — your changes will be overwritten.
