  use "../../../goaltype/simple_goaltype.ML";
     
(* instaintiate functors *) 
  structure SimpleGoalType : BASIC_GOALTYPE = SimpleGoalType_Fun(structure Prover = PPProver val struct_name = "SimpleGoalType");
  structure Data = PSGraphDataFun(SimpleGoalType);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = SimpleGoalType  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory)
  structure Env_Tac_Utils = EnvTacUtilsFunc (structure Theory = Theory val struct_name = "Env_Tac_Utils" );
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO structure Env_Tac_Utils = Env_Tac_Utils);
(*   structure PSComb = PSCombFun (structure PSGraph = PSGraph) *)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);
(* load the library for term manipulation and goal type predicates *)
  use_file "../simpleGT_lib.ML";
  
(* top level inteface for pp *)
  use "../pp_intf.ML"; 
   
  open Env_Tac_Utils PPProver 


