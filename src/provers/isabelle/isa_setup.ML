
structure GTData : GT_DATA = GTDataFun (IsaProver);
structure Class : CLASS = ClassFun (GTData);
structure Link : LINK = LinkFun(Class);
structure GoalTyp = GoalTypFun(Link);
structure Theory = PSTheoryFun(GoalTyp);
structure PSGraph = PSGraphFun(Theory);
structure PSComb = PSCombFun(PSGraph);
structure EData = EDataFun(structure Atomic = IsaAtomic
                           structure PSGraph = PSGraph);
structure EVal = EValFun(EData);
