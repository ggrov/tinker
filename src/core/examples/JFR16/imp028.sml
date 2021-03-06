structure Tactics2_DB = struct
val was_theory = get_current_theory_name ();

val _ = set_pc "initial";
fun �_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val thm1 = �_left_elim thm;
		val thm2 = �_right_elim thm;
	in	ttac1 thm1 THEN ttac2 thm2
	end
	handle ex => divert ex "�_left_elim" "�_THEN2" 28032 
		[fn () => string_of_thm thm]
);
fun �_THEN (ttac : THM -> TACTIC) : THM -> TACTIC = (fn thm => 
	(�_THEN2 ttac ttac thm)
	handle ex => pass_on ex "�_THEN2" "�_THEN"
);
fun �_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val (t1, t2) = dest_�(concl thm);
	in	(fn (seqasms, conc) =>
			let	val (sgs1, pf1) = ttac1 (asm_rule t1) (seqasms, conc);
				val (sgs2, pf2) = ttac2 (asm_rule t2) (seqasms, conc);
			in	(sgs1 @ sgs2,
				(fn thl =>
					let	val len = length sgs1;
					in �_elim thm (pf1(thl to (len - 1))) 
					  (pf2(thl from len))
					end
				))
			end)
	end
	handle ex => divert ex "dest_�" "�_THEN2" 28042 
		[fn () => string_of_thm thm]
);
fun �_THEN (ttac : THM -> TACTIC) (thm : THM) : TACTIC = (
	�_THEN2 ttac ttac thm
	handle complaint =>
	pass_on complaint "�_THEN2" "�_THEN"
);
fun CASES_T2 (t1 : TERM) (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
					: TACTIC = (fn gl as (seqasms, conc) =>
	let	val (sgs1, pf1) = ttac1 (asm_rule t1) (seqasms, conc);
		val (sgs2, pf2) = ttac2 (asm_rule (mk_� t1)) (seqasms, conc);
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
fun �_T (ttac : THM -> TACTIC) : TACTIC = (fn (seqasms, conc) =>
	let	val (t1, t2) = dest_� conc;
		val (sgs, pf) = ttac (asm_rule t1) (seqasms, t2);
	in	(sgs, �_intro t1 o pf)
	end
	handle ex => divert ex "dest_�" "�_T" 28051 []
);
fun SIMPLE_�_THEN (ttac : THM -> TACTIC) = (fn thm =>
	let	val (x, b) = dest_simple_�(concl thm);
	in	(fn (seqasms, conc) =>
			let	val x' = variant (flat(map frees
				(conc :: concl thm :: asms thm @ seqasms))) x;
				val (sgs, pf) = ttac (asm_rule (var_subst[(x', x)] b)) 
					(seqasms, conc);
			in	(sgs, 
				(fn thm1 =>
				simple_�_elim x' thm thm1
				handle complaint =>
				divert complaint 
					"simple_�_elim" 
					"SIMPLE_�_THEN"
					28094
					[fn () => string_of_term x',
					fn () => string_of_thm thm1,
					fn () => string_of_term x]
					) o pf)
			end)
	end
	handle ex => divert ex "dest_simple_�" "SIMPLE_�_THEN" 28093 
		[fn () => string_of_thm thm]
);
val t_tac : TACTIC = (fn gl =>
	accept_tac t_thm gl
	handle complaint =>
	divert complaint "accept_tac" "t_tac" 28011 []
);
val �_t_tac : TACTIC = (fn (seqasms, conc) => 
	let	val (lhs, rhs) = dest_eq conc;
	in	if rhs =$ mk_t
		then	([(seqasms, lhs)],
			 fn [th] => �_t_intro th | _ => bad_proof "�_t_tac")
		else if lhs =$ mk_t
		then	([(seqasms, rhs)],
			 fn [th] => eq_sym_rule(�_t_intro th) | _ => bad_proof "�_t_tac")
		else fail "�_t_tac" 28012 []
	end	handle Fail _ => fail "�_t_tac" 28012 []
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
val �_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (t1, t2) = dest_� conc
	in	([(seqasms, t1), (seqasms, t2)],
			 fn [th1, th2] => �_intro th1 th2
			 |   _ => bad_proof "�_tac" )
	end handle ex => divert ex "dest_�" "�_tac" 28031 []
);
val  �_left_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (a, b) = dest_� conc
	in	([(seqasms, a)],
			 fn [th] => �_right_intro b th
			 |   _ => bad_proof "�_left_tac" )
	end handle ex => divert ex "dest_�" "�_left_tac" 28041 []
);
val  �_right_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (a, b) = dest_� conc
	in	([(seqasms, b)],
			 fn [th] => �_left_intro a th
			 |   _ => bad_proof "�_right_tac" )
	end handle ex => divert ex "dest_�" "�_right_tac" 28041 []
);
val �_thm = ( (* � � a b � (a � b) � (a � b) � (b � a) *)
save_thm("�_thm",
let
	val thm1 = asm_rule �(a � b) � (b � a)�; 
	val thm2 = �_intro(�_left_elim thm1) (�_right_elim thm1);
	val (thm3, thm4) = �_elim(asm_rule�a � b�);
	val thm5 = �_intro thm3 thm4;
in
	list_simple_�_intro[�a:BOOL�, �b:BOOL�]
		(�_intro(all_�_intro thm5)(all_�_intro thm2))
end));
fun asm_ante_tac (t1 : TERM) : TACTIC = (fn (seqasms, conc) =>
	(if t1 term_mem seqasms
	then ([(seqasms term_less t1, mk_�(t1, conc))],
		(fn [thm] => undisch_rule thm | _ => bad_proof "asm_ante_tac"))
	else  term_fail "asm_ante_tac" 28052 [t1])
	handle ex => divert ex "mk_�" "asm_ante_tac" 28055 []
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
	([(seqasms, mk_�(concl thm, conc))],
	 fn [th] => �_elim th thm | _ => bad_proof "ante_tac")
	handle ex => divert ex "mk_�" "ante_tac" 28027 []
);
val simple_�_tac : TACTIC = (fn (seqasms, conc) =>
	let	val (x, b) = dest_simple_� conc;
		val x' = variant (flat(map frees(conc::seqasms))) x;
	in
		([(seqasms, var_subst[(x', x)] b)],
		(fn [thm] => simple_�_intro x' thm | _ => bad_proof "simple_�_tac"))
	end handle ex => divert ex "dest_simple_�" "simple_�_tac" 28081 []
);
fun intro_�_tac ((t1, x) : (TERM * TERM)) : TACTIC = (fn (seqasms, conc) =>
	let	val dummy = if t1 =$ x orelse
			not(is_free_in x conc)
			then ()
			else term_fail "intro_�_tac" 28083 [x,t1];
		val t' = subst[(x, t1)] conc;
	in	if if is_var t1 then not (is_free_in t1 conc) else t' =$ conc
		then	term_fail "intro_�_tac" 28082 [t1]
		else	([(seqasms, mk_simple_�(x, t'))],
			(fn [thm] => simple_�_elim t1 thm | _ => bad_proof "intro_�_tac"))
	end handle ex => (
		let val area = area_of ex;
		in	if area = "subst" orelse area = "mk_simple_�"
			then reraise ex "intro_�_tac" 
			else raise ex
		end
	)
);
fun intro_�_tac1 (x : TERM) : TACTIC = (
	intro_�_tac (x, x)
);
fun simple_�_tac (tm : TERM) : TACTIC = (fn (seqasms, conc) =>
	let	val (x, b) = dest_simple_� conc;
	in
		([(seqasms, var_subst[(tm, x)] b)],
		(fn [thm] => simple_�_intro conc thm | _ => bad_proof "simple_�_tac"))
	end
	handle ex =>
	case area_of ex of
		"var_subst" => term_fail "simple_�_tac" 28092 [tm]
	|	"dest_simple_�" => fail "simple_�_tac" 28091 []
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
		else if is_� t
		then	let	val t' = dest_� t;
				fun aux (asm :: more) = (
					if t ~=$ asm
					then id_tac
					else if asm ~=$ t'
					then accept_tac (�_elim conc (asm_rule asm) thm)
					else if asm ~=$ conc
					then accept_tac (asm_rule asm)
					else aux more
				) | aux [] = asm_tac thm;
			in	aux seqasms
			end
		else	let	fun aux (asm :: more) = (
					if t ~=$ asm
					then id_tac
					else if is_� asm andalso (dest_� asm) ~=$ t
					then accept_tac (�_elim conc thm (asm_rule asm))
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
		�_THEN, 
		�_THEN, 
		SIMPLE_�_THEN]
	ORELSE_TTCL
		FAIL_WITH_THEN "STRIP_THM_THEN" 28003 
			[fn () => string_of_thm thm])
	ttac
	thm
);
fun STRIP_CONCL_T (ttac : THM_TACTIC) : TACTIC = (fn gl =>
	(FIRST[ conv_tac(current_ad_sc_conv()),
		simple_�_tac,
		�_tac,
		�_T ttac,
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
	[ (thm_eqn_cxt �_thm) ];
val local_strip_concl_ts : EQN_CXT =
	[ (thm_eqn_cxt �_thm) ];

val _ = set_pc "'propositions";
val �_thm = save_thm("�_thm", tac_proof( ([], ��a b�(a � b) � (�a � b)�),
	REPEAT strip_tac
	THEN CASES_T �a:BOOL� asm_tac THEN_LIST
	[�_right_tac THEN all_asm_ante_tac THEN REPEAT strip_tac,
	 �_left_tac THEN all_asm_ante_tac THEN REPEAT strip_tac]));
val �_�_thm = save_thm("�_�_thm", tac_proof( ([], ��a�� �a � a�),
		REPEAT strip_tac THEN_LIST
	[accept_tac (�_�_elim (asm_rule ���a�)),
	 accept_tac (�_�_intro (asm_rule �a:BOOL�))]));
val �_�_thm = save_thm("�_�_thm", tac_proof( ([], ��a b�� (a � b) � (�a � �b)�),
	conv_tac(MAP_C (simple_eq_match_conv �_thm)) THEN
	REPEAT strip_tac THEN_LIST 
	[LEMMA_T �a � b�(accept_tac o �_mp_rule (asm_rule �a � b � F�)) THEN 
		�_left_tac THEN accept_tac(asm_rule �a:BOOL�), 
	LEMMA_T �a � b�(accept_tac o �_mp_rule (asm_rule �a � b � F�)) THEN
		�_right_tac THEN accept_tac(asm_rule �b:BOOL�),
	accept_tac(�_mp_rule (asm_rule �a � F�) (asm_rule �a:BOOL�)),
	accept_tac(�_mp_rule (asm_rule �b � F�) (asm_rule �b:BOOL�))] ));
val �_�_thm = tac_proof( ([], ��a b�(a � �b) � (b � a)�),
	REPEAT strip_tac THEN
	CASES_T �a:BOOL� asm_tac THEN_LIST
	[�_left_tac THEN all_asm_ante_tac THEN REPEAT strip_tac,
	�_right_tac THEN accept_tac(modus_tollens_rule(asm_rule�b � a�)(asm_rule��a�))]);
val �_�_thm = ( (* � �(a � b) � (�a � �b) *)
save_thm("�_�_thm",
let	val thm1 = tac_proof( ([], ��(a � b) � (a � �b)�),
	conv_tac(MAP_C (simple_eq_match_conv �_thm))
	THEN REPEAT strip_tac
	THEN_LIST
	[CASES_T�a:BOOL� asm_tac
		THEN LEMMA_T �a � b�
		(fn th1 => accept_tac(�_mp_rule(asm_rule�a � b � F�)(asm_rule�a � b�)))
		THEN REPEAT strip_tac,
		accept_tac(�_mp_rule(�_mp_rule(asm_rule�a � b � F�)
					(asm_rule�a:BOOL�))(asm_rule�b:BOOL�))]);
		val thm2 = tac_proof( ([], �(a � �b) � (�a � �b)�),
	conv_tac(MAP_C(FIRST_C(map simple_eq_match_conv
	[�_thm, �_�_thm, �_t_intro(refl_conv�x�)])))
	THEN t_tac);
in	list_simple_�_intro[�a:BOOL�, �b:BOOL�](eq_trans_rule thm1 thm2)
end));
val �_�_thm = save_thm("�_�_thm", tac_proof( ([], ��a b��(a � b) � (a � �b)�),
	conv_tac(TOP_MAP_C(FIRST_C (map simple_eq_match_conv
		[�_thm, �_�_thm, �_�_thm] )))
		THEN REPEAT strip_tac));
val �_�_thm = (* � � a b � � (a � b) � a � � b � b � � a  *)
		save_thm("�_�_thm",
		list_simple_�_intro[�a:BOOL�, �b:BOOL�]
		((RAND_C(simple_eq_match_conv �_thm)
		THEN_C (simple_eq_match_conv �_�_thm)
		THEN_C (MAP_C(simple_eq_match_conv �_�_thm)))
		��(a � b)�));
val �_f_thm = save_thm("�_f_thm", tac_proof( ([], ��F � T�),
	�_t_tac THEN conv_tac (simple_eq_match_conv �_thm) THEN strip_tac));
val �_if_thm = (* � � a b c� �(if a then b else c) � (if a then �b else �c)  *)
	save_thm("�_if_thm", 
	list_simple_�_intro[�a:BOOL�, �b:BOOL�, �c:BOOL�]
		(app_if_conv ��(if a then b else c)�));
val simple_��1_conv : CONV = (fn tm =>
	let	val (x, b) = dest_simple_��1 tm
		val s1 = �_intro tm (simple_��1_elim (asm_rule tm));
		val y = variant (x :: frees b) x;
		val conj = mk_�(b, mk_�(y, mk_�(var_subst[(y, x)]b, mk_eq(y, x))));
		val exi = mk_�(x, conj)
		val s2 = asm_rule conj;
		val s3 = simple_��1_intro (�_left_elim s2) (�_right_elim s2)
		val s4 = simple_�_elim x (asm_rule exi) s3
		val s5 = �_intro exi s4;
	in	�_intro s1 s5
	end handle ex => pass_on ex "dest_simple_��1" "simple_��1_conv"
);
val �_simple_��1_conv : CONV = (fn tm =>
	((RAND_C simple_��1_conv THEN_C �_simple_�_conv) tm)
	handle  Fail _ => term_fail "�_simple_��1_conv" 28091 [tm]
);
local
	val c = eqn_cxt_conv ((map thm_eqn_cxt
		[�_�_thm, �_�_thm, �_�_thm, �_�_thm,
		 �_�_thm, �_if_thm, �_t_thm, �_f_thm]) @
		[(��(� x � y)�, �_simple_�_conv),
		(��(� x � y)�, �_simple_�_conv),
		(��(��1 x � y)�, �_simple_��1_conv)]);
in
val simple_�_in_conv : CONV = (fn tm =>
	c tm
	handle complaint =>
	divert complaint "eqn_cxt_conv" "simple_�_in_conv" 28131
		[fn () => string_of_term tm]
);
end;
val SIMPLE_�_IN_THEN : THM_TACTICAL = (fn ttac => fn thm =>
	(ttac(�_mp_rule(simple_�_in_conv(concl thm))thm))
	handle complaint => 
	divert complaint "simple_�_in_conv" "SIMPLE_�_IN_THEN" 28026 []
);
val simple_�_in_tac : TACTIC = (fn gl => 
	((conv_tac simple_�_in_conv) gl)
	handle complaint => 
	divert complaint "simple_�_in_conv" "simple_�_in_tac" 28025 []
);
val �_THEN : THM_TACTICAL = (fn ttac => fn thm =>
	let	val (t1, t2) = dest_� (concl thm)
	in	ttac(�_mp_rule(list_simple_�_elim[t1, t2]�_thm)thm)
	end	handle ex => 
	divert ex "dest_�" "�_THEN" 28054 [fn () => string_of_thm thm]
);
val a_�_�b_thm = �_�_thm;

val �a_�_b_thm = list_simple_�_intro[�a:BOOL�, �b:BOOL�]
	(eq_sym_rule(all_simple_�_elim �_thm));

val a_�_b_thm = (
	conv_rule(MAP_C(simple_eq_match_conv �_�_thm))
	(list_simple_�_intro[�a:BOOL�, �b:BOOL�]
	(eq_sym_rule(list_simple_�_elim[��a�, �b:BOOL�]�_thm)))
);

local
val �_conv = FIRST_C(map simple_eq_match_conv
	[a_�_�b_thm,
	�a_�_b_thm,
	a_�_b_thm]);
in
val �_tac = conv_tac(�_conv);
end;
val local_if_thm =  
let	val s1 = asm_rule �(a � t1) � (� a � t2)�;
	val s2 = �_left_elim s1;
	val s3 = �_right_elim s1;
	val s4 = undisch_rule s2;
	val s5 = undisch_rule s3;
	val s6 = if_intro �a:BOOL� s4 s5;
	val s7 = all_�_intro s6;
	val s8 = asm_rule �if a then t1 else t2: BOOL�;
	val s9 = if_then_elim s8;
	val s10 = if_else_elim s8;
	val s11 = �_intro s9 s10;
	val s12 = all_�_intro s11;
	val s13 = �_intro s12 s7;
	val s14 = all_�_intro s13;
in	s14
end;
local	val s1 = refl_conv �x:'a�;
	val s2 = �_t_intro s1;
	val s3 = app_fun_rule �$�� s2;
	val s4 = eq_trans_rule s3 �_t_thm;
in
val local_eq_thm1 = simple_�_intro �x:'a� s2;
val local_eq_thm2 = simple_�_intro �x:'a� s4;
end;
val propositions_st_eqn_cxt : EQN_CXT =
	[	(thm_eqn_cxt �_thm),
		(thm_eqn_cxt �_thm),
		(thm_eqn_cxt local_if_thm),
		(thm_eqn_cxt local_eq_thm1),
		(thm_eqn_cxt local_eq_thm2),
		(���1 x � p�, simple_��1_conv)];
val propositions_sc_eqn_cxt : EQN_CXT =
	[	(thm_eqn_cxt �_thm),
		(thm_eqn_cxt a_�_�b_thm),
		(thm_eqn_cxt �a_�_b_thm),
		(thm_eqn_cxt a_�_b_thm),
		(thm_eqn_cxt local_eq_thm1),
		(thm_eqn_cxt local_eq_thm2),
		(thm_eqn_cxt local_if_thm)];
val _ = set_st_eqn_cxt propositions_st_eqn_cxt "'propositions";
val _ = set_sc_eqn_cxt propositions_sc_eqn_cxt "'propositions";
val _ = new_pc "'simple_abstractions";
val _ = set_st_eqn_cxt [(�� x�, simple_�_in_conv)] "'simple_abstractions";
val _ = set_sc_eqn_cxt [(�� x�, simple_�_in_conv)] "'simple_abstractions";
val _ = set_merge_pcs ["'propositions",
		"'simple_abstractions"];
val if_thm = save_thm("if_thm",
	tac_proof( ([],
	�� a b c � (if a then b else c) � 
		(a � b � � a � c)�),
	REPEAT strip_tac));
local
val taut_strip_thm_conv : CONV = (
	eqn_cxt_conv(
	map thm_eqn_cxt
	[�_�_thm, �_�_thm, �_�_thm, �_�_thm,
	 �_�_thm, �_t_thm, �_f_thm, �_if_thm,
	�_thm, �_thm, local_if_thm
]));

val taut_strip_concl_conv : CONV = (
	eqn_cxt_conv(
	map thm_eqn_cxt
	[�_�_thm, �_�_thm, �_�_thm, �_�_thm,
	 �_�_thm, �_t_thm, �_f_thm, �_if_thm,
	�_thm, local_if_thm,
	a_�_�b_thm, �a_�_b_thm, a_�_b_thm]
));

val taut_strip_thm_thens : THM_TACTICAL list = [
	�_THEN,
	�_THEN,
	CONV_THEN taut_strip_thm_conv
];

val taut_strip_concl_ts : (THM_TACTIC -> TACTIC) list = [
	fn _ => �_tac,
	�_T,
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
in
val simple_taut_tac : TACTIC = (fn gl =>
	case REPEAT taut_strip_tac gl of
		done as ([], _) => done
	|	_ => fail "simple_taut_tac" 28121 []
);
end;
fun  CONTR_T (thmtac : THM -> TACTIC) : TACTIC = (fn gl as (seqasms, conc) =>
	let	val �_conc = mk_� conc;
		val (sgs, pf) =  (thmtac (asm_rule �_conc)) (seqasms, mk_f);
		fun rule thm = (
			if �_conc term_mem (asms thm)
			then c_contr_rule conc thm
			else contr_rule conc thm
		);
	in	(sgs, rule o pf)
	end
	handle ex => divert ex "mk_�" "CONTR_T" 28027 []
);
val contr_tac : TACTIC = (fn gl =>
	(CONTR_T strip_asm_tac gl)
	handle ex => pass_on ex "CONTR_T" "contr_tac"
);
fun  �_elim_tac (tm : TERM) : TACTIC = (
	if not(type_of tm =: BOOL)
	then term_fail "�_elim_tac" 28022 [tm]
	else	(fn (seqasms, conc) =>
			([(seqasms, tm), (seqasms, mk_� tm)],
			 fn [th1, th2] => �_elim conc th1 th2
			 |   _ => bad_proof "�_elim_tac" )
		)
);
fun  �_T2 (t1 : TERM)
	(thmtac1 : THM -> TACTIC) (thmtac2 : THM -> TACTIC)
		: TACTIC = (fn gl as (seqasms, conc) =>
	let	val t2 = (dest_� conc)
			handle Fail _ => fail "�_T2" 28023 [];
		val �_t1 = (mk_� t1)
			handle Fail _ => term_fail "�_T2" 28022 [t1];
		val (sgs1, pf1) = (thmtac1 (asm_rule t2)) (seqasms, t1);
		val (sgs2, pf2) = (thmtac2 (asm_rule t2)) (seqasms, �_t1);
		fun rule [thm1, thm2] = �_intro t2 thm1 thm2
		|   rule _ = bad_proof "�_T2";
	in	(sgs1 @ sgs2, rule o map_shape[(pf1, length sgs1), 
			(pf2, length sgs2)])
	end	
);
fun  �_T (t1 : TERM) (thmtac : THM -> TACTIC) : TACTIC = (fn thm =>
	(�_T2 t1 thmtac thmtac thm)
	handle ex => pass_on ex "�_T2" "�_T"
);
fun �_tac (t : TERM) : TACTIC = (fn gl =>
	(�_T t strip_asm_tac gl)
	handle ex => pass_on ex "�_T" "�_tac"
);
val �_comm_thm : THM = tac_proof(([], ��a b�a � b � b � a�), 
	REPEAT strip_tac);
val swap_�_tac : TACTIC = (fn gl =>
	((conv_tac(simple_eq_match_conv �_comm_thm)) gl)
	handle ex => divert ex "simple_eq_match_conv" "swap_�_tac" 28041 []
);
fun cases_tac (tm : TERM) : TACTIC = (fn gl =>
	(CASES_T tm strip_asm_tac gl)
	handle ex => pass_on ex "CASES_T" "cases_tac"
);
val �_tac : TACTIC = (fn gl =>
	(�_T strip_asm_tac gl)
	handle ex => pass_on ex "�_T" "�_tac"
);
fun �_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val (thm1, thm2) = �_elim thm;
	in	ttac1 thm1 THEN ttac2 thm2
	end
	handle ex => divert ex "�_elim" "�_THEN2" 28062 
		[fn () => string_of_thm thm]
);
fun �_THEN (ttac : THM -> TACTIC) : THM -> TACTIC = (fn thm => 
	(�_THEN2 ttac ttac thm)
	handle ex => pass_on ex "�_THEN2" "�_THEN"
);
fun �_T2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: TACTIC = (fn (seqasms, conc) => 
	let	val (t1, t2) = dest_� conc;
		val (sgs1, pf1) = ttac1 (asm_rule t1) (seqasms, t2);
		val (sgs2, pf2) = ttac2 (asm_rule t2) (seqasms, t1);
		fun rule [thm1, thm2] = �_intro (�_intro t1 thm1) (�_intro t2 thm2)
		|   rule _ = bad_proof "�_T2";
	in	(sgs1 @ sgs2, rule o map_shape[(pf1, length sgs1), (pf2, length sgs2)])
	end
	handle ex => divert ex "dest_�" "�_T2" 28061 []
);
fun  �_T (ttac : THM -> TACTIC) : TACTIC = (fn thm =>
	(�_T2 ttac ttac thm)
	handle ex => pass_on ex "�_T2" "�_T"
);
val �_tac : TACTIC = (fn gl =>
	(�_T strip_asm_tac gl)
	handle ex => pass_on ex "�_T" "�_tac"
);
fun IF_THEN2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC)
						: THM -> TACTIC = (fn thm => 
	let	val thm1 = if_then_elim thm;
		val thm2 = if_else_elim thm;
	in	ttac1 thm1 THEN ttac2 thm2
	end
	handle ex => 
	pass_on ex "if_then_elim" "IF_THEN2"
);
fun IF_THEN (ttac : THM -> TACTIC) : THM -> TACTIC = (fn thm => 
	(IF_THEN2 ttac ttac thm)
	handle ex => pass_on ex "IF_THEN2" "IF_THEN"
);
fun IF_T2 (ttac1 : THM -> TACTIC) (ttac2 : THM -> TACTIC) 
		: TACTIC = (fn (seqasms, conc) =>
	let	val (a, tt, et) = dest_if conc;
		val (tsgs, tpf) = ttac1 (asm_rule a) (seqasms, tt);
		val (esgs, epf) = ttac2 (asm_rule (mk_� a)) (seqasms, et);
		fun rule [thm1, thm2] = if_intro a thm1 thm2
		|   rule _ = bad_proof "�IF_T2";

	in	(tsgs @ esgs, rule o map_shape[(tpf, length tsgs), (epf, length esgs)])
	end handle ex => divert ex "dest_if" "IF_T2" 28071 []
);
fun  IF_T (ttac : THM -> TACTIC) : TACTIC = (fn thm =>
	(IF_T2 ttac ttac thm)
	handle ex => pass_on ex "IF_T2" "IF_T"
);
val if_tac : TACTIC = (fn gl =>
	(IF_T strip_asm_tac gl)
	handle ex => pass_on ex "IF_T" "if_tac"
);
fun simple_��1_tac (tm : TERM) : TACTIC = (fn (seqasms, conc) =>
	let	val (x, b) = dest_simple_��1 conc;
		val x' = variant (frees tm) x;
		val b' = var_subst[(x',x)]b;
		val u = mk_�(x', mk_�(b', mk_eq(x', tm)))
	in
		([(seqasms, var_subst[(tm, x')] b'), (seqasms, u)],
		(fn [th1, th2] => simple_��1_intro th1 th2
		| _ => bad_proof "simple_��1_tac"))
	end
	handle ex =>
	case area_of ex of
		"dest_simple_��1" => fail "simple_��1_tac" 28101 []
	|	"mk_eq" => term_fail "simple_��1_tac" 28092 [tm]
	|	_ => raise ex
);

fun SIMPLE_��1_THEN (ttac : THM -> TACTIC) = (fn thm =>
	(SIMPLE_�_THEN ttac (simple_��1_elim thm))
	handle ex => divert ex "simple_��1_elim" 
		"SIMPLE_��1_THEN" 28102 
		[fn () => string_of_thm thm]
);
local
	val thm1 = tac_proof(([], �� f � (f � F) � � f�),
		REPEAT strip_tac);
	val thm2 = tac_proof(([], �� f � ((� f) � F) � f�),
		REPEAT strip_tac);
	val thm3 = tac_proof(([], 
		�� f g � (f � g) � ((� f) � g)�),
		REPEAT strip_tac);
	val thm4 = tac_proof(([], 
		�� f g � ((� f) � g) � (f � g)�),
		REPEAT strip_tac);
	val �_F_conv = (fn ntm =>
		let	val tm = fst(dest_� ntm);
		in
			if is_� tm
			then simple_�_elim(dest_� tm) thm2
			else simple_�_elim tm thm1
		end);
	fun local_conv (tm : TERM) : THM = (
	let	val (d1,d2) = dest_� tm;
	in
		if d2 =$ mk_f
		then �_F_conv tm
		else ((fn _ => if is_� d1
		then list_simple_�_elim[dest_� d1, d2] thm4
		else list_simple_�_elim[d1, d2] thm3)
			THEN_TRY_C (RAND_C local_conv)) tm
	end);
	fun local_tac ([] : THM list) : TACTIC = id_tac
	| local_tac thms = (
	let	val rthms = rev thms;
	in
		MAP_EVERY ante_tac rthms
		THEN conv_tac local_conv
	end);
	
	
in	
fun  SWAP_ASM_CONCL_T (asm:TERM) (thmtac:THM -> TACTIC) 
	: TACTIC = (
fn gl as (seqasms, conc) =>
let	val �_conc = mk_� conc;
	val (sgs, pf) =  ((asm_ante_tac asm THEN
		conv_tac �_F_conv THEN
		thmtac (asm_rule �_conc)) (seqasms, mk_f))
		handle complaint =>
		pass_on complaint "asm_ante_tac" "SWAP_ASM_CONCL_T";
	fun rule thm = (
		if �_conc term_mem (asms thm)
		then c_contr_rule conc thm
		else contr_rule conc thm
	);
in	(sgs, rule o pf)
end
handle complaint => 
divert complaint "mk_�" "SWAP_ASM_CONCL_T" 28027 []
);
fun  LIST_SWAP_ASM_CONCL_T ([]:TERM list) (thmtac:THM -> TACTIC) 
	: TACTIC = (
	CONTR_T thmtac
) | LIST_SWAP_ASM_CONCL_T lasms thmtac = (
fn gl as (seqasms, conc) =>
let	val �_conc = mk_� conc;
	val (sgs, pf) =  ((list_asm_ante_tac lasms THEN
		conv_tac (TRY_C local_conv) THEN
		thmtac (asm_rule �_conc)) (seqasms, mk_f))
		handle complaint =>
		pass_on complaint "list_asm_ante_tac" "LIST_SWAP_ASM_CONCL_T";
	fun rule thm = (
		if �_conc term_mem (asms thm)
		then c_contr_rule conc thm
		else contr_rule conc thm
	);
in	(sgs, rule o pf)
end
handle complaint => 
divert complaint "mk_�" "LIST_SWAP_ASM_CONCL_T" 28027 []
);
fun  SWAP_NTH_ASM_CONCL_T (n:int) (thmtac:THM -> TACTIC) : TACTIC = (
fn gl as (seqasms, conc) =>
let	val �_conc = mk_� conc;
	val (sgs, pf) =  (((DROP_NTH_ASM_T n ante_tac) THEN
		conv_tac �_F_conv THEN
		thmtac (asm_rule �_conc)) (seqasms, mk_f))
		handle complaint =>
		pass_on complaint "DROP_NTH_ASM_T" "SWAP_NTH_ASM_CONCL_T";
	fun rule thm = (
		if �_conc term_mem (asms thm)
		then c_contr_rule conc thm
		else contr_rule conc thm
	);
in	(sgs, rule o pf)
end
handle complaint => 
divert complaint "mk_�" "SWAP_NTH_ASM_CONCL_T" 28027 []
);
fun LIST_SWAP_NTH_ASM_CONCL_T ([]:int list) (thmtac:THM -> TACTIC) 
	: TACTIC = (
	CONTR_T thmtac
) | LIST_SWAP_NTH_ASM_CONCL_T ns thmtac = (
fn gl as (seqasms, conc) =>
let	val �_conc = mk_� conc;
	val (sgs, pf) =  ((LIST_DROP_NTH_ASM_T ns local_tac THEN
		thmtac (asm_rule �_conc)) (seqasms, mk_f))
		handle complaint =>
		pass_on complaint "LIST_DROP_NTH_ASM_T" 
			"LIST_SWAP_NTH_ASM_CONCL_T";
	fun rule thm = (
		if �_conc term_mem (asms thm)
		then c_contr_rule conc thm
		else contr_rule conc thm
	);
in	(sgs, rule o pf)
end
handle complaint => 
divert complaint "mk_�" "LIST_SWAP_NTH_ASM_CONCL_T" 28027 []
);
end;
fun swap_asm_concl_tac (tm : TERM) : TACTIC = (fn gl =>
	SWAP_ASM_CONCL_T tm strip_asm_tac gl
	handle complaint =>
	pass_on complaint "SWAP_ASM_CONCL_T" "swap_asm_concl_tac"
);
fun swap_nth_asm_concl_tac (n : int) : TACTIC = (fn gl =>
	SWAP_NTH_ASM_CONCL_T n strip_asm_tac gl
	handle complaint =>
	pass_on complaint "SWAP_NTH_ASM_CONCL_T" "swap_nth_asm_concl_tac"
);
fun list_swap_asm_concl_tac (tml : TERM list) : TACTIC = (fn gl =>
	LIST_SWAP_ASM_CONCL_T tml strip_asm_tac gl
	handle complaint =>
	pass_on complaint "LIST_SWAP_ASM_CONCL_T" "list_swap_asm_concl_tac"
);
fun list_swap_nth_asm_concl_tac (ns : int list) : TACTIC = (fn gl =>
	LIST_SWAP_NTH_ASM_CONCL_T ns strip_asm_tac gl
	handle complaint =>
	pass_on complaint "LIST_SWAP_NTH_ASM_CONCL_T" 
		"list_swap_nth_asm_concl_tac"
);
fun eq_sym_asm_tac (asm:TERM):TACTIC = (fn gl =>
	(DROP_ASM_T asm 
	(strip_asm_tac o conv_rule(ONCE_MAP_C eq_sym_conv)))
	gl
	handle complaint => 
	list_divert complaint "eq_sym_asm_tac"
		[("DROP_ASM_T",9301,[fn () => string_of_term asm]),
		("ONCE_MAP_C",28053,[fn () => string_of_term asm])]
);
fun eq_sym_nth_asm_tac (n:int):TACTIC = (fn (asms,cnc) =>
	(DROP_NTH_ASM_T n 
	(strip_asm_tac o conv_rule(ONCE_MAP_C eq_sym_conv)))
	(asms,cnc)
	handle complaint => 
	list_divert complaint "eq_sym_nth_asm_tac"
		[("DROP_NTH_ASM_T",9303,[fn () => string_of_int n]),
		("ONCE_MAP_C",28053,[fn () => string_of_term (nth (n-1) asms)])]
);
fun lemma_tac (sg : TERM) : TACTIC = (fn gl =>
	(LEMMA_T sg strip_asm_tac gl)
	handle ex => pass_on ex "LEMMA_T" "lemma_tac"
);
fun prove_tac (thms: THM list) :  TACTIC = (
let	val otac = current_ad_pr_tac ()
		handle complaint => 
		pass_on complaint "current_ad_pr_tac" "prove_tac";
	val tac = case otac of Value f => f thms | Nil => fail_tac;
in
	DROP_ASMS_T(fn asms =>
	tac
	THEN MAP_EVERY check_asm_tac (rev asms))
end);
val prove_�_tac : TACTIC = (fn gl =>
	DROP_ASMS_T(fn asms =>
	conv_tac(current_ad_cs_�_conv ())
	THEN MAP_EVERY check_asm_tac (rev asms)) gl
	handle complaint => 
	pass_on complaint "current_ad_cs_�_conv" "prove_�_tac"
);
val _ = open_theory was_theory;
end; (* of structure Tactics2 *)
open Tactics2;
