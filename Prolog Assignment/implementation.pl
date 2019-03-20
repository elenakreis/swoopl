:- [diagnosis].
% Helper function for children.
%%% getChildren(F,prevHn, Label, Children) unifies Children with the children of a node with set of edgelabels Hn.
getChildren(_,_,[],[]).
getChildren(DP, Hn, [Head|Tail], [HeadC|TailC]) :-
    makeHittingTree(DP, [Head|Hn] , HeadC),
    getChildren(DP, Hn, Tail, TailC)
    .
% Generates a hitting tree HT from a set of conflict sets.
% Using Hn as an additional parameter is not necessary (it could be done with pattern matching inside the node), but it is much more readible this way so we decided to stick with it.
%%% makeHittingTree(F,Hn,Tree) unifies Tree with the hitting tree of F.
makeHittingTree([SD, COMP, OBS], Hn, node(Children, S, Hn)) :- % node with list of Children, label S and list of edge labels Hn
  tp(SD, COMP, OBS, Hn, S),
  getChildren([SD, COMP, OBS], Hn, S, Children)
  .
makeHittingTree(_, Hn, node([], check, Hn)). % if tp fails go here

% Generates a hitting tree HT for a diagnostic problem (SD, COMP, OBS).
makeHittingTree(SD, COMP, OBS, HT) :-
  makeHittingTree([SD,COMP,OBS], [], HT)
  .
