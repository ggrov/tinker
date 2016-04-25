open_theory "topology";  
use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
  val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";
  val pspath = tinker_path ^ "src/dev/JFR/psgraph/conv/";
  open ListUtilities; (* this structure is from pp, and it is overrideed by psgraph*)

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


val fst_const : TERM = ¬Fst®;
val snd_const : TERM = ¬Snd®;
val product_t_const : TERM = ¬$¸‰T®;
in
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
(* definition of tactic *)
val simp_conv = simple_eq_match_conv o_i_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;
fun lift_conv ([PPProver.A_Conv c, PPProver.A_L pos]) =
  let 
   val pos': (CONV->CONV) list = map (fn PPProver.A_L l => l) pos 
    |> List.concat |> map (fn PPProver.A_CConv1 cc => cc)
   val conv : CONV = List.foldr (fn (a,b) => a b) c pos'
  in 
    conv_tac conv
  end
|   lift_conv _ = raise RunCall.Fail "Conversion Fails";

(****************************************************)
(* definition of env tactic *)
fun ENV_init_args [PPProver.A_Var unary, PPProver.A_Var binary, PPProver.A_Var param, PPProver.A_Var facts, PPProver.A_Var rw] env: PPProver.env list = 
 StrName.NTab.update (unary, map PPProver.E_Trm XXX |> PPProver.E_L) env
 |> StrName.NTab.update (unary, map PPProver.E_Trm XXX |> PPProver.E_L)
 |> StrName.NTab.update (binary, map PPProver.E_Trm XXX |> PPProver.E_L)
 |> StrName.NTab.update (param, map PPProver.E_Trm XXX |> PPProver.E_L)
 |> StrName.NTab.update (facts, map PPProver.E_Thm XXX |> PPProver.E_L)
 |> StrName.NTab.update (rw, map PPProver.E_Thm XXX |> PPProver.E_L)
 |> (fn x => [x])
|   ENV_init_args _ _ = [];

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
  in 
   [StrName.NTab.update (v, new_pos' :: pos) env]
  end
|   ENV_push _ _ = [];

fun ENV_pop [PPProver.A_Var v] env = 
 StrName.NTab.get env v
 |> tl
 |> (fn x => [StrName.NTab.update (v, x) env])
|   ENV_pop _ _ = [];

(****************************************************)
(* definition of gt *)
 val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z). ";

 val data = 
  default_gt_data
(*  |> ClauseGoalTyp.add_atomic "no_asm_to_strip" literal *)
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);

(****************************************************)
val ps = PSGraph.read_json_file (SOME data) (pspath^"basic_morphism.psgraph");

witness_tac;
(* definition of the GT *)
is_simp_conv(?rec)
not_simp_conv(?rec)




basic_morphism_tac;

  fun lift_conv_tac (conv : CONV) (conv_args : CONV) TACTIC = 
    (fn (assms, g) => 
      let 
        val thm = conv_args g
        val trm = PPProver.concl_of_thm thm |> PPTermLib.subtrm_of_pos [1];
      in
        pure_rewrite_tac [conv trm] (assms, g)
      end);
      
  fun gen_pre_post_conv (conv : CONV) conv_args = 
   let 
    val thm = PPProver.concl_of_thm (conv trm)
   in
    PPTermLib.strip_comb thm  (* pred, post *)
   end;
   
   val gen_pre_conv = snd o gen_pre_post_conv;
   val gen_post_conv = fst o gen_pre_post_conv;


(* definition of rec conv which is the trick conv to be lifed to tactic *)
i_rule_thm;
val rec rec_conv = 
(fn t =>
  ((i_conv ORELSE_C
	k_conv ORELSE_C
			(pair_conv THEN_C RAND_C(RANDS_C(TRY_C rec_conv))) ORELSE_C
			(unary_conv THEN_TRY_C RIGHT_C rec_conv) ORELSE_C
			(binary_conv THEN_C RIGHT_C (RAND_C(RANDS_C (TRY_C rec_conv)))) ORELSE_C
			(parametrized_conv THEN_C RIGHT_C (TRY_C rec_conv)))
				AND_OR_C simp_conv) t
		);


fun basic_continuity_tac (thms : THM list): TACTIC = (fn gl as (asms, _) =>
	basic_morphism_tac (continuity_params (thms @ map asm_rule asms)) [] gl
);

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