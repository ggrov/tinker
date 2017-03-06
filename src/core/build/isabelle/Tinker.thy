(* JSON protocal and comnumnication interfaces with the tinker GUI *)
theory Tinker                                                                                                                                                                                           
imports           
  EVal                                                                       
begin
 (* socket communication for the tinker gui *)
 ML_file "../../interface/text_socket.ML"
 ML_file "../../interface/tinker_protocol.ML"
                                                                                                                     

 -- "the prover"  
 ML_file "../../provers/Isabelle/isa_prover.ML"                              

   
 -- "setting up PSGraph"
ML{*
  structure Clause_GT = ClauseGTFun(structure Prover = IsaProver val struct_name = "Clause_GT");
  structure Data = PSGraphDataFun(Clause_GT);
  structure Graph = GraphFun(Data);
  structure Graph_Utils = GraphUtilsFun(Graph);
  structure Env_Tac_Utils = EnvTacUtilsFunc (structure Graph_Utils = Graph_Utils val struct_name = "Env_Tac_Utils" );
  structure PSGraph = 
  PSGraphFun(structure Graph = Graph structure Graph_Utils = Graph_Utils structure Env_Tac_Utils = Env_Tac_Utils);
  (*structure PSComb = PSCombFun (structure PSGraph = PSGraph)*)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure TextSocket = TextSocket_FUN (structure Prover = IsaProver);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal 
                                     structure TextSocket = TextSocket
                                     val gui_socket_port = 1790
                                     val prover_socket_port = 0);
 *}

ML{* open Env_Tac_Utils  *}
ML_file "../../provers/Isabelle/psgraph_isar_method.ML"       
end
