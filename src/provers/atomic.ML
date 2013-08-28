signature ATOMIC_SHARING =
sig
  type fact
  type tactic 
  type pplan
  type pnode
  type context
  type concl
  type assm
end

signature ATOMIC =
sig
  type fact
  type tactic 
  type pplan
  type pnode
  type context
  type concl
  type assm

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  val psgraph_prover_i : string (* a hack to fix muli-matching in graph rewriting *)

  (* could also make an init version with assumptions? *)
  val init : context -> concl -> pnode * pplan
  val init_with_assm : context -> assm list -> concl -> pnode * pplan

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
  val get_all_assms : pnode -> fact list
  val get_all_named_facts_pair : pnode -> (string * fact) list

  val get_open_pnodes : pplan -> pnode list
  val get_pnode_name : pnode -> string
  (*  TODO: can we give the pplan as arguments as well on these? *)
  (* What does this do? is this specific for one particular goal type? *)
  val get_pnode_concl : pnode -> concl (* return type concl which would be type term*)
  val get_pnode_ctxt : pnode -> context
  val pretty_concl : pnode -> Pretty.T
  val intf_pprint : Pretty.T -> unit

  structure Sharing : ATOMIC_SHARING
    sharing type Sharing.fact = fact
    sharing type Sharing.tactic = tactic
    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode
    sharing type Sharing.context = context
    sharing type Sharing.concl = concl
    sharing type Sharing.assm = assm
   
end;

