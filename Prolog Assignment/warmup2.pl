%a
isBinaryTree(leaf(_)).
isBinaryTree(node(X,Y,_)):-
    isBinaryTree(X),isBinaryTree(Y).

%b
nnodes(leaf(_),N):- N is 1.
nnodes(node(X,Y,_),N):-
    nnodes(X, N1),
    nnodes(Y, N2),
    N is N1 + N2 + 1.

%c is done by adding wildcard arguments to leaf() and node()

%d
makeBinary(0, leaf(0)).
makeBinary(N, node(X, Y, N)):-
    N > 0,
    M is N-1,
    makeBinary(M, X),
    makeBinary(M, Y).

%e
getChildren(_,_,0,[]).
getChildren(M, NrChildren, Iter, [Head|Tail]) :-
    Iter > 0,
    NextIter is Iter-1,
    makeTree(M, NrChildren, Head),
    getChildren(M, NrChildren, NextIter, Tail)
    .

makeTree(0,_,leaf(0)).
makeTree(N, NrChildren, node(Children, N)) :-
    N > 0,
    NrChildren > 0,
    M is N-1,
    getChildren(M, NrChildren, NrChildren, Children)
    .
