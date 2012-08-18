(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./base/pplan.ML
    Author:     Moa Johansson, University of Edinburgh
                moa.johansson@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    New representation of Proof-plans using non-Isar representation 
    for more flexibility.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature PPLAN = 
sig
  
  type T
  type gname = Prf.gname

  (* conjecturing *)
  val conj_term_in_cx_of : gname * Term.term -> gname -> T -> gname * T
  val conj_string_in_cx_of : gname * string -> gname -> T -> gname * T
  val conj_term_at_top : gname * Term.term -> T -> gname * T
  val conj_string_at_top : gname * string -> T -> gname * T

  (* basic operations *)
  val apply_res_bck 
      : gname (* conclusion *)
        -> gname (* goal *)
        -> T -> (gname list * T) Seq.seq (* subgoals *)
  val apply_res_fwd 
      : (gname * gname) (* assumption of conclusion *)
        -> gname (* use this to remove assumption *)
        -> T -> ((gname list (* subgoals *)
                  * gname) (* new factname *)
                 * T) Seq.seq (* - *)

  val apply_rule_thm : Thm.thm -> gname -> T -> (gname list * T) Seq.seq
  val apply_frule_thm : Thm.thm -> gname -> T -> (gname * T) Seq.seq
  val apply_erule_thm : Thm.thm -> gname -> gname -> T -> (gname list * T) Seq.seq

  val apply_subst_at : 
      gname (* equation result *)
      -> gname (* goal or result or assumption *)
      -> Zipper.T (* zipper on goal for where to subst *)
      -> T -> ((gname (* new result with subst applied *)
                * gname list) (* new subgoals from application *)
               * T) Seq.seq 



  (* creation *)
  val init : Proof.context -> T
  val init_from_thry : Context.theory -> T

  (* gets *)
  val get_theory : T -> Context.theory  
  val get_context : T -> Proof.context
  val set_context : Proof.context -> T -> T
  val update_context : (Proof.context -> Proof.context) -> T -> T

  val get_prf : T -> Prf.T
  val get_ienv : T -> InstEnv.T

  val get_all_results_tab : T -> Prf.nd Goaln.NTab.T
  val get_all_results_set : T -> Goaln.NSet.T
  val get_opengoals : T -> Goaln.NSet.T

  (* reading terms *) 
  val read_term : T -> string -> Term.term
  val read_prop : T -> string -> Term.term

  (* instantiation *)
  val inst : InstEnv.T -> T -> T

  (* assumptions *)
  val has_asm: T -> gname -> bool
  val has_new_asm : T -> gname list -> gname -> bool
  val new_asms : T -> gname list -> gname -> gname list

  val get_aasms: T -> gname -> gname list
  val get_lasms: T -> gname -> gname list
  val get_aasmtrms: T -> gname -> (gname * Term.term) list
  val get_lasmtrms: T -> gname -> (gname * Term.term) list

  val get_varified_ltrm : T -> gname -> Term.term

  val get_varified_aasm_natrms: T -> gname -> (gname * Term.term) list
  val get_varified_lasm_natrms: T -> gname -> (gname * Term.term) list

  val get_varified_lasm_nltrms: T -> gname -> (gname * Term.term) list

(*   val get_varified_aasm_nctrms: T -> gname -> (gname * Term.term) list *)
  val get_varified_lasm_nctrms: T -> gname -> (gname * Term.term) list

  (* properties *)
  val solved_all_goals_chk : T -> bool


  (* pretty *)
  val pretty_term : T -> Term.term -> Pretty.T 
  val pretty_gname : gname -> Pretty.T
  val pretty : T -> Pretty.T
  val print : T -> unit

end;

(* structure for non-Isar Proof Plans *)
structure PPlan 
: PPLAN 
= struct

(* This should be sorted at some point I guess...should make PPlan a functor.*)

type T = Prf.T;
type gname = Prf.gname;

(* New proof-plan from a theory *)
fun init context = Prf.init context;
fun init_from_thry thry = init (ProofContext.init_global thry);

val get_prf = I;
val get_theory = Prf.get_theory;
val get_context = Prf.get_context;
val get_ienv = Prf.get_ienv;

val set_context = Prf.set_context;
val update_context = Prf.update_context;

(* reading termsa from strings *)
val read_term = Prf.read_top_term;
val read_prop = Prf.read_prop;

(* instantiate *)
val inst = Prf.inst_prf;

(* Add a new top-level goal *)
(* we automatically change outer frees to params *)
val conj_term_at_top = Prf.conj_term_at_top;
val conj_string_at_top = Prf.conj_string_at_top;
val conj_term_in_cx_of = Prf.conj_term_in_cx_of;
val conj_string_in_cx_of = Prf.conj_string_in_cx_of;

(* Get assumptions as (gname,term). *)
val get_aasms = Prf.get_ndname_aasms;
val get_lasms = Prf.get_ndname_lasms;
val get_aasmtrms = Prf.get_ndname_aasm_ntrms;
val get_lasmtrms = Prf.get_ndname_lasm_ntrms;

val get_varified_aasm_natrms = Prf.get_ndname_varified_aasm_natrms;
val get_varified_lasm_nltrms = Prf.get_ndname_varified_lasm_nltrms;
val get_varified_lasm_natrms = Prf.get_ndname_varified_lasm_nltrms;

(* val get_varified_aasm_nctrms = Prf.get_ndname_varified_aasm_nctrms; *)
val get_varified_lasm_nctrms = Prf.get_ndname_varified_lasm_nctrms;
val get_all_results_tab = Prf.get_goals;
val get_all_results_set = Goaln.NTab.get_nameset o get_all_results_tab;
val get_opengoals = Prf.get_open_gnames;

val get_varified_ltrm = Prf.get_ndname_varified_ltrm;

(* val get_asm_thms = 
    Thm.assume (Prf.get_goal_asms); *)

(*Check if the specified goal has any assumptions*)
fun has_asm ppl gname = (not o null) (get_lasms ppl gname);

fun has_new_asm ppl old_asms gname = 
    let 
      val current_asms = (get_lasms ppl gname)
    in 
      (List.length current_asms) > (List.length old_asms)
    end;

(* get the assumptions of the goal,
excluding those names in the list old_asms *)
fun new_asms ppl old_asms gname = filter (fn a => not(TermConstLib.mem (a,old_asms))) 
                                         (get_lasms ppl gname)


fun solved_all_goals_chk ppl = Goaln.NSet.is_empty
                                 (Prf.get_open_gnames ppl)

(* Apply a declarative tactic to a goal *)
val apply_res_bck = Prf.apply_resol_bck;
val apply_res_fwd = Prf.apply_resol_fwd;

val apply_rule_thm = Prf.apply_rule_thm;
val apply_frule_thm = Prf.apply_frule_thm;
val apply_erule_thm = Prf.apply_erule_thm;

val apply_subst_at = Prf.apply_subst;

fun pretty_term pplan t = Syntax.pretty_term (get_context pplan) t
fun pretty pplan = Prf.pretty pplan;
fun print pplan = Prf.print pplan;
val pretty_gname = Prf.pretty_gname;
end;
