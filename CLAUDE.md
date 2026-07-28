# EFT-with-FFT — project guidelines for Claude

Lecture notes for a graduate school: `PT_lectures.tex` (2×90-min lectures +
2 hands-on sessions), `EFT_lectures.tex` (the full EFTofLSS course, forked).

## Mistakes made here — do not repeat

- **Lectured-thread integrity.** `reading`/`remark` blocks are skipped at the
  board. Text outside them must never `\eqref` an equation defined inside one,
  and a `quiz` must never sit inside one. After any restructuring or cut, run
  `python3 check_lectured_refs.py PT_lectures.tex` — it exits nonzero on
  violations. (2026-07-28: cuts left the board "linearizing Eqs. (1.6)–(1.7)"
  that the audience had never seen, and one Ask-the-room question was itself
  filed as Read-not-lectured.)

- **Plain answers, no fragments.** Student-facing text (quiz answers, nudges)
  must open with a complete declarative sentence that states the conclusion.
  No elliptical fragment openers ("On k >> H, ..."), no allusive compression
  that requires re-deriving the point to parse. Test: read the paragraph
  aloud, cold, to an undergraduate — if it needs your tone of voice to work,
  rewrite it. (2026-07-28: the user could not tell whether an answer I wrote
  was even coherent. Correct-but-unreadable is a repeated failure mode in this
  project; this is its prose form.)

- **Derive, don't assert, the load-bearing equations.** The system the whole
  course runs on (the linear fluid equations) was originally dropped in as
  "what survives" of a reduction the students never saw. Anything the lectures
  use repeatedly deserves a lead-up at the board: one physical statement per
  member, each a single line. The full GR bookkeeping can live in exercises.

- **Grep the LaTeX log for errors, not just warnings.** `-interaction=nonstopmode`
  still emits a PDF after a fatal error, so "0 warnings" proves nothing. A
  dropped `\end{quiz}` survived four commits and silently rendered 190 lines --
  two sections, two figures and a Comment -- in small blue italic. Always
  `grep -c '^!' <log>` and run `check_lectured_refs.py`, which now also checks
  environment balance. (2026-07-28.)

- **When replacing a whole environment, keep its delimiters in both strings.**
  The bug above came from an exact-match replacement whose `old` ended with
  `\end{quiz}` and whose `new` did not.

- **After every edit round, re-run the checks.** `pdflatex` ×3 (0 errors, 0 warnings),
  `python3 lecture_timing.py`, `python3 check_lectured_refs.py`, and
  `pdftotext` spot-checks of any passage whose surroundings changed. Every
  unverified edit round in this project has introduced ~1 error.

- **Checkpoint numbers belong to a named quantity.** `HANDS_ON_SPEC.md` carried
  a log-slope of −1.7 attached to `P_L(k)`; the number was right but it is
  `T(k)`'s slope (`P_L` gives −2.38), lifted from the `remark` at
  `PT_lectures.tex:762` and reattached to its neighbour. Same failure mode as
  the lectured-thread bug: a fact migrating away from the equation it belongs
  to. Any number written as a checkpoint must name what it measures and be
  produced by running the reference implementation, never by estimation.
  (2026-07-28.)

- **Generated artifacts get a generator, not a second copy.** The hands-on
  notebooks are emitted by `handson/make_notebooks.py`; `handson/verify_notebooks.py`
  checks the notebook's duplicated Eisenstein & Hu code against
  `figs_src/ptlib.py` to machine precision. Two hand-maintained copies of a
  fitting formula in a repo with a documented ~1-error-per-edit-round rate will
  drift. Run `python3 handson/verify_notebooks.py` after touching either.
