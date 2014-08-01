signature BASIC_GOALTYPE_SHARING =
sig
  type T
  type gnode
  type data
end

(* BASIC GOAL TYPE which is used for graph *)
signature BASIC_GOALTYPE = 
sig
  structure Prover : PROVER
  type T
  type gnode
  type data
   
  val default : T
  val default_gnode : gnode
  val default_data : data

  val eq : (T * T) -> bool
  val gnode_eq : (gnode * gnode) -> bool
  val goal_name : gnode -> string
  (* data_eq ?? *)

  val gnode_to_json : Prover.context -> gnode -> Json.json 
  val gnode_from_json : Prover.context -> Json.json -> gnode 

  val data_to_json : Prover.context -> data -> Json.json
  val data_from_json : Prover.context -> Json.json -> data

  val to_json : Prover.context -> T -> Json.json 
  val from_json : Prover.context -> Json.json -> T 

  val pretty_gnode : Prover.context -> gnode -> Pretty.T
  val pretty_data : Prover.context -> data -> Pretty.T
  val pretty : Prover.context -> T -> Pretty.T

  (* for evaluation *)
  val lift :  gnode -> data * T -> Prover.pnode -> gnode option
  val init_lift :  data * T -> Prover.pnode -> gnode option

  structure BasicSharing : BASIC_GOALTYPE_SHARING
    sharing type BasicSharing.T = T
    sharing type BasicSharing.gnode = gnode
    sharing type BasicSharing.data = data    
end;



