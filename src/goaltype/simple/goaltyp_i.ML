(* BASIC GOAL TYPE which is used for graph *)

functor BasicGoalTypFun (structure Atomic : ATOMIC
                      structure GoalTypJson : GOALTYP_JSON
                      structure GoalTypMatch : GOALTYP_MATCH
                      sharing Atomic.Sharing = GoalTypMatch.Sharing.Atomic) : BASIC_GOALTYPE = 
struct
  structure Atomic = Atomic

  type T = G.name
  type gnode = GNode.T
   
  val default = G.mk "default"
  val default_gnode = GNode.mk_goal (G.mk "top") "default_gnode"

  val ord = G.name_ord
  val eq = G.name_eq

  val gnode_ord = GNode.ord
  val gnode_eq = GNode.eq

  val goal_name = GNode.get_goal

(*
  val lookup_fact_names : C.name -> gnode -> StrName.NSet.T option
  val get_fact_names : C.name -> gnode -> StrName.NSet.T 
*)

  val gnode_to_json = GoalTypJson.gnode_to_json
  val gnode_from_json = GoalTypJson.gnode_from_json

  val to_json = GoalTypJson.to_json
  val from_json = GoalTypJson.from_json

  val pretty_gnode = GNode.pretty
  val pretty = Pretty.str o G.string_of_name

(* for evaluation *)

  val match = GoalTypMatch.match
  val lift = GoalTypMatch.lift
  val init_lift = GoalTypMatch.init_lift

(* for type checking *)

(*
 val is_subtyp : T -> T -> order option 
 val is_orthogonal : T -> T -> bool
 val is_equal : T -> T -> bool 
*)

(* to remove*)

  fun lookup_fact_names _ _ = NONE 
  fun get_fact_names _ _ = StrName.NSet.empty 


end;



