% spec.pl - independent oracle for prologinterest (different decomposition:
% goals are collected by flattening control constructs with =.., words by
% scanning characters, percentages by explicit rounding).

spec_for(assess, spec_assess).
spec_for(pie, spec_pie).

spec_assess(a(Prog, Ints, Log), scores(O, I, T)) :-
    spec_original(Prog, O), spec_interesting(Prog, Ints, I), spec_intuitive(Log, T).

spec_round(N, D, P) :- ( D =:= 0 -> P = 100 ; Q is N * 100 / D, P is floor(Q + 0.5) ).

spec_head_body(C, H, B) :- ( C = (H :- B) -> true ; H = C, B = true ).

spec_original(Prog, P) :-
    findall(F/N, ( member(C, Prog), spec_head_body(C, H, _), functor(H, F, N) ), Ds0), sort(Ds0, Ds),
    findall(F/N, ( member(C, Prog), spec_head_body(C, _, B), spec_goals(B, Gs), member(G, Gs),
                   functor(G, F, N), \+ spec_control(F/N) ), Cs0), sort(Cs0, Cs),
    findall(X, ( member(X, Cs), member(X, Ds) ), Hit), length(Hit, H), length(Cs, NC),
    spec_round(H, NC, P).

spec_goals(G, Gs) :-
    (   G =.. [Op, A, B], member(Op, [',', ';', '->'])
    ->  spec_goals(A, GA), spec_goals(B, GB), append(GA, GB, Gs)
    ;   G = (\+ A) -> spec_goals(A, Gs)
    ;   G == true -> Gs = []
    ;   Gs = [G]
    ).

spec_control(X) :- member(X, [(=)/2, (is)/2, (<)/2, (>)/2, (=<)/2, (>=)/2, (=:=)/2, (=\=)/2,
    (==)/2, (\==)/2, (\=)/2, member/2, append/3, length/2, write/1, writeln/1, nl/0,
    format/2, findall/3, atom/1, number/1, var/1, nonvar/1, (!)/0, fail/0, true/0]).

spec_interesting(Prog, Ints, P) :-
    findall(W, ( member(C, Prog), spec_sub_atom(C, A), atom_chars(A, Cs), spec_split(Cs, Ws),
                 member(W, Ws) ), All),
    sort(Ints, Is), findall(X, ( member(X, Is), member(X, All) ), L0), sort(L0, L),
    length(L, NL), length(Is, NI), spec_round(NL, NI, P).

spec_sub_atom(T, T) :- atom(T).
spec_sub_atom(T, A) :- compound(T), functor(T, A, _).
spec_sub_atom(T, A) :- compound(T), arg(_, T, X), spec_sub_atom(X, A).

spec_split(Cs, Ws) :- spec_split(Cs, [], Ws).
spec_split([], Acc, Ws) :- spec_flush(Acc, [], Ws).
spec_split(['_'|T], Acc, Ws) :- !, spec_split(T, [], W1), spec_flush(Acc, W1, Ws).
spec_split([C|T], Acc, Ws) :- append(Acc, [C], Acc1), spec_split(T, Acc1, Ws).
spec_flush([], W, W) :- !.
spec_flush(Acc, W, [A|W]) :- atom_chars(A, Acc).

spec_intuitive([], 0).
spec_intuitive([E|Es], P) :-
    findall(S, ( member(t(U, D, J), [E|Es]), S is 10 * U + 10 * D + J ), Ss),
    sum_list(Ss, Sum), length(Ss, N), D3 is 30 * N, spec_round(Sum, D3, P).

spec_pie(P, Rows) :-
    numlist(0, 10, Is),
    findall(R, ( member(YI, Is), Y is YI - 5,
                 findall(C, ( member(XI, Is), X is XI - 5,
                              ( X * X + Y * Y > 25 -> C = ' '
                              ; X == 0, Y == 0 -> ( P > 0 -> C = '#' ; C = o )
                              ; Ang is atan2(X, -Y),
                                ( Ang < 0 -> Frac is (Ang + 2 * pi) / (2 * pi) ; Frac is Ang / (2 * pi) ),
                                ( 100 * Frac < P -> C = '#' ; C = o ) ) ), Cs),
                 atom_chars(R, Cs) ), Rows).
