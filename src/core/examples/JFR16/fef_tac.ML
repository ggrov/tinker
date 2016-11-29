val tinkerhome = OS.FileSys.getDir() ^ "/psgraph";
use_file ( tinkerhome ^ "/src/core/examples/JFR16/fef_setup.ML");

open_theory "fef033";

set_pc"hol";

val ps_tac1 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac1.psgraph");
val ps_tac2 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac2.psgraph");
val ps_tac3 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac3.psgraph");
val ps_tac4 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac4.psgraph");

set_goal([], ¬µc te cel ee·
	te  OK_VC‰d c ±
	Elems (Map Fst cel) € OK_VC‰d c ±
	Elems (Map Snd cel) € OK_VC‰d c ±
	ee  OK_VC‰d c ´
	CaseVal c te cel ee  OK_VC‰d c
®);
a(REPEAT µ_tac);
a(list_induction_tac¬cel® THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac(CaseVal_lemma:: map get_spec[¬OK_VC‰d®, ¬Let®])
	THEN REPEAT µ_tac);
a(rewrite_tac[µ_elim¬Snd® fun_if_thm]);
a(CASES_T¬c dominates Fst (te tl‰0 rl‰0 r‰0)® rewrite_thm_tac);
a(CASES_T¬c dominates Fst (te tl‰1 rl‰1 r‰1)® rewrite_thm_tac);
(* *** Goal "1.1" (duplicates "1.2") *** *)
a(REPEAT strip_tac THEN
	DROP_ASM_T ¬ee  OK_VC‰d c®
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¬Map®, ¬Elems®]));
(* *** Goal "3" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¬Map®, ¬Elems®]));
(* *** Goal "4" *** *)
a(rewrite_tac(µ_elim¬Snd® fun_if_thm::µ_elim¬Fst® fun_if_thm::CaseVal_lemma::
	map get_spec[¬OK_VC‰d®, ¬Let®])
	THEN REPEAT µ_tac);
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¬Snd (te tl‰0 rl‰0 r‰0) = Snd (Fst x tl‰0 rl‰0 r‰0)®,
	 ¬c dominates Fst (te tl‰0 rl‰0 r‰0)®,
	 ¬c dominates Fst (Fst x tl‰0 rl‰0 r‰0)®]);
(* *** Goal "4.1" *** *)
(* reduce to the 8 subgoals 4.1.1 - 4.1.8 that tac1 and tac2 were designed for: *)
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¬Snd (te tl‰1 rl‰1 r‰1) = Snd (Fst x tl‰1 rl‰1 r‰1)®,
	 ¬c dominates Fst (Fst x tl‰1 rl‰1 r‰1)®,
	 ¬c dominates Fst (te tl‰1 rl‰1 r‰1)®]);


(* *** Goals "4.1.1" - "4.1.4" solved by tac1 in the original *** *)
PPIntf.apply_ps_i ps_tac1;
PPIntf.apply_ps ps_tac1;
PPIntf.apply_ps ps_tac1;
PPIntf.apply_ps ps_tac1;


(* *** Goals "4.1.5" - "4.1.8" solved by tac2 in the original *** *)
PPIntf.apply_ps_i ps_tac2;
PPIntf.apply_ps ps_tac2;
PPIntf.apply_ps ps_tac2;
PPIntf.apply_ps ps_tac2;

(* *** Goal "4.2" *** *)
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¬Snd (te tl‰1 rl‰1 r‰1) = Snd (Fst x tl‰1 rl‰1 r‰1)®,
	 ¬c dominates Fst (Fst x tl‰1 rl‰1 r‰1)®,
	 ¬c dominates Fst (te tl‰1 rl‰1 r‰1)®]);

val i = top_goal_state ();
drop_main_goal();
push_goal_state i;
(* *** Goals "4.2.1" - "4.2.4" solved by tac3 in the original *** *)
PPIntf.apply_ps_i ps_tac3;
PPIntf.apply_ps ps_tac3;
PPIntf.apply_ps ps_tac3;
PPIntf.apply_ps ps_tac3;


(* *** Goals "4.2.5" - "4.2.8" solved by tac4 in the original *** *)
PPIntf.apply_ps_i ps_tac4;
PPIntf.apply_ps ps_tac4;
PPIntf.apply_ps ps_tac4;
PPIntf.apply_ps ps_tac4;

val CaseVal_OK‰d_lemma = pop_thm();
TextSocket.safe_close();

