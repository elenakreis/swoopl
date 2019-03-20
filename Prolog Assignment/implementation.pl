:- [diagnosis].
%%% intersect(L1,L2,X) unifies X with the interesection between L1 and L2.
  intersect([], _, []).
  %If H1 is in L2
  intersect([H1|L1], L2, [H1|ITC]) :-
    member(H1,L2),
    intersect(L1,L2,ITC).
  %If H1 is not in L2
  intersect([_|L1] , L2, ITC) :-
    intersect(L1,L2,ITC).

% Helper function for label.
getLabel([HeadF|TailF], Hn, HeadF):- % base case
  intersect(HeadF, Hn, []) % take first item of F as label if intersection is empty
  .
getLabel([HeadF|TailF], Hn, Label):-
  getLabel(TailF, Hn, Label) % If head intersection was not empty, try next element
  .
% Helper function for children.
getChildren(_,_,[],[]).
getChildren(F, Hn, [Head|Tail], [HeadC|TailC]) :-
    makeHittingTree(F, [Head|Hn] , HeadC),
    getChildren(F, Hn, Tail, TailC)
    .
% Generates a hitting tree HT from a set of conflict sets.
% Using Hn as an additional parameter is not necessary (it could be done with pattern matching inside the node), but it is much more readible this way so we decided to stick with it.
makeHittingTree([],_,node([], check, Hn])).
makeHittingTree([S|TailF], Hn, HT) :- % base case
  intersect(S, Hn, I), I \= [], % S intersection Hn is not empty
  makeHittingTree(TailF, Hn, HT)
  .
makeHittingTree(F, Hn, node(Children, Label, Hn)) :-
  getLabel(F, Hn, Label),
  getChildren(F, Hn, Label, Children)
  .

% Generates a hitting tree HT for a diagnostic problem (SD, COMP, OBS).
makeHittingTree(SD, COMP, OBS, HT) :-
  getF(SD, COMP, OBS, F), % TODO
  makeHittingTree(F, [], HT)
  .
