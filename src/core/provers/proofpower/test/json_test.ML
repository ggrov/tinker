 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

get_theory_names();


 val path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/src/core/demo/AdvisoryBoardMeeting2015/" ;

  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  open_gui_single();

  val _ = LoggingHandler.active_all_tags ();
  val _ = LoggingHandler.print_active();

  val impI_thm = "This is a impI thm !";
  val conjI_thm =  "This is a conjI thm !";
  fun rule_tac pretty = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  val impI_tac  = step_strip_tac;
  val conjI_tac  = step_strip_tac;
  val assm_tac = step_strip_tac;

  (* test gty pred *)
  fun test_pred _ _ _ = true;
  fun test_failed_pred _ _ _ = false;
  fun test_true1 _ _ _ = true;

(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"demo_new.psgraph");
  val ps = PSGraph.read_json_file (path^"demo_env.psgraph");

  PPIntf.set_psg_goal ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®) ps;

  TextSocket.safe_close();
Pretty.string_of;