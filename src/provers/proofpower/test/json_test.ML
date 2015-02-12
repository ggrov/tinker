  val path = "/Users/yuhuilin/Desktop/" ;

 init_symbol_table [("HOL.conj", "%and%"), ("HOL.implies", "%implies%")];

  val impI_tac  = step_strip_tac;
  val conjI_tac  = step_strip_tac;
  val assm_tac = step_strip_tac;

(* test gty pred *)
  fun test_pred _ _ _ = true;
  fun test_failed_pred _ _ _ = false;


(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"demo_flat.psgraph");
  val ps = PSGraph.read_json_file (path^"demo_pred.psgraph");

  PSGraph.write_json_file (path^"demo1.psgraph") ps; 



(* socket testing *)
  PPIntf.set_psg_goal ([], %<% (A %implies% A) %and% (A %implies% B %implies% B) %>%) ps; 
  TextSocket.safe_close();