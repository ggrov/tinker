signature ATOMIC_SHARING =
sig
  type fact
  type tactic 
  type pplan
  type pnode
  type context
  type concl
end

signature ATOMIC =
sig
  type fact
  type tactic 
  type pplan
  type pnode
  type context
  type concl

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
  val get_all_name_facts : pnode -> (string * fact) list

  val get_pnode_name : pnode -> string
  (*  TODO: can we give the pplan as arguments as well on these? *)
  (* What does this do? is this specific for one particular goal type? *)
  val get_pnode_concl : pnode -> concl (* note that if the goal is A, then this will return A => A or [...] => A*)
  val get_pnode_ctxt : pnode -> context

  structure Sharing : ATOMIC_SHARING
    sharing type Sharing.fact = fact
    sharing type Sharing.tactic = tactic
    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode
    sharing type Sharing.context = context
    sharing type Sharing.concl = concl
end;

