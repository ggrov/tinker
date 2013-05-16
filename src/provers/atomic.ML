signature ATOMIC =
sig
  type fact
  type tactic 
  type pplan
  type pnode

  type appf = pplan * pnode -> (pplan * pnode list) Seq.seq

  (* we assume that prf contains the necessary context if required *)
  val apply_rule : fact -> appf
  val apply_erule : fact -> appf
  (* first assumption, next rule *)
  val apply_frule : fact -> fact -> appf
  val apply_subst : fact -> appf
  (* first assumption, second the equality rule *)
  val apply_subst_asm : fact -> fact -> appf
  val apply_tactic : fact list -> tactic -> appf

  val lookup_fact : pnode -> string -> fact option
  val get_all_facts : pnode -> fact list

  val get_pnode_name : pnode -> string
  
end;

