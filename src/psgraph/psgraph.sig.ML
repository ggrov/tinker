(* contains the data structure for a proof strategy graph *)
signature PS_GRAPH =
sig
  structure Theory : PS_THEORY 

  type T

  val empty : T
  val of_graph : Theory.Graph.T -> T

  (* get methods *)
  val get_graph : T -> Theory.Graph.T
  val get_graph_tactics : T -> (Theory.Graph.T list) StrName.NTab.T
  val get_atomic_tactics : T -> Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T

  (* set methods *)
  val set_graph : Theory.Graph.T -> T -> T
  val set_graph_tactics : (Theory.Graph.T list) StrName.NTab.T -> T -> T
  val set_atomic_tactics : Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T -> T -> T

  (* update methods *)
  val update_graph : (Theory.Graph.T -> Theory.Graph.T) -> T -> T
  val update_graph_tactics : ((Theory.Graph.T list) StrName.NTab.T 
                                  -> (Theory.Graph.T list) StrName.NTab.T) 
                              -> T -> T
  val update_atomic_tactics : (Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T 
                                -> Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T) 
                              -> T -> T

  (* fresh name generation *)
  val fresh_name : T -> StrName.name -> StrName.name
  
  (* load a list of atomics *)
  val load_atomics : (StrName.NTab.name * Theory.Data.GoalTyp.Prover.tactic) list -> T -> T

end
