"""Cell-emitting primitives shared by the hands-on notebook generators.

A generator builds a list of (kind, solution, student) triples and calls emit().
For a single-notebook generator the two sides are identical except where SC()
inserts a solution cell.
"""
import json


def _source(text):
    lines = text.strip("\n").split("\n")
    return [ln + "\n" for ln in lines[:-1]] + [lines[-1]]


def _cell(kind, text, idx):
    base = {"id": f"c{idx:03d}", "metadata": {}, "source": _source(text)}
    if kind == "markdown":
        return {"cell_type": "markdown", **base}
    return {"cell_type": "code", "execution_count": None, "outputs": [], **base}


def _solution_cell(text, idx):
    """A collapsed code cell. Colab honours #@title; Jupyter honours the metadata."""
    c = _cell("code", text, idx)
    c["metadata"] = {"cellView": "form", "jupyter": {"source_hidden": True},
                     "tags": ["solution"]}
    return c


def build(cells, which):
    """cells: list of (kind, solution, student). which in {'student','solutions'}."""
    assert which in ("student", "solutions"), which
    out = []
    for i, (kind, sol, stu) in enumerate(cells):
        text = sol if which == "solutions" else stu
        out.append(_solution_cell(text, i) if kind == "solution"
                   else _cell(kind, text, i))
    return {"cells": out,
            "metadata": {"kernelspec": {"display_name": "Python 3",
                                        "language": "python", "name": "python3"},
                         "language_info": {"name": "python", "version": "3.10"}},
            "nbformat": 4, "nbformat_minor": 5}


def emit(cells, path, which="solutions"):
    with open(path, "w") as fh:
        json.dump(build(cells, which), fh, indent=1)
        fh.write("\n")
    print(f"wrote {path.split('/')[-1]}  ({len(cells)} cells)")
