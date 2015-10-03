(* load the definition of taut_tac *) 
  use_file1 (OS.FileSys.getDir()  ^ "/psgraph/src/dev/JFR/pp_taut.sml");

(* load psgraph and tinker *) 
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
  val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
  val pspath = tinker_path ^ "src/dev/psgraph/";

(* open the definition of taut *) 
  open PP_Taut;

(* Version 1, just a loop *)
 val taut_v1 = PSGraph.read_json_file (pspath ^"simple_taut_tac_V1.psgraph");

  PPIntf.set_psg_goal (SOME ([],¬(A ± B) ´ (B ± A)®)) (SOME taut_v1);

(* Version 3, add goaltype *)

 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "h(Z) :- top_symbol(hyps,Z).") @ x);



(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"clause_demo.psgraph")|> PSGraph.set_goaltype_data data; 

±_tac;

get_pcs ();
open_theory "z_library";
 set_pc "z_library1";
set_goal ([],¬(A ± B) ´ (T)®);
a (step_strip_tac);
a t_tac;
a ±_tac;


val ps = PSGraph.read_json_file (pspath^"test.psgraph");

PPIntf.set_psg_goal (SOME ([],¬(A ± T)®)) (SOME ps);
TextSocket.safe_close();

use_string "±_tac";
Seq.empty;