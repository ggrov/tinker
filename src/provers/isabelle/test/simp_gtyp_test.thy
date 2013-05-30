theory simp_gtyp_test      
imports                   
  "../../basic_isabelle/build/BIsaP"  

  uses "../../../goaltype/simple/gnode.ML"
       "../../../goaltype/goaltyp_data.ML"
       "../../match_param.ML"
       "../../../goaltype/link.ML"
       "../../../goaltype/class.ML"
       "../../../goaltype/simple/goaltyp_json.ML"  
       "../../../goaltype/simple/goaltyp_match.ML"
begin
ML{*
Pretty.str o G.string_of_name;
G.name_ord;
G.name_eq
*}
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

