(* BASIC GOAL TYPE which is used for graph *)

signature BASIC_GOALTYPE = 
sig
  structure Atomic : ATOMIC
  type T
  type gnode
   
  val default : T
  val default_gnode : gnode

  val ord : (T * T) -> order (* just for printing? *)
  val eq : (T * T) -> bool

  val gnode_ord : (gnode * gnode) -> order
  val gnode_eq : (gnode * gnode) -> bool

  val goal_name : gnode -> string

  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val to_json : T -> Json.json 
  val from_json : Json.json -> T 

  val pretty_gnode : gnode -> Pretty.T
  val pretty : T -> Pretty.T

(* for evaluation *)

  val match : gnode -> T -> Atomic.pnode -> bool
  val lift :  gnode -> T -> Atomic.pnode -> gnode option
  val init_lift :  T -> Atomic.pnode -> gnode option

(* for type checking *)

(*
 val is_subtyp : T -> T -> order option 
 val is_orthogonal : T -> T -> bool
 val is_equal : T -> T -> bool 
*)

(* To be removed *)
  val lookup_fact_names : C.name -> gnode -> StrName.NSet.T option
  val get_fact_names : C.name -> gnode -> StrName.NSet.T 


end;



