(* 
  to be implemented for a prover
 *)
signature PROVER_SHARING =
sig
  type typ
  type term 
  type thm
  type context
  type tactic

  type pplan
  type pnode
end

signature PROVER =
sig
  type typ
  type term 
  type thm
  type context
  type tactic 

  type pplan
  type pnode
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  datatype arg_data =  Str of string | Trm of term | Thm of thm

  exception gterm_exp
  
  val default_ctxt : context (* used in those place need context in general *)
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val trm_of_string : context -> string -> term
  val string_of_trm : context -> term -> string
  val pretty_trm : context -> term -> Pretty.T

  val concl_of_thm : thm -> term
  val asms_of_thm : thm -> term list

  val init : context -> term list -> term -> pnode * pplan

  val apply_tactic : arg_data list -> tactic -> appf

  (* pnode related *)
  val get_open_pnodes : pplan -> pnode list
  val get_pnode_name : pnode -> string
  val get_pnode_concl : pnode -> term (* return type concl which would be type term*)
  val get_pnode_ctxt : pnode -> context

  (* pretty printing *)
  val pretty_pplan : pplan -> Pretty.T
  val pretty_pnode : pnode -> Pretty.T
  
  structure Sharing : PROVER_SHARING
    sharing type Sharing.typ = typ
    sharing type Sharing.term = term 
    sharing type Sharing.thm = thm
    sharing type Sharing.context = context
    sharing type Sharing.tactic = tactic 

    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode

end;

