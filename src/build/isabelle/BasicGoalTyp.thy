(* simple test of proof representation *)
theory BasicGoalTyp   
imports LoadQuantoLib      (*LoadQuantoLib *)            
begin
  ML_file "../../rtechn_names.ML" 
  ML_file "../../provers/prover.sig.ML"   
  ML_file "../../goaltype/basic_goaltyp.sig.ML"  

ML{*
val a = 1;

;
a;
*}   
end



