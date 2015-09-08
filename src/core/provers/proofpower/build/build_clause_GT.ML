(* clause goaltyp *)
 use "../../../goaltype/clause/goaltype.sig.ML";
 use "../../../goaltype/clause/goaltype.ML";
    
(* instaintiate functors *) 
  structure ClauseGoalTyp = ClauseGTFun(structure Prover = PPProver val struct_name = "ClauseGoalTyp"); 
  structure GT : BASIC_GOALTYPE = ClauseGoalTyp;
  structure Data = PSGraphDataFun(GT);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = GT  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory);
  structure Env_Tac_Utils = EnvTacUtilsFunc (structure Theory = Theory val struct_name = "Env_Tac_Utils" );
  structure PSGraph = PSGraphFun(structure Theory_IO = Theory_IO structure Env_Tac_Utils = Env_Tac_Utils);
(*   structure PSComb = PSCombFun (structure PSGraph = PSGraph) *)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);

(* load the library for term manipulation and goal type predicates *)
  use_file "../clasueGT_lib.ML";

  use "../pp_intf.ML"; 

