
  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  val _ = LoggingHandler.active_all_tags ();
  val _ = LoggingHandler.print_active();

  val impI_thm = "This is a impI thm !";
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
  PSGraph.write_json_file (path^"demo1.psgraph") ps; 

(* socket testing *)
  PPIntf.set_psg_goal ([], %<% (A %implies% (A %and% A %and% A)) %>%) ps; 

  PPIntf.set_psg_goal ([], %<% (A %implies% A) %and% (A %implies% B %implies% B) %>%) ps; 
  TextSocket.safe_close();
