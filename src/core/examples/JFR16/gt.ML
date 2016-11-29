val tinkerhome = OS.FileSys.getDir() ^ "/psgraph";
use (tinkerhome ^ "/src/core/build/proofpower/tinker");
open_theory "hol";
set_pc "hol";
(*=====  GoalTyp definitions *)
 val clause_def = 
 "left(X,L) :- dest_trm(X,L,_)." ^
 "top_symbol0(X,L) :- const_str(X,L)." ^
 "top_symbol0(X,L) :- left(X,Z),top_symbol0(Z,L).";

 val clause_def = 
 "left(X,L) :- dest_trm(X,L,_)." ^
 "right(X,R) :- dest_trm(X,_,R)." ^
 "has_symbol(X,Y) :- top_symbol(X,Y)." ^
 "has_symbol(X,Y) :- right(X,Z),has_symbol(Z,Y)." ^
 "has_symbol(X,Y) :- left(X,Z),has_symbol(Z,Y)." ;


 
 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);

 val ctxt = get_current_pc();
 val g = ([¬³ (A ± B)®],¬(A ± B)®);
 val (pnode,pplan) = PPProver.init ctxt (PPProver.G_TERM g);
  
 val gt1 = ClauseGoalTyp.scan_goaltyp ctxt" has_symbol(concl,conj)";
 val gt2= ClauseGoalTyp.scan_goaltyp ctxt" has_symbol(concl,disj)";
 val gt3 = ClauseGoalTyp.scan_goaltyp ctxt" top_symbol0(concl,conj)";

"dummy pos";
 ClauseGoalTyp.imatch data pnode gt1;

