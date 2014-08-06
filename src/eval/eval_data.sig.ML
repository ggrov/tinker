signature EVAL_DATA =
sig 
  (* add sharing constraints *)
  structure PSGraph : PS_GRAPH

  type branch
  type active
  type T

  type gnode = PSGraph.Theory.Data.GoalTyp.gnode
   (* initialisations *)
  val init : 
    PSGraph.T 
    -> PSGraph.Theory.Data.GoalTyp.Prover.pplan 
    -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T 
    -> gnode list
    -> T

  (* get methods *)
  val get_psgraph : T -> PSGraph.T  
  val get_pplan : T -> PSGraph.Theory.Data.GoalTyp.Prover.pplan
  val get_goals : T -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T
  val get_gnodes : T -> gnode list
  val get_searchf : T -> string
  val get_evalf : T -> string
  val get_graph : T -> PSGraph.Theory.Graph.T
  val get_current : T -> branch
  val get_branches : T -> branch list


  (* more get methods *)
  val lookup_goal : T -> string -> PSGraph.Theory.Data.GoalTyp.Prover.pnode option
  val get_goal : T -> string -> PSGraph.Theory.Data.GoalTyp.Prover.pnode
  val lookup_tactic : T -> string -> PSGraph.Theory.Data.GoalTyp.Prover.tactic option
  val get_tactic : T -> string -> PSGraph.Theory.Data.GoalTyp.Prover.tactic

  (* set methods *)
  val set_psgraph : PSGraph.T -> T -> T
  val set_pplan : PSGraph.Theory.Data.GoalTyp.Prover.pplan -> T -> T
  val set_goals : PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T -> T -> T
  val set_gnodes : gnode list -> T -> T
  val set_searchf : string -> T -> T
  val set_evalf : string -> T -> T
  val set_graph : PSGraph.Theory.Graph.T -> T -> T
  val set_current : branch -> T -> T
  val set_branches : branch list -> T -> T

  (* update methods *)
  val update_psgraph : (PSGraph.T -> PSGraph.T) -> T -> T
  val update_pplan : (PSGraph.Theory.Data.GoalTyp.Prover.pplan -> PSGraph.Theory.Data.GoalTyp.Prover.pplan) -> T -> T
  val update_goals : (PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T)  -> T -> T
  val update_graph : (PSGraph.Theory.Graph.T -> PSGraph.Theory.Graph.T) -> T -> T
  val update_gnodes : (gnode list -> gnode list) -> T -> T
  val update_searchf : (string -> string) -> T -> T
  val update_evalf : (string -> string) -> T -> T
  val update_current : (branch -> branch) -> T -> T
  val update_branches : (branch list -> branch list) -> T -> T

  val add_goals : PSGraph.Theory.Data.GoalTyp.Prover.pnode list -> T -> T
  val add_bgoals : PSGraph.Theory.Data.GoalTyp.Prover.pnode list -> branch -> branch


  (* methods for branches *)
  val get_bactive : branch -> active
  val get_bpplan : branch -> PSGraph.Theory.Data.GoalTyp.Prover.pplan
  val get_bgoals : branch -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T

  val set_bactive : active -> branch -> branch 
  val set_bpplan : PSGraph.Theory.Data.GoalTyp.Prover.pplan -> branch -> branch
  val set_bgoals : PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T -> branch -> branch
 
  val set_bgnodes : gnode list -> branch -> branch
  val get_bgnodes : branch -> gnode list
  val set_bsearchf : string -> branch -> branch
  val get_bsearchf : branch -> string
  val set_bevalf : string -> branch -> branch
  val get_bevalf : branch -> string

  val get_bgraph : branch -> PSGraph.Theory.Graph.T 
  val set_bgraph : PSGraph.Theory.Graph.T -> branch -> branch

  val update_bactive : (active -> active) -> branch -> branch 
  val update_bpplan : (PSGraph.Theory.Data.GoalTyp.Prover.pplan
                       -> PSGraph.Theory.Data.GoalTyp.Prover.pplan)
                      -> branch -> branch
  val update_bgoals : (PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T 
                      -> PSGraph.Theory.Data.GoalTyp.Prover.pnode StrName.NTab.T)
                      -> branch -> branch

  (* push and pop methods for parent *)
  val parent_lhs : T -> PSGraph.Theory.Graph.T option
  val pop_active : T -> T (* identify if it fails *)
  val push_active : PSGraph.Theory.Graph.T -> PSGraph.Theory.Graph.T -> gnode list -> T -> T

  val pop_bactive : branch -> branch (* identify if it fails *)
  val push_bactive : PSGraph.Theory.Graph.T -> PSGraph.Theory.Graph.T -> gnode list -> branch -> branch

  val next_branch : T -> (branch * T) option (* moves to next branch *)
  
  val pretty_goals : T -> Pretty.T


end (* signature *)
