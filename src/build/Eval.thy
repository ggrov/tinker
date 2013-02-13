(* simple test of proof representation *)
theory Eval                                                                                                                                                            
imports          
  Stratlang                                                                         
uses                            
  "../wire/match.ML"                                                   
  "../eval/basic_eval.ML"                
  "../eval/eval_data.ML" 
  "../proof/pplan_env.ML"  
  "../eval/eval_appf.ML"                                  
  "../eval/eval_output.ML"
  "../eval/eval_graph.ML"    
  "../eval/eval_atomic.ML"  
  "../eval/eval_nested.ML"
  "../eval/rtechn_eval.ML"  
  "../interface/gui_socket.ML" 
  "../eval/eval_tac.ML"     
begin

 -- "method to apply proof strategy"
 (* to do: add support for arguments, e.g. proof_strategy <strategy name> *)
 method_setup proof_strategy = 
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (EvalTac.strategy_then_assm_tac ctxt))) *} 
  "application of active proof strategy"

 method_setup interactive_proof_strategy = 
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (EvalTac.interactive_strategy_then_assm_tac ctxt))) *} 
  "application of interactive active proof strategy for debugging (assumes Eclipse)"

 -- "set active strategy"
 declare [[strategy = "assume"]]

 -- "idea is to set path to file to parse proofs from generalisations from"
 declare [[strategy_path = "this is not used"]]

end



