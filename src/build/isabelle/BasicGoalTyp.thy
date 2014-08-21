(* simple test of proof representation *)
theory BasicGoalTyp   
imports                
 "~~/contrib/isaplib/isabelle/isaplib/isaplib"                                               
begin
  ML_file "../../rtechn_names.ML" 
  ML_file "../../provers/prover.sig.ML"   
  ML_file "../../goaltype/basic_goaltyp.sig.ML"     
end



