signature PS_GRAPH_SHARING = 
sig
  type T
  type graph_tacs
  type atomic_tacs
  type env_tacs
  type occurences
  structure Graph: GRAPH_SHARING
end

(* contains the data structure for a proof strategy graph *)
signature PS_GRAPH =
sig
  structure Graph : GRAPH 
  structure Env_Tac_Utils : ENV_TAC_UTILS
  structure Graph_Utils : GRAPH_UTILS
   sharing Graph.Sharing = Graph_Utils.Sharing.Graph
   sharing Graph.Sharing = Env_Tac_Utils.Sharing.Graph

  type T
  type graph_tacs
  type atomic_tacs  
  type env_tacs
  type occurences
  exception tactic_exp of string

  val empty : T
  val of_graph : StrName.NTab.name -> Graph.T -> T

  (* get methods *)
  val get_top_graph : T -> Graph.T
  val get_graph_tactics : T -> graph_tacs StrName.NTab.T
  val get_atomic_tactics : T -> atomic_tacs StrName.NTab.T
  val get_env_tactics : T -> env_tacs StrName.NTab.T
  val get_graph : T -> StrName.NTab.name -> int -> Graph.T
  val get_graphs : T -> StrName.NTab.name -> Graph.T list
  val get_goaltype_data:  T ->  Graph.Data.GoalTyp.data

  val get_occurs : T -> occurences
  val get_main : T -> StrName.NTab.name
  val get_atomic_tac_by_name : T -> StrName.NTab.name -> Graph.Data.GoalTyp.Prover.tactic
  val get_atomic_env_tac_by_name : T -> StrName.NTab.name -> Graph.Data.GoalTyp.Prover.env_tac
(* set methods *)
  val set_top_graph : Graph.T -> T -> T
  val set_graph_tactics : graph_tacs StrName.NTab.T -> T -> T
  val set_atomic_tactics : atomic_tacs StrName.NTab.T  -> T -> T  
  val set_env_tactics : env_tacs StrName.NTab.T  -> T -> T  
  val set_graph :  StrName.NTab.name -> int -> Graph.T -> T -> T
  val set_occurs : occurences -> T -> T
  val set_goaltype_data: Graph.Data.GoalTyp.data -> T -> T
 
 (* update methods *)
  val update_goaltype_data: (Graph.Data.GoalTyp.data -> Graph.Data.GoalTyp.data)
                            -> T -> T
  val update_graph_tactics : (graph_tacs StrName.NTab.T 
                                  -> graph_tacs StrName.NTab.T) 
                              -> T -> T
  val update_atomic_tactics : (atomic_tacs StrName.NTab.T 
                                  -> atomic_tacs StrName.NTab.T) 
                              -> T -> T
  val update_occurs : (occurences -> occurences) -> T -> T
  (* fresh name generation *)
  val fresh_name : T -> StrName.name ->  StrName.NSet.name
  
  (* merger two psgraph by add merging all the subfields, exception would be raised when duplicated nodes are found*)
  val merge_disjoint : StrName.NTab.name -> T -> T -> T

  (* json i/o *)
  val output_json : T -> Json.json
  val output_eval_json : StrName.NTab.name list -> int -> T -> Json.json
  val input_json : bool (*if to reload tac/env tac def*) -> Json.json -> T
  val write_json_file : string -> T -> unit
  val read_json_file : Graph.Data.GoalTyp.data option ->  string -> T
  val from_prover_json : Json.json -> Json.json
  val to_prover_json : Json.json -> Json.json

  val validate_psgraph : T -> bool (* type checking, see issue #44 in the repo *)

  structure Sharing: PS_GRAPH_SHARING
    sharing type Sharing.T = T
    sharing type Sharing.graph_tacs = graph_tacs
    sharing type Sharing.atomic_tacs = atomic_tacs
    sharing type Sharing.env_tacs = env_tacs
    sharing type Sharing.occurences = occurences
    sharing Sharing.Graph = Graph.Sharing
end
