:- [diagnosis].
% Helper function for creating the children in the hitting set.
% getChildren(DP ,prevHn, Label, Children) unifies Children with the children of a node with set of edgelabels Hn.
getChildren(_,_,[],[]).
getChildren(DP, Hn, [Head|Tail], [HeadC|TailC]) :-
    makeHittingTree(DP, [Head|Hn] , HeadC),
    getChildren(DP, Hn, Tail, TailC)
    .
% makeHittingTree([SD, COMP, OBS], Hn, Tree) unifies Tree with the hitting tree of the diagnostic problem [SD, COMP, OBS].
% Note: Using Hn as an additional parameter is not necessary (it could be done with pattern matching inside the node), but it is much more readible this way so we decided to stick with it.
makeHittingTree([SD, COMP, OBS], Hn, node(Children, S, Hn)) :- % node: list of Children, label S and list of edge labels Hn.
  tp(SD, COMP, OBS, Hn, S),
  getChildren([SD, COMP, OBS], Hn, S, Children)
  .
makeHittingTree(_, Hn, node([], check, Hn)). % if tp fails, go here.

% Generates a hitting tree HT for a diagnostic problem (SD, COMP, OBS).
makeHittingTree(SD, COMP, OBS, HT) :-
  makeHittingTree([SD,COMP,OBS], [], HT)
  .

% -------------------------------------------------------------------------
% Helper function to gather diagnoses from each child.
gatherChildDiagnoses([], []).
gatherChildDiagnoses([HeadC|TailC], D) :-
  gatherDiagnoses(HeadC, HeadCD),
  gatherChildDiagnoses(TailC, TailCD),
  append(HeadCD, TailCD, D)
  .

% Function for getting all hitting sets of a hitting tree.
gatherDiagnoses(node(_, check, Hn), [Hn]).
gatherDiagnoses(node(Children, _, _), D) :-
  gatherChildDiagnoses(Children, D)
  .
% -------------------------------------------------------------------------
% This sorting function was taken from http://kti.ms.mff.cuni.cz/~bartak/prolog/sorting.html (Last accessed 03-04-2019) and adapted to sort according to list length. All credits go to Roman Barták.
insert_sort(List,Sorted):-
  i_sort(List,[],Sorted)
  .
i_sort([],Acc,Acc).
i_sort([H|T],Acc,Sorted):-
  insert(H,Acc,NAcc),
  i_sort(T,NAcc,Sorted)
  .

insert(X,[Y|T],[Y|NT]):-
  length(X, LenX),
  length(Y, LenY),
  LenX>LenY,
  insert(X,T,NT)
  .
insert(X,[Y|T],[X,Y|T]):-
  length(X, LenX),
  length(Y, LenY),
  LenX=<LenY.
insert(X,[],[X]).

%---------------------------------------------------
% isSuperset(Set, SetofSets) determines whether Set is a superset of any set in SetofSets.
~isSuperset(_, []).
isSuperset(D, [Head|Tail]) :-
  subset(Head, D); % D is superset of Head
  isSuperset(D, Tail)
  .
% getMD(D, MD). Helper function for getMinimalDiagnoses. Removes all supersets from D, if the sets in D are ordered by descending length.
getMD([],[]).
getMD([HeadD|TailD], MD):-
  getMD(TailD, TailMD),
  ( %if
    isSuperset(HeadD, TailD)
  ->
    %then
    MD = TailMD % Discard HeadD
  ;
    %else
    MD = [HeadD|TailMD] % Keep HeadD
  )
  .
% Removes all supersets of D to get MD.
% Sorts the sets in D by length, and then reverses them to have them in descending order.
getMinimalDiagnoses(D, MD) :-
  insert_sort(D, DSort), % Sort by length of sublists.
  reverse(DSort, DSortReverse), % Put longest lists in front.
  getMD(DSortReverse, MD)
  .

% ------------------------------------------------------------------------
% Main predicate that takes a diagnostic problem and returns the minimal diagnoses MD.
solveDP(SD, COMP, OBS, MD):-
  makeHittingTree(SD, COMP, OBS, HT),
  gatherDiagnoses(HT, D),
  getMinimalDiagnoses(D, MD)
  .
