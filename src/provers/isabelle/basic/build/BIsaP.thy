(* simple test of proof representation *)
theory BIsaP                                             
imports       
  "../../../../build/isabelle/BasicIsaPS"                                                                               
begin 
 
 ML_file "../isa_prover.ML"              

(* rippling *) 
 ML_file "../../termlib/rippling/basic_ripple.ML" 
(* induction *)
 ML_file "../../termlib/induct.ML"

 ML_file "../simple_goaltyp.ML"
                            


ML{*
structure Theory = PSTheoryFun(structure GoalTyp = SimpleGoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Prover = IsaProver);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Prover = IsaProver
                           structure PSGraph = PSGraph);
*}
ML{*
structure EVal = EValFun(EData); 
*}                    
          
end



