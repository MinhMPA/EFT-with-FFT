#!/usr/bin/env python3
"""Fail if the lectured thread depends on material filed as read-only.

The notes mark passages as `reading` (Read, not lectured) and `remark`
(Comment). Equations defined inside those blocks are never written on the
board, so text OUTSIDE them must not \\eqref them -- otherwise the spoken
thread references equations the audience has never seen. Exercises and plan
blocks are themselves off-board, so they may reference anything.

    python3 check_lectured_refs.py PT_lectures.tex
"""
import re, sys

def spans(s, envs):
    pat = r'\\begin\{(' + '|'.join(envs) + r')\}.*?\\end\{\1\}'
    return [(m.start(), m.end()) for m in re.finditer(pat, s, re.S)]

def main(path):
    s = open(path).read()
    hidden = spans(s, ['reading', 'remark'])
    allowed = hidden + spans(s, ['exercise', 'plan'])
    inside = lambda i, sp: any(a <= i < b for a, b in sp)
    labels = {m.group(1) for m in re.finditer(r'\\label\{([^}]+)\}', s)
              if inside(m.start(), hidden)}
    bad = []
    for m in re.finditer(r'\\(?:eq)?ref\{([^}]+)\}', s):
        if m.group(1) in labels and not inside(m.start(), allowed):
            bad.append((s[:m.start()].count('\n') + 1, m.group(1)))
    # a quiz is asked at the board, so it must not sit inside a reading block
    for m in re.finditer(r'\\begin\{quiz\}', s):
        if inside(m.start(), hidden):
            bad.append((s[:m.start()].count('\n') + 1, 'quiz inside reading/remark'))
    for line, what in bad:
        print(f"  line {line}: lectured thread depends on read-only '{what}'")
    if bad:
        sys.exit(1)
    print("  lectured thread is self-contained")

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else 'PT_lectures.tex')
