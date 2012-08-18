(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    As basic rippling, but will also apply a case-analysis critic
    if it comes across any if- or case statements.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

functor RippleCasePostSplitFUN (structure BasicRipple : BASIC_RIPPLE)
(* : BASIC_RIPPLE *)
= struct

structure RippleCInfo = BasicRipple.RippleCInfo;
local 
  open RTechnEnv;
in

exception rippling_rtechn_exp of string;

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

(* solve non-rippling branches of if-statements using this
fucntion. At the moment it requires simp to solve the goal
completely, otherwise it fails. *)
fun solve_by_simp goal rst =   
      (DTacRTechn.simp_no_asm_simp_changes goal rst)
      |> Seq.map_filter (fn r => if (null (RState.get_goalnames r)) 
                         then (SOME r) else NONE);

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
    (if is_eq_term asm_trm then 
        SOME (subst_all sym asm_nm goal rst)
     else NONE);

(* returns rst *)
fun subst_asms sym goal rst = 
    let 
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

(* Problem: need to exhaust rtechn, but doesn't finish in one step. 
   ugly little workaround, shouldn't do this...*)
fun case_split split_techn old_asms oldgoal goal rst = 
    let   
      
      (* Do one at the time *)
      val split_rsts = Seq.list_of (split_techn goal rst)
  
    in
      case (split_rsts) of
        (* No more splits to do, update cinfos, except it doesn't work and all
           goalnames dissapear! *)
        [] => Seq.single (RState.set_rtechn NONE (RState.set_goalnames [goal] rst))
      | (rst2::_) => 
        (* Perform more splits *)
        ((try_then
           (map_then (fn g' => (set_new_asm_as_resultnames old_asms g')
                                 fthen (subst_asm_then_techn g')))
           (map_then (case_split split_techn old_asms oldgoal)))
           thenr
           (map_then (case_split split_techn old_asms oldgoal)))
          rst2
    end;
(*
    ((split_tech goal) (* In this case, we should apply splitting as much as possible
                          before applying make cinff *)
       thenfs
       (map_rstseqf (make_ripple_goal_cinfos_post_split oldgoal)))
      rst;
*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Ripple Steps                                                       *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


(*-------- Do all rippling first, then case-splits -------------*)
fun check_is_still_ripplestep_techn s  oldgoal g = 
    (RippleCInfo.update oldgoal g
     o RState.set_goalnames [g])
      fsthen 
      (dummy 
            (RstName.str (s ^ "-case split: ")));

(* what to do after you apply a case split *)
fun post_split s oldgoal rst =  
    (split_then (not o (RippleCInfo.is_rippling rst))
              (*  (try_then (map_then 
                             (fn g => 
                                 (set_new_asm_as_resultnames old_asms g)
                                   fthen (subst_asm_then_techn g)
                                   fsthen (map_then solve_by_simp))) *)
                          (map_then solve_by_simp)
          (*      (try_then (map_then 
                             (fn g => ]]
                                 (set_new_asm_as_resultnames old_asms g)
                                   fthen
                                   (subst_asm_then_techn g)
                                   fsthen 
                                   (map_then 
                                      (check_is_still_ripplestep_techn s oldgoal)))) *)
                          (map_then (check_is_still_ripplestep_techn s oldgoal))
     ) rst;

fun make_ripple_goal_cinfos oldgoal newgoal rst = 
    (RState.set_goalnames [newgoal] rst)
    |> (RippleCInfo.update oldgoal newgoal);
fun do_dtac_ripple_step dtac goal = 
    givename (update_stepN dtac) 
             ((apply_dtac_to_g dtac goal)
                thenfs 
                (map_rstseqf (make_ripple_goal_cinfos goal)))
fun chk_if rst =
    List.exists (fn g => SplitterRTechn.is_if rst g) (RState.get_goalnames rst);
fun chk_case rst = 
    List.exists (fn g => SplitterRTechn.goal_in_rst_has_cases rst g) 
                (RState.get_goalnames rst);
(* Note: may now have both if and case statements in goal...*)
fun case_split_or_endr rst goal =
  let val old_asms = Goaln.NSet.of_list (RstPP.lasms_of_goal rst goal)
    
    in
    if (SplitterRTechn.is_if rst goal)
    then (* Get rid of both if- and case statements (if any ) *)
      (((case_split SplitterRTechn.split_if_rtechn old_asms goal goal)
         thenfs
         (map_rstseqf (make_ripple_goal_cinfos_post_split goal)))
         thenr 
         (post_split "if" goal)
         thenr 
         (map_then rsteps_on_goal)) rst
    else if (SplitterRTechn.goal_in_rst_has_cases rst goal)
    then
      (((case_split SplitterRTechn.split_case_rtechn old_asms goal goal)
          thenfs
          (map_rstseqf (make_ripple_goal_cinfos_post_split goal)))
         thenr
         (post_split  "case" goal)
         thenr 
         (map_then rsteps_on_goal)) rst
    (* No split needed, we're blocked *)
    else 
      Seq.single
        (rst |> end_rst (RstName.str ("end rippling on goal: " 
                                      ^ goal)) 
             |> RState.set_goalnames [goal])
  end
 
and rsteps_on_goal goal rst = 
    let 
      val possiblesL =
          (RippleCInfo.applicable_dtacseq_of rst goal)
            |> Seq.maps (fn dtac => ((do_dtac_ripple_step dtac goal)
                                      thenr (map_then rsteps_on_goal)) rst)
            |> Seq.list_of (* make sure we only evaluate the states once. *)
      val possibleSeq = Seq.of_list possiblesL
    in
      if RippleCInfo.blocked_chk rst goal possiblesL
      then 
        Seq.append (case_split_or_endr rst goal)
                 possibleSeq (* fixme: case_split_or_end doesn't finish in 1 step, 
                              but isn't possibleSeq empty anyway?*)
      else possibleSeq
    end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Start rippling                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val induct_and_rippleN = 
    RstName.str "Solve using Induction and Rippling.";
val induct_and_ripple_with_ruleN = 
    RstName.str "Solve using Induction (custom rule) and Rippling.";
val stepcase_by_ripplingN = 
    RstName.str "Solve the step case using rippling and case-analysis critic.";

val startr_on_goal = BasicRipple.startr_on_goal;
val simplify_basecase = BasicRipple.simplify_basecase;


fun ripple_stepcase goal rst =
    (refine stepcase_by_ripplingN
     ((startr_on_goal goal)
      thenr (rsteps_on_goal goal)
      thenr endr))
      rst;

fun induct_and_ripple g rst = 
    refine induct_and_rippleN
           (InductRTechn.induction_on_goal 
              g 
              (map_then simplify_basecase) 
              (map_then ripple_stepcase))
           rst; 
fun induct_and_ripple_with_rule g rule rst = 
    (refine induct_and_ripple_with_ruleN
           (InductRTechn.induction_on_goal_with 
              g
              (ProofContext.get_thm (RState.get_ctxt rst) rule)
              (map_then simplify_basecase)
              (map_then ripple_stepcase)))
      rst; 

end (* local *)

end (*struct *);
