  open_theory "hol";
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");


  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  open_gui_single();

  val _ = LoggingHandler.active_all_tags ();

  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  fun impI_tac _ = step_strip_tac;
  fun conjI_tac _ = step_strip_tac;
  fun assm_tac  _ = step_strip_tac;


(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file NONE (path^"demo.psgraph");
  val ps = PSGraph.read_json_file NONE (path^"demo_env.psgraph");

  PPIntf.set_psg_goal ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®) (SOME ps);

  TextSocket.safe_close();

======

  val ps = PSGraph.read_json_file NONE (path^"nonascii_tac.psgraph");
  PPIntf.set_psg_goal ([],¬µx· x = x®) ps;



set_goal 
a µ_tac;
open_gui_single (); 