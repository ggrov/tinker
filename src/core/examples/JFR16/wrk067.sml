force_delete_theory"topology" handle Fail _ => ();
open_theory"bin_rel";
set_merge_pcs["basic_hol1", "'sets_alg"];
new_theory"topology";
new_parent"fincomb";
πHOLCONST
‹ Topology : 'a SET SET SET
˜¸¸¸¸¸¸
‹ 	Topology =
‹	{‘ | (µV∑ V Ä ‘ ¥ ﬁ V ç ‘) ± (µA B∑A ç ‘ ± B ç ‘ ¥ A ° B ç ‘)}
∞
πHOLCONST
‹ SpaceâT : 'a SET SET ≠ 'a SET
˜¸¸¸¸¸¸
‹ µ‘∑ SpaceâT ‘ = ﬁ ‘
∞
declare_postfix(400, "Closed");
πHOLCONST
‹ $Closed : 'a SET SET ≠ 'a SET SET
˜¸¸¸¸¸¸
‹ µ‘∑ ‘ Closed = {A | ∂B∑B ç ‘ ± A = SpaceâT ‘ \ B}
∞
declare_infix(280, "ÚâT");
πHOLCONST
‹ $ÚâT : 'a SET ≠ 'a SET SET ≠ 'a SET SET
˜¸¸¸¸¸¸
‹ µX ‘∑ 	(X ÚâT ‘)
‹ =	{A | ∂B∑ B ç ‘ ± A = B ° X}
∞
declare_infix(290, "∏âT");
πHOLCONST
‹ $∏âT : 'a SET SET ≠ 'b SET SET ≠ ('a ∏ 'b) SET SET
˜¸¸¸¸¸¸
‹ µ” ‘∑	(” ∏âT ‘) = {C | µ x y∑ (x, y) ç C
‹		¥ ∂A B∑ A ç ” ± B ç ‘ ± x ç A ± y ç B ± (A ∏ B) Ä C}
∞
πHOLCONST
‹ $1âT : ONE SET SET
˜¸¸¸¸¸¸
‹ 1âT = {{}; {One}}
∞
πHOLCONST
‹ $êâT : Ó ≠ 'a SET SET ≠ 'a LIST SET SET 
˜¸¸¸¸¸¸
‹ µ‘ n∑ 	êâT 0 ‘ = { {}; {[]} }
‹ ±		(êâT (n+1) ‘) = {C | ≥[] ç C ± µ x v∑ Cons x v ç C ¥
‹				∂A B∑ A ç ‘ ± B ç êâT n ‘ ± x ç A ± v ç B ±
‹					µy w∑y ç A ± w ç B ¥ Cons y w ç C}
∞
declare_postfix(400, "Continuous");
πHOLCONST
‹ $Continuous : ('a SET SET ∏ 'b SET SET) ≠ ('a ≠ 'b) SET
˜¸¸¸¸¸¸
‹ µ” ‘∑	(”, ‘) Continuous =
‹	{f
‹	|	(µx∑ x ç SpaceâT ” ¥ f x ç SpaceâT ‘)
‹	±	(µA∑ A ç ‘ ¥ {x | x ç SpaceâT ” ± f x ç A} ç ”)}
∞
πHOLCONST
‹ Hausdorff : 'a SET SET SET
˜¸¸¸¸¸¸
‹ 	Hausdorff =
‹	{‘ | µx y∑ x ç SpaceâT ‘ ± y ç SpaceâT ‘ ± ≥x = y
‹	¥	∂A B∑A ç ‘ ± B ç ‘ ± x ç A ± y ç B ± A ° B = {}}
∞
declare_postfix(400, "Compact");
πHOLCONST
‹ $Compact : 'a SET SET ≠ 'a SET SET
˜¸¸¸¸¸¸
‹ µ‘∑ ‘ Compact =
‹	{A
‹	 |	A Ä SpaceâT ‘
‹	±	µV∑ V Ä ‘ ± A Ä ﬁ V ¥ ∂W∑ W Ä V ± W ç Finite ± A Ä ﬁ W}
∞
declare_postfix(400, "Connected");
πHOLCONST
‹ $Connected : 'a SET SET ≠ 'a SET SET
˜¸¸¸¸¸¸
‹ µ‘∑ ‘ Connected =
‹	{A | A Ä SpaceâT ‘
‹	± µB C∑ B ç ‘ ± C ç ‘ ± A Ä B ¿ C ± A ° B ° C = {} ¥ (A Ä B ≤ A Ä C)}
∞
declare_postfix(400, "Homeomorphism");
πHOLCONST
‹ $Homeomorphism : ('a SET SET ∏ 'b SET SET) ≠ ('a ≠ 'b) SET
˜¸¸¸¸¸¸
‹ µ” ‘∑	(”, ‘) Homeomorphism =
‹	{f
‹	|	f ç (”, ‘) Continuous
‹	±	∂g∑ 	g ç (‘, ”) Continuous
‹		±	(µx∑x ç SpaceâT ” ¥ g(f x) = x)
‹		±	(µy∑y ç SpaceâT ‘ ¥ f(g y) = y)}
∞
declare_infix(400, "Interior");
declare_infix(400, "Boundary");
declare_infix(400, "Closure");
πHOLCONST
‹ $Interior $Boundary $Closure: 'a SET SET ≠ 'a SET ≠ 'a SET
˜¸¸¸¸¸¸
‹ µ‘ A∑
‹	‘ Interior A = {x | ∂B∑ B ç ‘ ± x ç B ± B Ä A}
‹ ± 	‘ Boundary A =
‹	{x | x ç SpaceâT ‘ ± µB∑ B ç ‘ ± x ç B ¥ ≥B ° A = {} ± ≥B \ A = {}}
‹ ± 	‘ Closure A = •{B | B ç ‘ Closed ± A ° SpaceâT ‘ Ä B}
∞
declare_postfix(400, "CoveringProjection");
πHOLCONST
‹ $CoveringProjection : ('a SET SET ∏ 'b SET SET) ≠ ('a ≠ 'b) SET
˜¸¸¸¸¸¸
‹ µ” ‘∑	(”, ‘) CoveringProjection =
‹	{p
‹	|	p ç (”, ‘) Continuous
‹	±	µy∑ 	y ç SpaceâT ‘
‹		¥	∂C∑	y ç C ± C ç ‘ ±
‹			∂U∑	U Ä ”
‹			±	(µx∑ x ç SpaceâT ” ± p x ç C
‹					¥ ∂A∑ x ç A ± A ç U)
‹			±	(µA B∑ A ç U ± B ç U ± ≥A ° B = {} ¥ A = B)
‹			±	(µA∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism)}
∞
πHOLCONST
‹ SpaceâK : ('a SET ∏ Ó) SET ≠ 'a SET
˜¸¸¸¸¸¸
‹ µC∑ SpaceâK C = ﬁ{c | ∂m∑ (c, m) ç C}
∞
declare_infix(400, "Skeleton");
πHOLCONST
‹ $Skeleton : Ó ≠ ('a SET ∏ Ó) SET ≠ 'a SET
˜¸¸¸¸¸¸
‹ µn C∑ n Skeleton C = ﬁ{c | ∂m∑m º n ± (c, m) ç C}
∞
πHOLCONST
‹ Protocomplex : 'a SET SET ≠ ('a SET ∏ Ó) SET SET
˜¸¸¸¸¸¸
‹ µC ‘∑	C ç Protocomplex ‘ §
‹	(µc m∑ (c, m) ç C ¥ c ç ‘ Closed)
‹ ±	(µx∑ x ç SpaceâK C ¥
‹		∂â1 (c, m)∑ (c, m) ç C ± x ç ((m Skeleton C) ÚâT ‘) Interior c)
‹ ±	(µA∑ A Ä SpaceâK C ± (µc m∑ (c, m) ç C ¥ A ° c ç ‘ Closed) ¥ A ç ‘ Closed)
‹ ±	(µc m∑ (c, m) ç C ¥ {(d, n) | (d, n) ç C ± n < m ± ≥c ° d = {}} ç Finite)
∞
force_delete_theory"metric_spaces" handle Fail _ => ();
open_theory"topology";
new_theory"metric_spaces";
new_parent"analysis";
new_parent"trees";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
πHOLCONST
‹ Metric : ('a ∏ 'a ≠ Ø) SET
˜¸¸¸¸¸¸
‹ 	Metric =
‹	{	D
‹	|	(µx y∑ ÓØ 0 º D(x, y))
‹	±	(µx y∑ D(x, y) = ÓØ 0 § x = y)
‹	±	(µx y∑ D(x, y) = D (y, x))
‹	±	(µx y z∑ D(x, z) º D (x, y) + D(y, z))}
∞
declare_postfix(400, "MetricTopology");
πHOLCONST
‹ $MetricTopology : ('a ∏ 'a ≠ Ø) ≠ 'a SET SET
˜¸¸¸¸¸¸
‹  µD∑ D MetricTopology = {A | µx∑x ç A ¥ ∂e∑ ÓØ 0 < e ± (µy∑D(x, y) < e ¥ y ç A)}
∞
πHOLCONST
‹ ListMetric : ('a ∏ 'a ≠ Ø) ≠ ('a LIST ∏ 'a LIST) ≠ Ø
˜¸¸¸¸¸¸
‹ µD x v y w∑
‹		ListMetric D ([], []) = 0.
‹ ±		ListMetric D (Cons x v, []) = 1. + D(x, Arbitrary) + ListMetric D (v, [])
‹ ±		ListMetric D ([], Cons y w) = 1. + D(Arbitrary, y) + ListMetric D ([], w)
‹ ±		ListMetric D (Cons x v, Cons y w) = D(x, y) + ListMetric D (v, w)
∞
force_delete_theory"topology_Ø" handle Fail _ => ();
open_theory"metric_spaces";
new_theory"topology_Ø";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
declare_alias("OâR", ¨OpenâRÆ);
πHOLCONST
‹ DâR : Ø ∏ Ø ≠ Ø
˜¸¸¸¸¸¸
‹  µx y∑ DâR(x, y) = Abs(y - x)
∞
πHOLCONST
‹ DâR2 : (Ø ∏ Ø) ∏ (Ø ∏ Ø) ≠ Ø
˜¸¸¸¸¸¸
‹  µx1 y1 x2 y2∑ DâR2 ((x1, y1), (x2, y2)) = Abs(x2 - x1) + Abs(y2 - y1)
∞
declare_postfix(400, "Space");

πHOLCONST
‹ $Space : Ó ≠ Ø LIST SET SET
˜¸¸¸¸¸¸
‹  µn∑ n Space = {v | #v = n} ÚâT ListMetric DâR MetricTopology
∞
declare_postfix(400, "Cube");

πHOLCONST
‹ $Cube : Ó ≠ Ø LIST SET SET
˜¸¸¸¸¸¸
‹  µn∑ n Cube = {v | Elems v Ä ClosedInterval 0. 1.} ÚâT n Space
∞
declare_postfix(400, "OpenCube");

πHOLCONST
‹ $OpenCube : Ó ≠ Ø LIST SET SET
˜¸¸¸¸¸¸
‹  µn∑ n OpenCube = {v | Elems v Ä OpenInterval 0. 1.} ÚâT n Space
∞
declare_postfix(400, "Sphere");

πHOLCONST
‹ $Sphere : Ó ≠ Ø LIST SET SET
˜¸¸¸¸¸¸
‹  µn∑ n Sphere = {v | ≥Elems v ° {0.; 1.} = {}} ÚâT n Cube
∞
force_delete_theory"homotopy" handle Fail _ => ();
open_theory"topology_Ø";
new_theory"homotopy";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
πHOLCONST
‹ Paths : 'a SET SET ≠ (Ø ≠ 'a) SET
˜¸¸¸¸¸¸
‹ µ‘∑	Paths ‘ =
‹	{	f
‹	|	f ç (OâR, ‘) Continuous
‹	±	(µx∑ x º 0. ¥ f x = f 0.)
‹	±	(µx∑ 1. º x ¥ f x = f 1.)}
∞
declare_postfix(400, "PathConnected");
πHOLCONST
‹ $PathConnected : 'a SET SET ≠ 'a SET SET
˜¸¸¸¸¸¸
‹ µ‘∑ ‘ PathConnected =
‹	{	A
‹	|	A Ä SpaceâT ‘
‹	±	µx y∑ x ç A ± y ç A
‹	¥	∂f∑ 	f ç Paths ‘
‹		±	(µ t∑ f t ç A)
‹		±	f (ÓØ 0) = x
‹		±	f (ÓØ 1) = y}
∞
πHOLCONST
‹ LocallyPathConnected : 'a SET SET SET
˜¸¸¸¸¸¸
‹ µ‘∑	‘ ç LocallyPathConnected
‹ §	µx A∑x ç A ± A ç ‘ ¥ ∂B∑B ç ‘ ± x ç B ± B Ä A ± B ç ‘ PathConnected
∞
declare_postfix(400, "Homotopy");
πHOLCONST
‹ $Homotopy : 'a SET SET ∏ 'a SET ∏ 'b SET SET ≠ ('a ∏ Ø ≠ 'b) SET
˜¸¸¸¸¸¸
‹ µ” X ‘∑ (”, X, ‘) Homotopy =
‹	{ f | f ç ((” ∏âT OâR), ‘) Continuous ± µx s t∑x ç X ¥ f(x, s) = f(x, t)}
∞
declare_postfix(400, "HomotopyClass");
πHOLCONST
‹ $HomotopyClass : 'a SET SET ∏ 'a SET ∏ 'b SET SET ≠ ('a ≠ 'b) ≠ ('a ≠ 'b) SET
˜¸¸¸¸¸¸
‹ µ” X ‘ f∑ ((”, X, ‘) HomotopyClass) f =
‹	{g
‹	| ∂H∑ H ç (”, X, ‘) Homotopy
‹	± (µx∑ H(x, ÓØ 0) = f x) ± (µx∑ H(x, ÓØ 1) = g x)}
∞
declare_infix(300, "+âP");
πHOLCONST
‹ $+âP : (Ø ≠ 'a) ≠ (Ø ≠ 'a) ≠ (Ø ≠ 'a)
˜¸¸¸¸¸¸
‹ µf g∑ f +âP g = (Ãt∑if t º 1/2 then f (ÓØ 2*t) else g (ÓØ 2*(t - 1/2)))
∞
πHOLCONST
‹ 0âP : 'a ≠ (Ø ≠ 'a)
˜¸¸¸¸¸¸
‹ µx∑ 0âP x = (Ãt∑ x)
∞
πHOLCONST
‹ $~âP : (Ø ≠ 'a) ≠ (Ø ≠ 'a)
˜¸¸¸¸¸¸
‹ µf∑ ~âP f = (Ãt∑ f(ÓØ 1 -  t))
∞
πHOLCONST
‹ HomotopyLiftingProperty :
‹	('a SET SET ∏ ('b ≠ 'c ) ∏ 'b SET SET ∏ 'c SET SET) SET
˜¸¸¸¸¸¸
‹ µ“ ” ‘ p∑
‹	(“, (p, ”, ‘)) ç HomotopyLiftingProperty
‹ §		“ ç Topology
‹	±	” ç Topology
‹	±	‘ ç Topology
‹	±	p ç (”, ‘) Continuous
‹	±	(µf h∑
‹			f ç (“, ”) Continuous
‹		±	h ç (“ ∏âT OâR, ‘) Continuous
‹		±	(µ x∑ x ç SpaceâT “ ¥ h (x, 0.) = p (f x))
‹		¥	(∂L∑
‹				L ç (“ ∏âT OâR, ”) Continuous
‹			± 	(µ x∑ x ç SpaceâT “ ¥ L (x, 0.) = f x)
‹			±	(µ x s∑
‹					x ç SpaceâT “
‹				±	s ç ClosedInterval 0. 1.
‹				¥	p (L (x, s)) = h (x, s))))
∞
open_theory"topology";
set_merge_pcs["basic_hol1", "'sets_alg"];

val enum_set_Ä_thm = save_thm ( "enum_set_Ä_thm", (
set_goal([], ¨
	µ A B C∑  (Insert A B) Ä C § A ç C ± B Ä C
Æ);
a(PC_T1 "sets_ext1" rewrite_tac[insert_def]);
a(prove_tac[]);
pop_thm()
));


val ﬁ_enum_set_clauses = save_thm ( "ﬁ_enum_set_clauses", (
set_goal([], ¨
	ﬁ{} = {}
±	µ A B∑  ﬁ(Insert A B) = A ¿ (ﬁB)
Æ);
a(REPEAT strip_tac THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(PC_T "sets_ext1" strip_tac);
a(rewrite_tac[ﬁ_def, insert_def, ¿_def]);
a(prove_tac[]);
pop_thm()
));


val •_enum_set_clauses = save_thm ( "•_enum_set_clauses", (
set_goal([], ¨
	•{} = Universe
±	µ A B∑  •(Insert A B) = A ° (•B)
Æ);
a(REPEAT strip_tac THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(PC_T "sets_ext1" strip_tac);
a(rewrite_tac[•_def, insert_def, °_def]);
a(prove_tac[]);
pop_thm()
));
val enum_set_clauses = list_±_intro
	[enum_set_Ä_thm,  ﬁ_enum_set_clauses, •_enum_set_clauses];



val finite_image_thm = save_thm ( "finite_image_thm", (
set_goal([], ¨µ f : 'a ≠ 'b; A : 'a SET∑
	 A ç Finite ¥ {y | ∂x∑x ç A ± y = f x} ç Finite
Æ);
a(REPEAT strip_tac);
a(finite_induction_tac ¨AÆ THEN1 rewrite_tac[]);
(* *** Goal "1" *** *)
a(LEMMA_T¨{y:'b|F} = {}Æ (fn th => rewrite_tac[th, empty_finite_thm])
	THEN1 PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(LEMMA_T ¨{y|∂ x'∑ x' ç {x} ¿ A ± y = f x'} = {f x} ¿ {y|∂ x'∑ x' ç A ± y = f x'}Æ
	rewrite_thm_tac
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(bc_thm_tac singleton_¿_finite_thm THEN REPEAT strip_tac);
pop_thm()
));


val Ä_size_thm = save_thm ( "Ä_size_thm", (
set_goal([], ¨µa b∑ a ç Finite ± b Ä a ¥ #b º #aÆ);
a(REPEAT strip_tac);
a(POP_ASM_T ante_tac THEN intro_µ_tac(¨bÆ, ¨bÆ));
a(finite_induction_tac¨aÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LEMMA_T ¨b = {}Æ rewrite_thm_tac);
a(PC_T1"sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(cases_tac¨x ç bÆ);
(* *** Goal "2.1" *** *)
a(PC_T1 "predicates" lemma_tac¨b \ {x} Ä a ± ≥x ç b \ {x}Æ
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(all_fc_tac[Ä_finite_thm]);
a(LEMMA_T¨b = {x} ¿ (b \ {x})Æ once_rewrite_thm_tac
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(ALL_FC_T rewrite_tac[size_singleton_¿_thm]);
a(all_asm_fc_tac[]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨b Ä aÆ THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2.2.1" *** *)
a(asm_fc_tac[] THEN all_var_elim_asm_tac);
(* *** Goal "2.2.2" *** *)
a(ALL_FC_T rewrite_tac[size_singleton_¿_thm]);
a(asm_fc_tac[] THEN PC_T1 "lin_arith" asm_prove_tac[]);
pop_thm()
));


val Ä_size_thm1 = save_thm ( "Ä_size_thm1", (
set_goal([],¨µa b∑ a ç Finite ± b Ä a ± ≥b = a ¥ #b < #aÆ);
a(REPEAT strip_tac);
a(lemma_tac¨a \ b Ä a ± ≥a \ b = {}Æ THEN1
	PC_T1 "sets_ext1" asm_prove_tac[]);
a(REPEAT strip_tac THEN all_fc_tac[Ä_finite_thm]);
a(LEMMA_T ¨# (b ¿ (a \ b)) + # (b ° (a \ b)) = # b + # (a \ b)Æ ante_tac THEN1
	(bc_thm_tac size_¿_thm THEN REPEAT strip_tac));
a(LEMMA_T ¨b ¿ (a \ b) = a ± b ° (a \ b) = {}Æ rewrite_thm_tac THEN1
	PC_T1 "sets_ext1" asm_prove_tac[]);
a(rewrite_tac[size_empty_thm]);
a(STRIP_T rewrite_thm_tac);
a(lemma_tac ¨≥ #(a \ b) = 0Æ THEN_LIST
	[id_tac, PC_T1 "lin_arith" asm_prove_tac[]]);
a(ALL_FC_T1 fc_§_canon asm_rewrite_tac[size_0_thm]);
pop_thm()
));



val finite_Ä_well_founded_thm = save_thm ( "finite_Ä_well_founded_thm", (
set_goal([],¨µp a∑
	a ç Finite
±	p a
¥	∂b∑
	b Ä a
±	p b
±	µc∑c Ä b ± p c ¥ c = bÆ);
a(REPEAT strip_tac);
a(PC_T1 "predicates" lemma_tac ¨#a ç {n | ∂t∑ t Ä a ± p t ± n = #t}Æ);
(* *** Goal "1" *** *)
a(REPEAT strip_tac);
a(∂_tac¨aÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(all_fc_tac[min_ç_thm]);
a(∂_tac¨tÆ THEN REPEAT strip_tac);
a(contr_tac THEN all_fc_tac[Ä_finite_thm]);
a(all_fc_tac[Ä_size_thm1]);
a(DROP_NTH_ASM_T 9 discard_tac);
a(PC_T1 "predicates" lemma_tac ¨#c ç {n | ∂t∑ t Ä a ± p t ± n = #t}Æ);
(* *** Goal "2.1" *** *)
a(REPEAT strip_tac);
a(∂_tac¨cÆ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2.2" *** *)
a(all_fc_tac[min_º_thm]);
a(PC_T1 "lin_arith" asm_prove_tac[]);
pop_thm()
));

val topology_def = get_spec¨$TopologyÆ;
val space_t_def = get_spec¨SpaceâTÆ;
val closed_def = get_spec¨$ClosedÆ;
val continuous_def = get_spec¨$ContinuousÆ;
val connected_def = get_spec¨$ConnectedÆ;
val compact_def = get_spec¨$CompactÆ;
val subspace_topology_def = get_spec¨$ÚâTÆ;
val product_topology_def = get_spec¨$∏âTÆ;
val unit_topology_def = get_spec¨1âTÆ;
val power_topology_def = get_spec¨êâTÆ;
val hausdorff_def = get_spec¨HausdorffÆ;
val homeomorphism_def = get_spec¨$HomeomorphismÆ;
local
	val thm1 = all_µ_elim (get_spec¨$InteriorÆ);
	val [i_def, b_def, c_def] = strip_±_rule thm1;
in
	val interior_def = all_µ_intro i_def;
	val boundary_def = all_µ_intro b_def;
	val closure_def = all_µ_intro c_def;
end;
val covering_projection_def = get_spec¨$CoveringProjectionÆ;
val space_k_def = get_spec¨SpaceâKÆ;
val skeleton_def = get_spec¨$SkeletonÆ;
val protocomplex_def = get_spec¨ProtocomplexÆ;

val empty_open_thm = save_thm ( "empty_open_thm", (
set_goal([], ¨µ‘ : 'a SET SET ∑ ‘ ç Topology ¥ {} ç ‘Æ);
a(rewrite_tac[topology_def] THEN REPEAT strip_tac);
a(SPEC_NTH_ASM_T 2 ¨{}: 'a SET SETÆ ante_tac);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨ﬁ{} = {}Æ]);
pop_thm()
));


val space_t_open_thm = save_thm ( "space_t_open_thm", (
set_goal([], ¨µ‘ : 'a SET SET ∑ ‘ ç Topology ¥ SpaceâT ‘ ç ‘Æ);
a(rewrite_tac[topology_def, space_t_def] THEN REPEAT strip_tac);
a(SPEC_NTH_ASM_T 2 ¨‘: 'a SET SETÆ ante_tac);
a(rewrite_tac[]);
pop_thm()
));


val empty_closed_thm = save_thm ( "empty_closed_thm", (
set_goal([], ¨µ‘ : 'a SET SET ∑ ‘ ç Topology ¥ {} ç ‘ ClosedÆ);
a(rewrite_tac[closed_def] THEN REPEAT strip_tac);
a(all_fc_tac[space_t_open_thm]);
a(∂_tac¨SpaceâT ‘Æ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val space_t_closed_thm = save_thm ( "space_t_closed_thm", (
set_goal([], ¨µ‘ : 'a SET SET ∑ ‘ ç Topology ¥ SpaceâT ‘ ç ‘ ClosedÆ);
a(rewrite_tac[closed_def] THEN REPEAT strip_tac);
a(all_fc_tac[empty_open_thm]);
a(∂_tac¨{} : 'a SETÆ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val open_open_neighbourhood_thm = save_thm ( "open_open_neighbourhood_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology ¥
	(A ç ‘ § µx∑x ç A ¥ ∂B∑ B ç ‘ ± x ç B ± B Ä A)Æ);
a(rewrite_tac[topology_def, space_t_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(∂_tac¨AÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨A = ﬁ{B | B ç ‘ ± B Ä A}Æ);
(* *** Goal "2.1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN
	contr_tac THEN all_asm_fc_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2.2" *** *)
a(POP_ASM_T once_rewrite_thm_tac THEN DROP_NTH_ASM_T 3 bc_thm_tac);
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val closed_open_neighbourhood_thm = save_thm ( "closed_open_neighbourhood_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology ¥
	(	A ç ‘ Closed
	§ 	A Ä SpaceâT ‘
	±	µx∑x ç SpaceâT ‘  ± ≥x ç A ¥ ∂B∑ B ç ‘ ± x ç B ± B ° A = {})Æ);
a(rewrite_tac[closed_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨x ç BÆ THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(all_fc_tac[open_open_neighbourhood_thm]);
a(∂_tac¨B'Æ THEN PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(FC_T1 fc_§_canon once_rewrite_tac [open_open_neighbourhood_thm]);
a(∂_tac¨SpaceâT ‘ \ AÆ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "3.1" *** *)
a(all_asm_fc_tac[]);
a(∂_tac¨BÆ THEN PC_T1 "sets_ext1" asm_rewrite_tac[]);
a(rewrite_tac[space_t_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "3.1.1" *** *)
a(contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "3.1.2" *** *)
a(REPEAT_N 2 (POP_ASM_T ante_tac) THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "3.2" *** *)
a(LIST_GET_NTH_ASM_T [1, 3] (MAP_EVERY ante_tac)  THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val ç_space_t_thm = save_thm ( "ç_space_t_thm", (
set_goal([], ¨µ‘ x A ∑
	x ç A ± A ç ‘ ¥ x ç SpaceâT ‘
Æ);
a(rewrite_tac[space_t_def] THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));



val ç_closed_ç_space_t_thm = save_thm ( "ç_closed_ç_space_t_thm", (
set_goal([], ¨µ‘ x A ∑
	x ç A ± A ç ‘ Closed ¥ x ç SpaceâT ‘
Æ);
a(rewrite_tac[space_t_def, closed_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(all_asm_fc_tac[] THEN contr_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val closed_open_complement_thm = save_thm ( "closed_open_complement_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology ¥
	(	A ç ‘ Closed
	§ 	A Ä SpaceâT ‘
	±	SpaceâT ‘ \ A ç ‘)Æ);
a(rewrite_tac[closed_def] THEN REPEAT strip_tac THEN_TRY all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨B Ä SpaceâT ‘Æ THEN1
	(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_fc_tac[ç_space_t_thm]));
a(LEMMA_T ¨SpaceâT ‘ \ (SpaceâT ‘ \ B) = BÆ asm_rewrite_thm_tac
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨SpaceâT ‘ \ AÆ THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val ¿_open_thm = save_thm ( "¿_open_thm", (
set_goal([], ¨µ‘ A B ∑
	‘ ç Topology ± A ç ‘ ± B ç ‘ ¥ A ¿ B ç ‘
Æ);
a(rewrite_tac[topology_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(SPEC_NTH_ASM_T 4 ¨{A; B}Æ (strip_asm_tac o rewrite_rule[enum_set_clauses]));
pop_thm()
));


val ﬁ_open_thm = save_thm ( "ﬁ_open_thm", (
set_goal([], ¨µ ‘ V∑
	‘ ç Topology
±	V Ä ‘
¥	ﬁV ç ‘Æ);
a(rewrite_tac[topology_def] THEN REPEAT strip_tac
	THEN all_asm_fc_tac[]);
pop_thm()
));


val °_open_thm = save_thm ( "°_open_thm", (
set_goal([], ¨µ‘ A B ∑
	‘ ç Topology ± A ç ‘ ± B ç ‘ ¥ A ° B ç ‘
Æ);
a(rewrite_tac[topology_def] THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val •_open_thm = save_thm ( "•_open_thm", (
set_goal([], ¨µ ‘ V∑
	‘ ç Topology
±	≥V = {}
±	V ç Finite
±	V Ä ‘
¥	•V ç ‘Æ);
a(REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [1, 3, 4] (MAP_EVERY ante_tac));
a(intro_µ_tac1 ¨‘Æ THEN1 finite_induction_tac¨VÆ
	THEN REPEAT strip_tac);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[
	pc_rule1"sets_ext1" prove_rule[]
		¨(µx a∑ {x} Ä a § x ç a)
	±	µa b c∑a ¿ b Ä c § a Ä c ± b Ä cÆ]));
a(cases_tac¨V = {}Æ THEN1 all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(LEMMA_T¨µx∑ •({x} ¿ {}) = xÆ asm_rewrite_thm_tac);
a(DROP_ASMS_T discard_tac);
a(rewrite_tac[] THEN PC_T1 "sets_ext1" rewrite_tac[]
	THEN prove_tac[]);
a(POP_ASM_T bc_thm_tac THEN rewrite_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(lemma_tac¨x ° •V ç ‘Æ THEN1 all_fc_tac[°_open_thm]);
a(LEMMA_T¨µx b∑ •({x} ¿ b) = x ° •bÆ asm_rewrite_thm_tac);
a(DROP_ASMS_T discard_tac);
a(PC_T1 "sets_ext1" rewrite_tac[]
	THEN prove_tac[]);
a(POP_ASM_T bc_thm_tac THEN rewrite_tac[]);
pop_thm()
));



val °_closed_thm = save_thm ( "°_closed_thm", (
set_goal([], ¨µ‘ A B ∑
	‘ ç Topology ± A ç ‘ Closed ± B ç ‘ Closed ¥ A ° B ç ‘ Closed
Æ);
a(REPEAT strip_tac THEN REPEAT_N 2 (POP_ASM_T ante_tac));
a(ALL_FC_T1 fc_§_canon rewrite_tac[closed_open_complement_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b s∑a Ä s ± b Ä s ¥ a ° b Ä sÆ]);
(* *** Goal "2" *** *)
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µs a b∑ s \ a ° b = (s \ a) ¿ (s \ b)Æ]);
a(all_fc_tac [¿_open_thm]);
pop_thm()
));


val •_closed_thm = save_thm ( "•_closed_thm", (
set_goal([], ¨µ ‘ V∑
	‘ ç Topology
±	≥V = {}
±	V Ä ‘ Closed
¥	•V ç ‘ Closed
Æ);
a(REPEAT strip_tac THEN POP_ASM_T (ante_tac o pc_rule1"sets_ext1"rewrite_rule[]));
a(PC_T1 "sets_ext1" POP_ASM_T strip_asm_tac);
a(ALL_FC_T1 fc_§_canon rewrite_tac[closed_open_complement_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(LEMMA_T¨µt v∑ t \ •v  = ﬁ{a|∂b∑b ç v ± a = t \ b}Æ rewrite_thm_tac);
(* *** Goal "2.1" *** *)
a(DROP_ASMS_T discard_tac);
a(PC_T "sets_ext1" contr_tac THEN_TRY all_asm_fc_tac[]);
a(spec_nth_asm_tac 1 ¨t \ sÆ);
a(spec_nth_asm_tac 1 ¨sÆ);
(* *** Goal "2.2" *** *)
a(bc_thm_tac ﬁ_open_thm THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(all_asm_fc_tac[]);
pop_thm()
));


val ¿_closed_thm = save_thm ( "¿_closed_thm", (
set_goal([], ¨µ‘ A B ∑
	‘ ç Topology ± A ç ‘ Closed ± B ç ‘ Closed ¥ A ¿ B ç ‘ Closed
Æ);
a(REPEAT strip_tac THEN REPEAT_N 2 (POP_ASM_T ante_tac));
a(ALL_FC_T1 fc_§_canon rewrite_tac[closed_open_complement_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b s∑a Ä s ± b Ä s ¥ a ¿ b Ä sÆ]);
(* *** Goal "2" *** *)
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µs a b∑ s \ (a ¿ b) = (s \ a) ° (s \ b)Æ]);
a(all_fc_tac [°_open_thm]);
pop_thm()
));

val ﬁ_closed_thm = save_thm ( "ﬁ_closed_thm", (
set_goal([], ¨µ ‘ V∑
	‘ ç Topology
±	≥V = {}
±	V ç Finite
±	V Ä ‘ Closed
¥	ﬁV ç ‘ ClosedÆ);
a(REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [1, 3, 4] (MAP_EVERY ante_tac));
a(intro_µ_tac1 ¨‘Æ THEN1 finite_induction_tac¨VÆ
	THEN REPEAT strip_tac);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[
	pc_rule1"sets_ext1" prove_rule[]
		¨(µx a∑ {x} Ä a § x ç a)
	±	µa b c∑a ¿ b Ä c § a Ä c ± b Ä cÆ]));
a(cases_tac¨V = {}Æ THEN1 all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(LEMMA_T¨µx∑ ﬁ({x} ¿ {}) = xÆ asm_rewrite_thm_tac);
a(DROP_ASMS_T discard_tac);
a(rewrite_tac[] THEN PC_T1 "sets_ext1" rewrite_tac[]
	THEN prove_tac[]);
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(lemma_tac¨x ¿ ﬁV ç ‘ ClosedÆ THEN1 all_fc_tac[¿_closed_thm]);
a(LEMMA_T¨µx b∑ ﬁ({x} ¿ b) = x ¿ ﬁbÆ asm_rewrite_thm_tac);
a(DROP_ASMS_T discard_tac);
a(PC_T1 "sets_ext1" rewrite_tac[]
	THEN prove_tac[]);
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
pop_thm()
));





val finite_•_open_thm = save_thm ( "finite_•_open_thm", (
set_goal([], ¨µ‘ V∑
	‘ ç Topology ± V Ä ‘ ± ≥V = {} ± V ç Finite
¥	•V ç ‘Æ);
a(rewrite_tac[topology_def] THEN REPEAT strip_tac);
a(POP_ASM_T (fn th => POP_ASM_T ante_tac THEN POP_ASM_T ante_tac THEN asm_tac th));
a(finite_induction_tac¨VÆ);
(* *** Goal "1" *** *)
a(REPEAT strip_tac);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(all_var_elim_asm_tac1 THEN rewrite_tac[]);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µx y∑{x} Ä y § x ç yÆ]);
a(LEMMA_T¨•{x} = xÆ (fn th => rewrite_tac [th] THEN taut_tac));
(* *** Goal "3" *** *)
a(PC_T"sets_ext1" strip_tac THEN rewrite_tac[•_def] THEN prove_tac[]);
(* *** Goal "4" *** *)
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µx y z∑{x} ¿ z Ä y § x ç y ± z Ä yÆ]);
a(LEMMA_T¨•({x} ¿ V) = x ° •VÆ rewrite_thm_tac);
(* *** Goal "4.1" *** *)
a(PC_T"sets_ext1" strip_tac THEN rewrite_tac[•_def, °_def, ¿_def] THEN prove_tac[]);
(* *** Goal "4.2" *** *)
a(REPEAT strip_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val subspace_topology_thm = save_thm ( "subspace_topology_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
¥	(X ÚâT ‘) ç TopologyÆ);
a(rewrite_tac[topology_def, subspace_topology_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_asm_ante_tac THEN1 PC_T1 "sets_ext1" REPEAT strip_tac);
a(∂_tac ¨ﬁ{C| C ç ‘ ± C ° X ç V}Æ  THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "1.1" *** *)
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.2" *** *)
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.2.1" *** *)
a(all_asm_fc_tac[] THEN all_var_elim_asm_tac1);
a(∂_tac ¨BÆ  THEN REPEAT strip_tac);
(* *** Goal "1.2.2" *** *)
a(all_asm_fc_tac[] THEN all_var_elim_asm_tac1);
(* *** Goal "1.2.3" *** *)
a(∂_tac ¨s ° XÆ  THEN PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(all_var_elim_asm_tac1);
a(∂_tac ¨B' ° B''Æ   THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val subspace_topology_space_t_thm = save_thm ( "subspace_topology_space_t_thm", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
¥	SpaceâT (A ÚâT ‘) = A ° SpaceâT ‘Æ);
a(rewrite_tac[topology_def, space_t_def, subspace_topology_def] THEN
	PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(∂_tac ¨BÆ  THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "3" *** *)
a(∂_tac ¨s ° AÆ  THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
a(∂_tac ¨s Æ  THEN REPEAT strip_tac);
pop_thm()
));



val subspace_topology_space_t_thm1 = save_thm ( "subspace_topology_space_t_thm1", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
±	A Ä SpaceâT ‘
¥	SpaceâT (A ÚâT ‘) = AÆ);
a(REPEAT strip_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a Ä b = a ° b = aÆ]);
pop_thm()
));



val universe_subspace_topology_thm = save_thm ( "universe_subspace_topology_thm", (
set_goal([], ¨µ‘∑ (Universe ÚâT ‘) = ‘Æ);
a(REPEAT strip_tac THEN rewrite_tac[subspace_topology_def]);
a(rewrite_tac[pc_rule1 "sets_ext1" prove_rule[]
	¨µt∑ {a | ∂b∑ b ç t ± a = b} = tÆ]);
pop_thm()
));


val open_Ä_space_t_thm = save_thm ( "open_Ä_space_t_thm", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
±	A ç ‘
¥	A Ä SpaceâT ‘Æ);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_fc_tac[ç_space_t_thm]);
pop_thm()
));


val subspace_topology_space_t_thm2 = save_thm ( "subspace_topology_space_t_thm2", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
±	A ç ‘
¥	SpaceâT (A ÚâT ‘) = AÆ);
a(REPEAT strip_tac THEN bc_tac[
	subspace_topology_space_t_thm1,
	open_Ä_space_t_thm] THEN REPEAT strip_tac);
pop_thm()
));



val subspace_topology_space_t_thm3 = save_thm ( "subspace_topology_space_t_thm3", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
±	A ç ‘ Closed
¥	SpaceâT (A ÚâT ‘) = AÆ);
a(REPEAT strip_tac THEN bc_thm_tac subspace_topology_space_t_thm1);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_fc_tac[ç_closed_ç_space_t_thm]);
pop_thm()
));


val subspace_topology_closed_thm = save_thm ( "subspace_topology_closed_thm", (
set_goal([], ¨µX ‘∑
	‘ ç Topology
¥	(X ÚâT ‘) Closed = {A | ∂B∑ B ç ‘ Closed ± A = B ° X}
Æ);
a(REPEAT strip_tac THEN PC_T "sets_ext1" strip_tac);
a(lemma_tac¨X ÚâT ‘ ç TopologyÆ THEN1 ALL_FC_T rewrite_tac [subspace_topology_thm]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[closed_open_complement_thm,
	subspace_topology_space_t_thm]
	THEN rewrite_tac[subspace_topology_def]
	THEN REPEAT strip_tac
	THEN_TRY all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(∂_tac¨ SpaceâT ‘ \ B Æ);
a(lemma_tac¨B Ä SpaceâT ‘Æ THEN1
	(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_fc_tac[ç_space_t_thm]));
a(ALL_FC_T asm_rewrite_tac[pc_rule1"sets_ext1"prove_rule[]
	¨µb s∑b Ä s ¥ s \ b Ä s ± s \ (s \ b) = bÆ]);
a(asm_rewrite_tac[pc_rule1"sets_ext1"prove_rule[]
	¨µb s x∑ (s \ b) ° x = (x ° s) \ (b ° x)Æ]);
a(lemma_tac¨B ° X Ä X ° SpaceâT ‘Æ THEN1
	(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" prove_tac[]));
a(all_fc_tac[pc_rule1"sets_ext1"prove_rule[]
	¨µa b c∑ a Ä c ± b Ä c ± c \ a = b ¥ a = c \ bÆ]);
(* *** Goal "2" *** *)
a(ALL_FC_T rewrite_tac[pc_rule1"sets_ext1"prove_rule[]
	¨µb s x∑ b Ä s ¥ b ° x Ä x ° sÆ]);
(* *** Goal "3" *** *)
a(∂_tac¨ SpaceâT ‘ \ B Æ THEN REPEAT strip_tac);
a(rewrite_tac[pc_rule1"sets_ext1"prove_rule[]
	¨µb s x∑ (s \ b) ° x = (x ° s) \ (b ° x)Æ]);
pop_thm()
));


val trivial_subspace_topology_thm = save_thm ( "trivial_subspace_topology_thm", (
set_goal([], ¨µ‘∑
	‘ ç Topology
¥	(SpaceâT ‘ ÚâT ‘)  = ‘Æ);
a(rewrite_tac[subspace_topology_def] THEN  REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1 THEN all_fc_tac[space_t_open_thm]);
a(all_fc_tac[°_open_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨xÆ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
a(all_fc_tac[ç_space_t_thm]);
pop_thm()
));


val Ä_subspace_topology_thm = save_thm ( "Ä_subspace_topology_thm", (
set_goal([], ¨µ‘ A B∑
	A Ä B
¥	(A ÚâT (B ÚâT ‘))  = (A ÚâT ‘)Æ);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(∂_tac¨B''Æ THEN asm_rewrite_tac[]);
a(POP_ASM_T discard_tac THEN PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨B' ° BÆ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(∂_tac¨B'Æ THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(POP_ASM_T discard_tac THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val product_topology_thm = save_thm ( "product_topology_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	(” ∏âT ‘) ç TopologyÆ);
a(rewrite_tac[topology_def, product_topology_def]
	THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T  [3] all_fc_tac);
a(∂_tac¨AÆ  THEN ∂_tac ¨BÆ THEN REPEAT strip_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx y z∑x Ä y ± y ç z ¥ x Ä ﬁ zÆ]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T  [3, 4] all_fc_tac);
a(∂_tac¨A' ° A''Æ  THEN ∂_tac ¨B' ° B''Æ THEN REPEAT strip_tac
	THEN_TRY SOLVED_T (all_asm_fc_tac[]));
a(MERGE_PCS_T1["'bin_rel", "sets_ext1"] asm_prove_tac[]);
pop_thm()
));


val product_topology_space_t_thm = save_thm ( "product_topology_space_t_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	SpaceâT  (” ∏âT ‘)  = (SpaceâT ” ∏ SpaceâT ‘)Æ);
a(rewrite_tac[product_topology_def, space_t_def]);
a(MERGE_PCS_T1["'bin_rel", "sets_ext1"] REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[] THEN contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[] THEN contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨s ∏ s'Æ THEN MERGE_PCS_T1["'bin_rel", "sets_ext1"] REPEAT strip_tac);
a(∂_tac¨sÆ THEN ∂_tac¨s'Æ THEN MERGE_PCS_T1["'bin_rel", "sets_ext1"] REPEAT strip_tac);
pop_thm()
));


val unit_topology_thm = save_thm ( "unit_topology_thm", (
set_goal([], ¨ 1âT ç Topology Æ);
a(rewrite_tac[topology_def, unit_topology_def]
	THEN MERGE_PCS_T1 ["'one", "sets_ext1"] rewrite_tac[]
	THEN REPEAT strip_tac
	THEN all_asm_fc_tac[]);
a(asm_prove_tac[]);
pop_thm()
));

val space_t_unit_topology_thm = save_thm ( "space_t_unit_topology_thm", (
set_goal([], ¨ SpaceâT 1âT = Universe Æ);
a(rewrite_tac[space_t_def, unit_topology_def]
	THEN MERGE_PCS_T1 ["'one", "sets_ext1"] rewrite_tac[]
	THEN REPEAT strip_tac
	THEN all_asm_fc_tac[]);
a(∂_tac ¨UniverseÆ THEN asm_prove_tac[]);
pop_thm()
));


val power_topology_length_thm = save_thm ( "power_topology_length_thm", (
set_goal([], ¨µ‘ n v∑ v ç SpaceâT (êâT n ‘) ¥ Length v = nÆ);
a(REPEAT_N 2 strip_tac THEN induction_tac¨n:ÓÆ
	THEN rewrite_tac[power_topology_def, space_t_def]
	THEN REPEAT strip_tac THEN_TRY all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[length_def]);
(* *** Goal "2" *** *)
a(strip_asm_tac(µ_elim¨vÆ list_cases_thm) THEN all_var_elim_asm_tac1
	THEN all_asm_fc_tac[]);
a(all_fc_tac[ç_space_t_thm]);
a(all_asm_fc_tac[] THEN asm_rewrite_tac[length_def]);
pop_thm()
));


val power_topology_thm = save_thm ( "power_topology_thm", (
set_goal([], ¨µ‘ n∑ ‘ ç Topology ¥ êâT n ‘ ç TopologyÆ);
a(REPEAT strip_tac THEN induction_tac¨n:ÓÆ
	THEN rewrite_tac[power_topology_def]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" prove_tac[topology_def]);
(* *** Goal "2" *** *)
a(PC_T1 "sets_ext1" rewrite_tac[topology_def] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2.2" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(∂_tac¨AÆ THEN ∂_tac¨BÆ THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "2.3" *** *)
a(LIST_DROP_NTH_ASM_T  [3, 5] all_fc_tac);
a(∂_tac¨A' ° A''Æ  THEN ∂_tac ¨B' ° B''Æ THEN REPEAT strip_tac
	THEN all_asm_fc_tac[°_open_thm]);
pop_thm()
));



val continuous_ç_space_t_thm = save_thm ( "continuous_ç_space_t_thm", (
set_goal([], ¨µ ”; ‘; f : 'a ≠ 'b; x∑
	f ç (”, ‘) Continuous ± x ç SpaceâT ” ¥ f x ç SpaceâT ‘
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val continuous_open_thm = save_thm ( "continuous_open_thm", (
set_goal([], ¨µ ”; ‘; f : 'a ≠ 'b; A∑
	f ç (”, ‘) Continuous ± A ç ‘ ¥ {x|x ç SpaceâT ” ± f x ç A} ç ”
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val continuous_closed_thm = save_thm ( "continuous_closed_thm", (
set_goal([], ¨µ ” : 'a SET SET; ‘ : 'b SET SET∑
	(”, ‘) Continuous =
	{f
	|	(µx∑ x ç SpaceâT ” ¥ f x ç SpaceâT ‘)
	±	(µA∑ A ç ‘ Closed ¥ {x | x ç SpaceâT ” ± f x ç A} ç ” Closed)}
Æ);
a(REPEAT µ_tac THEN  rewrite_tac[continuous_def]);
a(PC_T1 "sets_ext1" once_rewrite_tac[] THEN strip_tac);
a(rename_tac[(¨xÆ, "f")] THEN rewrite_tac[
		taut_rule ¨µp q r∑ (r ± p § r ± q) § (r ¥ (p § q)) Æ,
		closed_def]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç B} Æ THEN asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 2 (ante_tac o µ_elim¨SpaceâT ‘ \ AÆ));
a(LEMMA_T ¨∂ B∑ B ç ‘ ± SpaceâT ‘ \ A = SpaceâT ‘ \ BÆ rewrite_thm_tac
	THEN1 asm_prove_tac[]);
a(REPEAT strip_tac);
a(LEMMA_T ¨{x|x ç SpaceâT ” ± f x ç A} = BÆ asm_rewrite_thm_tac);
a(lemma_tac¨B Ä SpaceâT ”Æ THEN1
	(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_fc_tac[ç_space_t_thm]));
a(lemma_tac¨{x|x ç SpaceâT ” ± f x ç A} Ä SpaceâT ”Æ THEN1
	(PC_T1 "sets_ext1" prove_tac[]));
a(ALL_FC_T1 fc_§_canon rewrite_tac[pc_rule1"sets_ext1" prove_rule[]
	¨ µa b c∑ a Ä c ± b Ä c ¥ (a = b § c \ a = c \ b)Æ]);
a(DROP_NTH_ASM_T 3 (rewrite_thm_tac o eq_sym_rule));
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val subspace_continuous_thm = save_thm ( "subspace_continuous_thm", (
set_goal([], ¨µ” ‘ A B f∑
	” ç Topology
±	‘ ç Topology
±	f ç (”, ‘) Continuous
±	(µx∑ x ç A ¥ f x ç B)
¥	f ç (A ÚâT ”, B ÚâT ‘) Continuous
Æ);
a(REPEAT strip_tac THEN rewrite_tac[continuous_def]);
a(ALL_FC_T asm_rewrite_tac[subspace_topology_space_t_thm]);
a(DROP_NTH_ASM_T 2 (strip_asm_tac o rewrite_rule[continuous_def]));
a(rewrite_tac[subspace_topology_def]THEN REPEAT strip_tac
	THEN (all_var_elim_asm_tac1
		ORELSE all_asm_fc_tac[]));
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç B'}Æ THEN asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val subspace_domain_continuous_thm = save_thm ( "subspace_domain_continuous_thm", (
set_goal([], ¨µ” ‘ A B f∑
	” ç Topology
±	‘ ç Topology
±	f ç (”, ‘) Continuous
¥	f ç (A ÚâT ”, ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(LEMMA_T ¨‘ = Universe ÚâT ‘Æ once_rewrite_thm_tac
	THEN1 rewrite_tac[universe_subspace_topology_thm]);
a(bc_thm_tac subspace_continuous_thm THEN asm_rewrite_tac[]);
pop_thm()
));


val empty_continuous_thm = save_thm ( "empty_continuous_thm", (
set_goal([], ¨µ” ‘ f∑
	” ç Topology
±	‘ ç Topology
¥	f ç ({} ÚâT ”, ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(asm_rewrite_tac[continuous_def]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨{x|F} = {}Æ]);
a(REPEAT strip_tac THEN rewrite_tac[subspace_topology_def]);
a(∂_tac¨{}Æ THEN ALL_FC_T rewrite_tac[empty_open_thm]);
pop_thm()
));


val subspace_range_continuous_thm = save_thm ( "subspace_range_continuous_thm", (
set_goal([], ¨µ” ‘ f B∑
	” ç Topology
±	‘ ç Topology
±	f ç (”, B ÚâT ‘) Continuous
¥	f ç (”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[] THEN POP_ASM_T ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(LEMMA_T ¨µx∑ x ç SpaceâT ” ± f x ç A §
	x ç SpaceâT ” ± f x ç A ° BÆ
	rewrite_thm_tac);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 3 ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2" *** *)
a(DROP_NTH_ASM_T 2 bc_thm_tac);
a(rewrite_tac[subspace_topology_def]
	THEN asm_prove_tac[]);
pop_thm()
));


val subspace_range_continuous_§_thm = save_thm ( "subspace_range_continuous_§_thm", (
set_goal([], ¨µ”; ‘; f : 'a ≠ 'b; B∑
	” ç Topology
±	‘ ç Topology
±	B Ä SpaceâT ‘
¥	(f ç (”, B ÚâT ‘) Continuous §
	 f ç (”, ‘) Continuous ± µx∑ x ç SpaceâT ” ¥ f x ç B)
Æ);
a(REPEAT strip_tac THEN1 all_fc_tac[subspace_range_continuous_thm]);
(* *** Goal "1" *** *)
a(all_fc_tac[continuous_ç_space_t_thm]);
a(POP_ASM_T ante_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(REPEAT strip_tac);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 2 ante_tac THEN asm_rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(all_asm_fc_tac[] THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[subspace_topology_def] THEN strip_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LEMMA_T ¨µx∑ x ç SpaceâT ” ± f x ç A § x ç SpaceâT ” ± f x ç B'Æ
	asm_rewrite_thm_tac);
a(all_var_elim_asm_tac1 THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [6] all_fc_tac);
pop_thm()
));


val subspace_range_continuous_bc_thm = save_thm ( "subspace_range_continuous_bc_thm", (
set_goal([], ¨µ”; ‘; f : 'a ≠ 'b; B∑
	” ç Topology
±	‘ ç Topology
±	B Ä SpaceâT ‘
±	(µx∑ x ç SpaceâT ” ¥ f x ç B)
±	f ç (”, ‘) Continuous
¥	f ç (”, B ÚâT ‘) Continuous
Æ);
a(REPEAT strip_tac THEN POP_ASM_T ante_tac);
a(ALL_FC_T1 fc_§_canon asm_rewrite_tac[subspace_range_continuous_§_thm]);
pop_thm()
));



val const_continuous_thm = save_thm ( "const_continuous_thm", (
set_goal([], ¨µ” ‘ c∑
	” ç Topology
±	‘ ç Topology
±	c ç SpaceâT ‘
¥	(Ãx∑ c) ç (”, ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(rewrite_tac[continuous_def, topology_def] THEN
	PC_T1 "sets_ext1" REPEAT strip_tac);
a(cases_tac¨c ç AÆ THEN asm_rewrite_tac[]);
(* *** Goal "1" *** *)
a(rewrite_tac[pc_rule1"sets_ext" prove_rule[]¨{x | x ç SpaceâT ”} = SpaceâT ”Æ]);
a(all_asm_fc_tac[space_t_open_thm]);
(* *** Goal "2" *** *)
a(rewrite_tac[pc_rule1"sets_ext" prove_rule[]¨{x | F} = {}Æ]);
a(all_asm_fc_tac[empty_open_thm]);
pop_thm()
));


val id_continuous_thm = save_thm ( "id_continuous_thm", (
set_goal([], ¨µ‘∑
	‘ ç Topology
¥	(Ãx∑ x) ç (‘, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def, topology_def, space_t_def] THEN
	PC_T1 "sets_ext1" REPEAT strip_tac);
a(LEMMA_T ¨ {x|x ç ﬁ ‘ ± x ç A} = AÆ  asm_rewrite_thm_tac);
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1"  prove_tac[]);
pop_thm()
));


val comp_continuous_thm = save_thm ( "comp_continuous_thm", (
set_goal([], ¨µf g “ ” ‘∑
	f ç (“, ”) Continuous
±	g ç (”, ‘) Continuous
±	“ ç Topology
±	” ç Topology
±	‘ ç Topology
¥	(Ãx∑ g(f x)) ç (“, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac THEN
	(all_asm_fc_tac[] THEN all_asm_fc_tac[]));
a( LEMMA_T ¨{x|x ç SpaceâT “ ± g (f x) ç A} ={x|x ç SpaceâT “ ± f x ç {x|x ç SpaceâT ” ± g x ç A}}Æ
	once_rewrite_thm_tac THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" prove_tac[] THEN all_asm_fc_tac[]);
pop_thm()
));


val left_proj_continuous_thm = save_thm ( "left_proj_continuous_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	(Ã(x, y)∑ x) ç ((” ∏âT ‘), ”) Continuous
Æ);
a(REPEAT strip_tac THEN rewrite_tac[continuous_def]);
a(all_fc_tac[product_topology_thm]);
a(ALL_FC_T rewrite_tac [product_topology_space_t_thm]);
a(rewrite_tac[product_topology_def, ∏_def] THEN REPEAT strip_tac);
a(∂_tac¨AÆ THEN ∂_tac¨SpaceâT ‘Æ THEN
	ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN_TRY asm_rewrite_tac[]);
a(all_fc_tac[ç_space_t_thm]);
pop_thm()
));


val fst_continuous_thm = save_thm ( "fst_continuous_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	Fst ç ((” ∏âT ‘), ”) Continuous
Æ);
a(REPEAT strip_tac);
a(LEMMA_T¨Fst = Ã(x:'a, y:'b)∑xÆ rewrite_thm_tac THEN1 prove_tac[]);
a(all_fc_tac[left_proj_continuous_thm]);
pop_thm()
));


val right_proj_continuous_thm = save_thm ( "right_proj_continuous_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	(Ã(x, y)∑ y) ç ((” ∏âT ‘), ‘) Continuous
Æ);
a(REPEAT strip_tac THEN rewrite_tac[continuous_def]);
a(all_fc_tac[product_topology_thm]);
a(ALL_FC_T rewrite_tac [product_topology_space_t_thm]);
a(rewrite_tac[product_topology_def, ∏_def] THEN REPEAT strip_tac);
a(∂_tac¨SpaceâT ”Æ THEN ∂_tac¨AÆ THEN
	ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN_TRY asm_rewrite_tac[]);
a(all_fc_tac[ç_space_t_thm]);
pop_thm()
));


val snd_continuous_thm = save_thm ( "snd_continuous_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET∑
	” ç Topology
±	‘ ç Topology
¥	Snd ç ((” ∏âT ‘), ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(LEMMA_T¨Snd = Ã(x:'a, y:'b)∑yÆ rewrite_thm_tac THEN1 prove_tac[]);
a(all_fc_tac[right_proj_continuous_thm]);
pop_thm()
));


val product_continuous_thm = save_thm ( "product_continuous_thm", (
set_goal([], ¨µ f : 'a ≠ 'b; g : 'a ≠ 'c; “ : 'a SET SET; ” : 'b SET SET; ‘ : 'c SET SET∑
	f ç (“, ”) Continuous
±	g ç (“, ‘) Continuous
±	“ ç Topology
±	” ç Topology
±	‘ ç Topology
¥	(Ãz∑(f z, g z)) ç (“, (” ∏âT ‘)) Continuous
Æ);
a(REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [4, 5] (MAP_EVERY ante_tac));
a(rewrite_tac[continuous_def]);
a(all_fc_tac[product_topology_thm]);
a(ALL_FC_T rewrite_tac [product_topology_space_t_thm]);
a(rewrite_tac[product_topology_def, ∏_def] THEN REPEAT strip_tac
	THEN_TRY (SOLVED_T (all_asm_fc_tac[])));
a(LIST_DROP_NTH_ASM_T (interval 6 16) discard_tac
	THEN ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(REPEAT strip_tac THEN all_asm_fc_tac[]);
a(LIST_DROP_NTH_ASM_T [11, 13] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT “ ± g x ç B} ° {x|x ç SpaceâT “ ± f x ç A'}Æ);
a(ALL_FC_T rewrite_tac[°_open_thm]);
a(REPEAT strip_tac THEN PC_T1"sets_ext1" REPEAT strip_tac);
a(bc_thm_tac (pc_rule1"sets_ext" prove_rule[]¨µa xy∑xy ç a ± a Ä A ¥ xy ç AÆ));
a(∂_tac¨{(v, w)|v ç A' ± w ç B}Æ THEN REPEAT strip_tac);
pop_thm()
));


set_goal([], ¨µ f : 'a ≠ 'b; g : 'a ≠ 'c; “ : 'a SET SET; ” : 'b SET SET; ‘ : 'c SET SET∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
¥	((Ãz∑(f z, g z)) ç (“, (” ∏âT ‘)) Continuous
	§	f ç (“, ”) Continuous
	±	g ç (“, ‘) Continuous)

Æ);
a(REPEAT µ_tac THEN ¥_tac);
a(lemma_tac¨(” ∏âT ‘) ç TopologyÆ THEN1 all_fc_tac[product_topology_thm]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LEMMA_T¨(Ãz∑ (Ã(x, y)∑ x) ((Ãz∑(f z, g z)) z))  ç (“, ”) ContinuousÆ
	(fn th => ante_tac th THEN rewrite_tac[»_axiom]));
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨” ∏âT ‘Æ THEN REPEAT strip_tac);
a(bc_thm_tac left_proj_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(LEMMA_T¨(Ãz∑ (Ã(x, y)∑ y) ((Ãz∑(f z, g z)) z))  ç (“, ‘) ContinuousÆ
	(fn th => ante_tac th THEN rewrite_tac[»_axiom]));
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨” ∏âT ‘Æ THEN REPEAT strip_tac);
a(bc_thm_tac right_proj_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "3" *** *)
a(all_fc_tac[product_continuous_thm]);
val product_continuous_§_thm = save_pop_thm "product_continuous_§_thm";



val left_product_inj_continuous_thm = save_thm ( "left_product_inj_continuous_thm", (
set_goal([], ¨µ” : 'a SET SET; ‘ : 'b SET SET; y : 'b∑
	” ç Topology
±	‘ ç Topology
±	y ç SpaceâT ‘
¥	(Ãx∑ (x, y)) ç (”, ” ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(ante_tac(list_µ_elim[¨Ãx:'a∑ xÆ, ¨Ãx:'a∑yÆ, ¨”Æ, ¨”Æ, ¨‘Æ] product_continuous_thm));
a(ALL_FC_T asm_rewrite_tac[id_continuous_thm, const_continuous_thm]);
pop_thm()
));


val right_product_inj_continuous_thm = save_thm ( "right_product_inj_continuous_thm", (
set_goal([], ¨µ”: 'a SET SET; ‘ : 'b SET SET; x : 'a∑
	” ç Topology
±	‘ ç Topology
±	x ç SpaceâT ”
¥	(Ãy∑ (x, y)) ç (‘, ” ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(ante_tac(list_µ_elim[¨Ãy:'b∑ xÆ, ¨Ãy:'b∑yÆ, ¨‘Æ, ¨”Æ, ¨‘Æ] product_continuous_thm));
a(ALL_FC_T asm_rewrite_tac[id_continuous_thm, const_continuous_thm]);
pop_thm()
));


val range_unit_topology_continuous_thm = save_thm ( "range_unit_topology_continuous_thm", (
set_goal([], ¨µ‘: 'a SET SET; f : 'a ≠ ONE∑
	‘ ç Topology
¥	f ç (‘, 1âT) Continuous
Æ);
a(rewrite_tac[continuous_def,
		unit_topology_def, space_t_unit_topology_thm] THEN
	REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" rewrite_tac[pc_rule1"sets_ext1" prove_rule[] ¨{x|F} = {}Æ]);
a(all_fc_tac[empty_open_thm]);
(* *** Goal "2" *** *)
a(rewrite_tac[one_def, pc_rule1"sets_ext1" prove_rule[] ¨µa∑{x|x ç a} = aÆ]);
a(all_fc_tac[space_t_open_thm]);
pop_thm()
));


val domain_unit_topology_continuous_thm = save_thm ( "domain_unit_topology_continuous_thm", (
set_goal([], ¨µ‘: 'a SET SET; f : ONE ≠ 'a∑
	‘ ç Topology
±	f One ç SpaceâT ‘
¥	f ç (1âT, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def,
		unit_topology_def, space_t_unit_topology_thm] THEN
	REPEAT strip_tac);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[one_def]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN POP_ASM_T ante_tac);
a(PC_T1 "sets_ext1" rewrite_tac[one_def]);
pop_thm()
));

val pair_continuous_thm = snd ( "pair_continuous_thm", (
set_goal([], ¨µ “ ” ‘ f g∑
	“ ç Topology ± ” ç Topology ± ‘ ç Topology ±
	f ç (“, ”) Continuous ± g ç (“, ‘) Continuous ¥
	Pair (f, g) ç (“, ” ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac THEN rewrite_tac[pair_def]
	THEN ALL_FC_T rewrite_tac[product_continuous_thm]);
pop_thm()
));

val o_continuous_thm = snd ( "o_continuous_thm", (
set_goal([], ¨µ “ ” ‘ f g∑
	“ ç Topology ± ” ç Topology ± ‘ ç Topology ±
	f ç (“, ”) Continuous ± g ç (”, ‘) Continuous ¥
	g o f ç (“, ‘) Continuous
Æ);
a(REPEAT strip_tac THEN rewrite_tac[
		prove_rule[o_def] ¨µf g∑ g o f = Ãx∑ g(f x)Æ]
	THEN ALL_FC_T rewrite_tac[comp_continuous_thm]);
pop_thm()
));

val i_continuous_thm = snd ( "i_continuous_thm", (
set_goal([], ¨µ‘∑ ‘ ç Topology ¥ CombI ç (‘, ‘) ContinuousÆ);
a(REPEAT strip_tac THEN rewrite_tac[
		prove_rule[get_spec¨CombIÆ] ¨CombI = Ãx∑ xÆ]
	THEN ALL_FC_T rewrite_tac[id_continuous_thm]);
pop_thm()
));

val k_continuous_thm = snd ( "k_continuous_thm", (
set_goal([], ¨µ ” ‘ c∑
	” ç Topology ± ‘ ç Topology ± c ç SpaceâT ‘ ¥
	CombK c ç (”, ‘) ContinuousÆ);
a(REPEAT strip_tac THEN rewrite_tac[
		prove_rule[get_spec¨CombKÆ] ¨µc∑CombK c = Ãx∑ cÆ]
	THEN ALL_FC_T rewrite_tac[const_continuous_thm]);
pop_thm()
));


val ç_space_t_product_thm = snd ( "ç_space_t_product_thm", (
set_goal([], ¨µ” ‘ x∑
	” ç Topology ± ‘ ç Topology ± Fst x ç SpaceâT ” ± Snd x ç SpaceâT ‘ ¥
	x ç SpaceâT(” ∏âT ‘)Æ);
a(REPEAT strip_tac THEN ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(asm_rewrite_tac[∏_def]);
pop_thm()
));



local

(*
*)

val continuity_fact_thms : THM list = [
	product_topology_thm,
	ç_space_t_product_thm,
	fst_continuous_thm,
	snd_continuous_thm,
	i_continuous_thm,
	k_continuous_thm,
	pair_continuous_thm,
	o_continuous_thm];

(*
*)

(*
*)
val continuity_pats = {
	object_pat = ¨(¡, ¡ ç Topology)Æ,
	unary_pat = ¨(x, x ç (¡, ¬) Continuous)Æ,
	binary_pat = ¨(x, Uncurry x ç (¡, ¬) Continuous)Æ,
	parametrized_pat = ¨(h, (Ã x∑ h x p) ç (¡, ¬) Continuous)Æ};

val fst_snd : TERM list = [¨FstÆ,  ¨SndÆ];

val product_t_const : TERM = ¨$∏âTÆ;

val continuity_params = morphism_params
		continuity_pats
		fst_snd
		[([], product_t_const)]
		∂_object_by_type_tac
		continuity_fact_thms;
in
(*
*)
fun basic_continuity_tac (thms : THM list): TACTIC = (fn gl as (asms, _) =>
	basic_morphism_tac (continuity_params (thms @ map asm_rule asms)) [] gl
);
end (* local ... in ... end *);
local
	val ç_topology_pattern = ¨¡ ç TopologyÆ;
in
fun basic_topology_tac (thms : THM list) : TACTIC = (fn gl as (asms, _) =>
	let
		val all_thms = map asm_rule asms @ thms;
		fun is_ç_topology tm = (
			(term_match tm ç_topology_pattern; true)
			handle Fail _ => false
		);
		fun is_rule thm = (
			let	val tm = (snd o strip_µ o concl) thm;
			in
			is_¥ tm andalso (is_ç_topology o snd o dest_¥) tm
			end
		);
		val is_axiom = is_ç_topology o snd o strip_µ o concl;
		val rule_thms = product_topology_thm ::
					subspace_topology_thm ::
					all_thms drop (not o is_rule);
		val basic_thms = unit_topology_thm ::
					all_thms drop (not o is_axiom);
	in	(REPEAT o CHANGED_T o FIRST)
			[rewrite_tac basic_thms, bc_tac rule_thms]
	end	gl
);
end;


val diag_inj_continuous_thm = save_thm ( "diag_inj_continuous_thm", (
set_goal([], ¨µ ‘ : 'a SET SET∑
	‘ ç Topology
¥	(Ãx∑ (x, x)) ç (‘, ‘ ∏âT ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(basic_continuity_tac[]);
pop_thm()
));


val cond_continuous_thm = save_thm ( "cond_continuous_thm", (
set_goal([], ¨µf g X ” ‘∑
	f ç (”, ‘) Continuous
±	g ç (”, ‘) Continuous
±	(µx∑x ç SpaceâT ” ±  (µA∑x ç A ± A ç ” ¥ ∂y z∑y ç A ± z ç A ± y ç X ± ≥z ç X)
		¥ f x = g x)
±	” ç Topology
±	‘ ç Topology
¥	(Ãx∑ if x ç X then f x else g x) ç (”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(cases_tac¨x ç XÆ THEN asm_rewrite_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(strip_tac THEN rewrite_tac[]);
a(cases_tac¨x ç XÆ THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(cases_tac¨≥ µ A∑ x ç A ± A ç ” ¥ (∂ y z∑ y ç A ± z ç A ± y ç X ± ≥ z ç X)Æ);
(* *** Goal "2.1.1" *** *)
a(LIST_DROP_NTH_ASM_T [13] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç A} ° A'Æ);
a(REPEAT strip_tac);
(* *** Goal "2.1.1.1" *** *)
a(bc_thm_tac °_open_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.1.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(spec_nth_asm_tac 5 ¨xÆ);
a(spec_nth_asm_tac 1 ¨x'Æ THEN asm_rewrite_tac[]);
(* *** Goal "2.1.2" *** *)
a(LIST_DROP_NTH_ASM_T [9, 11] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç A} ° {x | x ç SpaceâT ” ± g x ç A}Æ);
a(REPEAT strip_tac);
(* *** Goal "2.1.2.1" *** *)
a(bc_thm_tac °_open_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.2.2" *** *)
a(LEMMA_T¨f x = g xÆ (asm_rewrite_thm_tac o eq_sym_rule));
a(all_asm_fc_tac[]);
(* *** Goal "2.1.2.3" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(cases_tac ¨x' ç XÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(cases_tac¨≥ µ A∑ x ç A ± A ç ” ¥ (∂ y z∑ y ç A ± z ç A ± y ç X ± ≥ z ç X)Æ);
(* *** Goal "2.2.1" *** *)
a(LIST_DROP_NTH_ASM_T [11] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT ” ± g x ç A} ° A'Æ);
a(REPEAT strip_tac);
(* *** Goal "2.2.1.1" *** *)
a(bc_thm_tac °_open_thm THEN REPEAT strip_tac);
(* *** Goal "2.2.1.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(spec_nth_asm_tac 5 ¨x'Æ);
a(spec_nth_asm_tac 1 ¨xÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [9, 11] all_fc_tac);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç A} ° {x | x ç SpaceâT ” ± g x ç A}Æ);
a(REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(bc_thm_tac °_open_thm THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2" *** *)
a(LEMMA_T¨f x = g xÆ asm_rewrite_thm_tac);
a(all_asm_fc_tac[]);
(* *** Goal "2.2.2.3" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(cases_tac ¨x' ç XÆ THEN asm_rewrite_tac[]);
pop_thm()
));


val closed_¿_closed_continuous_thm = save_thm ( "closed_¿_closed_continuous_thm", (
set_goal([], ¨µ” ‘ A B f g∑
	” ç Topology
±	‘ ç Topology
±	A ç ” Closed
±	B ç ” Closed
±	f ç (A ÚâT ”, ‘) Continuous
±	g ç (B ÚâT ”, ‘) Continuous
±	(µx∑x ç A ° B ¥ f x = g x)
¥	(Ãx∑ if x ç A then f x else g x) ç ((A ¿ B) ÚâT ”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_closed_thm] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T (interval 1 6) (MAP_EVERY ante_tac));
a(lemma_tac ¨A ¿ B ç ” ClosedÆ THEN1 all_fc_tac[¿_closed_thm]);
a(ALL_FC_T rewrite_tac[subspace_topology_closed_thm,
	subspace_topology_space_t_thm3]);
a(PC_T1 "predicates" REPEAT strip_tac
	THEN cases_tac¨x ç AÆ);
(* *** Goal "1.1" *** *)
a(LIST_DROP_NTH_ASM_T [7] (ALL_FC_T asm_rewrite_tac));
(* *** Goal "1.2" *** *)
a(DROP_NTH_ASM_T 2 strip_asm_tac);
a(LIST_DROP_NTH_ASM_T [5] (ALL_FC_T asm_rewrite_tac));
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T (interval 1 6) (MAP_EVERY ante_tac));
a(lemma_tac ¨A ¿ B ç ” ClosedÆ THEN1 all_fc_tac[¿_closed_thm]);
a(ALL_FC_T rewrite_tac[subspace_topology_closed_thm,
	subspace_topology_space_t_thm3]
	THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [3, 5] all_fc_tac);
a(∂_tac¨(B'' ° A) ¿ (B' ° B)Æ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_tac[°_closed_thm, ¿_closed_thm] THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(LIST_DROP_NTH_ASM_T [1, 3] (rewrite_tac o map eq_sym_rule));
a(DROP_NTH_ASM_T 4 ante_tac THEN DROP_ASMS_T discard_tac);
a(PC_T1 "sets_ext1" rewrite_tac[] THEN strip_tac THEN µ_tac);
a(cases_tac¨x ç AÆ THEN asm_rewrite_tac[]
	THEN asm_prove_tac[]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));



val open_¿_open_continuous_thm = save_thm ( "open_¿_open_continuous_thm", (
set_goal([], ¨µ” ‘ A B f g∑
	” ç Topology
±	‘ ç Topology
±	A ç ”
±	B ç ”
±	f ç (A ÚâT ”, ‘) Continuous
±	g ç (B ÚâT ”, ‘) Continuous
±	(µx∑x ç A ° B ¥ f x = g x)
¥	(Ãx∑ if x ç A then f x else g x) ç ((A ¿ B) ÚâT ”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T (interval 1 6) (MAP_EVERY ante_tac));
a(lemma_tac ¨A ¿ B ç ”Æ THEN1 all_fc_tac[¿_open_thm]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]);
a(rewrite_tac[subspace_topology_def]);
a(PC_T1 "predicates" REPEAT strip_tac
	THEN cases_tac¨x ç AÆ);
(* *** Goal "1.1" *** *)
a(LIST_DROP_NTH_ASM_T [7] (ALL_FC_T asm_rewrite_tac));
(* *** Goal "1.2" *** *)
a(DROP_NTH_ASM_T 2 strip_asm_tac);
a(LIST_DROP_NTH_ASM_T [5] (ALL_FC_T asm_rewrite_tac));
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T (interval 1 6) (MAP_EVERY ante_tac));
a(lemma_tac ¨A ¿ B ç ”Æ THEN1 all_fc_tac[¿_open_thm]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [3, 5] all_fc_tac);
a(∂_tac¨(B'' ° A) ¿ (B' ° B)Æ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_tac[°_open_thm, ¿_open_thm] THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(LIST_DROP_NTH_ASM_T [1, 3] (rewrite_tac o map eq_sym_rule));
a(DROP_NTH_ASM_T 4 ante_tac THEN DROP_ASMS_T discard_tac);
a(PC_T1 "sets_ext1" rewrite_tac[] THEN strip_tac THEN µ_tac);
a(cases_tac¨x ç AÆ THEN asm_rewrite_tac[]
	THEN asm_prove_tac[]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));


val compatible_family_continuous_thm = save_thm ( "compatible_family_continuous_thm", (
set_goal([], ¨µ” ‘ X U G∑
	” ç Topology
±	‘ ç Topology
±	(µx∑ x ç X ¥ U x Ä X)
±	(µx∑ x ç X ¥ x ç U x)
±	(µx∑ x ç X ¥ U x ç X ÚâT ”)
±	(µx∑ x ç X ¥ G x ç (U x ÚâT ”, ‘) Continuous)
±	(µx y∑ x ç X ± y ç U x ¥ G y y = G x y)
¥	(Ãx∑ G x x) ç (X ÚâT ”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
	THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [4] (FC_T bc_tac));
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
	THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨X Ä SpaceâT ”Æ);
(* *** Goal "2.1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac);
a(all_asm_fc_tac[]);
a(lemma_tac ¨X ÚâT ” ç TopologyÆ THEN1 
	(bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac));
a(LEMMA_T ¨x ç SpaceâT (X ÚâT ”)Æ ante_tac THEN1 all_fc_tac[ç_space_t_thm]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm1]);
a(lemma_tac¨X ÚâT ” ç TopologyÆ THEN1 basic_topology_tac[]);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]
	THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
a(LIST_DROP_NTH_ASM_T [3, 4](MAP_EVERY ante_tac));
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm1]);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
a(lemma_tac¨x ç B ° U xÆ
	THEN1 (DROP_NTH_ASM_T 3 (rewrite_thm_tac o eq_sym_rule)
		THEN asm_rewrite_tac[]));
a(∂_tac¨B ° U xÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(∂_tac¨B ° B'Æ THEN REPEAT strip_tac THEN1 all_fc_tac[°_open_thm]);
a(asm_rewrite_tac[] THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2.2" *** *)
a(DROP_NTH_ASM_T 4 (rewrite_thm_tac o eq_sym_rule));
a(PC_T1 "sets_ext1" REPEAT strip_tac
	THEN1 PC_T1 "sets_ext" all_asm_fc_tac[]);
a(LIST_DROP_NTH_ASM_T [15] (ALL_FC_T asm_rewrite_tac));
pop_thm()
));


val compatible_family_continuous_thm1 = save_thm ( "compatible_family_continuous_thm1", (
set_goal([], ¨µ” : ('a ∏ 'b) SET SET; ‘ : 'c SET SET; X U G∑
	” ç Topology
±	‘ ç Topology
±	(µv r∑ (v, r) ç X ¥ U (v, r) Ä X)
±	(µv r∑ (v, r) ç X ¥ (v, r) ç U (v, r))
±	(µv r∑ (v, r) ç X ¥ U (v, r) ç X ÚâT ”)
±	(µv r∑ (v, r) ç X ¥ G (v, r) ç (U (v, r) ÚâT ”, ‘) Continuous)
±	(µv r w s∑ (v, r) ç X ± (w, s) ç U (v, r) ¥ G (w, s) (w, s) = G (v, r) (w, s))
¥	(Ã(v, r)∑ G (v, r) (v, r)) ç (X ÚâT ”, ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(LEMMA_T ¨(Ã(v, r)∑ G (v, r) (v, r)) = (Ãx∑G x x)Æ rewrite_thm_tac
	THEN1 rewrite_tac[]);
a(bc_thm_tac compatible_family_continuous_thm);
a(∂_tac¨UÆ THEN REPEAT strip_tac
	THEN pair_tac¨x = (a : 'a, b : 'b)Æ
	THEN_TRY pair_tac¨y = (c : 'a, d : 'b)Æ
	THEN asm_prove_tac[]);
pop_thm()
));


val same_on_space_continuous_thm = save_thm ( "same_on_space_continuous_thm", (
set_goal([], ¨µ” ‘ f g∑
	” ç Topology
±	‘ ç Topology
±	g ç (”, ‘) Continuous
±	(µx∑x ç SpaceâT ” ¥ f x = g x)
¥	f ç (”, ‘) Continuous
Æ);
a(rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[]);
a(LEMMA_T ¨µx∑ x ç SpaceâT ” ± f x ç A § x ç SpaceâT ” ± g x ç AÆ
	asm_rewrite_thm_tac);
a(rewrite_tac[taut_rule ¨µp q r∑ (p ± q § p ± r) § (p ¥ (q § r))Æ]);
a(µ_tac THEN ¥_tac THEN ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));



val same_on_space_continuous_thm1 = save_thm ( "same_on_space_continuous_thm1", (
set_goal([], ¨µ” ‘ f g∑
	” ç Topology
±	‘ ç Topology
±	(µx∑x ç SpaceâT ” ¥ f x = g x)
¥	(f ç (”, ‘) Continuous § g ç (”, ‘) Continuous)
Æ);
a(REPEAT strip_tac THEN all_fc_tac[same_on_space_continuous_thm]);
a(DROP_NTH_ASM_T 2 (strip_asm_tac o conv_rule(ONCE_MAP_C eq_sym_conv)));
a(all_fc_tac[same_on_space_continuous_thm]);
pop_thm()
));



val subspace_product_continuous_thm = save_thm ( "subspace_product_continuous_thm", (
set_goal([], ¨µ“ ” ‘ f A B∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	≥(A ∏ B) = {}
±	A Ä SpaceâT “
±	B Ä SpaceâT ”
¥	(f ç ((A ∏ B) ÚâT (“ ∏âT ”), ‘) Continuous §
	(µa b∑ a ç A ± b ç B ¥ f(a, b) ç SpaceâT ‘) ±
	(µa b E∑ a ç A ± b ç B ± f(a, b) ç E ± E ç ‘
		¥	∂C D∑ a ç C ± C ç “ ± b ç D ± D ç ” ± µx y∑
				x ç A ° C ± y ç B ° D ¥ f(x, y) ç E))
Æ);
a(REPEAT_UNTIL is_§ strip_tac);
a(lemma_tac¨“ ∏âT ” ç TopologyÆ THEN1 basic_topology_tac[]);
a(rewrite_tac[continuous_def]);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm,
		product_topology_space_t_thm]);
a(PC_T1 "sets_ext1" rewrite_tac[∏_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 4 bc_thm_tac THEN asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [1, 2, 5, 6] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(POP_ASM_T ante_tac);
a(lemma_tac¨{(v, w)|v ç A ± w ç B} ÚâT “ ∏âT ” ç TopologyÆ
	THEN1 (bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac));
a(LIST_GET_NTH_ASM_T [8, 9] (PC_T1 "sets_ext1" all_fc_tac));
a(PC_T1 "sets_ext1" rewrite_tac[product_topology_def, subspace_topology_def, ∏_def] THEN REPEAT strip_tac);
a(TOP_ASM_T (ante_tac o list_µ_elim[¨aÆ, ¨bÆ])
	THEN rewrite_tac[] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(∂_tac¨A'Æ THEN ∂_tac¨B''Æ THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 11 (ante_tac o list_µ_elim[¨xÆ, ¨yÆ])
	THEN rewrite_tac[] THEN REPEAT strip_tac
	THEN all_asm_fc_tac[]);
(* *** Goal "3" *** *)
a(DROP_NTH_ASM_T 6 (ante_tac o list_µ_elim[¨Fst xÆ, ¨Snd xÆ])
	THEN asm_rewrite_tac[]);
(* *** Goal "4" *** *)
a(rename_tac[(¨A'Æ, "E")]
	THEN LEMMA_T ¨
	{x |((Fst x ç A ± Snd x ç B) ± Fst x ç SpaceâT “ ± Snd x ç SpaceâT ”) ± f x ç E} =
	{(c, d) | (c ç A ± c ç SpaceâT “) ± (d ç B ± d ç  SpaceâT ”) ± f(c, d) ç E}Æ rewrite_thm_tac
	THEN1 MERGE_PCS_T1 ["'pair", "sets_ext1"] prove_tac[]);
a(LEMMA_T¨µx∑ x ç A ± x ç SpaceâT “ § x ç AÆ rewrite_thm_tac
	THEN1 (GET_NTH_ASM_T 6 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]));
a(LEMMA_T¨µx∑ x ç B ± x ç SpaceâT ” § x ç BÆ rewrite_thm_tac
	THEN1 (GET_NTH_ASM_T 5 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]));
a(lemma_tac¨{(v, w)|v ç A ± w ç B} ÚâT “ ∏âT ” ç TopologyÆ
	THEN1 (bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac));
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[
	open_open_neighbourhood_thm]);
a(REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [6] all_fc_tac);
a(∂_tac¨(A ° C) ∏ (B ° D)Æ
	THEN once_rewrite_tac[taut_rule¨µp q∑p ± q § q ± pÆ]
	THEN REPEAT strip_tac);
(* *** Goal "4.1" *** *)
a(MERGE_PCS_T1 ["'pair", "sets_ext1"] asm_rewrite_tac[∏_def]);
(* *** Goal "4.2" *** *)
a(MERGE_PCS_T1 ["'pair", "sets_ext1"] rewrite_tac[∏_def]
	THEN REPEAT strip_tac
	THEN all_asm_fc_tac[]);
(* *** Goal "4.3" *** *)
a(rewrite_tac[subspace_topology_def]);
a(∂_tac¨C ∏ DÆ
	THEN once_rewrite_tac[taut_rule¨µp q∑p ± q § q ± pÆ]
	THEN REPEAT strip_tac);
(* *** Goal "4.3.1" *** *)
a(MERGE_PCS_T1 ["'pair", "sets_ext1"] asm_rewrite_tac[∏_def]);
a(taut_tac);
(* *** Goal "4.3.2" *** *)
a(rewrite_tac[product_topology_def, ∏_def]
	THEN REPEAT strip_tac);
a(∂_tac¨CÆ THEN ∂_tac¨DÆ THEN REPEAT strip_tac);
pop_thm()
));


val subspace_topology_hausdorff_thm = save_thm ( "subspace_topology_hausdorff_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
±	‘ ç Hausdorff
¥	(X ÚâT ‘) ç Hausdorff
Æ);
a(rewrite_tac [hausdorff_def]);
a(REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T rewrite_tac [subspace_topology_space_t_thm]);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
a(∂_tac¨A ° XÆ THEN ∂_tac ¨B ° XÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(∂_tac¨AÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(∂_tac¨BÆ THEN REPEAT strip_tac);
(* *** Goal "3" *** *)
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val product_topology_hausdorff_thm = save_thm ( "product_topology_hausdorff_thm", (
set_goal([], ¨µ” ‘∑
	” ç Topology
±	‘ ç Topology
±	” ç Hausdorff
±	‘ ç Hausdorff
¥	(” ∏âT ‘) ç Hausdorff
Æ);
a(rewrite_tac [hausdorff_def]);
a(REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T rewrite_tac [product_topology_space_t_thm]);
a(rewrite_tac[product_topology_def,
	pc_rule1"prop_eq_pair" prove_rule[]
		¨µp q∑≥p = q § ≥Fst p = Fst q ≤ ≥Snd p = Snd qÆ,
	merge_pcs_rule1["'bin_rel", "sets_ext1"] prove_rule[]
		¨µp a b∑p ç (a ∏ b) § Fst p ç a ± Snd p ç bÆ]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_asm_fc_tac[]);
a(∂_tac¨A ∏ SpaceâT ‘Æ THEN ∂_tac ¨B ∏ SpaceâT ‘Æ);
a(rewrite_tac[merge_pcs_rule1["'bin_rel", "sets_ext1"] prove_rule[]
		¨µp a b∑p ç (a ∏ b) § Fst p ç a ± Snd p ç bÆ]
	THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(∂_tac¨AÆ THEN ∂_tac ¨SpaceâT ‘Æ THEN ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
(* *** Goal "1.2" *** *)
a(∂_tac¨BÆ THEN ∂_tac ¨SpaceâT ‘Æ THEN ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
a(asm_rewrite_tac[merge_pcs_rule1["'bin_rel", "sets_ext1"] prove_rule[]
		¨µa b c d∑ (a ∏ b) ° (c ∏ d) = ((a ° c) ∏ (b ° d))  ± ({} ∏ a) = {}Æ]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[]);
a(∂_tac¨SpaceâT ” ∏ AÆ THEN ∂_tac ¨SpaceâT ” ∏ BÆ);
a(rewrite_tac[merge_pcs_rule1["'bin_rel", "sets_ext1"] prove_rule[]
		¨µp a b∑p ç (a ∏ b) § Fst p ç a ± Snd p ç bÆ]
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(∂_tac¨SpaceâT ”Æ THEN ∂_tac ¨AÆ THEN ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
(* *** Goal "2.2" *** *)
a(∂_tac¨SpaceâT ”Æ THEN ∂_tac ¨BÆ THEN ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
a(asm_rewrite_tac[merge_pcs_rule1["'bin_rel", "sets_ext1"] prove_rule[]
		¨µa b c d∑ (a ∏ b) ° (c ∏ d) = ((a ° c) ∏ (b ° d))  ± (a ∏ {}) = {}Æ]);
pop_thm()
));


val punctured_hausdorff_thm = save_thm ( "punctured_hausdorff_thm", (
set_goal([], ¨µ‘ X x∑
	‘ ç Topology
±	‘ ç Hausdorff
±	X Ä SpaceâT ‘
±	x ç SpaceâT ‘
¥	(X \ {x}) ç (X ÚâT ‘)
Æ);
a(rewrite_tac [hausdorff_def] THEN REPEAT strip_tac);
a(lemma_tac ¨ (X ÚâT ‘) ç Topology Æ
	THEN1 ALL_FC_T rewrite_tac[subspace_topology_thm]);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[
	open_open_neighbourhood_thm]);
a(rewrite_tac[subspace_topology_def]
	THEN REPEAT strip_tac);
a(all_asm_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx X S∑x ç X ± X Ä S ¥ x ç SÆ]);
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(∂_tac¨A ° XÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(asm_prove_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN POP_ASM_T ante_tac
	THEN DROP_ASMS_T discard_tac);
a(PC_T "sets_ext1" contr_tac
	THEN all_var_elim_asm_tac1
	THEN all_asm_fc_tac[]);
pop_thm()
));


val compact_topological_thm = save_thm ( "compact_topological_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
¥	(X ç ‘ Compact § X ç (X ÚâT ‘) Compact)Æ);
a(rewrite_tac[compact_def] THEN PC_T1 "sets_ext1" REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T1 fc_§_canon rewrite_tac[subspace_topology_space_t_thm]);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a Ä a ° b § a Ä bÆ]);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(lemma_tac¨X Ä ﬁ{B | B ç ‘ ± B ° X ç V} Æ THEN1 PC_T1 "sets_ext" REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(LIST_GET_NTH_ASM_T [1, 2, 3] (PC_T1 "sets_ext1" (MAP_EVERY strip_asm_tac)));
a(all_asm_fc_tac[]);
a(LIST_GET_NTH_ASM_T [3] all_fc_tac THEN all_var_elim_asm_tac1);
a(∂_tac¨BÆ THEN REPEAT strip_tac);
(* *** Goal "1.2" *** *)
a(lemma_tac¨{B | B ç ‘ ± B ° X ç V} Ä ‘Æ THEN1 PC_T1 "sets_ext" prove_tac[]);
a(all_asm_fc_tac[]);
a(ante_tac(list_µ_elim[¨ÃB∑B ° XÆ, ¨WÆ]finite_image_thm));
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac ¨{C|∂ B∑ B ç W ± C = B ° X}Æ THEN REPEAT strip_tac);
(* *** Goal "1.2.1" *** *)
a(PC_T "sets_ext1"  strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1);
a(LIST_GET_NTH_ASM_T [5] (PC_T1 "sets_ext1" all_fc_tac));
(* *** Goal "1.2.2" *** *)
a(PC_T "sets_ext1"  strip_tac THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [3] (PC_T1 "sets_ext1" all_fc_tac));
a(∂_tac¨s ° XÆ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(lemma_tac¨X Ä ﬁ{C | ∂B∑ B ç V ± C = B ° X} Æ THEN1 PC_T1 "sets_ext" REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LIST_GET_NTH_ASM_T [2] (PC_T1 "sets_ext1" all_fc_tac));
a(∂_tac¨s ° XÆ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(lemma_tac¨{C | ∂B∑ B ç V ± C = B ° X} Ä {A|∂ B∑ B ç ‘ ± A = B ° X}Æ
	THEN1 (PC_T "sets_ext" strip_tac THEN REPEAT strip_tac));
(* *** Goal "2.2.1" *** *)
a(all_var_elim_asm_tac1 THEN ∂_tac ¨BÆ THEN
	REPEAT strip_tac THEN PC_T1 "sets_ext1" all_asm_fc_tac[]);
(* *** Goal "2.2.2" *** *)
a(all_asm_fc_tac[]);
a(lemma_tac¨∂f∑µC∑ C ç W ¥ f C ç V ± C = f C ° XÆ THEN1 prove_∂_tac);
(* *** Goal "2.2.2.1" *** *)
a(REPEAT strip_tac);
a(cases_tac¨≥C' ç WÆ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 (PC_T1 "sets_ext1" strip_asm_tac));
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(all_var_elim_asm_tac1 THEN ∂_tac¨BÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2" *** *)
a(strip_asm_tac(list_µ_elim[¨fÆ, ¨WÆ]finite_image_thm));
a(∂_tac¨{y|∂ x∑ x ç W ± y = f x}Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(PC_T "sets_ext1"  strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.2.2.2" *** *)
a(PC_T "sets_ext1"  strip_tac THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 4 (PC_T1 "sets_ext1" strip_asm_tac));
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(∂_tac¨f sÆ THEN asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(DROP_NTH_ASM_T 4 ante_tac);
a(POP_ASM_T (fn th => conv_tac(LEFT_C(once_rewrite_conv[th]))));
a(REPEAT strip_tac THEN rename_tac[]);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
pop_thm()
));


val image_compact_thm = save_thm ( "image_compact_thm", (
set_goal([], ¨µf C ” ‘∑
	f ç (”, ‘) Continuous
±	C ç ” Compact
±	” ç Topology
±	‘ ç Topology
¥	{y | ∂x∑ x ç C ± y = f x} ç ‘ Compact
Æ);
a(rewrite_tac[compact_def, continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac );
a(all_var_elim_asm_tac1 THEN PC_T1 "sets_ext1" all_asm_fc_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨{A | ∂B∑ B ç V ± A = {x|x ç SpaceâT ” ± f x ç B}} Ä ”Æ);
(* *** Goal "2.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN GET_NTH_ASM_T 8 bc_thm_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨C Ä ﬁ{A | ∂B∑ B ç V ± A = {x|x ç SpaceâT ” ± f x ç B}}Æ);
(* *** Goal "2.2.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(LEMMA_T¨f x ç {y|∂ x∑ x ç C ± y = f x}Æ  asm_tac THEN1
	(REPEAT strip_tac THEN ∂_tac¨xÆ THEN REPEAT strip_tac));
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
a(∂_tac¨{x|x ç SpaceâT ” ± f x ç s}Æ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2" *** *)
a(all_asm_fc_tac[]);
a(lemma_tac¨∂h∑µA∑ A ç W ¥ h A ç V ± A = {x | x ç SpaceâT ” ± f x ç h A}Æ
	THEN1 prove_∂_tac THEN REPEAT strip_tac);
 (* *** Goal "2.2.2.1" *** *)
a(cases_tac ¨A' ç WÆ  THEN asm_rewrite_tac[]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
a(∂_tac¨BÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2" *** *)
a(strip_asm_tac (list_µ_elim[¨hÆ, ¨WÆ] finite_image_thm));
a(∂_tac¨{y|∂ x∑ x ç W ± y = h x}Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.2.2.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1);
a(DROP_NTH_ASM_T 7 discard_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µb∑x' ç C ± C Ä b ¥ x' ç bÆ]);
a(∂_tac¨h sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.2.1" *** *)
a(all_asm_fc_tac[]);
a(POP_ASM_T (fn th => DROP_NTH_ASM_T 5 (ante_tac o once_rewrite_rule[th])));
a(REPEAT strip_tac);
(* *** Goal "2.2.2.2.2.2" *** *)
a(∂_tac¨sÆ THEN REPEAT strip_tac);
pop_thm()
));


val ¿_compact_thm = save_thm ( "¿_compact_thm", (
set_goal([], ¨µC D ”∑
	C ç ” Compact
±	D ç ” Compact
±	” ç Topology
¥	C ¿ D ç ” Compact
Æ);
a(rewrite_tac[compact_def] THEN REPEAT strip_tac
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a ¿ b Ä c ¥ a Ä c ± b Ä cÆ]);
a(all_asm_fc_tac[]);
a(∂_tac ¨W ¿ W'Æ THEN
	rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑ﬁ(a ¿ b) = ﬁa ¿ ﬁbÆ]
	THEN ALL_FC_T rewrite_tac[
	pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä c ± b Ä c ¥ a ¿ b Ä cÆ,
	pc_rule1"sets_ext1" prove_rule[]¨µa b c d∑a Ä c ± b Ä d ¥ a ¿ b Ä d ¿ cÆ,
	conv_rule(ONCE_MAP_C eq_sym_conv) ¿_finite_thm]);
pop_thm()
));


val compact_closed_lemma = (* not saved *) snd ( "compact_closed_lemma", (
set_goal([], ¨µ‘ V p∑
	‘ ç Topology
±	V Ä ‘
±	V ç Finite
±	p ç SpaceâT ‘
±	(µA∑ A ç V ¥ ∂B∑ B ç ‘ ± p ç B ± A ° B = {})
¥	∂B∑ B ç ‘ ± p ç B ± B ° ﬁV = {}Æ);
a(REPEAT strip_tac);
a(lemma_tac¨
	∂b∑µA∑A ç V ¥ b A ç ‘ ± p ç b A ± A ° b A = {}
Æ THEN1 prove_∂_tac);
(* *** Goal "1" *** *)
a(REPEAT strip_tac);
a(cases_tac¨≥A' ç VÆ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 2 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(cases_tac¨ﬁV = {}Æ);
(* *** Goal "2.1" *** *)
a(∂_tac ¨SpaceâT ‘Æ THEN ALL_FC_T asm_rewrite_tac[space_t_open_thm]);
(* *** Goal "2.2" *** *)
a(lemma_tac ¨•{y|∂ x∑ x ç V ± y = b x} ç ‘Æ THEN1 bc_thm_tac finite_•_open_thm);
(* *** Goal "2.2.1" *** *)
a(asm_rewrite_tac[] THEN ALL_FC_T rewrite_tac[finite_image_thm]);
a(REPEAT strip_tac THEN PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "2.2.1.1" *** *)
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.1.2" *** *)
a(rewrite_tac[]);
a(cases_tac¨V = {}Æ THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(POP_ASM_T (PC_T1 "sets_ext1" strip_asm_tac));
a(∂_tac¨b xÆ THEN ∂_tac¨xÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(∂_tac¨•{y|∂ x∑ x ç V ± y = b x}Æ THEN asm_rewrite_tac[]);
a(REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN rewrite_tac[°_def, •_def, ﬁ_def]);
a(REPEAT strip_tac);
a(∂_tac¨b sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(∂_tac¨ sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.2" *** *)
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val compact_closed_thm = save_thm ( "compact_closed_thm", (
set_goal([], ¨µ‘ C∑
	‘ ç Topology
±	‘ ç Hausdorff
±	C ç ‘ Compact
¥	C ç ‘ ClosedÆ);
a(REPEAT strip_tac);
a(ALL_FC_T1 fc_§_canon  rewrite_tac[closed_open_neighbourhood_thm]);
a(once_rewrite_tac[prove_rule[]¨µp1 p2∑ p1 ± p2 § p1 ± (p1 ¥ p2)Æ]);
a(REPEAT strip_tac THEN1
	(POP_ASM_T ante_tac THEN prove_tac[compact_def]));
a(lemma_tac¨C Ä ﬁ {A | A ç ‘ ± ∂B∑B ç ‘ ± x ç B ± A ° B = {}}Æ);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 5 (strip_asm_tac o rewrite_rule[hausdorff_def]));
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(lemma_tac¨x' ç SpaceâT ‘Æ THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(lemma_tac¨≥x' = xÆ THEN1 (contr_tac THEN all_var_elim_asm_tac1));
a(all_asm_fc_tac[]);
a(∂_tac¨AÆ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 5 (strip_asm_tac o rewrite_rule[compact_def]));
a(lemma_tac¨{A | A ç ‘ ± ∂B∑B ç ‘ ± x ç B ± A ° B = {}} Ä ‘Æ
	THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(all_asm_fc_tac[]);
a(lemma_tac¨W Ä ‘Æ THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(lemma_tac¨µ A∑ A ç W ¥ (∂ B∑ B ç ‘ ± x ç B ± A ° B = {})Æ);
(* *** Goal "2.1" *** *)
a(REPEAT strip_tac);
a(PC_T1 "sets_ext1" all_asm_fc_tac[]);
a(∂_tac¨BÆ THEN PC_T1 "sets_ext1" asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(all_fc_tac[compact_closed_lemma]);
a(∂_tac¨BÆ THEN  asm_rewrite_tac[]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[] ¨µX∑ C Ä X ± B ° X = {} ¥ B ° C = {}Æ]);
pop_thm()
));


val closed_Ä_compact_thm = save_thm ( "closed_Ä_compact_thm", (
set_goal([], ¨µ‘ B C∑
	‘ ç Topology
±	‘ ç Hausdorff
±	C ç ‘ Compact
±	B ç ‘ Closed
±	B Ä C
¥	B ç ‘ CompactÆ);
a(REPEAT strip_tac THEN GET_NTH_ASM_T 3 ante_tac);
a(rewrite_tac[compact_def] THEN REPEAT strip_tac
	THEN all_fc_tac[closed_open_complement_thm]);
a(all_fc_tac[compact_closed_thm]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µt a x∑a Ä t ± x ç t ¥ a ¿ {x} Ä tÆ]);
a(LEMMA_T¨µc b s v∑ c Ä s ± b Ä ﬁv ¥ c Ä ﬁ(v ¿ {s \ b})Æ
	(fn th => all_fc_tac[µ_elim¨CÆ th]));
(* *** Goal "1" *** *)
a(DROP_ASMS_T discard_tac THEN PC_T1 "sets_ext1" prove_tac[]);
a(cases_tac¨x ç bÆ THEN all_asm_fc_tac[]);
(* *** Goal "1.1" *** *)
a(contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "1.2" *** *)
a(∂_tac¨s \ bÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [8] all_fc_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µw v x∑ w Ä v ¿ {x} ¥ w \ {x} Ä v ± w \ {x} Ä wÆ]);
a(all_fc_tac[Ä_finite_thm]);
a(∂_tac¨W \ {SpaceâT ‘ \ B}Æ THEN REPEAT strip_tac);
a(LEMMA_T¨µc w s b∑ b Ä c ± c Ä ﬁw ¥ b Ä ﬁ(w \ {s \ b})Æ
	(fn th => bc_thm_tac (µ_elim¨CÆth)
		THEN contr_tac THEN all_asm_fc_tac[]));
a(DROP_ASMS_T discard_tac THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(∂_tac¨s'Æ THEN contr_tac THEN all_var_elim_asm_tac1);
pop_thm()
));


val compact_basis_thm = save_thm ( "compact_basis_thm", (
set_goal([], ¨µU ‘ X∑
	‘ ç Topology
±	U Ä ‘
±	(µA∑µx∑ x ç A ± A ç ‘ ¥ ∂B∑ x ç B ± B Ä A ± B ç U)
±	X Ä SpaceâT ‘
±	(µV∑ V Ä U ± X Ä ﬁ V ¥ ∂ W∑ W Ä V ± W ç Finite ± X Ä ﬁ W)
¥	X ç ‘ Compact
Æ);
a(rewrite_tac[compact_def] THEN REPEAT strip_tac);
a(lemma_tac¨{B | B ç U ± ∂ A∑ A ç V ± B Ä A} Ä UÆ THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(lemma_tac¨X Ä ﬁ{B | B ç U ± ∂ A∑ A ç V ± B Ä A}Æ
	THEN1 PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 3 (fn th => PC_T1 "sets_ext1" all_fc_tac[th]));
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx a∑x ç a ± a Ä ‘ ¥ x ç ‘Æ]);
a(DROP_NTH_ASM_T 9 (fn th => all_fc_tac[th]));
a(∂_tac¨BÆ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 5 (fn th => all_fc_tac[th]));
a(lemma_tac¨∂f∑µB∑B ç W ¥ f B ç V ± B Ä f BÆ THEN1 prove_∂_tac);
(* *** Goal "2.1" *** *)
a(REPEAT strip_tac THEN cases_tac¨B' ç WÆ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 (fn th => all_fc_tac[pc_rule1 "sets_ext1" once_rewrite_rule[] th]));
a(∂_tac ¨AÆ THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(ante_tac(list_µ_elim[¨fÆ, ¨WÆ] finite_image_thm) THEN asm_rewrite_tac[]);
a(REPEAT strip_tac);
a(∂_tac ¨{y|∂ x∑ x ç W ± y = f x}Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 4 (fn th => all_fc_tac[pc_rule1 "sets_ext1" once_rewrite_rule[] th]));
a(∂_tac ¨f sÆ THEN rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(PC_T1 "sets_ext" asm_prove_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(∂_tac ¨sÆ THEN asm_rewrite_tac[] );
pop_thm()
));


val compact_basis_product_topology_thm = save_thm ( "compact_basis_product_topology_thm", (
set_goal([], ¨µ” ‘ X∑
	” ç Topology
±	‘ ç Topology
±	X Ä SpaceâT (” ∏âT ‘)
±	(µV∑ 	V Ä (” ∏âT ‘)
	±	(µD∑ D ç V ¥ ∂B C∑ B ç ” ± C ç ‘ ± D = (B ∏ C))
	±	X Ä ﬁ V
	¥	∂ W∑ W Ä V ± W ç Finite ± X Ä ﬁ W)
¥	X ç (” ∏âT ‘) Compact
Æ);
a(REPEAT strip_tac THEN bc_thm_tac compact_basis_thm);
a(ALL_FC_T asm_rewrite_tac[product_topology_thm]);
a(∂_tac¨{D | ∂B C∑ B ç ” ± C ç ‘ ± D = (B ∏ C)}Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[product_topology_def] THEN PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(∂_tac¨BÆ THEN ∂_tac¨CÆ THEN asm_rewrite_tac[]);
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[∏_def]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[product_topology_def] THEN REPEAT strip_tac);
a(POP_ASM_T (ante_tac o list_µ_elim[¨Fst xÆ, ¨Snd xÆ]));
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨A' ∏ BÆ THEN REPEAT strip_tac THEN1 asm_rewrite_tac[∏_def]);
a(∂_tac¨A'Æ THEN ∂_tac¨BÆ THEN asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 2 (fn th => ante_tac(pc_rule1 "sets_ext1" once_rewrite_rule[] th)));
a(rewrite_tac[taut_rule¨µp1 p2∑(p1 ¥ p2 ± p1) § p1 ¥ p2Æ]);
a(REPEAT strip_tac THEN PC_T "sets_ext" strip_tac THEN REPEAT strip_tac);
a(all_asm_fc_tac[] THEN all_var_elim_asm_tac1);
a(rewrite_tac[product_topology_def] THEN REPEAT strip_tac);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
a(∂_tac¨BÆ THEN ∂_tac¨CÆ THEN asm_rewrite_tac[]);
pop_thm()
));


val compact_product_lemma = (* not saved *) snd ( "compact_product_lemma", (
set_goal([], ¨µ” ‘ W x∑
	” ç Topology
±	‘ ç Topology
±	x ç SpaceâT ”
±	W ç Finite
±	(µD∑D ç W ¥ ∂B C∑ x ç B ± B ç ” ± C ç ‘ ± D = (B ∏ C))
¥	∂A∑ x ç A ± A ç ” ± µt y∑(x, y) ç ﬁW ± t ç A ¥ (t, y) ç ﬁWÆ);
a(REPEAT strip_tac);
a(lemma_tac¨µV∑ V ç Finite ± V Ä W ¥
	∂A∑ x ç A ± A ç ” ± µt y∑(x, y) ç ﬁV ± t ç A ¥ (t, y) ç ﬁVÆ);
a(REPEAT strip_tac THEN POP_ASM_T ante_tac);
a(finite_induction_tac ¨VÆ);
(* *** Goal "1.1" *** *)
a(rewrite_tac[enum_set_clauses]);
a(all_fc_tac[space_t_open_thm] THEN contr_tac THEN all_asm_fc_tac[]);
(* *** Goal "1.2" *** *)
a(LEMMA_T ¨≥{x'} ¿ V Ä WÆ rewrite_thm_tac);
a(GET_NTH_ASM_T 2 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.3" *** *)
a(REPEAT strip_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[] ¨µx a b∑ {x} ¿ a Ä b ¥ x ç bÆ]);
a(LIST_DROP_NTH_ASM_T [8] all_fc_tac);
a(all_var_elim_asm_tac1 THEN rewrite_tac[enum_set_clauses,
	pc_rule1"sets_ext1" prove_rule[]¨µa v∑ﬁ(a ¿ v) = ﬁa ¿ ﬁvÆ]);
a(∂_tac ¨B ° AÆ THEN REPEAT strip_tac);
(* *** Goal "1.3.1" *** *)
a(bc_thm_tac °_open_thm THEN REPEAT strip_tac);
(* *** Goal "1.3.2" *** *)
a(swap_nth_asm_concl_tac 1 THEN LIST_DROP_NTH_ASM_T [3, 4] (MAP_EVERY ante_tac));
a(rewrite_tac[∏_def] THEN prove_tac[]);
(* *** Goal "1.3.3" *** *)
a(LEMMA_T ¨(x, y) ç ﬁVÆ asm_tac THEN1
	(LIST_DROP_NTH_ASM_T [5, 4] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext" prove_tac[]));
a(LIST_DROP_NTH_ASM_T [13] all_fc_tac);
a(contr_tac THEN all_asm_fc_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T bc_thm_tac THEN REPEAT strip_tac);
pop_thm()
));


val product_compact_thm = save_thm ( "product_compact_thm", (
set_goal([], ¨µX : 'a SET; Y : 'b SET; ” ‘ ∑
	X ç ” Compact
±	Y ç ‘ Compact
±	” ç Topology
±	‘ ç Topology
¥	(X ∏ Y) ç (” ∏âT ‘) CompactÆ);
a(REPEAT strip_tac THEN bc_thm_tac compact_basis_product_topology_thm);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(all_asm_ante_tac THEN rewrite_tac[compact_def] THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [4, 6] (MAP_EVERY ante_tac) THEN
	MERGE_PCS_T1 ["'bin_rel", "sets_ext1"] prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac ¨∂W∑µx∑ x ç X ¥
	W x Ä V ± W x ç Finite ± (µy∑y ç Y ¥ (x, y) ç ﬁ(W x)) ±
	µD∑ D ç W x ¥ (∂ B C∑ x ç B ± B ç ” ± C ç ‘ ± D = (B ∏ C))Æ
	THEN1 prove_∂_tac THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(cases_tac ¨x' ç XÆ THEN asm_rewrite_tac[]);
a(lemma_tac ¨x' ç SpaceâT ”Æ THEN1
	(LIST_DROP_NTH_ASM_T [1, 8] (MAP_EVERY ante_tac) THEN
	rewrite_tac[compact_def] THEN PC_T1 "sets_ext1" prove_tac[]));
a(strip_asm_tac (list_µ_elim[¨”Æ, ¨‘Æ, ¨x'Æ] right_product_inj_continuous_thm));
a(lemma_tac ¨(” ∏âT ‘) ç TopologyÆ THEN1 basic_topology_tac[]);
a(ante_tac (list_µ_elim[¨Ãy:'b∑(x', y)Æ, ¨YÆ, ¨‘Æ, ¨” ∏âT ‘Æ] image_compact_thm));
a(asm_rewrite_tac[compact_def] THEN REPEAT strip_tac);
a(lemma_tac¨x' ç X ¥ {y|∂ x∑ x ç Y ± Fst y = x' ± Snd y = x} Ä (X ∏ Y)Æ
	THEN1 (MERGE_PCS_T1 ["'bin_rel", "sets_ext" ] prove_tac[]
		THEN all_var_elim_asm_tac1));
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(POP_ASM_T (PC_T1 "sets_ext1" strip_asm_tac));
a(∂_tac ¨{A | A ç W ± ∂y∑(x', y) ç A}Æ THEN PC_T1 "basic_hol" REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(DROP_NTH_ASM_T 3 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.2" *** *)
a(bc_thm_tac Ä_finite_thm THEN ∂_tac ¨WÆ THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.3" *** *)
a(lemma_tac¨(x', y) ç ﬁWÆ);
(* *** Goal "2.1.3.1" *** *)
a(DROP_NTH_ASM_T 2 bc_thm_tac THEN REPEAT strip_tac);
a(∂_tac¨yÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.1.3.2" *** *)
a(REPEAT strip_tac);
a(∂_tac¨sÆ THEN asm_rewrite_tac[]);
a(∂_tac¨yÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.1.4" *** *)
a(lemma_tac¨D ç VÆ THEN1 (
	LIST_DROP_NTH_ASM_T [1, 4] (MAP_EVERY ante_tac)
		THEN PC_T1 "sets_ext" prove_tac[]));
a(LIST_DROP_NTH_ASM_T [14] all_fc_tac);
a(∂_tac¨BÆ THEN ∂_tac¨CÆ THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 5 ante_tac THEN all_var_elim_asm_tac1);
a(prove_tac[∏_def]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨X Ä ﬁ{A | A ç ” ±∂x∑x ç X ±  x ç A ± µt y∑t ç A ± y ç Y ¥ (t, y) ç ﬁ(W x)}Æ
	THEN1 PC_T1 "sets_ext" REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(lemma_tac ¨x ç SpaceâT ”Æ THEN1
	(LIST_DROP_NTH_ASM_T [1, 9] (MAP_EVERY ante_tac) THEN
	rewrite_tac[compact_def] THEN PC_T1 "sets_ext1" prove_tac[]));
a(DROP_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨xÆ));
a(all_fc_tac[compact_product_lemma]);
a(∂_tac¨AÆ THEN REPEAT strip_tac);
a(∂_tac¨xÆ THEN PC_T1 "basic_hol" REPEAT strip_tac);
a(PC_T1 "basic_hol" (LIST_DROP_NTH_ASM_T [7])  all_fc_tac);
a(PC_T1 "basic_hol" (LIST_DROP_NTH_ASM_T [4])  all_fc_tac);
(* *** Goal "2.2.2" *** *)
a(lemma_tac¨{A | A ç ” ±∂x∑x ç X ±  x ç A ± µt y∑t ç A ± y ç Y ¥ (t, y) ç ﬁ(W x)} Ä ”Æ
	THEN1 PC_T1 "sets_ext" prove_tac[]);
a(GET_NTH_ASM_T 10 (fn th => all_fc_tac[rewrite_rule[compact_def] th]));
a(LIST_DROP_NTH_ASM_T [4, 5, 7, 8] discard_tac);
a(lemma_tac¨∂U∑µA∑A ç W' ¥ (µ t y∑ t ç A ± y ç Y ¥ (t, y) ç ﬁ (U A)) ± U A Ä V ± U A ç FiniteÆ
	THEN1 prove_∂_tac);
(* *** Goal "2.2.2.1" *** *)
a(REPEAT strip_tac);
a(cases_tac¨A' ç W'Æ THEN asm_rewrite_tac[]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
a(∂_tac¨W xÆ THEN  POP_ASM_T ante_tac THEN ALL_ASM_FC_T rewrite_tac[] THEN taut_tac);
(* *** Goal "2.2.2.2" *** *)
a(∂_tac¨ﬁ{y|∂ x∑ x ç W' ± y = U x}Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(LIST_DROP_NTH_ASM_T [3] all_asm_fc_tac);
a(LIST_DROP_NTH_ASM_T [2, 4] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2.2.2.2" *** *)
a(ante_tac (list_µ_elim[¨UÆ, ¨W'Æ] finite_image_thm) THEN asm_rewrite_tac[] THEN strip_tac);
a(bc_thm_tac ﬁ_finite_thm THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(all_asm_fc_tac[]);
(* *** Goal "2.2.2.2.3" *** *)
a(MERGE_PCS_T1 ["'bin_rel", "sets_ext1"] REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [4] (PC_T1"sets_ext1" all_fc_tac));
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(∂_tac¨s'Æ THEN REPEAT strip_tac);
a(∂_tac¨U sÆ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
pop_thm()
));


val compact_sequentially_compact_lemma = (* not saved *) snd ( "compact_sequentially_compact_lemma", (
set_goal([], ¨µW s∑
	W ç Finite
±	(µm:Ó∑s m ç ﬁW)
¥	∂A∑A ç W ± µm∑∂n∑m º n ± s n ç A
Æ);
a(REPEAT strip_tac);
a(lemma_tac ¨µV s∑
	V ç Finite
±	(µm:Ó∑s m ç ﬁV)
±	V Ä W
¥	∂A∑A ç W ± µm∑∂n∑m º n ± s n ç A
Æ);
(* *** Goal "1" *** *)
a(REPEAT strip_tac THEN POP_ASM_T ante_tac THEN POP_ASM_T ante_tac);
a(intro_µ_tac(¨s'Æ, ¨s'Æ));
a(finite_induction_tac¨VÆ THEN
	rewrite_tac[ﬁ_enum_set_clauses,
		pc_rule1"sets_ext1" prove_rule[]¨µu v∑ﬁ(u ¿ v) = ﬁu ¿ ﬁvÆ]);
a(REPEAT strip_tac);
a(cases_tac¨µ m∑ ∂ n∑ m º n ± s' n ç xÆ);
(* *** Goal "1.1" *** *)
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 2 ante_tac THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(POP_ASM_T bc_thm_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.2" *** *)
a(DROP_NTH_ASM_T 5 (ante_tac o µ_elim¨Ãn∑s'(m + n)Æ));
a(ALL_FC_T rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a ¿ b Ä c ¥ b Ä cÆ]);
a(LEMMA_T ¨µ m'∑ s' (m + m') ç ﬁ VÆ rewrite_thm_tac THEN1 µ_tac);
(* *** Goal "1.2.1" *** *)
a(bc_thm_tac (pc_rule1"sets_ext1" prove_rule[]¨µa b y∑≥y ç a ± y ç a ¿ b ¥ y ç bÆ));
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
a(spec_nth_asm_tac 1 ¨m + m'Æ);
(* *** Goal "1.2.2" *** *)
a(REPEAT strip_tac THEN ∂_tac¨AÆ THEN REPEAT strip_tac);
a(spec_nth_asm_tac 1 ¨m'Æ);
a(∂_tac¨m + nÆ THEN asm_rewrite_tac[]);
a(PC_T1 "lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 1 (ante_tac o µ_elim¨WÆ) THEN rewrite_tac[] THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
a(∂_tac¨AÆ THEN asm_rewrite_tac[]);
pop_thm()
));


val compact_sequentially_compact_thm = save_thm ( "compact_sequentially_compact_thm", (
set_goal([], ¨µ‘ X s∑
	‘ ç Topology
±	X ç ‘ Compact
±	(µm:Ó∑s m ç X)
¥	∂x∑x ç X ± (µA∑A ç ‘ ± x ç A ¥ µm∑∂n∑m º n ± s n ç A)
Æ);
a(rewrite_tac[compact_def] THEN contr_tac);
a(lemma_tac¨X Ä ﬁ{A | A ç ‘ ± ∂x∑x ç A ± x ç X ± ∂m∑µn∑m º n ¥ ≥s n ç A}Æ);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac);
a(spec_nth_asm_tac 2 ¨xÆ);
a(∂_tac¨AÆ THEN asm_rewrite_tac[]);
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
a(∂_tac¨mÆ THEN REPEAT strip_tac);
a(spec_nth_asm_tac 2 ¨nÆ);
(* *** Goal "2" *** *)
a(lemma_tac¨{A | A ç ‘ ± ∂x∑x ç A ± x ç X ± ∂m∑µn∑m º n ¥ ≥s n ç A} Ä ‘Æ
	THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(lemma_tac¨µm∑s m ç ﬁWÆ THEN1
	all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a Ä b ± (µ m∑ s m ç a) ¥ (µ m∑ s m ç b)Æ]);
a(all_fc_tac[compact_sequentially_compact_lemma]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µy a b∑y ç a ± a Ä b ¥ y ç bÆ]);
a(spec_nth_asm_tac 5 ¨mÆ);
a(LIST_DROP_NTH_ASM_T [3] all_asm_fc_tac);
pop_thm()
));


val connected_topological_thm = save_thm ( "connected_topological_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
¥	(X ç ‘ Connected § X ç (X ÚâT ‘) Connected)Æ);
a(rewrite_tac[connected_def] THEN PC_T1 "sets_ext1" REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T1 fc_§_canon rewrite_tac[subspace_topology_space_t_thm]);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a Ä a ° b § a Ä bÆ]);
a(rewrite_tac[subspace_topology_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1);
a(lemma_tac¨X Ä B'  ¿ B''Æ THEN1
	(GET_NTH_ASM_T 3 ante_tac THEN  PC_T1 "sets_ext" prove_tac[]));
a(DROP_NTH_ASM_T 3 ante_tac THEN
	rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a ° (b ° a) ° c ° a = a ° b ° cÆ]);
a(REPEAT strip_tac);
a(lemma_tac¨≥X Ä B' Æ THEN1
	(GET_NTH_ASM_T 3 ante_tac THEN  PC_T1 "sets_ext" prove_tac[]));
a(all_asm_fc_tac[]);
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext" prove_tac[]);
(* *** Goal "2" *** *)
a(list_spec_nth_asm_tac 6 [¨B ° XÆ, ¨C ° XÆ]);
(* *** Goal "2.1" *** *)
a(list_spec_nth_asm_tac 1 [¨BÆ]);
(* *** Goal "2.2" *** *)
a(list_spec_nth_asm_tac 1 [¨CÆ]);
(* *** Goal "2.3" *** *)
a(i_contr_tac THEN LIST_DROP_NTH_ASM_T [1, 4] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.4" *** *)
a(i_contr_tac THEN LIST_DROP_NTH_ASM_T [1, 3] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.5" *** *)
a(i_contr_tac THEN LIST_DROP_NTH_ASM_T [1, 2] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.6" *** *)
a(LIST_DROP_NTH_ASM_T [1] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val connected_closed_thm = save_thm ( "connected_closed_thm", (
set_goal([], ¨µ‘ X∑
	‘ Connected =
	{A |A Ä SpaceâT ‘ ± µ B C ∑ B ç ‘ Closed ± C ç ‘ Closed ± A Ä B ¿ C ± A ° B ° C = {} ¥ A Ä B ≤ A Ä C}Æ);
a(REPEAT strip_tac THEN rewrite_tac[connected_def, closed_def]);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1 THEN rename_tac[(¨B'Æ, "c"), (¨B''Æ, "b")]);
a(DROP_NTH_ASM_T 2 ante_tac);
a(rewrite_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µA B C∑ (A \ B) ° (A \ C) = A \ (B ¿ C)Æ]
	THEN strip_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µS U X∑ X Ä S ± X ° (S \ U) = {} ¥ X Ä UÆ]);
a(DROP_NTH_ASM_T 4 ante_tac);
a(rewrite_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µA B C∑ (A \ B) ¿ (A \ C) = A \ (B ° C)Æ]
	THEN strip_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µS I X∑ X Ä S \ I  ¥ X ° I = {}Æ]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µS X∑ X Ä S \ (c ° b) ± ≥X Ä S \ c ¥ ≥X Ä bÆ]);
a(list_spec_nth_asm_tac 9 [¨cÆ, ¨bÆ]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µS X∑ X Ä S \ (c ° b) ± X Ä  c ¥ X Ä S \ bÆ]);
(* *** Goal "2" *** *)
a(LEMMA_T¨x Ä SpaceâT ‘ \ (B ° C)Æ ante_tac THEN1
	(LIST_GET_NTH_ASM_T [2, 7] (MAP_EVERY ante_tac)
		THEN PC_T1 "sets_ext1" prove_tac[]));
a(rewrite_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µA B C∑A \ (B ° C) =  (A \ B) ¿ (A \ C) Æ]
	THEN strip_tac);
a(LEMMA_T¨x ° (SpaceâT ‘ \ (B ¿ C)) = {}Æ ante_tac THEN1
	(LIST_GET_NTH_ASM_T [4, 8] (MAP_EVERY ante_tac)
		THEN PC_T1 "sets_ext1" prove_tac[]));
a(rewrite_tac[pc_rule1 "sets_ext1" prove_rule [] ¨µA B C∑A \ (B ¿ C) =  (A \ B) ° (A \ C) Æ]
	THEN strip_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule []
	¨µS∑ x Ä S ± ≥x Ä B ± x Ä B ¿ C ¥ ≥x Ä S \ CÆ]);
a(contr_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule []
	¨µS∑ x Ä S ± ≥x Ä C ± x Ä B ¿ C ¥ ≥x Ä S \ BÆ]);
a(lemma_tac¨x Ä SpaceâT ‘ \ B ≤ x Ä SpaceâT ‘ \ CÆ);
a(DROP_NTH_ASM_T 16 bc_thm_tac);
a(asm_rewrite_tac[]);
a(strip_tac THEN_LIST[∂_tac¨BÆ, ∂_tac¨CÆ] THEN REPEAT strip_tac);
pop_thm()
));


val connected_pointwise_thm = save_thm ( "connected_pointwise_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
¥	(	X ç ‘ Connected
	 § 	µx y∑ x ç X ± y ç X ¥ ∂Y∑ Y Ä X ± x ç Y ± y ç Y ± Y ç ‘ Connected)Æ);
a(REPEAT strip_tac THEN1 (∂_tac¨XÆ THEN PC_T1 "sets_ext1" asm_prove_tac[]));
a(POP_ASM_T ante_tac THEN rewrite_tac[connected_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_asm_fc_tac[]);
a(LIST_GET_NTH_ASM_T [2, 3, 4] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext" prove_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN PC_T "sets_ext1" contr_tac);
a(list_spec_nth_asm_tac 9 [¨xÆ, ¨x'Æ]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b ° c = {} ¥ a ° c = {}Æ]);
a(list_spec_nth_asm_tac 3 [¨BÆ, ¨CÆ]);
(* *** Goal "2.1" *** *)
a(LIST_GET_NTH_ASM_T [1, 7, 11] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext" prove_tac[]);
(* *** Goal "2.2" *** *)
a(LIST_GET_NTH_ASM_T [1, 6, 9] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext" prove_tac[]);
pop_thm()
));


val connected_pointwise_bc_thm = save_thm ( "connected_pointwise_bc_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
± 	(µx y∑ x ç X ± y ç X ¥ ∂Y∑ Y Ä X ± x ç Y ± y ç Y ± Y ç ‘ Connected)
¥	X ç ‘ ConnectedÆ);
a(REPEAT strip_tac THEN ALL_FC_T1 fc_§_canon once_rewrite_tac[connected_pointwise_thm]);
a(POP_ASM_T ante_tac THEN taut_tac);
pop_thm()
));


val empty_connected_thm = save_thm ( "empty_connected_thm", (
set_goal([], ¨µ‘∑ ‘ ç Topology ¥ {} ç ‘ ConnectedÆ);
a(REPEAT strip_tac THEN bc_thm_tac connected_pointwise_bc_thm);
a(asm_rewrite_tac[]);
pop_thm()
));


val singleton_connected_thm = save_thm ( "singleton_connected_thm", (
set_goal([], ¨µ‘ x∑ ‘ ç Topology ± x ç SpaceâT ‘ ¥ {x} ç ‘ ConnectedÆ);
a(REPEAT strip_tac THEN rewrite_tac[connected_def, enum_set_clauses]);
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val image_connected_thm = save_thm ( "image_connected_thm", (
set_goal([], ¨µf X ” ‘∑
	f ç (”, ‘) Continuous
±	X ç ” Connected
±	” ç Topology
±	‘ ç Topology
¥	{y | ∂x∑ x ç X ± y = f x} ç ‘ Connected
Æ);
a(rewrite_tac[connected_def, continuous_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac );
a(all_var_elim_asm_tac1 THEN PC_T1 "sets_ext1" all_asm_fc_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(contr_tac);
a(LIST_DROP_NTH_ASM_T [11] all_fc_tac);
a(GET_NTH_ASM_T 12 (PC_T1 "sets_ext1" strip_asm_tac));
a(lemma_tac¨
	X Ä {x|x ç SpaceâT ” ± f x ç B} ¿ {x|x ç SpaceâT ” ± f x ç C}
Æ THEN1 (PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
		THEN_TRY SOLVED_T (all_asm_fc_tac[])));
(* *** Goal "2.1" *** *)
a(swap_nth_asm_concl_tac 9 THEN PC_T "sets_ext1" strip_tac);
a(REPEAT strip_tac THEN ∂_tac¨f xÆ THEN REPEAT strip_tac);
a(∂_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(lemma_tac¨
	X ° {x|x ç SpaceâT ” ± f x ç B} ° {x|x ç SpaceâT ” ± f x ç C} = {}
Æ THEN1 (PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac));
(* *** Goal "2.2.1" *** *)
a(swap_nth_asm_concl_tac 11 THEN PC_T "sets_ext1" strip_tac);
a(REPEAT strip_tac THEN ∂_tac¨f xÆ);
a(rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2" *** *)
a(LEMMA_T ¨X Ä {x|x ç SpaceâT ” ± f x ç B} ≤ X Ä {x|x ç SpaceâT ” ± f x ç C}Æ ante_tac);
(* *** Goal "2.2.2.1" *** *)
a(DROP_NTH_ASM_T 14 bc_thm_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(swap_nth_asm_concl_tac 8);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.2.2.2" *** *)
a(swap_nth_asm_concl_tac 7);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
pop_thm()
));


val ¿_connected_thm = save_thm ( "¿_connected_thm", (
set_goal([], ¨µC D ”∑
	” ç Topology
±	C ç ” Connected
±	D ç ” Connected
±	≥C ° D = {}
¥	C ¿ D ç ” Connected
Æ);
a(rewrite_tac[connected_def] THEN REPEAT strip_tac
	THEN1 all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä c ± b Ä c ¥ a ¿ b Ä cÆ]);
a(DROP_NTH_ASM_T 6 (PC_T1 "sets_ext1" strip_asm_tac) THEN contr_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a ¿ b Ä c ¥ a Ä c ± b Ä cÆ]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑(a ¿ b) ° c = {} ¥ a ° c = {} ± b ° c = {}Æ]);
a(list_spec_nth_asm_tac 15 [¨BÆ, ¨C'Æ] THEN list_spec_nth_asm_tac 14 [¨BÆ, ¨C'Æ]);
(* *** Goal "1" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä c ± b Ä c ¥ a ¿ b Ä cÆ]);
(* *** Goal "2" *** *)
a(ante_tac(pc_rule1 "sets_ext1" prove_rule[]
	¨x ç C ± x ç D  ± C Ä B ± D Ä C' ¥ x ç C ° B ° C'Æ));
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(ante_tac(pc_rule1 "sets_ext1" prove_rule[]
	¨x ç C ± x ç D  ± C Ä C' ± D Ä B ¥ x ç C ° B ° C'Æ));
a(asm_rewrite_tac[]);
(* *** Goal "4" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä c ± b Ä c ¥ a ¿ b Ä cÆ]);
pop_thm()
));


val product_connected_thm = save_thm ( "product_connected_thm", (
set_goal([], ¨µX : 'a SET; Y : 'b SET; ” ‘ ∑
	X ç ” Connected
±	Y ç ‘ Connected
±	” ç Topology
±	‘ ç Topology
¥	(X ∏ Y) ç (” ∏âT ‘) ConnectedÆ);
a(REPEAT strip_tac);
a(lemma_tac ¨(” ∏âT ‘) ç TopologyÆ THEN1 basic_topology_tac[]);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[connected_pointwise_thm]);
a(REPEAT strip_tac);
a(lemma_tac¨
	(∂H∑ H ç (” ∏âT ‘) Connected ± x ç H ± (Fst y, Snd x) ç H ± H Ä (X ∏ Y))
±	(∂V∑ V ç (” ∏âT ‘) Connected ± y ç V ± (Fst y, Snd x) ç V ± V Ä (X ∏ Y))Æ
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(∂_tac¨{ab | ∂a∑ a ç X ± ab = (Ãa∑(a, Snd x)) a}Æ THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(bc_thm_tac image_connected_thm);
a(∂_tac¨”Æ THEN REPEAT strip_tac);
a(bc_thm_tac left_product_inj_continuous_thm THEN REPEAT strip_tac);
a(POP_ASM_T discard_tac THEN POP_ASM_T (ante_tac o rewrite_rule[∏_def]));
a(DROP_NTH_ASM_T 4 (strip_asm_tac o rewrite_rule[connected_def]));
a(POP_ASM_T discard_tac THEN POP_ASM_T ante_tac
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.2" *** *)
a(∂_tac ¨Fst xÆ THEN rewrite_tac[]);
a(POP_ASM_T discard_tac THEN POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
(* *** Goal "1.3" *** *)
a(∂_tac ¨Fst yÆ THEN rewrite_tac[]);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
(* *** Goal "1.4" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN rewrite_tac[∏_def] THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 3 (strip_asm_tac o rewrite_rule[∏_def]) THEN taut_tac);
(* *** Goal "2" *** *)
a(∂_tac¨{ab | ∂b∑ b ç Y ± ab = (Ãb∑(Fst y, b)) b}Æ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_thm_tac image_connected_thm);
a(∂_tac¨‘Æ THEN REPEAT strip_tac);
a(bc_thm_tac right_product_inj_continuous_thm THEN REPEAT strip_tac);
a(POP_ASM_T (ante_tac o rewrite_rule[∏_def]));
a(DROP_NTH_ASM_T 6 (strip_asm_tac o rewrite_rule[connected_def]));
a(POP_ASM_T discard_tac THEN POP_ASM_T ante_tac
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2" *** *)
a(∂_tac ¨Snd yÆ THEN rewrite_tac[]);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
(* *** Goal "2.3" *** *)
a(∂_tac ¨Snd xÆ THEN rewrite_tac[]);
a(POP_ASM_T discard_tac THEN POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
(* *** Goal "2.4" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN rewrite_tac[∏_def] THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 2 (strip_asm_tac o rewrite_rule[∏_def]) THEN taut_tac);
(* *** Goal "3" *** *)
a(lemma_tac ¨H ¿ V Ä (X ∏ Y)Æ THEN1
	all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa b c∑a Ä c ± b Ä c ¥ a ¿ b Ä cÆ]);
a(∂_tac¨H ¿ VÆ THEN REPEAT strip_tac);
a(bc_thm_tac ¿_connected_thm);
a(REPEAT strip_tac THEN PC_T "sets_ext1" contr_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val ¿_open_connected_thm = save_thm ( "¿_open_connected_thm", (
set_goal([], ¨µA B ”∑
	A ç ”
±	≥A = {}
±	B ç ”
±	≥B = {}
±	A ¿ B ç ” Connected
¥	≥A ° B = {}
Æ);
a(rewrite_tac[connected_def] THEN contr_tac);
a(DROP_NTH_ASM_T 2 (ante_tac o list_µ_elim[¨AÆ, ¨BÆ]));
a(asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [2, 4, 6] discard_tac THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val ¿_closed_connected_thm = save_thm ( "¿_closed_connected_thm", (
set_goal([], ¨µA B ”∑
	A ç ” Closed
±	≥A = {}
±	B ç ” Closed
±	≥B = {}
±	A ¿ B ç ” Connected
¥	≥A ° B = {}
Æ);
a(rewrite_tac[connected_closed_thm] THEN contr_tac);
a(DROP_NTH_ASM_T 2 (ante_tac o list_µ_elim[¨AÆ, ¨BÆ]));
a(asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [2, 4, 6] discard_tac THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val ¿_¿_connected_thm = save_thm ( "¿_¿_connected_thm", (
set_goal([], ¨µC D E ”∑
	” ç Topology
±	C ç ” Connected
±	D ç ” Connected
±	E ç ” Connected
±	≥C ° D = {}
±	≥D ° E = {}
¥	C ¿ D ¿ E ç ” Connected
Æ);
a(REPEAT strip_tac THEN REPEAT (bc_thm_tac ¿_connected_thm THEN REPEAT strip_tac));
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val cover_connected_thm = save_thm ( "cover_connected_thm", (
set_goal([], ¨µC U ”∑
	” ç Topology
±	C ç ” Connected
±	U Ä ” Connected
±	C Ä ﬁU
¥	ﬁ{D | D ç U ± ≥C ° D = {}} ç ” Connected
Æ);
a(REPEAT strip_tac THEN bc_thm_tac connected_pointwise_bc_thm THEN REPEAT strip_tac);
a(GET_NTH_ASM_T 7 (PC_T1 "sets_ext1" strip_asm_tac));
a(GET_NTH_ASM_T 9 (PC_T1 "sets_ext1" strip_asm_tac));
a(∂_tac¨s ¿ C ¿ s'Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(LIST_GET_NTH_ASM_T [3] all_fc_tac);
a(∂_tac¨s''Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(∂_tac¨x'Æ THEN REPEAT strip_tac);
(* *** Goal "3" *** *)
a(∂_tac¨s'Æ THEN REPEAT strip_tac);
(* *** Goal "4" *** *)
a(bc_thm_tac ¿_¿_connected_thm THEN REPEAT strip_tac
	THEN_TRY (SOLVED_T (all_asm_fc_tac[])));
a(GET_NTH_ASM_T 6 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val separation_thm = save_thm ( "separation_thm", (
set_goal([], ¨µ‘ C D∑
	‘ ç Topology
±	C ç ‘ Connected
±	D ç ‘ Connected
±	≥C ¿ D ç ‘ Connected
¥	∂A B∑	A ç ‘ ± B ç ‘ ± (C ¿ D) ° A ° B = {}
	±	C Ä A
	±	D Ä B
Æ);
a(rewrite_tac[connected_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(i_contr_tac THEN
	LIST_GET_NTH_ASM_T[1, 3, 5] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨C Ä B ¿ C' ± C ° B ° C' = {}Æ THEN1
	(LIST_GET_NTH_ASM_T[3, 4] (MAP_EVERY ante_tac)
		THEN PC_T1 "sets_ext1" prove_tac[]));
a(lemma_tac¨D Ä B ¿ C' ± D ° B ° C' = {}Æ THEN1
	(LIST_GET_NTH_ASM_T[5, 6] (MAP_EVERY ante_tac)
		THEN PC_T1 "sets_ext1" prove_tac[]));
a(LEMMA_T ¨C Ä B ≤ C Ä C'Æ ante_tac THEN1
	(DROP_NTH_ASM_T 13 bc_thm_tac THEN REPEAT strip_tac));
a(LEMMA_T ¨D Ä B ≤ D Ä C'Æ ante_tac THEN1
	(DROP_NTH_ASM_T 11 bc_thm_tac THEN REPEAT strip_tac));
a(REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(i_contr_tac THEN
	LIST_GET_NTH_ASM_T[1, 2, 8] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2" *** *)
a(∂_tac¨C'Æ THEN ∂_tac¨BÆ THEN REPEAT strip_tac);
a(GET_NTH_ASM_T 9 ante_tac THEN PC_T1"sets_ext1" prove_tac[]);
(* *** Goal "2.3" *** *)
a(∂_tac¨BÆ THEN ∂_tac¨C'Æ THEN REPEAT strip_tac);
(* *** Goal "2.4" *** *)
a(i_contr_tac THEN
	LIST_GET_NTH_ASM_T[1, 2, 7] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val finite_separation_thm = save_thm ( "finite_separation_thm", (
set_goal([], ¨µ‘ U A∑
	‘ ç Topology
±	U ç Finite
±	≥{} ç U
±	U Ä ‘ Connected
±	A ç U
±	(µB∑B ç U ± ≥A = B ¥ ≥A ¿ B ç ‘ Connected)
¥	∂C D∑	C ç ‘ ± D ç ‘ 
	±	A Ä C ± ﬁ(U \ {A}) Ä D
	±	ﬁU ° C ° D = {}
Æ);
a(REPEAT strip_tac);
a(cases_tac¨µb∑b ç U ¥ A = bÆ);
(* *** Goal "1" *** *)
a(∂_tac¨SpaceâT ‘Æ THEN ∂_tac¨{}Æ);
a(ALL_FC_T rewrite_tac[space_t_open_thm, empty_open_thm]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx u t∑x ç u ± u Ä t ¥ x ç tÆ]);
a(REPEAT strip_tac THEN1
	(POP_ASM_T ante_tac THEN rewrite_tac[connected_def]
	THEN PC_T1 "sets_ext1" prove_tac[]));
a(PC_T1"sets_ext1" REPEAT strip_tac
	THEN all_asm_fc_tac[] THEN all_var_elim_asm_tac1);
(* *** Goal "2" *** *)
a(lemma_tac¨∂f∑µb∑b ç U ± ≥A = b ¥
	Fst (f b) ç ‘ ± Snd (f b) ç ‘ ±
	A Ä Fst (f b) ± b Ä Snd (f b) ±
	(A ¿ b) ° Fst (f b) ° Snd (f b) = {}Æ);
(* *** Goal "2.1" *** *)
a(prove_∂_tac THEN REPEAT strip_tac);
a(cases_tac¨b' ç U ± ≥ A = b'Æ THEN asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T[3, 4, 5] all_fc_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx u t∑x ç u ± u Ä t ¥ x ç tÆ]);
a(all_fc_tac[separation_thm]);
a(∂_tac¨(A', B)Æ THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(∂_tac¨•{X | ∂b∑b ç U ± ≥A = b ± X = Fst(f b)}Æ);
a(∂_tac¨ﬁ{Y | ∂b∑b ç U ± ≥A = b ± Y = Snd(f b)}Æ);
a(REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(bc_thm_tac finite_•_open_thm THEN REPEAT strip_tac);
(* *** Goal "2.2.1.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.1.2" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN rewrite_tac[]);
a(∂_tac¨Fst(f b)Æ THEN ∂_tac¨bÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1.3" *** *)
a(GET_NTH_ASM_T 8 ante_tac THEN DROP_ASMS_T discard_tac
	THEN REPEAT strip_tac THEN finite_induction_tac¨UÆ);
(* *** Goal "2.2.1.3.1" *** *)
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨{a|F} = {}Æ,
	empty_finite_thm]);
(* *** Goal "2.2.1.3.2" *** *)
a(cases_tac¨A = xÆ THEN1 all_var_elim_asm_tac);
(* *** Goal "2.2.1.3.2.1" *** *)
a(LEMMA_T¨{X|∂ b∑ b ç {x} ¿ U ± ≥ x = b ± X = Fst (f b)}
            = {X|∂ b∑ b ç U ± ≥ x = b ± X = Fst (f b)}Æ
	asm_rewrite_thm_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
(* *** Goal "2.2.1.3.2.1.1" *** *)
a(∂_tac¨bÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1.3.2.1.2" *** *)
a(∂_tac¨bÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1.3.2.2" *** *)
a(LEMMA_T¨{X|∂ b∑ b ç {x} ¿ U ± ≥ A = b ± X = Fst (f b)}
            = {Fst(f x)} ¿ {X|∂ b∑ b ç U ± ≥ A = b ± X = Fst (f b)}Æ
	asm_rewrite_thm_tac THEN_LIST
	[id_tac,
	bc_thm_tac singleton_¿_finite_thm
		THEN REPEAT strip_tac]);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
(* *** Goal "2.2.1.3.2.2.1" *** *)
a(∂_tac¨bÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1.3.2.2.2" *** *)
a(∂_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.1.3.2.2.1" *** *)
a(∂_tac¨bÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2" *** *)
a(bc_thm_tac ﬁ_open_thm THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
(* *** Goal "2.2.3" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
a(LIST_GET_NTH_ASM_T[10, 15] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2.4" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(POP_ASM_T (strip_asm_tac o conv_rule(RAND_C eq_sym_conv)));
a(all_asm_fc_tac[]);
a(∂_tac¨Snd(f s)Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.4.1" *** *)
a(LIST_GET_NTH_ASM_T[9, 15] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2.4.2" *** *)
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.5" *** *)
a(PC_T "sets_ext1"  strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
a(cases_tac¨A = sÆ THEN1 (POP_ASM_T (asm_tac o eq_sym_rule) THEN all_var_elim_asm_tac1));
(* *** Goal "2.2.5.1" *** *)
a(LIST_DROP_NTH_ASM_T [6, 7, 8] all_asm_fc_tac);
a(LIST_GET_NTH_ASM_T[1, 3, 9, 11] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2.5.2" *** *)
a(DROP_NTH_ASM_T 5 (ante_tac o µ_elim¨Fst (f s)Æ));
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "2.2.5.2.1" *** *)
a(∂_tac¨sÆ THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2, 3, 7, 8, 9] all_asm_fc_tac);
a(LIST_GET_NTH_ASM_T[1, 2,  10] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val connected_extension_thm = save_thm ( "connected_extension_thm", (
set_goal([], ¨µ‘ U B∑
	‘ ç Topology
±	U ç Finite
±	≥{} ç U
±	U Ä ‘ Connected
±	B ç ‘ Connected
±	ﬁU ¿ B ç ‘ Connected
±	≥ﬁU Ä B
¥	∂A∑ A ç U ± A ¿ B ç ‘ Connected ± ≥A Ä B
Æ);
a(REPEAT strip_tac);
a(cases_tac¨B = {}Æ);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 2 ante_tac THEN
	asm_rewrite_tac[] THEN PC_T "sets_ext1" strip_tac);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx u t∑x ç u ± u Ä t ¥ x ç tÆ]);
a(cases_tac¨s = {}Æ THEN1 all_var_elim_asm_tac1);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(contr_tac);
a(PC_T1 "predicates" lemma_tac¨
	{B} ¿ ({C | C ç U ± ≥C Ä B}) ç Finite
±	≥{} ç {B} ¿ ({C | C ç U ± ≥C Ä B})
±	{B} ¿ ({C | C ç U ± ≥C Ä B}) Ä ‘ Connected
±	B ç {B} ¿ ({C | C ç U ± ≥C Ä B})
±	(µ C∑ C ç {B} ¿ ({C | C ç U ± ≥C Ä B})
		± ≥ B = C ¥ ≥ B ¿ C ç ‘ Connected)Æ
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_thm_tac singleton_¿_finite_thm);
a(bc_thm_tac Ä_finite_thm THEN ∂_tac¨UÆ THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(swap_nth_asm_concl_tac 2 THEN asm_rewrite_tac[]);
(* *** Goal "2.3" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN1 asm_rewrite_tac[]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx u t∑x ç u ± u Ä t ¥ x ç tÆ]);
(* *** Goal "2.4" *** *)
a(all_var_elim_asm_tac1);
(* *** Goal "2.5" *** *)
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µA∑A ¿ C = C ¿ AÆ]);
a(contr_tac THEN spec_nth_asm_tac 5 ¨CÆ);
(* *** Goal "2.6" *** *)
a(all_fc_tac[finite_separation_thm]);
a(swap_nth_asm_concl_tac 14 THEN rewrite_tac[connected_def]
	THEN REPEAT strip_tac);
a(i_contr_tac THEN POP_ASM_T ante_tac);
a(rewrite_tac[] THEN strip_tac THEN
	∂_tac¨CÆ THEN asm_rewrite_tac[]);
a(strip_tac THEN ∂_tac¨DÆ THEN asm_rewrite_tac[]);
a(lemma_tac ¨ﬁ ({B} ¿  {C|C ç U ± ≥C Ä B}) = ﬁU ¿ BÆ);
(* *** Goal "2.6.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "2.6.1.1" *** *)
a(all_var_elim_asm_tac);
(* *** Goal "2.6.1.2" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2.6.1.3" *** *)
a(cases_tac¨x ç BÆ  THEN1 (∂_tac¨BÆ THEN REPEAT strip_tac));
a(∂_tac¨sÆ THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T[2, 4] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.6.1.4" *** *)
a(∂_tac¨BÆ THEN REPEAT strip_tac);
(* *** Goal "2.6.2" *** *)
a(DROP_NTH_ASM_T 2 ante_tac THEN asm_rewrite_tac[] THEN strip_tac);
a(asm_rewrite_tac[]);
a(LEMMA_T ¨ﬁ U ¿ B Ä C ¿ DÆ rewrite_thm_tac);
(* *** Goal "2.6.2.1" *** *)
a(LEMMA_T ¨ﬁ U ¿ B = ﬁ (({B} ¿ {C|C ç U ± ≥ C Ä B}) \ {B}) ¿ BÆ rewrite_thm_tac);
(* *** Goal "2.6.2.1.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "2.6.2.1.1.1" *** *)
a(swap_nth_asm_concl_tac 1 THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN REPEAT strip_tac);
(* *** Goal "2.6.2.1.1.1.1" *** *)
a(LIST_GET_NTH_ASM_T[2, 4] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.6.2.1.1.1.2" *** *)
a(contr_tac THEN all_var_elim_asm_tac1);
(* *** Goal "2.6.2.1.1.2" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2.6.2.1.2" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µs v c d∑ v Ä c ± s Ä d ¥ s ¿ v Ä c ¿ dÆ]);
(* *** Goal "2.6.2.2" *** *)
a(contr_tac);
(* *** Goal "2.6.2.2.1" *** *)
a(LIST_DROP_NTH_ASM_T [1, 2, 3, 4, 15] (MAP_EVERY (PC_T1 "sets_ext1" strip_asm_tac)));
a(spec_nth_asm_tac 4 ¨xÆ);
(* *** Goal "2.6.2.2.1.1" *** *)
a(spec_nth_asm_tac 1 ¨sÆ);
(* *** Goal "2.6.2.2.1.1.1" *** *)
a(LIST_GET_NTH_ASM_T[1, 4, 6] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.6.2.2.1.1.2" *** *)
a(LIST_GET_NTH_ASM_T[1, 3, 5] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.6.2.2.1.2" *** *)
a(lemma_tac¨x ç CÆ THEN1 GET_NTH_ASM_T 8 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "2.6.2.2.1.2.1" *** *)
a(spec_nth_asm_tac 1 ¨sÆ);
(* *** Goal "2.6.2.2.1.2.2" *** *)
a(spec_nth_asm_tac 8 ¨xÆ);
(* *** Goal "2.6.2.2.1.2.2.1" *** *)
a(spec_nth_asm_tac 1 ¨sÆ);
(* *** Goal "2.6.2.2.1.2.2.2" *** *)
a(spec_nth_asm_tac 3 ¨s'Æ);
(* *** Goal "2.6.2.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [1, 2, 3, 4, 5, 14] (MAP_EVERY (PC_T1 "sets_ext1" strip_asm_tac)));
a(spec_nth_asm_tac 6 ¨xÆ);
a(spec_nth_asm_tac 3 ¨xÆ);
a(spec_nth_asm_tac 7 ¨xÆ);
pop_thm()
));


set_goal([], ¨µV A B∑V Ä {A} ¿ {B} ¥ V = {} ≤ V = {A} ≤ V = {B} ≤ V = {A} ¿ {B}Æ);
a(PC_T1"sets_ext1"  rewrite_tac[]);
a(contr_tac THEN_TRY all_var_elim_asm_tac1
	THEN  asm_fc_tac[] THEN_TRY all_var_elim_asm_tac1);
val Ä_doubleton_lemma = pop_thm();

set_goal([], ¨µL B∑ B ç Elems L ¥ B Ä ﬁ(Elems L)Æ);
a(µ_tac);
a(list_induction_tac¨LÆ THEN asm_rewrite_tac[elems_def,
	enum_set_clauses,
	pc_rule1"sets_ext1" prove_rule[]
		¨µu v∑ ﬁ(u ¿ v) = ﬁu ¿ ﬁ vÆ]);
a(REPEAT strip_tac THEN1 all_var_elim_asm_tac);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(all_asm_fc_tac[] THEN PC_T1 "sets_ext1" asm_prove_tac[]);
val Ä_ﬁ_elems_lemma = pop_thm();


set_goal([], ¨ µ‘ U A∑
	‘ ç Topology
±	U ç Finite
±	≥{} ç U
±	U Ä ‘ Connected
±	ﬁU ç ‘ Connected
±	A ç U
¥	∂L∑	L 0 = [A]
±	(µm∑ 	Elems (L m) Ä U)
±	(µm∑ 	ﬁ(Elems (L m)) ç ‘ Connected)
±	(µm∑ 	if	≥ﬁU Ä ﬁ(Elems (L m))
		then	∂B∑	B ç U
			±	B ¿ ﬁ(Elems (L m)) ç ‘ Connected
			±	≥B Ä ﬁ(Elems (L m))
			±	L(m + 1) = Cons B (L m)
		else	L (m + 1) = L m)
±	(µm∑ 	L m ç Distinct)
Æ);
a(REPEAT strip_tac);
a(once_rewrite_tac[taut_rule¨µp1 p2 p3 p4 p5∑
	p1 ± p2 ± p3 ± p4 ± p5 §
	p1 ± p2 ± p3 ± p4 ± (p4 ¥ p5)Æ]);
a(lemma_tac ¨∂f∑
	µV∑
	if	V ç ‘ Connected
	±	V Ä ﬁU
 	±	≥ ﬁ U Ä V
	then	f V ç U
	±	f V ¿ V ç ‘ Connected
	±	≥ f V Ä V
	else	f V = {}Æ
	THEN1 prove_∂_tac);
(* *** Goal "1" *** *)
a(REPEAT strip_tac THEN
	cases_tac¨V' ç ‘ Connected ± V' Ä ﬁU ± ≥ ﬁU Ä V'Æ
	THEN asm_rewrite_tac[] THEN_TRY prove_∂_tac);
a(bc_thm_tac connected_extension_thm THEN REPEAT strip_tac);
a(ALL_FC_T asm_rewrite_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µu v∑ v Ä u ¥ u ¿ v = uÆ]);
(* *** Goal "2" *** *)
a(lemma_tac ¨∂L∑
	L 0  = [A]
±	µm∑ L (m + 1) =
		if 	≥f(ﬁ(Elems(L m))) = {}
		then	Cons (f(ﬁ(Elems(L m)))) (L m)
		else	L mÆ
	THEN1 prove_∂_tac);
a(lemma_tac¨µ m∑ Elems (L m) Ä UÆ);
(* *** Goal "2.1" *** *)
a(REPEAT strip_tac THEN induction_tac¨m:ÓÆ
	THEN asm_rewrite_tac[elems_def]);
(* *** Goal "2.1.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac);
(* *** Goal "2.1.2" *** *)
a(cases_tac¨f (ﬁ (Elems (L m))) = {}Æ THEN
	asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 5 (ante_tac o µ_elim¨ﬁ (Elems (L m))Æ));
a(cases_tac¨ﬁ (Elems (L m)) ç ‘ Connected
	± ﬁ (Elems (L m)) Ä ﬁ U
	± ≥ ﬁ U Ä ﬁ (Elems (L m))Æ THEN asm_rewrite_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[elems_def]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx b c∑x ç c ± b Ä c ¥ {x} ¿ b Ä cÆ]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨µ m∑ ﬁ (Elems (L m)) ç ‘ ConnectedÆ);
(* *** Goal "2.2.1" *** *)
a(REPEAT strip_tac THEN induction_tac¨m:ÓÆ
	THEN asm_rewrite_tac[elems_def, enum_set_clauses]);
(* *** Goal "2.2.1.1" *** *)
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µx b c∑x ç b ± b Ä c ¥ x ç cÆ]);
(* *** Goal "2.2.1.2" *** *)
a(cases_tac¨f (ﬁ (Elems (L m))) = {}Æ THEN
	asm_rewrite_tac[]);
a(rewrite_tac[elems_def,
	enum_set_clauses,
	pc_rule1"sets_ext1" prove_rule[]
		¨µu v∑ ﬁ(u ¿ v) = ﬁu ¿ ﬁ vÆ]);
a(DROP_NTH_ASM_T 6 (ante_tac o µ_elim¨ﬁ (Elems (L m))Æ));
a(cases_tac¨ﬁ (Elems (L m)) ç ‘ Connected
	± ﬁ (Elems (L m)) Ä ﬁ U
	± ≥ ﬁ U Ä ﬁ (Elems (L m))Æ THEN asm_rewrite_tac[]);
a(taut_tac);
(* *** Goal "2.2.2" *** *)
a(∂_tac¨LÆ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "2.2.2.3" *** *)
a(DROP_NTH_ASM_T 6 (ante_tac o µ_elim¨ﬁ (Elems (L m))Æ));
a(lemma_tac¨Elems(L m) Ä UÆ THEN asm_rewrite_tac[]);
a(ALL_FC_T asm_rewrite_tac[pc_rule1"sets_ext1" prove_rule[]
	¨µu v∑ v Ä u ¥ ﬁv Ä ﬁu Æ]);
a(REPEAT strip_tac THEN ∂_tac¨f (ﬁ (Elems (L m)))Æ
	THEN REPEAT strip_tac);
a(cases_tac¨f (ﬁ (Elems (L m))) = {}Æ THEN
	asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 ante_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.4" *** *)
a(DROP_NTH_ASM_T 6 (ante_tac o µ_elim¨ﬁ (Elems (L m))Æ));
a(asm_rewrite_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.5" *** *)
a(induction_tac¨mÆ THEN1
	asm_rewrite_tac[distinct_def, elems_def]);
a(DROP_NTH_ASM_T 2 (ante_tac o µ_elim¨mÆ));
a(cases_tac¨ﬁU Ä ﬁ(Elems (L m))Æ THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac THEN asm_rewrite_tac[]);
a(asm_rewrite_tac[distinct_def]);
a(swap_nth_asm_concl_tac 2);
a(all_fc_tac[Ä_ﬁ_elems_lemma]);
val connected_chain_lemma1 = pop_thm();

set_goal([], ¨µlist x∑ ≥list = Cons x listÆ);
a(µ_tac THEN conv_tac(ONCE_MAP_C eq_sym_conv));
a(list_induction_tac ¨listÆ THEN REPEAT strip_tac
	THEN asm_rewrite_tac[nil_cons_def]);
val cons_lemma = pop_thm();


val connected_chain_thm = save_thm ( "connected_chain_thm", (
set_goal([], ¨ µ‘ U A∑
	‘ ç Topology
±	U ç Finite
±	≥{} ç U
±	U Ä ‘ Connected
±	ﬁU ç ‘ Connected
±	A ç U
¥	∂L n∑	L 0 = [A]
±	(µm∑ 	ﬁ(Elems (L m)) ç ‘ Connected)
±	(µm∑ 	Elems (L m) Ä U)
±	(µm∑ 	m < n
	¥	∂B∑	B ç U
		±	≥B Ä ﬁ(Elems (L m))
		±	L(m + 1) = Cons B (L m))
±	ﬁU = ﬁ(Elems (L n))
±	(µm∑ 	L m ç Distinct)
Æ);
a(REPEAT strip_tac THEN all_fc_tac[connected_chain_lemma1]);
a(lemma_tac¨∂N∑ L (N + 1) = L NÆ THEN1 contr_tac);
(* *** Goal "1" *** *)
a(lemma_tac¨µm∑#(L m) = m + 1Æ THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(induction_tac¨mÆ THEN1 asm_rewrite_tac[length_def]);
a(DROP_NTH_ASM_T 4 (ante_tac o µ_elim¨mÆ));
a(cases_tac ¨ﬁ U Ä ﬁ (Elems (L m))Æ THEN asm_rewrite_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[length_def]);
(* *** Goal "1.2" *** *)
a(LEMMA_T¨#(Elems(L (#U))) = #(L (#U))Æ ante_tac THEN1
	(bc_thm_tac distinct_size_length_thm
		THEN asm_rewrite_tac[]));
a(asm_rewrite_tac[]);
a(LEMMA_T¨#(Elems(L (#U))) º #UÆ ante_tac THEN1
	(bc_thm_tac Ä_size_thm THEN asm_rewrite_tac[]));
a(PC_T1 "lin_arith" prove_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨LÆ THEN ∂_tac¨Min{n | L(n+1) = L n}Æ);
a(asm_rewrite_tac[]);
a(REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 4 (ante_tac o µ_elim¨mÆ));
a(cases_tac¨≥ ﬁ U Ä ﬁ (Elems (L m))Æ THEN asm_rewrite_tac[]
	THEN1 prove_tac[]);
a(strip_tac THEN i_contr_tac);
a(lemma_tac ¨Min {n|L (n + 1) = L n} º mÆ THEN_LIST
	[bc_thm_tac min_º_thm, PC_T1 "lin_arith" asm_prove_tac[]]);
a(REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(lemma_tac¨µm∑ﬁ(Elems(L m)) Ä ﬁUÆ THEN1
	(strip_tac THEN bc_thm_tac
	(pc_rule1 "sets_ext1" prove_rule[]
		¨µv u∑v Ä u ¥ ﬁv Ä ﬁuÆ) THEN
			asm_rewrite_tac[]));
a(asm_rewrite_tac[pc_rule1 "sets_ext1" prove_rule[]
		¨µa b∑ a = b § a Ä b ± b Ä aÆ]);
a(contr_tac);
a(lemma_tac¨Min {n|L(n + 1) = L n} ç {n|L(n + 1) = L n}Æ THEN1
	(bc_thm_tac min_ç_thm THEN
		∂_tac¨NÆ THEN REPEAT strip_tac));
a(DROP_NTH_ASM_T 6 (ante_tac o µ_elim¨Min {n|L (n + 1) = L n}Æ)
	THEN asm_rewrite_tac[cons_lemma]);
pop_thm()
));


val connected_triad_thm = save_thm ( "connected_triad_thm", (
set_goal([],¨µ‘ A B C∑
	‘ ç Topology
±	A ç ‘ Connected
±	B ç ‘ Connected
±	C ç ‘ Connected
±	A ¿ B ¿ C ç ‘ Connected
¥	A ¿ C ç ‘ Connected ≤ B ¿ C ç ‘ ConnectedÆ);
a(contr_tac);
a(swap_nth_asm_concl_tac 3 THEN rewrite_tac[connected_def] THEN strip_tac);
a(≤_right_tac THEN conv_tac (TOP_MAP_C ≥_µ_conv));
a(all_fc_tac[separation_thm]);
a(∂_tac¨A'' ¿ A'Æ THEN ∂_tac¨B'' ° B'Æ);
a(ALL_FC_T rewrite_tac[¿_open_thm, °_open_thm]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_GET_NTH_ASM_T [1, 2, 6, 7] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(LIST_GET_NTH_ASM_T [1, 2, 3, 6, 7, 8] (MAP_EVERY ante_tac)
	THEN DROP_ASMS_T discard_tac
	THEN PC_T1 "sets_ext1" prove_tac[]
	THEN REPEAT (contr_tac THEN all_asm_fc_tac[]));
(* *** Goal "3" *** *)
a(contr_tac THEN lemma_tac¨C Ä A'' ¿ A'Æ THEN1
	(POP_ASM_T ante_tac THEN  PC_T1 "sets_ext1" prove_tac[]));
a(cases_tac ¨C = {}Æ THEN1 all_var_elim_asm_tac1);
(* *** Goal "3.1" *** *)
a(swap_nth_asm_concl_tac 10 THEN1 asm_rewrite_tac[]);
(* *** Goal "3.2" *** *)
a((LIST_GET_NTH_ASM_T [1, 2, 4, 6, 9, 11] (MAP_EVERY ante_tac)
		THEN DROP_ASMS_T  discard_tac
		THEN PC_T "sets_ext1" contr_tac));
a(LIST_DROP_NTH_ASM_T [2, 3, 4, 5, 6] (MAP_EVERY (strip_asm_tac o µ_elim¨xÆ)));
(* *** Goal "4" *** *)
a(contr_tac THEN lemma_tac¨A Ä B''Æ THEN1
	(POP_ASM_T ante_tac THEN  PC_T1 "sets_ext1" prove_tac[]));
a(cases_tac ¨A = {}Æ THEN1 all_var_elim_asm_tac1);
(* *** Goal "4.1" *** *)
a(swap_nth_asm_concl_tac 12 THEN1 asm_rewrite_tac[]);
(* *** Goal "4.2" *** *)
a((LIST_GET_NTH_ASM_T [1, 2, 5, 6] (MAP_EVERY ante_tac)
		THEN DROP_ASMS_T  discard_tac
		THEN PC_T "sets_ext1" contr_tac));
a(LIST_DROP_NTH_ASM_T [2, 3, 4] (MAP_EVERY (strip_asm_tac o µ_elim¨xÆ)));
pop_thm()
));



val connected_step_thm = save_thm ( "connected_step_thm", (
set_goal([], ¨ µ‘ U; A: 'a SET∑
	‘ ç Topology
±	U ç Finite
±	U Ä ‘ Connected
±	ﬁU ç ‘ Connected
±	A ç U
¥	A = ﬁU
≤	∂B V∑
	B  ç U
±	≥B = A
±	V Ä U
±	ﬁV ç ‘ Connected
±	≥B Ä ﬁV
±	ﬁU = B ¿ ﬁV
Æ);
a(REPEAT strip_tac THEN
	PC_T1 "predicates" lemma_tac¨
	U \  {{}:'a SET}ç Finite
±	≥{} ç U \  {{}}
±	U  \  {{}} Ä ‘ Connected
±	ﬁ(U \ {{}}) = ﬁUÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac Ä_finite_thm THEN ∂_tac¨UÆ THEN REPEAT strip_tac);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a \ b Ä aÆ]);
(* *** Goal "2" *** *)
a(bc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]
	 THEN ∂_tac¨UÆ THEN REPEAT strip_tac);
a(rewrite_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b∑a \ b Ä aÆ]);
(* *** Goal "3" *** *)
a(PC_T "sets_ext1" strip_tac THEN prove_tac[]);
a(∂_tac¨sÆ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(∂_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "4" *** *)
a(lemma_tac¨ﬁ(U \ {{}}) ç ‘ ConnectedÆ THEN1 asm_rewrite_tac[]);
a(cases_tac¨A = {}Æ  THEN1 all_var_elim_asm_tac1);
(* *** Goal "4.1" *** *)
a(DROP_NTH_ASM_T 6 (PC_T1 "sets_ext1" strip_asm_tac));
a(PC_T1 "predicates" all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µx∑x ç s ± s ç U ¥ s ç U \ {{}}Æ]);
a(all_fc_tac[connected_chain_thm]);
a(strip_asm_tac(µ_elim¨nÆ Ó_cases_thm)
	THEN all_var_elim_asm_tac1);
(* *** Goal "4.1.1" *** *)
a(∂_tac¨sÆ THEN ∂_tac¨{}Æ THEN
	ALL_FC_T asm_rewrite_tac[enum_set_clauses,
			empty_connected_thm]);
a(DROP_NTH_ASM_T 2 ante_tac THEN asm_rewrite_tac[elems_def,
		enum_set_clauses]);
a(REPEAT strip_tac THEN
	GET_ASM_T ¨x ç sÆ ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "4.1.2" *** *)
a(DROP_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨iÆ));
a(∂_tac¨BÆ THEN ∂_tac¨Elems(L i)Æ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 6 ante_tac THEN asm_rewrite_tac[
	pc_rule1"sets_ext1" prove_rule[]
		¨µu v∑ﬁ(u ¿ v) = ﬁu ¿ ﬁ vÆ,
	elems_def, enum_set_clauses]);
a(REPEAT strip_tac);
a(bc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]
	 THEN ∂_tac¨U \ {{}}Æ THEN asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "4.2" *** *)
a(PC_T1 "predicates" lemma_tac¨A ç U \ {{}}Æ THEN1
	REPEAT strip_tac);
a(all_fc_tac[connected_chain_thm]);
a(strip_asm_tac(µ_elim¨nÆ Ó_cases_thm)
	THEN all_var_elim_asm_tac1);
(* *** Goal "4.2.1" *** *)
a(i_contr_tac THEN DROP_NTH_ASM_T 2 ante_tac);
a(asm_rewrite_tac[elems_def, enum_set_clauses]);
a(contr_tac THEN all_var_elim_asm_tac1);
(* *** Goal "4.2.2" *** *)
a(GET_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨iÆ));
a(∂_tac¨BÆ THEN ∂_tac¨Elems(L i)Æ THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 6 ante_tac THEN asm_rewrite_tac[
	pc_rule1"sets_ext1" prove_rule[]
		¨µu v∑ﬁ(u ¿ v) = ﬁu ¿ ﬁ vÆ,
	elems_def, enum_set_clauses]);
a(REPEAT strip_tac);
(* *** Goal "4.2.2.1" *** *)
a(contr_tac THEN all_var_elim_asm_tac);
a(GET_NTH_ASM_T 4 (ante_tac o µ_elim¨i + 1Æ));
a(GET_NTH_ASM_T 2 rewrite_thm_tac);
a(asm_rewrite_tac[distinct_def]);
a(LIST_DROP_NTH_ASM_T [5, 8] (MAP_EVERY ante_tac));
a(DROP_ASMS_T discard_tac THEN induction_tac¨iÆ
	THEN REPEAT strip_tac
	THEN_TRY asm_rewrite_tac[elems_def]);
(* *** Goal "4.2.2.1.1" *** *)
a(i_contr_tac THEN SPEC_NTH_ASM_T 1 ¨m'Æ ante_tac);
a(LEMMA_T ¨m' < (i + 1) + 1Æ rewrite_thm_tac THEN1
	PC_T1 "lin_arith" asm_prove_tac[]);
a(conv_tac ≥_∂_conv THEN asm_rewrite_tac[]);
(* *** Goal "4.2.2.1.2" *** *)
a(SPEC_NTH_ASM_T 1 ¨iÆ ante_tac);
a(LEMMA_T ¨i < (i + 1) + 1Æ rewrite_thm_tac THEN1
	PC_T1 "lin_arith" prove_tac[]);
a(REPEAT strip_tac THEN asm_rewrite_tac[elems_def]
	THEN REPEAT strip_tac);
(* *** Goal "4.2.2.2" *** *)
a(bc_tac[pc_rule1"sets_ext1" prove_rule[]¨µa b c∑a Ä b ± b Ä c ¥ a Ä cÆ]
	 THEN ∂_tac¨U \ {{}}Æ THEN asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val id_homomorphism_thm = save_thm ( "id_homomorphism_thm", (
set_goal([], ¨µ‘∑
	‘ ç Topology
¥	(Ãx∑ x) ç (‘, ‘) HomeomorphismÆ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ALL_FC_T rewrite_tac[id_continuous_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨Ãy∑ yÆ);
a(ALL_FC_T rewrite_tac[id_continuous_thm]);
pop_thm()
));


val comp_homeomorphism_thm = save_thm ( "comp_homeomorphism_thm", (
set_goal([], ¨µf g “ ” ‘∑
	f ç (“, ”) Homeomorphism
±	g ç (”, ‘) Homeomorphism
±	“ ç Topology
±	” ç Topology
±	‘ ç Topology
¥	(Ãx∑ g(f x)) ç (“, ‘) Homeomorphism
Æ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ALL_FC_T rewrite_tac [comp_continuous_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨Ãy∑ g'(g'' y)Æ);
a(ALL_FC_T rewrite_tac [comp_continuous_thm]);
a(all_asm_ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(all_asm_fc_tac[] THEN ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(all_asm_fc_tac[] THEN ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));


val product_homeomorphism_thm = save_thm ( "product_homeomorphism_thm", (
set_goal([], ¨µ f : 'a ≠ 'b; g : 'c ≠ 'd; “ : 'a SET SET; ” : 'b SET SET; ‘ : 'c SET SET; ’ : 'd SET SET∑
	f ç (“, ”) Homeomorphism
±	g ç (‘, ’) Homeomorphism
±	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	’ ç Topology
¥	(Ã(x, y)∑(f x, g y)) ç ((“ ∏âT ‘), (” ∏âT ’)) Homeomorphism
Æ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LEMMA_T ¨
	(Ã (x, y)∑ (f x, g y)) = (Ãz∑( (Ãz∑f((Ã(x, y)∑ x) z)) z, (Ãz∑g((Ã(x, y)∑ y) z)) z))Æ
	pure_rewrite_thm_tac THEN1 rewrite_tac[]);
a(bc_thm_tac product_continuous_thm);
a(ALL_FC_T pure_asm_rewrite_tac[product_topology_thm]);
a(REPEAT strip_tac THEN bc_thm_tac comp_continuous_thm);
(* *** Goal "1.1" *** *)
a(∂_tac¨“Æ THEN REPEAT strip_tac
	THEN ALL_FC_T rewrite_tac[left_proj_continuous_thm, right_proj_continuous_thm,
		product_topology_thm]);
(* *** Goal "1.2" *** *)
a(∂_tac¨‘Æ THEN REPEAT strip_tac
	THEN ALL_FC_T rewrite_tac [left_proj_continuous_thm, right_proj_continuous_thm,
		product_topology_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨Ã(x, y)∑ (g' x, g'' y)Æ);
a(ALL_FC_T pure_rewrite_tac[product_topology_space_t_thm] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LEMMA_T ¨
	(Ã (x, y)∑ (g' x, g'' y)) = (Ãz∑( (Ãz∑g'((Ã(x, y)∑ x) z)) z, (Ãz∑g''((Ã(x, y)∑ y) z)) z))Æ
	pure_rewrite_thm_tac THEN1 rewrite_tac[]);
a(bc_thm_tac product_continuous_thm);
a(ALL_FC_T pure_asm_rewrite_tac[product_topology_thm]);
a(REPEAT strip_tac THEN bc_thm_tac comp_continuous_thm);
(* *** Goal "2.1.1" *** *)
a(∂_tac¨”Æ THEN REPEAT strip_tac
	THEN ALL_FC_T rewrite_tac [left_proj_continuous_thm, right_proj_continuous_thm,
		product_topology_thm]);
(* *** Goal "2.1.2" *** *)
a(∂_tac¨’Æ THEN REPEAT strip_tac
	THEN ALL_FC_T rewrite_tac[left_proj_continuous_thm, right_proj_continuous_thm,
		product_topology_thm]);
(* *** Goal "2.2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[∏_def]);
a(REPEAT strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2.3" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[∏_def]);
a(REPEAT strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2.4" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[∏_def]);
a(REPEAT strip_tac THEN ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));



val product_unit_homeomorphism_thm = save_thm ( "product_unit_homeomorphism_thm", (
set_goal([], ¨µ‘∑
	‘ ç Topology
¥	(Ãx∑(x, One)) ç (‘, ‘ ∏âT 1âT) Homeomorphism
Æ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(basic_continuity_tac[unit_topology_thm,
	range_unit_topology_continuous_thm,
	space_t_unit_topology_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨FstÆ THEN rewrite_tac[one_def]);
a(basic_continuity_tac[unit_topology_thm]);
pop_thm()
));


val swap_homeomorphism_thm = save_thm ("swap_homeomorphism_thm", (
set_goal([], ¨µ” ‘∑
	” ç Topology
±	‘ ç Topology
¥	(Ã(x, y)∑(y, x)) ç (” ∏âT ‘, ‘ ∏âT ”) Homeomorphism
Æ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(basic_continuity_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨(Ã(y, x)∑(x, y))Æ THEN rewrite_tac[]);
a(basic_continuity_tac[]);
pop_thm()
));


val homeomorphism_open_mapping_thm = save_thm ( "homeomorphism_open_mapping_thm", (
set_goal([], ¨µf ” ‘ A∑
	f ç (”, ‘) Homeomorphism
±	A ç ”
±	” ç Topology
±	‘ ç Topology
¥	{y | ∂x∑ x ç A ± y = f x} ç ‘
Æ);
a(rewrite_tac [homeomorphism_def, continuous_def] THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [6] all_fc_tac);
a(LEMMA_T ¨ {y|∂ x∑ x ç A ± y = f x} = {x|x ç SpaceâT ‘ ± g x ç A}Æ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1);
a(GET_NTH_ASM_T 11 bc_thm_tac);
a(ALL_FC_T rewrite_tac[ç_space_t_thm]);
(* *** Goal "2" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_space_t_thm]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨g xÆ THEN REPEAT strip_tac);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));



val homeomorphism_closed_mapping_thm = save_thm ( "homeomorphism_closed_mapping_thm", (
set_goal([], ¨µf ” ‘ A∑
	f ç (”, ‘) Homeomorphism
±	A ç ” Closed
±	” ç Topology
±	‘ ç Topology
¥	{y | ∂x∑ x ç A ± y = f x} ç ‘ Closed
Æ);
a(rewrite_tac [homeomorphism_def, continuous_closed_thm] THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T [6] all_fc_tac);
a(LEMMA_T ¨ {y|∂ x∑ x ç A ± y = f x} = {x|x ç SpaceâT ‘ ± g x ç A}Æ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1);
a(GET_NTH_ASM_T 11 bc_thm_tac);
a(ALL_FC_T rewrite_tac[ç_closed_ç_space_t_thm]);
(* *** Goal "2" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_closed_ç_space_t_thm]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨g xÆ THEN REPEAT strip_tac);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));


val homeomorphism_one_one_thm = save_thm ( "homeomorphism_one_one_thm", (
set_goal([], ¨µf ” ‘ x y∑
	f ç (”, ‘) Homeomorphism
±	” ç Topology
±	‘ ç Topology
±	x ç SpaceâT ” ± y ç SpaceâT ”
±	f x = f y
¥	x = y
Æ);
a(rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
a(LEMMA_T ¨g(f x) = g(f y)Æ ante_tac THEN1 asm_rewrite_tac[]);
a(ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));


val homeomorphism_onto_thm = save_thm ( "homeomorphism_onto_thm", (
set_goal([], ¨µf ” ‘ y∑
	f ç (”, ‘) Homeomorphism
±	” ç Topology
±	‘ ç Topology
±	y ç SpaceâT ‘
¥	∂x∑x ç SpaceâT ” ± y = f x
Æ);
a(rewrite_tac [homeomorphism_def, continuous_def] THEN REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T[7] all_fc_tac);
a(∂_tac¨g yÆ THEN REPEAT strip_tac);
a(ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));


val homeomorphism_one_one_open_mapping_thm = save_thm ( "homeomorphism_one_one_open_mapping_thm", (
set_goal([], ¨µf ” ‘∑
	” ç Topology
±	‘ ç Topology
¥	(	f ç (”, ‘) Homeomorphism
	§	(µx y∑ x ç SpaceâT ” ± y ç SpaceâT ” ± f x = f y ¥ x = y)
	±	(µy∑ y ç SpaceâT ‘ ¥ ∂x∑x ç SpaceâT ” ± y = f x)
	±	f ç (”, ‘) Continuous
	±	(µA∑A ç ” ¥ {y | ∂x∑ x ç A ± y = f x} ç ‘))
Æ);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[homeomorphism_one_one_thm]);
(* *** Goal "2" *** *)
a(bc_thm_tac homeomorphism_onto_thm);
a(∂_tac¨‘Æ THEN REPEAT strip_tac);
(* *** Goal "3" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "4" *** *)
a(all_fc_tac[homeomorphism_open_mapping_thm]);
(* *** Goal "5" *** *)
a(rewrite_tac[homeomorphism_def] THEN REPEAT strip_tac);
a(lemma_tac¨∂g∑µy∑y ç SpaceâT ‘ ¥ g y ç SpaceâT ” ± y = f(g y)Æ THEN1 prove_∂_tac);
(* *** Goal "5.1" *** *)
a(REPEAT strip_tac THEN cases_tac ¨y' ç SpaceâT ‘Æ THEN asm_rewrite_tac[]);
a(GET_NTH_ASM_T 4 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "5.2" *** *)
a(∂_tac¨gÆ THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
(* *** Goal "5.2.1" *** *)
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "5.2.2" *** *)
a(LIST_GET_NTH_ASM_T [3] all_fc_tac);
a(LEMMA_T¨{x|x ç SpaceâT ‘ ± g x ç A} = {y|∂ x∑ x ç A ± y = f x}Æ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "5.2.2.1" *** *)
a(∂_tac¨g xÆ THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "5.2.2.2" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_space_t_thm]);
a(GET_NTH_ASM_T 9 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "5.2.2.3" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_space_t_thm]);
a(LEMMA_T¨g(f x') = x'Æ asm_rewrite_thm_tac);
a(GET_NTH_ASM_T 9 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [9] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [14] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
(* *** Goal "5.2.3" *** *)
a(GET_NTH_ASM_T 4 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [9] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
(* *** Goal "5.2.4" *** *)
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(all_var_elim_asm_tac1);
a(LEMMA_T¨g(f x) = xÆ asm_rewrite_thm_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
pop_thm()
));



val homeomorphism_one_one_closed_mapping_thm = save_thm ( "homeomorphism_one_one_closed_mapping_thm", (
set_goal([], ¨µf ” ‘∑
	” ç Topology
±	‘ ç Topology
¥	(	f ç (”, ‘) Homeomorphism
	§	(µx y∑ x ç SpaceâT ” ± y ç SpaceâT ” ± f x = f y ¥ x = y)
	±	(µy∑ y ç SpaceâT ‘ ¥ ∂x∑x ç SpaceâT ” ± y = f x)
	±	f ç (”, ‘) Continuous
	±	(µA∑A ç ” Closed ¥ {y | ∂x∑ x ç A ± y = f x} ç ‘ Closed))
Æ);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[homeomorphism_one_one_thm]);
(* *** Goal "2" *** *)
a(bc_thm_tac homeomorphism_onto_thm);
a(∂_tac¨‘Æ THEN REPEAT strip_tac);
(* *** Goal "3" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac [homeomorphism_def] THEN REPEAT strip_tac);
(* *** Goal "4" *** *)
a(all_fc_tac[homeomorphism_closed_mapping_thm]);
(* *** Goal "5" *** *)
a(rewrite_tac[homeomorphism_def] THEN REPEAT strip_tac);
a(lemma_tac¨∂g∑µy∑y ç SpaceâT ‘ ¥ g y ç SpaceâT ” ± y = f(g y)Æ THEN1 prove_∂_tac);
(* *** Goal "5.1" *** *)
a(REPEAT strip_tac THEN cases_tac ¨y' ç SpaceâT ‘Æ THEN asm_rewrite_tac[]);
a(GET_NTH_ASM_T 4 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "5.2" *** *)
a(∂_tac¨gÆ THEN rewrite_tac[continuous_closed_thm] THEN REPEAT strip_tac);
(* *** Goal "5.2.1" *** *)
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "5.2.2" *** *)
a(LIST_GET_NTH_ASM_T [3] all_fc_tac);
a(LEMMA_T¨{x|x ç SpaceâT ‘ ± g x ç A} = {y|∂ x∑ x ç A ± y = f x}Æ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "5.2.2.1" *** *)
a(∂_tac¨g xÆ THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "5.2.2.2" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_closed_ç_space_t_thm]);
a(GET_NTH_ASM_T 7 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "5.2.2.3" *** *)
a(all_var_elim_asm_tac1);
a(all_fc_tac[ç_closed_ç_space_t_thm]);
a(LEMMA_T¨g(f x') = x'Æ asm_rewrite_thm_tac);
a(GET_NTH_ASM_T 7 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [12] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
(* *** Goal "5.2.3" *** *)
a(GET_NTH_ASM_T 4 ante_tac THEN rewrite_tac[continuous_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [9] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
(* *** Goal "5.2.4" *** *)
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(all_var_elim_asm_tac1);
a(LEMMA_T¨g(f x) = xÆ asm_rewrite_thm_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [7] all_fc_tac);
a(conv_tac eq_sym_conv THEN REPEAT strip_tac);
pop_thm()
));


val Ä_compact_homeomorphism_thm = save_thm ( "Ä_compact_homeomorphism_thm", (
set_goal([], ¨µf ” ‘ B C∑
	” ç Topology
±	” ç Hausdorff
±	‘ ç Topology
±	‘ ç Hausdorff
±	C ç ” Compact
±	B Ä C
±	f ç (”, ‘) Continuous
±	(µx y∑ x ç B ± y ç C ± f x = f y ¥ x = y)
¥	f ç (B ÚâT ”, {y | ∂x∑ x ç B ± y = f x} ÚâT ‘) Homeomorphism
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨B ÚâT ” ç Topology ± {y | ∂x∑ x ç B ± y = f x} ÚâT ‘ ç TopologyÆ
	THEN1 (REPEAT strip_tac THEN basic_topology_tac[]));
a(ALL_FC_T1 fc_§_canon rewrite_tac[homeomorphism_one_one_closed_mapping_thm]);
a(all_fc_tac[compact_closed_thm]);
a(lemma_tac¨C Ä SpaceâT ”Æ THEN1 all_fc_tac[closed_open_neighbourhood_thm]);
a(all_fc_tac[pc_rule1"sets_ext1" prove_rule[]¨µb c s∑b Ä c ± c Ä s ¥ b Ä sÆ]);
a(lemma_tac¨{y|∂ x∑ x ç B ± y = f x} Ä SpaceâT ‘Æ);
(* *** Goal "1" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(DROP_NTH_ASM_T 8 (bc_thm_tac o ±_left_elim o rewrite_rule[continuous_def]));
a(LIST_DROP_NTH_ASM_T [2] (PC_T1"sets_ext1" all_fc_tac));
(* *** Goal "2" *** *)
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm1]);
a(REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 10 bc_thm_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [11] (PC_T1"sets_ext1" all_fc_tac));
(* *** Goal "2.2" *** *)
a(bc_thm_tac subspace_continuous_thm THEN asm_rewrite_tac[]);
a(prove_tac[]);
(* *** Goal "2.3" *** *)
a(POP_ASM_T ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_closed_thm] THEN strip_tac);
a(rename_tac[(¨B'Æ, "D")] THEN all_var_elim_asm_tac1);
a(lemma_tac¨D ° C ç ” ClosedÆ THEN1 all_fc_tac[°_closed_thm]);
a(lemma_tac¨D ° C Ä CÆ THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(all_fc_tac[closed_Ä_compact_thm]);
a(DROP_NTH_ASM_T 14 discard_tac THEN all_fc_tac[image_compact_thm]);
a(DROP_NTH_ASM_T 2 discard_tac THEN all_fc_tac[compact_closed_thm]);
a(∂_tac¨{y|∂ x∑ x ç D ° C ± y = f x}Æ THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac
	THEN all_var_elim_asm_tac1);
(* *** Goal "2.3.1" *** *)
a(∂_tac¨x'Æ THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [1, 16] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.3.2" *** *)
a(∂_tac¨x'Æ THEN REPEAT strip_tac);
(* *** Goal "2.3.3" *** *)
a(POP_ASM_T (strip_asm_tac o eq_sym_rule));
a(LIST_DROP_NTH_ASM_T [16] all_fc_tac THEN all_var_elim_asm_tac);
a(∂_tac¨x'Æ THEN REPEAT strip_tac);
pop_thm()
));




val interior_boundary_Ä_space_t_thm = save_thm ( "interior_boundary_Ä_space_t_thm", (
set_goal([], ¨µ‘ A∑
	‘ Interior A Ä SpaceâT ‘
±	‘ Boundary A Ä SpaceâT ‘
Æ);
a(rewrite_tac [interior_def, boundary_def] THEN REPEAT strip_tac THEN_LIST
	[PC_T1 "sets_ext1" prove_tac[space_t_def],
	 PC_T1 "sets_ext1" prove_tac[]]);
pop_thm()
));


val interior_Ä_thm = save_thm ( "interior_Ä_thm", (
set_goal([], ¨µ‘ A∑
	‘ Interior A Ä A
Æ);
a(rewrite_tac [interior_def] THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val boundary_interior_thm = save_thm ( "boundary_interior_thm", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
¥	‘ Boundary A = SpaceâT ‘ \ (‘ Interior A ¿ ‘ Interior (SpaceâT ‘ \ A))
Æ);
a(rewrite_tac [interior_def, boundary_def] THEN PC_T "sets_ext1" contr_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(DROP_NTH_ASM_T 4 (strip_asm_tac o µ_elim¨BÆ));
a(swap_nth_asm_concl_tac 1 THEN PC_T1 "sets_ext1" REPEAT strip_tac
	THEN all_asm_fc_tac[ç_space_t_thm]);
(* *** Goal "4" *** *)
a(DROP_NTH_ASM_T 5 (strip_asm_tac o µ_elim¨BÆ));
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val interior_∏_thm = save_thm ( "interior_∏_thm", (
set_goal([], ¨µ” ‘ A B ∑
	(” ∏âT ‘) Interior (A ∏ B) = (” Interior A ∏ ‘ Interior B)
Æ);
a(REPEAT strip_tac THEN PC_T "sets_ext1" strip_tac);
a(rewrite_tac[product_topology_def, interior_def, ∏_def]
	THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T [3] (PC_T1 "sets_ext1" all_fc_tac));
a(∂_tac¨A'Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [3] (PC_T1 "sets_ext1" all_fc_tac));
a(∂_tac¨B''Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(all_asm_fc_tac[]);
(* *** Goal "3" *** *)
a(∂_tac ¨B' ∏ B''Æ THEN rewrite_tac[∏_def] THEN
	PC_T1 "sets_ext1" REPEAT strip_tac
	THEN_TRY (SOLVED_T (all_asm_fc_tac[])));
a(∂_tac¨B'Æ THEN ∂_tac¨B''Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
pop_thm()
));


val open_§_disjoint_boundary_thm = save_thm ( "open_§_disjoint_boundary_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology
¥	(A ç ‘ § A Ä SpaceâT ‘ ± A ° ‘ Boundary A = {})
Æ);
a(REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(rewrite_tac[boundary_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(all_fc_tac[ç_space_t_thm]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(LIST_GET_NTH_ASM_T [3] all_fc_tac);
a(DROP_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨xÆ)
	THEN_TRY SOLVED_T (PC_T1 "sets_ext1" asm_prove_tac[]));
a(∂_tac¨BÆ THEN PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val closed_§_boundary_Ä_thm = save_thm ( "closed_§_boundary_Ä_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology
¥	(A ç ‘ Closed § A Ä SpaceâT ‘ ± ‘ Boundary A Ä A)
Æ);
a(REPEAT µ_tac THEN ¥_tac);
a(ALL_FC_T1 fc_§_canon rewrite_tac[boundary_interior_thm,
	closed_open_complement_thm,
	open_§_disjoint_boundary_thm]);
a(rewrite_tac[taut_rule¨µp q r∑ (p ± q § p ± r) § (p ¥ (q § r))Æ]);
a(¥_tac THEN LEMMA_T ¨SpaceâT ‘ \ A Ä SpaceâT ‘ ±
		SpaceâT ‘ \ (SpaceâT ‘ \ A) = AÆ rewrite_thm_tac
	THEN1 PC_T1 "sets_ext1" asm_prove_tac[]);
a(lemma_tac¨‘ Interior (SpaceâT ‘ \ A) Ä SpaceâT ‘ \ A ± ‘ Interior A Ä AÆ
	THEN1 rewrite_tac[interior_Ä_thm]);
a(all_asm_ante_tac THEN PC_T1 "sets_ext1" rewrite_tac[]
	THEN contr_tac
	THEN(asm_fc_tac[] THEN asm_fc_tac[]));
pop_thm()
));


val interior_ﬁ_thm = save_thm ( "interior_ﬁ_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology
¥	‘ Interior A = ﬁ{B | B ç ‘ ± B Ä A}
Æ);
a(REPEAT strip_tac THEN rewrite_tac[interior_def]);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
pop_thm()
));


val closure_interior_complement_thm = save_thm ( "closure_interior_complement_thm", (
set_goal([], ¨µ‘ A ∑
	‘ ç Topology
¥	‘ Closure A = SpaceâT ‘ \ ‘ Interior (SpaceâT ‘ \ A)
Æ);
a(REPEAT strip_tac);
a(rewrite_tac[closure_def]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[closed_open_complement_thm, interior_ﬁ_thm]);
a(PC_T1 "sets_ext1" rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[empty_open_thm]);
a(DROP_NTH_ASM_T 2 bc_thm_tac THEN prove_tac[]);
(* *** Goal "2" *** *)
a(bc_thm_tac (pc_rule1 "sets_ext1" prove_rule[] ¨x ç SpaceâT ‘ \ s ¥ ≥x ç sÆ));
a(∂_tac¨‘Æ THEN DROP_NTH_ASM_T 3 bc_thm_tac);
a(asm_prove_tac[]);
a(LEMMA_T ¨SpaceâT ‘ \ (SpaceâT ‘ \ s) = sÆ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(spec_nth_asm_tac 4 ¨SpaceâT ‘ \ sÆ);
a(spec_nth_asm_tac 4 ¨x'Æ);
pop_thm()
));



val unique_lifting_lemma1 = (* not saved *) snd ( "unique_lifting_lemma1", (
set_goal([], ¨µ“ ” ‘; p:'b ≠ 'c; f g : 'a ≠ 'b ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	g ç (“, ”) Continuous
±	(µx∑ x ç SpaceâT “ ¥ p(f x) = p(g x))
¥	{x | x ç SpaceâT “ ± g x = f x} ç “
Æ);
a(rewrite_tac[covering_projection_def] THEN REPEAT strip_tac);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(REPEAT strip_tac);
a(lemma_tac¨f x ç SpaceâT ”Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(lemma_tac¨p(f x) ç SpaceâT ‘Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(LIST_DROP_NTH_ASM_T [8] all_fc_tac);
a(spec_nth_asm_tac 3 ¨f xÆ);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa u s∑a ç u ± u Ä s ¥ a ç sÆ]);
a(all_fc_tac[continuous_open_thm]);
a(lemma_tac¨g x ç AÆ THEN1 asm_rewrite_tac[]);
a(∂_tac¨{y|y ç SpaceâT “ ± f y ç A} ° {y|y ç SpaceâT “ ± g y ç A}Æ
	THEN ALL_FC_T asm_rewrite_tac[°_open_thm]
	THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [11] all_fc_tac);
a(lemma_tac¨f x' ç SpaceâT ”Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(lemma_tac¨g x' ç SpaceâT ”Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(bc_thm_tac (µ_elim¨pÆ homeomorphism_one_one_thm));
a(MAP_EVERY ∂_tac [¨C ÚâT ‘Æ, ¨A ÚâT ”Æ, ¨pÆ]
	THEN ALL_FC_T asm_rewrite_tac[subspace_topology_thm,
		subspace_topology_space_t_thm2]);
a(LIST_GET_NTH_ASM_T [23] (ALL_FC_T rewrite_tac));
pop_thm()
));


val unique_lifting_lemma2 = (* not saved *) snd ( "unique_lifting_lemma2", (
set_goal([], ¨µ“ ” ‘; p:'b ≠ 'c; f g : 'a ≠ 'b ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	g ç (“, ”) Continuous
±	(µx∑ x ç SpaceâT “ ¥ p(f x) = p(g x))
¥	{x | x ç SpaceâT “ ± ≥g x = f x} ç “
Æ);
a(rewrite_tac[covering_projection_def] THEN REPEAT strip_tac);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(REPEAT strip_tac);
a(all_fc_tac[continuous_ç_space_t_thm]);
a(lemma_tac¨p(f x) ç SpaceâT ‘Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(LIST_DROP_NTH_ASM_T [9] all_fc_tac);
a(LIST_GET_NTH_ASM_T [12] all_fc_tac);
a(POP_ASM_T (strip_asm_tac o eq_sym_rule));
a(lemma_tac¨p(g x) ç CÆ
	THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa u s∑a ç u ± u Ä s ¥ a ç sÆ]);
a(all_fc_tac[continuous_open_thm]);
a(∂_tac¨{y|y ç SpaceâT “ ± f y ç A'} ° {y|y ç SpaceâT “ ± g y ç A}Æ
	THEN ALL_FC_T asm_rewrite_tac[°_open_thm]
	THEN REPEAT strip_tac);
a(PC_T "sets_ext1" contr_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨ µa b x y∑x ç a ± y ç b ± y = x ¥ ≥a ° b  = {}Æ]);
a(LIST_DROP_NTH_ASM_T [22] all_fc_tac THEN all_var_elim_asm_tac1);
a(LIST_DROP_NTH_ASM_T [17] all_fc_tac);
a(swap_nth_asm_concl_tac 24);
a(lemma_tac¨f x' ç SpaceâT ”Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(lemma_tac¨g x' ç SpaceâT ”Æ THEN1 all_fc_tac[continuous_ç_space_t_thm]);
a(bc_thm_tac (µ_elim¨pÆ homeomorphism_one_one_thm));
a(MAP_EVERY ∂_tac [¨C ÚâT ‘Æ, ¨A ÚâT ”Æ, ¨pÆ]
	THEN ALL_FC_T asm_rewrite_tac[subspace_topology_thm,
		subspace_topology_space_t_thm2]);
pop_thm()
));


val unique_lifting_thm = save_thm ( "unique_lifting_thm", (
set_goal([], ¨µ“ ” ‘; p:'b ≠ 'c; f g : 'a ≠ 'b; a : 'a ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	SpaceâT “ ç “ Connected
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	g ç (“, ”) Continuous
±	(µx∑ x ç SpaceâT “ ¥ p(f x) = p(g x))
±	a ç SpaceâT “
±	g a = f a
¥	µx∑ x ç SpaceâT “ ¥ g x = f x
Æ);
a(REPEAT strip_tac);
a(swap_nth_asm_concl_tac 8 THEN rewrite_tac[connected_def]
	THEN REPEAT strip_tac);
a(all_fc_tac[unique_lifting_lemma1, unique_lifting_lemma2]);
a(∂_tac¨{x | x ç SpaceâT “ ± g x = f x}Æ THEN REPEAT strip_tac);
a(∂_tac¨{x | x ç SpaceâT “ ± ≥g x = f x}Æ THEN asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(∂_tac¨xÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨aÆ THEN asm_rewrite_tac[]);
pop_thm()
));

open_theory"metric_spaces";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
val metric_def = get_spec¨MetricÆ;
val metric_topology_def = get_spec¨$MetricTopologyÆ;
val list_metric_def = get_spec¨ListMetricÆ;

val metric_topology_thm = save_thm ( "metric_topology_thm", (
set_goal([], ¨µD∑D ç Metric ¥ D MetricTopology ç TopologyÆ);
a(rewrite_tac[topology_def, metric_def, metric_topology_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µx b c∑x ç b ± b Ä c ¥ x ç  cÆ]);
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(∂_tac¨eÆ THEN REPEAT strip_tac);
a(∂_tac¨sÆ THEN ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [3, 4] all_fc_tac);
a(cases_tac¨e º e'Æ);
(* *** Goal "2.1" *** *)
a(∂_tac¨eÆ THEN PC_T1 "predicates" REPEAT strip_tac);
a(lemma_tac¨D(x, y) < e'Æ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LIST_DROP_NTH_ASM_T [4, 6] all_fc_tac THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(∂_tac¨e'Æ THEN PC_T1 "predicates" REPEAT strip_tac);
a(lemma_tac¨D(x, y) < eÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LIST_DROP_NTH_ASM_T [4, 6] all_fc_tac THEN REPEAT strip_tac);
pop_thm()
));



val space_t_metric_topology_thm = save_thm ( "space_t_metric_topology_thm", (
set_goal([], ¨µD∑
	D ç Metric
¥	SpaceâT (D MetricTopology) = Universe
Æ);
a(PC_T1 "sets_ext1" rewrite_tac[metric_def, metric_topology_def, space_t_def]
	THEN REPEAT strip_tac);
a(∂_tac¨UniverseÆ THEN rewrite_tac[]);
a(∂_tac¨1/2Æ THEN REPEAT strip_tac);
pop_thm()
));


val open_ball_open_thm = save_thm ( "open_ball_open_thm", (
set_goal([], ¨µD e x∑ÓØ 0 <  e ± D ç Metric ¥ {y | D (x, y) < e} ç D MetricTopologyÆ);
a(rewrite_tac[metric_topology_def, metric_def] THEN REPEAT strip_tac);
a(∂_tac¨e - D(x, x')Æ THEN REPEAT strip_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(lemma_tac¨D(x, y) º D(x, x') + D(x', y)Æ THEN1 asm_rewrite_tac[]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val open_ball_neighbourhood_thm = save_thm ( "open_ball_neighbourhood_thm", (
set_goal([], ¨µD e x∑ÓØ 0 <  e ± D ç Metric ¥ x ç {y | D(x, y) < e}Æ);
a(rewrite_tac[metric_def] THEN REPEAT strip_tac);
a(lemma_tac¨D(x, x) = ÓØ 0Æ THEN asm_rewrite_tac[]);
pop_thm()
));




val metric_topology_hausdorff_thm = save_thm ( "metric_topology_hausdorff_thm", (
set_goal([], ¨µD∑
	D ç Metric
¥	D MetricTopology ç Hausdorff
Æ);
a(REPEAT strip_tac THEN TOP_ASM_T ante_tac);
a(rewrite_tac[metric_def, hausdorff_def, space_t_metric_topology_thm]
	THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 5 ante_tac);
a(lemma_tac¨0. º D(x, y) ± ≥D(x, y) = 0.Æ
	THEN1 asm_rewrite_tac[]);
a(lemma_tac¨0. < 1/2 * D(x, y)Æ
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]
	THEN strip_tac);
a(∂_tac¨{z | D(x, z) < 1/2 * D(x, y)}Æ
	THEN ∂_tac¨{z | D(y, z) < 1/2 * D(x, y)}Æ
	THEN ALL_FC_T rewrite_tac[open_ball_open_thm]);
a(POP_ASM_T ante_tac
	THEN LEMMA_T¨µz∑ D(z, z) = 0.Æ asm_rewrite_thm_tac
	THEN1 asm_rewrite_tac[]);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
a(LEMMA_T¨D(x, y) º D(x, x') + D(x', y)Æ ante_tac
	THEN1 DROP_NTH_ASM_T 10 rewrite_thm_tac);
a(rewrite_tac[]);
a(LEMMA_T ¨D(x', y) = D(y, x')Æ rewrite_thm_tac
	THEN1 (DROP_NTH_ASM_T 3
		(fn th => conv_tac(LEFT_C(once_rewrite_conv[th])))
		THEN REPEAT strip_tac));
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val product_metric_thm = save_thm ( "product_metric_thm", (
set_goal([], ¨µD1 D2∑
	D1 ç Metric ± D2 ç Metric
¥	(Ã((x1, x2), (y1, y2))∑ D1(x1, y1) + D2(x2, y2)) ç Metric
Æ);
a(rewrite_tac[metric_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]
	¨µx y∑ÓØ 0 º x ± ÓØ 0 º y ¥ ÓØ 0 º x + yÆ) THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac ¨ÓØ 0 º D1(Fst x, Fst y) ± ÓØ 0 º D2(Snd x, Snd y)Æ
	THEN1 asm_rewrite_tac[]);
a(lemma_tac ¨D1(Fst x, Fst y) = ÓØ 0 ± D2(Snd x, Snd y) = ÓØ 0Æ
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(all_asm_fc_tac[]);
a(pure_once_rewrite_tac[prove_rule[]¨µp∑p = (Fst p, Snd p)Æ]);
a(pure_asm_rewrite_tac[] THEN rewrite_tac[]);
(* *** Goal "3" *** *)
a(LEMMA_T¨x = y ± (µx∑ D1(x, x) = ÓØ 0) ± (µy∑D2(y, y) = ÓØ 0)Æ rewrite_thm_tac
	THEN LIST_GET_NTH_ASM_T [1, 4, 8] rewrite_tac);
(* *** Goal "4" *** *)
a(GET_NTH_ASM_T 6 (rewrite_thm_tac o µ_elim¨Fst yÆ));
a(GET_NTH_ASM_T 2 (rewrite_thm_tac o µ_elim¨Snd yÆ));
(* *** Goal "5" *** *)
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µa b c d e f:Ø∑a º c + e ± b º d + f ¥ a + b º (c + d) + e + fÆ));
a(asm_rewrite_tac[]);
pop_thm()
));


val product_metric_topology_thm = save_thm ( "product_metric_topology_thm", (
set_goal([], ¨µD1 D2∑
	D1 ç Metric ± D2 ç Metric
¥	(Ã((x1, x2), (y1, y2))∑ D1(x1, y1) + D2(x2, y2)) MetricTopology   =
	(D1 MetricTopology ∏âT D2 MetricTopology)
Æ);
a(rewrite_tac[metric_def, metric_topology_def, product_topology_def] THEN
	PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(lemma_tac¨ÓØ 0 < (1/2)*eÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(∂_tac¨{x1 | D1(x', x1)  < (1/2)*e}Æ THEN ∂_tac¨{x2 | D2(y, x2)  < (1/2)*e}Æ THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(∂_tac¨(1/2)*e - D1(x' , x'')Æ THEN REPEAT strip_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(lemma_tac¨D1(x', y') º D1(x', x'') + D1(x'', y')Æ THEN1 GET_NTH_ASM_T 11 rewrite_thm_tac);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2" *** *)
a(∂_tac¨(1/2)*e - D2(y , x'')Æ THEN REPEAT strip_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(lemma_tac¨D2(y, y') º D2(y, x'') + D2(x'', y')Æ THEN1 GET_NTH_ASM_T 7 rewrite_thm_tac);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.3" *** *)
a(LEMMA_T ¨µx∑ D1(x, x) = ÓØ 0Æ asm_rewrite_thm_tac
	THEN1 LIST_GET_NTH_ASM_T [1, 11] rewrite_tac);
(* *** Goal "1.4" *** *)
a(LEMMA_T ¨µx∑ D2(x, x) = ÓØ 0Æ asm_rewrite_thm_tac
	THEN LIST_GET_NTH_ASM_T [1, 7] rewrite_tac);
(* *** Goal "1.5" *** *)
a(rewrite_tac[∏_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(DROP_NTH_ASM_T 4 (bc_thm_tac o rewrite_rule[]));
a(rewrite_tac[] THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 2 (ante_tac o list_µ_elim[¨Fst x'Æ, ¨Snd x'Æ]));
a(rewrite_tac[] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [4, 5] all_fc_tac);
a(cases_tac¨e < e'Æ);
(* *** Goal "2.1" *** *)
a(∂_tac¨eÆ THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1 "sets_ext1" prove_rule[]¨µa x y∑ a Ä x ± y ç a ¥ y ç xÆ));
a(∂_tac¨A ∏ BÆ THEN REPEAT strip_tac);
a(lemma_tac ¨ÓØ 0 º D1 (Fst x', Fst y) ± ÓØ 0 º  D2 (Snd x', Snd y)Æ
	THEN1 LIST_GET_NTH_ASM_T [14, 18] rewrite_tac);
a(lemma_tac ¨D1 (Fst x', Fst y) < e' ± D2 (Snd x', Snd y) < eÆ
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LIST_DROP_NTH_ASM_T[7, 9] all_fc_tac);
a(rewrite_tac[∏_def] THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(∂_tac¨e'Æ THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1 "sets_ext1" prove_rule[]¨µa x y∑ a Ä x ± y ç a ¥ y ç xÆ));
a(∂_tac¨A ∏ BÆ THEN REPEAT strip_tac);
a(lemma_tac ¨ÓØ 0 º D1 (Fst x', Fst y) ± ÓØ 0 º  D2 (Snd x', Snd y)Æ
	THEN1 LIST_GET_NTH_ASM_T [14, 18] rewrite_tac);
a(lemma_tac ¨D1 (Fst x', Fst y) < e' ± D2 (Snd x', Snd y) < eÆ
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LIST_DROP_NTH_ASM_T[7, 9] all_fc_tac);
a(rewrite_tac[∏_def] THEN REPEAT strip_tac);
pop_thm()
));


val lebesgue_number_thm = save_thm ( "lebesgue_number_thm", (
set_goal([], ¨µD X U∑
	D ç Metric
±	X ç (D MetricTopology) Compact
±	U Ä D MetricTopology
±	X Ä ﬁU
¥	∂e∑ ÓØ 0 < e
±	µx∑ x ç X ¥ ∂A∑ x ç  A ± A ç U ± µy∑ D(x, y) < e ¥ y ç A
Æ);
a(contr_tac);
a(all_fc_tac [metric_topology_thm]);
a(lemma_tac¨∂s∑(µm:Ó∑ s m ç X) ± (µA; m:Ó∑A ç U ¥ ∂y∑ D(s m, y) < ÓØ (m + 1) õ-õ1 ± ≥y ç A)Æ
	THEN1 (prove_∂_tac THEN REPEAT strip_tac));
(* *** Goal "1" *** *)
a(lemma_tac¨ÓØ 0 < ÓØ (m' + 1)õ-õ1Æ THEN1
	(bc_thm_tac  Ø_0_less_0_less_recip_thm THEN
		rewrite_tac [ÓØ_less_thm] THEN PC_T1 "lin_arith" prove_tac[]));
a(spec_nth_asm_tac 3 ¨ÓØ (m' + 1)õ-õ1Æ);
a(∂_tac¨xÆ THEN REPEAT strip_tac);
a(spec_nth_asm_tac 2 ¨AÆ);
(* *** Goal "1.1" *** *)
a(∂_tac¨xÆ THEN REPEAT strip_tac);
a(LEMMA_T ¨D(x, x) = ÓØ 0Æ asm_rewrite_thm_tac);
a(DROP_NTH_ASM_T 11 (rewrite_thm_tac o rewrite_rule[metric_def]));
(* *** Goal "1.2" *** *)
a(∂_tac¨yÆ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(all_fc_tac[compact_sequentially_compact_thm]);
a(DROP_NTH_ASM_T 7 (PC_T1 "sets_ext1" strip_asm_tac));
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µa∑s' ç U ± U Ä a ¥ s' ç aÆ]);
a(spec_nth_asm_tac 4 ¨s'Æ);
a(GET_NTH_ASM_T 2 (strip_asm_tac o rewrite_rule[metric_topology_def]));
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(lemma_tac¨ÓØ 0  < (1/2)*e Æ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(DROP_NTH_ASM_T 3 discard_tac);
a(lemma_tac¨{y | D(x, y) < (1/2)*e} ç D MetricTopologyÆ
	THEN1 (bc_thm_tac open_ball_open_thm THEN REPEAT strip_tac));
a(LEMMA_T¨x ç {y | D(x, y) < (1/2)*e}Æ asm_tac
	THEN1 (bc_thm_tac open_ball_neighbourhood_thm THEN REPEAT strip_tac));
a(PC_T1 "predicates" (spec_nth_asm_tac 9) ¨{y | D(x, y) < (1/2)*e}Æ);
a(all_fc_tac[Ø_archimedean_recip_thm]);
a(spec_nth_asm_tac 2 ¨m+1Æ);
a(lemma_tac¨ÓØ 0 < ÓØ(m+1) ± ÓØ 0 < ÓØ(n+1) ± ÓØ(m+1) < ÓØ(n+1)Æ
	THEN1 (rewrite_tac [ÓØ_less_thm] THEN PC_T1 "lin_arith" asm_prove_tac[]));
a(lemma_tac¨ÓØ(n+1)õ-õ1  < ÓØ(m+1)õ-õ1Æ
	THEN1 (bc_thm_tac Ø_less_recip_less_thm THEN REPEAT strip_tac));
a(lemma_tac¨ÓØ 0 < ÓØ(m+1)õ-õ1 ± ÓØ 0 < ÓØ(n+1)õ-õ1Æ
	THEN1 (ALL_FC_T rewrite_tac [Ø_0_less_0_less_recip_thm]));
a(list_spec_nth_asm_tac 21 [¨s'Æ, ¨nÆ]);
a(swap_nth_asm_concl_tac 1 THEN DROP_NTH_ASM_T 15 bc_thm_tac);
a(lemma_tac¨D(x, y) º D(x, s n) + D(s n, y)Æ
	THEN1 DROP_NTH_ASM_T 27 (rewrite_thm_tac o rewrite_rule[metric_def]));
a(lemma_tac¨D(s n, y) < (1/2)*eÆ
	THEN1 REPEAT (all_fc_tac[Ø_less_trans_thm]));
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val collar_thm = save_thm ( "collar_thm", (
set_goal([], ¨µD X U∑
	D ç Metric
±	X ç (D MetricTopology) Compact
±	A ç D MetricTopology
±	X Ä A
¥	∂e∑ ÓØ 0 < e
±	µx y∑ x ç X ± y ç SpaceâT ‘ ± D(x, y) < e ¥ y ç A
Æ);
a(REPEAT strip_tac);
a(lemma_tac ¨X Ä ﬁ{A} ± {A} Ä D MetricTopologyÆ  THEN1 asm_rewrite_tac[enum_set_clauses]);
a(strip_asm_tac (list_µ_elim[¨DÆ, ¨XÆ, ¨{A}Æ] lebesgue_number_thm));
a(∂_tac¨eÆ THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
a(all_var_elim_asm_tac1 THEN all_asm_fc_tac[]);
pop_thm()
));



val list_pseudo_metric_lemma1 = (* not saved *) snd ( "list_pseudo_metric_lemma1", (
set_goal([], ¨∂P∑
	(µD x v y w∑
	P D ([], []) = 0.
±	P D (Cons x v, []) = D(x, Arbitrary) + P D (v, [])
±	P D ([], Cons y w) = D(Arbitrary, y) + P D ([], w)
±	P D (Cons x v, Cons y w) = D (x, y) + P D (v, w))
±	µD v w∑
	ListMetric D (v, w) =
	Abs(ÓØ(#v) - ÓØ (#w)) + P D (v, w)
Æ);
a(strip_asm_tac (prove_∂_rule
 ¨∂P∑
	µD: 'a ∏ 'a ≠ Ø; x v y w∑
	P D ([], []) = 0.
±	P D (Cons x v, []) = D(x, Arbitrary) + P D (v, [])
±	P D ([], Cons y w) = D(Arbitrary, y) + P D ([], w)
±	P D (Cons x v, Cons y w) = D (x, y) + P D (v, w)
Æ));
a(∂_tac¨PÆ THEN asm_rewrite_tac[] THEN REPEAT_N 2 strip_tac);
a(list_induction_tac¨vÆ THEN REPEAT strip_tac
	THEN list_induction_tac¨w:'a LISTÆ
	THEN REPEAT strip_tac
	THEN asm_rewrite_tac[list_metric_def, length_def,
		ÓØ_plus_homomorphism_thm]);
(* *** Goal "1" *** *)
a(lemma_tac¨0. º ÓØ(#w)Æ THEN1 rewrite_tac[ÓØ_º_thm]);
a(LEMMA_T¨µx∑0. º x ¥ ≥0. º ~x + ~1.Æ
	(fn th => all_fc_tac[th])
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(asm_rewrite_tac[Ø_abs_def] THEN1 PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨0. º ÓØ(#v)Æ THEN1 rewrite_tac[ÓØ_º_thm]);
a(LEMMA_T¨µx∑0. º x ¥ 0. º x + 1.Æ
	(fn th => all_fc_tac[th])
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(asm_rewrite_tac[Ø_abs_def] THEN1 PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "3" *** *)
a(conv_tac(ONCE_MAP_C Ø_anf_conv));
a(cases_tac¨0. º ÓØ (# v) + ~ (ÓØ (# w))Æ
	THEN asm_rewrite_tac[Ø_abs_def]
	THEN PC_T1 "Ø_lin_arith" prove_tac[]);
pop_thm()
));


val list_pseudo_metric_lemma2 = (* not saved *) snd ( "list_pseudo_metric_lemma2", (
set_goal([], ¨µP; D : 'a ∏ 'a ≠ Ø∑
	(µx v y w∑
	P D ([], []) = 0.
±	P D (Cons x v, []) = D(x, Arbitrary) + P D (v, [])
±	P D ([], Cons y w) = D(Arbitrary, y) + P D ([], w)
±	P D (Cons x v, Cons y w) = D (x, y) + P D (v, w))
±	(µx∑ D (x, x) = 0.)
±	(µx y z∑ D (x, z) º D (x, y) + D(y, z))
¥	P D (u, w) º P D (u, v) + P D (v, w)
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨
	(µv w∑ P D (v @ [Arbitrary], w) = P D (v, w))
±	(µw v∑ P D (v, w @ [Arbitrary]) = P D (v, w))Æ
	THEN1 ±_tac);
(* *** Goal "1" *** *)
a(µ_tac THEN list_induction_tac ¨v:'a LISTÆ THEN asm_rewrite_tac[append_def]
	THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(list_induction_tac ¨wÆ THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(list_induction_tac ¨wÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(µ_tac THEN list_induction_tac ¨w:'a LISTÆ THEN asm_rewrite_tac[append_def]
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(list_induction_tac ¨vÆ THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(list_induction_tac ¨vÆ THEN asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(lemma_tac¨∂pad∑µj v∑ pad v 0 = v ± pad v (j+1) = pad v j @ [Arbitrary]Æ
	THEN1 prove_∂_tac);
a(lemma_tac¨µj v∑#(pad v j) = #v + jÆ
	THEN1 (µ_tac THEN induction_tac¨j:ÓÆ
	THEN asm_rewrite_tac[length_append_thm, length_def, plus_assoc_thm]));
a(lemma_tac¨µj v w∑P D (pad v j, w) = P D (v, w)Æ
	THEN1 (µ_tac THEN induction_tac¨j:ÓÆ
	THEN asm_rewrite_tac[]));
a(lemma_tac¨µj v w∑P D (v, pad w j) = P D (v, w)Æ
	THEN1 (µ_tac THEN induction_tac¨j:ÓÆ
	THEN asm_rewrite_tac[]));
a(lemma_tac¨∂i j k∑ #u + i = #v + j ± #v + j = #w + kÆ
	THEN1 (MAP_EVERY ∂_tac [¨#v + #wÆ, ¨#u + #wÆ, ¨#u + #vÆ]
		THEN1 PC_T1 "lin_arith" prove_tac[]));
a(lemma_tac¨#(pad u i) = #(pad v j) ± #(pad v j) = #(pad w k)Æ
	THEN1 asm_rewrite_tac[]);
a(LEMMA_T¨
	P D (u, w) = P D (pad u i, pad w k)
±	P D (u, v) = P D (pad u i, pad v j)
±	P D (v, w) = P D (pad v j, pad w k)Æ rewrite_thm_tac
	THEN1 asm_rewrite_tac[]);
a(LEMMA_T¨µu v w∑#u = #v ± #v =#w ¥ P D (u, w) º P D (u, v) + P D (v, w)Æ
	(fn th => bc_thm_tac th THEN REPEAT strip_tac));
a(LIST_DROP_NTH_ASM_T [1, 2, 3, 4] discard_tac THEN REPEAT strip_tac);
a(lemma_tac¨∂m∑ #u = mÆ THEN1 prove_∂_tac);
a(LIST_DROP_NTH_ASM_T [2, 3, 1] (MAP_EVERY ante_tac));
a(MAP_EVERY intro_µ_tac1 [¨wÆ, ¨vÆ, ¨uÆ]);
a(induction_tac¨mÆ);
(* *** Goal "3.1" *** *)
a(REPEAT µ_tac THEN strip_tac THEN asm_rewrite_tac[]);
a(STRIP_T (strip_asm_tac o eq_sym_rule) THEN asm_rewrite_tac[]);
a(STRIP_T (ante_tac o eq_sym_rule)
	THEN POP_ASM_T ante_tac THEN POP_ASM_T ante_tac);
a(rewrite_tac[length_0_thm]);
a(REPEAT strip_tac THEN asm_rewrite_tac[]);
(* *** Goal "3.2" *** *)
a(REPEAT µ_tac THEN strip_tac THEN asm_rewrite_tac[]);
a(STRIP_T (strip_asm_tac o eq_sym_rule) THEN asm_rewrite_tac[]);
a(STRIP_T (strip_asm_tac o eq_sym_rule));
a(MAP_EVERY (fn t => strip_asm_tac(µ_elim t list_cases_thm)
	THEN all_var_elim_asm_tac1 THEN1
		(all_asm_ante_tac THEN rewrite_tac[length_def]))
	[¨uÆ, ¨vÆ, ¨wÆ]);
a(LIST_DROP_NTH_ASM_T [1, 2, 3] (MAP_EVERY (strip_asm_tac o rewrite_rule[length_def])));
a(asm_rewrite_tac[Ø_plus_assoc_thm]);
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]
	¨µa b c x y z:Ø∑a º b + c ± x º y + z ¥
		a + x º b + y + c + zÆ)
	THEN asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 4 (bc_thm_tac o rewrite_rule[taut_rule¨
	µp q r∑p ¥ q ¥ r § p ± q ¥ rÆ])
	THEN PC_T1 "lin_arith" asm_prove_tac[]);
pop_thm()
));


val list_metric_nonneg_thm = save_thm ( "list_metric_nonneg_thm", (
set_goal([], ¨µD x∑
	D ç Metric
¥	0. º ListMetric D (x, y)
Æ);
a(rewrite_tac[metric_def] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [1, 2, 3] discard_tac);
a(intro_µ_tac1¨yÆ THEN list_induction_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(list_induction_tac ¨yÆ THEN asm_rewrite_tac[list_metric_def] THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µx y∑0. º x ± 0. º y ¥ 0. º 1. + x + yÆ)
	THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(list_induction_tac ¨yÆ THEN rewrite_tac[list_metric_def] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µx y∑0. º x ± 0. º y ¥ 0. º 1. + x + yÆ)
	THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µx y∑0. º x ± 0. º y ¥ 0. º x + yÆ)
	THEN asm_rewrite_tac[]);
pop_thm()
));



val list_metric_sym_thm = save_thm ( "list_metric_sym_thm", (
set_goal([], ¨µD x y∑
	D ç Metric
¥	ListMetric D (x, y) = ListMetric D (y, x)
Æ);
a(rewrite_tac[metric_def] THEN REPEAT strip_tac);
a(intro_µ_tac1¨yÆ THEN list_induction_tac¨xÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(list_induction_tac¨yÆ THEN REPEAT strip_tac
	THEN rewrite_tac[list_metric_def]);
a(DROP_NTH_ASM_T 3 (once_asm_rewrite_thm_tac o µ_elim¨xÆ)
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(strip_asm_tac(µ_elim¨yÆ list_cases_thm)
	THEN all_var_elim_asm_tac1 THEN rewrite_tac[list_metric_def]);
(* *** Goal "2.1" *** *)
a(POP_ASM_T rewrite_thm_tac);
a(DROP_NTH_ASM_T 2 (once_asm_rewrite_thm_tac o µ_elim¨x'Æ)
	THEN REPEAT strip_tac);
(* *** Goal "2.2" *** *)
a(DROP_NTH_ASM_T 3 (once_asm_rewrite_thm_tac o µ_elim¨x'Æ)
	THEN strip_tac);
pop_thm()
));



val list_metric_metric_thm = save_thm ( "list_metric_metric_thm", (
set_goal([], ¨µD∑
	D ç Metric
¥	ListMetric D ç Metric
Æ);
a(REPEAT strip_tac THEN TOP_ASM_T ante_tac);
a(rewrite_tac[metric_def] THEN ¥_tac);
a(all_fc_tac[list_metric_nonneg_thm] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 4 discard_tac);
a(POP_ASM_T ante_tac THEN lemma_tac¨∂m∑ Length x = mÆ THEN1 prove_∂_tac);
a(POP_ASM_T ante_tac THEN intro_µ_tac1¨yÆ THEN intro_µ_tac1¨xÆ);
a(induction_tac¨mÆ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(POP_ASM_T ante_tac THEN POP_ASM_T ante_tac
	THEN rewrite_tac[length_0_thm]
	THEN REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(POP_ASM_T ante_tac THEN strip_asm_tac(µ_elim¨yÆ list_cases_thm)
	THEN asm_rewrite_tac[list_metric_def]);
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µx y∑0. º x ± 0. º y ¥ ≥1. + x + y = 0.Æ)
	THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨≥x = []Æ THEN1 (contr_tac THEN all_var_elim_asm_tac1
	THEN all_asm_ante_tac THEN rewrite_tac[length_def]));
a(DROP_NTH_ASM_T 2 ante_tac THEN strip_asm_tac(µ_elim¨xÆ list_cases_thm));
a(strip_asm_tac(µ_elim¨yÆ list_cases_thm)
	THEN all_var_elim_asm_tac1 THEN1 asm_rewrite_tac[list_metric_def]);
(* *** Goal "2.2.1" *** *)
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]¨µx y∑0. º x ± 0. º y ¥ ≥1. + x + y = 0.Æ)
	THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2" *** *)
a(DROP_NTH_ASM_T 2 ante_tac THEN rewrite_tac[list_metric_def, length_def]);
a(REPEAT_UNTIL is_± strip_tac);
a(FC_T (MAP_EVERY ante_tac) [pc_rule1 "Ø_lin_arith" prove_rule[]
	¨µx y∑ x + y = 0. ± 0. º x ± 0. º y ¥ x = 0. ± y = 0.Æ]);
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
a(all_asm_fc_tac[]);
(* *** Goal "3" *** *)
a(all_var_elim_asm_tac);
a(list_induction_tac¨yÆ THEN asm_rewrite_tac[list_metric_def]);
(* *** Goal "4" *** *)
a(bc_thm_tac list_metric_sym_thm THEN REPEAT strip_tac);
(* *** Goal "5" *** *)
a(strip_asm_tac list_pseudo_metric_lemma1 THEN asm_rewrite_tac[Ø_plus_assoc_thm]);
a(bc_thm_tac (pc_rule1 "Ø_lin_arith" prove_rule[]
	¨µa b c x y z:Ø∑a º b + c ± x º y + z ¥
		a + x º b + y + c + zÆ)
	THEN REPEAT strip_tac);
(* *** Goal "5.1" *** *)
a(rewrite_tac[pc_rule1 "Ø_lin_arith" prove_rule[]
	¨ÓØ (# x) + ~ (ÓØ (# z)) =
	(ÓØ (# x) + ~ (ÓØ (# y))) + (ÓØ (# y) + ~ (ÓØ (# z)))Æ, Ø_abs_plus_thm]);
(* *** Goal "5.1" *** *)
a(bc_thm_tac list_pseudo_metric_lemma2);
a(DROP_NTH_ASM_T 5 discard_tac THEN asm_rewrite_tac[]);
pop_thm()
));


open_theory"topology_Ø";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
val d_Ø_def = get_spec¨DâRÆ;
val d_Ø_2_def = get_spec¨DâR2Æ;
val d_Ø_2_def1 = save_thm ( "d_Ø_2_def1", (
set_goal([], ¨µxy1 xy2∑ DâR2 (xy1, xy2) = Abs(Fst xy2 - Fst xy1)  + Abs(Snd xy2 - Snd  xy1)Æ);
a(REPEAT strip_tac);
a(pure_once_rewrite_tac[prove_rule[]¨µp:Ø ∏ Ø∑p = (Fst p, Snd p)Æ]);
a(pure_rewrite_tac[d_Ø_2_def]);
a(rewrite_tac[]);
pop_thm()
));


val open_Ø_topology_thm = save_thm ( "open_Ø_topology_thm", (
set_goal([], ¨OâR ç TopologyÆ);
a(rewrite_tac[topology_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_fc_tac[ﬁ_open_Ø_thm]);
(* *** Goal "2" *** *)
a(all_fc_tac[°_open_Ø_thm]);
pop_thm()
));


val space_t_Ø_thm = save_thm ( "space_t_Ø_thm", (
set_goal([], ¨SpaceâT OâR = UniverseÆ);
a(PC_T1 "sets_ext" REPEAT strip_tac);
a(bc_thm_tac ç_space_t_thm);
a(∂_tac¨UniverseÆ THEN rewrite_tac[open_Ø_topology_thm, empty_universe_open_closed_thm]);
pop_thm()
));


val closed_closed_Ø_thm = save_thm ( "closed_closed_Ø_thm", (
set_goal([], ¨OâR Closed = ClosedâRÆ);
a(rewrite_tac[closed_def, closed_Ø_def, space_t_Ø_thm] THEN REPEAT strip_tac);
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(asm_rewrite_tac[pc_rule1"sets_ext1" prove_rule[complement_clauses]¨µa:'a SET∑~(~a) = aÆ]);
(* *** Goal "2" *** *)
a(∂_tac¨~xÆ THEN
	asm_rewrite_tac[pc_rule1"sets_ext1" prove_rule[complement_clauses]¨µa:'a SET∑~(~a) = aÆ]);
pop_thm()
));


val compact_compact_Ø_thm = save_thm ( "compact_compact_Ø_thm", (
set_goal([], ¨OâR Compact = CompactâRÆ);
a(rewrite_tac[compact_def, compact_Ø_def, space_t_Ø_thm] THEN REPEAT strip_tac);
pop_thm()
));


val open_Ø_const_continuous_thm = save_thm("open_Ø_const_continuous_thm",
	all_µ_intro(
	rewrite_rule[open_Ø_topology_thm, space_t_Ø_thm]
	(list_µ_elim[¨” : 'a SET SETÆ, ¨OâRÆ] const_continuous_thm)));


val open_Ø_id_continuous_thm = save_thm("open_Ø_id_continuous_thm",
	rewrite_rule[open_Ø_topology_thm]
	(µ_elim¨OâRÆ id_continuous_thm));



val continuous_cts_at_Ø_thm = save_thm ( "continuous_cts_at_Ø_thm", (
set_goal([], ¨µf∑ f ç (OâR, OâR) Continuous § µx∑f Cts xÆ);
a(rewrite_tac[continuous_def, cts_open_Ø_thm, space_t_Ø_thm] THEN REPEAT strip_tac);
pop_thm()
));

val cts_at_Ø_continuous_thm = save_thm( "cts_at_Ø_continuous_thm",
	conv_rule(BINDER_C eq_sym_conv) continuous_cts_at_Ø_thm);


val universe_Ø_connected_thm = save_thm ( "universe_Ø_connected_thm", (
set_goal([], ¨Universe ç OâR ConnectedÆ);
a(rewrite_tac[connected_def, space_t_Ø_thm] THEN PC_T1 "sets_ext1" rewrite_tac[]);
a(strip_asm_tac open_Ø_topology_thm THEN contr_tac);
a(lemma_tac¨∂f∑µt∑ f t = if t ç B then ÓØ 0 else ÓØ 1Æ THEN1 prove_∂_tac);
a(lemma_tac¨µt∑f Cts tÆ);
(* *** Goal "1" *** *)
a(rewrite_tac[cts_open_Ø_thm] THEN REPEAT strip_tac);
a(cases_tac¨ÓØ 0 ç AÆ THEN cases_tac¨ÓØ 1 ç AÆ);
(* *** Goal "1.1" *** *)
a(LEMMA_T ¨{x | f x ç A} = SpaceâT OâRÆ rewrite_thm_tac THEN_LIST
	[rewrite_tac[space_t_Ø_thm], ALL_FC_T rewrite_tac[space_t_open_thm]]);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN asm_rewrite_tac[]);
a(cases_tac ¨x'' ç BÆ THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(LEMMA_T ¨{x | f x ç A} = BÆ  asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN_TRY asm_rewrite_tac[]);
a(swap_nth_asm_concl_tac 1 THEN asm_rewrite_tac[]);
(* *** Goal "1.3" *** *)
a(LEMMA_T ¨{z | f z ç A} = CÆ  asm_rewrite_thm_tac);
a(LEMMA_T¨µt∑t ç B § ≥t ç CÆ asm_rewrite_thm_tac THEN1 asm_prove_tac[]);
a(PC_T1 "sets_ext1" REPEAT strip_tac THEN_TRY asm_rewrite_tac[]);
a(swap_nth_asm_concl_tac 1 THEN asm_rewrite_tac[]);
(* *** Goal "1.4" *** *)
a(LEMMA_T ¨{x | f x ç A} = {}Æ rewrite_thm_tac THEN_LIST
	[PC_T "sets_ext1" contr_tac, ALL_FC_T rewrite_tac[empty_open_thm]]);
a(POP_ASM_T ante_tac THEN spec_nth_asm_tac 8 ¨x''Æ THEN asm_rewrite_tac[]);
a(LEMMA_T¨µt∑t ç B § ≥t ç CÆ asm_rewrite_thm_tac THEN1 asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨µt∑≥f t = 1/2Æ THEN1 (strip_tac THEN cases_tac¨t ç BÆ THEN asm_rewrite_tac[]));
a(lemma_tac¨f x = ÓØ 1Æ THEN1 asm_rewrite_tac[]);
a(lemma_tac¨f x' = ÓØ 0Æ THEN1
	(cases_tac ¨x' ç BÆ THEN asm_rewrite_tac[] THEN asm_prove_tac[]));
a(DROP_NTH_ASM_T 5 discard_tac);
a(lemma_tac¨≥x = x'Æ THEN1  (contr_tac THEN all_var_elim_asm_tac THEN asm_prove_tac[]));
a(strip_asm_tac (list_µ_elim[¨xÆ, ¨x'Æ] Ø_less_cases_thm));
(* *** Goal "2.1" *** *)
a(ante_tac(list_µ_elim[¨fÆ, ¨xÆ, ¨x'Æ] intermediate_value_thm)
	THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨1/2Æ  THEN asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(ante_tac(list_µ_elim[¨fÆ, ¨x'Æ, ¨xÆ] intermediate_value_thm)
	THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨1/2Æ  THEN asm_rewrite_tac[]);
pop_thm()
));


val closed_interval_connected_thm = save_thm ( "closed_interval_connected_thm", (
set_goal([], ¨µx y∑ x < y ¥ ClosedInterval x y ç OâR ConnectedÆ);
a(REPEAT strip_tac);
a(ante_tac(list_µ_elim[¨xÆ, ¨yÆ,  ¨Ãt:Ø∑tÆ] cts_extension_thm1));
a(asm_rewrite_tac[id_cts_thm,
	conv_rule(ONCE_MAP_C eq_sym_conv) continuous_cts_at_Ø_thm] THEN strip_tac);
a(strip_asm_tac universe_Ø_connected_thm THEN strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[image_connected_thm]);
a(POP_ASM_T ante_tac THEN rewrite_tac[]);
a(bc_thm_tac(prove_rule[]¨µx y a∑x = y ¥ x ç a ¥ y ç aÆ));
a(rewrite_tac[closed_interval_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1);
a(cases_tac¨x'' < xÆ THEN1 ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨y < x''Æ THEN1
	(ALL_ASM_FC_T rewrite_tac[] THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨x º x'' ± x'' º yÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(all_var_elim_asm_tac1);
a(cases_tac¨y < x''Æ THEN1 ALL_ASM_FC_T rewrite_tac[]);
a(cases_tac¨x'' < xÆ THEN1
	(ALL_ASM_FC_T rewrite_tac[] THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨x º x'' ± x'' º yÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨x'Æ THEN ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));


val connected_Ø_thm = save_thm ( "connected_Ø_thm", (
set_goal([], ¨µX∑
		X ç OâR Connected
	§	µx y z∑x ç X ± y ç X ± x º z ± z º y ¥ z ç XÆ
);
a(REPEAT_N 3 strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[connected_def, space_t_Ø_thm, Ø_º_def] THEN REPEAT strip_tac
	THEN_TRY all_var_elim_asm_tac THEN contr_tac);
a(strip_asm_tac (µ_elim¨zÆ half_infinite_intervals_open_thm));
a(lemma_tac¨X Ä {t|t < z} ¿ {t | z < t}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a((cases_tac¨x' = zÆ THEN1 all_var_elim_asm_tac) THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2" *** *)
a(lemma_tac¨X ° {t|t < z} ° {t | z < t} = {}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1.2.1" *** *)
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2.2" *** *)
a(lemma_tac¨≥X Ä {t|t < z}Æ THEN PC_T "sets_ext1" contr_tac);
(* *** Goal "1.2.2.1" *** *)
a(spec_nth_asm_tac 1 ¨yÆ THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2.2.2" *** *)
a(lemma_tac¨≥X Ä {t|z < t}Æ THEN PC_T "sets_ext1" contr_tac);
(* *** Goal "1.2.2.2.1" *** *)
a(spec_nth_asm_tac 1 ¨xÆ THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2.2.2.2" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "2" *** *)
a(REPEAT strip_tac THEN strip_asm_tac open_Ø_topology_thm);
a(bc_thm_tac connected_pointwise_bc_thm);
a(REPEAT strip_tac);
a(strip_asm_tac (list_µ_elim[¨xÆ, ¨yÆ] Ø_less_cases_thm));
(* *** Goal "2.1" *** *)
a(∂_tac¨ClosedInterval x yÆ);
a(ALL_FC_T rewrite_tac[closed_interval_connected_thm]);
a(PC_T1 "sets_ext1" rewrite_tac[closed_interval_def]);
a(REPEAT strip_tac THEN all_asm_fc_tac[] THEN asm_rewrite_tac[Ø_º_def]);
(* *** Goal "2.2" *** *)
a(∂_tac¨{x}Æ THEN asm_rewrite_tac[enum_set_clauses]);
a(lemma_tac¨y ç SpaceâT OâRÆ THEN1 rewrite_tac[space_t_Ø_thm]);
a(ALL_FC_T rewrite_tac[singleton_connected_thm]);
(* *** Goal "2.3" *** *)
a(∂_tac¨ClosedInterval y xÆ);
a(ALL_FC_T rewrite_tac[closed_interval_connected_thm]);
a(PC_T1 "sets_ext1" rewrite_tac[closed_interval_def]);
a(REPEAT strip_tac THEN rename_tac[] THEN all_asm_fc_tac[] THEN asm_rewrite_tac[Ø_º_def]);
pop_thm()
));



val continuous_Ø_∏_Ø_Ø_thm = save_thm ( "continuous_Ø_∏_Ø_Ø_thm", (
set_goal([], ¨µX f∑
	X ç (OâR ∏âT OâR)
¥	(f ç (X ÚâT (OâR ∏âT OâR), OâR) Continuous
	§	µx y u v∑ f(u, v) ç OpenInterval x y ± (u, v) ç X ¥
		∂a b c d∑u ç OpenInterval a b ± v ç OpenInterval c d ±
			µs t∑	s ç OpenInterval a b ± t ç OpenInterval c d ± (s, t) ç X
			¥	f(s, t) ç OpenInterval x y)Æ);
a(rewrite_tac[continuous_def]);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[product_topology_thm]);
a(ALL_FC_T rewrite_tac [subspace_topology_space_t_thm, product_topology_space_t_thm]);
a(rewrite_tac[space_t_Ø_thm]);
a(rewrite_tac [open_Ø_def, product_topology_def, subspace_topology_def,
	merge_pcs_rule1 ["'bin_rel", "sets_ext"] prove_rule[]¨(Universe ∏ Universe) = UniverseÆ]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 4 discard_tac);
a(DROP_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨OpenInterval x yÆ));
(* *** Goal "1.1" *** *)
a(swap_nth_asm_concl_tac 1 THEN REPEAT strip_tac);
a(∂_tac¨xÆ THEN REPEAT strip_tac);
a(∂_tac¨yÆ THEN REPEAT strip_tac);
(* *** Goal "1.2" *** *)
a(lemma_tac¨(u, v) ç B ° XÆ THEN1
	(POP_ASM_T (rewrite_thm_tac o eq_sym_rule) THEN asm_rewrite_tac[]));
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4, 5] all_fc_tac);
a(MAP_EVERY ∂_tac [¨x''Æ, ¨y''Æ, ¨x'Æ, ¨y'Æ] THEN REPEAT strip_tac);
a(LEMMA_T¨(s, t) ç B ° XÆ ante_tac THEN1 REPEAT strip_tac);
(* *** Goal "1.2.1" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
a(lemma_tac¨(s, t) ç (A ∏ B')Æ THEN1 asm_rewrite_tac[∏_def]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
(* *** Goal "1.2.2" *** *)
a(DROP_NTH_ASM_T 12 (rewrite_thm_tac o eq_sym_rule) THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨{(s, t) | (s, t) ç X ±  f(s, t) ç A }Æ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [6] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4, 5, 10] all_fc_tac);
a(MAP_EVERY ∂_tac [¨OpenInterval a b ° OpenInterval x''' y'''Æ,
	¨OpenInterval c d ° OpenInterval x''  y''Æ] THEN REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(strip_asm_tac (list_µ_elim[¨aÆ, ¨bÆ, ¨x'''Æ, ¨y'''Æ] °_open_interval_thm));
a(MAP_EVERY ∂_tac [¨x''''Æ,	¨y''''Æ]);
a(POP_ASM_T (rewrite_thm_tac o eq_sym_rule) THEN REPEAT strip_tac);
(* *** Goal "2.1.2" *** *)
a(strip_asm_tac (list_µ_elim[¨cÆ, ¨dÆ, ¨x''Æ, ¨y''Æ] °_open_interval_thm));
a(MAP_EVERY ∂_tac [¨x''''Æ,	¨y''''Æ]);
a(POP_ASM_T (rewrite_thm_tac o eq_sym_rule) THEN REPEAT strip_tac);
(* *** Goal "2.1.3" *** *)
a(rewrite_tac[∏_def] THEN PC_T1 "sets_ext1" rewrite_tac[]);
a(REPEAT µ_tac THEN ¥_tac);
a(once_rewrite_tac[taut_rule¨µa b∑a ± b § a ± (a ¥ b)Æ] THEN REPEAT strip_tac);
(* *** Goal "2.1.3.1" *** *)
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
a(lemma_tac¨(x1, x2) ç (A' ∏ B)Æ THEN1 asm_rewrite_tac[∏_def]);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]¨µx a b∑x ç a ± a Ä b ¥ x ç bÆ]);
(* *** Goal "2.1.3.2" *** *)
a(all_asm_fc_tac[] THEN PC_T1 "sets_ext1" all_asm_fc_tac[]);
(* *** Goal "2.2" *** *)
a(PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val continuous_Ø_∏_Ø_Ø_thm1 = save_thm ( "continuous_Ø_∏_Ø_Ø_thm1", (
set_goal([], ¨µf∑
	f ç ((OâR ∏âT OâR), OâR) Continuous
	§	µx y u v∑ f(u, v) ç OpenInterval x y ¥
		∂a b c d∑u ç OpenInterval a b ± v ç OpenInterval c d ±
			µs t∑	s ç OpenInterval a b ± t ç OpenInterval c d
			¥	f(s, t) ç OpenInterval x yÆ);
a(ante_tac(µ_elim¨SpaceâT (OâR ∏âT OâR)Æ continuous_Ø_∏_Ø_Ø_thm));
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[product_topology_thm]);
a(ALL_FC_T rewrite_tac [trivial_subspace_topology_thm, space_t_open_thm]);
a(ALL_FC_T rewrite_tac [product_topology_space_t_thm]);
a(rewrite_tac[space_t_Ø_thm,
	merge_pcs_rule1 ["'bin_rel", "sets_ext"] prove_rule[]¨(Universe ∏ Universe) = UniverseÆ]);
pop_thm()
));


set_goal([], ¨µX∑
	(µx y u v∑ f(u, v) ç OpenInterval x y ± (u, v) ç X ¥
		∂a b c d∑u ç OpenInterval a b ± v ç OpenInterval c d ±
			µs t∑	s ç OpenInterval a b ± t ç OpenInterval c d ± (s, t) ç X
			¥	f(s, t) ç OpenInterval x y)
§	(µe u v∑ ÓØ 0 < e ± (u, v) ç X ¥
		∂d1 d2 ∑ ÓØ 0 < d1 ± ÓØ 0 < d2 ±
			µs t∑	Abs(s - u) < d1 ± Abs(t - v) < d2 ± (s, t) ç X
			¥	Abs(f(s, t) - f(u, v)) < e)
Æ);
a(rewrite_tac[open_interval_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(list_spec_nth_asm_tac 3 [¨f(u, v) + ~eÆ, ¨f(u, v) + eÆ, ¨uÆ, ¨vÆ]
	THEN_TRY SOLVED_T(PC_T1"Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨ÓØ 0 < u + ~a ±  ÓØ 0 < b + ~u ± ÓØ 0 < v + ~c ± ÓØ 0 < d + ~vÆ
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(cases_tac¨u + ~a < b + ~uÆ THEN cases_tac¨v + ~c < d + ~vÆ);
(* *** Goal "1.1" *** *)
a(∂_tac¨u + ~aÆ THEN ∂_tac¨v + ~cÆ THEN  asm_rewrite_tac[]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm] THEN REPEAT µ_tac THEN ¥_tac);
a(DROP_NTH_ASM_T 12 bc_thm_tac);
a(PC_T1"Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2" *** *)
a(∂_tac¨u + ~aÆ THEN ∂_tac¨d + ~vÆ THEN  asm_rewrite_tac[]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm] THEN REPEAT µ_tac THEN ¥_tac);
a(DROP_NTH_ASM_T 12 bc_thm_tac);
a(PC_T1"Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.3" *** *)
a(∂_tac¨b + ~uÆ THEN ∂_tac¨v + ~cÆ THEN  asm_rewrite_tac[]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm] THEN REPEAT µ_tac THEN ¥_tac);
a(DROP_NTH_ASM_T 12 bc_thm_tac);
a(PC_T1"Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.4" *** *)
a(∂_tac¨b + ~uÆ THEN ∂_tac¨d + ~vÆ THEN  asm_rewrite_tac[]);
a(ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm] THEN REPEAT µ_tac THEN ¥_tac);
a(DROP_NTH_ASM_T 12 bc_thm_tac);
a(PC_T1"Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨∂e∑ÓØ 0 < e ± e º f(u, v) + ~x ± e º  y + ~(f(u, v))Æ THEN1
	(cases_tac ¨f(u, v) + ~x º y + ~(f(u, v))Æ  THEN_LIST
	[∂_tac¨f(u, v) + ~xÆ THEN PC_T1 "Ø_lin_arith" asm_prove_tac[],
	 ∂_tac¨y + ~(f(u, v))Æ THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]]));
a(all_asm_fc_tac[]);
a(MAP_EVERY ∂_tac [¨u + ~d1Æ, ¨u + d1Æ, ¨v + ~d2Æ, ¨v + d2Æ]);
a(strip_tac THEN_TRY SOLVED_T (PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(strip_tac THEN_TRY SOLVED_T (PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(REPEAT µ_tac THEN ¥_tac);
a(LIST_SPEC_NTH_ASM_T 6 [¨sÆ, ¨tÆ] ante_tac);
a(ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
val continuous_Ø_∏_Ø_Ø_lemma = pop_thm ();
val continuous_Ø_∏_Ø_Ø_thm3 = save_thm(
	"continuous_Ø_∏_Ø_Ø_thm3",
	rewrite_rule[continuous_Ø_∏_Ø_Ø_lemma] continuous_Ø_∏_Ø_Ø_thm);
val continuous_Ø_∏_Ø_Ø_thm4 = save_thm(
	"continuous_Ø_∏_Ø_Ø_thm4",
	rewrite_rule[
		rewrite_rule[](µ_elim¨Universe:(Ø ∏ Ø) SETÆ
			continuous_Ø_∏_Ø_Ø_lemma)] continuous_Ø_∏_Ø_Ø_thm1);

val plus_continuous_Ø_∏_Ø_thm = save_thm ( "plus_continuous_Ø_∏_Ø_thm", (
set_goal([], ¨ (Uncurry $+) ç ((OâR ∏âT OâR), OâR) Continuous Æ);
a(rewrite_tac[continuous_Ø_∏_Ø_Ø_thm1] THEN REPEAT strip_tac);
a(MAP_EVERY ∂_tac[ ¨u - (1/2)*(u + v - x)Æ, ¨u + (1/2)*(y - (u + v))Æ,
	¨v - (1/2)*(u + v - x)Æ, ¨v + (1/2)*(y - (u + v))Æ]);
a(POP_ASM_T ante_tac THEN rewrite_tac[open_interval_def] THEN REPEAT strip_tac
	THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val times_continuous_Ø_∏_Ø_thm = save_thm ( "times_continuous_Ø_∏_Ø_thm", (
set_goal([], ¨ (Uncurry $*) ç ((OâR ∏âT OâR), OâR) Continuous Æ);
a(rewrite_tac[continuous_Ø_∏_Ø_Ø_thm4] THEN REPEAT strip_tac);
a(lemma_tac¨∂t∑Abs u + ÓØ 1 < t ± Abs v < tÆ);
(* *** Goal "1" *** *)
a(cases_tac ¨Abs u + ÓØ 1 <  Abs vÆ THEN_LIST [
	∂_tac ¨ Abs v + ÓØ 1Æ, ∂_tac¨Abs u + ÓØ 2Æ]
	THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨ÓØ 0  < ÓØ 2 * tÆ THEN1
	(strip_asm_tac(µ_elim¨vÆØ_0_º_abs_thm) THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨ÓØ 0 < e * (ÓØ 2 * t) õ-õ1Æ THEN1
	(all_fc_tac[Ø_0_less_0_less_recip_thm] THEN all_fc_tac[Ø_0_less_0_less_times_thm]));
a(lemma_tac¨∂d∑ÓØ 0 <  d ± d < ÓØ 1 ± d <  e * (ÓØ 2 * t) õ-õ1Æ);
(* *** Goal "2.1" *** *)
a(cases_tac ¨ÓØ 1 < e * (ÓØ 2 * t) õ-õ1ÆTHEN_LIST [
	∂_tac ¨1/2Æ, ∂_tac¨(1/2)* e * (ÓØ 2 * t) õ-õ1Æ]
	THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2.2" *** *)
a(∂_tac¨dÆ THEN ∂_tac¨dÆ THEN REPEAT strip_tac);
a(bc_thm_tac (rewrite_rule[]times_lim_seq_lemma));
a(∂_tac¨tÆ THEN REPEAT strip_tac THEN_TRY PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(DROP_NTH_ASM_T 2 ante_tac THEN ALL_FC_T1 fc_§_canon rewrite_tac[Ø_abs_diff_bounded_thm]);
a(DROP_NTH_ASM_T 8 ante_tac);
a(cases_tac¨ÓØ 0 º sÆ THEN cases_tac ¨ÓØ 0 º uÆ
	THEN asm_rewrite_tac[Ø_abs_def]
	THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val cond_continuous_Ø_thm = save_thm ( "cond_continuous_Ø_thm", (
set_goal([], ¨µb c f g ” ‘∑
	” ç  Topology
±	‘ ç  Topology
±	c ç (”, OâR) Continuous
±	f ç (”, ‘) Continuous
±	g ç (”, ‘) Continuous
±	(µx∑x ç SpaceâT ” ± c x = b ¥ f x = g x)
¥	(Ãx∑if c x º b then f x else g x) ç (”, ‘) Continuous
Æ);
a(REPEAT strip_tac);
a(LEMMA_T ¨µx∑c x º b § x ç {t|c t º b}Æ pure_once_rewrite_thm_tac THEN1
	rewrite_tac[]);
a(bc_thm_tac cond_continuous_thm THEN REPEAT strip_tac);
a(POP_ASM_T ante_tac THEN rewrite_tac[Ø_≥_º_less_thm] THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 3 bc_thm_tac);
a(strip_asm_tac (list_µ_elim[¨c xÆ, ¨bÆ] Ø_less_cases_thm) THEN
	REPEAT strip_tac THEN  i_contr_tac);
(* *** Goal "1" *** *)
a(lemma_tac¨{t | t < b} ç OâRÆ THEN1
	rewrite_tac[half_infinite_intervals_open_thm]);
a(DROP_NTH_ASM_T 7 (fn th => all_fc_tac[rewrite_rule[continuous_def] th]));
a(spec_nth_asm_tac 5 ¨{x|x ç SpaceâT ” ± c x ç {t|t < b}}Æ);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨{t | b < t} ç OâRÆ THEN1
	rewrite_tac[half_infinite_intervals_open_thm]);
a(DROP_NTH_ASM_T 7 (fn th => all_fc_tac[rewrite_rule[continuous_def] th]));
a(spec_nth_asm_tac 5 ¨{x|x ç SpaceâT ” ± c x ç {t|b < t}}Æ);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val d_Ø_metric_thm = save_thm ( "d_Ø_metric_thm", (
set_goal([], ¨
	DâR ç Metric
Æ);
a(rewrite_tac[metric_def, d_Ø_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[Ø_0_º_abs_thm]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN rewrite_tac[Ø_abs_eq_0_thm] THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[Ø_abs_0_thm]);
(* *** Goal "4" *** *)
a(pure_rewrite_tac[pc_rule1 "Ø_lin_arith" prove_rule[] ¨y + ~x = ~(x + ~y)Æ, Ø_abs_minus_thm]);
a(rewrite_tac[]);
(* *** Goal "5" *** *)
a(rewrite_tac[pc_rule1 "Ø_lin_arith" prove_rule[] ¨z + ~x = (y + ~x) + (z + ~y)Æ, Ø_abs_plus_thm]);
pop_thm()
));


val d_Ø_open_Ø_thm = save_thm ( "d_Ø_open_Ø_thm", (
set_goal([], ¨
	DâR MetricTopology = OâR
Æ);
a(PC_T1 "sets_ext1" rewrite_tac[metric_topology_def, open_Ø_delta_thm, d_Ø_def] THEN REPEAT strip_tac);
pop_thm()
));


val d_Ø_2_metric_thm = save_thm ( "d_Ø_2_metric_thm", (
set_goal([], ¨
	DâR2 ç Metric
Æ);
a(LEMMA_T ¨DâR2 = (Ã ((x1, x2), y1, y2)∑ DâR (x1, y1) + DâR (x2, y2))Æ rewrite_thm_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[d_Ø_def] THEN REPEAT strip_tac);
a(pure_once_rewrite_tac[prove_rule[]¨x = (Fst x, Snd x)Æ]);
a(pure_rewrite_tac[d_Ø_2_def1]);
a(rewrite_tac[]);
(* *** Goal "2" *** *)
a(bc_thm_tac product_metric_thm THEN rewrite_tac[d_Ø_metric_thm]);
pop_thm()
));


val d_Ø_2_open_Ø_∏_open_Ø_thm = save_thm ( "d_Ø_2_open_Ø_∏_open_Ø_thm", (
set_goal([], ¨
	DâR2 MetricTopology = (OâR ∏âT OâR)
Æ);
a(LEMMA_T ¨DâR2 = (Ã ((x1, x2), y1, y2)∑ DâR (x1, y1) + DâR (x2, y2))Æ rewrite_thm_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[d_Ø_def] THEN REPEAT strip_tac);
a(pure_once_rewrite_tac[prove_rule[]¨x = (Fst x, Snd x)Æ]);
a(pure_rewrite_tac[d_Ø_2_def1]);
a(rewrite_tac[]);
(* *** Goal "2" *** *)
a(strip_asm_tac d_Ø_metric_thm);
a(ALL_FC_T rewrite_tac[product_metric_topology_thm]);
a(rewrite_tac[d_Ø_open_Ø_thm]);
pop_thm()
));


val open_Ø_hausdorff_thm = save_thm ( "open_Ø_hausdorff_thm", (
set_goal([], ¨
	OâR ç Hausdorff
Æ);
a(rewrite_tac[eq_sym_rule d_Ø_open_Ø_thm]
	THEN bc_thm_tac metric_topology_hausdorff_thm
	THEN rewrite_tac[d_Ø_metric_thm]);
pop_thm()
));



val open_Ø_∏_open_Ø_hausdorff_thm = save_thm ( "open_Ø_∏_open_Ø_hausdorff_thm", (
set_goal([], ¨
	(OâR ∏âT OâR) ç Hausdorff
Æ);
a(rewrite_tac[eq_sym_rule d_Ø_2_open_Ø_∏_open_Ø_thm]
	THEN bc_thm_tac metric_topology_hausdorff_thm
	THEN rewrite_tac[d_Ø_2_metric_thm]);
pop_thm()
));


val Ø_lebesgue_number_thm = save_thm (
	"Ø_lebesgue_number_thm",
	pc_rule1 "predicates"
	rewrite_rule[d_Ø_def, d_Ø_metric_thm, d_Ø_open_Ø_thm, compact_compact_Ø_thm]
	(µ_elim¨DâRÆlebesgue_number_thm));

val closed_interval_lebesgue_number_thm = save_thm (
	"closed_interval_lebesgue_number_thm",
	all_µ_intro(
	pc_rule1 "predicates"
	rewrite_rule[closed_interval_compact_thm]
	(µ_elim¨ClosedInterval y zÆ Ø_lebesgue_number_thm)));

val dissect_unit_interval_thm = save_thm ( "dissect_unit_interval_thm", (
set_goal([], ¨µx∑
	0. < x
¥	∂n t∑ 0 < n ± t 0 = 0. ± t n = 1.
±	(µi j∑ i < j ¥ t i < t j)
±	(µi∑t (i + 1) - t i < x)
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂n t∑ t 0 = 0. ± t n = 1.
±	(µi∑t i < t (i + 1) ± t (i + 1) < t i + x)Æ);
(* *** Goal "1" *** *)
a(lemma_tac¨∂n y∑ 0. < y ± y < x ± ÓØ n * y = 1.Æ);
(* *** Goal "1.1" *** *)
a(strip_asm_tac (µ_elim¨xÆ Ø_archimedean_recip_thm));
a(lemma_tac¨0. < ÓØ(m + 1)Æ THEN1 rewrite_tac[ÓØ_less_thm]);
a(lemma_tac¨≥ÓØ(m + 1) = 0.Æ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(∂_tac¨m+1Æ THEN ∂_tac¨ÓØ(m+1) õ-õ1Æ THEN
	ALL_FC_T asm_rewrite_tac[Ø_0_less_0_less_recip_thm,
		Ø_recip_clauses]);
(* *** Goal "1.2" *** *)
a(∂_tac¨nÆ THEN ∂_tac¨Ãi∑ ÓØ i * yÆ THEN asm_rewrite_tac[
		ÓØ_plus_homomorphism_thm,
		Ø_times_plus_distrib_thm]);
(* *** Goal "2" *** *)
a(∂_tac¨nÆ THEN ∂_tac¨tÆ THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(swap_nth_asm_concl_tac 2 THEN LEMMA_T¨n = 0Æ asm_rewrite_thm_tac);
a(PC_T1 "lin_arith" asm_prove_tac[]);
(* *** Goal "2.2" *** *)
a(LEMMA_T ¨i + 1 º jÆ (strip_asm_tac o rewrite_rule[º_def])
	THEN1 PC_T1 "lin_arith" asm_prove_tac[]);
a(all_var_elim_asm_tac1);
a(POP_ASM_T discard_tac THEN induction_tac¨i'Æ THEN asm_rewrite_tac[plus_assoc_thm1]);
a(bc_thm_tac Ø_less_trans_thm THEN ∂_tac¨t ((i + 1) + i')Æ THEN
	asm_rewrite_tac[]);
(* *** Goal "2.3" *** *)
a(lemma_tac¨t (i + 1) < t i + xÆ THEN1 asm_rewrite_tac[]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val product_interval_cover_thm1 = save_thm ( "product_interval_cover_thm1", (
set_goal([], ¨µ‘ U x∑
	‘ ç Topology
±	U Ä (‘ ∏âT OâR)
±	x ç SpaceâT ‘
±	(µs∑ s ç ClosedInterval 0. 1. ¥ ∂B∑ (x, s) ç B ± B ç U) 
¥	∂n t A∑ t 0 = 0. ± t n = 1. ± (µi∑t i < t (i + 1))
	±	x ç A
	±	A ç ‘
	±	µi∑ i < n ¥ ∂B∑ B ç U ± (A ∏ ClosedInterval (t i) (t (i+1))) Ä B
Æ);
a(strip_asm_tac open_Ø_topology_thm);
a(REPEAT strip_tac);
a(lemma_tac¨(‘ ∏âT OâR) ç TopologyÆ THEN1 basic_topology_tac[]);
a(lemma_tac¨
	{I | I ç OâR ±
	∂X B∑ x ç X ± X ç ‘ ± B ç U ± (X ∏ I) Ä B} Ä OâRÆ
	THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(lemma_tac¨
	ClosedInterval 0. 1. Ä
	ﬁ {I | I ç OâR ± ∂X B∑ x ç X ± X ç ‘ ± B ç U ± (X ∏ I) Ä B}
Æ);
(* *** Goal "1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]
	¨µb u t∑ b ç u ± u Ä t ¥ b ç tÆ]
	THEN swap_nth_asm_concl_tac 1);
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]);
a(rewrite_tac[product_topology_def] THEN swap_nth_asm_concl_tac 1
	THEN strip_tac THEN rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [1] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(∂_tac¨B''Æ THEN REPEAT strip_tac);
a(∂_tac¨AÆ THEN ∂_tac¨BÆ THEN REPEAT strip_tac);
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]
	¨µa b c∑ a Ä b ± b Ä c ¥ a Ä cÆ]);
(* *** Goal "2" *** *)
a(all_fc_tac[closed_interval_lebesgue_number_thm]);
a(all_fc_tac[dissect_unit_interval_thm]);
a(∂_tac¨nÆ THEN ∂_tac ¨tÆ THEN asm_rewrite_tac[]);
a(lemma_tac¨∂Q∑µi∑ i < n ¥
	x ç Q i ± Q i ç ‘ ±
	∂B∑B ç U ± (Q i ∏ ClosedInterval (t i) (t(i + 1))) Ä BÆ
	THEN prove_∂_tac THEN strip_tac);
(* *** Goal "2.1" *** *)
a(cases_tac¨i' < nÆ THEN asm_rewrite_tac[]);
a(lemma_tac¨t i' ç ClosedInterval 0. 1.Æ);
(* *** Goal "2.1.1" *** *)
a(rewrite_tac[closed_interval_def]);
a(cases_tac¨i' = 0Æ THEN1 asm_rewrite_tac[]);
a(lemma_tac¨0 < i'Æ THEN1 PC_T1 "lin_arith" asm_prove_tac[]);
a(rewrite_tac[Ø_º_def] THEN LIST_DROP_NTH_ASM_T [5] (ALL_FC_T (MAP_EVERY ante_tac)));
a(asm_rewrite_tac[] THEN taut_tac);
(* *** Goal "2.1.2" *** *)
a(LIST_DROP_NTH_ASM_T [8] all_fc_tac);
a(∂_tac¨XÆ THEN REPEAT strip_tac THEN ∂_tac¨BÆ THEN REPEAT strip_tac);
a(bc_thm_tac(pc_rule1 "sets_ext1" prove_rule[]
		¨µa b c∑ a Ä b ± b Ä c ¥ a Ä cÆ)
	THEN ∂_tac¨X ∏ AÆ THEN REPEAT strip_tac);
a(bc_thm_tac(pc_rule1 "sets_ext1" prove_rule[∏_def]
		¨µx i a∑ i Ä a ¥ (x ∏ i) Ä (x ∏ a)Æ));
a(rewrite_tac[closed_interval_def] THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(lemma_tac¨Abs(x' - t i') < eÆ);
(* *** Goal "2.1.2.1" *** *)
a(rewrite_tac[Ø_abs_def]);
a(LEMMA_T ¨0. º x' + ~ (t i')Æ rewrite_thm_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(lemma_tac¨t(i' + 1) - t i' < eÆ THEN1 asm_rewrite_tac[]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2.1.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
(* *** Goal "2.2" *** *)
a(strip_asm_tac(rewrite_rule[range_finite_size_thm]
	(list_µ_elim[¨QÆ, ¨{i | i < n}Æ]finite_image_thm)));
a(∂_tac¨•{y|∂ x∑ x < n ± y = Q x}Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(all_var_elim_asm_tac1 THEN LIST_DROP_NTH_ASM_T [3] all_fc_tac);
(* *** Goal "2.2.2" *** *)
a(bc_thm_tac (•_open_thm) THEN asm_rewrite_tac[]);
a(strip_tac THEN1 PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(∂_tac¨Q 0Æ THEN asm_rewrite_tac[]);
a(∂_tac¨0Æ THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac);
a(all_var_elim_asm_tac1 THEN LIST_DROP_NTH_ASM_T [3] all_fc_tac);
(* *** Goal "2.2.3" *** *)
a(DROP_NTH_ASM_T 3 (strip_asm_tac o µ_elim¨iÆ));
a(∂_tac¨BÆ THEN REPEAT strip_tac);
a(bc_thm_tac(pc_rule1 "sets_ext1" prove_rule[]
		¨µa b c∑ a Ä b ± b Ä c ¥ a Ä cÆ)
	THEN ∂_tac¨Q i ∏ ClosedInterval (t i) (t (i + 1))Æ THEN REPEAT strip_tac);
a(bc_thm_tac(pc_rule1 "sets_ext1" prove_rule[∏_def]
		¨µx y i∑ x Ä y ¥ (x ∏ i) Ä (y ∏ i)Æ));
a(DROP_NTH_ASM_T 5 ante_tac THEN DROP_ASMS_T discard_tac);
a(strip_tac THEN PC_T "sets_ext1" strip_tac);
a(rewrite_tac[•_def] THEN REPEAT strip_tac);
a(asm_prove_tac[]);
(* *** Goal "2.3" *** *)
a(strip_tac THEN DROP_NTH_ASM_T 3 bc_thm_tac THEN REPEAT strip_tac);
pop_thm()
));


val inc_seq_thm = save_thm ( "inc_seq_thm", (
set_goal([], ¨µt: Ó ≠ Ø; i j∑
	(µi∑ t i < t (i + 1))
§	(µi j∑ i < j ¥ t i < t j)Æ);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(POP_ASM_T ante_tac THEN induction_tac¨jÆ THEN strip_tac);
(* *** Goal "1.1" *** *)
a(lemma_tac¨i = jÆ THEN1 PC_T1 "lin_arith" asm_prove_tac[]
	THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(bc_thm_tac Ø_less_trans_thm THEN ∂_tac¨t jÆ
	THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T bc_thm_tac THEN rewrite_tac[]);
(* *** Goal "2" *** *)
pop_thm()
));

val product_interval_cover_thm = save_thm ("product_interval_cover_thm",
	rewrite_rule[inc_seq_thm] product_interval_cover_thm1);
rewrite_rule[cts_at_Ø_continuous_thm] minus_cts_thm;


local
	
val Ø_continuity_fact_thms : THM list =
	map (rewrite_rule[cts_at_Ø_continuous_thm]) (
		Ø_Ó_exp_cts_thm::
		minus_cts_thm::
		exp_cts_thm::
		(map all_µ_intro o strip_±_rule o all_µ_elim)
			sin_cos_cts_thm) @ [
	plus_continuous_Ø_∏_Ø_thm,
	times_continuous_Ø_∏_Ø_thm,
	open_Ø_topology_thm,
	space_t_Ø_thm];


in
(*
*)
fun Ø_continuity_tac (thms : THM list): TACTIC = (
	basic_continuity_tac (thms @ Ø_continuity_fact_thms)
);
end (* local ... in ... end *);



open_theory "homotopy";
set_merge_pcs["basic_hol1", "'sets_alg", "'˙", "'Ø"];
val paths_def = get_spec¨$PathsÆ;
val path_connected_def = get_spec¨$PathConnectedÆ;
val locally_path_connected_def = get_spec¨LocallyPathConnectedÆ;
val homotopy_def = get_spec¨$HomotopyÆ;
val homotopy_class_def = get_spec¨$HomotopyClassÆ;
val path_plus_def = get_spec¨$+âPÆ;
val path_0_def = get_spec¨0âPÆ;
val path_minus_def = get_spec¨~âPÆ;
val homotopy_lifting_property_def = get_spec¨HomotopyLiftingPropertyÆ;

val path_connected_connected_thm = save_thm ( "path_connected_connected_thm", (
set_goal([], ¨µ‘ X∑
	‘ ç Topology
±	X ç ‘ PathConnected
¥	X ç ‘ Connected
Æ);
a(rewrite_tac[path_connected_def, paths_def] THEN REPEAT strip_tac);
a(bc_thm_tac connected_pointwise_bc_thm THEN REPEAT strip_tac);
a(list_spec_nth_asm_tac 3 [¨xÆ, ¨yÆ]);
a(ante_tac(list_µ_elim[¨fÆ, ¨Universe:Ø SETÆ, ¨OâRÆ, ¨‘Æ] image_connected_thm));
a(pure_asm_rewrite_tac[open_Ø_topology_thm, universe_Ø_connected_thm]);
a(rewrite_tac[] THEN REPEAT strip_tac);
a(∂_tac¨{y|∂ x∑ y = f x}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(all_var_elim_asm_tac1 THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨ÓØ 0Æ THEN asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(∂_tac¨ÓØ 1Æ THEN asm_rewrite_tac[]);
pop_thm()
));


val product_path_connected_thm = save_thm ( "product_path_connected_thm", (
set_goal([], ¨µ” ‘ X Y∑
	” ç Topology
±	‘ ç Topology
±	X ç ” PathConnected
±	Y ç ‘ PathConnected
¥	(X ∏ Y) ç (” ∏âT ‘) PathConnected
Æ);
a(rewrite_tac[path_connected_def, paths_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(LIST_GET_NTH_ASM_T [2, 4] (MAP_EVERY ante_tac));
a(MERGE_PCS_T1 ["'bin_rel", "sets_ext1"] prove_tac[]);
(* *** Goal "2" *** *)
a(POP_ASM_T ante_tac THEN POP_ASM_T ante_tac);
a(rewrite_tac[∏_def] THEN REPEAT strip_tac);
a(list_spec_nth_asm_tac 7 [¨Fst xÆ, ¨Fst yÆ]);
a(list_spec_nth_asm_tac 11 [¨Snd xÆ, ¨Snd yÆ]);
(* *** Goal "2.1" *** *)
a(∂_tac¨Ãt∑(f t, f' t)Æ THEN asm_rewrite_tac[] THEN REPEAT strip_tac
	THEN_TRY SOLVED_T (ALL_ASM_FC_T asm_rewrite_tac[]));
a(bc_thm_tac product_continuous_thm THEN REPEAT strip_tac);
a(accept_tac open_Ø_topology_thm);
pop_thm()
));


val homotopy_class_refl_thm = save_thm ( "homotopy_class_refl_thm", (
set_goal([], ¨µ” X ‘ f∑
	” ç Topology
±	‘ ç Topology
±	f ç (”, ‘) Continuous
¥	f ç ((”, X, ‘) HomotopyClass) f
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(asm_tac open_Ø_topology_thm);
a(∂_tac¨Ã x∑ f (Fst x)Æ THEN asm_rewrite_tac[]);
a(Ø_continuity_tac[]);
pop_thm()
));

val Ã_un_¬_rand_conv : CONV = (fn tm =>
	let	val (v, _) = dest_Ã tm;
	in	SIMPLE_Ã_C (RAND_C (un_¬_conv v)) tm
	end
);



val homotopy_class_sym_thm = save_thm ( "homotopy_class_sym_thm", (
set_goal([], ¨µ” : 'a SET SET; X ‘ f g∑
	” ç Topology
±	‘ ç Topology
±	g ç ((”, X, ‘) HomotopyClass) f
¥	f ç ((”, X, ‘) HomotopyClass) g
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨Ã xt∑ H(Fst xt, ÓØ 1 -  Snd xt)Æ THEN asm_rewrite_tac[]);
a(Ø_continuity_tac[]);
pop_thm()
));


val homotopy_class_trans_thm = save_thm ( "homotopy_class_trans_thm", (
set_goal([], ¨µ” : 'a SET SET; X ‘ f g h∑
	” ç Topology
±	‘ ç Topology
±	g ç ((”, X, ‘) HomotopyClass) f
±	h ç ((”, X, ‘) HomotopyClass) g
¥	h ç ((”, X, ‘) HomotopyClass) f
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨
	Ã xt∑
	if	Snd xt º 1/2
	then	H(Fst xt, ÓØ 2 * Snd xt)
	else	H'(Fst xt, ÓØ 2 * (Snd xt + ~ (1/2)))Æ THEN asm_rewrite_tac[]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(strip_asm_tac open_Ø_topology_thm THEN ALL_FC_T asm_rewrite_tac[product_topology_thm]);
a(REPEAT strip_tac THEN_TRY Ø_continuity_tac[]
	THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(LEMMA_T ¨µt∑ H(x, t) = g x ± H'(x, t) = g xÆ rewrite_thm_tac THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LIST_DROP_NTH_ASM_T [6] (rewrite_tac o map (conv_rule(ONCE_MAP_C eq_sym_conv))));
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(LIST_DROP_NTH_ASM_T [3] (rewrite_tac o map (conv_rule(ONCE_MAP_C eq_sym_conv))));
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2.3" *** *)
a(cases_tac ¨s º 1/2Æ THEN cases_tac ¨t º 1/2Æ THEN  asm_rewrite_tac[]);
pop_thm()
));


val homotopy_Ä_thm = save_thm ( "homotopy_Ä_thm", (
set_goal([], ¨µ” X Y ‘ H∑
	” ç Topology
±	‘ ç Topology
±	H ç (”, X, ‘) Homotopy
±	Y Ä X
¥	H ç (”, Y, ‘) Homotopy
Æ);
a(rewrite_tac[ homotopy_def ] THEN REPEAT strip_tac);
a(PC_T1 "sets_ext1" all_asm_fc_tac[]);
a(ALL_ASM_FC_T rewrite_tac[]);
pop_thm()
));


val homotopy_class_Ä_thm = save_thm ( "homotopy_class_Ä_thm", (
set_goal([], ¨µ” X Y ‘ f g∑
	” ç Topology
±	‘ ç Topology
±	g ç ((”, X, ‘) HomotopyClass) f
±	Y Ä X
¥	g ç ((”, Y, ‘) HomotopyClass) f
Æ);
a(rewrite_tac[ homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨HÆ THEN ALL_FC_T asm_rewrite_tac[homotopy_Ä_thm]);
pop_thm()
));


val homotopy_class_comp_left_thm = save_thm ( "homotopy_class_comp_left_thm", (
set_goal([], ¨µ“ ” ‘ X f g h∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	g ç ((“, X, ”) HomotopyClass) f
±	h ç (”,‘) Continuous
¥	(Ãx∑h(g x)) ç ((“, X, ‘) HomotopyClass) (Ãx∑h(f x))
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨Ãxt∑ h(H xt)Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨”Æ THEN REPEAT strip_tac);
a(bc_thm_tac product_topology_thm THEN asm_rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "2" *** *)
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val homotopy_class_comp_right_thm = save_thm ( "homotopy_class_comp_right_thm", (
set_goal([], ¨µ“ ” ‘ X f g h∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	g ç ((”, X, ‘) HomotopyClass) f
±	h ç (“,”) Continuous
¥	(Ãx∑g(h x)) ç ((“, {x | h x ç X}, ‘) HomotopyClass) (Ãx∑f(h x))
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨Ãxt∑ H ((Ãxt∑ (h(Fst xt), Snd xt)) xt)Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac comp_continuous_thm);
a(strip_asm_tac open_Ø_topology_thm);
a(∂_tac¨(” ∏âT OâR)Æ THEN ALL_FC_T asm_rewrite_tac[product_topology_thm]);
a(pure_once_rewrite_tac[prove_rule[]¨µx∑h(Fst x) = (Ãx∑h(Fst x))xÆ]);
a(bc_thm_tac product_continuous_thm);
a(ALL_FC_T asm_rewrite_tac[product_topology_thm] THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨“Æ THEN ALL_FC_T asm_rewrite_tac[product_topology_thm]);
a(rewrite_tac[prove_rule[]¨Fst = (Ã(x, y)∑ x)Æ]);
a(bc_thm_tac left_proj_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "1.2" *** *)
a(rewrite_tac[prove_rule[]¨Snd = (Ã(x, y)∑ y)Æ]);
a(bc_thm_tac right_proj_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val homotopy_class_Ø_thm = save_thm ( "homotopy_class_Ø_thm", (
set_goal([], ¨µ‘ f g ∑
	‘ ç Topology
±	f ç (‘,OâR) Continuous
±	g ç (‘,OâR) Continuous
¥	g ç ((‘, {x | g x = f x}, OâR) HomotopyClass) f
Æ);
a(rewrite_tac[ homotopy_def, homotopy_class_def ] THEN REPEAT strip_tac);
a(∂_tac¨Ãxt∑ (ÓØ 1 + ~(Snd xt))*f (Fst xt) + (Snd xt)*g(Fst xt) Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(pure_once_rewrite_tac[prove_rule[]¨µx y:Ø∑ x + y = Uncurry $+ (x, y)Æ]);
a(conv_tac (LEFT_C Ã_un_¬_rand_conv));
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨OâR ∏âT OâRÆ THEN asm_rewrite_tac[plus_continuous_Ø_∏_Ø_thm]);
a(strip_asm_tac open_Ø_topology_thm);
a(ALL_FC_T asm_rewrite_tac[product_topology_thm]);
a(Ø_continuity_tac[]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[] THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "4" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));




val half_open_interval_retract_thm = save_thm ( "half_open_interval_retract_thm", (
set_goal([], ¨µb∑
	(Ãs∑ if s º b then s else b) ç
	(OâR, {s | s º b} ÚâT OâR) Continuous
Æ);
a(REPEAT strip_tac THEN strip_asm_tac open_Ø_topology_thm);
a(lemma_tac¨{s | s º b} Ä SpaceâT OâRÆ
	THEN1 rewrite_tac[space_t_Ø_thm]);
a(ALL_FC_T1 fc_§_canon rewrite_tac
	[subspace_range_continuous_§_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(asm_rewrite_tac[space_t_Ø_thm]);
a(REPEAT strip_tac THEN Ø_continuity_tac[]);
(* *** Goal "2" *** *)
a(cases_tac¨x º bÆ THEN asm_rewrite_tac[]);
pop_thm()
));


val closed_interval_retract_thm = save_thm ( "closed_interval_retract_thm", (
set_goal([], ¨µa b∑
	a º b
¥	(Ãs∑ if s º a then a else if s º b then s else b) ç
	(OâR, ClosedInterval a b ÚâT OâR) Continuous
Æ);
a(REPEAT strip_tac THEN strip_asm_tac open_Ø_topology_thm);
a(lemma_tac¨ClosedInterval a b Ä SpaceâT OâRÆ
	THEN1 rewrite_tac[space_t_Ø_thm]);
a(ALL_FC_T1 fc_§_canon rewrite_tac
	[subspace_range_continuous_§_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(asm_rewrite_tac[space_t_Ø_thm]);
a(REPEAT strip_tac THEN_TRY Ø_continuity_tac[] THEN_TRY asm_rewrite_tac[]);
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(asm_rewrite_tac[space_t_Ø_thm]);
a(REPEAT strip_tac THEN Ø_continuity_tac[]);
(* *** Goal "2" *** *)
a(rewrite_tac[closed_interval_def]);
a(cases_tac¨x º aÆ THEN asm_rewrite_tac[]);
a(cases_tac¨x º bÆ THEN asm_rewrite_tac[]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val ∏_closed_interval_retract_thm = save_thm ( "∏_closed_interval_retract_thm", (
set_goal([], ¨µ‘ X a b∑
	‘ ç Topology
±	X Ä SpaceâT ‘
±	a º b
¥	(Ã(x, s)∑ (x, if s º a then a else if s º b then s else b)) ç
	((X ∏ Universe) ÚâT (‘ ∏âT OâR),
		(X ∏ ClosedInterval a b) ÚâT (‘ ∏âT OâR)) Continuous
Æ);
a(REPEAT strip_tac THEN strip_asm_tac open_Ø_topology_thm);
a(lemma_tac¨‘ ∏âT OâR ç TopologyÆ THEN1 basic_topology_tac[]);
a(lemma_tac¨(X ∏ ClosedInterval a b) Ä SpaceâT (‘ ∏âT OâR)Æ);
(* *** Goal "1" *** *)
a(ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(rewrite_tac[space_t_Ø_thm]);
a(DROP_NTH_ASM_T 4 ante_tac);
a(MERGE_PCS_T1 ["'pair", "sets_ext1"] prove_tac[∏_def]);
(* *** Goal "2" *** *)
a(lemma_tac¨(X ∏ Universe) ÚâT ‘ ∏âT OâR ç TopologyÆ
	THEN1 (bc_tac[subspace_topology_thm, product_topology_thm] THEN REPEAT strip_tac));
a(ALL_FC_T1 fc_§_canon rewrite_tac
	[subspace_range_continuous_§_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LEMMA_T ¨(Ã (x:'a, s)∑ (x, (if s º a then a else if s º b then s else b))) =
	(Ã xs∑ (Fst xs, (Ãxs∑if Snd xs º a then a else if Snd xs º b then Snd xs else b) xs))Æ
	pure_rewrite_thm_tac
	THEN1 prove_tac[]);
a(bc_thm_tac product_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(bc_tac[subspace_domain_continuous_thm, fst_continuous_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2.1.2" *** *)
a(bc_thm_tac subspace_domain_continuous_thm THEN REPEAT strip_tac);
a(LEMMA_T ¨(Ã xs∑ if Snd xs º a then a else if Snd xs º b then Snd xs else b) =
	(Ãxs∑ (Ã s∑ if s º a then a else if s º b then s else b)(Snd xs))Æ
	pure_rewrite_thm_tac
	THEN1 prove_tac[]);
a(bc_thm_tac comp_continuous_thm);
a(∂_tac¨OâRÆ THEN REPEAT strip_tac);
(* *** Goal "2.1.2.1" *** *)
a(bc_thm_tac snd_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.2.2" *** *)
a(all_fc_tac[closed_interval_retract_thm]);
a(all_fc_tac[subspace_range_continuous_thm]);
(* *** Goal "2.2" *** *)
a(POP_ASM_T ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm,
	product_topology_space_t_thm]);
a(rewrite_tac[∏_def] THEN REPEAT strip_tac);
a(rewrite_tac[closed_interval_def]);
a(cases_tac¨Snd x º aÆ THEN asm_rewrite_tac[]);
a(cases_tac ¨Snd x º bÆ THEN asm_rewrite_tac[]);
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val closed_interval_extension_thm = save_thm ( "closed_interval_extension_thm", (
set_goal([], ¨µ“; ”; f : 'a ∏ Ø ≠ 'b; X a b∑
	“ ç Topology
±	” ç Topology
±	X Ä SpaceâT “
±	a º b
±	f ç ((X ∏ ClosedInterval a b) ÚâT “ ∏âT OâR, ”) Continuous
¥	∂g : 'a ∏ Ø ≠ 'b∑
	g ç ((X ∏ Universe) ÚâT (“ ∏âT OâR), ”) Continuous
±	µx s∑	x ç X ± s ç ClosedInterval a b
	¥	g(x, s) = f(x, s)
Æ);
a(REPEAT strip_tac THEN all_fc_tac[∏_closed_interval_retract_thm]);
a(strip_asm_tac open_Ø_topology_thm);
a(∂_tac¨Ãxs∑f((Ã (x, s)∑ (x, (if s º a then a else if s º b then s else b))) xs)Æ
	THEN strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac comp_continuous_thm THEN REPEAT strip_tac);
a(∂_tac¨(X ∏ ClosedInterval a b) ÚâT “ ∏âT OâRÆ);
a(asm_rewrite_tac[] THEN REPEAT strip_tac
	THEN bc_tac[subspace_topology_thm, product_topology_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(rewrite_tac[closed_interval_def] THEN REPEAT strip_tac);
a(cases_tac¨s = aÆ THEN1 asm_rewrite_tac[]);
a(lemma_tac¨≥s º aÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(asm_rewrite_tac[]);
pop_thm()
));



val ∏_interval_glueing_thm = save_thm ( "∏_interval_glueing_thm", (
set_goal([], ¨µ“; ”; f g : 'a ∏ Ø ≠ 'b; X a b∑
	“ ç Topology
±	” ç Topology
±	X Ä SpaceâT “
±	a º b ± b º c
±	f ç ((X ∏ ClosedInterval a b) ÚâT “ ∏âT OâR, ”) Continuous
±	g ç ((X ∏ ClosedInterval b c) ÚâT “ ∏âT OâR, ”) Continuous
±	(µx∑ x ç X ¥ f(x, b) = g(x, b))
¥	∂h : 'a ∏ Ø ≠ 'b∑
	h ç ((X ∏ ClosedInterval a c) ÚâT “ ∏âT OâR, ”) Continuous
±	(µx s∑	x ç X ± s ç ClosedInterval a b
	¥	h(x, s) = f(x, s))
±	(µx s∑	x ç X ± s ç ClosedInterval b c
	¥	h(x, s) = g(x, s))
Æ);
a(REPEAT strip_tac);
a(all_fc_tac[closed_interval_extension_thm]);
a(strip_asm_tac open_Ø_topology_thm);
a(LIST_DROP_NTH_ASM_T [7, 8] discard_tac
	THEN rename_tac[(¨g'Æ, "eg"), (¨g''Æ, "ef")]);
a(∂_tac¨Ãxs∑ if Snd xs º b then ef xs else eg xsÆ
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(lemma_tac¨(X ∏ ClosedInterval a c) Ä (X ∏ Universe)Æ
	THEN1 MERGE_PCS_T1 ["'pair", "sets_ext1"] prove_tac[∏_def]);
a(lemma_tac¨“ ∏âT OâR ç TopologyÆ THEN1 basic_topology_tac[]);
a(ALL_FC_T (once_rewrite_tac o map (conv_rule (ONCE_MAP_C eq_sym_conv)))
	 [Ä_subspace_topology_thm]);
a(bc_thm_tac subspace_domain_continuous_thm);
a(REPEAT strip_tac THEN1 (bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac));
a(LEMMA_T ¨µxs∑Snd xs º b § xs ç {(x, s) | s º b}Æ pure_once_rewrite_thm_tac
	THEN1 rewrite_tac[]);
a(lemma_tac¨(X ∏ Universe) ÚâT “ ∏âT OâR ç TopologyÆ
	THEN1 (bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac));
a(bc_thm_tac cond_continuous_thm THEN REPEAT strip_tac);
a(DROP_NTH_ASM_T 2 ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]);
a(rewrite_tac[∏_def] THEN strip_tac);
a(lemma_tac¨Snd x = bÆ);
(* *** Goal "1.1" *** *)
a(lemma_tac¨Snd x < b ≤ Snd x = b ≤ b < Snd xÆ
	THEN1 PC_T1 "Ø_lin_arith" prove_tac[] THEN i_contr_tac);
(* *** Goal "1.1.1" *** *)
a(swap_nth_asm_concl_tac 4 THEN strip_tac);
a(∂_tac¨X ∏ OpenInterval (Snd x + ~1.) bÆ THEN REPEAT strip_tac);
(* *** Goal "1.1.1.1" *** *)
a(PC_T1 "sets_ext1" asm_rewrite_tac[∏_def, open_interval_def]
	THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.1.1.2" *** *)
a(rewrite_tac[subspace_topology_def]);
a(∂_tac¨SpaceâT “ ∏  OpenInterval (Snd x + ~ 1.) bÆ
	THEN REPEAT strip_tac);
(* *** Goal "1.1.1.2.1" *** *)
a(rewrite_tac[product_topology_def, ∏_def] THEN REPEAT strip_tac);
a(∂_tac¨SpaceâT “Æ THEN ∂_tac¨OpenInterval (Snd x + ~ 1.) bÆ
	THEN asm_rewrite_tac[open_interval_open_thm]);
a(ALL_FC_T rewrite_tac[space_t_open_thm]);
(* *** Goal "1.1.1.2.2" *** *)
a(DROP_NTH_ASM_T 15 ante_tac
	THEN MERGE_PCS_T1 ["'pair", "sets_ext1"] prove_tac[∏_def]);
(* *** Goal "1.1.1.3" *** *)
a(swap_nth_asm_concl_tac 1);
a(DROP_NTH_ASM_T 3 ante_tac);
a(rewrite_tac[∏_def, open_interval_def]);
a(PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.1.2" *** *)
a(swap_nth_asm_concl_tac 4 THEN strip_tac);
a(∂_tac¨X ∏ OpenInterval b (Snd x + 1.)Æ THEN REPEAT strip_tac);
(* *** Goal "1.1.2.1" *** *)
a(PC_T1 "sets_ext1" asm_rewrite_tac[∏_def, open_interval_def]
	THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.1.2.2" *** *)
a(rewrite_tac[subspace_topology_def]);
a(∂_tac¨SpaceâT “ ∏  OpenInterval b (Snd x + 1.)Æ
	THEN REPEAT strip_tac);
(* *** Goal "1.1.2.2.1" *** *)
a(rewrite_tac[product_topology_def, ∏_def] THEN REPEAT strip_tac);
a(∂_tac¨SpaceâT “Æ THEN ∂_tac¨OpenInterval b (Snd x + 1.)Æ
	THEN asm_rewrite_tac[open_interval_open_thm]);
a(ALL_FC_T rewrite_tac[space_t_open_thm]);
(* *** Goal "1.1.2.2.2" *** *)
a(DROP_NTH_ASM_T 15 ante_tac
	THEN MERGE_PCS_T1 ["'pair", "sets_ext1"] prove_tac[∏_def]);
(* *** Goal "1.1.2.3" *** *)
a(swap_nth_asm_concl_tac 2);
a(DROP_NTH_ASM_T 1 ante_tac);
a(rewrite_tac[∏_def, open_interval_def]);
a(PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.2" *** *)
a(lemma_tac¨Snd x ç ClosedInterval a b ± Snd x ç ClosedInterval b cÆ
	THEN1 (rewrite_tac[closed_interval_def]
		THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(LIST_DROP_NTH_ASM_T [11, 13] (ALL_FC_T (MAP_EVERY ante_tac)));
a(rewrite_tac[] THEN REPEAT (STRIP_T rewrite_thm_tac));
a(LEMMA_T¨x = (Fst x, b)Æ once_rewrite_thm_tac THEN1 asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 13 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(POP_ASM_T (strip_asm_tac o rewrite_rule[closed_interval_def]));
a(asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 5 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def]);
(* *** Goal "3" *** *)
a(POP_ASM_T (strip_asm_tac o rewrite_rule[closed_interval_def]));
a(asm_rewrite_tac[]);
a(cases_tac¨s = bÆ THEN1 all_var_elim_asm_tac1);
(* *** Goal "3.1" *** *)
a(LEMMA_T ¨g(x, b) = f(x, b)Æ rewrite_thm_tac
	THEN1 LIST_DROP_NTH_ASM_T [7] (ALL_FC_T rewrite_tac));
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def]);
(* *** Goal "3.2" *** *)
a(lemma_tac¨≥s º bÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 9 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def]);
pop_thm()
));



val paths_continuous_thm = save_thm ( "paths_continuous_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	f ç (OâR, ‘) Continuous
Æ);
a(prove_tac[paths_def]);
pop_thm()
));

val paths_representative_thm = save_thm ( "paths_representative_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç (OâR, ‘) Continuous
¥	∂â1 g∑ g ç Paths ‘ ± µs∑ s ç ClosedInterval 0. 1. ¥ g s = f s
Æ);
a(rewrite_tac[paths_def] THEN REPEAT strip_tac);
a(∂â1_tac ¨Ãt∑ if t º 0. then f 0. else if t º 1. then f t else f 1.Æ
	THEN rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(asm_rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY Ø_continuity_tac[] THEN_TRY asm_rewrite_tac[]);
(* *** Goal "1.1" *** *)
a(bc_thm_tac continuous_ç_space_t_thm);
a(∂_tac¨OâRÆ THEN asm_rewrite_tac[space_t_Ø_thm]);
(* *** Goal "1.2" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(asm_rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY Ø_continuity_tac[] THEN_TRY asm_rewrite_tac[]);
a(bc_thm_tac continuous_ç_space_t_thm);
a(∂_tac¨OâRÆ THEN asm_rewrite_tac[space_t_Ø_thm]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(LEMMA_T¨≥ x º 0.Æ asm_rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(cases_tac¨x = 1.Æ THEN1 asm_rewrite_tac[]);
a(LEMMA_T¨≥ x º 1.Æ rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "4" *** *)
a(POP_ASM_T (strip_asm_tac o rewrite_rule[closed_interval_def]));
a(cases_tac¨s = 0.Æ THEN asm_rewrite_tac[]);
a(LEMMA_T¨≥ s º 0.Æ asm_rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "5" *** *)
a(POP_ASM_T (strip_asm_tac o rewrite_rule[closed_interval_def]));
a(cases_tac ¨x º 0.Æ THEN ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "5.1" *** *)
a(DROP_NTH_ASM_T 2 bc_thm_tac THEN REPEAT strip_tac);
(* *** Goal "5.2" *** *)
a(cases_tac¨x º 1.Æ THEN asm_rewrite_tac[]);
(* *** Goal "5.2.1" *** *)
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "5.2.2" *** *)
a(lemma_tac¨1. º xÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LIST_DROP_NTH_ASM_T [5] (ALL_FC_T rewrite_tac));
a(DROP_NTH_ASM_T 4 bc_thm_tac THEN REPEAT strip_tac);
pop_thm()
));


val path_0_path_thm = save_thm ( "path_0_path_thm", (
set_goal([], ¨µ‘ x∑
	‘ ç Topology
±	x ç SpaceâT ‘
¥	0âP x ç Paths ‘
Æ);
a(rewrite_tac[paths_def, path_0_def] THEN REPEAT strip_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[const_continuous_thm]);
pop_thm()
));


val path_plus_path_thm = save_thm ( "path_plus_path_thm", (
set_goal([], ¨µ‘ f g∑
	‘ ç Topology
±	f ç Paths ‘
±	g ç Paths ‘
±	g(ÓØ 0) = f(ÓØ 1)
¥	f +âP g ç Paths ‘
Æ);
a(rewrite_tac[paths_def, path_plus_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(strip_asm_tac open_Ø_topology_thm THEN asm_rewrite_tac[]);
a(REPEAT strip_tac THEN_TRY SOLVED_T (Ø_continuity_tac []));
a(all_var_elim_asm_tac1 THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(LEMMA_T ¨x º 1 / 2Æ rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(DROP_NTH_ASM_T 7 bc_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(LEMMA_T ¨≥x º 1 / 2Æ rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val path_minus_path_thm = save_thm ( "path_minus_path_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	 ~âP f ç Paths ‘
Æ);
a(rewrite_tac[path_minus_def, paths_def] THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(Ø_continuity_tac []);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 2 bc_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val path_plus_assoc_lemma1 = (* not saved *) snd ( "path_plus_assoc_lemma1", (
set_goal([], ¨µ‘ f g h k∑
	‘ ç Topology
±	f ç Paths ‘
±	g ç Paths ‘
±	h ç Paths ‘
±	(µt∑k t = if t º 1/4 then ÓØ 2*t else if t º 1/2 then t + 1/4 else (1/2)*t + 1/2)
¥	((f +âP g) +âP h) = Ãt∑ (f +âP (g +âP h)) (k t)
Æ);
a(rewrite_tac[paths_def, path_plus_def] THEN REPEAT strip_tac);
a(asm_rewrite_tac[]);
a(cases_tac¨x º 1/4Æ THEN cases_tac ¨x º 1/2Æ THEN asm_rewrite_tac[]);
(* *** Goal "1" *** *)
a(LEMMA_T¨ÓØ 2*x º 1/2Æ  rewrite_thm_tac THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "3" *** *)
a(LEMMA_T¨≥ÓØ 2*x º 1/2 ± ≥x + 1/4 º 1/2Æ  rewrite_thm_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LEMMA_T¨ÓØ 2 * ((x + 1 / 4) + ~ (1 / 2)) º 1 / 2Æ  rewrite_thm_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(conv_tac (ONCE_MAP_C Ø_anf_conv) THEN strip_tac);
(* *** Goal "4" *** *)
a(LEMMA_T¨≥(1/2)*x º ÓØ 0Æ  rewrite_thm_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(LEMMA_T¨≥ÓØ 2 * ((1 / 2 * x + 1 / 2) + ~ (1 / 2)) º 1 / 2Æ  rewrite_thm_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(conv_tac (ONCE_MAP_C Ø_anf_conv) THEN strip_tac);
pop_thm()
));


val path_plus_assoc_lemma2 = (* not saved *) snd ( "path_plus_assoc_lemma2", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/4 then ÓØ 2*t else if t º 1/2 then t + 1/4 else (1/2)*t + 1/2)
¥	k ç (OâR, OâR) Continuous
Æ);
a(REPEAT strip_tac);
a(pure_once_rewrite_tac[conv_rule(ONCE_MAP_C eq_sym_conv) (µ_elim¨kÆ»_axiom)]);
a(POP_ASM_T pure_rewrite_thm_tac);
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY SOLVED_T (Ø_continuity_tac []));
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY SOLVED_T (Ø_continuity_tac []));
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "2" *** *)
a(all_var_elim_asm_tac1 THEN rewrite_tac[]);
pop_thm()
));


val path_plus_assoc_lemma3 = (* not saved *) snd ( "path_plus_assoc_lemma3", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/4 then ÓØ 2*t else if t º 1/2 then t + 1/4 else (1/2)*t + 1/2)
¥	k ç ((OâR, {ÓØ 0; ÓØ 1},OâR) HomotopyClass) (Ãx∑x)
Æ);
a(REPEAT strip_tac);
a(bc_thm_tac homotopy_class_Ä_thm);
a(strip_asm_tac open_Ø_topology_thm THEN asm_rewrite_tac[]);
a(∂_tac¨{x | k x = (Ãx∑ x) x}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac homotopy_class_Ø_thm);
a(ALL_FC_T asm_rewrite_tac[id_continuous_thm, path_plus_assoc_lemma2]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val path_plus_assoc_thm = save_thm ( "path_plus_assoc_thm", (
set_goal([], ¨µ‘ f g h∑
	‘ ç Topology
±	f ç Paths ‘
±	g ç Paths ‘
±	h ç Paths ‘
±	g(ÓØ 0) = f(ÓØ 1)
±	h(ÓØ 0) = g(ÓØ 1)
¥	((f +âP g) +âP h) ç ((OâR, {ÓØ 0; ÓØ 1}, ‘) HomotopyClass)(f +âP (g +âP h))
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂k∑µt∑k t = if t º 1/4 then ÓØ 2*t else if t º 1/2 then t + 1/4 else (1/2)*t + 1/2Æ
	THEN1 prove_∂_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[path_plus_assoc_lemma2, path_plus_assoc_lemma3]);
a(pure_once_rewrite_tac[prove_rule[]¨f +âP g +âP h = Ãt∑(f +âP g +âP h)((Ãx∑ x) t)Æ]);
a(PC_T1 "predicates" (ALL_FC_T pure_rewrite_tac)[path_plus_assoc_lemma1]);
a(bc_thm_tac homotopy_class_comp_left_thm);
a(∂_tac¨OâRÆ THEN REPEAT strip_tac);
a(bc_tac [path_plus_path_thm, paths_continuous_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_tac [path_plus_path_thm, paths_continuous_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[path_plus_def]);
pop_thm()
));


val path_plus_0_lemma1 = (* not saved *) snd ( "path_plus_0_lemma1", (
set_goal([], ¨µ‘ f k∑
	‘ ç Topology
±	f ç Paths ‘
±	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 1)
¥	(f +âP 0âP (f(ÓØ 1))) = Ãt∑ f (k t)
Æ);
a(rewrite_tac[paths_def, path_plus_def, path_0_def] THEN REPEAT strip_tac);
a(asm_rewrite_tac[]);
a(cases_tac¨x º 1/2Æ THEN asm_rewrite_tac[]);
pop_thm()
));


val path_plus_0_lemma2 = (* not saved *) snd ( "path_plus_0_lemma2", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 1)
¥	k ç (OâR, OâR) Continuous
Æ);
a(REPEAT strip_tac);
a(pure_once_rewrite_tac[conv_rule(ONCE_MAP_C eq_sym_conv) (µ_elim¨kÆ»_axiom)]);
a(POP_ASM_T pure_rewrite_thm_tac);
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY (SOLVED_T (Ø_continuity_tac[])));
a(asm_rewrite_tac[]);
pop_thm()
));


val path_plus_0_lemma3 = (* not saved *) snd ( "path_plus_0_lemma3", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 1)
¥	k ç ((OâR, {ÓØ 0; ÓØ 1},OâR) HomotopyClass) (Ãx∑x)
Æ);
a(REPEAT strip_tac);
a(bc_thm_tac homotopy_class_Ä_thm);
a(strip_asm_tac open_Ø_topology_thm THEN asm_rewrite_tac[]);
a(∂_tac¨{x | k x = (Ãx∑ x) x}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac homotopy_class_Ø_thm);
a(ALL_FC_T asm_rewrite_tac[id_continuous_thm, path_plus_0_lemma2]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val path_plus_0_thm = save_thm ( "path_plus_0_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	f +âP 0âP (f(ÓØ 1)) ç ((OâR, {ÓØ 0; ÓØ 1}, ‘) HomotopyClass) f
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂k∑µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 1Æ
	THEN1 prove_∂_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[path_plus_0_lemma2, path_plus_0_lemma3]);
a(conv_tac (RIGHT_C (pure_once_rewrite_conv[prove_rule[]¨f = Ãt∑f ((Ãt∑t)t)Æ])));
a(PC_T1 "predicates" (ALL_FC_T pure_rewrite_tac)[path_plus_0_lemma1]);
a(bc_thm_tac homotopy_class_comp_left_thm);
a(∂_tac¨OâRÆ THEN REPEAT strip_tac);
a(bc_tac [paths_continuous_thm] THEN REPEAT strip_tac);
pop_thm()
));


val path_0_plus_lemma1 = (* not saved *) snd ( "path_0_plus_lemma1", (
set_goal([], ¨µ‘ f k∑
	‘ ç Topology
±	f ç Paths ‘
±	(µt∑k t = if t º 1/2 then ÓØ 0 else ÓØ 2*t + ~(ÓØ 1))
¥	0âP (f(ÓØ 0)) +âP f = Ãt∑ f (k t)
Æ);
a(rewrite_tac[paths_def, path_plus_def, path_0_def] THEN REPEAT strip_tac);
a(asm_rewrite_tac[]);
a(cases_tac¨x º 1/2Æ THEN  asm_rewrite_tac[]);
a(conv_tac (ONCE_MAP_C Ø_anf_conv) THEN  asm_rewrite_tac[]);
pop_thm()
));


val path_0_plus_lemma2 = (* not saved *) snd ( "path_0_plus_lemma2", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 0 else ÓØ 2*t + ~(ÓØ 1))
¥	k ç (OâR, OâR) Continuous
Æ);
a(REPEAT strip_tac);
a(pure_once_rewrite_tac[conv_rule(ONCE_MAP_C eq_sym_conv) (µ_elim¨kÆ»_axiom)]);
a(POP_ASM_T pure_rewrite_thm_tac);
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY (SOLVED_T (Ø_continuity_tac[])));
a(asm_rewrite_tac[]);
pop_thm()
));


val path_0_plus_lemma3 = (* not saved *) snd ( "path_0_plus_lemma3", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 0 else ÓØ 2*t + ~(ÓØ 1))
¥	k ç ((OâR, {ÓØ 0; ÓØ 1},OâR) HomotopyClass) (Ãx∑x)
Æ);
a(REPEAT strip_tac);
a(bc_thm_tac homotopy_class_Ä_thm);
a(strip_asm_tac open_Ø_topology_thm THEN asm_rewrite_tac[]);
a(∂_tac¨{x | k x = (Ãx∑ x) x}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac homotopy_class_Ø_thm);
a(ALL_FC_T asm_rewrite_tac[id_continuous_thm, path_0_plus_lemma2]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val path_0_plus_thm = save_thm ( "path_0_plus_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	0âP (f(ÓØ 0)) +âP f ç ((OâR, {ÓØ 0; ÓØ 1}, ‘) HomotopyClass) f
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂k∑	(µt∑k t = if t º 1/2 then ÓØ 0 else ÓØ 2*t + ~(ÓØ 1))Æ
	THEN1 prove_∂_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[path_0_plus_lemma2, path_0_plus_lemma3]);
a(conv_tac (RIGHT_C (pure_once_rewrite_conv[prove_rule[]¨f = Ãt∑f ((Ãt∑t)t)Æ])));
a(PC_T1 "predicates" (ALL_FC_T pure_rewrite_tac)[path_0_plus_lemma1]);
a(bc_thm_tac homotopy_class_comp_left_thm);
a(∂_tac¨OâRÆ THEN REPEAT strip_tac);
a(bc_tac [paths_continuous_thm] THEN REPEAT strip_tac);
pop_thm()
));


val path_plus_minus_lemma1 = (* not saved *) snd ( "path_plus_minus_lemma1", (
set_goal([], ¨µ‘ f k∑
	‘ ç Topology
±	f ç Paths ‘
±	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 2 + ~(ÓØ 2*t) )
¥	f +âP ~âP f= Ãt∑ f (k t)
Æ);
a(rewrite_tac[paths_def, path_plus_def, path_minus_def] THEN REPEAT strip_tac);
a(asm_rewrite_tac[]);
a(cases_tac¨x º 1/2Æ THEN  asm_rewrite_tac[]);
a(conv_tac (ONCE_MAP_C Ø_anf_conv) THEN REPEAT strip_tac);
pop_thm()
));


val path_plus_minus_lemma2 = (* not saved *) snd ( "path_plus_minus_lemma2", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 2 + ~(ÓØ 2*t) )
¥	k ç (OâR, OâR) Continuous
Æ);
a(REPEAT strip_tac);
a(pure_once_rewrite_tac[conv_rule(ONCE_MAP_C eq_sym_conv) (µ_elim¨kÆ»_axiom)]);
a(POP_ASM_T pure_rewrite_thm_tac);
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY (SOLVED_T (Ø_continuity_tac[])));
a(asm_rewrite_tac[]);
pop_thm()
));


val path_plus_minus_lemma3 = (* not saved *) snd ( "path_plus_minus_lemma3", (
set_goal([], ¨µk∑
	(µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 2 + ~(ÓØ 2*t) )
¥	k ç ((OâR, {ÓØ 0; ÓØ 1},OâR) HomotopyClass) (Ãx∑ÓØ 0)
Æ);
a(REPEAT strip_tac);
a(bc_thm_tac homotopy_class_Ä_thm);
a(strip_asm_tac open_Ø_topology_thm THEN asm_rewrite_tac[]);
a(∂_tac¨{x | k x = (Ãx∑ ÓØ 0) x}Æ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac homotopy_class_Ø_thm);
a(lemma_tac¨ÓØ 0 ç SpaceâT OâRÆ THEN1 rewrite_tac[space_t_Ø_thm]);
a(ALL_FC_T asm_rewrite_tac[const_continuous_thm, path_plus_minus_lemma2]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(asm_rewrite_tac[]);
pop_thm()
));


val path_plus_minus_thm = save_thm ( "path_plus_minus_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	f +âP ~âP fç ((OâR, {ÓØ 0; ÓØ 1}, ‘) HomotopyClass) (0âP (f(ÓØ 0)))
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂k∑ (µt∑k t = if t º 1/2 then ÓØ 2*t else ÓØ 2 + ~(ÓØ 2*t) )Æ
	THEN1 prove_∂_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(all_fc_tac[path_plus_minus_lemma2, path_plus_minus_lemma3]);
a(rewrite_tac[path_0_def]);
a(pure_once_rewrite_tac[prove_rule[]¨(Ãt∑f(ÓØ 0)) =(Ãt∑f((Ãt∑ÓØ 0)t))Æ]);
a(PC_T1 "predicates" (ALL_FC_T pure_rewrite_tac)[path_plus_minus_lemma1]);
a(bc_thm_tac homotopy_class_comp_left_thm);
a(∂_tac¨OâRÆ THEN REPEAT strip_tac);
a(bc_tac [paths_continuous_thm] THEN REPEAT strip_tac);
pop_thm()
));


val path_minus_minus_thm = save_thm ( "path_minus_minus_thm", (
set_goal([], ¨µf∑
	 ~âP (~âP f) = f
Æ);
a(rewrite_tac[path_minus_def] THEN conv_tac (ONCE_MAP_C Ø_anf_conv));
a(REPEAT strip_tac);
pop_thm()
));


val path_minus_plus_thm = save_thm ( "path_minus_plus_thm", (
set_goal([], ¨µ‘ f∑
	‘ ç Topology
±	f ç Paths ‘
¥	~âP f +âP fç ((OâR, {ÓØ 0; ÓØ 1}, ‘) HomotopyClass) (0âP (f(ÓØ 1)))
Æ);
a(REPEAT strip_tac);
a(all_fc_tac[path_minus_path_thm]);
a(DROP_NTH_ASM_T 2 discard_tac);
a(ALL_FC_T (MAP_EVERY ante_tac) [path_plus_minus_thm]);
a(rewrite_tac[path_minus_minus_thm]);
a(rewrite_tac[path_0_def, path_minus_def]);
pop_thm()
));


val open_connected_path_connected_thm = save_thm ( "open_connected_path_connected_thm", (
set_goal([], ¨µ‘ A∑
	‘ ç Topology
±	‘ ç LocallyPathConnected
±	A ç ‘
±	A ç ‘ Connected
¥	A ç ‘ PathConnected
Æ);
a(rewrite_tac[path_connected_def, connected_def, locally_path_connected_def]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(lemma_tac¨{z | ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z} ç ‘Æ);
(* *** Goal "1" *** *)
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]
	THEN REPEAT strip_tac);
a(lemma_tac¨x' ç AÆ THEN1 (all_var_elim_asm_tac1 THEN asm_rewrite_tac[]));
a(list_spec_nth_asm_tac 11 [¨x'Æ, ¨AÆ]);
a(∂_tac¨BÆ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
a(list_spec_nth_asm_tac 2 [¨x'Æ, ¨x''Æ]);
a(∂_tac¨f +âP f'Æ THEN REPEAT strip_tac THEN_TRY SOLVED_T (asm_rewrite_tac[path_plus_def]));
(* *** Goal "1.1" *** *)
a(bc_thm_tac path_plus_path_thm THEN asm_rewrite_tac[]);
(* *** Goal "1.2" *** *)
a(rewrite_tac[path_plus_def]);
a(cases_tac¨t º 1/2Æ THEN asm_rewrite_tac[]);
a(LEMMA_T¨f' (ÓØ 2 * (t + ~ (1 / 2))) ç BÆ ante_tac THEN1 asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 9 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨{z | z ç A ± ≥ ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z} ç ‘Æ);
(* *** Goal "2.1" *** *)
a(ALL_FC_T1 fc_§_canon once_rewrite_tac[open_open_neighbourhood_thm]
	THEN REPEAT strip_tac);
a(list_spec_nth_asm_tac 9 [¨x'Æ, ¨AÆ]);
a(∂_tac¨BÆ THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(LIST_DROP_NTH_ASM_T [1, 4] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.2" *** *)
a(swap_nth_asm_concl_tac 10 THEN REPEAT strip_tac);
a(list_spec_nth_asm_tac 6 [¨x''Æ, ¨x'Æ]);
a(∂_tac¨f +âP f'Æ THEN REPEAT strip_tac THEN_TRY SOLVED_T (asm_rewrite_tac[path_plus_def]));
(* *** Goal "2.1.2.1" *** *)
a(bc_thm_tac path_plus_path_thm THEN asm_rewrite_tac[]);
(* *** Goal "2.1.2.2" *** *)
a(rewrite_tac[path_plus_def]);
a(cases_tac¨t º 1/2Æ THEN asm_rewrite_tac[]);
a(LEMMA_T¨f' (ÓØ 2 * (t + ~ (1 / 2))) ç BÆ ante_tac THEN1 asm_rewrite_tac[]);
a(DROP_NTH_ASM_T 13 ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.2" *** *)
a(lemma_tac¨
	A Ä {z | ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z}
	¿ {z | z ç A ± ≥ ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z}Æ
	THEN1 PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2.1" *** *)
a(spec_nth_asm_tac 4 ¨fÆ);
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2" *** *)
a(lemma_tac¨
	A ° {z | ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z}
	° {z | z ç A ± ≥ ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z} = {}Æ
	THEN1 PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2.2.1" *** *)
a(spec_nth_asm_tac 1 ¨fÆ);
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.2" *** *)
a(DROP_NTH_ASM_T 7 (ante_tac o list_µ_elim
	[¨{z | ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z}Æ,
	¨{z | z ç A ± ≥ ∂ f∑ f ç Paths ‘ ± (µ t∑ f t ç A) ± f (ÓØ 0) = x ± f (ÓØ 1) = z}Æ]));
a(asm_rewrite_tac[]);
a(REPEAT_N 4 (POP_ASM_T discard_tac) THEN PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.2.2.2.1" *** *)
a(spec_nth_asm_tac 1 ¨yÆ);
a(∂_tac ¨fÆ THEN asm_rewrite_tac[]);
(* *** Goal "2.2.2.2.2" *** *)
a(i_contr_tac THEN spec_nth_asm_tac 1 ¨xÆ);
a(swap_nth_asm_concl_tac 1 THEN REPEAT strip_tac);
a(∂_tac¨Ãt:Ø∑ xÆ THEN asm_rewrite_tac[paths_def]);
a(bc_thm_tac const_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2.2.2.2.2.1" *** *)
a(accept_tac open_Ø_topology_thm);
(* *** Goal "2.2.2.2.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [3, 4] (MAP_EVERY ante_tac) THEN PC_T1 "sets_ext1" prove_tac[]);
pop_thm()
));


val open_interval_path_connected_thm = save_thm ( "open_interval_path_connected_thm", (
set_goal([], ¨µx y∑OpenInterval x y ç OâR PathConnectedÆ);
a(rewrite_tac[path_connected_def, open_interval_def, paths_def, space_t_Ø_thm]
	THEN REPEAT strip_tac);
a(∂_tac¨Ãt∑if t º ÓØ 0 then x' else if t º ÓØ 1 then x' + (y' + ~x') * t else y'Æ THEN rewrite_tac[]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY SOLVED_T (Ø_continuity_tac[]));
(* *** Goal "1.1" *** *)
a(ho_bc_thm_tac cond_continuous_Ø_thm);
a(rewrite_tac[open_Ø_topology_thm]);
a(REPEAT strip_tac THEN_TRY SOLVED_T (Ø_continuity_tac[]));
a(asm_rewrite_tac[] THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(cases_tac¨x'' = 1.Æ THEN1 (asm_rewrite_tac[] THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(LEMMA_T ¨≥x'' º 0. ± ≥x'' º 1.Æ rewrite_thm_tac THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "4" *** *)
a(cases_tac ¨t º 0.Æ THEN cases_tac ¨t º 1.Æ THEN asm_rewrite_tac[]);
a(cases_tac¨x' º y'Æ);
(* *** Goal "4.1" *** *)
a(bc_thm_tac Ø_less_º_trans_thm THEN ∂_tac¨x'Æ THEN REPEAT strip_tac);
a(bc_thm_tac Ø_0_º_0_º_times_thm THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "4.2" *** *)
a(bc_thm_tac Ø_less_º_trans_thm THEN ∂_tac¨y'Æ THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1"Ø_lin_arith" prove_rule[]
	¨ÓØ 0 º (x' + ~y') *(ÓØ 1 + ~t) ¥ y' º x' + (y' + ~ x') * tÆ));
a(bc_thm_tac Ø_0_º_0_º_times_thm THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "5" *** *)
a(cases_tac ¨t º 0.Æ THEN cases_tac ¨t º 1.Æ THEN asm_rewrite_tac[]);
a(cases_tac¨x' º y'Æ);
(* *** Goal "5.1" *** *)
a(bc_thm_tac Ø_º_less_trans_thm THEN ∂_tac¨y'Æ THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1"Ø_lin_arith" prove_rule[]
	¨ÓØ 0 º (y' + ~x') *(ÓØ 1 + ~t) ¥ x' + (y' + ~ x') * t º y'Æ));
a(bc_thm_tac Ø_0_º_0_º_times_thm THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "5.2" *** *)
a(bc_thm_tac Ø_º_less_trans_thm THEN ∂_tac¨x'Æ THEN REPEAT strip_tac);
a(bc_thm_tac (pc_rule1"Ø_lin_arith" prove_rule[]
	¨ÓØ 0 º (x' + ~y') *t ¥ (y' + ~ x') * t º ÓØ 0Æ));
a(bc_thm_tac Ø_0_º_0_º_times_thm THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "6" *** *)
a(PC_T1 "Ø_lin_arith" asm_prove_tac[]);
pop_thm()
));


val Ø_locally_path_connected_thm = save_thm ( "Ø_locally_path_connected_thm", (
set_goal([], ¨OâR ç LocallyPathConnectedÆ);
a(rewrite_tac[locally_path_connected_def] THEN REPEAT strip_tac);
a(POP_ASM_T  (fn th => all_fc_tac[rewrite_rule[open_Ø_def]th]));
a(∂_tac¨OpenInterval x' yÆ THEN
	asm_rewrite_tac[open_interval_open_thm, open_interval_path_connected_thm]);
pop_thm()
));


val product_locally_path_connected_thm = save_thm ( "product_locally_path_connected_thm", (
set_goal([], ¨µ” ‘ f a b c∑
	” ç Topology
±	‘ ç Topology
±	” ç LocallyPathConnected
±	‘ ç LocallyPathConnected
¥	(” ∏âT ‘) ç LocallyPathConnected
Æ);
a(rewrite_tac[locally_path_connected_def] THEN REPEAT strip_tac);
a(POP_ASM_T
	(ante_tac o list_µ_elim[¨Fst xÆ, ¨Snd xÆ] o rewrite_rule[product_topology_def]));
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [8, 7] all_fc_tac);
a(∂_tac¨B'' ∏ B'Æ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(rewrite_tac[product_topology_def] THEN REPEAT strip_tac);
a(POP_ASM_T (strip_asm_tac o rewrite_rule[∏_def]));
a(∂_tac¨B''Æ THEN ∂_tac¨B'Æ THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(asm_rewrite_tac[∏_def]);
(* *** Goal "3" *** *)
a(LIST_DROP_NTH_ASM_T [2, 6, 9] (MAP_EVERY ante_tac));
a(DROP_ASMS_T discard_tac);
a(MERGE_PCS_T1 ["'bin_rel", "sets_ext1"] REPEAT strip_tac);
a(DROP_NTH_ASM_T 5 bc_thm_tac THEN REPEAT strip_tac);
a(MERGE_PCS_T1 ["'bin_rel", "sets_ext1"] REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "4" *** *)
a(bc_thm_tac product_path_connected_thm THEN REPEAT strip_tac);
pop_thm()
));



val covering_projection_fibration_lemma1 = (* not saved *) snd ( "covering_projection_fibration_lemma1", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c;
	N : 'a SET;
	S : 'b SET;
	a b : Ø;
	C : 'c SET;
	U : 'b SET SET ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	h ç ((N ∏ ClosedInterval a b) ÚâT “ ∏âT OâR, ‘) Continuous
±	N ç “
±	(µx∑ x ç N ¥ f x ç S)
±	(µx∑ x ç N ¥ h(x, a) = p(f x))
±	S ç U
±	a < b
±	(µx t∑ x ç N ± t ç ClosedInterval a b ¥ h (x, t) ç C)
±	C ç ‘
±	U Ä ”
±	(µ A∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism)
¥	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((N ∏ ClosedInterval a b) ÚâT (“ ∏âT OâR), ”) Continuous
±	(µx∑	x ç N
	¥	L(x, a) = f x)
±	(µx s∑	x ç N
	±	s ç ClosedInterval a b
	¥	L(x, s) ç S)
±	(µx s∑	x ç N
	±	s ç ClosedInterval a b
	¥	p(L(x, s)) = h(x, s))
Æ);
a(REPEAT strip_tac);
a(LIST_GET_NTH_ASM_T[1] all_fc_tac);
a(POP_ASM_T (ante_tac o rewrite_rule[homeomorphism_def]));
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]
	¨µa u s∑ a ç u ± u Ä s ¥ a ç sÆ]); 
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]
	THEN REPEAT strip_tac);
a(∂_tac¨Ãxt∑g(h xt)Æ THEN rewrite_tac[]);
a(REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac comp_continuous_thm);
a(strip_asm_tac open_Ø_topology_thm);
a(∂_tac¨C ÚâT ‘Æ THEN
	ALL_FC_T asm_rewrite_tac[
subspace_topology_thm]
	THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(all_fc_tac[open_Ä_space_t_thm]);
a(lemma_tac¨(N ∏ ClosedInterval a b) Ä SpaceâT (“ ∏âT OâR)Æ
	THEN1 (ALL_FC_T rewrite_tac[product_topology_space_t_thm]
		THEN rewrite_tac[space_t_Ø_thm]
		THEN POP_ASM_T ante_tac
		THEN PC_T1 "sets_ext1" prove_tac[∏_def]));
a(bc_thm_tac subspace_range_continuous_bc_thm
	THEN asm_rewrite_tac[]
	THEN strip_tac
	THEN1 (bc_tac [product_topology_thm, subspace_topology_thm]
		THEN REPEAT strip_tac));
a(lemma_tac¨“ ∏âT OâR ç TopologyÆ THEN1 basic_topology_tac[]);
a(µ_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm1,
	product_topology_space_t_thm]);
a(rewrite_tac[∏_def]);
a(pair_tac¨x = (v, s)Æ THEN rewrite_tac[]);
a(REPEAT strip_tac THEN all_asm_fc_tac[]);
(* *** Goal "1.2" *** *)
a(bc_thm_tac subspace_range_continuous_thm);
a(∂_tac¨SÆ THEN REPEAT strip_tac);
a(bc_thm_tac subspace_topology_thm THEN REPEAT strip_tac);
(* *** Goal "1.3" *** *)
a(bc_tac[product_topology_thm, subspace_topology_thm] THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(LIST_DROP_NTH_ASM_T [14] all_fc_tac);
a(LIST_DROP_NTH_ASM_T [4, 14] (ALL_FC_T rewrite_tac));
(* *** Goal "3" *** *)
a(LIST_DROP_NTH_ASM_T [11] all_fc_tac);
a(lemma_tac¨h(x, s) ç SpaceâT (C ÚâT ‘)Æ
	THEN1 ALL_FC_T asm_rewrite_tac[subspace_topology_space_t_thm2]);
a(ALL_FC_T (MAP_EVERY ante_tac) [continuous_ç_space_t_thm]);
a(ALL_FC_T asm_rewrite_tac[subspace_topology_space_t_thm2]);
(* *** Goal "4" *** *)
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN all_asm_fc_tac[]);
pop_thm()
));


val covering_projection_fibration_lemma2 = (* not saved *) snd ( "covering_projection_fibration_lemma2", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c;
	N : 'a SET;
	a b : Ø;
	C : 'c SET;
	U : 'b SET SET ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	f ç (N ÚâT “, ”) Continuous
±	h ç ((N ∏ ClosedInterval a b) ÚâT “ ∏âT OâR, ‘) Continuous
±	N ç “
±	a < b
±	(µx∑ x ç N ¥ h(x, a) = p(f x))
±	(µx s∑ x ç N ± s ç ClosedInterval a b ¥ h (x, s) ç C)
±	C ç ‘
±	U Ä ”
±	(µx∑ x ç SpaceâT ” ± p x ç C ¥ ∂A∑ x ç A ± A ç U)
±	(µ A B∑ A ç U ± B ç U ± ≥ A ° B = {} ¥ A = B)
±	(µ A∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism)
¥	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((N ∏ ClosedInterval a b) ÚâT (“ ∏âT OâR), ”) Continuous
±	(µx∑	x ç N
	¥	L(x, a) = f x)
±	(µx s∑	x ç N
	±	s ç ClosedInterval a b
	¥	p(L(x, s)) = h(x, s))
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂W∑µv: 'a; r : Ø∑
	W (v, r) = {w | w ç N ± ∂A∑ f v ç A ± f w ç A ± A ç U}Æ
	THEN1 prove_∂_tac);
a(lemma_tac¨∂V∑µw r∑
	V (w, r) = (W (w, r) ∏ ClosedInterval a b)Æ
	THEN1 prove_∂_tac);
a(lemma_tac¨∂S∑µw : 'a; r : Ø∑
	S (w, r) = {y | ∂A∑ y ç A ± f w ç A ± A ç U}Æ
	THEN1 prove_∂_tac);
a(lemma_tac¨∂G∑µv r∑ v ç N ± r ç ClosedInterval a b ¥
	G (v, r) ç (V (v, r) ÚâT (“ ∏âT OâR), ”) Continuous
±	(µw∑	w ç W (v, r)
	¥	G(v, r)(w, a) = f w)
±	(µw s∑	w ç W (v, r)
	±	s ç ClosedInterval a b
	¥	G (v, r) (w, s) ç S (v, r))
±	(µw s∑	w ç W (v, r)
	±	s ç ClosedInterval a b
	¥	p(G (v, r) (w, s)) = h(w, s))Æ);
(* *** Goal "1" *** *)
a(lemma_tac¨∂H∑µvr∑ Fst vr ç N ± Snd vr ç ClosedInterval a b ¥
	H vr ç (V vr ÚâT (“ ∏âT OâR), ”) Continuous
±	(µw∑	w ç W vr
	¥	H vr (w, a) = f w)
±	(µw s∑	w ç W vr
	±	s ç ClosedInterval a b
	¥	H vr (w, s) ç S vr)
±	(µw s∑	w ç W vr
	±	s ç ClosedInterval a b
	¥	p(H vr (w, s)) = h(w, s))Æ
	THEN1 (prove_∂_tac THEN strip_tac));
(* *** Goal "1.1" *** *)
a(pair_tac¨vr' = (v, r)Æ);
a(GET_NTH_ASM_T 2 rewrite_thm_tac);
a(cases_tac¨≥v ç NÆ THEN1 asm_rewrite_tac[]);
a(cases_tac¨≥r ç ClosedInterval a bÆ THEN1 asm_rewrite_tac[]);
a(LIST_GET_NTH_ASM_T [1, 2] rewrite_tac);
a(LEMMA_T¨h(v, a) ç CÆ ante_tac
	THEN1 (DROP_NTH_ASM_T 11 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def, Ø_º_def]));
a(LIST_GET_NTH_ASM_T [12] (ALL_FC_T rewrite_tac) THEN strip_tac);
a(lemma_tac¨f v ç SpaceâT ”Æ
	THEN1 (bc_thm_tac continuous_ç_space_t_thm
		THEN ∂_tac¨N ÚâT “Æ
		THEN ALL_FC_T asm_rewrite_tac[ç_space_t_thm, subspace_topology_space_t_thm2]));
a(LIST_GET_NTH_ASM_T [10] all_fc_tac);
a(DROP_NTH_ASM_T 3 discard_tac);
a(bc_thm_tac covering_projection_fibration_lemma1);
a(MAP_EVERY ∂_tac[¨CÆ, ¨UÆ, ¨‘Æ]);
a(LIST_DROP_NTH_ASM_T [6, 7, 8] asm_rewrite_tac THEN REPEAT strip_tac);
(* *** Goal "1.1.1" *** *)
a(LEMMA_T ¨
	({w|w ç N ± (∂ A∑ f v ç A ± f w ç A ± A ç U)} ∏ ClosedInterval a b)
		ÚâT “ ∏âT OâR =
	({w|w ç N ± (∂ A∑ f v ç A ± f w ç A ± A ç U)} ∏ ClosedInterval a b)
		ÚâT (N ∏ ClosedInterval a b) ÚâT “ ∏âT OâRÆ
	rewrite_thm_tac
	THEN1 (conv_tac eq_sym_conv THEN bc_thm_tac Ä_subspace_topology_thm
		THEN1 PC_T1 "sets_ext1" prove_tac[∏_def]));
a(bc_thm_tac subspace_domain_continuous_thm THEN REPEAT strip_tac);
a(bc_tac[product_topology_thm, subspace_topology_thm] THEN REPEAT strip_tac);
a(rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "1.1.2" *** *)
a(DROP_NTH_ASM_T 10 discard_tac);
a(LIST_GET_NTH_ASM_T [9] (PC_T1 "sets_ext1" all_fc_tac));
a(all_fc_tac [continuous_open_thm]);
a(POP_ASM_T ante_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]);
a(rewrite_tac[subspace_topology_def] THEN strip_tac);
a(lemma_tac¨B ° N ç “Æ THEN1 all_fc_tac[°_open_thm]); 
a(LEMMA_T ¨µz∑ (∂ A∑ f v ç A ± z ç A ± A ç U) § z ç AÆ asm_rewrite_thm_tac);
a(REPEAT strip_tac);
(* *** Goal "1.1.2.1" *** *)
a(LEMMA_T ¨A = A'Æ asm_rewrite_thm_tac);
a(DROP_NTH_ASM_T 14 bc_thm_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [3, 9] (MAP_EVERY ante_tac));
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.1.2.2" *** *)
a(∂_tac¨AÆ THEN REPEAT strip_tac);
(* *** Goal "1.1.3" *** *)
a(∂_tac¨A'Æ THEN REPEAT strip_tac);
(* *** Goal "1.1.4" *** *)
a(DROP_NTH_ASM_T 16 bc_thm_tac THEN strip_tac);
(* *** Goal "1.1.5" *** *)
a(LEMMA_T¨{y|∂ A∑ y ç A ± f v ç A ± A ç U} = AÆ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "1.1.5.1" *** *)
a(LEMMA_T¨A = A'Æ asm_rewrite_thm_tac);
a(DROP_NTH_ASM_T 10 bc_thm_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2, 5] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.1.5.2" *** *)
a(∂_tac¨AÆ THEN REPEAT strip_tac);
(* *** Goal "1.1.6" *** *)
a(all_asm_fc_tac[]);
(* *** Goal "1.2" *** *)
a(∂_tac¨HÆ THEN REPEAT µ_tac THEN ¥_tac);
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨Ã(v, r)∑ G (v, r) (v, r)Æ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(bc_thm_tac compatible_family_continuous_thm1);
a(∂_tac¨VÆ THEN POP_ASM_T ante_tac
	THEN LIST_DROP_NTH_ASM_T [1, 2, 3] rewrite_tac);
a(rewrite_tac[∏_def] THEN REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(bc_thm_tac product_topology_thm THEN asm_rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "2.1.2" *** *)
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.3" *** *)
a(rewrite_tac[taut_rule¨µp q∑p ± p ± q § p ± qÆ]);
a(GET_NTH_ASM_T 6 bc_thm_tac);
a(LEMMA_T¨f v ç SpaceâT ”Æ rewrite_thm_tac
	THEN1 (bc_thm_tac continuous_ç_space_t_thm
		THEN ∂_tac¨N ÚâT “Æ
		THEN ALL_FC_T asm_rewrite_tac[ç_space_t_thm, subspace_topology_space_t_thm2]));
a(LEMMA_T¨h(v, a) ç CÆ ante_tac
	THEN1 (DROP_NTH_ASM_T 9 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def, Ø_º_def]));
a(LIST_DROP_NTH_ASM_T [10] (ALL_FC_T rewrite_tac));
(* *** Goal "2.1.4" *** *)
a(LEMMA_T¨h(v, a) ç CÆ ante_tac
	THEN1 (DROP_NTH_ASM_T 9 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def, Ø_º_def]));
a(LIST_GET_NTH_ASM_T [10] (ALL_FC_T rewrite_tac) THEN strip_tac);
a(lemma_tac¨f v ç SpaceâT ”Æ
	THEN1 (bc_thm_tac continuous_ç_space_t_thm
		THEN ∂_tac¨N ÚâT “Æ
		THEN ALL_FC_T asm_rewrite_tac[ç_space_t_thm, subspace_topology_space_t_thm2]));
a(LIST_GET_NTH_ASM_T [8] all_fc_tac);
a(rewrite_tac[subspace_topology_def]);
a(∂_tac¨{v|v ç N ± f v ç A} ∏ UniverseÆ THEN rewrite_tac[∏_def] THEN REPEAT strip_tac);
(* *** Goal "2.1.4.1" *** *)
a(LIST_GET_NTH_ASM_T [11] (PC_T1 "sets_ext1" all_fc_tac));
a(all_fc_tac [continuous_open_thm]);
a(POP_ASM_T discard_tac THEN POP_ASM_T ante_tac);
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]);
a(rewrite_tac[subspace_topology_def] THEN strip_tac);
a(POP_ASM_T (strip_asm_tac o eq_sym_rule));
a(LEMMA_T¨B ° N ç “Æ ante_tac THEN1 all_fc_tac[°_open_thm]);
a(asm_rewrite_tac[product_topology_def] THEN REPEAT strip_tac);
a(∂_tac¨{x|x ç N ± f x ç A}Æ THEN ∂_tac¨UniverseÆ);
a(asm_rewrite_tac[empty_universe_open_closed_thm]);
a(PC_T1 "sets_ext1" prove_tac[∏_def]);
(* *** Goal "2.1.4.2" *** *)
a(PC_T1 "sets_ext1" REPEAT strip_tac);
(* *** Goal "2.1.4.2.1" *** *)
a(lemma_tac¨f v ç A ± f v ç A' ¥ ≥A' ° A = {}Æ
	THEN1 PC_T1 "sets_ext1" prove_tac[]);
a(LIST_DROP_NTH_ASM_T [15] all_fc_tac THEN all_var_elim_asm_tac);
(* *** Goal "2.1.4.2.2" *** *)
a(∂_tac¨AÆ THEN REPEAT strip_tac);
(* *** Goal "2.1.5" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
(* *** Goal "2.1.6" *** *)
a(GET_NTH_ASM_T 8 (strip_asm_tac o list_µ_elim[¨vÆ, ¨rÆ]));
a(DROP_NTH_ASM_T 12 (strip_asm_tac o list_µ_elim[¨wÆ, ¨sÆ]));
a(LIST_DROP_NTH_ASM_T [3, 4, 7, 8] discard_tac);
a(lemma_tac¨p(G(v, r)(w, s)) = h(w, s)Æ
	THEN1 (DROP_NTH_ASM_T 3 bc_thm_tac THEN REPEAT strip_tac
		THEN ∂_tac¨AÆ THEN REPEAT strip_tac));
a(lemma_tac¨p(G(w, s)(w, s)) = h(w, s)Æ
	THEN1 (DROP_NTH_ASM_T 2 bc_thm_tac THEN REPEAT strip_tac
		THEN ∂_tac¨AÆ THEN REPEAT strip_tac));
a(LIST_DROP_NTH_ASM_T [3, 5] discard_tac);
a(DROP_NTH_ASM_T 4 (strip_asm_tac o list_µ_elim[¨wÆ, ¨sÆ])
	THEN1 all_asm_fc_tac[]);
a(DROP_NTH_ASM_T 6 (strip_asm_tac o list_µ_elim[¨wÆ, ¨sÆ])
	THEN1 all_asm_fc_tac[]);
a(lemma_tac¨A' = AÆ);
(* *** Goal "2.1.6.1" *** *)
a(DROP_NTH_ASM_T 17 bc_thm_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [5, 12] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.6.2" *** *)
a(all_var_elim_asm_tac);
a(lemma_tac¨A'' = AÆ);
(* *** Goal "2.1.6.2.1" *** *)
a(DROP_NTH_ASM_T 15 bc_thm_tac THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2, 9] (MAP_EVERY ante_tac)
	THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.6.2.2" *** *)
a(all_var_elim_asm_tac);
a(LIST_DROP_NTH_ASM_T [12] all_fc_tac);
a(POP_ASM_T (ante_tac o rewrite_rule[homeomorphism_def]));
a(all_fc_tac[pc_rule1 "sets_ext1" prove_rule[]
	¨µa u s∑ a ç u ± u Ä s ¥ a ç sÆ]); 
a(ALL_FC_T rewrite_tac[subspace_topology_space_t_thm2]
	THEN REPEAT strip_tac);
a(LEMMA_T ¨g(p(G(w, s)(w, s))) = g(p(G(v, r)(w, s)))Æ ante_tac
	THEN1 asm_rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [2] (ALL_FC_T rewrite_tac));
(* *** Goal "2.2" *** *)
a(DROP_NTH_ASM_T 2 (ante_tac o list_µ_elim[¨xÆ, ¨aÆ]));
a(asm_rewrite_tac[closed_interval_def, Ø_º_def] THEN strip_tac);
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN REPEAT strip_tac);
a(rewrite_tac[taut_rule¨µp q∑p ± p ± q § p ± qÆ]);
a(GET_NTH_ASM_T 10 bc_thm_tac);
a(LEMMA_T¨f x ç SpaceâT ”Æ rewrite_thm_tac
	THEN1 (bc_thm_tac continuous_ç_space_t_thm
		THEN ∂_tac¨N ÚâT “Æ
		THEN ALL_FC_T asm_rewrite_tac[ç_space_t_thm, subspace_topology_space_t_thm2]));
a(LEMMA_T ¨p(f x) = h(x, a)Æ rewrite_thm_tac
	THEN1 LIST_DROP_NTH_ASM_T [14] (ALL_FC_T rewrite_tac));
a(DROP_NTH_ASM_T 13 bc_thm_tac);
a(asm_rewrite_tac[closed_interval_def, Ø_º_def]);
(* *** Goal "2.3" *** *)
a(DROP_NTH_ASM_T 3 (ante_tac o list_µ_elim[¨xÆ, ¨sÆ]));
a(LIST_DROP_NTH_ASM_T[3, 4, 5] rewrite_tac
	THEN REPEAT strip_tac);
a(POP_ASM_T bc_thm_tac THEN asm_rewrite_tac[]);
a(rewrite_tac[taut_rule¨µp q∑p ± p ± q § p ± qÆ]);
a(LEMMA_T¨h(x, a) ç CÆ ante_tac
	THEN1 (DROP_NTH_ASM_T 11 bc_thm_tac THEN asm_rewrite_tac[closed_interval_def, Ø_º_def]));
a(LIST_DROP_NTH_ASM_T [12] (ALL_FC_T rewrite_tac)
	THEN strip_tac);
a(lemma_tac¨f x ç SpaceâT ”Æ
	THEN1 (bc_thm_tac continuous_ç_space_t_thm
		THEN ∂_tac¨N ÚâT “Æ
		THEN ALL_FC_T asm_rewrite_tac[ç_space_t_thm, subspace_topology_space_t_thm2]));
a(DROP_NTH_ASM_T 10 bc_thm_tac THEN REPEAT strip_tac);
pop_thm()
));


val covering_projection_fibration_lemma3 = (* not saved *) snd ( "covering_projection_fibration_lemma3", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c;
	N : 'a SET;
	t : Ó ≠ Ø;
	n : Ó ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	f ç (N ÚâT “, ”) Continuous
±	h ç ((N ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR, ‘) Continuous
±	N ç “
±	(µx∑ x ç N ¥ h(x, 0.) = p(f x))
±	t 0 = 0. ± t n = 1.
±	(µi j∑ i < j ¥ t i < t j)
±	(µi∑ i < n ¥ ∂C∑
			(µx s∑ x ç N ± s ç ClosedInterval (t i) (t(i+1)) ¥ h(x, s) ç C)
		±	C ç ‘
		±	∂U∑
			U Ä ”
		±	(µx∑ x ç SpaceâT ” ± p x ç C ¥ ∂A∑ x ç A ± A ç U)
		±	(µ A B∑ A ç U ± B ç U ± ≥ A ° B = {} ¥ A = B)
		±	(µ A∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism))
¥	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((N ∏ ClosedInterval 0. 1.) ÚâT (“ ∏âT OâR), ”) Continuous
±	(µx∑	x ç N
	¥	L(x, 0.) = f x)
±	(µx s∑	x ç N
	±	s ç ClosedInterval 0. 1.
	¥	p(L(x, s)) = h(x, s))
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨µk∑k < n ¥
	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((N ∏ ClosedInterval 0. (t(k+1))) ÚâT (“ ∏âT OâR), ”) Continuous
±	(µx∑	x ç N
	¥	L(x, 0.) = f x)
±	(µx s∑	x ç N
	±	s ç ClosedInterval 0. (t(k+1))
	¥	p(L(x, s)) = h(x, s))Æ);
a(strip_tac THEN induction_tac¨k:ÓÆ THEN REPEAT strip_tac
	THEN_TRY PC_T1 "lin_arith" asm_prove_tac[]
	THEN rewrite_tac[plus_assoc_thm]);
(* *** Goal "1.1" *** *)
a(bc_thm_tac covering_projection_fibration_lemma2);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac);
a(GET_NTH_ASM_T 8 (strip_asm_tac o list_µ_elim [¨0Æ, ¨1Æ]));
a(LIST_DROP_NTH_ASM_T [1, 7] (MAP_EVERY ante_tac)
	THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
a(MAP_EVERY ∂_tac[¨UÆ, ¨CÆ, ¨‘Æ] THEN asm_rewrite_tac[]);
a(cases_tac¨n = 1Æ THEN1 (all_var_elim_asm_tac1 THEN asm_rewrite_tac[]));
a(lemma_tac¨1 < nÆ THEN1 PC_T1 "lin_arith" asm_prove_tac[]);
a(GET_NTH_ASM_T 11 (strip_asm_tac o list_µ_elim [¨1Æ, ¨nÆ]));
a(POP_ASM_T ante_tac THEN asm_rewrite_tac[] THEN strip_tac);
a(LEMMA_T ¨
	(N ∏ ClosedInterval 0. (t 1)) ÚâT “ ∏âT OâR =
	(N ∏ ClosedInterval 0. (t 1))
		ÚâT (N ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâRÆ
	rewrite_thm_tac
	THEN1 (conv_tac eq_sym_conv THEN bc_thm_tac Ä_subspace_topology_thm
		THEN PC_T1 "sets_ext1" asm_rewrite_tac[closed_interval_def, ∏_def]
		THEN REPEAT strip_tac
		THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(bc_thm_tac subspace_domain_continuous_thm THEN REPEAT strip_tac);
a(bc_tac[subspace_topology_thm, product_topology_thm] THEN REPEAT strip_tac);
a(rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "1.2" *** *)
a(lemma_tac ¨∂M∑
	M ç ((N ∏ ClosedInterval (t(k+1)) (t(k+2))) ÚâT “ ∏âT OâR, ”) Continuous 
±	(µ x∑ x ç N ¥ M(x, t(k+1)) = (Ãx∑ L(x, t(k+1))) x)
±	(µ x s∑ x ç N ± s ç ClosedInterval (t(k+1)) (t(k+2))
	¥	p (M(x, s)) = h (x, s))Æ);
(* *** Goal "1.2.1" *** *)
a(bc_thm_tac covering_projection_fibration_lemma2);
a(DROP_NTH_ASM_T 3 discard_tac);
a(LIST_DROP_NTH_ASM_T [4] all_fc_tac);
a(GET_NTH_ASM_T 10 (ante_tac o list_µ_elim [¨k+1Æ, ¨(k+1)+1Æ])
	THEN rewrite_tac[]);
a(LIST_DROP_NTH_ASM_T [6] (MAP_EVERY ante_tac)
	THEN asm_rewrite_tac[plus_assoc_thm] THEN REPEAT strip_tac);
a(MAP_EVERY ∂_tac[¨UÆ, ¨CÆ, ¨‘Æ] THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac);
(* *** Goal "1.2.1.1" *** *)
a(lemma_tac¨(N ∏ ClosedInterval 0. (t (k + 1))) ÚâT “ ∏âT OâR ç TopologyÆ
	THEN1 basic_topology_tac[open_Ø_topology_thm]);
a(lemma_tac¨N ÚâT “ ç TopologyÆ
	THEN1 basic_topology_tac[]);
a(Ø_continuity_tac[subspace_range_continuous_bc_thm]);
(* *** Goal "1.2.1.1.1" *** *)
a(strip_asm_tac open_Ø_topology_thm);
a(ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(PC_T1 "sets_ext1" rewrite_tac[space_t_Ø_thm, ∏_def]);
a(LEMMA_T ¨N Ä SpaceâT “Æ ante_tac THEN1 all_fc_tac [open_Ä_space_t_thm]);
a(PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "1.2.1.1.2" *** *)
a(rewrite_tac[comb_i_def, comb_k_def, ∏_def]);
a(POP_ASM_T ante_tac THEN ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
	THEN REPEAT strip_tac);
a(rewrite_tac[closed_interval_def]);
a(GET_NTH_ASM_T 15 (ante_tac o list_µ_elim [¨0Æ, ¨k+1Æ])
	THEN rewrite_tac[]);
a(asm_rewrite_tac[] THEN PC_T1 "Ø_lin_arith" prove_tac[]);
(* *** Goal "1.2.1.1.3" *** *)
a(bc_thm_tac subspace_domain_continuous_thm THEN REPEAT strip_tac);
a(ALL_FC_T rewrite_tac[i_continuous_thm]);
(* *** Goal "1.2.1.2" *** *)
a(LEMMA_T ¨
	(N ∏ ClosedInterval (t (k + 1)) (t (k + 2))) ÚâT “ ∏âT OâR =
	(N ∏ ClosedInterval (t (k + 1)) (t (k + 2)))
		ÚâT (N ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâRÆ
	rewrite_thm_tac);
(* *** Goal "1.2.1.2.1" *** *)
a(conv_tac eq_sym_conv THEN bc_thm_tac Ä_subspace_topology_thm);
a(GET_NTH_ASM_T 11 (ante_tac o list_µ_elim [¨0Æ, ¨k+1Æ])
	THEN rewrite_tac[]);
a(PC_T1 "sets_ext1" asm_rewrite_tac[closed_interval_def, ∏_def]
	THEN REPEAT strip_tac
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(cases_tac¨(k+2) = nÆ
	THEN1 (all_var_elim_asm_tac1
		THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨k+2 < nÆ THEN1 PC_T1 "lin_arith" asm_prove_tac[]);
a(DROP_NTH_ASM_T 17 (ante_tac o list_µ_elim [¨k+2Æ, ¨nÆ])
	THEN asm_rewrite_tac[]
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(bc_thm_tac subspace_domain_continuous_thm THEN REPEAT strip_tac);
a(bc_tac[subspace_topology_thm, product_topology_thm]
	THEN asm_rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "1.2.1.3" *** *)
a(conv_tac eq_sym_conv THEN DROP_NTH_ASM_T 10 bc_thm_tac);
a(asm_rewrite_tac[closed_interval_def]);
a(DROP_NTH_ASM_T 11 (ante_tac o list_µ_elim [¨0Æ, ¨k+1Æ])
	THEN asm_rewrite_tac[]
	THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
(* *** Goal "1.2.2" *** *)
a(lemma_tac¨µx∑ x ç N ¥ L(x, t(k+1)) = M(x, t(k+1))Æ
	THEN1 (REPEAT strip_tac THEN ALL_ASM_FC_T rewrite_tac[]));
a(lemma_tac¨0. º t(k+1)Æ
	THEN1(DROP_NTH_ASM_T 10 (ante_tac o list_µ_elim [¨0Æ, ¨k+1Æ])
		THEN asm_rewrite_tac[]
		THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(lemma_tac¨t(k+1) º t(k+2)Æ
	THEN1(DROP_NTH_ASM_T 11 (ante_tac o list_µ_elim [¨k+1Æ, ¨(k+1)+1Æ])
		THEN rewrite_tac[] THEN rewrite_tac[plus_assoc_thm]
		THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(all_fc_tac[open_Ä_space_t_thm]);
a(all_fc_tac[∏_interval_glueing_thm]);
a(∂_tac¨h'Æ THEN rename_tac[(¨h'Æ, "K")] THEN REPEAT strip_tac);
(* *** Goal "1.2.2.1" *** *)
a(LIST_DROP_NTH_ASM_T [14] all_fc_tac);
a(POP_ASM_T (rewrite_thm_tac o eq_sym_rule));
a(DROP_NTH_ASM_T 3 bc_thm_tac);
a(asm_rewrite_tac[closed_interval_def]);
(* *** Goal "1.2.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [1, 3, 4, 10, 14] (MAP_EVERY ante_tac));
a(rewrite_tac[closed_interval_def] THEN REPEAT strip_tac);
a(strip_asm_tac (list_µ_elim[¨sÆ, ¨t(k+1)Æ] Ø_º_cases_thm)
	THEN ALL_ASM_FC_T rewrite_tac[]);
(* *** Goal "2" *** *)
a(lemma_tac¨≥n = 0Æ
	THEN1 (contr_tac THEN all_var_elim_asm_tac1
			THEN PC_T1 "Ø_lin_arith" asm_prove_tac[]));
a(strip_asm_tac (µ_elim ¨nÆ Ó_cases_thm));
a(DROP_NTH_ASM_T 2 discard_tac THEN all_var_elim_asm_tac1);
a(POP_ASM_T (ante_tac o µ_elim¨iÆ));
a(asm_rewrite_tac[]);
pop_thm()
));


val covering_projection_fibration_lemma4 = (* not saved *) snd ( "covering_projection_fibration_lemma4", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c;
	y : 'a ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	h ç (“ ∏âT OâR, ‘) Continuous
±	y ç SpaceâT “
¥	∂n t N∑
		y ç N
	±	N ç “
	±	t 0 = 0.
	±	t n = 1.
	±	(µi j∑ i < j ¥ t i < t j)
	±	µi∑	i < n ¥
		∂C∑	(µ x s∑ x ç N ± s ç ClosedInterval (t i) (t (i + 1)) ¥ h (x, s) ç C)
		±	C ç ‘
		±	∂U∑	U Ä ”
			±	(µ x∑ x ç SpaceâT ” ± p x ç C ¥ (∂ A∑ x ç A ± A ç U))
			±	(µ A B∑ A ç U ± B ç U ± ≥ A ° B = {} ¥ A = B)
			±	(µ A∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism)
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂U∑
U = {A | ∂C∑ C ç ‘ ± A = {vr | vr ç SpaceâT (“ ∏âT OâR) ± h vr ç C} ±
	∂U∑	U Ä ”
	±	(µ x∑ x ç SpaceâT ” ± p x ç C ¥ (∂ A∑ x ç A ± A ç U))
	±	(µ A B∑ A ç U ± B ç U ± ≥ A ° B = {} ¥ A = B)
	±	(µ A∑ A ç U ¥ p ç (A ÚâT ”, C ÚâT ‘) Homeomorphism)}Æ
	THEN1 prove_∂_tac);
a(lemma_tac¨∂n t N∑ t 0 = 0. ± t n = 1. ± (µ i j∑ i < j ¥ t i < t j)
	±	y ç N
	±	N ç “
	±	µi∑ i < n ¥ ∂B∑ B ç U ± (N ∏ ClosedInterval (t i) (t (i+1))) Ä BÆ);
(* *** Goal "1" *** *)
a(bc_thm_tac product_interval_cover_thm);
a(all_var_elim_asm_tac1 THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(PC_T "sets_ext1" strip_tac THEN REPEAT strip_tac THEN all_var_elim_asm_tac1);
a(all_fc_tac[continuous_open_thm]);
(* *** Goal "1.2" *** *)
a(DROP_NTH_ASM_T 5 (strip_asm_tac o rewrite_rule[covering_projection_def]));
a(strip_asm_tac open_Ø_topology_thm);
a(lemma_tac¨(y, s) ç SpaceâT (“ ∏âT OâR)Æ
	THEN1 (ALL_FC_T rewrite_tac[product_topology_space_t_thm]
		THEN asm_rewrite_tac[∏_def, space_t_Ø_thm]));
a(all_fc_tac[continuous_ç_space_t_thm]);
a(LIST_DROP_NTH_ASM_T [5] fc_tac);
a(∂_tac¨{vr|vr ç SpaceâT (“ ∏âT OâR) ± h vr ç C}Æ
	THEN asm_rewrite_tac[]);
a(∂_tac¨CÆ THEN asm_rewrite_tac[]);
a(∂_tac¨UÆ THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(MAP_EVERY ∂_tac [¨nÆ, ¨tÆ, ¨NÆ] THEN all_var_elim_asm_tac1
	THEN asm_rewrite_tac[] THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T [2] all_fc_tac THEN all_var_elim_asm_tac1);
a(∂_tac¨CÆ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 3 (fn th => all_fc_tac[pc_rule1 "sets_ext1"rewrite_rule[∏_def]th]));
(* *** Goal "2.2" *** *)
a(∂_tac¨UÆ THEN asm_rewrite_tac[]);
pop_thm()
));






val covering_projection_fibration_lemma5 = (* not saved *) snd ( "covering_projection_fibration_lemma5", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	h ç (“ ∏âT OâR, ‘) Continuous
±	(µx∑ x ç SpaceâT “ ¥  h (x, 0.) = p (f x))
±	y ç SpaceâT “
¥	∂N : 'a SET∑
	y ç N ± N ç “ ±
	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((N ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR, ”) Continuous
±	(µx∑	x ç N
	¥	L(x, 0.) = f x)
±	(µx s∑	x ç N
	±	s ç ClosedInterval 0. 1.
	¥	p(L(x, s)) = h(x, s))
Æ);
a(REPEAT strip_tac THEN all_fc_tac[covering_projection_fibration_lemma4]);
a(∂_tac¨NÆ THEN REPEAT strip_tac);
a(bc_thm_tac covering_projection_fibration_lemma3);
a(MAP_EVERY ∂_tac[¨nÆ, ¨tÆ, ¨‘Æ]
	THEN asm_rewrite_tac[]
	THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(bc_thm_tac subspace_domain_continuous_thm
	THEN REPEAT strip_tac);
(* *** Goal "2" *** *)
a(bc_thm_tac subspace_domain_continuous_thm
	THEN REPEAT strip_tac);
a(bc_thm_tac product_topology_thm THEN REPEAT strip_tac);
a(accept_tac open_Ø_topology_thm);
(* *** Goal "3" *** *)
a(ALL_FC_T (PC_T1 "sets_ext1" all_fc_tac)[open_Ä_space_t_thm]);
a(DROP_NTH_ASM_T 10 bc_thm_tac THEN strip_tac);
pop_thm()
));




val covering_projection_fibration_thm1 = save_thm ( "covering_projection_fibration_thm1", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c;
	f : 'a ≠ 'b;
	h : 'a ∏ Ø ≠ 'c ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç (“, ”) Continuous
±	h ç (“ ∏âT OâR, ‘) Continuous
±	(µx∑ x ç SpaceâT “ ¥  h (x, 0.) = p (f x))
¥	∂L : 'a ∏ Ø ≠ 'b∑
	L ç ((SpaceâT “ ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR, ”) Continuous
±	(µx∑	x ç SpaceâT “
	¥	L(x, 0.) = f x)
±	(µx s∑	x ç SpaceâT “
	±	s ç ClosedInterval 0. 1.
	¥	p(L(x, s)) = h(x, s))
Æ);
a(REPEAT strip_tac);
a(lemma_tac¨∂N : 'a ≠ 'a SET; K : 'a ≠ 'a ∏ Ø ≠ 'b∑
	µy∑ y ç SpaceâT “ ¥
	y ç N y ± N y ç “ ±
	K y ç ((N y ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR, ”) Continuous
±	(µx∑	x ç N y
	¥	K y (x, 0.) = f x)
±	(µx s∑	x ç N y
	±	s ç ClosedInterval 0. 1.
	¥	p(K y (x, s)) = h(x, s))Æ
	THEN1 (prove_∂_tac THEN strip_tac));
a(cases_tac¨y'' ç SpaceâT “Æ THEN asm_rewrite_tac[]);
a(all_fc_tac[covering_projection_fibration_lemma5]);
a(∂_tac¨LÆ THEN ∂_tac¨NÆ THEN asm_rewrite_tac[]);
(* *** Goal "2" *** *)
a(∂_tac¨Ã(y, s)∑ K y (y, s)Æ THEN rewrite_tac[]
	THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(LEMMA_T¨(Ã (y, s)∑ K y (y, s)) = 
(Ã (y, s)∑ (Ã(y, s)∑K y) (y, s) (y, s))Æ
	pure_rewrite_thm_tac
	THEN1 rewrite_tac[]);
a(bc_thm_tac compatible_family_continuous_thm1);
a(∂_tac¨Ã(y, r)∑(N y ∏ ClosedInterval 0. 1.)Æ THEN asm_rewrite_tac[∏_def]
	THEN REPEAT strip_tac);
(* *** Goal "2.1.1" *** *)
a(bc_thm_tac product_topology_thm THEN
	asm_rewrite_tac[open_Ø_topology_thm]);
(* *** Goal "2.1.2" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(all_fc_tac[open_Ä_space_t_thm]);
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" prove_tac[]);
(* *** Goal "2.1.3" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
(* *** Goal "2.1.4" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(rewrite_tac[subspace_topology_def]);
a(∂_tac¨N v ∏ UniverseÆ THEN REPEAT strip_tac);
(* *** Goal "2.1.4.1" *** *)
a(rewrite_tac[product_topology_def, ∏_def]
	THEN REPEAT strip_tac);
a(∂_tac¨N vÆ THEN ∂_tac¨UniverseÆ THEN asm_rewrite_tac[empty_universe_open_closed_thm]);
(* *** Goal "2.1.4.2" *** *)
a(all_fc_tac[open_Ä_space_t_thm]);
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" prove_tac[∏_def]);
(* *** Goal "2.1.5" *** *)
a(LIST_DROP_NTH_ASM_T [3] all_fc_tac);
a(LEMMA_T ¨{(v', w)|v' ç N v ± w ç ClosedInterval 0. 1.} =
	(N v ∏ ClosedInterval 0. 1.)Æ asm_rewrite_thm_tac);
a(PC_T1 "sets_ext1" prove_tac[∏_def]);
(* *** Goal "2.1.6" *** *)
a(LEMMA_T¨µr∑r ç ClosedInterval 0. 1. ¥
	(Ãr∑K w (w, r)) r = (Ãr∑K v (w, r)) rÆ
	(fn th => ALL_FC_T rewrite_tac[rewrite_rule[]th]));
a(strip_asm_tac open_Ø_topology_thm);
a(LEMMA_T ¨ClosedInterval 0. 1. = SpaceâT(ClosedInterval 0. 1. ÚâT OâR)Æ
	pure_once_rewrite_thm_tac
	THEN1 (ALL_FC_T rewrite_tac[subspace_topology_space_t_thm]
		THEN rewrite_tac[space_t_Ø_thm]));
a(lemma_tac¨ClosedInterval 0. 1. ÚâT OâR ç TopologyÆ
	THEN1 basic_topology_tac[]);
a(bc_thm_tac unique_lifting_thm);
a(MAP_EVERY ∂_tac[¨0.Æ, ¨pÆ, ¨‘Æ, ¨”Æ]
	THEN ALL_FC_T asm_rewrite_tac[subspace_topology_space_t_thm]
	THEN rewrite_tac[space_t_Ø_thm]
	THEN REPEAT strip_tac);
(* *** Goal "2.1.6.1" *** *)
a(ALL_FC_T1 fc_§_canon rewrite_tac[
	conv_rule(ONCE_MAP_C eq_sym_conv)connected_topological_thm]);
a(bc_tac[closed_interval_connected_thm] THEN REPEAT strip_tac);
(* *** Goal "2.1.6.2" *** *)
a(bc_thm_tac comp_continuous_thm);
a(lemma_tac¨“ ∏âT OâR ç TopologyÆ
	THEN1 ALL_FC_T rewrite_tac[product_topology_thm]);
a(lemma_tac¨(N v ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR ç TopologyÆ
	THEN1 ALL_FC_T rewrite_tac[subspace_topology_thm]);
a(∂_tac¨(N v ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâRÆ
	THEN REPEAT strip_tac);
(* *** Goal "2.1.6.2.1" *** *)
a(LEMMA_T¨$, w = Ãr:Ø∑(w, r)Æ once_rewrite_thm_tac
	THEN1 rewrite_tac[]);
a(bc_thm_tac subspace_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.6.2.1.1" *** *)
a(bc_thm_tac right_product_inj_continuous_thm
	THEN REPEAT strip_tac);
a(lemma_tac¨N v ç “Æ THEN1 LIST_DROP_NTH_ASM_T[9] all_fc_tac);
a(ALL_FC_T (PC_T1 "sets_ext1" all_fc_tac)[open_Ä_space_t_thm]);
(* *** Goal "2.1.6.2.1.2" *** *)
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" rewrite_tac[∏_def]
	THEN REPEAT strip_tac);
(* *** Goal "2.1.6.2.2" *** *)
a(LIST_DROP_NTH_ASM_T [9] fc_tac);
(* *** Goal "2.1.6.3" *** *)
a(bc_thm_tac comp_continuous_thm);
a(lemma_tac¨“ ∏âT OâR ç TopologyÆ
	THEN1 ALL_FC_T rewrite_tac[product_topology_thm]);
a(lemma_tac¨N v ç “Æ THEN1 LIST_DROP_NTH_ASM_T[8] all_fc_tac);
a(ALL_FC_T (PC_T1 "sets_ext1" all_fc_tac)[open_Ä_space_t_thm]);
a(lemma_tac¨(N w ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâR ç TopologyÆ
	THEN1 ALL_FC_T rewrite_tac[subspace_topology_thm]);
a(∂_tac¨(N w ∏ ClosedInterval 0. 1.) ÚâT “ ∏âT OâRÆ
	THEN REPEAT strip_tac);
(* *** Goal "2.1.6.3.1" *** *)
a(LEMMA_T¨$, w = Ãr:Ø∑(w, r)Æ once_rewrite_thm_tac
	THEN1 rewrite_tac[]);
a(bc_thm_tac subspace_continuous_thm THEN REPEAT strip_tac);
(* *** Goal "2.1.6.3.1.1" *** *)
a(bc_thm_tac right_product_inj_continuous_thm
	THEN REPEAT strip_tac);
(* *** Goal "2.1.6.3.1.2" *** *)
a(POP_ASM_T ante_tac THEN PC_T1 "sets_ext1" rewrite_tac[∏_def]
	THEN REPEAT strip_tac);
a(LIST_DROP_NTH_ASM_T[12] all_fc_tac);
(* *** Goal "2.1.6.3.2" *** *)
a(LIST_DROP_NTH_ASM_T [11] fc_tac);
(* *** Goal "2.1.6.4" *** *)
a(lemma_tac¨N v ç “Æ THEN1 LIST_DROP_NTH_ASM_T[8] all_fc_tac);
a(ALL_FC_T (PC_T1 "sets_ext1" all_fc_tac)[open_Ä_space_t_thm]);
a(LIST_DROP_NTH_ASM_T [10] fc_tac);
(* It is unclear why so much hand-instantiation is needed here. *)
a(list_spec_nth_asm_tac 5 [¨wÆ, ¨xÆ]);
a(list_spec_nth_asm_tac 10 [¨wÆ, ¨xÆ]);
a(asm_rewrite_tac[]);
(* *** Goal "2.1.6.5" *** *)
a(rewrite_tac[closed_interval_def]);
(* *** Goal "2.1.6.6" *** *)
a(lemma_tac¨N v ç “Æ THEN1 LIST_DROP_NTH_ASM_T[7] all_fc_tac);
a(ALL_FC_T (PC_T1 "sets_ext1" all_fc_tac)[open_Ä_space_t_thm]);
a(LIST_DROP_NTH_ASM_T [9] fc_tac);
a(spec_nth_asm_tac 4 ¨wÆ);
a(spec_nth_asm_tac 9 ¨wÆ);
a(asm_rewrite_tac[]);
(* *** Goal "2.2" *** *)
a(all_asm_fc_tac[] THEN all_asm_fc_tac[]);
(* *** Goal "2.3" *** *)
a(LIST_DROP_NTH_ASM_T [3] fc_tac);
a(LIST_DROP_NTH_ASM_T [5] all_fc_tac);
pop_thm()
));


val covering_projection_continuous_thm = save_thm ( "covering_projection_continuous_thm", (
set_goal([], ¨µ” ‘ p ∑
	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
¥	p ç (”, ‘) Continuous
Æ);
a(rewrite_tac [covering_projection_def] THEN taut_tac);
pop_thm()
));


val covering_projection_fibration_thm = save_thm ( "covering_projection_fibration_thm", (
set_goal([], ¨µ“; ”; ‘;
	p : 'b ≠ 'c ∑
	“ ç Topology
±	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
¥	(“, (p, ”, ‘)) ç HomotopyLiftingProperty
Æ);
a(rewrite_tac [homotopy_lifting_property_def] THEN REPEAT strip_tac
	THEN1 all_fc_tac[covering_projection_continuous_thm]);
a(all_fc_tac[covering_projection_fibration_thm1]);
a(LEMMA_T ¨SpaceâT “ Ä SpaceâT “Æ asm_tac THEN1 rewrite_tac[]);
a(LEMMA_T ¨0. º 1.Æ asm_tac THEN1 rewrite_tac[]);
a(all_fc_tac [closed_interval_extension_thm]);
a(∂_tac¨gÆ THEN REPEAT strip_tac);
(* *** Goal "1" *** *)
a(DROP_NTH_ASM_T 2 ante_tac);
a(strip_asm_tac open_Ø_topology_thm);
a(lemma_tac¨“ ∏âT OâR ç TopologyÆ THEN1 basic_topology_tac[]);
a(LEMMA_T ¨(SpaceâT “ ∏ Universe) = SpaceâT(“ ∏âT OâR)Æ
	(fn th => rewrite_tac[th]
		THEN ALL_FC_T rewrite_tac[trivial_subspace_topology_thm]));
a(ALL_FC_T rewrite_tac[product_topology_space_t_thm]);
a(rewrite_tac[space_t_Ø_thm]);
(* *** Goal "2" *** *)
a(lemma_tac¨0. ç ClosedInterval 0. 1.Æ THEN1 rewrite_tac[closed_interval_def]);
a(ALL_ASM_FC_T asm_rewrite_tac[]);
(* *** Goal "3" *** *)
a(ALL_ASM_FC_T asm_rewrite_tac[]);
pop_thm()
));



val covering_projection_path_lifting_thm = save_thm ( "covering_projection_path_lifting_thm", (
set_goal([], ¨µ”; ‘;
	p : 'a ≠ 'b;
	y : 'a;
	f : Ø ≠ 'b ∑
	” ç Topology
±	‘ ç Topology
±	p ç (”, ‘) CoveringProjection
±	f ç Paths ‘
±	y ç SpaceâT ”
±	p y = f 0.
¥	∂g: Ø ≠ 'a∑
	g ç Paths ”
±	g 0. = y
±	(µs∑ p(g s) = f s)
Æ);
a(REPEAT strip_tac);
a(DROP_NTH_ASM_T 3 (strip_asm_tac o rewrite_rule[paths_def]));
a(lemma_tac¨∂h: Ø ≠ 'a∑
	h ç (OâR, ”) Continuous
±	h 0. = y
±	(µs∑ s ç ClosedInterval 0. 1. ¥ p(h s) = f s)Æ);
(* *** Goal "1" *** *)
a((ante_tac o list_µ_elim[ ¨1âTÆ, ¨”Æ, ¨‘Æ, ¨pÆ])
	covering_projection_fibration_thm);
a(asm_rewrite_tac [homotopy_lifting_property_def,
	one_def, unit_topology_thm, space_t_unit_topology_thm]);
a(ALL_FC_T rewrite_tac[covering_projection_continuous_thm]);
a(STRIP_T (ante_tac o list_µ_elim[ ¨Ãx:ONE∑yÆ, ¨Ã(x:ONE, t)∑f tÆ]));
a(asm_rewrite_tac[] THEN REPEAT strip_tac);
(* *** Goal "1.1" *** *)
a(i_contr_tac THEN POP_ASM_T ante_tac THEN Ø_continuity_tac[unit_topology_thm]);
(* *** Goal "1.2" *** *)
a(i_contr_tac THEN POP_ASM_T ante_tac THEN Ø_continuity_tac[unit_topology_thm]);
(* *** Goal "1.3" *** *)
a(∂_tac¨Ãt∑ L(One, t)Æ THEN asm_rewrite_tac[]);
a(lemma_tac¨1âT ∏âT OâR ç TopologyÆ THEN1 basic_topology_tac[open_Ø_topology_thm]);
a(Ø_continuity_tac[unit_topology_thm, space_t_unit_topology_thm]);
(* *** Goal "2" *** *)
a(DROP_NTH_ASM_T 6 (fn th => all_fc_tac[paths_representative_thm]
	THEN asm_tac th));
a(∂_tac¨gÆ THEN REPEAT strip_tac);
(* *** Goal "2.1" *** *)
a(DROP_NTH_ASM_T 6 (rewrite_thm_tac o eq_sym_rule));
a(DROP_NTH_ASM_T 3 bc_thm_tac THEN rewrite_tac[closed_interval_def]);
(* *** Goal "2.2" *** *)
a(cases_tac¨s ç ClosedInterval 0. 1.Æ THEN1 ALL_ASM_FC_T rewrite_tac[]);
a(DROP_NTH_ASM_T 5 (strip_asm_tac o rewrite_rule[paths_def]));
a(DROP_NTH_ASM_T 4 (strip_asm_tac o rewrite_rule[closed_interval_def]));
(* *** Goal "2.2.1" *** *)
a(lemma_tac¨s º 0.Æ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(ALL_ASM_FC_T rewrite_tac[]);
a(LEMMA_T ¨g 0. = h 0.Æ rewrite_thm_tac THEN1
	(DROP_NTH_ASM_T 8 bc_thm_tac THEN rewrite_tac[closed_interval_def]));
a(DROP_NTH_ASM_T 9 bc_thm_tac THEN rewrite_tac[closed_interval_def]);
(* *** Goal "2.2.2" *** *)
a(lemma_tac¨1. º sÆ THEN1 PC_T1 "Ø_lin_arith" asm_prove_tac[]);
a(ALL_ASM_FC_T rewrite_tac[]);
a(LEMMA_T ¨g 1. = h 1.Æ rewrite_thm_tac THEN1
	(DROP_NTH_ASM_T 8 bc_thm_tac THEN rewrite_tac[closed_interval_def]));
a(DROP_NTH_ASM_T 9 bc_thm_tac THEN rewrite_tac[closed_interval_def]);
pop_thm()
));

output_theory{out_file="wrk0671.th.doc", theory="topology"};
output_theory{out_file="wrk0672.th.doc", theory="metric_spaces"};
output_theory{out_file="wrk0673.th.doc", theory="topology_Ø"};
output_theory{out_file="wrk0674.th.doc", theory="homotopy"};
