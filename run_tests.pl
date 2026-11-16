% Runs the 200 saved I/O pairs against the implementation and checks every proof.
% Usage (from the repo root):  swipl run_tests.pl
:- ensure_loaded('prologinterest.pl').
:- ensure_loaded('proofs.pl').
:- ensure_loaded('tests/io_pairs.pl').
:- initialization(main).

main :-
    findall(Id, io(Id,_,_,_), Ids), length(Ids, N),
    findall(Id, (io(Id,P,I,O), \+ passes(P,I,O)), Fails),
    length(Fails, NF), NP is N - NF,
    format("I/O pairs: ~w/~w passed~n", [NP, N]),
    ( Fails == [] -> true ; format("Failed pairs: ~w~n", [Fails]) ),
    findall(T, proof(T,_), Ts), length(Ts, NT),
    findall(T, (proof(T,G), \+ catch(G,_,fail)), PF),
    length(PF, NPF), NPP is NT - NPF,
    format("Proofs: ~w/~w hold~n", [NPP, NT]),
    ( PF == [] -> true ; format("Failed proofs: ~w~n", [PF]) ),
    ( Fails == [], PF == [], N >= 200 -> halt(0) ; halt(1) ).

passes(P, I, O) :- catch(call(P, I, G), _, fail), G == O, !.
