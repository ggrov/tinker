theory TinkeringRodin


imports   "../../build/isabelle/Tinker"      
begin  


ML_file "../../interface/text_socket.ML"

ML_file "./interface/wsock.sig.ML"
ML_file "./interface/json_protocol.sig.ML"
ML_file "./interface/tpp_protocol.sig.ML"

ML_file "./build/unicode_helper.ML"
ML_file "./build/rodin_socket.struct.ML"
ML_file "./build/rodin_json_protocol.struct.ML"
ML_file "./build/rodin_protocol.ML"

ML_file "./rodin_prover.ML"

ML_file "../../goaltype/simple_goaltype.ML"

ML{*
  structure SimpleGoalType : BASIC_GOALTYPE = SimpleGoalType_Fun(structure Prover = RodinProver val struct_name = "SimpleGoalType");
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

ML{*  open Env_Tac_Lib  *}

end
