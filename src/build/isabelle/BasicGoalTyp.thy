(* simple test of proof representation *)
theory BasicGoalTyp   
imports Pure
 (* isalib is now part of quanto lib *) 
  Main       
  "~~/contrib/quantomatic/core/quanto"                                             
begin
  ML_file "../../rtechn_names.ML" 
  ML_file "../../provers/prover.sig.ML"   
  ML_file "../../goaltype/basic_goaltyp.sig.ML"     
end



