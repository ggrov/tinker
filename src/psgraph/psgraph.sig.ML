signature PS_GRAPH_SHARING = 
sig
  type T
  structure Theory: PS_THEORY_SHARING
end

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
  val get_goaltype_data : T -> Theory.Data.GoalTyp.data
  val get_parents: T -> (StrName.NTab.name) StrName.NTab.T

  (* set methods *)
  val set_graph : Theory.Graph.T -> T -> T
  val set_graph_tactics : (Theory.Graph.T list) StrName.NTab.T -> T -> T
  val set_atomic_tactics : Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T -> T -> T
  val set_goaltype_data :  Theory.Data.GoalTyp.data -> T -> T
  val set_parents : (StrName.NTab.name) StrName.NTab.T -> T -> T

  (* update methods *)
  val update_graph : (Theory.Graph.T -> Theory.Graph.T) -> T -> T
  val update_graph_tactics : ((Theory.Graph.T list) StrName.NTab.T 
                                  -> (Theory.Graph.T list) StrName.NTab.T) 
                              -> T -> T
  val update_atomic_tactics : (Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T 
                                -> Theory.Data.GoalTyp.Prover.tactic StrName.NTab.T) 
                              -> T -> T
  val update_goaltype_data :  (Theory.Data.GoalTyp.data -> Theory.Data.GoalTyp.data)
                              -> T -> T
  val update_parents : ((StrName.NTab.name) StrName.NTab.T -> (StrName.NTab.name) StrName.NTab.T)
                       -> T -> T

  (* fresh name generation *)
  val fresh_name : T -> StrName.name -> StrName.name
  
  (* merger two psgraph by add merging all the subfields, exception would be raised when duplicated nodes are found*)
  val merge_disjoint : T -> T -> T

  (* load a list of atomics *)
  val load_atomics : (StrName.NTab.name * Theory.Data.GoalTyp.Prover.tactic) list -> T -> T

  (* json i/o *)
  val output_json : T -> Json.json
  val output_json_as_eval_field : T -> Json.json
  val input_json : Json.json -> T
  val write_json_file : string -> T -> unit

  structure Sharing: PS_GRAPH_SHARING
    sharing type Sharing.T = T
    sharing Sharing.Theory = Theory.Sharing
end
