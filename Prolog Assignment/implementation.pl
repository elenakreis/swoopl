% Generates a hitting tree HT from a set of conflict sets.
makeHittingTree(F, leaf(...)).
makeHittingTree(F, node(Children, Label)):-

  .

% Generates a hitting tree HT for a diagnostic problem (SD, COMP, OBS).
makeHittingTree(SD, COMP, OBS, HT) :-
  getF(SD, COMP, OBS, F),
  makeHittingTree(F, HT)
  .
