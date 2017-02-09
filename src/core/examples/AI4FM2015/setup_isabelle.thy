theory setup_isabelle                                           
imports       
  "../../provers/isabelle/basic/build/BIsaP"    
begin

ML{*
  val path = "/Users/yuhuilin/Workspace/StrategyLang/psgraph/src/core/demo/AI4FM2015/" ;
*}


ML{*
fun rule_tac (arg as [IsaProver.A_Thm thm]) ctxt i =  rtac thm i;
fun assm_tac  _ i =  atac i;
*}

(* choose which logging info do we want *)
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
  LoggingHandler.print_all_tags();
*}

end
