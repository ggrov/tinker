signature BASIC_GOALTYPE_SHARING =
sig
  type T
  type gnode
  type data
  type gtyp
  structure Prover : PROVER_SHARING
end

(* BASIC GOAL TYPE which is used for graph *)
signature BASIC_GOALTYPE = 
sig
  structure Prover : PROVER

  type T
  type gnode
  type data
  type gtyp
  structure GoalTyp_ML_Exec : ML_EXEC
  sharing type GoalTyp_ML_Exec.ret_typ = gtyp
   
  val default : T
  val default_gnode : gnode
  val default_data : data

  val eq : (T * T) -> bool
  val gnode_eq : (gnode * gnode) -> bool
  val goal_name : gnode -> string
  (* data_eq ?? *)

  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val data_to_json : data -> Json.json
  val data_from_json : Json.json -> data

  val to_json : T -> Json.json 
  val from_json : Json.json -> T 

  val pretty_gnode : gnode -> Pretty.T
  val pretty_data :  data -> Pretty.T
  val pretty :  T -> Pretty.T
  
  val check : data * T -> (gnode option * Prover.pnode) -> bool
  val match :  data -> Prover.pnode -> T -> Prover.env -> Prover.env list
  val lift : Prover.pnode -> gnode
  (* val init_lift :  data * T -> Prover.pnode -> gnode list *)

  structure BasicSharing : BASIC_GOALTYPE_SHARING
    sharing type BasicSharing.T = T
    sharing type BasicSharing.gnode = gnode
    sharing type BasicSharing.data = data    
    sharing type BasicSharing.gtyp = gtyp    
    sharing BasicSharing.Prover = Prover.Sharing
end;



