(* This interface is used for implement instructive protocol for all Third party prover that 
 * wants to use tinker and is not based on ML.

 * The implemented structure will be used by tinker prover directly. All the functions implemented
 * here is called by Tinker. The aim of this interface is to integret json protocol and sock protocol
 * out side the tinker structure to make them transparent to Tinker.  
 * tpp_protocol = Thrid Party Prover Protocol
 *)

signature TPP_PROTOCOL =
sig
  (* Proof node *)
  type pnode

  (* Proof plan, used to initiate the proof *)
  type pplan

  (* Type that describe a tactic, for third party prover, it is usually string*)
  type tactic
  
  (* Type that specify the context of a term *)
  type context

  (* Type of the arguments when applying tactic*)
  type arg
  type arg_data

  type typ
  (* Initialise the proof , obtain the proof plan to start *)
  (* In use for Rodin only: the pplan is the first node to start, as the open node
   * user selected in Rodin *)
  val prover_name : string   

  (* Match two terms given context information *)
  val match :  context -> string * string -> bool

  val initialise : unit -> pplan
  
  (* Get all open nodes starting with pplan *)
  val get_all_open_nodes : pplan -> pnode list


  (* Apply a tactic on a proof node with given pplan with arguments
  *)
  val apply_tactic : arg_data list list -> tactic -> pnode -> pnode list
  
  (* Type of a term, prover should return the type representation of this term *)
  val typ_of : string -> string

end
