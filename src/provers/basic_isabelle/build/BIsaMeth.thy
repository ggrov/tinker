(* simple test of proof representation *)
theory BIsaMeth                                             
imports       
  BIsaP                                                                             
begin

 ML_file "../psgraph_method.ML" 

 -- "method to apply proof strategy"
 (* to do: add support for arguments, e.g. proof_strategy <strategy name> *)
 method_setup psgraph =
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (PSGraphMethod.psgraph_tac ctxt))) *}
  "application of active psgraph"

 method_setup interactive_psgraph =
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (PSGraphMethod.ic_psgraph_tac ctxt))) *}
  "application of active psgraph"


 -- "set active strategy"
 declare [[psgraph = "unknown"]]
 
end



