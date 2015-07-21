(* simple test of proof representation *)
theory BasicGoalTyp   
imports LoadQuantoLib      (*LoadQuantoLib13 *)            
begin
  ML_file "../../unicode_helper.ML"
  ML_file "../../psgraph_names.ML" 
  ML_file "../../logging_handler.ML"
  ML_file "../../ml_exec.ML"
  ML_file "../../provers/prover.sig.ML"  
  ML_file "../../goaltype/basic_goaltyp.sig.ML"

end



