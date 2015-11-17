(*===== Load the definition of taut_tac *) 
  use_file1 (OS.FileSys.getDir()  ^ "/psgraph/src/dev/JFR/pp_taut.sml");

(*===== Load psgraph and tinker *) 
  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
  val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
  val pspath = tinker_path ^ "src/dev/psgraph/";

 open_theory "hol";
 set_pc "hol";

(*===== Get access to the definition of tactics in taut *) 
  open PP_Taut;


(*=====  GoalTyp definitions *)
 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);

 val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z). " ^
 "c_not_literal(X) :- c(X), rand_trm(concl, Y), not_trm_var_nor_const(Y)." ^
 "h_not_literal(X) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), not_trm_var_nor_const(Z)." ^
 "taut_simp(concl) :- is_goal(true)." ^
 "taut_simp(concl) :- has_hyp(concl)." ^
 "taut_simp(concl) :- c(conj)." ^
 "taut_simp(concl) :- c(disj)." ^
 "taut_simp(concl) :- c(if_then_else)." ^
 "taut_simp(concl) :- c(equiv)." ^
 "taut_simp(concl) :- c(implies)." ^
 "taut_simp(concl) :- c_not_literal(not)." ^
 "asm_to_strip(hyps) :- h(conj)." ^
 "asm_to_strip(hyps) :- h(disj)." ^
 "asm_to_strip(hyps) :- h(equiv)." ^
 "asm_to_strip(hyps) :- h(implies)." ^
 "asm_to_strip(hyps) :- h(if_then_else)." ^
 "asm_to_strip(hyps) :- h_not_literal(not)." ^
 "no_asm_to_strip(hyps) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), trm_var(Z)." ^
 "no_asm_to_strip(hyps) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), trm_const(Z).";


 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c(Z) :- top_symbol(concl,Z).") @ x)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "h(Z) :- top_symbol(hyps,Z).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "c_not_literal(X) :- c(X), rand_trm(concl, Y), is_not_trm_var(Y).") @ x)
 |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "h_not_literal(X) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), is_not_trm_var(Z).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- is_goal(true).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- has_hyp(concl).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c(conj).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c(disj).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c(if_then_else).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c(equiv).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c(implies).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "taut_simp(concl) :- c_not_literal(not).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h(conj).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h(disj).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h(equiv).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h(implies).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h(if_then_else).") @ x)
  |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "asm_to_strip(hyps) :- h_not_literal(not).") @ x)
 |>  ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt "no_asm_to_strip(hyps) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), is_not_trm_var(Z).") @ x);

is_const ¬ T®;

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
 ±_THEN (asm_tac) (asm_rule hyp);

fun elim_²_asm_tac [PPProver.A_Trm hyp] =
 ²_THEN (asm_tac) (asm_rule hyp);

fun taut_conv_asm thm_l =  (eqn_cxt_conv (map thm_eqn_cxt thm_l));

fun elim_¤_asm_tac [PPProver.A_Trm hyp] =
 CONV_THEN (taut_conv_asm [¤_thm]) (asm_tac) (asm_rule hyp);

fun elim_´_asm_tac [PPProver.A_Trm hyp] =
 CONV_THEN (taut_conv_asm [´_thm]) (asm_tac) (asm_rule hyp);

fun elim_if_asm_tac [PPProver.A_Trm hyp] =
 CONV_THEN (taut_conv_asm [local_if_thm]) (asm_tac) (asm_rule hyp);

fun elim_³_asm_tac [PPProver.A_Trm hyp] =
 CONV_THEN (taut_conv_asm [³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm, ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm]) (asm_tac) (asm_rule hyp);

(*===== ENV Tactic definitions *)
fun ENV_all_asms [PPProver.A_L_Trm hyps, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list = 
   [StrName.NTab.update (name, map PPProver.E_Trm hyps |> PPProver.E_L) env]
|   ENV_all_asms _ _ = [];

fun ENV_top_symb_asm [PPProver.A_L_Trm hyps, PPProver.A_Str symb, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list =
 let
  val hyp' = filter (fn x => member (op =) (top_level_str' x) name) hyps |> hd
 in
  [StrName.NTab.update (name, PPProver.E_Trm hyp') env] 
 end;

fun ENV_top_symb_non_literal_asm [PPProver.A_L_Trm hyps, PPProver.A_Str symb, PPProver.A_Var name] (env : PPProver.env)  : PPProver.env list =
 let
  val hyp' = filter (fn x => (member (op =) (top_level_str' x) name andalso (dest_app x |> snd |> (not o is_var) ))) hyps |> hd
 in
  [StrName.NTab.update (name, PPProver.E_Trm hyp') env] 
 end;





check_new_asms_tac;

val drop_´_concl_tac = (´_T (fn _ => id_tac));
val ²_then_asm_tac = (²_THEN asm_tac);
val drop_asm_tac = (fn trm => DROP_ASM_T trm (fn _ => id_tac));

val test_tac = ´_T(²_THEN (fn _ => id_tac));
val test2_tac =  (´_T (fn thm => asm_rule(concl thm) |> asm_tac));
´_T ;
concl;

(fn [PPProver.A_Trm trm] => DROP_ASM_T trm (±_THEN asm_tac));


check_asm_tac;

taut_strip_thm_conv;
conv_rule;
asm_rule (StrName.NTab.get env name);
fun ENV_taut_strip_thm_conv [PPProver.A_Var name] env =
 [StrName.NTab.update (name, dest_%implies% trm |> fst) env]
|   ENV_taut_strip_thm_conv _ _ = []

±_THEN check_asm_tac;
²_THEN check_asm_tac;

CONV_THEN taut_strip_thm_conv check_asm_tac;

(* Version 1, just a loop *)
 val taut_v1 = PSGraph.read_json_file (pspath ^"simple_taut_tac_V1.psgraph");

  PPIntf.set_psg_goal (SOME ([],¬(A ± B) ´ (B ± A)®)) (SOME taut_v1);

(* Version 3, add goaltype *)
 val taut_v3 = PSGraph.read_json_file (pspath ^"simple_taut_tac_V3.psgraph") |> PSGraph.set_goaltype_data data; 

 PPIntf.set_psg_goal (SOME g3) (SOME taut_v3);

val ps = PSGraph.read_json_file (pspath^"branching.psgraph");

PPIntf.set_psg_goal (SOME g1) (SOME ps);
TextSocket.safe_close();


(*==== Test *)
val ps = PSGraph.read_json_file (pspath^"scratch.psgraph");

PPIntf.set_psg_goal (SOME g2) (SOME ps);

val (pnode,pplan) = PPProver.init PPProver.default_ctxt (fst g2) (snd g2);

val g1 : GOAL = ([],¬T®);
val g2 : GOAL = ([¬B ± A®, ¬³ (A ± B)®],¬³ (A ± B)®);
val g3 : GOAL = ([],¬if a then F else T®);
val g4 : GOAL = ([¬F®],¬A ´ B´A®);
val g5 : GOAL = ([],¬³ (B)®);

fun drop_asm_tac t = DROP_ASM_T t (fn _ => id_tac);
val pop_asm_tac = POP_ASM_T (fn _ => id_tac);

val ctxt = PPProver.default_ctxt;
ClauseGoalTyp.scan_goaltyp ctxt "c(?x)";



ClauseGoalTyp.imatch data pnode (ClauseGoalTyp.scan_goaltyp ctxt "h_not_literal(not)");

ClauseGoalTyp.imatch data pnode ("c", [ClauseGoalTyp.Name "not"]);

ClauseGoalTyp.imatch data pnode ("top_symbol",[ClauseGoalTyp.Concl, ClauseGoalTyp.Name "not"]);



ClauseGoalTyp.imatch data pnode ("c",[ClauseGoalTyp.Name "conj"]);


ClauseGoalTyp.imatch data pnode ("top_symbol",[ClauseGoalTyp.Concl, ClauseGoalTyp.Name "not"]);


ClauseGoalTyp.imatch data pnode ("top_symbol",[ClauseGoalTyp.Hyps, ClauseGoalTyp.Name "not", ClauseGoalTyp.Var "tmp"]);


val e = ClauseGoalTyp.imatch data pnode ("top_symbol",[ClauseGoalTyp.Hyps, ClauseGoalTyp.Name "not", ClauseGoalTyp.Var "hyp"])
|> hd
|> ClauseGoalTyp.match data pnode ("rand_trm",[ClauseGoalTyp.Var "hyp", ClauseGoalTyp.Var "tmp"])
|> hd
|> ClauseGoalTyp.match data pnode ("is_not_trm_var",[ClauseGoalTyp.Var "tmp"]);


ClauseGoalTyp.match data pnode ("(is_not_trm_var",[ClauseGoalTyp.Var "tmp"]) e;