structure IsaProver : PROVER =
struct 
  type pos = int list
  type typ = typ
  type term = Term.term  
  type thm = Thm.thm
  type context = Proof.context
  type tactic = context -> tactic
  
  exception gterm_exp

  val current_ctxt = @{context}
  val typ_of = Term.type_of
  fun match ctxt = Pattern.matches (Context.Proof_Context.theory_of ctxt)
  fun eq_pos (pos1, pos2) = 
    let 
      fun if_eq pos1 (x :: xs) = if ( hd pos1 = x) then if_eq (tl pos1) xs else false
        | if_eq _ [] = true
    in 
      if List.length pos1 = List.length pos2 then if_eq pos1 pos2 else false
    end
  fun top_of_trm trm = fst (Term.strip_comb trm)
  fun subtrm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(Term.strip_comb t), x))) (tl  pos) trm
  fun trm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(Term.strip_comb t), x))) (tl pos) trm 
                           |> Term.strip_comb 
                           |> fst;

  (*val trm_of_thm = Thm.prop_of;*)

  val trm_of_string = Syntax.parse_term;
  val string_of_trm = Syntax.string_of_term;
  val pretty_trm = Syntax.pretty_term;

  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
  val asms_of_thm = Thm.prems_of
  val concl_of_thm = Thm.concl_of

  structure Sharing = 
  struct
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
  end
end
