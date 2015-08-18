(* build tinker *)
 use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

 val path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/src/core/demo/AdvisoryBoardMeeting2015/" ;

(* choose which logging info do we want *)
  LoggingHandler.clear_active_tags ();
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_all_tags();
  LoggingHandler.print_active();
  (*LoggingHandler.clear_active_tags ();*)

  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  fun impI_tac _ = step_strip_tac;
  fun conjI_tac _ = step_strip_tac;
  fun assm_tac  _ = step_strip_tac;


