(* simple test of proof representation *)
theory CIsaP                                             
imports       
  "../../../build/isabelle/Tinker"                                                                               
begin     
 -- "the goaltype"
 ML_file "../../../goaltype/clause/goaltype.ML"                                                                                                                        

 -- "the prover"  
 ML_file "../basic/isa_prover.ML"   

 -- "setting up PSGraph"

ML{*
  structure Clause_GT : BASIC_GOALTYPE = ClauseGTFun(structure Prover = IsaProver val struct_name = "Clause_GT");
  structure Data = PSGraphDataFun(Clause_GT);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = Clause_GT  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory)
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO);
  (*structure PSComb = PSCombFun (structure PSGraph = PSGraph)*)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);
  structure Env_Tac_Lib = EnvTacLibFunc (Theory);
*}

ML{*  open Env_Tac_Lib  *}

end



