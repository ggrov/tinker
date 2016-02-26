use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";

open_theory "fef032";


val pspath = tinker_path ^ "src/dev/psgraph/";


(*=====  tactics definitions *)
val repeat_strip_tac = REPEAT strip_tac;
fun PC_T1_asm_prove_tac [PPProver.A_Str ctxt, PPProver.A_Trm t1, PPProver.A_Trm t2] = PC_T1 ctxt asm_prove_tac(map get_spec[t1, t2])
| PC_T1_asm_prove_tac _ = fail_tac;
fun asm_fc_thm_tac [PPProver.A_Trm t, PPProver.A_Trm sg]=  all_fc_tac[rewrite_rule(map get_spec[t]) (asm_rule sg)]
| asm_fc_thm_tac _ = fail_tac;
fun asm_rewrite_sym_thm_tac [PPProver.A_Trm t] = (asm_rewrite_thm_tac o eq_sym_rule) (asm_rule t)
| asm_rewrite_sym_thm_tac _ = fail_tac;
fun drop_asm_tac [PPProver.A_Trm t] = DROP_ASM_T t (fn _ => id_tac)
| drop_asm_tac _ = fail_tac;


(*=====  GoalTyp definitions *)
 val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z). ";

 val data = 
  default_gt_data
(*  |> ClauseGoalTyp.add_atomic "no_asm_to_strip" literal *)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);
