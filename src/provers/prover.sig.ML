(* 
  to be implemented for a prover
 *)
signature PROVER_SHARING =
sig
  type pos
  type typ
  type term 
  type thm
  type context
  type tactic

  type fact
  type concl
  type pplan
  type pnode
  type Object
end

signature PROVER =
sig
(* [] for root, digit n for the nth branch  *)
  type pos
  type typ
  type term 
  type thm
  type context
  type tactic 


  type fact
  type concl
  type pplan
  type pnode
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  datatype Object =  Fact of fact | Concl of concl

  exception gterm_exp
  
  val current_ctxt : context (* used in those place need context in general *)
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val eq_pos : (pos * pos) -> bool
  val intlist_of_pos : pos -> int list
  val pos_of_intlist : int list -> pos

  val root_of_trm : term -> term
  val trm_of_pos : pos -> term -> term 
  val subtrm_of_pos : pos -> term -> term

  (*val trm_of_thm : thm -> term*)
  (*val consts_of_trm : term -> term list  return ops ?? duplicated ops allowed*)
 
  val trm_of_string : context -> string -> term
  val string_of_trm : context -> term -> string
  val pretty_trm : context -> term -> Pretty.T

  val concl_of_thm : thm -> term
  val asms_of_thm : thm -> term list


  val psgraph_prover_i : string (* a hack to fix muli-matching in graph rewriting *)

  (* could also make an init version with assumptions? *)
  val init : context -> term -> pnode * pplan
  val init_with_assm : context -> term list -> term -> pnode * pplan

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
  
 (* val get_goal : context -> T ->  (context * term)*)
  
  structure Sharing : PROVER_SHARING
    sharing type Sharing.pos = pos
    sharing type Sharing.typ = typ
    sharing type Sharing.term = term 
    sharing type Sharing.thm = thm
    sharing type Sharing.context = context
    sharing type Sharing.tactic = tactic 

    sharing type Sharing.fact = fact
    sharing type Sharing.concl = concl
    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode
    sharing type Sharing.Object = Object
end;

