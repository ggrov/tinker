(* simple test of proof representation *)
theory BIsaP                                             
imports       
  "../../isabelle/build/basic/BasicIsaPS"                                                                             
begin
 ML_file "../isa_prover.ML"  
 ML_file "../isa_atomic.ML"
 ML_file "../simple_goaltyp.ML"              

ML{*
structure Theory = PSTheoryFun(structure GoalTyp = SimpleGoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Atomic = BIsaAtomic);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = BIsaAtomic
                           structure PSGraph = PSGraph);
*}
ML{*
structure EVal = EValFun(EData);
*}                               
end



