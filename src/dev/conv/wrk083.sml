fun thm_frees (thm : THM) : TERM list = (
	frees (list_mk_± (concl thm :: asms thm))
);
new_error_message{id = 999001,
	text = "?0 is not of form ?1"};
new_error_message{id = 999002,
	text = "?0 expects a ?1-element argument list"};
new_error_message{id = 999003,
	text = "hd2 expects a list with at least 2 elements"};
fun dest_any (pattern : TERM, fun_name : string) : TERM -> TERM list = (
	let	val (f, args) = strip_app pattern;
		val arity = length args;
		fun strip_and_check tm = (
			let	val (g, args) = strip_app tm;
				val _ = term_match g f;
			in	if	length args = arity
				then	args
				else	fail "" 0 []
			end	handle Fail _ => (
				term_fail fun_name 999001 [tm, pattern]
			)
		);
	in	strip_and_check
	end
);
fun is_any (pattern : TERM) : TERM -> bool = (
	let	val dest = dest_any (pattern, "is_any");
	in	fn tm => (dest tm; true) handle Fail _ => false
	end
);
fun mk_any (pattern : TERM, fun_name : string) : TERM list -> TERM = (
	let	val (f, args) = strip_app pattern;
		val arity_s = string_of_int (length args);
		val ftys = map type_of args;
		fun match_arg_tys i (aty :: more_atys) (fty :: more_ftys) = (
			let	val i = type_match1 i aty fty;
			in	match_arg_tys i more_atys more_ftys
			end
		) | match_arg_tys i [] [] = (i
		) | match_arg_tys _ _ _ = (
			fail fun_name 999002 [fn () => arity_s]
		);
		fun match_and_apply tms = (
			let	val atys = map type_of tms;
				val i = match_arg_tys [] atys ftys;
				val f' = inst [] i f;
			in	list_mk_app (f', tms)
			end
		);
	in	match_and_apply
	end
);
fun hd2 (x :: y :: _ : 'a list) : 'a * 'a = (x, y)
|   hd2 _ = fail "hd2" 999003 [];
local 
	val old_thy = get_current_theory_name();
	val _ = open_theory"combin";
	val _ = push_pc"basic_hol1";
in
val mk_o : TERM * TERM -> TERM = (
	let	val mk = mk_any (¬(t1 : 'b ­ 'c) o (t2 : 'a ­ 'b)®, "mk_o");
	in	fn (t1, t2) => mk [t1, t2]
	end
);
val dest_o : TERM -> TERM * TERM = (
	let	val dest = dest_any (¬(t1 : 'b ­ 'c) o (t2 : 'a ­ 'b)®, "mk_o");
	in	hd2 o dest
	end
);
val is_o : TERM -> bool = is_any ¬(t1 : 'b ­ 'c) o (t2 : 'a ­ 'b)®;
val _ = open_theory old_thy;
end;
local 
	val old_thy = get_current_theory_name();
	val _ = open_theory"combin";
	val _ = push_pc"basic_hol1";
in

val i_rule_thm = snd ("i_rule_thm", (
set_goal([], ¬(Ìx· x) = CombI®);
a(rewrite_tac [get_spec¬CombI®]);
pop_thm()
));
val o_i_rule_thm = snd ("o_i_rule_thm", (
set_goal([], ¬µf·f o CombI = f®);
a(rewrite_tac [get_spec¬CombI®, get_spec¬$o®]);
pop_thm()
));
val k_rule_thm = snd ("k_rule_thm", (
set_goal([], ¬µc· (Ìx· c) = CombK c®);
a(rewrite_tac [get_spec¬CombK®]);
pop_thm()
));
val unary_rule_thm = snd ("unary_rule_thm", (
set_goal([], ¬ µf t· (Ìx·f (t x)) = f o t ®);
a(rewrite_tac[o_def]);
pop_thm()
));
val pair_rule_thm = snd ("pair_rule_thm", (
set_goal([], ¬ µs t· (Ìx·(s x, t x)) = Pair(s, t)®);
a(rewrite_tac[pair_def, o_def, uncurry_def]);
pop_thm()
));
val binary_rule_thm = snd ("binary_rule_thm", (
set_goal([], ¬ µf s t· (Ìx·f (s x) (t x)) = Uncurry f o Pair(s, t)®);
a(rewrite_tac[pair_def, o_def, uncurry_def]);
pop_thm()
));
val binary_rule_thm1 = snd ("binary_rule_thm1", (
set_goal([], ¬ µf c t· (Ìx·f c (t x)) = Uncurry f o Pair ((Ìx·c), t)®);
a(rewrite_tac[pair_def, o_def, uncurry_def]);
pop_thm()
));
val parametrized_rule_thm = snd ("parametrized_rule_thm", (
set_goal([], ¬ µf s p· (Ìx·f (s x) p) = (Ìx·f x p) o s®);
a(rewrite_tac[o_def]);
pop_thm()
));

val È_expand_thm : THM = prove_rule[]¬µf· f = Ìz· f z®;

val _ = pop_pc();
val _ = open_theory old_thy;
end (* of local ... in ... end *);
fun list_string_variant (avoid : string list) (ss : string list) : string list = (
	let	fun aux (s, (av, res)) = (
			let	val s' = string_variant av s;
			in	(s'::av, s'::res)
			end
		);
	in	rev(snd (revfold aux ss (avoid, [])))
	end
);
fun gen_µ_elim (tm : TERM) (thm : THM) : THM = (
	let	val tm_tyvs = term_tyvars tm;
		val (asms, conc) = dest_thm thm;
		val thm_tyvs = term_tyvars (mk_list(conc::asms));
		val thm_tyvs' = list_string_variant tm_tyvs thm_tyvs;
		val thm' = inst_type_rule (combine (map mk_vartype thm_tyvs') (map mk_vartype thm_tyvs)) thm;
	in	µ_elim tm thm'
	end
);
fun all_µ_intro1 (tm : TERM) (thm : THM) : THM = (
	let	val fvs = frees tm;
		val bvs = thm_frees thm diff fvs;
	in	list_µ_intro bvs thm
	end
);


fun morphism_conv
	{unary : TERM list, binary : TERM list, parametrized : TERM list}
	: CONV = (
	let	val unary_thms = map (fn t => all_µ_intro1 t (gen_µ_elim t unary_rule_thm))
			unary;
		val binary_thms = map (fn t => all_µ_intro1 t (gen_µ_elim t binary_rule_thm))
			binary;
		val binary_thms1 = map (fn t => all_µ_intro1 t (gen_µ_elim t binary_rule_thm1))
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
		val simp_conv = simple_eq_match_conv o_i_rule_thm;
		val rec rec_conv = (fn t =>
			((i_conv ORELSE_C
			k_conv ORELSE_C
			(pair_conv THEN_C RAND_C(RANDS_C(TRY_C rec_conv))) ORELSE_C
			(unary_conv THEN_TRY_C RIGHT_C rec_conv) ORELSE_C
			(binary_conv THEN_C RIGHT_C (RAND_C(RANDS_C (TRY_C rec_conv)))) ORELSE_C
			(parametrized_conv THEN_C RIGHT_C (TRY_C rec_conv)))
				AND_OR_C simp_conv) t
		);
	in	Ì_unpair_conv AND_OR_C rec_conv
	end
);

val  È_expand_conv : CONV = (fn tm => (
	if	is_Ì tm
	then	fail_conv
	else	simple_eq_match_conv È_expand_thm) tm);


val unpair_rewrite_tac : THM list -> TACTIC = 
	rewrite_tac o map (conv_rule (TRY_C (MAP_C Ì_unpair_conv)));
fun basic_morphism_tac
	{
		unary : TERM list,
		binary : TERM list,
		parametrized : TERM list,
		facts : THM list,
		witness_tac : TACTIC} : THM list -> TACTIC = (
	let	val m_conv = morphism_conv {unary = unary, binary = binary, parametrized = parametrized};
		val is_rule = is_´ o snd o strip_µ o concl;
		val rule_thms = facts drop (not o is_rule);
		val axiom_thms = facts drop is_rule;
	in	fn rw_thms =>
			TRY (conv_tac (LEFT_C È_expand_conv))
		THEN	TRY (unpair_rewrite_tac rw_thms)
		THEN	conv_tac (LEFT_C m_conv)	
		THEN 	(REPEAT o CHANGED_T) (
				(TRY o bc_tac) rule_thms
			THEN	TRY witness_tac
			THEN	REPEAT strip_tac
			THEN	(TRY o rewrite_tac) axiom_thms)
	end
);
fun object_by_type (ocs : (string list * TERM) list) : TYPE -> TERM = (
	let	fun preprocess acc [] = acc
		|   preprocess acc ((tvs, oc) :: more) = (
			let	val rev_tys = rev(strip_­_type (type_of oc));
				val res_ty = hd (rev_tys);
				val tysubs0 = map (fn tv => (mk_vartype tv, mk_vartype tv)) tvs;
				val arg_tys = rev (tl rev_tys);
			in	preprocess ((res_ty,  (oc, tysubs0, arg_tys)) :: acc) more
			end
		);
		val table = preprocess [] ocs;
		fun solve [] ty = fail "object_by_type" 1005 []
		|   solve ((res_ty, (oc, tysubs0, arg_tys)) :: more) ty = (
			let	val recur = solve table;
				val tysubs = type_match1 tysubs0 ty res_ty;
				val args = map (recur o inst_type tysubs) arg_tys;
				val ioc = inst [] tysubs oc;
			in	list_mk_app(ioc, args)
			end	handle Fail _ => solve more ty
		);
	in	solve table
	end
);
fun ¶_object_by_type_tac (ocs : (string list * TERM) list) : TACTIC = (
	let	val witness_by_type = object_by_type ocs;
	in	fn gl as (_, conc) => 
		let	val (x, _) = dest_simple_¶ conc;
		in	(simple_¶_tac o witness_by_type o type_of) x gl
		end
	end
);

local
fun bc_rule (th : THM) : THM = (
	let	val (ant, suc) = dest_´ (concl th);
		fun aux (v :: vs) a th = (
			let	val (a', th') = aux vs a th;
				val a'' = mk_simple_¶ (v, a');
				val th1 = asm_rule a'';
				val th2 = simple_¶_elim v th1 th';
			in	(a'', th2)
			end
		) | aux [] a th = (a, th);
	in	case frees ant term_diff
		(flat(map frees(suc :: asms th))) of
		[] => th
		|	vs => (
			let	val (a,th1) = aux vs ant (undisch_rule th);
				val th2 = ´_intro a th1;
			in	th2
			end
		)
	end
);
in
fun ho_bc_thm_tac (thm : THM) : TACTIC = ( 
	let	val thm0 = all_µ_elim thm;
		val thm1 = all_µ_intro(
			if	is_´(concl thm0)
			then	thm0
			else	fst (¤_elim thm0))
			handle Fail _ => thm_fail "bc_thm_tac" 29012 [thm];
		val (bvs, _) =  strip_µ(concl thm1);
	in
	fn gl as (_, conc) =>
	let	val nbvs = list_variant (frees conc) bvs;
		val thm2 = list_µ_elim nbvs thm1;
		val (_, suc) = dest_´(concl thm2);
		val (tym, tmm) = simple_ho_match [] conc suc
			handle Fail _ => term_fail "bc_thm_tac" 29011 [suc];
		val thm3 = asm_inst_term_rule tmm (asm_inst_type_rule tym thm2);
		val thm4 = conv_rule (TRY_C
				(LEFT_C all_simple_Â_conv AND_OR_C
					RIGHT_C simple_Â_È_norm_conv)) thm3;
		val thm5 = bc_rule thm4;
	in	TRY (conv_tac simple_Â_È_norm_conv) THEN ´_thm_tac thm5
	end	gl
	end
);
end;
