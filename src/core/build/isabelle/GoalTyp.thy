(* simple test of proof representation *)
theory GoalTyp   
imports LoadLib            
begin
  ML_file "../../utils/pretty_str_helper.ML"
  ML_file "../../utils/psgraph_names.ML" 
  ML_file "../../utils/unicode_helper.ML"
  ML_file "../../utils/logging_handler.ML"
  ML_file "../../utils/ml_exec.ML"
  ML_file "../../provers/prover.sig.ML"  


  ML_file "../../goaltype/goaltype.sig.ML"                                                                                                                      
  ML_file "../../goaltype/goaltype.ML"   
end



