(* simple test of proof representation *)
theory BIsaP                                             
imports       
  "../../../../build/isabelle/Tinker"                                                                               
begin 

(* wrapping trm with name structure *)
  ML_file "../../termlib/rippling/unif_data.ML" 
  ML_file "../../termlib/rippling/collection.ML"   
  ML_file "../../termlib/rippling/pregraph.ML"  
  ML_file "../../termlib/rippling/rgraph.ML" 
  
  ML_file "../../termlib/rippling/embedding/paramtab.ML" 
  ML_file "../../termlib/rippling/embedding/trm.ML"  
  ML_file "../../termlib/rippling/embedding/isa_trm.ML"
  ML_file "../../termlib/rippling/embedding/instenv.ML"
  ML_file "../../termlib/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../termlib/rippling/embedding/eterm.ML"  
  ML_file "../../termlib/rippling/embedding/ectxt.ML" 
  ML_file "../../termlib/rippling/embedding/embed.ML" 
 
(* measure and skeleton *)
  ML_file "../../termlib/rippling/measure_traces.ML"
  ML_file "../../termlib/rippling/measure.ML" 
  (*ML_file "../../provers/isabelle/termlib/rippling/flow_measure.ML"*)
  ML_file "../..//termlib/rippling/dsum_measure.ML" 

(* wave rule set *)
  ML_file  "../../termlib/rippling/rulesets/substs.ML"
                         
  ML_file "../../termlib/term_fo_au.ML"  
  ML_file "../../termlib/term_features.ML"   

  ML_file "../isa_prover.ML"                     

(* rippling *) 
  ML_file "../../termlib/rippling/basic_ripple.ML" 
(* induction *)
  ML_file "../../termlib/induct.ML"

  ML_file "../../../../goaltype/simple_goaltype.ML"
                            

ML{*
  structure SimpleGoalType : BASIC_GOALTYPE = SimpleGoalType_Fun(structure Prover = IsaProver val struct_name = "SimpleGoalType");
  structure Data = PSGraphDataFun(SimpleGoalType);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = SimpleGoalType  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory)
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO);
  structure PSComb = PSCombFun (structure PSGraph = PSGraph)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (IEVal);
  structure Env_Tac_Lib = EnvTacLibFunc (Theory);
*}

  ML_file "../simpleGT_lib.ML"
  ML{*  open Env_Tac_Lib SimpleGT_Lib IsaProver*}
  (* ML_file "../psgraph_isar_method.ML"*) (*method does not work because fail to exec ml code*)
end



