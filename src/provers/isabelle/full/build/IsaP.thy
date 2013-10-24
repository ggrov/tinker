(* simple test of proof representation *)
theory IsaP                                              
imports        
  "GoalTyp" 
begin     

 ML_file "../pplan/isa_pnode.ML"  
 ML_file "../pplan/isa_pplan.ML"  
 ML_file "../pplan/isa_prover.ML"      

 ML_file "../isa_setup.ML"          

(* socket *)
 ML_file "../../../../interface/text_socket.ML"
 ML_file "../../../../interface/ui_socket.ML"

(* json protocol, they are alreay in Quantolib *)
 ML_file "../../../../interface/json_protocol/controller_util.ML"
 ML_file "../../../../interface/json_protocol/controller_module.ML"
 ML_file "../../../../interface/json_protocol/modules/psgraph.ML"
 ML_file "../../../../interface/json_protocol/controller_registry.ML"
 ML_file "../../../../interface/json_protocol/protocol.ML"

 (* induction tactic from isaplanner *)
 ML_file "../../termlib/induct.ML"  

 (*features *)
 ML_file "../isa_features.ML"    
 setup {* IsaFeatures.default *}

 ML_file "../pplan/export/export_thm.ML"
 ML_file "../isa_method.ML"              
end



