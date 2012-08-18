(* 
 This should be stored somewhere, maybe even part of the reasoning state, thus replacing continuation?
 will provide information about the current evaluation.

*)
structure EvalCtxt =
struct
  structure RTab = NameTabFun(RTechn_Theory.Rule);

  datatype T = {
    rst : RState.T,
    enabled : V.name list, (* generalise? - or rule name?? *)   
    graph : RTechnComb.graph,
    cont : RState.T RTab, (* maps a rule to the continuation rstate *)
    critics : unit, (* to rewrite graphs? *)
    apprules : RTechn_Theory.Ruleset.T
    nested : RTechn_Theory.Ruleset.T
  }

  
end
