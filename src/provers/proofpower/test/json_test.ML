  val path = "/Users/yuhuilin/Desktop/psgraph/" ;
  set_flag ("output_in_utf8", true);
  set_flag ("input_in_utf8", true);
  set_flag ("output_in_utf8", false);
  set_flag ("input_in_utf8", false);


string_of_term ¬A ¤ A ± A® |> ;

 init_symbol_table [("HOL.conj", "%and%"), ("HOL.implies", "%implies%")];

  val impI_tac  = step_strip_tac;
  val conjI_tac  = step_strip_tac;
  val assm_tac = step_strip_tac;

(* test gty pred *)
  fun test_true1 _ _ _ = true;
  fun test_failed_pred _ _ _ = false;


(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file (path^"demo_flat.psgraph");
  val ps = PSGraph.read_json_file (path^"demo_pred.psgraph");
  val ps = PSGraph.read_json_file (path^"demo_hie.psgraph");
  PSGraph.write_json_file (path^"demo1.psgraph") ps; 



(* socket testing *)
  PPIntf.set_psg_goal ([], %<% (A %implies% A) %and% (A %implies% B %implies% B) %>%) ps; 
  TextSocket.safe_close();