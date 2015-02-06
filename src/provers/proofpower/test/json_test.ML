  val path = "/Users/yuhuilin/Desktop/" ;

  (*
  infixr 6 THENG; 
  val op THEN = PSComb.THEN;

  init_symbol_table [("and", "%and%"), ("implies", "%implies%")];
  val gt = Data.GT SimpleGoalTyp.default;
  val gt_imp =  Data.GT "top_symbol(implies)";
  val gt_conj = Data.GT "top_symbol(and)";
  
  val step_assm =  Data.T_Atomic {name = "step_assm", ,tactic = "step_assm", args = [[]]}; 
  val step_strip_imp =  Data.T_Atomic {name = "step_strip_imp", tactic = "step_strip_imp", args = [[]]}; 
  val step_strip_conj =  Data.T_Atomic {name = "step_strip_conj", tactic = "step_strip_conj", args = [[]]}; 

  val psasm =  PSComb.LIFT ([gt],[gt]) (step_assm);
  val psimpI = PSComb.LIFT ([gt_imp, gt_imp],[gt_imp, gt]) (step_strip_imp);
  val psconjI =  PSComb.LIFT ([gt_conj],[gt_imp]) (step_strip_conj);
  val ps = psconjI THEN ((PSComb.LOOP_WITH gt_imp psimpI) THEN psasm);
 *)

  val impI_tac  = step_strip_tac
  val conjI_tac  = step_strip_tac

(* test gty pred *)
  fun test_pred _ _ _ = true
  fun test_failed_pred _ _ _ = false
(* read and load a psgraph created by gui *)

  val ps = PSGraph.read_json_file (path^"demo_flat.psgraph");
  val ps = PSGraph.read_json_file (path^"demo_pred.psgraph");

  PSGraph.write_json_file (path^"demo1.psgraph") ps; 

  
(* socket testing *)
  PPIntf.set_psg_goal ([], %<% (A %implies% A) %and% (A %implies% B %implies% B) %>%) ps; 
  TextSocket.safe_close();