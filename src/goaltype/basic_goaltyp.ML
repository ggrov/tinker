(* BASIC GOAL TYPE which is used for graph *)

signature BASIC_GOALTYPE = 
sig

  type T
  type gnode
   
  val default : T
  val default_gnode : T

  val ord : (T * T) -> order
  val eq : (T * T) -> bool

  val gnode_ord : (T * T) -> order
  val gnode_eq : (T * T) -> bool

(*
  val match : context -> gnode -> T -> bool
  val lift : context -> gnode -> T -> pnode -> bool
  val init_lift : context -> T -> pnode -> bool
*)

end;



