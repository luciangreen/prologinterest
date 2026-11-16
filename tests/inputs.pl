% inputs.pl - 200 deterministic test inputs: 160 assessments, 40 pie charts.
input(Id, assess, I) :- between(1, 160, Id), gen_case(Id, I).
input(Id, pie, P) :- between(161, 200, Id), P is (Id - 161) * 5 // 2 + (Id mod 3).

lcg(S0, S) :- S is (S0 * 1103515245 + 12345) mod 2147483648.
pick(L, S0, S, X) :- lcg(S0, S), length(L, N), K is (S >> 16) mod N, nth0(K, L, X).
rint(N, S0, S, X) :- lcg(S0, S), X is (S >> 16) mod N.

vocab([music, meditation, sales, finance, logic, grammar, theatre, medicine,
       pedagogy, economics, computer, science, politics, time, travel]).

gen_case(Id, a(Prog, Ints, Log)) :-
    S0 is Id * 7919,
    vocab(V),
    findall(Nm, ( between(1, 6, K), S is S0 + K * 31, pick(V, S, S1, W1), pick(V, S1, _, W2),
                  atomic_list_concat([W1, W2], '_', Nm) ), Names),
    rint(5, S0, S2, NC0), NC is NC0 + 1,
    gen_clauses(NC, Names, V, S2, S3, Prog),
    rint(4, S3, S4, NI0), NI is NI0 + 1, gen_list(NI, V, S4, S5, Ints),
    rint(5, S5, S6, NL), gen_log(NL, S6, Log).

gen_list(0, _, S, S, []) :- !.
gen_list(N, V, S0, S, [X|Xs]) :- pick(V, S0, S1, X), N1 is N - 1, gen_list(N1, V, S1, S, Xs).

gen_clauses(0, _, _, S, S, []) :- !.
gen_clauses(N, Names, V, S0, S, [C|Cs]) :-
    pick(Names, S0, S1, H0), rint(2, S1, S2, Ar),
    ( Ar =:= 0 -> H = H0, S3 = S2 ; pick(V, S2, S3, Arg), H =.. [H0, Arg] ),
    rint(4, S3, S4, NB),
    gen_body(NB, Names, V, S4, S5, Gs),
    ( Gs == [] -> C = H ; list_conj(Gs, B), C = (H :- B) ),
    N1 is N - 1, gen_clauses(N1, Names, V, S5, S, Cs).

gen_body(0, _, _, S, S, []) :- !.
gen_body(N, Names, V, S0, S, [G|Gs]) :-
    rint(4, S0, S1, K),
    (   K =:= 0 -> pick(V, S1, S2, W), G = writeln(W)
    ;   K =:= 1 -> pick(V, S1, S2, W), atom_concat(W, '_gap', Nm), G = Nm
    ;   pick(Names, S1, S2, Nm), G = Nm
    ),
    N1 is N - 1, gen_body(N1, Names, V, S2, S, Gs).

list_conj([G], G) :- !.
list_conj([G|Gs], (G, B)) :- list_conj(Gs, B).

gen_log(0, _, []) :- !.
gen_log(N, S0, [t(U, D, E)|T]) :- rint(2, S0, S1, U), rint(2, S1, S2, D), rint(11, S2, S3, E),
    N1 is N - 1, gen_log(N1, S3, T).
