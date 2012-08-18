(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Rippling with case-splitting and lemma calculation. It will try to prove
    non-rippling goals after splits by simp, or failing that
    lemma calculation.
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

functor RippleCaseSplitCalcFUN (structure BasicRipple : BASIC_RIPPLE)
(* : RIPPLE_LEMCALC *)
= struct

structure RippleCInfo = BasicRipple.RippleCInfo;
local 
  open RTechnEnv;
in

exception rippling_rtechn_exp of string;
structure BasicRipple = BasicRipple;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* End rippling and fertilisation                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
val endr = BasicRipple.endr;
val strong_fert_goal = BasicRipple.strong_fert_goal;
val weak_fert_goal = BasicRipple.weak_fert_goal;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  rst descriptions                                                   *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
fun update_stepN dtac =
    RstName.f (fn rst => 
                  if (RippleCInfo.some_curgoal_is_rippling rst) then 
                    Pretty.chunks 
                      [Pretty.block 
                         [Pretty.str "Ripple Step by ",
                          DTac.pretty dtac (RState.get_ctxt rst)],
                       RippleCInfo.pretty_curgoals_skels rst]
                  else Pretty.chunks 
                         [Pretty.block 
                            [Pretty.str "Ripple Step by ",
                             DTac.pretty dtac (RState.get_ctxt rst)],
                          Pretty.block
                          ((RState.get_goalnames rst)
                            |> map (fn g => (RstPP.goal_concl rst g)
                                              |> PPlan.pretty_term (RState.get_pplan rst)))]);


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Case-splitting                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* solve non-rippling branches by simplification, or lemma calculation. *)
fun solve_by_simp goal rst =  
    let 
       (* force eval *)
      val res =  
          (DTacRTechn.simp_no_asm_simp_changes goal rst)
            |> Seq.map_filter (fn r => if (null (RState.get_goalnames r)) 
                                       then (SOME r) else NONE)
            |> Seq.list_of
    in Seq.of_list res end;

fun solve_by_simp_or_calc lem_techn goal rst = 
    ((solve_by_simp goal)
      try1_orelse 
      (ConjRTechn.prove_goal_by_lemma lem_techn goal))
      rst;

fun is_eq_term t = 
    is_some (Subst.move_to_concl_eq (Zipper.mktop t));

fun subst_all sym asm goal rst = 
    case (Seq.pull (RTechnEnv.subst_eq asm sym goal rst)) of
      NONE => rst
    | SOME (rst2, _) => 
      (case (RState.get_goalnames rst2) of 
         [g] => (subst_all sym asm g rst2)
       | l => (RState.print rst2;
               map PolyML.print l;
               raise ERROR "subst_all: many goal names"));

fun subst_asm sym (asm_nm, asm_trm) goal rst =
    if (is_eq_term asm_trm) then 
      let val lhs = Zipper.trm (Subst.move_to_lhs_of_eq 
                                 (Zipper.mktop asm_trm))
          val rhs = Zipper.trm (Subst.move_to_rhs_of_eq 
                                 (Zipper.mktop asm_trm))
      in 
        if sym then
          if (Pattern.matches_subterm (RstPP.get_theory rst) (rhs, lhs))
          then NONE (* not valid rewrite this way around *)
          else SOME (subst_all sym asm_nm goal rst)
        else
          if (Pattern.matches_subterm (RstPP.get_theory rst) (lhs, rhs))
          then NONE (* not valid rewrite this way around *)
          else SOME (subst_all sym asm_nm goal rst)
      end
    else NONE;

(* returns rst *)
fun subst_asms sym goal rst = 
    let
      (* Note: here we expect asms to be a singleton list
         with only the new assumption introduced by the
         recent split, which has previosuly been set
         to be the result-names of this rst *)
      val asms = 
          map (fn n => (n, RstPP.goal_concl rst n))
              (RState.get_resultnames rst)
    in
      (RState.set_goalnames [goal] rst)
        |> fold (fn a => 
                 fn rst => 
                    (case RState.get_goalnames rst of 
                       [g] => 
                       (case subst_asm sym a g rst 
                         of NONE => rst | SOME rst2 => rst2)
                     | _ => (RState.print rst;
                             raise ERROR "subst_asms: many goal names"))
                ) asms
    end;

fun subst_asm_then_techn g rst = 
    let 
      val rst1 = subst_asms false g rst
      val rst2 = subst_asms true g rst
    in
      Seq.of_list 
      (case filter (fn rst => 
                       case RState.get_goalnames rst of
                         [g2] => not (g2 = g))
                   [rst1,rst2]
        of [] => []
         | l => l)
    end;

fun make_ripple_goal_cinfos_post_split oldgoal newgoal rst = 
   let val rsts =
        (RState.set_goalnames [newgoal] rst)
        |> (RippleCInfo.update oldgoal newgoal)
        |> Seq.list_of
     in 
       if (null rsts) then (Seq.single (RState.set_goalnames [newgoal] rst))
       else Seq.of_list rsts
    end; 


 (* hack cos basic techn are not doing it: 
  set cur_resulnames to be derived asms *)
fun set_new_asm_as_resultnames old_asms g rst = 
    RState.set_resultnames 
      (Goaln.NSet.list_of
         (Goaln.NSet.subtract 
            (Goaln.NSet.of_list
               (RstPP.lasms_of_goal rst g))
            old_asms))
      rst;

(* Perform a case-split on goal, which contain an if/case statement. 
 Then compute cinfo on the result from splitting, note this must be
 done from the oldgoal, which is the goal *before* we applied the
 rule that introduced the if/case. This is because the goal prior
 to split may not be measure decreasing due to extra syntax. *) 
fun case_split split_tech oldgoal goal rst = 
    ((split_tech goal)
       thenfs
       (map_rstseqf (make_ripple_goal_cinfos_post_split oldgoal)))
      rst;

(* re-update the goal to re-find applicable rules in the proof plan
   where the simp step has been previously applied:
   avoids cached proof plan from undoing the simp step. *)
fun check_is_still_ripplestep_techn s dtac oldgoal g = 
    (RippleCInfo.update oldgoal g
     o RState.set_goalnames [g])
      fsthen 
      (dummy 
         (RstName.prepend_block 
            (RstName.str (s ^ "-case split: ")) 
            (BasicRipple.update_stepN dtac)));

(* what to do after you apply a case split *)
fun post_split lem_techn old_asms s dtac oldgoal rst =  
    (split_then (not o (RippleCInfo.is_rippling rst))
                (try_then (map_then 
                             (fn g => 
                                 (set_new_asm_as_resultnames old_asms g)
                                   fthen (subst_asm_then_techn g)
                                   fsthen (map_then (solve_by_simp_or_calc lem_techn))))
                          (map_then (solve_by_simp_or_calc lem_techn)))
                (try_then (map_then 
                             (fn g => 
                                 (set_new_asm_as_resultnames old_asms g)
                                   fthen (subst_asm_then_techn g)
                                   fsthen 
                                   (map_then 
                                      (check_is_still_ripplestep_techn s dtac oldgoal))))
                          (map_then (check_is_still_ripplestep_techn s dtac oldgoal)))
     ) rst;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Ripple Steps                                                       *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

fun maybe_apply_casesplit lem_techn dtac oldg goal rst =
    let val old_asms = Goaln.NSet.of_list (RstPP.lasms_of_goal rst goal)
    in
    if (SplitterRTechn.is_if rst goal) then
      ((case_split SplitterRTechn.split_if_rtechn oldg goal)
         thenr
         (post_split lem_techn old_asms "if" dtac oldg)) rst
    else
      if SplitterRTechn.goal_in_rst_has_cases rst goal then 
        ((case_split SplitterRTechn.split_case_rtechn oldg goal)
           thenr 
           (post_split lem_techn old_asms "case" dtac oldg)) rst
       (* No split needed, just update ripple-cinfo *)
      else ((RippleCInfo.update oldg goal
             o RState.set_goalnames [goal])
              fsthen (dummy (BasicRipple.update_stepN dtac))) rst
    end;


fun do_ripple_step lem_techn goal rst = 
    (RippleCInfo.applicable_dtacseq_of rst goal)
    |> Seq.maps 
    (fn dtac => (* givename (update_stepN dtac) *)
        ((apply_dtac_to_g dtac goal)
           thenr
           (map_then (maybe_apply_casesplit lem_techn dtac goal))) 
          rst);

(* do a valid ripple steps using the wave rules in the wave rule DB.
When we get to a state in which has no following state has a better
out measure, then we know rippling is blocked.  *)
fun stop_or_cont_rippling lem_techn oldrst oldgoal steps_ref rst =
    let val steps = (!steps_ref)
    in 
      case List.find RstPP.solved_focusgoals steps of 
        NONE => 
        let val continue_rsts = 
                Seq.of_list 
                  (map (RState.set_rtechn (SOME (map_then (rsteps_on_goal lem_techn)))) 
                       steps)
        in
          if RippleCInfo.blocked_chk oldrst oldgoal steps
          then 
            Seq.cons (oldrst |> end_rst (RstName.str ("end rippling on goal: " 
                                                      ^ oldgoal)) 
                             |> RState.set_goalnames [oldgoal])
                     continue_rsts
          else continue_rsts
        end
        (* We haev chosen to ignore other possible proofs if 
           all goals (on this ripple branch) were solved - give back
           only the (first) solved rst *)
      | SOME solved_rst => Seq.single solved_rst
    end
(* note steps only caleld on rst with NONE continuation *)
and note_step steps_ref rst =
    let val _ = steps_ref := rst :: (!steps_ref)
    in DescripCInfo.prepend_str_rst "Noting possible ripple step.\n" rst 
    end
and rsteps_on_goal lem_techn goal rst = 
    let 
      val steps_ref = Unsynchronized.ref []
    in
      rst |> (RState.set_rtechn
                (SOME (allfail_critic (dummy_str "choices complete")
                                     (((do_ripple_step lem_techn goal)
                                         thenf (note_step steps_ref))
                                        thenr RTechn.fail))))
          (* search through ripple-step application *)
          |> ((GSearch.depth_fs 
                 (is_none o RState.get_rtechn)
                 RState.unfold) 
                fsthen (* then give possible continuations *)
                (stop_or_cont_rippling lem_techn rst goal steps_ref))
    end;

(*fun make_ripple_goal_cinfos oldgoal newgoal rst = 
    (RState.set_goalnames [newgoal] rst)
    |> (RippleCInfo.update oldgoal newgoal);
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Start rippling                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
val induct_and_ripple_lemcalcN = 
    RstName.str "Solve using Induction, Rippling and Lemma Calculation.";
val induct_and_ripple_with_ruleN = 
    RstName.str "Solve using Induction (custom rule), Rippling and Lemma Calculation.";
val solved_by_ripplingN = 
    RstName.str "Rippling solves the goal directly";
val stepcase_by_ripplingN = 
    RstName.str "Solve the step case using rippling.";

val startr_on_goal = BasicRipple.startr_on_goal;
(*val simplify_basecase = BasicRipple.simplify_basecase;*)


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Induction and Rippling with Lemma Calc                             *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

fun simp_or_calc g = 
    (solve_or_nothing (DTacRTechn.simp_noasm g))
    try1_orelse 
    (ConjRTechn.prove_goal_by_lemma induct_ripple_lemcalc g)

and fert_calc g = 
    (BasicRipple.weak_fert_goal g)
     thenr (map_then simp_or_calc)

(* only with lemma calc *)
and endr_lemcalc rst = 
    rstif (null o RState.get_goalnames)
          (dummy solved_by_ripplingN)
          (split_then (RippleCInfo.success_chk rst) 
                      (map_then BasicRipple.strong_fert_goal)
                      (map_then fert_calc))              
      rst

(*
fun ripple_stepcase goal rst = 
    (refine stepcase_by_ripplingN
            ((startr_on_goal goal) 
               thenr (rsteps_on_goal goal) 
               thenr endr))
      rst;
*)
and ripple_stepcase_lemcalc g rst = 
      (refine stepcase_by_ripplingN
              ((startr_on_goal g)
                 thenr (rsteps_on_goal induct_ripple_lemcalc g)
                 thenr endr_lemcalc))
               rst

and induct_ripple_lemcalc g rst = 
            (refine induct_and_ripple_lemcalcN
                    (InductRTechn.induction_on_goal g
                       (map_then (ConjRTechn.conj_critic induct_ripple_lemcalc 
                                              BasicRipple.simplify_basecase))
                       (map_then ripple_stepcase_lemcalc))) rst;

(* given explicit rule for first induction *)
fun induct_ripple_lemcalc_with_rule g rule rst= 
    (refine induct_and_ripple_with_ruleN
           (InductRTechn.induction_on_goal_with g 
              (ProofContext.get_thm (RState.get_ctxt rst) rule)
              (map_then (ConjRTechn.conj_critic induct_ripple_lemcalc 
                                     BasicRipple.simplify_basecase))
              (map_then induct_ripple_lemcalc))) 
           rst;   

(*fun ripple_stepcase2 goal rst =
    (refine stepcase_by_ripplingN
     ((startr_on_goal goal)
      thenr (rsteps_on_goal2 goal)
      thenr (dummy_str "oddness") thenr endr))
      rst;
*)


(*and induct_and_ripple g rst = 
    refine induct_and_rippleN
           (InductRTechn.induction_on_goal 
              g 
              (map_then simplify_basecase) 
              (map_then ripple_stepcase )) 
           (*   (map_then ripple_stepcase2)) *)
           rst; 
fun induct_and_ripple_with_rule g rule rst = 
    (refine induct_and_ripple_with_ruleN
           (InductRTechn.induction_on_goal_with 
              g
              (ProofContext.get_thm (RState.get_ctxt rst) rule)
              (map_then simplify_basecase)
              (map_then ripple_stepcase)))
      rst; 
*)

end (* local *)

end (*struct *);
