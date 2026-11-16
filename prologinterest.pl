% prologinterest - rates software that was run or read on three axes and
% draws each as a circular pie chart percentage:
%   original  - does it complete gaps in reasoning? (share of the predicates
%               it calls that it actually defines, rather than leaving open)
%   interesting - does its reasoning link to the user? (share of the user's
%               interests that appear as words in the program's names)
%   intuitive - does the user understand, do and enjoy the task? (mean of
%               understood 0/1, did 0/1 and enjoyed 0..10 from the test log)
%
% Input: a(Program, Interests, Log)
%   Program   - list of clauses, e.g. [(teach_music(X) :- scale(X)), scale(c)]
%   Interests - list of atoms, e.g. [music, meditation]
%   Log       - list of t(Understood, Did, Enjoyed)
%
% Try: ?- example(E), report(E).

assess(a(Prog, Interests, Log), scores(O, I, T)) :-
    original(Prog, O),
    interesting(Prog, Interests, I),
    intuitive(Log, T).

pct(_, 0, 100) :- !.
pct(N, D, P) :- P is (200 * N + D) // (2 * D).

% ---- original ---------------------------------------------------------------
original(Prog, P) :-
    defined(Prog, Defs), called(Prog, Calls),
    intersection(Calls, Defs, Done),
    length(Done, ND), length(Calls, NC),
    pct(ND, NC, P).

clause_parts((H :- B), H, B) :- !.
clause_parts(H, H, true).

defined(Prog, Defs) :-
    findall(N/A, ( member(C, Prog), clause_parts(C, H, _), functor(H, N, A) ), D0),
    sort(D0, Defs).

called(Prog, Calls) :-
    findall(N/A, ( member(C, Prog), clause_parts(C, _, B), body_goal(B, G),
                   functor(G, N, A), \+ builtin(N/A) ), C0),
    sort(C0, Calls).

% gaps(+Program, -Undefined): called predicates still to be written.
gaps(Prog, Gaps) :- defined(Prog, D), called(Prog, C), subtract(C, D, Gaps).

body_goal(V, _) :- var(V), !, fail.
body_goal((A, B), G) :- !, ( body_goal(A, G) ; body_goal(B, G) ).
body_goal((A ; B), G) :- !, ( body_goal(A, G) ; body_goal(B, G) ).
body_goal((A -> B), G) :- !, ( body_goal(A, G) ; body_goal(B, G) ).
body_goal(\+ A, G) :- !, body_goal(A, G).
body_goal(true, _) :- !, fail.
body_goal(G, G).

builtin(N/A) :- memberchk(N/A, ['='/2, is/2, '<'/2, '>'/2, '=<'/2, '>='/2, '=:='/2, '=\\='/2,
    '=='/2, '\\=='/2, '\\='/2, member/2, append/3, length/2, write/1, writeln/1, nl/0,
    format/2, findall/3, atom/1, number/1, var/1, nonvar/1, '!'/0, fail/0, true/0]).

% ---- interesting ------------------------------------------------------------
interesting(Prog, Interests, P) :-
    words(Prog, Ws),
    include(in_list(Ws), Interests, Linked0), sort(Linked0, Linked),
    sort(Interests, Is),
    length(Linked, NL), length(Is, NI),
    pct(NL, NI, P).

in_list(L, X) :- memberchk(X, L).

words(Prog, Ws) :-
    findall(W, ( member(C, Prog), term_atom(C, A), atomic_list_concat(Parts, '_', A),
                 member(W, Parts), W \== '' ), W0),
    sort(W0, Ws).

term_atom(T, A) :- atom(T), !, A = T.
term_atom(T, A) :- compound(T), T =.. [F|Args], ( A = F ; member(X, Args), term_atom(X, A) ).

% ---- intuitive --------------------------------------------------------------
intuitive([], 0) :- !.
intuitive(Log, P) :-
    foldl(entry_score, Log, 0, Tot), length(Log, N),
    P is (2 * Tot + 3 * N) // (6 * N).

entry_score(t(U, D, E), A0, A) :- A is A0 + 100 * U + 100 * D + 10 * E.

% ---- circular pie charts ----------------------------------------------------
% pie(+Percent, -Rows): an 11x11 circle; '#' is the filled sector (clockwise
% from 12 o'clock), 'o' the rest, ' ' outside the circle.
pie(P, Rows) :-
    findall(Row, ( between(-5, 5, Y),
                   findall(C, ( between(-5, 5, X), pie_cell(P, X, Y, C) ), Cs),
                   atom_chars(Row, Cs) ), Rows).

pie_cell(P, X, Y, C) :-
    (   X * X + Y * Y > 25 -> C = ' '
    ;   X =:= 0, Y =:= 0 -> ( P > 0 -> C = '#' ; C = o )
    ;   A is atan2(X, -Y), F0 is A / (2 * pi),
        ( F0 < 0 -> F is F0 + 1 ; F = F0 ),
        ( F * 100 < P -> C = '#' ; C = o )
    ).

report(Input) :-
    assess(Input, scores(O, I, T)),
    pie(O, PO), pie(I, PI), pie(T, PT),
    format("  original ~w%      interesting ~w%   intuitive ~w%~n", [O, I, T]),
    forall(nth1(K, PO, R1), ( nth1(K, PI, R2), nth1(K, PT, R3),
                              format("  ~w      ~w      ~w~n", [R1, R2, R3]) )),
    Input = a(Prog, _, _), gaps(Prog, G),
    ( G == [] -> true ; format("Gaps in reasoning to complete: ~w~n", [G]) ).

% svg(+scores(O,I,T), -Svg): three donut pie charts.
svg(scores(O, I, T), Svg) :-
    donut(O, 60, original, A), donut(I, 180, interesting, B), donut(T, 300, intuitive, C),
    format(atom(Svg), '<svg xmlns="http://www.w3.org/2000/svg" width="360" height="140">~w~w~w</svg>', [A, B, C]).

donut(P, CX, Label, S) :-
    Dash is P * 314 // 100, Rest is 314 - Dash,
    format(atom(S), '<circle cx="~w" cy="60" r="50" fill="none" stroke="#e0e0e0" stroke-width="18"/><circle cx="~w" cy="60" r="50" fill="none" stroke="#3f51b5" stroke-width="18" stroke-dasharray="~w ~w" transform="rotate(-90 ~w 60)"/><text x="~w" y="65" text-anchor="middle" font-size="16">~w%</text><text x="~w" y="132" text-anchor="middle" font-size="12">~w</text>',
           [CX, CX, Dash, Rest, CX, CX, P, CX, Label]).

example(a([ (teach_music(Student) :- scale(Student, S), practise(S)),
            scale(alice, c_major),
            (meditation_break :- breathe, writeln(calm)) ],
          [music, meditation, sales],
          [t(1, 1, 8), t(1, 0, 6), t(0, 1, 7)])).
