theory TinkeringRodinClause


imports   "../../build/isabelle/Tinker"      
begin  

 -- "the goaltype"
ML_file "../../../goaltype/clause/goaltype.ML"   

ML_file "../../interface/text_socket.ML"

ML_file "./interface/wsock.sig.ML"
ML_file "./interface/json_protocol.sig.ML"
ML_file "./interface/tpp_protocol.sig.ML"

ML_file "./build/unicode_helper.ML"
ML_file "./build/predicate_tag.ML"
ML_file "./build/rodin_socket.struct.ML"
ML_file "./build/rodin_json_protocol.struct.ML"
ML_file "./build/rodin_protocol.ML"

ML_file "./rodin_prover.ML"

ML_file "../../goaltype/simple_goaltype.ML"

ML_file "simpleGT_lib.ML"


ML{*
  structure Clause_GT : BASIC_GOALTYPE = ClauseGTFun(structure Prover = Rodin val struct_name = "Clause_GT");
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
ML{*  open Env_Tac_Lib SimpleGT_Lib *}

end
