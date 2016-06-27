(*===== Load the definition of taut_tac *) 
  new_theory  "psgraph_taut";
  use_file1 (OS.FileSys.getDir()  ^ "/psgraph/src/dev/JFR/pp_taut.sml");

(*===== Load psgraph and tinker *)
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
  val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
  val pspath = tinker_path ^ "src/dev/JFR/psgraph/taut/";

 open_theory "psgraph_taut";

(*===== Get access to the definition of tactics in taut *) 
  open PP_Taut;


(*=====  GoalTyp definitions *)
 val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- member(X, hyps), top_symbol(X,Z). " ^
 "not_trm_var(Y) :- not(trm_var(Y)). " ^
 "has_no_hyp(Y) :- not(has_hyp(Y)). " ^
 "c_not_literal(X) :- c(X), dest_term(concl, _, Y2), not_trm_var(Y2)." ^
 "h_not_literal(X) :- member(X, hyps), top_symbol(X,Z), dest_term(Y, _, Z2), not_trm_var(Z2)." ^
 "taut_simp() :- is_goal(true)." ^
 "taut_simp() :- has_hyp(concl)." ^
 "taut_simp() :- has_no_hyp(concl), c(conj)." ^
 "taut_simp() :- has_no_hyp(concl), c(disj)." ^
 "taut_simp() :- has_no_hyp(concl), c(if_then_else)." ^
 "taut_simp() :- has_no_hyp(concl), c(equiv)." ^
 "taut_simp() :- has_no_hyp(concl), c(implies)." ^
 "taut_simp() :- has_no_hyp(concl), c_not_literal(not)." ^
 "asm_to_strip() :- h(conj)." ^
 "asm_to_strip() :- h(disj)." ^
 "asm_to_strip() :- h(equiv)." ^
 "asm_to_strip() :- h(implies)." ^
 "asm_to_strip() :- h(if_then_else)." ^
 "asm_to_strip() :- h_not_literal(not)." ^
 "no_asm_to_strip() :- not(asm_to_strip())." ;

 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);

(*===== Tactic definitions *)
fun taut_strip_concl thm_l = 
  conv_tac (eqn_cxt_conv (map thm_eqn_cxt thm_l));
val strip_²_concl_tac = taut_strip_concl [a_²_³b_thm, ³a_²_b_thm, a_²_b_thm];
val strip_¤_concl_tac = taut_strip_concl [´_thm, ¤_thm];
val strip_³_concl_tac = taut_strip_concl [³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm, ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm];
val strip_if_concl_tac = taut_strip_concl [local_if_thm];
val strip_´_concl_tac = (´_T (asm_tac));

fun check_new_asms_tac [PPProver.A_L data, PPProver.A_L_Trm hyps] =
 let
  val old_hyps = map (fn (PPProver.A_Trm x) => x) data
  val new_hyps = fold (fn a => fn b => filter (fn x => x ~=$ a) b) old_hyps hyps
 in
  map (fn trm => TRY (DROP_ASM_T trm check_asm_tac)) new_hyps
  |> (fn x => fold (fn a => fn b => a THEN b) x id_tac)
 end;

fun elim_±_asm_tac [PPProver.A_Trm hyp] =
 DROP_ASM_T hyp (±_THEN asm_tac);

fun elim_²_asm_tac [PPProver.A_Trm hyp] =
 DROP_ASM_T hyp  (²_THEN asm_tac);

fun taut_conv_asm thm_l = (eqn_cxt_conv (map thm_eqn_cxt thm_l));

fun elim_¤_asm_tac [PPProver.A_Trm hyp] =
  DROP_ASM_T hyp (CONV_THEN (taut_conv_asm [¤_thm]) asm_tac);

fun elim_´_asm_tac [PPProver.A_Trm hyp] =
  DROP_ASM_T hyp (CONV_THEN (taut_conv_asm [´_thm]) asm_tac);

fun elim_if_asm_tac [PPProver.A_Trm hyp] =
  DROP_ASM_T hyp (CONV_THEN (taut_conv_asm [local_if_thm]) asm_tac);

fun elim_³_asm_tac [PPProver.A_Trm hyp] =
  DROP_ASM_T hyp (CONV_THEN (taut_conv_asm [³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm, ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm]) asm_tac);

(*===== ENV Tactic definitions *)
fun ENV_all_asms [PPProver.A_L_Trm hyps, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list = 
   [StrName.NTab.update (name, map PPProver.E_Trm hyps |> PPProver.E_L) env]
|   ENV_all_asms _ _ = [];

fun ENV_top_symb_asm [PPProver.A_L_Trm hyps, PPProver.A_Str symb, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list =
 let
  val hyp' = filter (fn x => member (op =) (top_level_str' x) symb) hyps |> hd
 in
  [StrName.NTab.update (name, PPProver.E_Trm hyp') env] 
 end
| ENV_top_symb_asm _ _ = []

fun ENV_top_symb_non_literal_asm [PPProver.A_L_Trm hyps, PPProver.A_Str symb, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list =
 let
  val hyp' = filter (fn x => (member (op =) (top_level_str' x) symb andalso (dest_app x |> snd |> (not o is_var) ))) hyps |> hd
 in
  [StrName.NTab.update (name, PPProver.E_Trm hyp') env] 
 end
|   ENV_top_symb_non_literal_asm _ _ = []