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
       "../../../goaltype/simple/goaltyp_i.ML"
       "../isa_match_param.ML"
begin

ML{*
structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (IsaProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = IsaProver);
structure MatchParam = IsaMatchParamFun (structure GoalTypData = GoalTypData
                                         structure Prover = IsaProver )
structure GoalTypMatch = GoalTypMatchFun (structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = IsaProver
                                         structure Atomic = BIsaAtomic
                                         structure MatchParam = MatchParam);
structure BasicGoalTyp = BasicGoalTypFun (structure Atomic = BIsaAtomic
                                          structure GoalTypMatch =  GoalTypMatch
                                          structure GoalTypJson = GoalTypJson); 

*}

