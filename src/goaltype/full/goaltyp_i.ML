(* BASIC GOAL TYPE which is used for graph *)

functor GoalTypIFun (structure GoalTyp : GOAL_TYP 
                         structure Atomic : ATOMIC
                         structure GoalTypJson : GOALTYP_JSON
                         structure GoalTypMatch : GOALTYP_MATCH
                         sharing GoalTyp.Sharing = GoalTypJson.Sharing.GoalTyp
                         sharing GoalTypMatch.Sharing.GoalTyp = GoalTypJson.Sharing.GoalTyp
                         sharing Atomic.Sharing = GoalTypMatch.Sharing.Atomic) = 
struct
  structure Atomic = Atomic
  structure GoalTyp = GoalTyp
  structure Class = GoalTyp.Class
  structure Link = GoalTyp.Link

  type T = GoalTyp.T
  type gnode = GNode.T
   
  val default = GoalTyp.top
  val default_gnode = GNode.mk_goal_no_facts "default_gnode"

  val ord = GoalTyp.ord
  val eq = GoalTyp.eq

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
  val pretty = GoalTyp.pretty

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

(* for full goal type *)
  val get_name = GoalTyp.get_name
  val get_link = GoalTyp.get_link
  val get_facts = GoalTyp.get_facts
  val get_gclass = GoalTyp.get_gclass
  val set_name = GoalTyp.set_name
  val set_link = GoalTyp.set_link
  val set_facts = GoalTyp.set_facts
  val set_gclass = GoalTyp.set_gclass


  structure FullSharing = 
  struct
    structure Link = GoalTyp.Sharing.Link
    structure Class = GoalTyp.Sharing.Class
  end

  structure BasicSharing = 
  struct
    type T = T
    type gnode = gnode
  end

(* to remove*)

  fun lookup_fact_names _ _ = NONE 
  fun get_fact_names _ _ = StrName.NSet.empty 

end;



