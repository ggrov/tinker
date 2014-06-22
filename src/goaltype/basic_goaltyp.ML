signature BASIC_GOALTYPE_SHARING =
sig
  type T
  type gnode
end

(* BASIC GOAL TYPE which is used for graph *)
signature BASIC_GOALTYPE = 
sig
  structure Prover : PROVER
  type T
  type gnode
   
  val default : T
  val default_gnode : gnode

  val eq : (T * T) -> bool
  val gnode_eq : (gnode * gnode) -> bool
  val goal_name : gnode -> string

  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val to_json : T -> Json.json 
  val from_json : Json.json -> T 

  val pretty_gnode : gnode -> Pretty.T
  val pretty : T -> Pretty.T

(* for evaluation *)

  (* val match : gnode -> T -> Prover.pnode -> bool *)

  val lift :  gnode -> T -> Prover.pnode -> gnode option
  val init_lift :  T -> Prover.pnode -> gnode option

(* To be removed *)
  val lookup_fact_names : C.name -> gnode -> StrName.NSet.T option
  val get_fact_names : C.name -> gnode -> StrName.NSet.T 

  structure BasicSharing : BASIC_GOALTYPE_SHARING
    sharing type BasicSharing.T = T
    sharing type BasicSharing.gnode = gnode
    
end;



