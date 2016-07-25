open_theory "fef032";
(force_delete_theory "fef033" handle _ => ());
new_theory"fef033";
new_parent"fef031";
set_pc"hol";
push_consistency_goal¨TableComputationsÆ;
a(prove_∂_tac);
a(strip_tac THEN rewrite_tac[tac_proof(([], ¨µx∑∂z y∑ (y, z) = xÆ),
		strip_tac THEN ∂_tac¨Snd xÆ THEN ∂_tac¨Fst xÆ THEN rewrite_tac[])]);
save_consistency_thm¨TableComputationsÆ (pop_thm());
set_pc"hol";
set_goal([], ¨µi1 i2∑ BoolItem i1 = BoolItem i2 § i1 = i2Æ);
a(rewrite_tac(map get_spec[¨BoolItemÆ, ¨ValuedItemItemÆ])
	THEN REPEAT µ_tac THEN §_tac THEN_TRY asm_rewrite_tac[]);
a(LEMMA_T ¨VI_val(MkValuedItem sterling (BoolVal i1))
             = VI_val(MkValuedItem sterling (BoolVal i2))Æ
	(accept_tac o rewrite_rule(map get_spec[¨MkValuedItemÆ, ¨BoolValÆ]))
	THEN1 asm_rewrite_tac[]);
val BoolItem_OneOne_lemma = save_pop_thm"BoolItem_OneOne_lemma";
set_goal([], ¨µc r1 r2∑
	HideDerTableRow c r1 = HideDerTableRow c r2 ¥
	Length (DTR_cols r1) = Length (DTR_cols r2)Æ);
a(rewrite_tac(MkDerTableRow_lemma :: map get_spec[¨HideDerTableRowÆ, ¨LetÆ]));
a(REPEAT strip_tac);
a(LEMMA_T¨Length(Map(Ã (c', i) ∑ if c dominates c'
                   then (c', i)
                   else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols r1))
             = Length(Map (Ã (c', i) ∑ if c dominates c'
                   then (c', i)
                   else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols r2))Æ
	(strip_asm_tac o once_rewrite_rule[length_map_thm])
	THEN1 asm_rewrite_tac[]);
val HideDerTableRow_Length_lemma = save_pop_thm"HideDerTableRow_Length_lemma";
set_goal([], ¨µc r i∑
	1 º i ± i º Length (DTR_cols r) ¥
	Nth (DTR_cols (HideDerTableRow c r)) i =
	(Fst (Nth (DTR_cols r) i),
	if	c dominates (Fst (Nth (DTR_cols r) i))
	then	Snd(Nth (DTR_cols r) i)
	else	ValuedItemItem (MkValuedItem sterling dummyVal))Æ);
a(REPEAT µ_tac);
a(rewrite_tac(map get_spec[¨LetÆ, ¨DTR_colsÆ, ¨HideDerTableRowÆ]));
a(LEMMA_T ¨∂cols∑ DTR_cols r = colsÆ
	(REPEAT_TTCL STRIP_THM_THEN rewrite_thm_tac)
	THEN1 prove_∂_tac);
a(intro_µ_tac(¨iÆ, ¨iÆ) THEN list_induction_tac¨colsÆ);
(* *** Goal "1" *** *)
a(rewrite_tac(map get_spec[¨LengthÆ]));
a(REPEAT strip_tac THEN all_var_elim_asm_tac);
(* *** Goal "2" *** *)
a(rewrite_tac(map get_spec[¨LengthÆ, ¨NthÆ]));
a(REPEAT µ_tac);
a(cases_tac ¨i = 1Æ THEN asm_rewrite_tac(map get_spec[¨MapÆ, ¨NthÆ])
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(CASES_T ¨c dominates Fst xÆ rewrite_thm_tac);
(* *** Goal "2.2" *** *)
a(GET_ASM_T ¨1 º iÆ (strip_asm_tac o rewrite_rule[get_spec¨$ºÆ]));
a(LEMMA_T¨i = i' + 1Æ rewrite_thm_tac THEN1
	(POP_ASM_T (rewrite_thm_tac o eq_sym_rule)));
a(lemma_tac¨1 º i' ± i' º Length colsÆ THEN1 PC_T1 "lin_arith" asm_prove_tac[]);
a(all_asm_fc_tac[]);
val Nth_HideDerTableRow_lemma = save_pop_thm"Nth_HideDerTableRow_lemma";
push_goal([], ¨µc∑ DTR_row o HideDerTableRow c = DTR_rowÆ);
a(PC_T1"hol2" REPEAT strip_tac);
a(rewrite_tac(
	map get_spec[¨$o:(('a≠'c)≠(('b≠'a)≠('b≠'c)))Æ,
	¨HideDerTableRowÆ, ¨DTR_rowÆ, ¨LetÆ]));
val DTR_row_o_HideDerTableRow_lemma = 
	save_pop_thm"DTR_row_o_HideDerTableRow_lemma";
set_goal([], ¨µf a b c∑ f(if a then b else c) = (if a then f b else f c)Æ);
a(REPEAT strip_tac THEN cases_tac¨a:BOOLÆ THEN asm_rewrite_tac[]);
val fun_if_thm = save_pop_thm"fun_if_thm";
push_goal([], ¨µc rl∑
	rl ˘ {r|c dominates DTR_row r ± c dominates DTR_where r} = []
	§
	(Map (HideDerTableRow c) (rl ˘ {r|c dominates DTR_row r}))
		˘ {r|c dominates DTR_where r} = []Æ);
a(REPEAT µ_tac);
a(list_induction_tac ¨rlÆ THEN asm_rewrite_tac(
	map get_spec[¨LetÆ, ¨MapÆ, ¨DTR_rowÆ, ¨HideDerTableRowÆ, ¨$˘Æ]));
(* *** Goal "1" *** *)
a(strip_tac THEN cases_tac ¨c dominates DTR_row xÆ THEN asm_rewrite_tac(
	map get_spec[¨LetÆ, ¨MapÆ, ¨DTR_rowÆ, ¨HideDerTableRowÆ, ¨$˘Æ]));
a(cases_tac¨c dominates DTR_where xÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(strip_tac THEN cases_tac ¨c dominates DTR_row xÆ THEN asm_rewrite_tac(
	map get_spec[¨LetÆ, ¨MapÆ, ¨DTR_rowÆ, ¨HideDerTableRowÆ, ¨$˘Æ]));
a(cases_tac¨c dominates DTR_where xÆ THEN asm_rewrite_tac[]);
val ˘_null_map_hide_lemma = save_pop_thm"˘_null_map_hide_lemma";
push_goal([], ¨µc rl1 rl2∑
	Map (HideDerTableRow c) rl1 = Map(HideDerTableRow c) rl2
	¥
	Map (HideDerTableRow c) (rl1 ˘ {r | c dominates DTR_where r})
	=
	Map (HideDerTableRow c) (rl2 ˘ {r | c dominates DTR_where r})Æ);
a(REPEAT_N 2 strip_tac);
a(list_induction_tac ¨rl1Æ THEN asm_rewrite_tac(
	map_null_thm::map get_spec[¨MapÆ, ¨$˘Æ]) THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[get_spec¨$˘Æ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN strip_asm_tac(µ_elim¨rl2Ælist_cases_thm)
	THEN all_var_elim_asm_tac1 THEN asm_rewrite_tac[get_spec¨MapÆ]);
a(rewrite_tac(MkDerTableRow_lemma::
	map get_spec[¨HideDerTableRowÆ, ¨LetÆ, ¨MapÆ, ¨$˘Æ])
	THEN REPEAT strip_tac);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates DTR_where x'Æ THEN asm_rewrite_tac[get_spec¨MapÆ]);
a(rewrite_tac(MkDerTableRow_lemma::
	map get_spec[¨HideDerTableRowÆ, ¨LetÆ, ¨MapÆ, ¨$˘Æ])
	THEN REPEAT strip_tac);
val map_hide_map_hide_˘_lemma = save_pop_thm"map_hide_map_hide_˘_lemma";
set_goal([], ¨µl a b∑ l ˘ (a ° b) = (l ˘ a) ˘ bÆ);
a(REPEAT strip_tac);
a(list_induction_tac ¨lÆ THEN asm_rewrite_tac(
	map get_spec[¨$˘Æ]));
a(strip_tac THEN PC_T1 "sets_ext1" rewrite_tac[]);
a(cases_tac¨x ç aÆ THEN asm_rewrite_tac[get_spec¨$˘Æ]);
val ˘_°_lemma = save_pop_thm"˘_°_lemma";
push_goal([], ¨µxy list∑
	Split [] = ([], []) ±
	Split (Cons xy list) =
	(Cons (Fst xy) (Fst (Split list)), Cons (Snd xy) (Snd (Split list)))Æ);
a(rewrite_tac[get_spec¨SplitÆ] THEN REPEAT strip_tac);
a(lemma_tac ¨∂x y∑xy = (x, y)Æ THEN1
	(∂_tac¨Fst xyÆ THEN ∂_tac¨Snd xyÆ) THEN
	asm_rewrite_tac[get_spec¨SplitÆ]);
val split_thm = save_pop_thm"split_thm";
push_goal([], ¨µlist∑Length list = 0 § list = []Æ);
a(REPEAT strip_tac THEN_LIST [id_tac, asm_rewrite_tac[get_spec¨LengthÆ]]);
a(POP_ASM_T ante_tac THEN list_induction_tac¨listÆ
	THEN rename_tac[] THEN asm_rewrite_tac[get_spec¨LengthÆ]);
val length_0_thm = save_pop_thm"length_0_thm";
push_goal([], ¨µlist∑Length list = 1 § ∂x∑list = [x]Æ);
a(REPEAT strip_tac THEN_LIST [id_tac, asm_rewrite_tac[get_spec¨LengthÆ]]);
a(POP_ASM_T ante_tac THEN list_induction_tac¨listÆ
	THEN rename_tac[] THEN asm_rewrite_tac[get_spec¨LengthÆ, length_0_thm]);
a(REPEAT strip_tac THEN prove_∂_tac);
val length_1_thm = save_pop_thm"length_1_thm";
push_goal([], ¨µlist∑
	Fst(Split list) = Map Fst list ±
	Snd(Split list)= Map Snd list Æ);
a(strip_tac);
a(list_induction_tac ¨listÆ THEN
	asm_rewrite_tac(split_thm::map get_spec[¨MapÆ]));
val fst_snd_split_thm = save_pop_thm"fst_snd_split_thm";
push_goal([], ¨µc cl∑ lubl [] = lattice_bottom ± lubl (Cons c cl) = c lub lubl clÆ);
a(REPEAT µ_tac THEN rewrite_tac(map get_spec[¨lublÆ, ¨FoldÆ]));
val lubl_lemma = save_pop_thm"lubl_lemma";
push_goal([], ¨µc∑ c lub lattice_bottom = cÆ);
a(REPEAT strip_tac THEN lemma_tac
	¨c dominates c lub lattice_bottom ±
		c lub lattice_bottom dominates cÆ
	THEN_LIST [rewrite_tac[get_spec¨$lubÆ], all_fc_tac[get_spec¨$lubÆ]]);
a(lemma_tac
	¨c dominates c ± c dominates lattice_bottomÆ
	THEN_LIST [rewrite_tac[get_spec¨$lubÆ], all_fc_tac[get_spec¨$lubÆ]]);
val lub_lattice_bottom_thm = save_pop_thm"lub_lattice_bottom_thm";
push_goal([], ¨µcc cil∑
	cc dominates lubl (Map Fst cil)
	¥
	Map (Ã (c, i)∑ (c, (if cc dominates c then i else Arbitrary))) cil
	= cil
Æ);
a(REPEAT µ_tac);
a(list_induction_tac ¨cilÆ
	THEN asm_rewrite_tac(dominates_lub_lemma::lubl_lemma :: map get_spec[¨MapÆ]));
a(REPEAT strip_tac THEN asm_rewrite_tac[]);
val dominates_lubl_map_hide_lemma = save_pop_thm "dominates_lubl_map_hide_lemma";
set_goal([], ¨µcc tst cev cevs ev∑
	CaseVal cc tst [] ev =
	(Ãtl rl r∑
	let	(tc, ti) = tst tl rl r
	in let	(ec, ei) = ev tl rl r
	in	if	cc dominates tc
		then	(ec, ei)
		else	(tc, ei))
±	CaseVal cc tst (Cons cev cevs) ev =
	(Ãtl rl r∑
	let	(cr, ir) = CaseVal cc tst cevs ev tl rl r
	in let	(tc, ti) = tst tl rl r
	in let	(ce, cv) = cev
	in let 	(cec, cei) = ce tl rl r
	in let 	(cvc, cvi) = cv tl rl r
	in	if	ti = cei
		then	if	cc dominates tc ± cc dominates cec
			then	(cvc, cvi)
			else if	≥cc dominates tc
			then	(tc, cvi)
			else	(cec, cvi)
		else	if	cc dominates tc ± cc dominates cec
			then	(cr, ir)
			else if	≥cc dominates tc
			then	(tc, ir)
			else	(cec, ir))
Æ);
a(PC_T1 "predicates1" rewrite_tac[]);
a(rewrite_tac(map get_spec[¨$domÆ, ¨CaseValÆ, ¨CheckTestÆ,
	¨CaseValValueÆ, ¨CheckListÆ, ¨LetÆ, ¨MapÆ]) THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(cases_tac ¨cc dominates Fst (tst x x' x'')Æ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(cases_tac ¨cc dominates Fst (tst x x' x'')Æ THEN
	cases_tac ¨cc dominates Fst (Fst cev x x' x'')Æ THEN
	cases_tac ¨Snd (tst x x' x'') = Snd (Fst cev x x' x'')Æ THEN
	asm_rewrite_tac[]);
val CaseVal_lemma = save_pop_thm "CaseVal_lemma";
set_pc"hol";
set_goal([], ¨µc∑ OK_TCâd c Ä OkTableComputation cÆ);
a(PC_T1"hol2"
	rewrite_tac(map get_spec[¨OK_TCâdÆ, ¨OkTableComputationÆ, ¨RiskInputsÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 2 (strip_asm_tac o eq_sym_rule));
a(DROP_NTH_ASM_T 2 (strip_asm_tac o conv_rule(RAND_C eq_sym_conv)));
a(all_asm_fc_tac[]);
val OK_TCâd_lemma = save_pop_thm"OK_TCâd_lemma";
set_goal([], ¨µc ci∑ DenoteConstant ci ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨DenoteConstantÆ]) THEN REPEAT strip_tac);
val DenoteConstant_OKâd_lemma = save_pop_thm"DenoteConstant_OKâd_lemma";
set_goal([], ¨µc i∑ Contents i ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨ContentsÆ])
	THEN REPEAT strip_tac);
a(POP_ASM_T ante_tac THEN all_fc_tac[HideDerTableRow_Length_lemma]);
a(cases_tac ¨1 º i ± i º # (DTR_cols râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨i º # (DTR_cols râ0)Æ THEN1 asm_rewrite_tac[]);
a(ALL_FC_T (MAP_EVERY(asm_tac o µ_elim¨cÆ)) [Nth_HideDerTableRow_lemma]);
a(contr_tac);
a(swap_nth_asm_concl_tac 4 THEN LIST_DROP_NTH_ASM_T [3, 8] rewrite_tac);
a(cases_tac ¨Fst (Nth (DTR_cols râ1) i) = Fst (Nth (DTR_cols râ0) i)Æ
	THEN asm_rewrite_tac[]);
a(conv_tac (RAND_C eq_sym_conv) THEN asm_rewrite_tac[]);
val Contents_OKâd_lemma = save_pop_thm"Contents_OKâd_lemma";
set_goal([], ¨µc i∑ Classification i ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨ClassificationÆ]) 
	THEN REPEAT strip_tac);
a(POP_ASM_T ante_tac THEN all_fc_tac[HideDerTableRow_Length_lemma]);
a(cases_tac ¨1 º i ± i º # (DTR_cols râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨i º # (DTR_cols râ0)Æ THEN1 asm_rewrite_tac[]);
a(ALL_FC_T (MAP_EVERY(asm_tac o µ_elim¨cÆ)) [Nth_HideDerTableRow_lemma]);
a(contr_tac);
a(swap_nth_asm_concl_tac 4 THEN LIST_DROP_NTH_ASM_T [3, 8] rewrite_tac);
a(cases_tac ¨Fst (Nth (DTR_cols râ1) i) = Fst (Nth (DTR_cols râ0) i)Æ
	THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 3 ante_tac THEN asm_rewrite_tac[]);
val Classification_OKâd_lemma = save_pop_thm"Classification_OKâd_lemma";
set_goal([], ¨µc∑ CountAll ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨CountAllÆ,¨LetÆ]) THEN REPEAT strip_tac);
a(lemma_tac¨≥(# rlâ0) = (# rlâ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(DROP_NTH_ASM_T 2 (fn x => id_tac));
a(POP_ASM_T ante_tac THEN POP_ASM_T ante_tac THEN POP_ASM_T ante_tac);
a(intro_µ_tac(¨râ1Æ,¨râ1Æ));
a(intro_µ_tac(¨râ0Æ,¨râ0Æ));
a(intro_µ_tac(¨rlâ1Æ,¨rlâ1Æ));
a(list_induction_tac¨rlâ0Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "1.1" *** *)
a(DROP_NTH_ASM_T 2 ante_tac THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(swap_asm_concl_tac
	¨Map (HideDerTableRow c) [] = Map (HideDerTableRow c) rlâ1Æ
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "2.1" *** *)
a(swap_asm_concl_tac
	¨Map (HideDerTableRow c) (Cons x rlâ0) = Map (HideDerTableRow c) rlâ1Æ
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2.2" *** *)
a(var_elim_nth_asm_tac 1);
a(rewrite_tac[dominates_lub_lemma,lubl_lemma,get_spec¨MapÆ]);
a(REPEAT strip_tac);
a(DROP_NTH_ASM_T 4 (strip_asm_tac o rewrite_rule[get_spec¨MapÆ]));
a(DROP_NTH_ASM_T 6 (ante_tac o list_µ_elim[¨list2Æ,¨xÆ,¨x'Æ]));
a(REPEAT strip_tac);
a(DROP_NTH_ASM_T 5 (strip_asm_tac o rewrite_rule[get_spec¨LengthÆ]));
val CountAll_OKâd_lemma = save_pop_thm"CountAll_OKâd_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâd c ¥ MonOp f vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨MonOpÆ, ¨LetÆ]) THEN REPEAT strip_tac);
a(lemma_tac¨≥Snd (vc tlâ0 rlâ0 râ0) = Snd (vc tlâ1 rlâ1 râ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(all_asm_fc_tac[]);
val MonOp_OKâd_lemma = save_pop_thm"MonOp_OKâd_lemma";
set_goal([],
	¨µcc cil1 cil2∑
	Map (Ã(c, i)∑ (c, if cc dominates c then i else Arbitrary)) cil1 =
	Map (Ã(c, i)∑ (c, if cc dominates c then i else Arbitrary)) cil2
	¥	Fst(ComputeAnd cc cil1) = Fst(ComputeAnd cc cil2)
	±	(cc dominates Fst(ComputeAnd cc cil1)
		¥	Snd(ComputeAnd cc cil1) = Snd(ComputeAnd cc cil2))
Æ);
a(rewrite_tac(µ_elim¨FstÆ fun_if_thm :: µ_elim¨SndÆ fun_if_thm ::
	map get_spec[¨ComputeAndÆ, ¨MapÆ, ¨LetÆ])
	THEN REPEAT µ_tac THEN strip_tac);
a(lemma_tac¨cil1 ˘ {(c, i)|cc dominates c ± ≥ ItemBool i}
		= cil2 ˘ {(c, i)|cc dominates c ± ≥ ItemBool i}Æ);
(* *** Goal "1" *** *)
a(all_asm_ante_tac THEN intro_µ_tac(¨cil2Æ, ¨cil2Æ)
	THEN list_induction_tac¨cil1Æ
	THEN asm_rewrite_tac(map get_spec[¨$˘Æ, ¨MapÆ]));
(* *** Goal "1.1" *** *)
a(rewrite_tac[map_null_thm]);
a(REPEAT strip_tac THEN asm_rewrite_tac[get_spec¨$˘Æ]);
(* *** Goal "1.2" *** *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨cil2Ælist_cases_thm) THEN all_var_elim_asm_tac1
	THEN POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(REPEAT strip_tac THEN all_asm_fc_tac[]);
a(asm_rewrite_tac[get_spec¨$˘Æ]);
a(cases_tac¨cc dominates Fst x'Æ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 ante_tac THEN asm_rewrite_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[]);
a(cases_tac¨≥ ItemBool (Snd x')Æ THEN asm_rewrite_tac[]);
a(PC_T1 "prop_eq_pair" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
a(lemma_tac¨Map Fst cil1 = Map Fst cil2Æ);
(* *** Goal "2.1" *** *)
a(LEMMA_T¨
	Map Fst(Map (Ã (c, i)∑
		(c, (if cc dominates c then i else Arbitrary))) cil1) = 
	Map Fst(Map (Ã (c, i)∑
		(c, (if cc dominates c then i else Arbitrary))) cil2)Æ
	(ante_tac o rewrite_rule[map_o_lemma])
	THEN1 asm_rewrite_tac[]);
a(LEMMA_T ¨
	(Fst o (Ã (c, i:Item) ∑ (c, (if cc dominates c then i else Arbitrary))))
	= FstÆ rewrite_thm_tac);
a(PC_T1"hol2" rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(cases_tac¨cil2 ˘ {(c, i)|cc dominates c ± ≥ItemBool i} = []Æ THEN
	asm_rewrite_tac[]);
a(strip_tac THEN LEMMA_T ¨cil1 = cil2Æ rewrite_thm_tac);
a(lemma_tac¨cc dominates lubl (Map Fst cil1)Æ THEN1 asm_rewrite_tac[]);
a(all_fc_tac[dominates_lubl_map_hide_lemma]);
a(swap_nth_asm_concl_tac 8 THEN asm_rewrite_tac[]);
val ComputeAnd_lemma = save_pop_thm"ComputeAnd_lemma";
set_goal([],
	¨µc vcl∑ Elems vcl Ä OK_VCâd c ± Elems vcl Ä OK_VCâc c 
	¥ BinOpAnd c vcl ç OK_VCâd cÆ);
a(rewrite_tac(
	map get_spec[¨BinOpAndÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac THEN swap_nth_asm_concl_tac 1
	THEN POP_ASM_T ante_tac THEN strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ0 rlâ0 râ0) vcl) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ1 rlâ1 râ1) vcl)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeAnd_lemma]]);
a(POP_ASM_T discard_tac THEN
	asm_ante_tac ¨Elems vcl Ä OK_VCâc cÆ THEN 
	asm_ante_tac ¨Elems vcl Ä OK_VCâd cÆ
	THEN list_induction_tac¨vclÆ);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "3" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac(map get_spec[¨ElemsÆ, ¨MapÆ]) THEN REPEAT_N 3 strip_tac);
a(LEMMA_T¨x ç OK_VCâd c ± x ç OK_VCâc cÆ	
	(strip_asm_tac o rewrite_rule(map get_spec[¨OK_VCâdÆ, ¨OK_VCâcÆ])) THEN1
	PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst (x tlâ1 rlâ1 râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (x tlâ0 rlâ0 râ0)Æ THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val BinOpAnd_OKâd_lemma = save_pop_thm"BinOpAnd_OKâd_lemma";
set_goal([],
	¨µcc cil1 cil2∑
	Map (Ã(c, i)∑ (c, if cc dominates c then i else Arbitrary)) cil1 =
	Map (Ã(c, i)∑ (c, if cc dominates c then i else Arbitrary)) cil2
	¥	Fst(ComputeOr cc cil1) = Fst(ComputeOr cc cil2)
	±	(cc dominates Fst(ComputeOr cc cil1)
		¥	Snd(ComputeOr cc cil1) = Snd(ComputeOr cc cil2))
Æ);
a(rewrite_tac(µ_elim¨FstÆ fun_if_thm :: µ_elim¨SndÆ fun_if_thm ::
	map get_spec[¨ComputeOrÆ, ¨MapÆ, ¨LetÆ])
	THEN REPEAT µ_tac THEN strip_tac);
a(lemma_tac¨cil1 ˘ {(c, i)|cc dominates c ± ItemBool i}
		= cil2 ˘ {(c, i)|cc dominates c ± ItemBool i}Æ);
(* *** Goal "1" *** *)
a(all_asm_ante_tac THEN intro_µ_tac(¨cil2Æ, ¨cil2Æ)
	THEN list_induction_tac¨cil1Æ
	THEN asm_rewrite_tac(map get_spec[¨$˘Æ, ¨MapÆ]));
(* *** Goal "1.1" *** *)
a(rewrite_tac[map_null_thm]);
a(REPEAT strip_tac THEN asm_rewrite_tac[get_spec¨$˘Æ]);
(* *** Goal "1.2" *** *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨cil2Ælist_cases_thm) THEN all_var_elim_asm_tac1
	THEN POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(REPEAT strip_tac THEN all_asm_fc_tac[]);
a(asm_rewrite_tac[get_spec¨$˘Æ]);
a(cases_tac¨cc dominates Fst x'Æ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 ante_tac THEN asm_rewrite_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[]);
a(cases_tac¨≥ ItemBool (Snd x')Æ THEN asm_rewrite_tac[]);
a(PC_T1 "prop_eq_pair" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
a(lemma_tac¨Map Fst cil1 = Map Fst cil2Æ);
(* *** Goal "2.1" *** *)
a(LEMMA_T¨
	Map Fst(Map (Ã (c, i)∑
		(c, (if cc dominates c then i else Arbitrary))) cil1) = 
	Map Fst(Map (Ã (c, i)∑
		(c, (if cc dominates c then i else Arbitrary))) cil2)Æ
	(ante_tac o rewrite_rule[map_o_lemma])
	THEN1 asm_rewrite_tac[]);
a(LEMMA_T ¨
	(Fst o (Ã (c, i:Item) ∑ (c, (if cc dominates c then i else Arbitrary))))
	= FstÆ rewrite_thm_tac);
a(PC_T1"hol2" rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(cases_tac¨cil2 ˘ {(c, i)|cc dominates c ± ItemBool i} = []Æ THEN
	asm_rewrite_tac[]);
a(strip_tac THEN LEMMA_T ¨cil1 = cil2Æ rewrite_thm_tac);
a(lemma_tac¨cc dominates lubl (Map Fst cil1)Æ THEN1 asm_rewrite_tac[]);
a(all_fc_tac[dominates_lubl_map_hide_lemma]);
a(swap_nth_asm_concl_tac 8 THEN asm_rewrite_tac[]);
val ComputeOr_lemma = save_pop_thm"ComputeOr_lemma";
set_goal([],
	¨µc vcl∑ Elems vcl Ä OK_VCâd c ± Elems vcl Ä OK_VCâc c 
	¥ BinOpOr c vcl ç OK_VCâd cÆ);
a(rewrite_tac(
	map get_spec[¨BinOpOrÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac THEN swap_nth_asm_concl_tac 1
	THEN POP_ASM_T ante_tac THEN strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ0 rlâ0 râ0) vcl) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ1 rlâ1 râ1) vcl)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeOr_lemma]]);
a(POP_ASM_T discard_tac THEN
	asm_ante_tac ¨Elems vcl Ä OK_VCâc cÆ THEN 
	asm_ante_tac ¨Elems vcl Ä OK_VCâd cÆ
	THEN list_induction_tac¨vclÆ);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "3" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac(map get_spec[¨ElemsÆ, ¨MapÆ]) THEN REPEAT_N 3 strip_tac);
a(LEMMA_T¨x ç OK_VCâd c ± x ç OK_VCâc cÆ	
	(strip_asm_tac o rewrite_rule(map get_spec[¨OK_VCâdÆ, ¨OK_VCâcÆ])) THEN1
	PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst (x tlâ1 rlâ1 râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (x tlâ0 rlâ0 râ0)Æ THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val BinOpOr_OKâd_lemma = save_pop_thm"BinOpOr_OKâd_lemma";
set_goal([], ¨µc f vc1 vc2∑ vc1 ç OK_VCâd c ± vc2 ç OK_VCâd c 
	¥ BinOp f vc1 vc2 ç OK_VCâd cÆ);
a(rewrite_tac(dominates_lub_lemma :: map get_spec[¨OK_VCâdÆ, ¨BinOpÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨Snd (vc2 tlâ0 rlâ0 râ0) = Snd (vc2 tlâ1 rlâ1 râ1)Æ
	THEN1 (contr_tac THEN all_asm_fc_tac[]));
a(lemma_tac¨≥Snd (vc1 tlâ0 rlâ0 râ0) = Snd (vc1 tlâ1 rlâ1 râ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(all_asm_fc_tac[]);
val BinOp_OKâd_lemma = save_pop_thm"BinOp_OKâd_lemma";
set_goal([], ¨µc f vc1 vc2 vc3∑
	vc1 ç OK_VCâd c ± vc2 ç OK_VCâd c ± vc3 ç OK_VCâd c ¥
	TriOp f vc1 vc2 vc3 ç OK_VCâd cÆ);
a(rewrite_tac(dominates_lub_lemma :: map get_spec[¨OK_VCâdÆ, ¨TriOpÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨Snd (vc2 tlâ0 rlâ0 râ0) = Snd (vc2 tlâ1 rlâ1 râ1) ±
	Snd (vc3 tlâ0 rlâ0 râ0) = Snd (vc3 tlâ1 rlâ1 râ1)Æ
	THEN1 (contr_tac THEN all_asm_fc_tac[]));
a(lemma_tac¨≥Snd (vc1 tlâ0 rlâ0 râ0) = Snd (vc1 tlâ1 rlâ1 râ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(all_asm_fc_tac[]);
val TriOp_OKâd_lemma = save_pop_thm"TriOp_OKâd_lemma";
set_goal([], ¨µc te cel ee∑
	te ç OK_VCâd c ±
	Elems (Map Fst cel) Ä OK_VCâd c ±
	Elems (Map Snd cel) Ä OK_VCâd c ±
	ee ç OK_VCâd c ¥
	CaseVal c te cel ee ç OK_VCâd c
Æ);
a(REPEAT µ_tac);
a(list_induction_tac¨celÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac(CaseVal_lemma:: map get_spec[¨OK_VCâdÆ, ¨LetÆ])
	THEN REPEAT µ_tac);
a(rewrite_tac[µ_elim¨SndÆ fun_if_thm]);
a(CASES_T¨c dominates Fst (te tlâ0 rlâ0 râ0)Æ rewrite_thm_tac);
a(CASES_T¨c dominates Fst (te tlâ1 rlâ1 râ1)Æ rewrite_thm_tac);
(* *** Goal "1.1" (duplicates "1.2") *** *)
a(REPEAT strip_tac THEN
	DROP_ASM_T ¨ee ç OK_VCâd cÆ
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "3" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "4" *** *)
a(rewrite_tac(µ_elim¨SndÆ fun_if_thm::µ_elim¨FstÆ fun_if_thm::CaseVal_lemma::
	map get_spec[¨OK_VCâdÆ, ¨LetÆ])
	THEN REPEAT µ_tac);
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¨Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0)Æ,
	 ¨c dominates Fst (te tlâ0 rlâ0 râ0)Æ,
	 ¨c dominates Fst (Fst x tlâ0 rlâ0 râ0)Æ]);
(* *** Goal "4.1" *** *)
val tac1 = REPEAT strip_tac THEN
	LEMMA_T ¨Snd x ç OK_VCâd cÆ
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ]);
val tac2 = REPEAT strip_tac THEN
	cases_tac¨Snd (te tlâ0 rlâ0 râ0) = Snd (te tlâ1 rlâ1 râ1)Æ
	THEN_LIST [
	asm_ante_tac ¨≥ Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	THEN POP_ASM_T (asm_rewrite_thm_tac o eq_sym_rule)
	THEN REPEAT strip_tac THEN
	LEMMA_T ¨Fst x ç OK_VCâd cÆ
		(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ])
	,
	DROP_ASM_T ¨te ç OK_VCâd cÆ
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])];
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¨Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ,
	 ¨c dominates Fst (Fst x tlâ1 rlâ1 râ1)Æ,
	 ¨c dominates Fst (te tlâ1 rlâ1 râ1)Æ]
	THEN_LIST[tac1, tac1, tac1, tac1, tac2, tac2, tac2, tac2]);
(* *** Goal "4.2" *** *)
val tac3 = REPEAT strip_tac THEN
	cases_tac¨Snd (te tlâ0 rlâ0 râ0) = Snd (te tlâ1 rlâ1 râ1)Æ
	THEN_LIST [
	asm_ante_tac ¨≥ Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0)Æ
	THEN asm_rewrite_tac[]
	THEN STRIP_T (asm_tac o conv_rule(RAND_C eq_sym_conv)) THEN
	LEMMA_T ¨Fst x ç OK_VCâd cÆ
		(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ])
	,
	DROP_ASM_T ¨te ç OK_VCâd cÆ
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th])];
val tac4 = REPEAT strip_tac THEN
	DROP_ASM_T ¨CaseVal c te cel ee ç OK_VCâd cÆ
	(fn th => all_fc_tac[rewrite_rule(map get_spec[¨OK_VCâdÆ])th]);
a(MAP_EVERY (fn t => CASES_T t (fn th => rewrite_tac[th] THEN strip_asm_tac th))
	[¨Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ,
	 ¨c dominates Fst (Fst x tlâ1 rlâ1 râ1)Æ,
	 ¨c dominates Fst (te tlâ1 rlâ1 râ1)Æ]
	THEN_LIST[tac3, tac3, tac3, tac3, tac4, tac4, tac4, tac4]);
val CaseVal_OKâd_lemma = save_pop_thm"CaseVal_OKâd_lemma";
set_goal([], ¨µc cel ee∑
	Elems (Map Fst cel) Ä OK_VCâd c ±
	Elems (Map Snd cel) Ä OK_VCâd c ±
	ee ç OK_VCâd c ¥
	Case c cel ee ç OK_VCâd c
Æ);
a(rewrite_tac(map get_spec[¨LetÆ,¨CaseÆ]));
a(REPEAT µ_tac);
a(list_induction_tac¨celÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN 
	rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨LetÆ,¨MapÆ,¨CaseCÆ,¨CaseValueÆ])
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "3" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "4" *** *)
a(DROP_NTH_ASM_T 4 ante_tac THEN
	rewrite_tac(map get_spec[ ¨LetÆ,¨MapÆ,¨CaseCÆ,¨CaseValueÆ,¨OK_VCâdÆ])
	THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 5 (ante_tac o list_µ_elim
	[¨tlâ0Æ,¨tlâ1Æ,¨rlâ0Æ,¨rlâ1Æ,¨râ0Æ,¨râ1Æ])
	THEN asm_rewrite_tac[]);
a(POP_ASM_T ante_tac 
	THEN cases_tac¨≥ c dominates Fst (Fst x tlâ0 rlâ0 râ0)Æ
	THEN cases_tac¨ItemBool (Snd (Fst x tlâ0 rlâ0 râ0))Æ
	THEN cases_tac¨ItemBool (Snd (Fst x tlâ1 rlâ1 râ1))Æ

	THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac);
(* 4.1 and 4.2 the same except for asm 1 *)
(* *** Goal "4.1" *** *)
a(POP_ASM_T (fn x => id_tac));
set_labelled_goal"4.2";
(* *** Goal "4.2" *** *)
a(POP_ASM_T (fn x => id_tac));
a(lemma_tac¨Snd x ç OK_VCâd cÆ
	THEN_LIST[PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ]),
		all_asm_fc_tac[get_spec¨OK_VCâdÆ]]);
(* *** Goal "4.3" *** *)
(* 4.3 and 4.4 the same except for asm 1 *)
a(POP_ASM_T (fn x => id_tac));
set_labelled_goal"4.4";
(* *** Goal "4.4" *** *)
a(POP_ASM_T (fn x => id_tac));
a(lemma_tac¨Fst x ç OK_VCâd cÆ
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ]));
a(lemma_tac¨≥ Snd (Fst x tlâ0 rlâ0 râ0) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(all_asm_fc_tac[get_spec¨OK_VCâdÆ]);
(* *** Goal "4.5" *** *)
a(lemma_tac¨Fst x ç OK_VCâd cÆ
	THEN1 PC_T1 "sets_ext" asm_prove_tac(map get_spec[¨ElemsÆ, ¨MapÆ]));
a(lemma_tac¨≥ Snd (Fst x tlâ0 rlâ0 râ0) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(all_asm_fc_tac[get_spec¨OK_VCâdÆ]);
val Case_OKâd_lemma = save_pop_thm"Case_OKâd_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâd c ¥ SetFuncAll f vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllÆ, ¨OK_VCâdÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨≥ Snd(Split(Map(vc tlâ0 rlâ0) rlâ0)) =
		Snd(Split(Map (vc tlâ1 rlâ1) rlâ1))Æ
	THEN1 PC_T1 "prop_eq" asm_prove_tac[]);
a(lemma_tac ¨µrl1 rl2 rlâ1∑
	Map (HideDerTableRow c) rl1 = Map (HideDerTableRow c) rl2 ±
	Map (HideDerTableRow c) rlâ0 = Map (HideDerTableRow c) rlâ1
             ¥ ≥ (Snd (Split (Map (vc tlâ0 rl1) rlâ0)))
                 = (Snd (Split (Map (vc tlâ1 rl2) rlâ1)))
             ¥ ≥ c dominates lubl (Fst (Split (Map (vc tlâ0 rl1) rlâ0)))Æ
	THEN_LIST[id_tac, all_asm_fc_tac[]]);
a(LIST_DROP_NTH_ASM_T [1, 2, 3, 4] (Combinators.K id_tac));
a(list_induction_tac¨rlâ0Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "1.1" *** *)
a(swap_asm_concl_tac
	 ¨≥ (Snd (Split (Map (vc tlâ0 rl1) [])))
		= (Snd (Split (Map (vc tlâ1 rl2) rlâ1)))Æ
	THEN asm_rewrite_tac(map get_spec[¨SplitÆ, ¨MapÆ]));
(* *** Goal "1.2" *** *)
a(swap_asm_concl_tac
	¨Map (HideDerTableRow c) [] = Map (HideDerTableRow c) rlâ1Æ
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "2.1" *** *)
a(swap_asm_concl_tac
	¨Map (HideDerTableRow c) (Cons x rlâ0) = Map (HideDerTableRow c) rlâ1Æ
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2.2" *** *)
a(var_elim_nth_asm_tac 1);
a(rewrite_tac[fst_snd_split_thm, lubl_lemma,
	get_spec¨MapÆ, dominates_lub_lemma]);
a(swap_asm_concl_tac
	 ¨≥ (Snd (Split (Map (vc tlâ0 rl1) (Cons x rlâ0))))
		= (Snd (Split (Map (vc tlâ1 rl2) (Cons x' list2))))Æ
	THEN asm_rewrite_tac[fst_snd_split_thm, lubl_lemma,
	get_spec¨MapÆ, dominates_lub_lemma]);
a(GET_NTH_ASM_T 3 (strip_asm_tac o rewrite_rule[map_def]));
a(DROP_NTH_ASM_T 7 (strip_asm_tac o rewrite_rule[fst_snd_split_thm]));
a(contr_tac THEN all_asm_fc_tac[]);
val SetFuncAll_OKâd_lemma = save_pop_thm"SetFuncAll_OKâd_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâd c ¥ SetFuncDistinct f vc ç OK_VCâd cÆ);
a(REPEAT strip_tac);
a(lemma_tac¨SetFuncDistinct f vc = SetFuncAll (f o Elems) vcÆ
	THEN_LIST [rewrite_tac(map get_spec[¨SetFuncDistinctÆ, ¨SetFuncAllÆ, ¨LetÆ]),
		POP_ASM_T rewrite_thm_tac]);
a(bc_tac[SetFuncAll_OKâd_lemma]THEN asm_rewrite_tac[]);
val SetFuncDistinct_OKâd_lemma = save_pop_thm"SetFuncDistinct_OKâd_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ± vc ç OK_VCâc c 
	¥ SetFuncAllAnd c vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllAndÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac THEN swap_nth_asm_concl_tac 1
	THEN POP_ASM_T ante_tac THEN strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rlâ0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rlâ1)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeAnd_lemma]]);
a(LEMMA_T¨
	µrl0 rl1∑
	Map (HideDerTableRow c) rl0 = Map (HideDerTableRow c) rl1
	¥
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rl0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rl1)Æ
	(fn th => all_fc_tac[th]));
a(strip_tac);
a(list_induction_tac¨rl0Æ THEN asm_rewrite_tac[map_null_thm, get_spec¨MapÆ]);
(* rewrite solves base case *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨rl1Æ list_cases_thm) THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨c dominates Fst (vc tlâ1 rlâ1 x')Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (vc tlâ0 rlâ0 x)Æ
	THEN1 ALL_ASM_FC_T asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val SetFuncAllAnd_OKâd_lemma = save_pop_thm"SetFuncAllAnd_OKâd_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ± vc ç OK_VCâc c ¥ SetFuncAllOr c vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllOrÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac THEN swap_nth_asm_concl_tac 1
	THEN POP_ASM_T ante_tac THEN strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rlâ0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rlâ1)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeOr_lemma]]);
a(LEMMA_T¨
	µrl0 rl1∑
	Map (HideDerTableRow c) rl0 = Map (HideDerTableRow c) rl1
	¥
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rl0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rl1)Æ
	(fn th => all_fc_tac[th]));
a(strip_tac);
a(list_induction_tac¨rl0Æ THEN asm_rewrite_tac[map_null_thm, get_spec¨MapÆ]);
(* rewrite solves base case *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨rl1Æ list_cases_thm) THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨c dominates Fst (vc tlâ1 rlâ1 x')Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (vc tlâ0 rlâ0 x)Æ
	THEN1 ALL_ASM_FC_T asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val SetFuncAllOr_OKâd_lemma = save_pop_thm"SetFuncAllOr_OKâd_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ¥ CountNonNull vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨CountNonNullÆ,  ¨LetÆ])
	THEN REPEAT strip_tac);
a(bc_tac[SetFuncAll_OKâd_lemma]THEN asm_rewrite_tac[]);
val CountNonNull_OKâd_lemma = save_pop_thm"CountNonNull_OKâd_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ¥ CountDistinct vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨CountDistinctÆ,  ¨LetÆ])
	THEN REPEAT strip_tac);
a(bc_tac[SetFuncDistinct_OKâd_lemma]THEN asm_rewrite_tac[]);
val CountDistinct_OKâd_lemma = save_pop_thm"CountDistinct_OKâd_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ¥ CommonValue vc ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨CommonValueÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(ALL_FC_T rewrite_tac [SetFuncAll_OKâd_lemma]);
val CommonValue_OKâd_lemma = save_pop_thm"CommonValue_OKâd_lemma";
set_goal([], ¨µc tc∑ tc ç OK_TCâd c ± tc ç OK_TCâc c ¥ ExistsTuples c tc ç OK_VCâd cÆ);
a(rewrite_tac(BoolItem_OneOne_lemma :: dominates_lub_lemma ::
	µ_elim¨FstÆfun_if_thm :: µ_elim¨SndÆfun_if_thm ::
	map get_spec[¨OK_TCâdÆ, ¨OK_TCâcÆ, ¨OK_VCâdÆ, ¨ExistsTuplesÆ, ¨LetÆ]));
a(REPEAT strip_tac THEN POP_ASM_T ante_tac);
a(all_asm_fc_tac[]);
a(asm_rewrite_tac[]);
a(cases_tac ¨c dominates Fst (tc tlâ1)Æ THEN asm_rewrite_tac[BoolItem_OneOne_lemma]);
a(cases_tac ¨HideDerTable c (Snd (tc tlâ0)) = HideDerTable c (Snd (tc tlâ1))Æ);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac(MkDerTable_lemma::
	map get_spec[¨HideDerTableÆ, ¨HideDerTableDataÆ, ¨LetÆ]));
a(strip_tac);
a(once_rewrite_tac[˘_null_map_hide_lemma]);
a(asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[]);
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[]);
val ExistsTuples_OKâd_lemma = save_pop_thm"ExistsTuples_OKâd_lemma";
set_goal([], ¨µc tc∑ tc ç OK_TCâd c ± tc ç OK_TCâc c ¥ SingleValue c tc ç OK_VCâd cÆ);
a(rewrite_tac(BoolItem_OneOne_lemma :: dominates_lub_lemma ::
	µ_elim¨FstÆfun_if_thm :: µ_elim¨SndÆfun_if_thm ::
	map get_spec[¨OK_TCâdÆ, ¨OK_TCâcÆ, ¨OK_VCâdÆ, ¨SingleValueÆ, ¨LetÆ]));
a(REPEAT strip_tac THEN POP_ASM_T ante_tac);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac ¨c dominates Fst (tc tlâ1)Æ THEN asm_rewrite_tac[]);
a(cases_tac ¨≥HideDerTable c (Snd (tc tlâ0)) = HideDerTable c (Snd (tc tlâ1))Æ);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[]);
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac(MkDerTable_lemma::
	pc_rule1 "sets_ext1" prove_rule[]
	¨{r|c dominates DTR_row r ± c dominates DTR_where r} =
	{r|c dominates DTR_row r} ° {r|c dominates DTR_where r}Æ::
	map get_spec[¨HideDerTableÆ, ¨HideDerTableDataÆ, ¨LetÆ]));
a(rewrite_tac[˘_°_lemma] THEN strip_tac);
a(all_fc_tac[map_hide_map_hide_˘_lemma]);
a(LEMMA_T¨
	#(Map (HideDerTableRow c)
		((DT_rows (Snd (tc tlâ0)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r})) =
	#(Map (HideDerTableRow c)
		((DT_rows (Snd (tc tlâ1)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}))Æ
	(strip_asm_tac o rewrite_rule[length_map_thm])
	THEN1 asm_rewrite_tac[]);
a(cases_tac¨
	#((DT_rows (Snd (tc tlâ1)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}) = 1Æ
	THEN asm_rewrite_tac[]);
a(lemma_tac¨
	#((DT_rows (Snd (tc tlâ0)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}) = 1Æ
	THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T[1,2]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[length_1_thm])));
a(asm_rewrite_tac[]);
a(lemma_tac¨HideDerTableRow c x = HideDerTableRow c x'Æ);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 5 ante_tac THEN asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2.2" *** *)
a(POP_ASM_T ante_tac THEN
	rewrite_tac[MkDerTableRow_lemma, let_def, get_spec¨HideDerTableRowÆ]);
a(strip_tac);
a(LEMMA_T¨
	#(Map (Ã (c', i)∑ if c dominates c'
		then (c', i)
		else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols x)) =
	#(Map (Ã (c', i)∑ if c dominates c'
		then (c', i)
		else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols x'))Æ
	(strip_asm_tac o rewrite_rule[length_map_thm])
	THEN1 asm_rewrite_tac[]);
a(asm_rewrite_tac[]);
a(cases_tac¨# (DTR_cols x') = 1Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨# (DTR_cols x) = 1Æ THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T[1,2]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[length_1_thm])));
a(DROP_NTH_ASM_T 4 ante_tac THEN asm_rewrite_tac[get_spec¨MapÆ]);
a(cases_tac¨c dominates Fst x''Æ THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst x'''Æ THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 3 ante_tac THEN asm_rewrite_tac[]);
val SingleValue_OKâd_lemma = save_pop_thm"SingleValue_OKâd_lemma";
set_goal([], ¨µc i∑ JoinedRowExistence i ç OK_VCâd cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâdÆ, ¨JoinedRowExistenceÆ])
	THEN REPEAT strip_tac);
a(GET_NTH_ASM_T 2 ante_tac THEN
	rewrite_tac(MkDerTableRow_lemma::map get_spec[¨HideDerTableRowÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(PC_T1 "prop_eq" asm_prove_tac[]);
val JoinedRowExistence_OKâd_lemma = save_pop_thm"JoinedRowExistence_OKâd_lemma";
set_goal([], ¨µc ci∑ DenoteConstant ci ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨DenoteConstantÆ]) THEN REPEAT strip_tac);
val DenoteConstant_OKâc_lemma = save_pop_thm"DenoteConstant_OKâc_lemma";
set_goal([], ¨µc i∑ Contents i ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨ContentsÆ])
	THEN REPEAT strip_tac);
a(all_fc_tac[HideDerTableRow_Length_lemma]);
a(cases_tac ¨1 º i ± i º # (DTR_cols râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨i º # (DTR_cols râ0)Æ THEN1 asm_rewrite_tac[]);
a(ALL_FC_T (MAP_EVERY(ante_tac o µ_elim¨cÆ)) [Nth_HideDerTableRow_lemma]);
a(asm_rewrite_tac[]);
a(PC_T1 "prop_eq_pair" prove_tac[]);
val Contents_OKâc_lemma = save_pop_thm"Contents_OKâc_lemma";
set_goal([], ¨µc i∑ Classification i ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨ClassificationÆ]) 
	THEN REPEAT strip_tac);
a(all_fc_tac[HideDerTableRow_Length_lemma]);
a(cases_tac ¨1 º i ± i º # (DTR_cols râ1)Æ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 ante_tac THEN
	rewrite_tac(MkDerTableRow_lemma::map get_spec[¨LetÆ, ¨HideDerTableRowÆ])
	THEN taut_tac);
val Classification_OKâc_lemma = save_pop_thm"Classification_OKâc_lemma";
set_goal([], ¨µc∑ CountAll ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨CountAllÆ,¨LetÆ]) THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [1,3] discard_tac);
a(POP_ASM_T ante_tac);
a(intro_µ_tac(¨rlâ1Æ,¨rlâ1Æ));
a(list_induction_tac¨rlâ0Æ);
(* *** Goal "1" *** *)
a(µ_tac);
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm)
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2" *** *)
a(REPEAT µ_tac);
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm)
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
a(rewrite_tac(lubl_lemma::MkDerTableRow_lemma::map get_spec[¨LetÆ, ¨HideDerTableRowÆ])
	THEN REPEAT strip_tac);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
val CountAll_OKâc_lemma = save_pop_thm"CountAll_OKâc_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâc c ¥ MonOp f vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨MonOpÆ, ¨LetÆ]) THEN REPEAT strip_tac);
val MonOp_OKâc_lemma = save_pop_thm"MonOp_OKâc_lemma";
set_goal([],
	¨µc vcl∑ Elems vcl Ä OK_VCâd c ± Elems vcl Ä OK_VCâc c 
	¥ BinOpAnd c vcl ç OK_VCâc cÆ);
a(rewrite_tac(
	map get_spec[¨BinOpAndÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ0 rlâ0 râ0) vcl) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ1 rlâ1 râ1) vcl)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeAnd_lemma]]);
a(asm_ante_tac ¨Elems vcl Ä OK_VCâc cÆ THEN asm_ante_tac ¨Elems vcl Ä OK_VCâd cÆ
	THEN list_induction_tac¨vclÆ);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "3" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac(map get_spec[¨ElemsÆ, ¨MapÆ]) THEN REPEAT_N 3 strip_tac);
a(LEMMA_T¨x ç OK_VCâd c ± x ç OK_VCâc cÆ	
	(strip_asm_tac o rewrite_rule(map get_spec[¨OK_VCâdÆ, ¨OK_VCâcÆ])) THEN1
	PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst (x tlâ1 rlâ1 râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (x tlâ0 rlâ0 râ0)Æ THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val BinOpAnd_OKâc_lemma = save_pop_thm"BinOpAnd_OKâc_lemma";
set_goal([],
	¨µc vcl∑ Elems vcl Ä OK_VCâd c ± Elems vcl Ä OK_VCâc c 
	¥ BinOpOr c vcl ç OK_VCâc cÆ);
a(rewrite_tac(
	map get_spec[¨BinOpOrÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ0 rlâ0 râ0) vcl) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (Ã e∑ e tlâ1 rlâ1 râ1) vcl)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeOr_lemma]]);
a(asm_ante_tac ¨Elems vcl Ä OK_VCâc cÆ THEN asm_ante_tac ¨Elems vcl Ä OK_VCâd cÆ
	THEN list_induction_tac¨vclÆ);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "3" *** *)
a(PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac(map get_spec[¨ElemsÆ, ¨MapÆ]) THEN REPEAT_N 3 strip_tac);
a(LEMMA_T¨x ç OK_VCâd c ± x ç OK_VCâc cÆ	
	(strip_asm_tac o rewrite_rule(map get_spec[¨OK_VCâdÆ, ¨OK_VCâcÆ])) THEN1
	PC_T1"sets_ext1" asm_prove_tac[get_spec¨ElemsÆ]);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst (x tlâ1 rlâ1 râ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (x tlâ0 rlâ0 râ0)Æ THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val BinOpOr_OKâc_lemma = save_pop_thm"BinOpOr_OKâc_lemma";
set_goal([], ¨µc f vc1 vc2∑ vc1 ç OK_VCâc c ± vc2 ç OK_VCâc c 
	¥ BinOp f vc1 vc2 ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨BinOpÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(ALL_ASM_FC_T rewrite_tac[]);
val BinOp_OKâc_lemma = save_pop_thm"BinOp_OKâc_lemma";
set_goal([], ¨µc f vc1 vc2 vc3∑
	vc1 ç OK_VCâc c ± vc2 ç OK_VCâc c ± vc3 ç OK_VCâc c ¥
	TriOp f vc1 vc2 vc3 ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨TriOpÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(ALL_ASM_FC_T rewrite_tac[]);
val TriOp_OKâc_lemma = save_pop_thm"TriOp_OKâc_lemma";
set_goal([], ¨µc te cel ee∑
	te ç OK_VCâd c ±
	te ç OK_VCâc c ±
	Elems (Map Fst cel) Ä OK_VCâd c ±
	Elems (Map Fst cel) Ä OK_VCâc c ±
	Elems (Map Snd cel) Ä OK_VCâc c ±
	ee ç OK_VCâc c ¥
	CaseVal c te cel ee ç OK_VCâc c
Æ);
a(REPEAT µ_tac);
a(list_induction_tac¨celÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T [1,5] (MAP_EVERY ante_tac)
	THEN rewrite_tac(CaseVal_lemma:: map get_spec[¨OK_VCâcÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(rewrite_tac[µ_elim¨FstÆ fun_if_thm]);
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "3" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "4" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "5" *** *)
a(rewrite_tac(µ_elim¨SndÆ fun_if_thm::µ_elim¨FstÆ fun_if_thm::CaseVal_lemma::
	map get_spec[¨OK_VCâcÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨
	Fst (te tlâ0 rlâ0 râ0) = Fst (te tlâ1 rlâ1 râ1) ±
	Fst (Fst x tlâ0 rlâ0 râ0) = Fst (Fst x tlâ1 rlâ1 râ1) ±
	Fst (Snd x tlâ0 rlâ0 râ0) = Fst (Snd x tlâ1 rlâ1 râ1) ±
	Fst (CaseVal c te cel ee tlâ0 rlâ0 râ0) =
		 Fst (CaseVal c te cel ee tlâ1 rlâ1 râ1)Æ);
(* *** Goal "5.1" *** *)
a(lemma_tac ¨Fst x ç OK_VCâc c ± Snd x ç OK_VCâc cÆ
	THEN1 PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
a(LIST_DROP_NTH_ASM_T [1,2,10,12]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[get_spec¨OK_VCâcÆ])));
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "5.2" *** *)
a(asm_rewrite_tac[]);
a(cases_tac¨c dominates Fst (te tlâ1 rlâ1 râ1)Æ
	THEN cases_tac¨c dominates Fst (Fst x tlâ1 rlâ1 râ1)Æ
	THEN asm_rewrite_tac[]);
(* *** Goal "5.2.1" *** *)
a(LEMMA_T¨Snd (te tlâ0 rlâ0 râ0) = Snd (te tlâ1 rlâ1 râ1)
	± Snd (Fst x tlâ0 rlâ0 râ0) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	rewrite_thm_tac);
a(lemma_tac ¨Fst x ç OK_VCâd cÆ
	THEN1 PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
a(LIST_DROP_NTH_ASM_T [1,16]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[get_spec¨OK_VCâdÆ])));
a(lemma_tac¨c dominates Fst (te tlâ0 rlâ0 râ0)
	±	c dominates Fst (Fst x tlâ0 rlâ0 râ0)Æ
	THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "5.2.2" *** *)
a(CASES_T ¨Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0)Æ
	rewrite_thm_tac
	THEN CASES_T¨Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	rewrite_thm_tac);
(* *** Goal "5.2.3" *** *)
a(CASES_T ¨Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0)Æ
	rewrite_thm_tac
	THEN CASES_T¨Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	rewrite_thm_tac);
(* *** Goal "5.2.4" *** *)
a(CASES_T ¨Snd (te tlâ0 rlâ0 râ0) = Snd (Fst x tlâ0 rlâ0 râ0)Æ
	rewrite_thm_tac
	THEN CASES_T¨Snd (te tlâ1 rlâ1 râ1) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	rewrite_thm_tac);
val CaseVal_OKâc_lemma = save_pop_thm"CaseVal_OKâc_lemma";
set_goal([], ¨µc cel ee∑
	Elems (Map Fst cel) Ä OK_VCâd c ±
	Elems (Map Fst cel) Ä OK_VCâc c ±
	Elems (Map Snd cel) Ä OK_VCâc c ±
	ee ç OK_VCâc c ¥
	Case c cel ee ç OK_VCâc c
Æ);
a(rewrite_tac(map get_spec[¨LetÆ,¨CaseÆ]));
a(REPEAT µ_tac);
a(list_induction_tac¨celÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN 
	rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨LetÆ,¨MapÆ,¨CaseCÆ,¨CaseValueÆ])
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "3" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "4" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
(* *** Goal "5" *** *)
a(rewrite_tac(map get_spec[ ¨LetÆ,¨MapÆ,¨CaseCÆ,¨CaseValueÆ,¨OK_VCâcÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨Fst x ç OK_VCâc cÆ THEN1
	PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
a(POP_ASM_T (fn th => all_asm_fc_tac[rewrite_rule[get_spec¨OK_VCâcÆ]th]));
a(asm_rewrite_tac[]);
a(cases_tac¨≥ c dominates Fst (Fst x tlâ1 rlâ1 râ1)Æ
	THEN asm_rewrite_tac[]);
a(lemma_tac¨Snd x ç OK_VCâc cÆ THEN1
	PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
a(POP_ASM_T (fn th => all_asm_fc_tac[rewrite_rule[get_spec¨OK_VCâcÆ]th]));
a(asm_rewrite_tac[]);
a(LEMMA_T¨Snd (Fst x tlâ0 rlâ0 râ0) = Snd (Fst x tlâ1 rlâ1 râ1)Æ
	rewrite_thm_tac);
(* *** Goal "5.1" *** *)
a(lemma_tac¨Fst x ç OK_VCâd cÆ THEN1
	PC_T1 "sets_ext1" asm_prove_tac(map get_spec[¨MapÆ, ¨ElemsÆ]));
a(POP_ASM_T (strip_asm_tac o rewrite_rule[get_spec¨OK_VCâdÆ]));
a(lemma_tac¨c dominates Fst (Fst x tlâ0 rlâ0 râ0)Æ
	THEN1 asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "5.2" *** *)
a(cases_tac¨ItemBool (Snd (Fst x tlâ1 rlâ1 râ1))Æ
	THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 12 (fn th => all_asm_fc_tac[rewrite_rule[get_spec¨OK_VCâcÆ]th]));
val Case_OKâc_lemma = save_pop_thm"Case_OKâc_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâc c ¥ SetFuncAll f vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllÆ, ¨OK_VCâcÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(lemma_tac ¨µtlâ0 tlâ1 rl1 rl2 rlâ1∑
	Map (HideDerTable c) tlâ0 = Map (HideDerTable c) tlâ1 ±
	Map (HideDerTableRow c) rl1 = Map (HideDerTableRow c) rl2 ±
	Map (HideDerTableRow c) rlâ0 = Map (HideDerTableRow c) rlâ1
             ¥ Fst (Split (Map (vc tlâ0 rl1) rlâ0))
                 = Fst(Split (Map (vc tlâ1 rl2) rlâ1))Æ
	THEN_LIST[id_tac, ALL_ASM_FC_T rewrite_tac[]]);
a(LIST_DROP_NTH_ASM_T [1, 2, 3] discard_tac);
a(list_induction_tac¨rlâ0Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "1.1" *** *)
a(asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "1.2" *** *)
a(var_elim_nth_asm_tac 1);
a(all_asm_ante_tac THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2" *** *)
a(strip_asm_tac (µ_elim¨rlâ1Æ list_cases_thm));
(* *** Goal "2.1" *** *)
a(swap_asm_concl_tac
	¨Map (HideDerTableRow c) (Cons x rlâ0) = Map (HideDerTableRow c) rlâ1Æ
	THEN asm_rewrite_tac(map get_spec[¨MapÆ]));
(* *** Goal "2.2" *** *)
a(var_elim_nth_asm_tac 1);
a(all_asm_ante_tac THEN rewrite_tac[fst_snd_split_thm, get_spec¨MapÆ]
	THEN REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2.2.2" *** *)
a(all_asm_fc_tac[]);
val SetFuncAll_OKâc_lemma = save_pop_thm"SetFuncAll_OKâc_lemma";
set_goal([], ¨µc f vc∑ vc ç OK_VCâc c ¥ SetFuncDistinct f vc ç OK_VCâc cÆ);
a(REPEAT strip_tac);
a(lemma_tac¨SetFuncDistinct f vc = SetFuncAll (f o Elems) vcÆ
	THEN_LIST [rewrite_tac(map get_spec[¨SetFuncDistinctÆ, ¨SetFuncAllÆ, ¨LetÆ]),
		POP_ASM_T rewrite_thm_tac]);
a(bc_tac[SetFuncAll_OKâc_lemma]THEN asm_rewrite_tac[]);
val SetFuncDistinct_OKâc_lemma = save_pop_thm"SetFuncDistinct_OKâc_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ± vc ç OK_VCâc c 
	¥ SetFuncAllAnd c vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllAndÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rlâ0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rlâ1)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeAnd_lemma]]);
a(LEMMA_T¨
	µrl0 rl1∑
	Map (HideDerTableRow c) rl0 = Map (HideDerTableRow c) rl1
	¥
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rl0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rl1)Æ
	(fn th => all_fc_tac[th]));
a(strip_tac);
a(list_induction_tac¨rl0Æ THEN asm_rewrite_tac[map_null_thm, get_spec¨MapÆ]);
(* rewrite solves base case *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨rl1Æ list_cases_thm) THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨c dominates Fst (vc tlâ1 rlâ1 x')Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (vc tlâ0 rlâ0 x)Æ
	THEN1 ALL_ASM_FC_T asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val SetFuncAllAnd_OKâc_lemma = save_pop_thm"SetFuncAllAnd_OKâc_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâd c ± vc ç OK_VCâc c ¥ SetFuncAllOr c vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨SetFuncAllOrÆ, ¨OK_VCâdÆ, ¨OK_VCâcÆ])
	THEN REPEAT strip_tac);
a(lemma_tac¨
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rlâ0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rlâ1)Æ
	THEN_LIST [id_tac, all_fc_tac[ComputeOr_lemma]]);
a(LEMMA_T¨
	µrl0 rl1∑
	Map (HideDerTableRow c) rl0 = Map (HideDerTableRow c) rl1
	¥
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ0 rlâ0) rl0) =
	Map (Ã (c', i)∑ (c', (if c dominates c' then i else Arbitrary)))
	(Map (vc tlâ1 rlâ1) rl1)Æ
	(fn th => all_fc_tac[th]));
a(strip_tac);
a(list_induction_tac¨rl0Æ THEN asm_rewrite_tac[map_null_thm, get_spec¨MapÆ]);
(* rewrite solves base case *)
a(REPEAT strip_tac);
a(strip_asm_tac(µ_elim¨rl1Æ list_cases_thm) THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[get_spec¨MapÆ]);
a(strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨c dominates Fst (vc tlâ1 rlâ1 x')Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (vc tlâ0 rlâ0 x)Æ
	THEN1 ALL_ASM_FC_T asm_rewrite_tac[]);
a(contr_tac THEN all_asm_fc_tac[]);
val SetFuncAllOr_OKâc_lemma = save_pop_thm"SetFuncAllOr_OKâc_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâc c ¥ CountNonNull vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨CountNonNullÆ,  ¨LetÆ])
	THEN REPEAT strip_tac);
a(bc_tac[SetFuncAll_OKâc_lemma]THEN asm_rewrite_tac[]);
val CountNonNull_OKâc_lemma = save_pop_thm"CountNonNull_OKâc_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâc c ¥ CountDistinct vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨CountDistinctÆ,  ¨LetÆ])
	THEN REPEAT strip_tac);
a(bc_tac[SetFuncDistinct_OKâc_lemma]THEN asm_rewrite_tac[]);
val CountDistinct_OKâc_lemma = save_pop_thm"CountDistinct_OKâc_lemma";
set_goal([], ¨µc vc∑ vc ç OK_VCâc c ¥ CommonValue vc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨CommonValueÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(ALL_FC_T rewrite_tac [SetFuncAll_OKâc_lemma]);
val CommonValue_OKâc_lemma = save_pop_thm"CommonValue_OKâc_lemma";
set_goal([], ¨µc tc∑ tc ç OK_TCâd c ± tc ç OK_TCâc c ¥ ExistsTuples c tc ç OK_VCâc cÆ);
a(rewrite_tac(
	map get_spec[¨OK_TCâdÆ, ¨OK_TCâcÆ, ¨OK_VCâcÆ, ¨ExistsTuplesÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(cases_tac¨≥ HideDerTable c (Snd (tc tlâ0)) = HideDerTable c (Snd (tc tlâ1))Æ);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[]);
a(DROP_ASM_T ¨≥ c dominates Fst (tc tlâ0)Æ ante_tac THEN asm_rewrite_tac[]);
a(strip_tac THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[]);
a(cases_tac¨c dominates Fst (tc tlâ1)Æ THEN asm_rewrite_tac[]);
a(DROP_ASM_T ¨HideDerTable c (Snd (tc tlâ0)) = HideDerTable c (Snd (tc tlâ1))Æ
	ante_tac);
a(rewrite_tac(MkDerTable_lemma::
	pc_rule1 "sets_ext1" prove_rule[]
	¨{r|c dominates DTR_row r ± c dominates DTR_where r} =
	{r|c dominates DTR_row r} ° {r|c dominates DTR_where r}Æ::
	˘_°_lemma::
	map get_spec[¨HideDerTableÆ, ¨HideDerTableDataÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(all_fc_tac[map_hide_map_hide_˘_lemma]);
a(lemma_tac¨
	Map DTR_row(Map(HideDerTableRow c)
		((DT_rows (Snd (tc tlâ0)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r})) =
	Map DTR_row(Map(HideDerTableRow c)
		((DT_rows (Snd (tc tlâ1)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}))Æ
	THEN1 asm_rewrite_tac[]);
a(POP_ASM_T ante_tac THEN 
	rewrite_tac[map_o_lemma, DTR_row_o_HideDerTableRow_lemma]);
a(STRIP_T rewrite_thm_tac);
val ExistsTuples_OKâc_lemma = save_pop_thm"ExistsTuples_OKâc_lemma";
set_goal([], ¨µc tc∑ tc ç OK_TCâd c ± tc ç OK_TCâc c ¥ SingleValue c tc ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_TCâdÆ, ¨OK_TCâcÆ, ¨OK_VCâcÆ, ¨SingleValueÆ, ¨LetÆ])
	THEN REPEAT strip_tac);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[µ_elim¨FstÆfun_if_thm]);
a(cases_tac¨c dominates Fst (tc tlâ1)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨c dominates Fst (tc tlâ0)Æ THEN1 asm_rewrite_tac[]);
a(cases_tac¨≥HideDerTable c (Snd (tc tlâ0)) = HideDerTable c (Snd (tc tlâ1))Æ
	THEN1 all_asm_fc_tac[]);
a(POP_ASM_T ante_tac THEN rewrite_tac(MkDerTable_lemma::
	pc_rule1 "sets_ext1" prove_rule[]
	¨{r|c dominates DTR_row r ± c dominates DTR_where r} =
	{r|c dominates DTR_row r} ° {r|c dominates DTR_where r}Æ::
	map get_spec[¨HideDerTableÆ, ¨HideDerTableDataÆ, ¨LetÆ]));
a(rewrite_tac[˘_°_lemma] THEN strip_tac);
a(all_fc_tac[map_hide_map_hide_˘_lemma]);
a(LEMMA_T¨
	#(Map (HideDerTableRow c)
		((DT_rows (Snd (tc tlâ0)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r})) =
	#(Map (HideDerTableRow c)
		((DT_rows (Snd (tc tlâ1)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}))Æ
	(strip_asm_tac o rewrite_rule[length_map_thm])
	THEN1 asm_rewrite_tac[]);
a(cases_tac¨
	#((DT_rows (Snd (tc tlâ1)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}) = 1Æ
	THEN asm_rewrite_tac[]);
a(lemma_tac¨
	#((DT_rows (Snd (tc tlâ0)) ˘ {r|c dominates DTR_row r})
			˘ {r|c dominates DTR_where r}) = 1Æ
	THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T[1,2]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[length_1_thm])));
a(asm_rewrite_tac[]);
a(lemma_tac¨HideDerTableRow c x = HideDerTableRow c x'Æ);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 5 ante_tac THEN asm_rewrite_tac[get_spec¨MapÆ]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN
	rewrite_tac[MkDerTableRow_lemma, let_def, get_spec¨HideDerTableRowÆ]);
a(strip_tac);
a(LEMMA_T¨
	#(Map (Ã (c', i)∑ if c dominates c'
		then (c', i)
		else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols x)) =
	#(Map (Ã (c', i)∑ if c dominates c'
		then (c', i)
		else (c', ValuedItemItem (MkValuedItem sterling dummyVal)))
               (DTR_cols x'))Æ
	(strip_asm_tac o rewrite_rule[length_map_thm])
	THEN1 asm_rewrite_tac[]);
a(asm_rewrite_tac[]);
a(cases_tac¨# (DTR_cols x') = 1Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨# (DTR_cols x) = 1Æ THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T[1,2]
	(MAP_EVERY(strip_asm_tac o rewrite_rule[length_1_thm])));
a(DROP_NTH_ASM_T 4 ante_tac THEN asm_rewrite_tac[get_spec¨MapÆ]);
a(cases_tac¨c dominates Fst x''Æ THEN asm_rewrite_tac[]);
(* *** Goal "2.1" *** *)
a(cases_tac¨c dominates Fst x'''Æ THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(cases_tac¨c dominates Fst x'''Æ THEN asm_rewrite_tac[]);
a(PC_T1 "prop_eq_pair" prove_tac[]);
val SingleValue_OKâc_lemma = save_pop_thm"SingleValue_OKâc_lemma";
set_goal([], ¨µc i∑ JoinedRowExistence i ç OK_VCâc cÆ);
a(rewrite_tac(map get_spec[¨OK_VCâcÆ, ¨JoinedRowExistenceÆ])
	THEN REPEAT strip_tac);
val JoinedRowExistence_OKâc_lemma = save_pop_thm"JoinedRowExistence_OKâc_lemma";
