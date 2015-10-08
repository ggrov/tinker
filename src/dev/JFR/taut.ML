(* load the definition of taut_tac *) 
  use_file1 (OS.FileSys.getDir()  ^ "/psgraph/src/dev/JFR/pp_taut.sml");

(* load psgraph and tinker *) 
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
  val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
  val pspath = tinker_path ^ "src/dev/psgraph/";

 open_theory "hol";
 set_pc "hol";

(* open the definition of taut *) 
  open PP_Taut;

(* Setup GoalType and Tac def *)
 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "h(Z) :- top_symbol(hyps,Z).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c_and_rand_not_var(Z) :- c(Z), rand_trm(concl, X), is_not_trm_var(X).") @ x);

fun taut_strip_concl thm_l = 
  conv_tac (eqn_cxt_conv (map thm_eqn_cxt thm_l));
val strip_²_concl_tac = taut_strip_concl [a_²_³b_thm, ³a_²_b_thm, a_²_b_thm];
val strip_¤_concl_tac = taut_strip_concl [´_thm, ¤_thm]
val strip_³_concl_tac = taut_strip_concl [³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm, ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm];
val strip_if_concl_tac = taut_strip_concl [local_if_thm];
val strip_´_concl_tac = (´_T (asm_tac));


(* Version 1, just a loop *)
 val taut_v1 = PSGraph.read_json_file (pspath ^"simple_taut_tac_V1.psgraph");

  PPIntf.set_psg_goal (SOME ([],¬(A ± B) ´ (B ± A)®)) (SOME taut_v1);

(* Version 3, add goaltype *)
 val taut_v3 = PSGraph.read_json_file (pspath ^"simple_taut_tac_V3.psgraph") |> PSGraph.set_goaltype_data data; 

 PPIntf.set_psg_goal (SOME g3) (SOME taut_v3);

val ps = PSGraph.read_json_file (pspath^"branching.psgraph");

PPIntf.set_psg_goal (SOME g1) (SOME a);
TextSocket.safe_close();

val (pnode,pplan) = PPProver.init PPProver.default_ctxt (fst g3) (snd g3);
val g1 : GOAL = ([],¬(A ± T)´B®);
val g2 : GOAL = ([¬B ± A®],¬A ± B®);
val g3 : GOAL = ([],¬if a then F else T®);
val g4 : GOAL = ([],¬A´B®);
val g5 : GOAL = ([],¬³ (B)®);

val ctxt = PPProver.default_ctxt;
ClauseGoalTyp.scan_goaltyp ctxt "c(?X)";

"c(conj)";
default_gt_data;
data;

ClauseGoalTyp.type_check data pnode ("c_and_rand_not_var",[ClauseGoalTyp.Name "not"]);

ClauseGoalTyp.type_check data pnode ("c",[ClauseGoalTyp.Name "Cond"]);


  val data = ClauseGoalTyp.add_atomic "rand_trm" rand_trm ClauseGoalTyp.default_data; 

set_goal g4;
a simple_taut_tac;

asm_tac;
dest_simple_term ¬if a then b else c® ;
dest_%implies% ¬a %implies% b® ;


(* arg_data list -> env -> env list *)

is_const;
is_var;