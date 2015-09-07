theory TinkeringRodin


imports   "../../build/isabelle/Tinker"      
begin  
ML_file "../../goaltype/clause/goaltype.sig.ML"                                                                                                                      
ML_file "../../goaltype/clause/goaltype.ML"   

ML_file "../../interface/text_socket.ML"

ML_file "./interface/wsock.sig.ML"
ML_file "./interface/json_protocol.sig.ML"
ML_file "./interface/tpp_protocol.sig.ML"

ML_file "../../unicode_helper.ML"



ML_file "./build/predicate_tag.ML"
ML_file "./build/rodin_socket.struct.ML"
ML_file "./build/rodin_json_protocol.struct.ML"

ML_file "./build/rodin_helper.ML"
ML_file "./build/rodin_protocol.ML"

ML_file "./rodin_prover.ML"

(* 
ML_file "simpleGT_lib.ML" *)

ML{*
  structure Clause_GT : CLAUSE_GOALTYPE = ClauseGTFun(structure Prover = RodinProver val struct_name = "ClauseGoalType");
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
(*   structure Env_Tac_Lib = EnvTacLibFunc (Theory); *)
*}

ML{*(*   open Env_Tac_Lib  *) *}

end
