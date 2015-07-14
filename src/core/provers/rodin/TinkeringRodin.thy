theory TinkeringRodin
imports       
  "../../build/isabelle/Tinker"                                                                               
begin 

(* TODO: move rodin prover here *)
ML_file "./interface/unicode_helper.ML"
ML_file "./interface/rodin_socket.ml"
ML_file "./interface/interface.ML" 
ML_file "./rodin_prover.ML"
ML_file "./interface/rodin_extra.ML"
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
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);
  structure Env_Tac_Lib = EnvTacLibFunc (Theory);
*}

ML{*  open Env_Tac_Lib  *}

end

