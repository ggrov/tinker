(* simple test of combinators *)
theory comb_test                                              
imports               
 "../build/GoalTyp"                                                                  
  uses  "../isa_prover.ML" "../../basic_isabelle/isa_atomic.ML" "../isa_match_param.ML" (* "../isa_setup.ML"*)
begin
ML{*
structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (IsaProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = IsaProver);
structure GoalTyp = GoalTypFun(structure Link = Link structure Class = Class);
structure GoalTypJson = GoalTypJsonFun  (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = IsaProver);
structure MatchParam = IsaMatchParamFun (structure GoalTypData = GoalTypData
                                         structure Prover = IsaProver )
structure GoalTypMatch = GoalTypMatchFun (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = IsaProver
                                         structure Atomic = BIsaAtomic
                                         structure MatchParam = MatchParam);
structure BasicGoalTyp = BasicGoalTypFun (structure GoalTyp = GoalTyp
                                          structure Atomic : ATOMIC = BIsaAtomic
                                          structure GoalTypJson : GOALTYP_JSON = GoalTypJson
                                          structure GoalTypMatch : GOALTYP_MATCH = GoalTypMatch)
*}

ML{*
structure Theory = PSTheoryFun(structure GoalTyp = BasicGoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Atomic = BIsaAtomic);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = BIsaAtomic
                           structure PSGraph = PSGraph);
*}

ML{*
structure EVal = EValFun(EData);
*}   

ML{*
 val impI = RTechn.id
           |> RTechn.set_name (RT.mk "impI")
           |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"))
*}
ML{*
  val psfg1 = PSComb.LIFT ([GoalTyp.top],[GoalTyp.top]) (impI)
  val psfg2 = PSComb.LIFT ([GoalTyp.top],[GoalTyp.top]) (RTechn.id)
  val psfg3 = PSComb.THENG (psfg1,psfg2);
*}

ML{*
 RTechnJSON.rtechn_to_json RTechn.id
  |> Json.pretty
  |> Pretty.writeln;
*}

ML{*
  val ps = psfg3 PSGraph.empty;
  val g = PSGraph.get_graph ps;
*}

ML{*
 Theory.PS_TheoryIO.OutputGraphJSON.output g
  |> Json.pretty
  |> Pretty.writeln;
*}




end



