%%% intersect(L1,L2,X) unifies X with the interesection between L1 and L2.
  intersect([], _, []).
  %If H1 is in L2
  intersect([H1|L1], L2, [H1|ITC]) :-
    member(H1,L2),
    intersect(L1,L2,ITC).
  %If H1 is not in L2
  intersect([_|L1] , L2, ITC) :-
    intersect(L1,L2,ITC).

% Helper function for children.
getChildren(_,_,[],[]).
getChildren(F, Hn, [Head|Tail], [HeadC|TailC]) :-
    makeHittingTree(F, [Head|Hn] , HeadC),
    getChildren(F, Hn, Tail, TailC)
    .
% Generates a hitting tree HT from a set of conflict sets.
% Using Hn as an additional parameter is not necessary (it could be done with pattern matching inside the node), but it is much more readible this way so we decided to stick with it.
makeHittingTree([],_,_).
makeHittingTree([HeadF|TailF], Hn, node([], check, Hn])) :-
  intersect(HeadF, Hn, S), S \= [],
  makeHittingTree(TailF, Hn, node([], check, Hn))
  .
makeHittingTree(F, Hn, node(Children, Label, Hn)) :-
  Label = ..., % TODO
  getChildren(F, Hn, Label, Children)
  .

% Generates a hitting tree HT for a diagnostic problem (SD, COMP, OBS).
makeHittingTree(SD, COMP, OBS, HT) :-
  getF(SD, COMP, OBS, F), % TODO
  makeHittingTree(F, [], HT)
  .
