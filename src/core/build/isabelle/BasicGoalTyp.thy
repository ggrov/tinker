(* simple test of proof representation *)
theory BasicGoalTyp   
imports LoadQuantoLib      (*LoadQuantoLib13 *)            
begin
  ML_file "../../utils/psgraph_names.ML" 
  ML_file "../../utils/unicode_helper.ML"
  ML_file "../../utils/logging_handler.ML"
  ML_file "../../utils/ml_exec.ML"
  ML_file "../../provers/prover.sig.ML"  
  ML_file "../../goaltype/basic_goaltyp.sig.ML"

end



