use (OS.FileSys.getDir() ^ "/psgraph/src/dev/JFR/fef_setup.ML");
val pspath = tinker_path ^ "src/dev/psgraph/";

(******************************************)
(* definitions for tactics *)
(******************************************)
  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);

(******************************************)
(* definitions for goaltypes *)
(******************************************)
(*val scan_def = ClauseGoalTyp.scan_data PPProver.default_ctxt;*)
  val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
  val data = default_gt_data;
   
(* read and load a psgraph created by gui *)
  val ps_tac1 = PSGraph.read_json_file (SOME data) (pspath^"fef_tac.psgraph");

(******************************************)
(* definition of tac1 - tac 4 *)
(******************************************)
(*
THEN1 apply the 1st subgoal to tac2, others to id
LEMMA_T applies the 1st arg as subgoal, and then using the 1st arg as thm with the 2sn fn to apply to the orginal goal
POP_ASM_T remove the 1st asm and use it as a thm to snd fns
*)

open_theory "fef032";
map get_spec [¬Elems®, ¬OK_VC‰d®];

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

(******************************************)
(* experiments*)
(******************************************)
  val ps = PSGraph.read_json_file (SOME data) (pspath^"fef_tac.psgraph");
  PPIntf.set_psg_goal (SOME ([], ¬B%and%A®)) (SOME ps);

  fun drop_asm_tac ast = DROP_ASM_T ast (fn _ => id_tac);

  TextSocket.safe_close();

  PPIntf.set_psg_goal (SOME ([], ¬B%and%B®)) (NONE);
  PPIntf.set_psg_goal (SOME ([], ¬A®)) (NONE);


asm_fc_tac;
fn g => [rewrite_rule [get_spec ¬OK_VCÇd®] (asm_rule g)];

fn ([PPProver.A_Str str, PPProver.A_Trm def1, PPProver.A_Trm def2]) => PC_T1 str asm_prove_tac(map get_spec[def1, def2]);
(******************************************)
(* Test *)
(******************************************)
open_theory "fef032";
(* 1, test is goal and is not goal *)
  val ps = PSGraph.read_json_file NONE (pspath^"scratch.psgraph") |> PSGraph.set_goaltype_data default_gt_data; 

  PPIntf.set_psg_goal (SOME ([], ¬B%and%A®)) (SOME ps);

  TextSocket.safe_close();

(* 2, tac with arg parsing *)
  val ps = PSGraph.read_json_file NONE (pspath^"toy.psgraph") |> PSGraph.set_goaltype_data default_gt_data; 

  PPIntf.set_psg_goal (SOME ([], ¬B%and%A®)) (SOME ps);

  TextSocket.safe_close();
