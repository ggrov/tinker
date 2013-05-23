
structure GoalTypData : GOALTYP_DATA = GoalTypDataFun (IsaProver);
structure Class : CLASS = ClassFun (GoalTypData);
structure Link : LINK = LinkFun(structure GoalTypData = GoalTypData structure Prover = IsaProver);
structure GoalTyp = GoalTypFun(structure Link = Link structure Class = Class);

structure GoalTypJson = GoalTypJsonFun  (structure GoalTyp: GOAL_TYP = GoalTyp
                                         structure Link : LINK = Link
                                         structure Class : CLASS = Class
                                         structure GoalTypData : GOALTYP_DATA = GoalTypData
                                         structure Prover : PROVER = IsaProver);

structure Theory = PSTheoryFun(structure GoalTyp = GoalTyp
                               structure GoalTypJson = GoalTypJson);
structure PSGraph = PSGraphFun(Theory);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = IsaAtomic
                           structure PSGraph = PSGraph);
structure EVal = EValFun(EData);
