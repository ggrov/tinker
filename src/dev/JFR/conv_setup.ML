
(****************************************************)
(* some required definitions in 083 and 067 *)
fun all_µ_intro1 (tm : TERM) (thm : THM) : THM = (
	let	val fvs = frees tm;
		val bvs = thm_frees thm diff fvs;
	in	list_µ_intro bvs thm
	end
);


(* local defintion in order to init params for basic moriphism *)
local  
val continuity_fact_thms : THM list = [
	product_topology_thm,
	_space_t_product_thm,
	fst_continuous_thm,
	snd_continuous_thm,
	i_continuous_thm,
	k_continuous_thm,
	pair_continuous_thm,
	o_continuous_thm];

val (unary_v, unary_p) = 
dest_pair ¬(x, x  (Á, Â) Continuous)®;

val (binary_v, binary_p) = dest_pair ¬(x, Uncurry x  (Á, Â) Continuous)®;
val (parametrized_v, parametrized_p) = dest_pair ¬(h, (Ì x· h x p)  (Á, Â) Continuous)®;
val (object_v, object_p) = dest_pair ¬(Á, Á  Topology)®;



val fst_const : TERM = ¬Fst®;
val snd_const : TERM = ¬Snd®;
in
val product_t_const : TERM = ¬$¸‰T®;
fun get_patterns
	(accs as (acc_u, acc_b, acc_p, acc_o)
		: TERM list * TERM list * TERM list * (string list * TERM) list)
	((thm :: more) : THM list)
	: TERM list * TERM list * TERM list * (string list * TERM) list = (
	let	val tm = (snd o strip_µ o concl) thm;
	in	let	val (tym, tmm) = term_match tm binary_p;
			val bin = subst tmm (inst [] tym binary_v);
		in	get_patterns (acc_u, bin::acc_b, acc_p, acc_o) more
		end	handle Fail _ =>
		let	val (tym, tmm) = term_match tm parametrized_p;
			val par = subst tmm (inst [] tym parametrized_v);
		in	get_patterns (acc_u, acc_b, par::acc_p, acc_o) more
		end	handle Fail _ =>
		let	val (tym, tmm) = term_match tm unary_p;
			val un = subst tmm (inst [] tym unary_v);
		in	get_patterns (un::acc_u, acc_b, acc_p, acc_o) more
		end	handle Fail _ =>
		let	val (tym, tmm) = term_match tm object_p;
			val ob = subst tmm (inst [] tym object_v);
			val tvs = (list_cup o map term_tyvars o asms) thm;
		in	get_patterns (acc_u, acc_b, acc_p, (tvs, ob)::acc_o) more
		end	handle Fail _ => get_patterns accs more
	end
) | get_patterns accs [] = accs;

fun continuity_params (thms : THM list) :
	{facts: THM list,
	 unary: TERM list,
	 binary: TERM list,
	 witness_tac: TACTIC,
	 parametrized: TERM list} = (
	let	val (uns, bins, pars, obs) = get_patterns ([], [], [], []) thms;
	in
		{unary = fst_const :: snd_const :: uns,
		 binary = bins,
		 parametrized = pars,
		 facts = thms @ continuity_fact_thms,
		 witness_tac = ¶_object_by_type_tac (([], product_t_const) :: obs)}
	end
);
end;

(****************************************************)
(* definition for the configuration for basic_continuity_tac *)
val bm_params : THM list = [];

fun witness_tac [PPProver.A_L thms] = 
  let val thms' = map (fn PPProver.A_Thm x => x) thms 
   val (_,_,_,obs) = get_patterns  ([], [], [], [])  thms' in
  ¶_object_by_type_tac (([], product_t_const) :: obs) end
| witness_tac _ = raise RunCall.Fail "witness_tac Fails due to unexpected params";

fun ENV_init_args [PPProver.A_Var unary, PPProver.A_Var binary, PPProver.A_Var par, PPProver.A_Var facts, PPProver.A_Var rw, PPProver.A_Var wt, PPProver.A_L_Trm hyps] env =
 let 
  val param : {binary: TERM list,
     facts: THM list,
     parametrized: TERM list, unary: TERM list, witness_tac: TACTIC} = (bm_params @ (map asm_rule hyps)) |> continuity_params;
  val p_unary: TERM list = (#unary param);
  val p_bin : TERM list= (#binary param);
  val p_param : TERM list = (#parametrized param);
  val p_facts : THM list = (#facts param);
  val p_wt = bm_params @ (map asm_rule hyps)
 in
 StrName.NTab.update (unary, map PPProver.E_Trm p_unary |> PPProver.E_L) env
 |> StrName.NTab.update (binary, map PPProver.E_Trm p_bin |> PPProver.E_L)
 |> StrName.NTab.update (par, map PPProver.E_Trm p_param |> PPProver.E_L)
 |> StrName.NTab.update (facts, map PPProver.E_Thm p_facts |> PPProver.E_L)
 |> StrName.NTab.update (rw, PPProver.E_L [])
 |> StrName.NTab.update (wt, map PPProver.E_Thm p_wt |> PPProver.E_L)
 |> (fn x => [x]) end
|   ENV_init_args _ _ = [];

(****************************************************)
(* definition of tactic *)
val i_conv = simple_eq_match_conv i_rule_thm;
val k_conv = simple_eq_match_conv k_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;

val simp_conv = simple_eq_match_conv o_i_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;
fun lift_conv ([PPProver.A_Conv c, PPProver.A_L pos]) =
  let 
   val cc :(CONV->CONV) = 
    map (fn PPProver.A_CConv1 cc => cc) pos
    |> List.foldr (op o) (fn x => x);
   val conv : CONV = cc c
  in 
    conv_tac conv
  end
|   lift_conv _ = raise RunCall.Fail "Conversion Fails due to unexpected params";


(****************************************************)
(* definition of env tactic *)

fun ENV_init_rule_axiom_thm [PPProver.A_Var rule, PPProver.A_Var ax, PPProver.A_L f] env = 
 let 
  val is_rule = is_´ o snd o strip_µ o concl 
  val facts = map (fn PPProver.A_Thm x => x) f
  val rule_thms = facts drop (not o is_rule);
  val axiom_thms = facts drop is_rule;
 in
   StrName.NTab.update (rule, map PPProver.E_Thm rule_thms|> PPProver.E_L) env
 |> StrName.NTab.update (ax, map PPProver.E_Thm axiom_thms |> PPProver.E_L)
 |> (fn x => [x])
 end  
|   ENV_init_rule_axiom_thm _ _ = [];

fun ENV_init [PPProver.A_Var cc, pos] env = 
 [StrName.NTab.update (cc, PPProver.arg_to_env pos) env]
|   ENV_init _ _ = [];

fun ENV_mk_thms [PPProver.A_L l, PPProver.A_Thm thm, PPProver.A_Var v] env = 
 let val trm_l = map (fn PPProver.A_Trm x => x) l in
  map (fn (t : TERM) => all_µ_intro1 t (gen_µ_elim t thm)) trm_l
  |> map PPProver.E_Thm
  |> PPProver.E_L
  |> (fn x => StrName.NTab.update (v,x) env)
  |> (fn x => [x])
 end
|   ENV_mk_thms _ _ = [];

fun ENV_mk_params [PPProver.A_L l, PPProver.A_Var v] env = 
 let val trm_l = map (fn PPProver.A_Trm x => x) l in
  map (switch gen_µ_elim parametrized_rule_thm) trm_l
  |> map PPProver.E_Thm
  |> PPProver.E_L
  |> (fn x => StrName.NTab.update (v,x) env)
  |> (fn x => [x])
 end
|   ENV_mk_params _ _ = [];

fun ENV_mk_conv [PPProver.A_Var unary, PPProver.A_Var bin, PPProver.A_Var param, PPProver.A_L uthm, PPProver.A_L bthm, PPProver.A_L bthm1, PPProver.A_L pthm ] env = 
 let 
  val de_cons = fn (PPProver.A_Thm x) => x
  val unary_thms = map de_cons uthm
  val binary_thms = map de_cons bthm
  val binary_thms1 = map de_cons bthm1
  val parametrized_thms = map de_cons pthm
  val unary_conv : CONV = FIRST_C (map simple_ho_eq_match_conv1 unary_thms)
   handle Fail _ => fail_conv;
  val binary_conv : CONV = FIRST_C (map simple_ho_eq_match_conv1 (binary_thms @ binary_thms1))
   handle Fail _ => fail_conv;
  val parametrized_conv : CONV = FIRST_C (map simple_ho_eq_match_conv1 parametrized_thms)
   handle Fail _ => fail_conv;
 in
   StrName.NTab.update (unary, PPProver.E_Conv unary_conv) env
   |> StrName.NTab.update (bin, PPProver.E_Conv binary_conv)
   |> StrName.NTab.update (param, PPProver.E_Conv parametrized_conv)
   |> (fn x => [x])
 end
|   ENV_mk_conv _ _ = [];

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

(****************************************************)
(* definition of gt *)
 fun strip_E_Thm (PPProver.E_Thm th) = th;
 fun strip_E_CC (PPProver.E_CConv1 cc) = cc;

 fun pred_of_conv conv : ClauseGoalTyp.gtyp = 
  fn env => fn pnode => fn _ => (conv (PPProver.get_pnode_concl pnode); [env])
 handle BasicError.Fail msg => [];
 fun neg_pred_of_conv conv : ClauseGoalTyp.gtyp = 
  fn env => fn pnode => fn _ =>(conv (PPProver.get_pnode_concl pnode); [])
 handle BasicError.Fail msg => [env];

 val is_left_eta_conv = pred_of_conv (LEFT_C È_expand_conv);
 val not_left_eta_conv = neg_pred_of_conv(LEFT_C È_expand_conv);

 fun is_unpair env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_L th) => 
              (unpair_rewrite_tac (map strip_E_Thm th) (PPProver.get_pnode_hyps pnode, PPProver.get_pnode_concl pnode);[env])
  handle _ => [])
| is_unpair _ _ _ = [];

 fun not_unpair env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_L th) => 
              (unpair_rewrite_tac (map strip_E_Thm th) (PPProver.get_pnode_hyps pnode, PPProver.get_pnode_concl pnode);[])
  handle _ => [env])
| not_unpair _ _ _ = [];

val is_lambda_pair = pred_of_conv Ì_unpair_conv;
val not_lambda_pair = neg_pred_of_conv Ì_unpair_conv;

fun is_some_conv' c env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_L cc) => 
              (map strip_E_CC cc) 
              |> List.foldr (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env]))
  handle _ => [])
| is_some_conv' _ _ _ _ = [];

fun is_some_conv env pnode [ClauseGoalTyp.PVar pc, ClauseGoalTyp.PVar pcc] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pcc of
             NONE => []
           | SOME (PPProver.E_L cc) => 
            (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pc of
              NONE => []
              | SOME (PPProver.E_Conv c) =>
              (map strip_E_CC cc) 
              |> List.foldr (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env])))
  handle _ => [])
| is_some_conv env pnode [ClauseGoalTyp.Var pc, ClauseGoalTyp.Var pcc] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pcc of
             NONE => []
           | SOME (PPProver.E_L cc) => 
            (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pc of
              NONE => []
              | SOME (PPProver.E_Conv c) =>
              (map strip_E_CC cc) 
              |> List.foldr (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env])))
  handle _ => [])
| is_some_conv _ _ _ = [];

val is_i_conv : ClauseGoalTyp.gtyp = is_some_conv' i_conv
val is_k_conv : ClauseGoalTyp.gtyp = is_some_conv' k_conv
val is_pair_conv : ClauseGoalTyp.gtyp = is_some_conv' pair_conv
val is_simp_conv: ClauseGoalTyp.gtyp = is_some_conv' simp_conv


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
  |> ClauseGoalTyp.add_atomic "is_left_eta_conv" is_left_eta_conv
  |> ClauseGoalTyp.add_atomic "not_left_eta_conv" not_left_eta_conv
  |> ClauseGoalTyp.add_atomic "is_unpair" is_unpair
  |> ClauseGoalTyp.add_atomic "not_unpair" not_unpair
  |> ClauseGoalTyp.add_atomic "is_lambda_pair" is_lambda_pair
  |> ClauseGoalTyp.add_atomic "not_lambda_pair" not_lambda_pair
  |> ClauseGoalTyp.add_atomic "is_i_conv" is_i_conv
  |> ClauseGoalTyp.add_atomic "is_unary_conv" is_unary_conv
  |> ClauseGoalTyp.add_atomic "is_binary_conv" is_binary_conv
  |> ClauseGoalTyp.add_atomic "is_param_conv" is_param_conv
  |> ClauseGoalTyp.add_atomic "is_pair_conv" is_pair_conv
  |> ClauseGoalTyp.add_atomic "is_k_conv" is_k_conv
  |> ClauseGoalTyp.add_atomic "is_some_conv" is_some_conv
  |> ClauseGoalTyp.add_atomic "is_simp_conv" is_simp_conv
  |> ClauseGoalTyp.add_atomic "eq" eq
  
(*  |> ClauseGoalTyp.add_atomic "no_asm_to_strip" literal *)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);


(*
  fun is_goal env pnode [ClauseGoalTyp.PVar p] =
   (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_Trm t) => if t = (PPProver.get_pnode_concl pnode) then [env] else []
           | SOME _ => [])
  | is_goal env pnode [ClauseGoalTyp.Var p] =
   (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (PPProver.E_Trm t) => if t = (PPProver.get_pnode_concl pnode) then [env] else []
           | SOME _ => [])
  | is_goal env pnode [ClauseGoalTyp.Name trm_str] = 
    if (PPProver.trm_of_string PPProver.default_ctxt trm_str) = (PPProver.get_pnode_concl pnode) 
    then [env] 
    else []
  | is_goal _ _ _ = [];
*)