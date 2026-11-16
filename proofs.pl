% proofs.pl - properties of the three measures and the pie charts.
:- ensure_loaded('prologinterest.pl').
:- ensure_loaded('spec.pl').
:- ensure_loaded('tests/inputs.pl').

sample(I) :- between(1, 60, Id), gen_case(Id, I).

% Every score is a percentage 0..100.
% Proof: pct/3 rounds N/D*100 with 0 =< N =< D (N counts a subset of D);
% intuitive divides a sum of entries each =< 300 by 3N.
proof(scores_are_percentages, forall(sample(I), ( assess(I, scores(O, A, T)),
        forall(member(X, [O, A, T]), ( integer(X), X >= 0, X =< 100 )) ))).

% A program with no gaps in reasoning is 100% original.
% Proof: if every called predicate is defined, intersection(Calls,Defs)=Calls.
proof(closed_program_is_original, ( original([(a :- b, c), b, (c :- b)], 100) )).

% Completing a gap never lowers originality (monotonicity).
% Proof: adding a fact for a called predicate adds it to Defs, so the
% numerator rises by one or stays, the denominator is unchanged.
proof(filling_gaps_monotone, forall(sample(a(P, _, _)),
        ( original(P, O1), gaps(P, G),
          ( G = [N/0|_] -> append(P, [N], P2), original(P2, O2), O2 >= O1 ; true ) ))).

% Interestingness is 100% exactly when every interest occurs as a word.
proof(interest_full, ( interesting([music_logic(time)], [music, time, logic], 100) )).
proof(interest_none, ( interesting([sales_x], [music], 0) )).

% Intuitive = 100 for a perfect log, 0 for an empty one.
proof(intuitive_bounds, ( intuitive([t(1, 1, 10), t(1, 1, 10)], 100), intuitive([], 0), intuitive([t(0, 0, 0)], 0) )).

% The pie is monotone: raising the percentage never removes a filled cell.
proof(pie_monotone, forall(( between(0, 95, P), 0 =:= P mod 5 ), ( P2 is P + 5,
        pie(P, R1), pie(P2, R2), atomic_list_concat(R1, A1), atomic_list_concat(R2, A2),
        atom_chars(A1, C1), atom_chars(A2, C2),
        forall(nth1(K, C1, '#'), nth1(K, C2, '#')) ))).

% 0% has no filled cells; 100% fills the whole disc.
proof(pie_extremes, ( pie(0, R0), \+ ( member(R, R0), sub_atom(R, _, _, _, '#') ),
                      pie(100, R1), \+ ( member(R, R1), sub_atom(R, _, _, _, o) ) )).

% Refinement: implementation equals the independent spec on every sample.
proof(implementation_equals_spec, forall(sample(I), ( assess(I, A), spec_assess(I, B), A == B ))).
