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
structure GoalTyp_I = GoalTypIFun (structure GoalTyp = GoalTyp
                                          structure Atomic : ATOMIC = BIsaAtomic
                                          structure GoalTypJson : GOALTYP_JSON = GoalTypJson
                                          structure GoalTypMatch : GOALTYP_MATCH = GoalTypMatch);
structure BasicGoalTyp : BASIC_GOALTYPE = GoalTyp_I
structure FullGoalTyp : FULL_GOAL_TYP = GoalTyp_I

structure Theory = PSTheoryFun(structure GoalTyp = BasicGoalTyp);
structure PSGraph = PSGraphFun(structure PSTheory = Theory
                               structure Atomic = BIsaAtomic);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = BIsaAtomic
                           structure PSGraph = PSGraph);
structure EVal = EValFun(EData);
