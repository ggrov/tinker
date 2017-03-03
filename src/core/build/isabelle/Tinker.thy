(* JSON protocal and comnumnication interfaces with the tinker GUI *)
theory Tinker                                                                                                                                                                                           
imports           
  Graph                                                                       
begin
 (* socket communication for the tinker gui *)
 ML_file "../../interface/text_socket.ML"
 ML_file "../../interface/tinker_protocol.ML"
                                                                                                                     

 -- "the prover"  
 ML_file "../../provers/Isabelle/isa_prover.ML"                              

   
ML{*
  structure Clause_GT = ClauseGTFun(structure Prover = IsaProver val struct_name = "Clause_GT");
  structure Data = PSGraphDataFun(Clause_GT);
  structure Graph = Graph(Data);

val path = "/Users/yuhuilin/Desktop/scratch.psgraph";
val path2 = "/Users/yuhuilin/Desktop/scratch2.psgraph";

val str1  = File_Io.read_string path 
val str2 =  Json.of_string str1 |> Graph.from_json |> Graph.to_json |> Json.encode;
str1 = str2;
 
*}   
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
  structure TextSocket = TextSocket_FUN (structure Prover = IsaProver);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal 
                                     structure TextSocket = TextSocket
                                     val gui_socket_port = 1790
                                     val prover_socket_port = 0);
 *}

ML{* open Env_Tac_Utils  *}
ML_file "../../provers/Isabelle/psgraph_isar_method.ML"       
end
