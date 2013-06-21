(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/ripple_rtechn.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Reasoning Techniques - stuff working towards proof planning 
    with hi-proofs.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature BASIC_RIPPLE (* RIPPLE_RTECHN *)=
sig
  exception rippling_rtechn_exp of string
  structure RippleCInfo : BASIC_RIPPLE_CINFO 

  (* basic rippling tools *)
  val startr_on_goal : PPlan.gname -> RTechn.T
 (* val do_dtac_ripple_step : DB_DTac.T -> PPlan.gname -> RTechn.T *)
  val rsteps_on_goal : PPlan.gname -> RTechn.T
  val update_stepN : DTac.T -> RstName.T
                                    
  (*val cached_steps : RTechn.T *)
  val endr :  RTechn.T
  val strong_fert_goal : PPlan.gname ->  RTechn.T 
  val weak_fert_goal :  PPlan.gname -> RTechn.T

  (* wihtout conjecturing *)
  val simplify_basecase : PPlan.gname -> RTechn.T
  val ripple_stepcase :  PPlan.gname -> RTechn.T
  val induct_and_ripple : PPlan.gname -> RTechn.T
  val induct_and_ripple_with_rule : PPlan.gname -> xstring -> RTechn.T

(* we can't add these because they are not part of the case-split version. 
  (* internal, but useful for debugging *)
  val do_dtac_ripple_step : DTac.T -> PPlan.gname -> RState.T -> RState.T Seq.seq
  val make_ripple_goal_cinfos : PPlan.gname -> PPlan.gname  -> RState.T -> RState.T Seq.seq
*)
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor BasicRippleRTechnFUN
          (structure RippleCInfo : BASIC_RIPPLE_CINFO
           structure ConjRTechn : CONJ_RTECHN)
(*         : BASIC_RIPPLE *)
= struct

(* prepare the skeleton, ie change object level "all's" and meta level
all's to schematic var representation. *)

(* IDEA: use records for autmatic type checking of results and for
passing back and taking information... this can capture state
transition requirements, such as needing explore to be true etc - this
would provide some compile-time code checking. *)

(* val prep_skeleton = Data.rulify o Drule.gen_all; *)
structure RippleCInfo = RippleCInfo;
local 
  open RTechnEnv;
in

exception rippling_rtechn_exp of string;


(* Reasoning state pretty printing functions *)
val basecaseN = 
    RstName.str "Solve the base case by simplification.";
val induct_and_rippleN = 
    RstName.str "Solve using Induction and Rippling.";
val induct_and_ripple_with_ruleN = 
    RstName.str "Solve using Induction (custom rule) and Rippling.";
val strong_fertN = RstName.str "Strong fertilisation";  
val weak_fertN = RstName.str "Weak fertilisation"; 
fun start_ripplingN goal = 
    RstName.chunks [RstName.str "Start Rippling with state: ",
                    (fn rst => RippleCInfo.pretty_skels rst goal)];
fun update_stepN dtac =
    RstName.f (fn rst => Pretty.chunks 
                           [Pretty.block 
                              [Pretty.str "Ripple Step by ",
                               DTac.pretty dtac (RState.get_ctxt rst)],
                            RippleCInfo.pretty_curgoals_skels rst]);
val solved_by_ripplingN = 
    RstName.str "Rippling solves the goal directly";
val stepcase_by_ripplingN = 
    RstName.str "Solve the step case using rippling.";


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Fertilisation                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Strong Fertilisation *)
fun strong_fert_goal goal rst =
    givename strong_fertN 
             (orr_list (map (fn s => apply_res s goal)
                            (RippleCInfo.skeleton_names_of rst goal)))
             rst;

(* Weak Fertilisation by a single step of direct rewriting *)
fun is_eq_term t = 
    is_some (Subst.move_to_concl_eq (Zipper.mktop t));
fun subst_skel goal (skelnm,skel) rst = 
    (if is_eq_term skel then 
       let
         val gt = RstPP.goal_concl rst goal
         val z = Zipper.mktop gt
       in
         if is_eq_term gt then 
           orr_list [RTechnEnv.subst_in_lhs skelnm false goal, 
                     RTechnEnv.subst_in_rhs skelnm true goal]
         else
           (* try the skelequation both ways around *)
           orr_list [RTechnEnv.subst_eq skelnm false goal, 
                     RTechnEnv.subst_eq skelnm true goal]
       end else fail) rst;

fun subst_skels goal skels = orr_list (map (subst_skel goal) skels);

(* FIXME: This is perhaps a bit hacky, but it had issues with 
   returing reasoning states with no goalnames, or something otherwise.
   Also, maybe we don't always want to fertilise with all skels. *)
fun subst_skels2 goal [] rst = Seq.single (RState.set_goalnames [goal] rst)
  | subst_skels2 goal (skel1::skels) rst = 
    (subst_skel goal skel1 rst) 
      |> Seq.maps (fold_over_each_goal (fn g => subst_skels2 g skels));

fun weak_fert_goal goal rst =
    givename weak_fertN (subst_skels2 goal 
                         (RippleCInfo.skeleton_namedterms_of rst goal))
             rst; 


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Start Rippling                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* given an reasoning state which is being use to explore, then we can
setup rippling with the give skeleton terms and theorems. *)
fun startr_on_goal goal rst = 
    let 
      val skels = PPlan.get_varified_lasm_nctrms (RState.get_pplan rst) goal;
    in
      rst |> RState.set_rtechn NONE
          |> (givename (start_ripplingN goal)
                       (RippleCInfo.start skels ParamRGraph.empty goal))
    end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Rippling Steps                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* apply dtac and update the rippling state information *)
(* implicit arg: rst *)

fun filter_in_if_some_rippling_goal rst = 
    let val gnames = RState.get_goalnames rst
        val ripple_gnames = 
            filter (RippleCInfo.is_valid_ripple_state_goal rst) gnames
    in 
      if null ripple_gnames then Seq.empty
      else Seq.single (RState.set_goalnames ripple_gnames rst)
    end;
(* 
    if RippleCInfo.some_curgoal_is_ripple_valid rst 
    then Seq.single rst
    else Seq.empty;
*)

fun make_ripple_goal_cinfos oldgoal newgoal rst = 
      ((RState.set_goalnames [newgoal] rst)
         |> ((RippleCInfo.update oldgoal newgoal)
             try1_orelse
             (dummy_str "non-rippling-goal")
      ));

fun do_dtac_ripple_step dtac goal = 
    givename (update_stepN dtac) 
             ((apply_dtac_to_g dtac goal)
                thenfs 
                (map_rstseqf (make_ripple_goal_cinfos goal))
                thenfs
                filter_in_if_some_rippling_goal
             );


(* do a valid ripple steps using the wave rules in the wave rule DB.
When we get to a state in which has no following state has a better
out measure, then we know rippling is blocked.  *)
fun rsteps_on_goal goal rst = 
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
        Seq.cons (rst |> end_rst (RstName.str ("end rippling on goal: " 
                                               ^ goal)) 
                      |> RState.set_goalnames [goal])
                 possibleSeq
      else possibleSeq
    end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Simplify Base Case                                                 *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Simplify the base case *)
fun simplify_basecase g = 
(*     givename basecaseN (DTacRTechn.simp_asm_full g);  *)
    givename basecaseN (DTacRTechn.simp_no_asm_simp_changes g);

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Induction and Rippling: no conjecturing                            *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
fun endr rst = 
    rstif (null o RState.get_goalnames) 
          (dummy solved_by_ripplingN)
          (split_then (RippleCInfo.success_chk rst) 
                      (map_then strong_fert_goal)
                      ((map_then weak_fert_goal)
                         try1_then 
                         ((map_then DTacRTechn.simp_noasm)
                            try1_orelse 
                            (dummy (RstName.str "Step case stuck")))))
      rst;
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
              (Proof_Context.get_thm (RState.get_ctxt rst) rule)
              (map_then simplify_basecase)
              (map_then ripple_stepcase)))
      rst; 


end; (* RTechnEnv local *) 
end; (* struct *)
