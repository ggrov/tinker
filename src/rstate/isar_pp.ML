signature ISAR_PP = 
sig
    val init_from_ctxt_i : Proof.context -> Term.term -> PPlan.T
    val init_from_pst : Proof.state -> PPlan.T
    val init_from_str :  Proof.context -> string * string -> PPlan.T
    val init_from_term : Proof.context -> string * Term.term -> PPlan.T
    val init_lemma :
       IntNames.namebase * string ->
       PPlan.T -> PPlan.T -> IntNames.name * PPlan.T
    val init_lemma_i :
       (
       (IntNames.name -> PScript.T) ->
       IntNames.namebase * (IntNames.name -> PScript.T)) * Term.term ->
       PPlan.T -> PPlan.T -> IntNames.name * PPlan.T
    val init_rst : Theory.theory -> string * string -> RState.T
    val init_rst_from_ctxt_i : Proof.context -> Term.term -> RState.T
    val init_rst_from_pst_i : Proof.state -> RState.T
    val init_rst_i : Theory.theory -> string * Term.term -> RState.T

    val gaps_in : PPlan.T -> Thm.cterm list
    val export_thm_of : PPlan.T -> Thm.thm

    val apply_dmeth : IsarLang.Apply.T -> PPlan.T -> PPlan.T
    val assumes : (bstring * Term.term) list -> PPlan.T -> PPlan.T
    val assumes_wattr :
       ((bstring * Term.term) * DAttrib.T list) list ->
       PPlan.T -> PPlan.T
    val by_dmeth : IsarLang.By.E.T -> PPlan.T -> PPlan.T
    val done : PPlan.T -> PPlan.T
    val fix_args :
       (string list * Term.typ option) list -> PPlan.T -> PPlan.T
    val fix_term_params : Term.term -> PPlan.T -> PPlan.T
    val fix_topgoal_params : PPlan.T -> PPlan.T
    val from : xstring list -> PPlan.T -> PPlan.T
    val by_gap : PPlan.T -> PPlan.T
    val global_qed : IsarLang.GlobalQed.E.T -> PPlan.T -> PPlan.T
    val have_named_term : bstring * Term.term -> PPlan.T -> PPlan.T
    val hence_named_term : bstring * Term.term -> PPlan.T -> PPlan.T
    val local_qed : IsarLang.LocalQed.E.T -> PPlan.T -> PPlan.T
    val next : PPlan.T -> PPlan.T
    val note : xstring list -> PPlan.T -> PPlan.T
    val note_wattr :
       (xstring * DAttrib.T list) list -> PPlan.T -> PPlan.T
    val proof_dmeth : IsarLang.IsarProof.E.T -> PPlan.T -> PPlan.T
    val proof_triv : PPlan.T -> PPlan.T
    val qed : IsarLang.Qed.E.T -> PPlan.T -> PPlan.T
    val show_term : Term.term -> PPlan.T -> PPlan.T
    val isarthen : PPlan.T -> PPlan.T
    val thus_term : Term.term -> PPlan.T -> PPlan.T
    val pretty : PPlan.T -> Pretty.T
    val pretty_and_indent_ps : PScript.T -> Pretty.T
    val pretty_w_pst : PPlan.T -> Pretty.T
    val print_w_pst : PPlan.T -> unit

end;

structure IsarPP 
: ISAR_PP
= struct

local open PPlan; in 

(* constructor functions for starting a new proof plan. These use
Isar's multi_theorem, and so we have an internal (_i), term based
version, and a user string based version. *)
fun init_from_term ctxt (n,t) = 
    init_with_script
      (IsarLang.Theorem.E.mkplan n
         (IsarLang.Theorem.mk_init_theorem_i ctxt (n, t)));

fun init_from_str ctxt (n,s) = 
    init_with_script 
      (IsarLang.Theorem.E.mkplan n
         (IsarLang.Theorem.mk_init_theorem ctxt (n, s)));

(* starting from inside another Isar proof  *)
fun init_from_pst pst = 
    init_with_script 
      (IsarLang.Theorem.E.mkplan "ignoredname"
         (IsarLang.Theorem.mk_init_from_pst_i pst));

(* with lemmas in proof planning *)
fun init_lemma_i (nf,t) pp = 
    start_lemma_with_scriptf 
    (nf
       (fn n => IsarLang.Theorem.E.mkplan (IntNames.string_of n)
                  (IsarLang.Theorem.mk_init_lemma_i 
                     (ProofContext.init (top_theory_of pp)) 
                     (IntNames.string_of n, t))));

fun init_lemma (nf,s) pp = 
    start_lemma_with_scriptf 
    (nf,
     (fn n => IsarLang.Theorem.E.mkplan (IntNames.string_of n)
                (IsarLang.Theorem.mk_init_lemma 
                   (ProofContext.init (top_theory_of pp)) 
                   (IntNames.string_of n, s))));

(* create a local thm within a proof context from a term and the context 
   This if for integration with Isar proofs *)
fun init_from_ctxt_i ctxt t = 
    init_with_script 
      (IsarLang.Theorem.E.mkplan "ignoredname"
         (IsarLang.Theorem.mk_init_from_ctxt_i ctxt t));


(* adds a fake: qed, which names the theorem, 
   (and stops anything else from happening?). *)
fun global_qed dmethopt = 
    update_script
      (IsarLang.GlobalQed.E.addstep  
         (IsarLang.GlobalQed.of_dmeth_opt dmethopt))


(* General qed, acts appropriately dependening on where it is used *)
fun qed dmethopt = 
    update_script
      (IsarLang.Qed.E.addstep  
         (IsarLang.Qed.of_dmeth_opt dmethopt))
  
(* adds:
apply (dmeth)
*)
(* implicit pp *)
fun apply_dmeth dmeth = 
    update_script 
      (IsarLang.Apply.E.addstep  
         (IsarLang.Apply.of_named_meth dmeth));

(* adds: done *)
(* implicit pp *)
val done =
    update_script (IsarLang.Done.E.addstep ());

(* adds: qed dmeth *)
(* implicit pp *)
fun local_qed dmethopt = 
    update_script
      (IsarLang.LocalQed.E.addstep  
         (IsarLang.LocalQed.of_dmeth_opt dmethopt));

(* adds:
proof (dmeth)
*)
(* implicit pp *)
fun proof_dmeth dmeth = 
    update_script
    (IsarLang.IsarProof.E.addstep  
       (IsarLang.IsarProof.of_named_meth dmeth));

(* adds "proof -" *)
(* implicit pp *)
val proof_triv = 
    update_script 
      (IsarLang.IsarProof.E.addstep  
         (IsarLang.IsarProof.of_named_meth IsarMeths.Triv.trivmeth));

(* adds: by (dmeth) *)
(* implicit pp *)
fun by_dmeth dmeth = 
    update_script 
      (IsarLang.By.E.addstep  
         (IsarLang.By.of_named_meth dmeth));

(* General qed, acts appropriately dependening on where it is used 
   same as "by gap"
*)
val by_gap = by_dmeth (GapTac.dmeth NONE);
(*    update_script
      (IsarLang.GoalGap.E.addstep  
         (IsarLang.GoalGap.gap)); *)


(* 
given args to fix in form vs : (string list * typ option) list
adds:
  fix s1 : "ty1"
  and s2 : "ty2"
  and ...
  and sn : "tyn"
*)
(* implicit pp *)
fun fix_args [] = I
  | fix_args vs = 
    update_script
      (IsarLang.Fix.E.addstep  
         (IsarLang.Fix.fix_i vs));

(* fixes all params in term - to be used with goalterms_of *)
fun fix_term_params t pp = 
    (case Logic.strip_params t
     of [] => pp
      | _ =>  update_script
                (IsarLang.Fix.E.addstep  
                   (IsarLang.Fix.fix_params (top_ctxt_of pp) t)) pp);

fun fix_topgoal_params pp= 
    (case top_goalterms_of pp of 
       [] => raise pplan_exp "fix_topgoal_params: no goals"
     | (h :: t) => 
       (case Logic.strip_params h 
         of [] => pp
          | _ => update_script
                   (IsarLang.Fix.E.addstep  
                      (IsarLang.Fix.fix_params (top_ctxt_of pp) h)) pp));


(*
l: (string * term) list
adds: 
assume s1: "t1"
   and s2: "t2" 
   and ... 
   and sn: "tn"
*)
(* implicit pp *)
fun assumes [] = I
  | assumes l = 
    update_script
      (IsarLang.Assume.E.addstep  
         (IsarLang.Assume.assume_named_terms l));

fun assumes_wattr [] = I
  | assumes_wattr l = 
    update_script
      (IsarLang.Assume.E.addstep  
         (IsarLang.Assume.assume_named_terms_wattr l));

(* adds: next *)
(* implicit pp *)
val next = update_script (IsarLang.Next.E.addstep ());

(* adds: then *)
(* implicit pp *)
val isarthen = update_script (IsarLang.Then.E.addstep ());

(* adds: show "t" *)
(* implicit pp *)
fun show_term t =
    update_script
      (IsarLang.Show.E.addstep 
         (IsarLang.Show.show_term t));

(* adds: thus "t" *)
(* implicit pp *)
fun thus_term t =
      update_script 
        (IsarLang.Thus.E.addstep 
         (IsarLang.Thus.thus_term t));

(* adds: hence n: "t" *)
(* implicit pp *)
fun hence_named_term (n,t) =
    update_script
      (IsarLang.Hence.E.addstep 
         (IsarLang.Hence.hence_named_term (n,t)));

(* adds: have n: "t" *)
(* implicit pp *)
fun have_named_term (n,t) =
    update_script
      (IsarLang.Have.E.addstep 
         (IsarLang.Have.have_named_term (n,t)))

(* adds: from strs *)
(* implicit pp *)
fun from [] = I
  | from strs = 
    update_script
      (IsarLang.From.E.addstep  
         (IsarLang.From.from_names strs))


(* adds: note strs *)
(* implicit pp *)
fun note [] = I
  | note strs = 
    update_script
      (IsarLang.Note.E.addstep  
         (IsarLang.Note.note_names strs))

fun note_wattr [] = I
  | note_wattr strs_w_attr = 
    update_script
      (IsarLang.Note.E.addstep  
         (IsarLang.Note.note_names_atts strs_w_attr))

(* returns a pretty list of the steps, but indented according to
rules... we use foldr to start from teh back of the list, and we use
pairing of pretty blocks to make sure we print the first things first,
not last! *)
fun pretty_and_indent_ps ps = 
    let 
      val psteps = (PScript.stepsl_of ps)

      (* indenting function, keeps track to current indent and also
      the current pretty script... for use with foldr*)
      fun ind_auxf (el,(ind, lb, script)) = 
          let 
            val k = PScript.kind_of_step el
          in
            ((if (k = IsarLang.IsarProof.E.kind) orelse 
                 (k = IsarLang.Have.E.kind) orelse 
                 (k = IsarLang.Hence.E.kind) orelse 
                 (k = IsarLang.Next.E.kind) 
              then (ind + 2)
              else if (k = IsarLang.By.E.kind) orelse 
                      (k = IsarLang.LocalQed.E.kind)
              then (ind - 2)
              else ind), 
             (if (k = IsarLang.From.E.kind) then 
                false else true), 
             (if lb then Pretty.chunks 
                           [script, (Pretty.indent ind (snd (PScript.pretty_step el)))]
              else 
                Pretty.block [script, (Pretty.indent ind (snd (PScript.pretty_step el)))]
            ))
          end
    in #3 (foldr ind_auxf (0,true,Pretty.block []) psteps) end;

(* Pretty printing *)
fun pretty pp = 
    Pretty.chunks ((map pretty_and_indent_ps (lemmas_of pp)) @ 
                  [pretty_and_indent_ps (script_of pp)]);


fun pretty_w_pst pp = 
    Pretty.chunks [pretty pp, 
                   Pretty.str "-----",
                   Pretty.chunks (Proof.pretty_state 0 (top_pst_of pp))];
val print_w_pst = Pretty.writeln o pretty_w_pst;

(* collect all the gaps in proof planning *)
fun gaps_in pp = 
    let val steps = PScript.stepsl_of (PPlan.script_of pp)
    in
      Library.flat 
      (Library.mapfilter
        (fn s => case IsarLang.By.E.data_of s 
                  of NONE => NONE
                   | SOME dm => 
                     if DMethod.kind_of dm = GapTac.I.kind then
                       SOME (map (fst o GapTac.gap_of_term 
                                             (Proof.theory_of 
                                                (PScript.pst_of_step s)))
                                    (PScript.goalterms_of_step s))
                     else
                       NONE)
        steps)
    end;

fun export_thm_of pp = 
    Drule.implies_intr_list (gaps_in pp) (PPlan.top_thm_of pp);

(* we don't know about the rst yet. *)
(* 
fun pretty_term_from_rst rst t =  
    pretty_term (RState.get_pplan rst) t; *)

(*
fun rawstring_of_term pp t = 
    Pretty.string_of (rawpretty_term pp t);
val string_of_term = rawstring_of_term;
val string_of_term = rawstring_of_term;
*)

(*     Sign.string_of_term (Theory.sign_of (theory_of pp)) t;  *)
(* string of a term in the proof plan, uses Isar language translation... *)
(* fun string_of_term pp t = 
    IsarLang.string_of_term_in_ctxt ((Proof.context_of o top_pst_of) pp) t;
*)

  (* RState constructors for Isar proof plans *)
  fun init_rst_i thy (n,t) = 
      let val ctxt = ProofContext.init thy in
        RState.init_with_pp_from_thy thy (init_from_term ctxt (n,t))
      end;
  fun init_rst thy (n,s) = 
      let val ctxt = ProofContext.init thy in
      RState.init_with_pp_from_thy thy (init_from_str ctxt (n,s))
      end;
(* this is just for faking that we are proof planning inside an
   existing proof attempt. *)
  fun init_rst_from_ctxt_i ctxt t = 
      RState.init_with_pp_from_ctxt ctxt (init_from_ctxt_i ctxt t);
  fun init_rst_from_pst_i pst = 
      RState.init_with_pp_from_ctxt (Proof.context_of pst)
                                    (init_from_pst pst);

end (* local *)

end;
