  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/";
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  (*open_gui_single();*)

  val _ = LoggingHandler.active_all_tags ();

  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  fun impI_tac _ = step_strip_tac;
  fun conjI_tac _ = step_strip_tac;
  fun assm_tac  _ = step_strip_tac;
  val id_tac0 = id_tac; 
  fun id_tac _ =  id_tac0;

  val data = ClauseGoalTyp.add_atomic "top_symbol" top_symbol ClauseGoalTyp.default_data; 
  val scan_def = ClauseGoalTyp.scan_data PPProver.default_ctxt;
  val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
  val pdef1 = scan_def def1;
  val data = ClauseGoalTyp.update_data_defs (K pdef1) data;
   
(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"clause_demo.psgraph")|> PSGraph.set_goaltype_data data; 

  PPIntf.set_psg_goal (SOME ([], ¬A%and%A%and%A®)) (SOME ps);

  TextSocket.safe_close();

drop_main_goal();
val g1 = ([ ¬A®, ¬A%implies%A®], ¬A%and%A%and%A®);
val g2= ([ ¬A®, ¬A%and%A®], ¬A%and%A%and%A®);
val g3 = ([ ¬A%and%A%and%A®, ¬A%implies%A®], ¬A%and%A%and%A®);



val ctxt = PPProver.default_ctxt;

(ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).");

default_gt_data;

val data = 
default_gt_data
|> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x)
|> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "h(Z) :- top_symbol(hyps,Z).") @ x);

ClauseGoalTyp.update_data_defs;

val (pnode,pplan) = PPProver.init PPProver.default_ctxt (fst g2) (snd g2);

ClauseGoalTyp.scan_goaltyp ctxt "c(conj)";
default_gt_data;
ClauseGoalTyp.type_check data pnode ("h",[ClauseGoalTyp.Name "conj"]);

