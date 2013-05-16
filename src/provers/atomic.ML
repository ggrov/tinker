signature ATOMIC =
sig
  type fact
  type tactic 
  type pplan
  type pnode

  type appf = pplan * pnode -> (pplan * pnode list) Seq.seq

  (* we assume that prf contains the necessary context if required *)
  val apply_erule : fact -> appf
  val apply_frule : fact -> fact -> appf
  val apply_subst : fact -> appf
  val apply_subst_fact : fact -> fact -> appf
  val apply_tactic : fact list -> tactic -> appf

  val lookup_fact : string -> pnode -> fact option
  val get_all_facts : pnode -> fact list

  val get_pnode_name : pnode -> string
  
end;

