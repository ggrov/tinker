structure IsaEVal  =
struct 

functor EData(structure Atomic : ATOMIC
              structure PSGraph : PS_GRAPH
              sharing type Atomic.tactic = PSGraph.tactic) : EVAL_DATA  =

  structure EData = EDataFun(structure Atomic = IsaAtomic
                             structure PSGraph 
  structure Eval = EValFun(EData);

end
