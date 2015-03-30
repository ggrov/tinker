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
  PSGraph.empty;
  structure PSComb = PSCombFun (structure PSGraph = PSGraph)
  structure EData =  EDataFun( PSGraph);
  structure EVal = EValFun(EData);
  structure IEVal = InteractiveEvalFun (EVal);
  structure Tinker = TinkerProtocol (IEVal);  

  use "../pp_intf.ML"; 

(* enable the subgoal package printing *)
  reset_flag "subgoal_package_quiet";
  new_pc "zed_psgraph";
  set_pc "zed_psgraph";
