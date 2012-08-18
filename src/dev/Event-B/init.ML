
structure EB_Init =
struct

  (* adapted with no_wdss *)
   fun unlift_thm ctxt th = 
    let
      val context = Context.Proof ctxt
      val ((_, ths), ctxt') = Variable.import true [th] ctxt
      val th' = hd ths
      fun export th = Variable.export ctxt' ctxt [th] |> hd
    in
      th' |>
      asm_full_simplify (Eb_Pre_Simp.ss context) |>
      full_simplify (Eb_Trans_Simp1.ss context) |>
      full_simplify (Eb_Trans_Simp2.ss context) |>
      full_simplify (Eb_Post.ss context) |>
      export |>
      Drule.zero_var_indexes
    end;

  fun unfold_thm defs ctxt = Local_Defs.unfold ctxt defs;

 (* make it stable so it doesn't fail on the empty list of defs! *)
 fun unlift_unfold_thm defs ctxt = unfold_thm defs ctxt #> unlift_thm ctxt;

  fun get_unlifted_goal_term_from_gctxt thm_list gctxt =
    let
      fun visible_facts facts =
        Facts.dest_static [] facts
        |> filter_out (Facts.is_concealed facts o #1);
    in
      gctxt
      |> (hd o snd o hd o visible_facts o ProofContext.facts_of)
      |> unlift_unfold_thm thm_list gctxt
      |> Thm.prop_of
    end;

  (*construct a term of implication with given list of terms*)
  fun mk_implies_list_rl [] = Logic.true_prop
    | mk_implies_list_rl trms = foldr1  Logic.mk_implies trms;

 (*get a list of hyps terms and goal term to make a new term which used => as connectivity*)
  fun mk_goal_term_for_rippling thm_list hyps_ctxt goal_term =
    let 
      fun visible_facts facts = Facts.dest_static [] facts
                              |> filter_out (Facts.is_concealed facts o #1);
      fun flatten [] = []
       |  flatten (x::xs) = x @ flatten xs;
      fun trans_hyps_thm thm = unlift_unfold_thm thm_list hyps_ctxt thm |> Thm.prop_of;
      val hyps_term_list     = (visible_facts o ProofContext.facts_of) hyps_ctxt
                              |> map snd
                              |> flatten
                              |> map trans_hyps_thm (*unlifted hyps term list*)
                              |> rev (*in a right order*);
    in
      hyps_term_list @ [goal_term] |> mk_implies_list_rl
  end;

  fun init_rst_from_locale thm_list locale_sub_str thy (wire,gf) = 
    let
      val eb_goal_ctxt = Locale.init (locale_sub_str ^ "_goal") thy;
      val hyps_ctxt = Locale.init (locale_sub_str ^ "_hyps") thy;
      val goal_term_ori = get_unlifted_goal_term_from_gctxt thm_list eb_goal_ctxt;
      val goal_term = goal_term_ori |> mk_goal_term_for_rippling thm_list hyps_ctxt
      val thy' = Proof_Context.theory_of hyps_ctxt
    in
     RTechnEval.init thy' (RTechnEval.TermGoals [goal_term]) wire gf
    end;

end (* struct *)

(* structure (RTechn_EventB : RTECHN_EVENTB) = RTechn_EventB_DB *)
