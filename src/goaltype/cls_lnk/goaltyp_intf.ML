(* BASIC GOAL TYPE which is used for graph *)

functor BasicGoalTyp (structure GNode : GNODE
                      structure GoalTyp : GOAL_TYP
                      structure GoalTypMatch : GOALTYP_MATCH
                      structure GoalTypJson : GOALTYP_JSON): BASIC_GOALTYPE = 
structure
  type T = GoalTyp.T
  type gnode = Gnode.T
   
  val default = GoalTyp.top
  val default_gnode : gnode

  val ord = GoalTyp.ord
  val eq = GoalTyp.eq

  val gnode_ord = GNode.ord
  val gnode_eq = GNode.eq

  val goal_name = GNode.get_goal

(*
  val lookup_fact_names : C.name -> gnode -> StrName.NSet.T option
  val get_fact_names : C.name -> gnode -> StrName.NSet.T 
*)

  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val to_json : T -> Json.json 
  val from_json : Json.json -> T 

  val pretty_gnode : gnode -> Pretty.T
  val pretty : T -> Pretty.T

(* for evaluation *)

  val match : context -> gnode -> T -> bool
  val lift :  gnode -> T -> pnode -> bool
  val init_lift :  T -> pnode -> bool

(* for type checking *)

(*
 val is_subtyp : T -> T -> order option 
 val is_orthogonal : T -> T -> bool
 val is_equal : T -> T -> bool 
*)

end;



