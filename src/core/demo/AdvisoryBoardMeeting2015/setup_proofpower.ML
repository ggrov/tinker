(* build tinker *)
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

 val path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/src/core/demo/AdvisoryBoardMeeting2015/" ;

(* choose which logging info do we want *)
  LoggingHandler.clear_active_tags ();
  LoggingHandler.print_active();
  LoggingHandler.print_all_tags();
  map LoggingHandler.ins_active_tag ["EVAL", "GRAPH", "HIERARCHY", "SOCKET", "TACTIC"];
  LoggingHandler.print_active();
  LoggingHandler.clear_active_tags ();

  val impI_thm = "This is a impI thm !";
  val conjI_thm = "This is a conjI thm";
  fun rule_tac pretty = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  val assm_tac = step_strip_tac;

