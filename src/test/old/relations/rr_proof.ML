(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      test/relations/rr_proof.ML
    Author:     Dominic Mulligan, University of Edinburgh
                dpm_edinburgh@yahoo.com
    Created:    22 Aug 2007  
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Stress test IsaPlanner with an ugly relational proof (the lemma
    needed for the proof of the confluence of an arbitrary rewrite
    system satisfying a local confluence property).
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

local 
val _ = quick_and_dirty := true;
val _ = use_thy "test/relations/Relations";
val _ = Trm.drop_var_args_flag := false;
val thry = (theory "Relations");
val gctxt = (Context.Theory thry);
val ctxt = (ProofContext.init thry);
val pp = Prf.init ctxt;

val thm = PureThy.get_thm thry;

val expr = Prf.read_top_term pp "((!!x y z. [| r x y ; r x z |] ==> (EX v. r y v & r z v)) ==> (!! a b c. (n a c \\<in> r*** & r a b) ==> (EX d. n b d \\<in> r*** & r c d)))";
val (g, pp) = Prf.conj_term_at_top ("g", expr) pp;
val rst = RState.init_from_pp pp;
val (rst::L) = Seq.list_of (InductRTechn.just_induction_on_goal g rst);
(* 
val SOME (g,p2,th) =
    (Seq.list_of (InductRTechn.just_induction_on_goal g rst); NONE)
    handle DB_DTac.bug_exp x => SOME x;
*)
val [base,step1] = RState.get_goalnames rst;

val premeth_p = (RState.get_pplan rst);
val pp = Prf.start_meth [step1] (RState.get_pplan rst);

val [IH_conc, CR_conc, Asm] = Prf.get_ndname_lasms pp step1;
val (([step2], pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "conjE") Asm step1);
val [Assm1, Assm2] = Prf.get_ndname_lasms pp step2;


val ((for1,pp)::L) = Seq.list_of (pp |> Prf.apply_frule_thm (thm "confluence_single_forward_imp") Assm1);
val (([step3],pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "exE") for1 step2);
val [exEAssm] = Prf.get_ndname_lasms pp step3;
val (([step4], pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "conjE") exEAssm step3);
val [ra2, ra1] = Prf.get_ndname_lasms pp step4
val (([crh1,crh2,step5],pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "exE") CR_conc step4);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck Assm2 crh1);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck ra2 crh2);
val [CRAssm] = Prf.get_ndname_lasms pp step5;
val (([step6],pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "conjE") CRAssm step5);
val [cr2,cr1] = Prf.get_ndname_lasms pp step6;

val (g,pp) = Prf.end_meth "Forwards on the assumptions." [step6,cr2,cr1,IH_conc,CR_conc] [step1] pp premeth_p;
val premeth_p = pp;
val pp = Prf.start_meth [step6] pp;
val (([crgoal1, rtc_step, step7],pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "exE") IH_conc step6);
val (g,pp) = Prf.end_meth "Application of inductive hypothesis." [crgoal1, rtc_step, step7] [step6] pp premeth_p;

val premeth_p = pp;
val pp = Prf.start_meth [rtc_step, step7, crgoal1] pp;

val (([rtc_stepl, rtc_stepr],pp)::L) = Seq.list_of (pp |> Prf.apply_rule_thm (thm "conjI") rtc_step);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck ra1 rtc_stepl);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck "conjEn" rtc_stepr);
val (([step8], pp)::L) = Seq.list_of (pp |> Prf.apply_rule_thm (thm "exI") step7);
val (([step9l, cnc2], pp)::L) = Seq.list_of (pp |> Prf.apply_rule_thm (thm "conjI") step8);
val (([cnc1, cr2b], pp)::L) = Seq.list_of (pp |> Prf.apply_rule_thm (thm "rtc3.step") step9l);
val (([], pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck cr2 cr2b);
val [cnc1_assm] = Prf.get_ndname_lasms pp cnc1;
val (([cnc2a], pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "conjE") cnc1_assm cnc1);
val [cnc2al, cnc2ar] = Prf.get_ndname_lasms pp cnc2a;
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck cnc2al cnc2a);
val [crassml, crassmr] = Prf.get_ndname_lasms pp crgoal1;
val (([crl, crr], pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck CR_conc crgoal1);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck crassml crl);
val (([],pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck crassmr crr);
val (([cnc2b], pp)::L) = Seq.list_of (pp |> Prf.apply_erule_thm (thm "conjE") cnc1_assm cnc2);
val [cnc2bl, cnc2br] = Prf.get_ndname_lasms pp cnc2b;
val (([], pp)::L) = Seq.list_of (pp |> Prf.apply_resol_bck cnc2br cnc2b);

val (g,pp) = Prf.end_meth "Backwards on the conclusions." [] [rtc_step, step7, crgoal1] pp premeth_p;
val _ = Prf.print pp;
in
val _ = writeln "test/relations/rr_proof.ML: test completed.";
end;
(* Proof complete! *)
