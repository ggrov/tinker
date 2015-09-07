(* simple test of proof representation *)
theory CIsaP                                             
imports       
  "../../../build/isabelle/Tinker"                                                                               
begin     
 -- "the goaltype"
 ML_file "../../../goaltype/clause/goaltype.sig.ML"                                                                                                                      
 ML_file "../../../goaltype/clause/goaltype.ML"                                                                                                                        

 -- "the prover"  
 ML_file "../basic/isa_prover.ML"                                

 -- "setting up PSGraph"

ML{*
  structure Clause_GT = ClauseGTFun(structure Prover = IsaProver val struct_name = "Clause_GT");
  structure Data = PSGraphDataFun(Clause_GT);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = Clause_GT  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory)
  structure Env_Tac_Utils = EnvTacUtilsFunc (structure Theory = Theory val struct_name = "Env_Tac_Utils" );
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO structure Env_Tac_Utils = Env_Tac_Utils);
  (*structure PSComb = PSCombFun (structure PSGraph = PSGraph)*)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);
 *}

ML{*  open Env_Tac_Utils  *}

end



