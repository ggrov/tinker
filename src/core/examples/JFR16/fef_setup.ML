open_theory "hol";
use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
open_theory "fef032";
val pspath = tinker_path ^ "src/core/examples/JFR16/psgraph/fef/";

(*=====  tactics definitions *)
val repeat_strip_tac = REPEAT strip_tac;
(*fun PC_T1_asm_prove_tac [PPProver.A_Str ctxt, PPProver.A_Trm t1, PPProver.A_Trm t2] = PC_T1 ctxt asm_prove_tac(map get_spec[t1, t2])*)
(*fun asm_fc_thm_tac [PPProver.A_Trm t, PPProver.A_Trm sg]=  all_fc_tac[rewrite_rule(map get_spec[t]) (asm_rule sg)]
| asm_fc_thm_tac _ = fail_tac;
fun asm_rewrite_sym_thm_tac [PPProver.A_Trm t] = (asm_rewrite_thm_tac o eq_sym_rule) (asm_rule t)
| asm_rewrite_sym_thm_tac _ = fail_tac;*)

val PC_T1_asm_prove_tac = PC_T1 "sets_ext" asm_prove_tac(map get_spec[¬Elems®, ¬Map®]);
fun asm_fc_thm_tac [PPProver.A_Thm sg]=  all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®]) sg]
| asm_fc_thm_tac [PPProver.A_Trm sg]=  all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®]) (asm_rule sg)]
| asm_fc_thm_tac _ = fail_tac;
fun asm_rewrite_sym_thm_tac [PPProver.A_Thm th] = (asm_rewrite_thm_tac o eq_sym_rule) th
| asm_rewrite_sym_thm_tac _ = fail_tac;
fun rewrite_sym_thm_tac [PPProver.A_Trm t] = (rewrite_thm_tac o eq_sym_rule) (asm_rule t)
| rewrite_sym_thm_tac _ = fail_tac;
fun drop_asm_tac [PPProver.A_Trm t] = DROP_ASM_T t (discard_tac)
| drop_asm_tac _ = fail_tac;
val default_asm_rewrite_tac = asm_rewrite_tac [];
val strip_concl_conv_tac = STRIP_T (asm_tac o conv_rule(RAND_C eq_sym_conv));

(*=====  GoalTyp definitions *)
 val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z). ";

 val data = 
  default_gt_data
(*  |> ClauseGoalTyp.add_atomic "no_asm_to_strip" literal *)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);


(*===== Reference: definitions of tac1 - tac 4 *)
(*
THEN1 apply the 1st subgoal to tac2, others to id
LEMMA_T applies the 1st arg as subgoal, and then using the 1st arg as thm with the 2nd fn to apply to the orginal goal
POP_ASM_T remove the 1st asm and use it as a thm to snd fns

val tac1 = REPEAT strip_tac THEN
	LEMMA_T ¬Snd x  OK_VC‰d c®
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¬Elems®, ¬Map®]);

val tac2 = REPEAT strip_tac THEN
	cases_tac¬Snd (te tl‰0 rl‰0 r‰0) = Snd (te tl‰1 rl‰1 r‰1)®
	THEN_LIST [
	asm_ante_tac ¬³ Snd (te tl‰1 rl‰1 r‰1) = Snd (Fst x tl‰1 rl‰1 r‰1)®
	THEN POP_ASM_T (asm_rewrite_thm_tac o eq_sym_rule)
	THEN REPEAT strip_tac THEN
	LEMMA_T ¬Fst x  OK_VC‰d c®
		(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¬Elems®, ¬Map®])
	,
	DROP_ASM_T ¬te  OK_VC‰d c®
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])];
val tac3 = REPEAT strip_tac THEN
	cases_tac¬Snd (te tl‰0 rl‰0 r‰0) = Snd (te tl‰1 rl‰1 r‰1)®
	THEN_LIST [
	asm_ante_tac ¬³ Snd (te tl‰0 rl‰0 r‰0) = Snd (Fst x tl‰0 rl‰0 r‰0)®
	THEN asm_rewrite_tac[]
	THEN STRIP_T (asm_tac o conv_rule(RAND_C eq_sym_conv)) THEN
	LEMMA_T ¬Fst x  OK_VC‰d c®
		(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¬Elems®, ¬Map®])
	,
	DROP_ASM_T ¬te  OK_VC‰d c®
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th])];
val tac4 = REPEAT strip_tac THEN
	DROP_ASM_T ¬CaseVal c te cel ee  OK_VC‰d c®
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¬OK_VC‰d®])th]);
*)