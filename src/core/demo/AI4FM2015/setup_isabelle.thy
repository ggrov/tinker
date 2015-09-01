theory setup_isabelle                                           
imports       
  "../../provers/isabelle/basic/build/BIsaP"    
begin

ML{*
  val path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/src/core/demo/AI4FM2015/" ;
*}


ML{*
fun rule_tac ctxt i (arg as [IsaProver.A_Str thm_name]) =  rtac (get_thm_by_name ctxt thm_name) i;
fun assm_tac  _ i _ =  atac i;
*}

(* choose which logging info do we want *)
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
  LoggingHandler.print_all_tags();
*}

end
