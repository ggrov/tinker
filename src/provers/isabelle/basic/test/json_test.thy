theory json_test                                           
imports        
  "../build/BIsaP"    
begin
ML{*-
  val path = "/u1/staff/gg112/";
*}
ML{*
  val path = "/Users/yuhuilin/Desktop/" ;
*}

(* test psgraph level *)

ML{*
(* setting up a psgraph for testing *)
  fun at_impI_tac _ i _ = rtac @{thm impI} i;
  fun at_conjI_tac _ i _ = rtac @{thm conjI} i;
  fun at_atac _ i _ = atac i;
  fun at_all_tac  _ _ _ = all_tac

  val asm =  Data.T_Atomic {name = "atac", args = [[]]}; 
  val allT =  Data.T_Atomic {name = "all_tac", args = [[]]}; 
  val impI =  Data.T_Atomic {name = "impI", args = [[]]}; 
  val conjI =  Data.T_Atomic {name = "conjI", args = [[]]}; 

  fun load_atom ps =  PSGraph.load_atomics 
    [("all_tac", at_all_tac), ("atac", at_atac), ("impI", at_impI_tac), ("conjI", at_conjI_tac)] 
    ps;

  val gt = Data.GT SimpleGoalTyp.default;
  val gt_imp =  Data.GT "top_symbol(HOL.implies)";
  val gt_conj = Data.GT "top_symbol(HOL.conj)";
  
  infixr 6 THENG; 
  val op THEN = PSComb.THEN;

  
  val psasm =  PSComb.LIFT ([gt],[gt]) (asm);
  val psall =  PSComb.LIFT ([gt],[gt]) (allT);
  val psimpI = PSComb.LIFT ([gt_imp, gt_imp],[gt_imp, gt]) (impI);
  val psconjI =  PSComb.LIFT ([gt_conj],[gt_imp]) (conjI);

  val ps = psconjI THEN ((PSComb.LOOP_WITH gt_imp psimpI) THEN psasm)
    |> load_atom;
*}

ML{*

val g = PSGraph.get_graph ps;
Theory_IO.write_json_file (path^"test.psgraph") g;
*}

ML{*


 PSGraph.write_json_file (path^"test0.psgraph") ps;
*}
