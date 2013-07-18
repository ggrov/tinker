(* simple test of proof representation *)
theory BIsaMeth                                             
imports       
  BIsaP                                                                             
begin
  
(* socket *)
ML_file "../../../interface/text_socket.ML"
ML_file "../../../interface/ui_socket.ML"

(* json protocol, they are alreay in Quantolib *)
ML_file "../../../interface/json_protocol/controller_util.ML"
ML_file "../../../interface/json_protocol/controller_module.ML"
ML_file "../../../interface/json_protocol/modules/psgraph.ML"
ML_file "../../../interface/json_protocol/controller_registry.ML"
ML_file "../../../interface/json_protocol/protocol.ML"

ML_file "../psgraph_method.ML" 

 -- "method to apply proof strategy"
 (* to do: add support for arguments, e.g. proof_strategy <strategy name> *)
 method_setup psgraph =
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (PSGraphMethod.psgraph_tac ctxt))) *}
  "application of active psgraph"

 method_setup ipsgraph =
  {* Scan.lift (Scan.succeed (fn ctxt => SIMPLE_METHOD (PSGraphMethod.ic_psgraph_tac ctxt))) *}
  "application of active psgraph"


 -- "set active strategy"
 declare [[psgraph = "unknown"]]
 
end



