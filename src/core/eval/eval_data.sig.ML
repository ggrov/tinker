signature EVAL_DATA_SHARING =
sig
  type branch
  type active
  type T
  type gnode
  structure PSGraph : PS_GRAPH_SHARING
end

signature EVAL_DATA =
sig 
  structure PSGraph : PS_GRAPH

  type branch
  type active
  type T

  type gnode = PSGraph.Graph.Data.GoalTyp.gnode
   (* initialisation *)
  val init : 
    PSGraph.T 
    -> PSGraph.Graph.Data.GoalTyp.Prover.pplan 
    -> PSGraph.Graph.Data.GoalTyp.Prover.pnode StrName.NTab.T 
    -> gnode list
    -> T

  (* get methods *)
  val get_psgraph : T -> PSGraph.T  
  val get_pplan : T -> PSGraph.Graph.Data.GoalTyp.Prover.pplan
(*  val get_goals : T -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T *)
  val get_gnodes : T -> gnode list
  val get_searchf : T -> string
  val get_evalf : T -> string
  val get_graph : T -> PSGraph.Graph.T
  val get_current : T -> branch
  val get_branches : T -> branch list
  val get_parent : T -> (StrName.NTab.name * int) StrName.NTab.T
  val get_name_current_hie: T -> (StrName.NTab.name* V.name) list
  val get_name_current: T -> StrName.NTab.name * V.name
  val get_index_current : T -> int 
  val get_main_current : T -> StrName.NTab.name

  (* more get methods *)
  val lookup_goal : T -> string -> PSGraph.Graph.Data.GoalTyp.Prover.pnode option
(*  val get_goal : T -> string -> PSGraph.Theory.Data.GoalTyp.Prover.pnode *)
(*  val lookup_tactic : T ->  StrName.NTab.name -> PSGraph.Theory.Data.GoalTyp.Prover.tactic option
  val get_tactic : T ->  StrName.NTab.name -> PSGraph.Theory.Data.GoalTyp.Prover.tactic *)

  (* set methods *)
  val set_psgraph : PSGraph.T -> T -> T
  val set_pplan : PSGraph.Graph.Data.GoalTyp.Prover.pplan -> T -> T
(*  val set_goals : PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T -> T -> T *)
  val set_gnodes : gnode list -> T -> T
  val set_searchf : string -> T -> T
  val set_evalf : string -> T -> T
  val set_graph : PSGraph.Graph.T -> T -> T
  val set_current : branch -> T -> T
  val set_branches : branch list -> T -> T

  (* update methods *)
  val update_psgraph : (PSGraph.T -> PSGraph.T) -> T -> T
  val update_pplan : (PSGraph.Graph.Data.GoalTyp.Prover.pplan -> PSGraph.Graph.Data.GoalTyp.Prover.pplan) -> T -> T
  val update_goals : (PSGraph.Graph.Data.GoalTyp.Prover.pnode StrName.NTab.T -> PSGraph.Graph.Data.GoalTyp.Prover.pnode StrName.NTab.T)  -> T -> T
  val update_gnodes : (gnode list -> gnode list) -> T -> T
  val update_searchf : (string -> string) -> T -> T
  val update_evalf : (string -> string) -> T -> T
  val update_current : (branch -> branch) -> T -> T
  val update_branches : (branch list -> branch list) -> T -> T
  val update_parent : ((StrName.NTab.name * int) StrName.NTab.T -> (StrName.NTab.name * int) StrName.NTab.T) -> T -> T
(*
  val add_goals : PSGraph.Theory.Data.GoalTyp.Prover.pnode list -> T -> T
  val add_bgoals : PSGraph.Theory.Data.GoalTyp.Prover.pnode list -> branch -> branch
  val pop_cur_hie : T -> T
  val push_cur_hie : StrName.NTab.name -> T -> T
*)
  (* methods for branches *)
  val get_bactive : branch -> active
  val get_bpplan : branch -> PSGraph.Graph.Data.GoalTyp.Prover.pplan
(*  val get_bgoals : branch -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T *)

  val set_bactive : active -> branch -> branch 
  val set_bpplan : PSGraph.Graph.Data.GoalTyp.Prover.pplan -> branch -> branch
  val set_bgoals : PSGraph.Graph.Data.GoalTyp.Prover.pnode StrName.NTab.T -> branch -> branch
 
  val set_bgnodes : gnode list -> branch -> branch
  val get_bgnodes : branch -> gnode list
  val set_bsearchf : string -> branch -> branch
  val get_bsearchf : branch -> string
  val set_bevalf : string -> branch -> branch
  val get_bevalf : branch -> string

  val update_bparent : ((StrName.NTab.name * int) StrName.NTab.T  -> (StrName.NTab.name * int) StrName.NTab.T )
                        -> branch -> branch
  val set_bparent : (StrName.NTab.name * int) StrName.NTab.T -> branch -> branch
  val get_bparent : branch -> (StrName.NTab.name * int) StrName.NTab.T

  val pop_bcur_hie : branch -> branch
  val push_bcur_hie : StrName.NTab.name * V.name -> branch -> branch

  val get_bgraph : branch -> PSGraph.Graph.T 
  val set_bgraph : PSGraph.Graph.T -> branch -> branch
  val get_bgraph_gen : StrName.NTab.name -> int -> branch -> PSGraph.Graph.T 
  val get_bgraphs_gen : StrName.NTab.name -> branch -> PSGraph.Graph.T list
  val set_bgraph_gen : StrName.NTab.name -> int -> PSGraph.Graph.T -> branch -> branch

  val update_bname_current_hie : ((StrName.NTab.name * V.name) list  -> (StrName.NTab.name * V.name) list)  -> branch -> branch
  val set_bname_current_hie : (StrName.NTab.name* V.name) list -> branch -> branch
  val get_bname_current_hie : branch ->  (StrName.NTab.name* V.name) list
  val get_bname_current : branch ->  StrName.NTab.name* V.name
  val update_bindex_current : (int -> int) -> branch -> branch
  val set_bindex_current : int -> branch -> branch
  val get_bindex_current : branch -> int

  
  val update_bactive : (active -> active) -> branch -> branch 
  val update_bpplan : (PSGraph.Graph.Data.GoalTyp.Prover.pplan
                       -> PSGraph.Graph.Data.GoalTyp.Prover.pplan)
                      -> branch -> branch
(*   val update_bgoals : (PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T 
                      -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T)
                      -> branch -> branch
 *)
  (* push and pop methods for parent *)
  val next_branch : T -> (branch * T) option (* moves to next branch *)
  
  val pretty_goals : T -> Pretty.T

  structure Sharing : EVAL_DATA_SHARING
    sharing type branch = Sharing.branch
    sharing type active = Sharing.active
    sharing type T = Sharing.T
    sharing type gnode = Sharing.gnode
    sharing Sharing.PSGraph = PSGraph.Sharing

end (* signature *)
