theory PPlan            
imports "IsapLib"                                                  
uses   

(* pplan *)
"../pplan/isa_step.ML"
"../pplan/depenv.ML" (* var/goal dependency environment *)
"../pplan/rtree.ML" (* result trees = horn clauses *)
"../pplan/aprf.ML" (* abstract proof *)
"../pplan/prf.ML" (* real proof  with flexes *)

(* Basic Generic Framework *)
"../pplan/pplan.ML"

(* tactic/method language *)
"../pplan/gtacs.ML" (* generic tacticcals for named results *)
(*  "../gproof/tools/m.ML" generic goal-named tactics *)


(* rippling libraries *)
"../rtechn/rippling/measure.ML"
"../rtechn/rippling/flow_measure.ML"
"../rtechn/rippling/dsum_measure.ML"
"../rtechn/rippling/skel.ML"
"../rtechn/rippling/skel_mes_traces.ML"
(* "../rtechn/rippling/skel_betters.ML" *)
(* "../rtechn/rippling/skel_better.ML" *)



(* declarative things; add datatype with more infor for Isar stuff *)
"../pplan/pplan_tac.ML" (* declarative tactics *)
"../isar/dthm.ML" (* declarative theorms (possibly with attributes!) *)
"../isar/isar_attr.ML" (* specific Isar attributes with their names*)

 (* from IsaPHOL *)
"../pplan/subst.ML"



begin

end;