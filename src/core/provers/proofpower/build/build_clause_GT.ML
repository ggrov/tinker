(* clause goaltyp *)
 use "../../../goaltype/clause/goaltype.ML";
     
(* instaintiate functors *) 
  structure ClauseGoalTyp = ClauseGTFun(PPProver); 
  structure GT : BASIC_GOALTYPE = ClauseGoalTyp;
  structure Data = PSGraphDataFun(GT);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);
  structure Theory = PSGraph_TheoryFun(structure GoalTyp = GT  
                                     structure Data = Data);
  structure Theory_IO = PSGraph_Theory_IOFun(structure PSTheory = Theory);
  structure PSGraph = PSGraphFun(Theory_IO);
  structure PSComb = PSCombFun (structure PSGraph = PSGraph)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (structure IEVal = IEVal val gui_socket_port = 1790 val prover_socket_port = 0);
  structure Env_Tac_Lib = EnvTacLibFunc (Theory);

  use "../pp_intf.ML"; 

