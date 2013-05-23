(* BASIC GOAL TYPE which is used for graph *)

signature BASIC_GOALTYPE = 
sig

  type T
  type gnode
   
  val default : T
  val default_gnode : gnode

  val ord : (T * T) -> order (* just for printing? *)
  val eq : (T * T) -> bool

  val gnode_ord : (gnode * gnode) -> order
  val gnode_eq : (gnode * gnode) -> bool

  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val gnode_to_json : T -> Json.json 
  val gnode_from_json : Json.json -> T 

(* for evaluation *)
(*
  val match : context -> gnode -> T -> bool
  val lift : context -> gnode -> T -> pnode -> bool
  val init_lift : context -> T -> pnode -> bool
*)

(* for type checking *)
 val is_subtyp : T -> T -> order option (* NONE means non_compareble, SOME false means supertyp *)
 val is_orthogonal : T -> T -> bool
 val is_equal : T -> T -> bool (* yes should mean that is_sybtyp in both directions *)


end;



