#!/usr/bin/env python3
"""Dry-run timing estimate for the lecture notes.

Word counts alone underestimate board time badly, for two reasons. Notes are
compressed -- a lecturer says two or three words for every one on the page --
and the things that cost the most time (writing an equation, discussing a
figure, waiting out a question) contain almost no words at all.

So this counts components and prices them separately. Parameters are at the top
and are meant to be argued with; the point is that they are visible rather than
buried in a single words-per-minute constant.

    python3 lecture_timing.py PT_lectures.tex
"""
import re, sys

# ---- pace parameters -------------------------------------------------------
# Slow, deliberate delivery: speaking ~120 wpm, but expanding terse notes by a
# factor of ~2.7 as you go, so you get through ~45 words of *notes* per minute.
WORDS_PER_MIN   = 45.0
SEC_PER_EQN     = 60.0    # write a displayed equation on the board and talk through it
SEC_PER_BOXED   = 30.0    # a boxed equation gets extra attention; added on top
SEC_PER_FIGURE  = 150.0   # put it up, orient the room, draw out the point
SEC_PER_TABLE   = 90.0
SEC_PER_QUIZ    = 150.0   # pose, wait, take an answer, resolve. Often the nudge too.
SEC_PER_DERIV   = 30.0    # pose a break derivation; the doing happens off the clock
OVERHEAD        = 0.10    # transitions, admin, losing your place
BUDGET_MIN      = 65.0

ENV_EQN = re.compile(r'\\begin\{(equation|align|eqnarray)\*?\}')

def strip_for_words(t):
    for e in ('figure', 'table', 'exercise', 'quiz', 'center', 'remark', 'reading', 'plan', 'derivation'):
        t = re.sub(r'\\begin\{' + e + r'\}.*?\\end\{' + e + r'\}', '', t, flags=re.S)
    t = re.sub(ENV_EQN.pattern + r'.*?\\end\{\w+\*?\}', '', t, flags=re.S)
    t = re.sub(r'\$[^$]*\$', ' X ', t)
    t = re.sub(r'\\[a-zA-Z]+\*?(\[[^\]]*\])?(\{[^}]*\})?', ' ', t)
    return t

def estimate(block):
    w      = len(strip_for_words(block).split())
    eqn    = len(ENV_EQN.findall(block))
    boxed  = block.count(r'\boxed')
    fig    = block.count(r'\begin{figure}')
    tab    = block.count(r'\begin{tabular}')
    quiz   = block.count(r'\begin{quiz}')
    deriv  = block.count(r'\begin{derivation}')
    # Comments and 'Read, not lectured' passages are in the notes but not delivered,
    # so their words and equations are excluded above and here.
    for env in ('remark', 'reading'):
        for m in re.finditer(r'\\begin\{'+env+r'\}.*?\\end\{'+env+r'\}', block, re.S):
            eqn -= len(ENV_EQN.findall(m.group(0)))
    secs = (w / WORDS_PER_MIN * 60 + eqn * SEC_PER_EQN + boxed * SEC_PER_BOXED
            + fig * SEC_PER_FIGURE + max(tab, 0) * SEC_PER_TABLE + quiz * SEC_PER_QUIZ
            + deriv * SEC_PER_DERIV)
    return dict(words=w, eqn=eqn, fig=fig, tab=max(tab, 0), quiz=quiz,
                min=secs * (1 + OVERHEAD) / 60)

def main(path):
    lines = open(path).read().split('\n')
    idx = lambda p: next(i for i, l in enumerate(lines) if l.startswith(p))
    L1, L2, app = (idx(r'\section*{Lecture 1'), idx(r'\section*{Lecture 2'),
                   idx(r'\appendix'))
    subs = [(i, l) for i, l in enumerate(lines[L1:app], L1)
            if l.startswith(r'\subsection{')] + [(app, '')]
    subs = sorted(subs + [(L2, None)], key=lambda t: t[0])
    plan = next(i for i in range(L1, L2) if lines[i].startswith(r'\end{plan}'))

    print(f"  pace: {WORDS_PER_MIN:.0f} words/min of notes, {SEC_PER_EQN:.0f}s per equation, "
          f"{SEC_PER_FIGURE:.0f}s per figure, {SEC_PER_QUIZ:.0f}s per question, "
          f"+{OVERHEAD:.0%} overhead\n")
    print(f"  {'min':>5} {'wds':>5} {'eq':>3} {'fig':>4} {'?':>3}   section")
    tot = {1: 0.0, 2: 0.0}
    pre = estimate('\n'.join(lines[plan + 1:subs[0][0]]))
    print(f"  {pre['min']:5.1f} {pre['words']:5d} {pre['eqn']:3d} {pre['fig']:4d} "
          f"{pre['quiz']:3d}   L1  prelude")
    tot[1] += pre['min']
    cur = 1
    for (i, l), (j, _) in zip(subs, subs[1:]):
        if l is None:            # the Lecture 2 header: a boundary, not a section
            cur = 2
            continue
        e = estimate('\n'.join(lines[i:j]))
        name = re.sub(r'\\subsection\{|\}', '', l)
        name = re.sub(r'\\texorpdfstring.*', '...', name)[:44]
        print(f"  {e['min']:5.1f} {e['words']:5d} {e['eqn']:3d} {e['fig']:4d} "
              f"{e['quiz']:3d}   L{cur}  {name}")
        tot[cur] += e['min']
    print()
    for n in (1, 2):
        over = tot[n] - BUDGET_MIN
        flag = f"OVER by {over:.0f}" if over > 0 else f"{-over:.0f} spare"
        print(f"  Lecture {n}: {tot[n]:5.1f} min of {BUDGET_MIN:.0f}    ({flag})")

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else 'PT_lectures.tex')
