(* simple test of proof representation *)
theory Eval                                                       
imports         
  Stratlang                                                         
uses              
  "../wire/match.ML"                                   
  "../rtechn/rtechn_rs.ML"       
  "../eval/basic_eval.ML"               
  "../proof/pplan_env.ML" 
  "../eval/eval_appf.ML"                                  
  "../eval/eval_output.ML" 
  "../eval/eval_atomic.ML"  
  "../eval/rtechn_eval.ML"                          
  "../eval/eval_tac.ML" 
begin

 -- "method to apply proof strategy"
 (* to do: add support for arguments, e.g. proof_strategy <strategy name> *)
 method_setup proof_strategy = 
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (EvalTac.strategy_then_assm_tac ctxt))) *} 
  "application of active proof strategy"

 -- "adds assume tactic (should reallly be done when creating method)"
 setup {* TacticTab.add_tactic ("atac",K (K (atac 1))) *}

 -- "set active path"
 declare [[strategy = "assume"]]

 -- "idea is to set path to file to parse proofs from generalisations from"
 declare [[strategy_path = "this is not used"]]

end



