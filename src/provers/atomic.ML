signature ATOMIC =
sig
  type fact
  type tactic 
  type pplan
  type pnode

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  (* FIXME: also need to add name for export! *)


  (* we assume that prf contains the necessary context if required *)
  val apply_rule : string -> fact -> appf
  val apply_erule : string -> fact -> appf
  (* first assumption, next rule *)
  val apply_frule : (string * fact) -> (string * fact)  -> appf
  val apply_subst : string -> fact -> appf
  (* first assumption, second the equality rule *)
  val apply_subst_asm : (string * fact) -> (string * fact) -> appf
  val apply_tactic : string -> fact list -> tactic -> appf

  val lookup_fact : pnode -> string -> fact option
  val get_all_facts : pnode -> fact list

  val get_pnode_name : pnode -> string
  
end;

