signature RIPPLE_LEMSPEC =
sig

structure RippleLemCalc : RIPPLE_LEMCALC 
structure BasicRipple : BASIC_RIPPLE
val do_midout_ripple_step : PPlan.gname -> RTechn.T

val induct_ripple_lemspec : PPlan.gname -> RTechn.T
val induct_ripple_lemspec_with_rule : PPlan.gname ->  xstring -> RTechn.T

val lemma_spec : PPlan.gname -> RTechn.T


end;


functor RippleLemSpecFUN (structure RippleLemCalc : RIPPLE_LEMCALC
                          structure MidOutRCInfo : MIDOUT_RIPPLE_CINFO) 
(* : RIPPLE_LEMSPEC*) =
struct

local 
  open RTechnEnv;
in

structure RippleLemCalc = RippleLemCalc;
structure BasicRipple = RippleLemCalc.BasicRipple;
structure BasicRCInfo = MidOutRCInfo.BasicCInfo;

 
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Ending Middle-Out Rippling                                         *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Only want projections that keep the skeleton *)
fun check_project old_skels goal rst =
    let 
      val goal_trm = RstPP.goal_concl rst goal
      val ectxt = Ectxt.init (RstPP.get_ienv rst) 
                             (BasicRCInfo.get_relgraph rst goal)
    in
      Option.isSome 
        (Seq.pull (Seq.maps (fn skel => Embed.embed ectxt skel goal_trm) 
                            (Seq.of_list old_skels)))
    end;


fun fert_and_check lemma_nm goal rst =
    let 
      val old_skels_trms = map (snd o fst) (BasicRCInfo.all_skels_of rst goal)
      val proj_rstl = Seq.list_of (rst |> RState.set_rtechn NONE
                                    |> MidOutRCInfo.proj_of goal)
      val _ = 
          Pretty.writeln 
            (Pretty.block 
               [Pretty.str "projsl: ",
                Pretty.str (string_of_int (length proj_rstl))]);
      val projembeds_rstl = 
          filter (check_project old_skels_trms goal) proj_rstl;
      val _ = Pretty.writeln 
            (Pretty.block 
               [Pretty.str "proj_embedsl: ",
                Pretty.str (string_of_int (length projembeds_rstl))])
      val x = 
          (Seq.of_list projembeds_rstl)
(*       |> Seq.map_filter (check_project old_skels_trms goal)   *)
      |> Seq.maps (Seq.ORELSE ((BasicRipple.strong_fert_goal goal), 
                              (BasicRipple.weak_fert_goal goal)))
      (* if fert fails then we end up with empty seq, 
         so no counter-example stuff is done unless fert is successful *)
      |> Seq.map (CounterExCInfo.quickcheck_concl lemma_nm)
      |> Seq.filter (not o (CounterExCInfo.has_counterex lemma_nm))


      |> Seq.map (RState.add_goalnames [lemma_nm])
      |> Seq.map (continue_with 
                 (map_then (ConjRTechn.prove_goal_by_lemma 
                              RippleLemCalc.induct_ripple_lemcalc))) 
      |> Seq.list_of;
      val _ = 
          Pretty.writeln (Pretty.block [Pretty.str "fert_and_check_complete: "])
    in
      Seq.of_list x
     (* |> Seq.map (RState.set_goalnames []) *) (* Decide we're finished here without proving lemmas.*)
    end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Middle-Out Rippling Steps                                          *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val update_midout_N =
      RstName.f (fn rst => Pretty.chunks 
                             [Pretty.block 
                                [Pretty.str ("Mid-out Ripple Step")],
                                 BasicRCInfo.pretty_curgoals_skels rst])

fun make_ripple_goal_cinfos oldgoal newgoal rst = 
    (RState.set_goalnames [newgoal] rst)
    |> MidOutRCInfo.update_midout_from_goal oldgoal newgoal

fun do_midout_ripple_step goal = 
    givename update_midout_N                               
    ((MiddleOutRW.midout_rw goal)
    thenfs
    (map_rstseqf 
             (fn newgoal => 
                 (make_ripple_goal_cinfos goal newgoal))))
 
fun midout_steps_on_goal lemma_nm goal rst = 
    let
       fun cont_rtechn g = 
           (fert_and_check lemma_nm g)
           try1_orelse 
           (midout_steps_on_goal lemma_nm g);

       val possiblesL = (do_midout_ripple_step goal
                         thenr (map_then cont_rtechn)) rst
                        |> Seq.list_of (* make sure only evals once *)

       val possiblesSeq = Seq.of_list possiblesL  
          in
            if BasicRCInfo.blocked_chk rst goal possiblesL
            then 
              fail rst      
            else possiblesSeq
    end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*   Lemma Speculation                                                 *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
fun init_midout_cinfos oldskels newgoal rst = 
    (RState.set_goalnames [newgoal] rst)
    |> MidOutRCInfo.init oldskels newgoal

(* apply a schematic lemma. copute measure and embedding optimisticly,
 ie. ignore meta-variables and compute embedding for projections *)
fun apply_lemma goal lemma_nm rst =
          let
            val apply_lemma_N  = RstName.f (fn rst => Pretty.chunks 
                                  [Pretty.block 
                                  [Pretty.str "Apply speculated lemma "],
                                   BasicRCInfo.pretty_curgoals_skels rst])

            fun apply lemma_nm goal rst = 
                let 
                  val oldskels = BasicRCInfo.all_skels_of rst goal
                in
                  ((RTechnEnv.subst_eq lemma_nm false goal)
                  thenfs
                  (map_rstseqf 
                        (fn newgoal => 
                                  (givename apply_lemma_N
                                        (init_midout_cinfos oldskels newgoal)))))
                  rst (* (RState.set_rtechn NONE rst) *) 
                end;

        
            (* continue with mid-out ripple steps. The measure need to be at least one
             better than before, as applying the lemma would have had to improve mes.*)
          in
             ((apply lemma_nm goal)
             thenr 
             (map_then (midout_steps_on_goal lemma_nm))) rst
          end;


fun add_lemma goal lemma_trm rst =
      let
        val ppl0 = RState.get_pplan rst
        val (lemma_nm, ppl) = PPlan.conj_term_in_cx_of ("spec_lemma_", lemma_trm) goal ppl0
        val add_lemma_nm = RstName.pretty (Pretty.chunks 
                                          [(Pretty.str "Speculated lemma: " ),
                                          Trm.pretty (PPlan.get_context ppl) lemma_trm])
      in
        givename add_lemma_nm (fn rst' => Seq.single 
                                  (continue_with (apply_lemma goal lemma_nm) rst'))
          (RState.set_pplan ppl rst)
      end;

(*
fun lemma_spec goal rst = 
    let 
       (* the lemmas from each skeleton *)
       val skels = BasicRCInfo.inst_skels_terms rst goal
       (* This is either a list [lhs_lemma, rhs_lemma] or a singelton list
          if the goal is not an equation *)
       val lemmas = LemmaSpec.lemmaspec skels goal rst
                                          
       (*if goal is equation, get two schematic lemmas per skeleton,
          here apply one OR the other.  *)
       val rtechs = orr_list (map (add_lemma goal) lemmas)
    in
        (* Apply the lemma for a skeleton OR another skel. *)
        rtechs rst
    end;
*)

(* Cut the rest of the search space if we've found a lemma already *)
fun cut_if_found foundref rst = 
    if !foundref
    then 
      case RState.get_rtechn rst 
       of NONE => rst
        | SOME _ => RState.set_rtechn (SOME RTechn.fail) rst
    else rst;

fun set_found_lemQ lemQ rst = 
    let val _ = lemQ := true
    in rst end;

(* This speculates lemmas based on subterms of the goal *)
fun lemma_spec2 goal rst =
    let 
      (* Set a reference variable for benchmarking *)
(*      val _ = IsaPBenchmarksSql.spec_applied := true*)
      val embeddings = BasicRCInfo.embeddings_of rst goal
      val lemmas = LemmaSpec.lemmaspec2 embeddings goal rst
      val found_lemQ = Unsynchronized.ref false;
      val _ = (* for debugging print out lemmas we are thinking about *)
          Pretty.writeln 
            (Pretty.block [Pretty.str "Speculating for: ", 
                           Pretty.str goal,
                           Pretty.list 
                             "[" "]"
                             (map (fn t => 
                                      Pretty.block [
                                        Pretty.str " \"",
                                        Trm.pretty (RstPP.get_ctxt rst) t,
                                        Pretty.str "\"."])
                                  lemmas)
                          ])
    in 
       (* Create a subspace, so all alternative attempts are pruned
          from the search space once we've found a lemma that works *)      
      (RTechn.map (cut_if_found found_lemQ) 
                  ((orr_list (map (add_lemma goal) lemmas))
                     thenf (set_found_lemQ found_lemQ))
      ) rst
    end;

          
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Induction and Rippling with Lemma Speculation                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
val solved_by_ripplingN = 
    RstName.str "Rippling solves the goal directly";
val stepcase_by_ripplingN = 
    RstName.str "Solve the step case using rippling.";
val induct_and_rippleN = 
    RstName.str "Solve using Induction, Rippling and Lemma Speculation.";

 

(* Order function that prefers the rst that has the fewest number of 
   meta-variables in its goals *)
(* 
 Wherever you put bf-search it applies it WRONG after conjecturing lemmas!!!
 Then it simply refuses to work for whatever reason.

fun compare_rsts (rst1, rst2) = 
    let 
      fun num_vars rst = 
          map (RstPP.goal_concl rst) (RState.get_goalnames rst)
              |> map (List.length o Term.term_vars)
              |> foldl (op +) 0
    in
      Library.int_ord ((num_vars rst1), (num_vars rst2))
    end  

(RTechn.search (MSearch.bestfs compare_rsts)
*)

fun simp_or_calc g = 
    (solve_or_nothing (DTacRTechn.simp_noasm g))
    try1_orelse 
    (ConjRTechn.prove_goal_by_lemma RippleLemCalc.induct_ripple_lemcalc g);
    
fun fert_calc_spec g = 
    ((BasicRipple.weak_fert_goal g)
     thenr (map_then simp_or_calc))
    try1_orelse 
    (lemma_spec2 g)
    (*lemma_spec g*);

fun endr_lemspec rst = 
    (rstif 
      (null o RState.get_goalnames)
      (dummy solved_by_ripplingN)     
      (split_then (BasicRCInfo.success_chk rst) 
                  (map_then BasicRipple.strong_fert_goal)                
                  (map_then fert_calc_spec))) rst;

fun ripple_stepcase_lemspec g rst = 
      (refine stepcase_by_ripplingN
              ((BasicRipple.startr_on_goal g)
                 thenr (BasicRipple.rsteps_on_goal g)
                 thenr endr_lemspec))
               rst;

fun induct_ripple_lemspec g rst = 
    refine induct_and_rippleN
           (InductRTechn.induction_on_goal g
              (map_then (ConjRTechn.conj_critic 
                            RippleLemCalc.induct_ripple_lemcalc
                            BasicRipple.simplify_basecase))
              (map_then ripple_stepcase_lemspec))
      rst;
fun induct_ripple_lemspec_with_rule g rule rst = 
    refine induct_and_rippleN
           (InductRTechn.induction_on_goal_with g 
              (ProofContext.get_thm (RState.get_ctxt rst) rule)
              (map_then (ConjRTechn.conj_critic 
                             induct_ripple_lemspec
                             BasicRipple.simplify_basecase))
              (map_then ripple_stepcase_lemspec))
            rst;   


end (*open local *)
end; (* struct *)
