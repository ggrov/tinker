open ListUtilities;
structure PP_Taut = struct
fun ±_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val thm1 = ±_left_elim thm;
		val thm2 = ±_right_elim thm;
	in	ttac1 thm1 THEN ttac2 thm2
	end
	handle ex => divert ex "±_left_elim" "±_THEN2" 28032 
		[fn () => string_of_thm thm]
);
fun ±_THEN (ttac : THM -> TACTIC) : THM -> TACTIC = (fn thm => 
	(±_THEN2 ttac ttac thm)
	handle ex => pass_on ex "±_THEN2" "±_THEN"
);
fun ²_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val (t1, t2) = dest_²(concl thm);
	in	(fn (seqasms, conc) =>
			let	val (sgs1, pf1) = ttac1 (asm_rule t1) (seqasms, conc);
				val (sgs2, pf2) = ttac2 (asm_rule t2) (seqasms, conc);
			in	(sgs1 @ sgs2,
				(fn thl =>
					let	val len = length sgs1;
					in ²_elim thm (pf1(thl to (len - 1))) 
					  (pf2(thl from len))
					end
				))
			end)
	end
	handle ex => divert ex "dest_²" "²_THEN2" 28042 
		[fn () => string_of_thm thm]
);
fun ²_THEN (ttac : THM -> TACTIC) (thm : THM) : TACTIC = (
	²_THEN2 ttac ttac thm
	handle complaint =>
	pass_on complaint "²_THEN2" "²_THEN"
);
fun CASES_T2 (t1 : TERM) (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
					: TACTIC = (fn gl as (seqasms, conc) =>
	let	val (sgs1, pf1) = ttac1 (asm_rule t1) (seqasms, conc);
		val (sgs2, pf2) = ttac2 (asm_rule (mk_³ t1)) (seqasms, conc);
	in	(sgs1 @ sgs2,
		(fn thl =>
			let	val len = length sgs1;
			in	asm_elim t1 (pf1(thl to (len - 1))) (pf2(thl from len))
			end
			))
	end
	handle ex => (
		if area_of ex = "asm_rule"
		then term_fail "CASES_T2" 28022 [t1]
		else raise ex
	)
);
fun CASES_T (t1 : TERM) (ttac : THM -> TACTIC) : TACTIC = (fn gl =>
	((CASES_T2 t1 ttac ttac) gl)
	handle ex => pass_on ex "CASES_T2" "CASES_T"
);
fun ´_T (ttac : THM -> TACTIC) : TACTIC = (fn (seqasms, conc) =>
	let	val (t1, t2) = dest_´ conc;
		val (sgs, pf) = ttac (asm_rule t1) (seqasms, t2);
	in	(sgs, ´_intro t1 o pf)
	end
	handle ex => divert ex "dest_´" "´_T" 28051 []
);
fun SIMPLE_¶_THEN (ttac : THM -> TACTIC) = (fn thm =>
	let	val (x, b) = dest_simple_¶(concl thm);
	in	(fn (seqasms, conc) =>
			let	val x' = variant (flat(map frees
				(conc :: concl thm :: asms thm @ seqasms))) x;
				val (sgs, pf) = ttac (asm_rule (var_subst[(x', x)] b)) 
					(seqasms, conc);
			in	(sgs, 
				(fn thm1 =>
				simple_¶_elim x' thm thm1
				handle complaint =>
				divert complaint 
					"simple_¶_elim" 
					"SIMPLE_¶_THEN"
					28094
					[fn () => string_of_term x',
					fn () => string_of_thm thm1,
					fn () => string_of_term x]
					) o pf)
			end)
	end
	handle ex => divert ex "dest_simple_¶" "SIMPLE_¶_THEN" 28093 
		[fn () => string_of_thm thm]
);
val t_tac : TACTIC = (fn gl =>
	accept_tac t_thm gl
	handle complaint =>
	divert complaint "accept_tac" "t_tac" 28011 []
);
val ¤_t_tac : TACTIC = (fn (seqasms, conc) => 
	let	val (lhs, rhs) = dest_eq conc;
	in	if rhs =$ mk_t
		then	([(seqasms, lhs)],
			 fn [th] => ¤_t_intro th | _ => bad_proof "¤_t_tac")
		else if lhs =$ mk_t
		then	([(seqasms, rhs)],
			 fn [th] => eq_sym_rule(¤_t_intro th) | _ => bad_proof "¤_t_tac")
		else fail "¤_t_tac" 28012 []
	end	handle Fail _ => fail "¤_t_tac" 28012 []
);
val i_contr_tac : TACTIC = (fn (seqasms, conc) => 
	([(seqasms, mk_f)],
	 fn [th] => contr_rule conc th | _ => bad_proof "i_contr_tac")
);
fun f_thm_tac (thm : THM) : TACTIC = (fn gl as (_, conc) => 
	let	val thm1 = contr_rule conc thm
	in	accept_tac thm1 gl
	end
	handle	ex => divert ex "contr_rule" "f_thm_tac" 28021 
		[fn () => string_of_thm thm]
);
val ±_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (t1, t2) = dest_± conc
	in	([(seqasms, t1), (seqasms, t2)],
			 fn [th1, th2] => ±_intro th1 th2
			 |   _ => bad_proof "±_tac" )
	end handle ex => divert ex "dest_±" "±_tac" 28031 []
);
val  ²_left_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (a, b) = dest_² conc
	in	([(seqasms, a)],
			 fn [th] => ²_right_intro b th
			 |   _ => bad_proof "²_left_tac" )
	end handle ex => divert ex "dest_²" "²_left_tac" 28041 []
);
val  ²_right_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (a, b) = dest_² conc
	in	([(seqasms, b)],
			 fn [th] => ²_left_intro a th
			 |   _ => bad_proof "²_right_tac" )
	end handle ex => divert ex "dest_²" "²_right_tac" 28041 []
);
val ¤_thm = ( (* ô µ a b · (a ¤ b) ¤ (a ´ b) ± (b ´ a) *)
save_thm("¤_thm",
let
	val thm1 = asm_rule ¬(a ´ b) ± (b ´ a)®; 
	val thm2 = ¤_intro(±_left_elim thm1) (±_right_elim thm1);
	val (thm3, thm4) = ¤_elim(asm_rule¬a ¤ b®);
	val thm5 = ±_intro thm3 thm4;
in
	list_simple_µ_intro[¬a:BOOL®, ¬b:BOOL®]
		(¤_intro(all_´_intro thm5)(all_´_intro thm2))
end));
fun asm_ante_tac (t1 : TERM) : TACTIC = (fn (seqasms, conc) =>
	(if t1 term_mem seqasms
	then ([(seqasms term_less t1, mk_´(t1, conc))],
		(fn [thm] => undisch_rule thm | _ => bad_proof "asm_ante_tac"))
	else  term_fail "asm_ante_tac" 28052 [t1])
	handle ex => divert ex "mk_´" "asm_ante_tac" 28055 []
);
local
	fun try_asm_ante_tac allasms asm : TACTIC = (fn (seqasms,conc) =>
	asm_ante_tac asm (seqasms,conc)
	handle complaint as (Fail _) =>
	if asm term_mem allasms andalso type_of asm =: BOOL
		andalso type_of conc =: BOOL
	then id_tac  (seqasms,conc)
	else pass_on complaint "asm_ante_tac" "list_asm_ante_tac"
	);
	fun try_asm_ante_tac1 asm : TACTIC = (fn (seqasms,conc) =>
	asm_ante_tac asm (seqasms,conc)
	handle complaint as (Fail _) =>
	if type_of asm =: BOOL andalso type_of conc =: BOOL
	then id_tac  (seqasms,conc)
	else pass_on complaint "asm_ante_tac" "all_asm_ante_tac"
	);
in
fun list_asm_ante_tac (lasms : TERM list):  TACTIC = (fn (seqasms,conc) =>
	MAP_EVERY (try_asm_ante_tac seqasms) (rev lasms) (seqasms,conc)
);

val all_asm_ante_tac :  TACTIC = (fn (seqasms,conc) =>
	MAP_EVERY (try_asm_ante_tac1) seqasms (seqasms,conc)
);
end;
fun ante_tac (thm : THM) : TACTIC = (fn (seqasms, conc) =>
	([(seqasms, mk_´(concl thm, conc))],
	 fn [th] => ´_elim th thm | _ => bad_proof "ante_tac")
	handle ex => divert ex "mk_´" "ante_tac" 28027 []
);
val simple_µ_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (x, b) = dest_simple_µ conc;
		val x' = variant (flat(map frees(conc::seqasms))) x;
	in
		([(seqasms, var_subst[(x', x)] b)],
		(fn [thm] => simple_µ_intro x' thm | _ => bad_proof "simple_µ_tac"))
	end handle ex => divert ex "dest_simple_µ" "simple_µ_tac" 28081 []
);
fun intro_µ_tac ((t1, x) : (TERM * TERM)) : TACTIC = (fn (seqasms, conc) =>
	let	val dummy = if t1 =$ x orelse
			not(is_free_in x conc)
			then ()
			else term_fail "intro_µ_tac" 28083 [x,t1];
		val t' = subst[(x, t1)] conc;
	in	if if is_var t1 then not (is_free_in t1 conc) else t' =$ conc
		then	term_fail "intro_µ_tac" 28082 [t1]
		else	([(seqasms, mk_simple_µ(x, t'))],
			(fn [thm] => simple_µ_elim t1 thm | _ => bad_proof "intro_µ_tac"))
	end handle ex => (
		let val area = area_of ex;
		in	if area = "subst" orelse area = "mk_simple_µ"
			then reraise ex "intro_µ_tac" 
			else raise ex
		end
	)
);
fun intro_µ_tac1 (x : TERM) : TACTIC = (
	intro_µ_tac (x, x)
);
fun simple_¶_tac (tm : TERM) : TACTIC = (fn (seqasms, conc) =>
	let	val (x, b) = dest_simple_¶ conc;
	in
		([(seqasms, var_subst[(tm, x)] b)],
		(fn [thm] => simple_¶_intro conc thm | _ => bad_proof "simple_¶_tac"))
	end
	handle ex =>
	case area_of ex of
		"var_subst" => term_fail "simple_¶_tac" 28092 [tm]
	|	"dest_simple_¶" => fail "simple_¶_tac" 28091 []
	|	_ => raise ex
);
fun check_asm_tac (thm : THM) : TACTIC = (fn gl as (seqasms, conc) =>
	let	val t = concl thm;
	in	if t ~=$ conc
		then accept_tac thm
		else if is_t t
		then id_tac
		else if is_f t
		then f_thm_tac thm
		else if is_³ t
		then	let	val t' = dest_³ t;
				fun aux (asm :: more) = (
					if t ~=$ asm
					then id_tac
					else if asm ~=$ t'
					then accept_tac (³_elim conc (asm_rule asm) thm)
					else if asm ~=$ conc
					then accept_tac (asm_rule asm)
					else aux more
				) | aux [] = asm_tac thm;
			in	aux seqasms
			end
		else	let	fun aux (asm :: more) = (
					if t ~=$ asm
					then id_tac
					else if is_³ asm andalso (dest_³ asm) ~=$ t
					then accept_tac (³_elim conc thm (asm_rule asm))
					else if asm ~=$ conc
					then accept_tac (asm_rule asm)
					else aux more
					) | aux [] = asm_tac thm;
			in	aux seqasms
			end
	end	gl
);
val concl_in_asms_tac : TACTIC = (fn gl as (seqasms, conc) =>
	if conc term_mem seqasms
	then accept_tac (asm_rule conc) gl
	else fail "concl_in_asms_tac" 28002 []
);
val STRIP_THM_THEN : THM_TACTICAL = (fn ttac:THM_TACTIC => 
	fn thm :THM =>
	(FIRST_TTCL[CONV_THEN (current_ad_st_conv()),
		±_THEN, 
		²_THEN, 
		SIMPLE_¶_THEN]
	ORELSE_TTCL
		FAIL_WITH_THEN "STRIP_THM_THEN" 28003 
			[fn () => string_of_thm thm])
	ttac
	thm
);
fun STRIP_CONCL_T (ttac : THM_TACTIC) : TACTIC = (fn gl =>
	(FIRST[ conv_tac(current_ad_sc_conv()),
		simple_µ_tac,
		±_tac,
		´_T ttac,
		t_tac,
		concl_in_asms_tac]
	ORELSE_T
		fail_with_tac "STRIP_CONCL_T" 28003 
		[fn () => string_of_term(snd gl)])
	gl
);
val (strip_concl_conv : CONV) = (fn (tm : TERM) =>
	current_ad_sc_conv() tm
	handle (Fail _) =>
	term_fail "strip_concl_conv" 28003 [tm]
);
val (strip_asm_conv : CONV) = (fn (tm : TERM) =>
	current_ad_st_conv() tm
	handle (Fail _) =>
	term_fail "strip_asm_conv" 28003 [tm]
);
val STRIP_T : THM_TACTIC -> TACTIC = STRIP_CONCL_T;
val strip_asm_tac : THM_TACTIC =
	REPEAT_TTCL STRIP_THM_THEN check_asm_tac;
val  strip_concl_tac : TACTIC = (fn gl => 
	STRIP_CONCL_T strip_asm_tac gl
	handle complaint =>
	pass_on complaint "STRIP_CONCL_T" "strip_tac");
val  strip_tac : TACTIC = strip_concl_tac; 
val local_strip_thm_thens : EQN_CXT =
	[ (thm_eqn_cxt ¤_thm) ];
val local_strip_concl_ts : EQN_CXT =
	[ (thm_eqn_cxt ¤_thm) ];

val _ = set_pc "'propositions";
val ²_³_thm = tac_proof( ([], ¬µa b·(a ² ³b) ¤ (b ´ a)®),
	REPEAT strip_tac);
val simple_¶‰1_conv : CONV = (fn tm =>
	let	val (x, b) = dest_simple_¶‰1 tm
		val s1 = ´_intro tm (simple_¶‰1_elim (asm_rule tm));
		val y = variant (x :: frees b) x;
		val conj = mk_±(b, mk_µ(y, mk_´(var_subst[(y, x)]b, mk_eq(y, x))));
		val exi = mk_¶(x, conj)
		val s2 = asm_rule conj;
		val s3 = simple_¶‰1_intro (±_left_elim s2) (±_right_elim s2)
		val s4 = simple_¶_elim x (asm_rule exi) s3
		val s5 = ´_intro exi s4;
	in	¤_intro s1 s5
	end handle ex => pass_on ex "dest_simple_¶‰1" "simple_¶‰1_conv"
);
val ³_simple_¶‰1_conv : CONV = (fn tm =>
	((RAND_C simple_¶‰1_conv THEN_C ³_simple_¶_conv) tm)
	handle  Fail _ => term_fail "³_simple_¶‰1_conv" 28091 [tm]
);
local
	val c = eqn_cxt_conv ((map thm_eqn_cxt
		[³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm,
		 ³_¤_thm, ³_if_thm, ³_t_thm, ³_f_thm]) @
		[(¬³(µ x · y)®, ³_simple_µ_conv),
		(¬³(¶ x · y)®, ³_simple_¶_conv),
		(¬³(¶‰1 x · y)®, ³_simple_¶‰1_conv)]);
in
val simple_³_in_conv : CONV = (fn tm =>
	c tm
	handle complaint =>
	divert complaint "eqn_cxt_conv" "simple_³_in_conv" 28131
		[fn () => string_of_term tm]
);
end;
val SIMPLE_³_IN_THEN : THM_TACTICAL = (fn ttac => fn thm =>
	(ttac(¤_mp_rule(simple_³_in_conv(concl thm))thm))
	handle complaint => 
	divert complaint "simple_³_in_conv" "SIMPLE_³_IN_THEN" 28026 []
);
val simple_³_in_tac : TACTIC = (fn gl => 
	((conv_tac simple_³_in_conv) gl)
	handle complaint => 
	divert complaint "simple_³_in_conv" "simple_³_in_tac" 28025 []
);
val ´_THEN : THM_TACTICAL = (fn ttac => fn thm =>
	let	val (t1, t2) = dest_´ (concl thm)
	in	ttac(¤_mp_rule(list_simple_µ_elim[t1, t2]´_thm)thm)
	end	handle ex => 
	divert ex "dest_´" "´_THEN" 28054 [fn () => string_of_thm thm]
);
val a_²_³b_thm = ²_³_thm;

val ³a_²_b_thm = list_simple_µ_intro[¬a:BOOL®, ¬b:BOOL®]
	(eq_sym_rule(all_simple_µ_elim ´_thm));

val a_²_b_thm = (
	conv_rule(MAP_C(simple_eq_match_conv ³_³_thm))
	(list_simple_µ_intro[¬a:BOOL®, ¬b:BOOL®]
	(eq_sym_rule(list_simple_µ_elim[¬³a®, ¬b:BOOL®]´_thm)))
);

local
val ²_conv = FIRST_C(map simple_eq_match_conv
	[a_²_³b_thm,
	³a_²_b_thm,
	a_²_b_thm]);
in
val ²_tac = conv_tac(²_conv);
end;
val local_if_thm =  
let	val s1 = asm_rule ¬(a ´ t1) ± (³ a ´ t2)®;
	val s2 = ±_left_elim s1;
	val s3 = ±_right_elim s1;
	val s4 = undisch_rule s2;
	val s5 = undisch_rule s3;
	val s6 = if_intro ¬a:BOOL® s4 s5;
	val s7 = all_´_intro s6;
	val s8 = asm_rule ¬if a then t1 else t2: BOOL®;
	val s9 = if_then_elim s8;
	val s10 = if_else_elim s8;
	val s11 = ±_intro s9 s10;
	val s12 = all_´_intro s11;
	val s13 = ¤_intro s12 s7;
	val s14 = all_µ_intro s13;
in	s14
end;
local	val s1 = refl_conv ¬x:'a®;
	val s2 = ¤_t_intro s1;
	val s3 = app_fun_rule ¬$³® s2;
	val s4 = eq_trans_rule s3 ³_t_thm;
in
val local_eq_thm1 = simple_µ_intro ¬x:'a® s2;
val local_eq_thm2 = simple_µ_intro ¬x:'a® s4;
end;
val propositions_st_eqn_cxt : EQN_CXT =
	[	(thm_eqn_cxt ´_thm),
		(thm_eqn_cxt ¤_thm),
		(thm_eqn_cxt local_if_thm),
		(thm_eqn_cxt local_eq_thm1),
		(thm_eqn_cxt local_eq_thm2),
		(¬¶‰1 x · p®, simple_¶‰1_conv)];
val propositions_sc_eqn_cxt : EQN_CXT =
	[	(thm_eqn_cxt ¤_thm),
		(thm_eqn_cxt a_²_³b_thm),
		(thm_eqn_cxt ³a_²_b_thm),
		(thm_eqn_cxt a_²_b_thm),
		(thm_eqn_cxt local_eq_thm1),
		(thm_eqn_cxt local_eq_thm2),
		(thm_eqn_cxt local_if_thm)];


val if_thm = save_thm("if_thm",
	tac_proof( ([],
	¬µ a b c · (if a then b else c) ¤ 
		(a ± b ² ³ a ± c)®),
	(asm_prove_tac [])));

val taut_strip_thm_conv : CONV = (
	eqn_cxt_conv(
	map thm_eqn_cxt
	[³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm,
	 ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm,
	´_thm, ¤_thm, local_if_thm
]));

val taut_strip_concl_conv : CONV = (
	eqn_cxt_conv(
	map thm_eqn_cxt
	[³_³_thm, ³_±_thm, ³_²_thm, ³_´_thm,
	 ³_¤_thm, ³_t_thm, ³_f_thm, ³_if_thm,
	¤_thm, local_if_thm,
	a_²_³b_thm, ³a_²_b_thm, a_²_b_thm]
));

val taut_strip_thm_thens : THM_TACTICAL list = [
	±_THEN,
	²_THEN,
	CONV_THEN taut_strip_thm_conv
];

val taut_strip_concl_ts : (THM_TACTIC -> TACTIC) list = [
	fn _ => ±_tac,
	´_T,
	fn _ => t_tac,
	fn _ => conv_tac taut_strip_concl_conv,
	fn _ => concl_in_asms_tac
];

val taut_strip_tac : TACTIC = (
	FIRST
	(map(fn t => t(REPEAT_TTCL (FIRST_TTCL taut_strip_thm_thens) 
			check_asm_tac))
		taut_strip_concl_ts)
);

val simple_taut_tac : TACTIC = (fn gl =>
	case REPEAT taut_strip_tac gl of
		done as ([], _) => done
	|	_ => fail "simple_taut_tac" 28121 []
);
end;
open List;
