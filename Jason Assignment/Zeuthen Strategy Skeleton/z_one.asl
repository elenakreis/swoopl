// Agent z_one in project Zeuthen Strategy.mas2j

//z_one is similar to z_two, and in fact, mostly copied and pasted (including this very text!). There is one important difference:
//A deal, defined as [[list],[list]], consists of two task allocations, one for each agent.
//Z_one uses the LEFT list as its set, and the right list as Z_two's. You are free to define a deal in other ways, however.
//Depending on how you implement the Zeuthen strategy, you might end up adding functionalities to one agent and not to the other.
//Always make sure that when you copy and paste code from one agent to the other, that you make the necessary adjustments (such as
//switching which side the agent has to use).

//Hint: Jason is not widely used on the internet, so code examples mostly exist
//on the Jason site itself. However, the beliefs are mostly prolog: take examples
//from prolog code, then check on http://jason.sourceforge.net/api/ if their prolog
//equivalents exist.
//Further, you should not need to use the environment/java part of this code.
//You should be able to finish all assignments by adjusting z_one and z_two.

/* Initial beliefs and rules */
//I remember where the post office is.
postoffice(a).

//I remember the following routes and their cost:
//Unless you want to make a graph search algorithm (not recommended),
//these beliefs will likely be unused.
route(a,b,2).
route(a,c,3).
route(b,c,4).
route(b,d,6).
route(b,e,5).
route(e,f,4).
route(c,f,3).

//I know the costs of all sub-tasks. Keep in mind that every possible combination
//is written here: if you want to add more, you will have to write down all
//new possible costs.
//It is recommended to keep lists in alphabetic order. Jason does not see
//[b,c] as the same as [c,b]. This can cause bugs. If necessary, use the function
// .sort(List,SortedList) to make a list[c,b] a sorted list [b,c].
cost([],0).
cost([b],4).
cost([c],6).
cost([d],16).
cost([e],14).
cost([f],12).
cost([b,c],9).
cost([b,d],16).
cost([b,e],14).
cost([b,f],15).
cost([c,d],21).
cost([c,e],17).
cost([c,f],12).
cost([d,e],26).
cost([d,f],27).
cost([e,f],17).
cost([b,c,d],21).
cost([b,c,e],17).
cost([b,c,f],17).
cost([b,d,e],26).
cost([b,d,f],27).
cost([b,e,f],17).
cost([c,d,e],27).
cost([c,d,f],27).
cost([c,e,f],17).
cost([d,e,f],27).
cost([b,c,d,e],27).
cost([b,c,d,f],27).
cost([b,c,e,f],17).
cost([b,d,e,f],27).
cost([c,d,e,f],27).
cost([b,c,d,e,f],27).

//I remember my task set. During experiments, make sure to adjust the task.
originalTask([b,c,f]).

//Checking if two task sets are indeed valid re-distribution. This code requires
// having the total task set (b,c,d,e,f for example). You will need a way for totalTask
//to get the total task set when agents need to calculate the total task set by themselves.
validDistribution(OneSide,OtherSide) :-
	checkTotalTask(OneSide,OtherSide,[b,c,d,e,f]) & //Adjust [b,c,d,e,f] with a totalTask belief later on in the assignment.
	uniqueSets(OneSide,OtherSide).

//Checking if the two task sets are indeed the total task. 
checkTotalTask(D1, D2, TotalSet):-
	.union(D1, D2, TotalSet).

//Checking if two sets are unique. 
uniqueSets(D1, D2):-
	.intersection(D1, D2, []).
	
computeUtility(D, OT, Utility) :-
	cost(OT, C_OT) &
	cost(D, C_D) &
	Utility = C_OT - C_D.
	
//I know when a task is individual rational.
indiRatio(D, OT) :-
	computeUtility(D, OT, Utility) &
	Utility >= 0. // weakly dominates conflict deal, whose utility is 0.
	
//I know when a deal is pareto optimal:
paretoOptimal(D1, D2) :-
	.findall([OtherD1, OtherD2], (dominates([OtherD1, OtherD2], [D1,D2]) & validDistribution(OtherD1, OtherD2)), []).
	
dominates([DA1,DA2], [DB1,DB2]):-
	originalTask(OT) &
	theirOriginalTask(TOT) &
	computeUtility(DA1, OT, UA1) &
	computeUtility(DA2, TOT, UA2) &
	computeUtility(DB1, OT, UB1) &
	computeUtility(DB2, TOT, UB2) &
	UA1 >= UB1 & UA2 >= UB2 & (UA1 > UB1 | UA2 > UB2).
	
//I know what a deal I can offer up for negotiations, is like.
//If you want to check if you did a part correct, for example, validDistribution,
//comment the other parts out. 
goodDeal([MySide,TheirSide]) :-
	cost(MySide,_) &
	cost(TheirSide,_) &
	validDistribution(MySide,TheirSide) &
	originalTask(OT) &
	theirOriginalTask(TOT) & //The agent should have received this info from the other agent.
	indiRatio(MySide,OT) & //I am not going to consider deals worse than the conflict deal.
	indiRatio(TheirSide,TOT) & //The other agent is always going to refuse deals worse than the conflict deal. No point in considering them.
	paretoOptimal(MySide,TheirSide). 
	
//I can find all possible deals for negotiations.
setOfDeals(SetOfDeals) :-
	.findall(Deal, goodDeal(Deal),SetOfDeals).
	// The function .findall(Answer, belief(Nonsense,Answer), Answers) finds all
	//potential solutions to belief(Nonsense,Answer) and puts them in a list of Answers.
	//The first argument (Answer) states which part of the belief we want all solution of.
	//The second argument is the belief that we attempt to unify with the believes we have,
	//using the parameters 'Nonsense' and 'Answer'.
	//In this particular belief, we ask for all potential deals that are correct and put them
	//in the list SetOfDeals.
	
//I can sort a set of good deals so that the deals that are best for me, come first and slowly decline to less profitable deals.
sortedSet([[MySide,TheirSide]|OtherDeals],SetOfSortedDeals) :-
	sortSet(OtherDeals,[[MySide,TheirSide]|OtherDeals],[MySide,TheirSide],SetOfSortedDeals).

//I can sort a set of deals. This is accomplished using selection sort.
//No more deals left to try and sort. We are done.
sortSet([],[],_,SetOfSortedDeals) :- SetOfSortedDeals =[].
//Went through the list and found the lowest cost. Placing it on the spot, remove
//it from the to be sorted list, and continue with remainder.
sortSet([],ToBeSortedDeals,Deal,[X|Y]) :-
	X=Deal &
	.delete(Deal,ToBeSortedDeals,ToBeSorted) &
	sortSet(ToBeSorted,ToBeSorted,[],Y).
//Starting anew, assuming for now that lowest cost comes from the first deal in the list.
sortSet([Deal|OtherDeals],ToBeSorted,[],SetOfSortedDeals) :-
	sortSet(OtherDeals,ToBeSorted,Deal,SetOfSortedDeals).
//We found a deal with a lower cost: remembering it so we can compare it with the deals after it.
sortSet([[MySide,TheirSide]|OtherDeals],ToBeSorted,[CurMyHigh,CurTheirHigh],SetOfSortedDeals) :-
	cost(MySide,MyCheckCost) &
	cost(CurMyHigh,CurMyCost) &
	MyCheckCost < CurMyCost &
	sortSet(OtherDeals,ToBeSorted,[MySide,TheirSide],SetOfSortedDeals).
//No new deal with a lower cost, so our current assumed best remains the best for now.
sortSet([[MySide,TheirSide]|OtherDeals],ToBeSorted,CurBestDeal,SetOfSortedDeals) :-
	sortSet(OtherDeals,ToBeSorted,CurBestDeal,SetOfSortedDeals).


/* Helper functions */
acceptableDeal([TheirD1, _]):-
	myDeal([MyD1, _]) &
	originalTask(OT) &
	computeUtility(MyD1, OT, U_MyD) &
	computeUtility(TheirD1, OT, U_TheirD) &
	U_TheirD >= U_MyD.
	
wrisk([MyD1, MyD2], MyWrisk, TheirWrisk) :-
	theirDeal([TheirD1, TheirD2]) &
	originalTask(OT) &
	theirOriginalTask(TOT) &
	computeUtility(MyD1, OT, U_MyD1) &
	computeUtility(MyD2, TOT, U_MyD2) &
	computeUtility(TheirD1, OT, U_TheirD1) &
	computeUtility(TheirD2, TOT, U_TheirD2) &
	MyWrisk = (U_MyD1 - U_TheirD1) / U_MyD1 & 
	TheirWrisk = (U_TheirD2 - U_MyD2) / U_TheirD2.
	
/* Initial goals */
//I hate the deal I have been given. I want a better one! Perhaps I can ask z_two...
!startUp.




/* Plans */
//Initial conversation with the other agent. If I do not know their Original Task,
//then I have not yet asked. So I will ask for that and remember their answer. I will show
//their original task to the user as well. After this, I find all good deals and sort them and
//print the answer to the user. I then wait for further negotiation.

//This function requires you to finish the beliefs the agent has. If you have completed
//everything correctly, then you should see the following pop up:
//Agent 1 offers following deals  [[[c,f],[b,d,e]],[[d],[b,c,e,f]],[[b,d],[c,e,f]],[[c,e,f],[b,d]],[[b,c,e,f],[d]]]
//This is the negotiation set: you completed the first part of the assignment.

//It is recommended to first finish negotiations when you get to this point. After,
//you will need to come back to this function to create a way to reason what the total
//task set is given originalTask and theirOriginalTask, as well converse about the costs and remember these.
+!startUp
	: not theirOriginalTask(Task)
	<-
	.send(z_two, askOne, originalTask(TheirTask), originalTask(Answer)); //Asking the other agent what their original task is.
	//Note that here, we only want the Answer, whereas this function would normally return 'originalTask(Answer)[source: z_two]
	//By specifying originalTask in the return, we can seperate Answer from the rest and make a new belief with it.
	+theirOriginalTask(Answer);
	.print("Agent 2 told Agent 1 their task was ", Answer);
	?setOfDeals(Deals); //Finding all good deals, but they are unsorted.
	?sortedSet(Deals,SortedSet); //All good deals are now sorted.
	.print("Agent 1 offers following deals ", SortedSet);
	+theSetOfNegotiationDeals(SortedSet); //Remember the current negotiation deals.
	!firstRound.

+!firstRound
	: true
	<-
	.print("Start first round!");
	?theSetOfNegotiationDeals([BestDeal|Rest]);
	.send(z_two, tell, theirDeal(BestDeal));
	+myDeal(BestDeal);
	!checkAccept.

// if we don't know their deal yet, wait a bit and try again
+!checkAccept
	: not theirDeal(TheirDeal)
	<-
	.wait(500);
	!checkAccept.
	
+!checkAccept
	: theirDeal(TheirDeal) & acceptableDeal(TheirDeal)
	<-
	// accept their deal
	.print("Agent 1 accepts");
	.send(z_two, tell, acceptedDeal(TheirDeal));
	+acceptedDeal(TheirDeal).
	
+acceptedDeal(Deal)
	: true
	<-
	.print("Final result ", Deal);
	.drop_all_intentions.

+!checkAccept
	: theirDeal(TheirDeal) & not acceptableDeal(TheirDeal)
	<- 
	.print("Agent 1 doesn't accept");
	!getBetterDeal.
	
// coin flip
+!getBetterDeal
	: theirDeal(TheirDeal) & myDeal(MyDeal) & wrisk(MyDeal, MyWrisk, TheirWrisk) & MyWrisk = TheirWrisk & .random(N) & N > 0.5
	<- 
	.print("Coin flipped - 1 concedes");
	!concede.

+!getBetterDeal
	: theirDeal(TheirDeal) & myDeal(MyDeal) & wrisk(MyDeal, MyWrisk, TheirWrisk) & MyWrisk = TheirWrisk 
	<- 
	.print("Coin flipped - 2 concedes");
	.send(z_two, achieve, concede).

+!getBetterDeal
	: theirDeal(TheirDeal) & myDeal(MyDeal) & wrisk(MyDeal, MyWrisk, TheirWrisk) & MyWrisk < TheirWrisk 
	<- 
	.print("Agent 1 concedes");
	!concede.

// Superfluous function - used for printing
+!getBetterDeal
	: theirDeal(TheirDeal) & myDeal(MyDeal) & wrisk(MyDeal, MyWrisk, TheirWrisk) & MyWrisk > TheirWrisk 
	<- 
	.print("Agent 1 sends same deal").	

// There is at least one item to suggest otherwise
+!concede
	: theSetOfNegotiationDeals(NegotiationDeals) &	.findall(Deal, wrisk(Deal, MyNewWrisk, TheirNewWrisk) 
	& (MyNewWrisk > TheirNewWrisk | MyNewWrisk = 0 & TheirWrisk = 0) & .member(Deal, NegotiationDeals), Deals) & sortedSet(Deals, [NextBestDeal|_]) 
	<- 
	.print("Conceding");
	?myDeal(OldDeal);
	.send(z_two, untell, theirDeal(OldDeal));
	.send(z_two, tell, theirDeal(NextBestDeal));
	-+myDeal(NextBestDeal);
	.print("Agent 1 proposes: ", NextBestDeal);
	.send(z_two, achieve, checkAccept).

// There are no more deals to suggest
+!concede
	: theSetOfNegotiationDeals(NegotiationDeals) &	.findall(Deal, wrisk(Deal, MyNewWrisk, TheirNewWrisk)
	& MyNewWrisk > TheirNewWrisk & .member(Deal, NegotiationDeals), [])
	<- 
	.print("Conflict!");
	?originalTask(OT);
	?theirOriginalTask(TOT);
	.send(z_two, tell, acceptedDeal([OT,TOT]));
	+acceptedDeal([OT,TOT]).
	
