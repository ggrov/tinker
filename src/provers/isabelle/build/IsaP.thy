(* simple test of proof representation *)
theory IsaP                                              
imports       
  "GoalTyp" 
begin  

 ML_file "../isa_prover.ML" 
 ML_file "../../basic_isabelle/isa_atomic.ML" 
 ML_file "../isa_match_param.ML" 
 ML_file "../isa_setup.ML"

end



