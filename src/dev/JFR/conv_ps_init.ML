
val (asms0,_) = top_goal();
val asms0 = [¬Ô  Topology®];
val params = continuity_params (map asm_rule asms0);

val {unary : TERM list, binary : TERM list,
     parametrized : TERM list,
     pattern_vars : TERM list,
     facts : THM list, witness_tac : TACTIC} = continuity_params (map asm_rule asms0);

val m_conv = morphism_conv {
			unary = unary,
			binary = binary,
			parametrized = parametrized,
			pattern_vars = pattern_vars};

val unary_thms = map (fn t => all_µ_intro1 pattern_vars t (gen_µ_elim t unary_rule_thm))
			unary;
val binary_thms = map (fn t => all_µ_intro1 pattern_vars t (gen_µ_elim t binary_rule_thm))
			binary;
val binary_thms1 = map (fn t => all_µ_intro1 pattern_vars t (gen_µ_elim t binary_rule_thm1))
			binary;
val parametrized_thms = map (switch gen_µ_elim parametrized_rule_thm)
			parametrized;
val i_conv = simple_eq_match_conv i_rule_thm;
val k_conv = simple_eq_match_conv k_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;
val unary_conv = FIRST_C (map simple_ho_eq_match_conv1 unary_thms)
 handle Fail _ => fail_conv;
val binary_conv = FIRST_C (map simple_ho_eq_match_conv1 (binary_thms @ binary_thms1))
 handle Fail _ => fail_conv;
val parametrized_conv = FIRST_C (map simple_ho_eq_match_conv1 parametrized_thms)
 handle Fail _ => fail_conv;
val param_conv = parametrized_conv;
val simp_conv = simple_eq_match_conv o_i_rule_thm;

val is_rule = is_´ o snd o strip_µ o concl;
val rule_thms = facts drop (not o is_rule);
val axiom_thms = facts drop is_rule;
val rw_thms = [];

val pre_conv_app = TRY (conv_tac (LEFT_C È_expand_conv)) THEN	
 TRY (unpair_rewrite_tac rw_thms);

val conversion_tac = conv_tac (LEFT_C m_conv);	
val post_conv_app = (REPEAT o CHANGED_T) (
				(TRY o bc_tac) rule_thms
			THEN	TRY witness_tac
			THEN	REPEAT strip_tac
			THEN	(TRY o rewrite_tac) axiom_thms);


(****************************************************)
(* PSGraph definition *)
fun lift_conv ([PPProver.A_Conv c, PPProver.A_L pos]) =
  let 
   val cc :(CONV->CONV) = 
    map (fn PPProver.A_CConv1 cc => cc) pos
    |> List.foldl (op o) (fn x => x);
   val conv : CONV = cc c
  in 
    conv_tac conv
  end
|   lift_conv _ = raise RunCall.Fail "Conversion Fails due to unexpected params";

(****************************************************)
(* definition of env tactic *)
fun ENV_init [PPProver.A_Var v, PPProver.A_L l] env = 
	[StrName.NTab.update (v, PPProver.arg_to_env (PPProver.A_L l)) env]
| ENV_init _ _ =[];

fun ENV_push [new_pos, PPProver.A_Var v] env = 
  let 
   val pos = StrName.NTab.get env v
   val new_pos' = PPProver.arg_to_env new_pos
   val f = (fn (x, PPProver.E_L l2) => PPProver.E_L (x :: l2))
  in 
   [StrName.NTab.update (v, f (new_pos', pos)) env]
  end
|   ENV_push _ _ = [];

fun ENV_pop [PPProver.A_Var v] env = 
 StrName.NTab.get env v
 |> (fn PPProver.E_L x => x)
 |> tl
 |> (fn x => [StrName.NTab.update (v, PPProver.E_L x) env])
|   ENV_pop _ _ = [];

fun strip_E_CC (PPProver.E_CConv1 cc) = cc;

fun is_some_conv' c env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (PPProver.E_L cc) => 
              (map strip_E_CC cc) 
              |> List.foldl (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env]))
  handle _ => [])
| is_some_conv' c env pnode [ClauseGoalTyp.Var p] = 
 (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (PPProver.E_L cc) => 
              (map strip_E_CC cc) 
              |> List.foldl (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env]))
  handle _ => [])
| is_some_conv' _ _ _ _ = [];

val is_i_conv : ClauseGoalTyp.gtyp = is_some_conv' i_conv
val is_k_conv : ClauseGoalTyp.gtyp = is_some_conv' k_conv
val is_pair_conv : ClauseGoalTyp.gtyp = is_some_conv' pair_conv
val is_simp_conv: ClauseGoalTyp.gtyp = is_some_conv' simp_conv

val is_unary_conv: ClauseGoalTyp.gtyp = is_some_conv' unary_conv
val is_binary_conv: ClauseGoalTyp.gtyp = is_some_conv' binary_conv
val is_param_conv: ClauseGoalTyp.gtyp = is_some_conv' param_conv


fun eq0 env pnode cur cc = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) cur of
             NONE => []
           | SOME (PPProver.E_L cur') => 
            (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) cc of
              NONE => []
              | SOME (PPProver.E_L cc') =>
                if (List.length cur' = List.length cc')
                then [env]
                else [])
  handle _ => [])
fun eq env pnode [ClauseGoalTyp.PVar pc, ClauseGoalTyp.PVar pcc] = eq0 env pnode pc pcc
| eq env pnode [ClauseGoalTyp.Var pc, ClauseGoalTyp.Var pcc] = eq0 env pnode pc pcc
| eq _ _ _ = []

 val clause_def = 
 "is_rec_conv(X) :- is_unary_conv(X)." ^
 "is_rec_conv(X) :- is_param_conv(X)." ^
 "is_rec_conv(X) :- is_binary_conv(X)." ^
 "is_rec_conv(X) :- is_pair_conv(X)." ^
 "more_rec(X) :- is_i_conv(X)." ^
 "more_rec(X) :- is_k_conv(X)." ^
 "more_rec(X) :- is_rec_conv(X)." ;

 val data = 
  default_gt_data
  |> ClauseGoalTyp.add_atomic "is_i_conv" is_i_conv
  |> ClauseGoalTyp.add_atomic "is_unary_conv" is_unary_conv
  |> ClauseGoalTyp.add_atomic "is_binary_conv" is_binary_conv
  |> ClauseGoalTyp.add_atomic "is_param_conv" is_param_conv
  |> ClauseGoalTyp.add_atomic "is_pair_conv" is_pair_conv
  |> ClauseGoalTyp.add_atomic "is_k_conv" is_k_conv
  |> ClauseGoalTyp.add_atomic "is_simp_conv" is_simp_conv
  |> ClauseGoalTyp.add_atomic "eq" eq
  
(*  |> ClauseGoalTyp.add_atomic "no_asm_to_strip" literal *)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);

val ps = PSGraph.read_json_file (SOME data) (pspath^"rec_conv.psgraph");

