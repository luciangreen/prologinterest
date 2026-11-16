# prologinterest

Rates software you ran or read on three axes, each drawn as a circular pie chart percentage (ASCII and SVG):

- **Original**: does it complete gaps in reasoning? This is the share of predicates it calls that it also defines. The open gaps are listed.
- **Interesting**: does the reasoning link to the user? This is the share of the user's interests that appear as words in the program.
- **Intuitive**: does the user understand, do and enjoy the task? This is the mean of understood (0/1), did (0/1) and enjoyed (0 to 10) from a test log.

```
?- example(E), report(E).
?- assess(E, S), svg(S, Svg).
```

Proved properties: all scores are percentages, a closed program is 100% original, filling a gap never lowers originality, the bounds of the interest and intuitive scores, pies are monotone, and the 0% and 100% pie extremes.

## Tests and proofs

```
swipl run_tests.pl        # runs the 200 saved I/O pairs and checks every proof
swipl tests/gen_io.pl     # regenerates tests/io_pairs.pl from spec.pl
```

- `tests/io_pairs.pl` has 200 saved `io(Id, Predicate, Input, ExpectedOutput)` facts.
- The expected outputs come from `spec.pl`, an independent specification written in a different style from the implementation. Because the implementation is checked against a separate oracle, a pass is real evidence and not the program checking itself.
- `proofs.pl` has machine-checked `proof(Name, Goal)` theorems. Each one is checked exhaustively on a bounded domain or over sample inputs, and its comment gives the general (usually inductive) argument.

All files are plain, portable SWI-Prolog, with no packs needed.
