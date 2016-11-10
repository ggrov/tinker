theory heap_example
imports "ai4fm_setup" "heap/HEAP1" "heap/HEAP1Lemmas"
begin  


thm VDMMaps.f_in_dom_ar_the_subsume
thm l_locs_of_Locs_of_iff

lemma "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow>  Locs_of (S -\<triangleleft> f) l =  Locs_of f l"
by (metis Locs_of_def f_in_dom_ar_apply_not_elem l_dom_ar_notin_dom_or)


ML{*
  (* define your local path here *)
  val pspath = tinker_home ^ "/psgraph/src/dev/ai4fm/"
  val heap_tac_file = "heap_po.psgraph"
  val demo_rippling_file = "rippling/rippling.psgraph" 

  val clause_def = "";
  val data =  data   
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val heap_tac = PSGraph.read_json_file (SOME data) (pspath ^ heap_tac_file);
  val demo_rippling =  PSGraph.read_json_file (SOME data) (pspath ^ demo_rippling_file);

 *}
 
setup {* PSGraphIsarMethod.add_graph ("demo_rippling", demo_rippling) *}
setup {* PSGraphIsarMethod.add_graph ("heap_tac", heap_tac) *}

(* setup wave rules *)
lemma finite_Diff[wrule]: "finite A \<Longrightarrow> finite (A - B) = finite A"
 by (metis finite_Diff)
declare  VDMMaps.l_dom_dom_ar [wrule]
declare VDMMaps.f_in_dom_ar_the_subsume [wrule]

(* the first simple rippling example in the book *)
lemma "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"
apply (elim conjE)+  
apply (-tinker demo_rippling)
ML_val {* -
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME demo_rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
done

ML{*-
TextSocket.safe_close();
*}

thm l_disjoint_dispose1_ext
lemma dummy: "(x = x) = True"  by auto
lemma dummy2: "(A \<and> True) = A"  by auto

lemma "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow> ((S -\<triangleleft> f) l) = (f l)"
 by (rule VDMMaps.f_in_dom_ar_apply_subsume)

lemma munion_def2: "  dom f \<inter> dom g = {}  \<Longrightarrow> f \<union>m g = f \<dagger> g"
by (metis munion_def)
lemma dom_domsub_dagger: "dom ((s -\<triangleleft> f) \<dagger> g) = (dom f - s)  \<union> dom g "
by (metis dagger_def dom_map_add l_dom_dom_ar sup_commute)
lemma in_sminus_sunion:"x \<in> (a - b \<union> c) = (x \<in> a \<and> x \<notin> b \<or> x : c)" 
by (metis DiffE DiffI Un_iff)
lemma impE_fert: "\<lbrakk>(P\<longrightarrow> Q); P' \<Longrightarrow>  P; Q \<Longrightarrow> Q'\<rbrakk> \<Longrightarrow>  (P'\<longrightarrow> Q')" by auto
lemma impE_fert2: "\<lbrakk>(P\<longrightarrow> Q); P' \<Longrightarrow>  P; P'\<Longrightarrow> Q \<Longrightarrow> Q'\<rbrakk> \<Longrightarrow>  (P'\<longrightarrow> Q')" by auto
lemma domsub_dagger_apply: "x \<notin> s \<Longrightarrow> x \<notin> dom g \<Longrightarrow> (s -\<triangleleft> f \<dagger> g) x =  f x" 
by (metis f_in_dom_ar_apply_not_elem l_dagger_apply)

(*declare VDMMaps.f_in_dom_ar_apply_subsume [wrule]*)

(* Now move on to the real heap example *)
(* The PO of new fsb *)
context level1_new
begin
lemmas pre_def = PO_new1_feasibility_def new1_pre_def
lemmas post_def = new1_postcondition_def new1_post_def new1_post_eq_def new1_post_gr_def Set.Ball_def Set.Bex_def
lemmas inv_def = F1_inv_def Disjoint_def  Set.Ball_def
theorem locale1_new_FSB: "PO_new1_feasibility"
(* setup the goal *)
thm l1_new1_precondition_def l1_invariant_def
apply (insert l1_new1_precondition_def l1_invariant_def)
thm PO_new1_feasibility_def new1_postcondition_def new1_pre_def new1_post_def
(* before match_leq, need to elim conj and existence quantifier, maybe in structure brrak down *)
ML_val {* -
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME heap_tac) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (-tinker heap_tac)

apply (elim exE conjE)

(* Move disj up *)
(* GT def
need_move_dis_up :- inst2(concl,"\<exists>x.?P x \<and> ?Q x", X, _), match(X, "?P \<or> ?Q").
need_move_dis_up :- inst2(concl,"\<exists>x.?P x \<and> ?Q x", _, Y), match(Y, "?P \<or> ?Q").
*)


thm HOL.conj_disj_distribR HOL.ex_disj_distrib
apply (subst HOL.conj_disj_distribR)
apply (subst HOL.ex_disj_distrib)+

(* Pattern: hca *)
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME hca) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (tinker hca)

(* Manual steps:  Disj Intro and ex instantiation *)
apply (rule disjI1) prefer 2
apply (rule disjI2) prefer 2

(* now part of one point rule*)
apply (subst ex_comm) apply (rule_tac x = x in exI) prefer 2
apply (subst ex_comm) apply (rule_tac x = x in exI) prefer 2
(* Pattern: one point rule *)
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME onep) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*} 
apply (tinker onep)
prefer 2
apply (tinker onep)
prefer 2

(*TODO: how to encode this in PSGraph*)
prefer 2
apply (subgoal_tac " x + s1 \<notin> dom f1") prefer 2 
apply (unfold  F1_inv_def) 
apply (metis l1_input_notempty_def l_disjoint_mapupd_keep_sep)
prefer 2 

(* from here, only prove part of the PO, ignore other subgoals *) 
(* structure breakdown ? donesn't seem to fit here, only unfolding the inv_def *)
unfolding inv_def (* inv Disjoint *)
apply (elim conjE)+ apply (intro conjI)+
(* some simple sg are dischared by assumption*)
apply assumption 
apply assumption 
apply (rule refl)

(* now all remaining sgs are inv, and the other case *)
(* the sg we now deal with is the INV disjoint *)
(* pre tidy up for rippling , these steps can be potentially pwf for rippling *)
thm VDMMaps.l_dom_dom_ar
thm Set.Diff_iff
apply (subst VDMMaps.l_dom_dom_ar)+
apply (subst Set.Diff_iff)+
apply (intro allI impI)+
apply (elim conjE)+
apply (erule_tac x = xa in allE )
(* pwf for imp *) apply (erule impE) apply assumption
(* elim allE for the inv hyp *) apply (erule_tac x = xb in allE)
(* pwf for imp *) apply (erule impE) apply assumption
(* pwf for imp *) apply (erule impE) apply assumption

(* a bit more tidy up on the definition of Locs_of *)
thm l_locs_of_Locs_of_iff
apply (subst l_locs_of_Locs_of_iff)
apply (metis l_in_dom_ar)
apply (subst  l_locs_of_Locs_of_iff) apply (metis l_in_dom_ar)
apply (subst(asm)  l_locs_of_Locs_of_iff) apply metis
apply (subst(asm)  l_locs_of_Locs_of_iff) apply metis

(* rippling *)
thm VDMMaps.f_in_dom_ar_the_subsume 
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*} 
apply (subst VDMMaps.f_in_dom_ar_apply_subsume)apply (metis l_in_dom_ar)
apply (subst VDMMaps.f_in_dom_ar_apply_subsume) apply (metis l_in_dom_ar)
apply assumption

(* inv sep *)
unfolding sep_def Set.Ball_def
thm VDMMaps.l_dom_dom_ar thm Set.Diff_iff
apply (subst VDMMaps.l_dom_dom_ar)+

apply (intro allI) apply(rotate_tac 4) apply (erule_tac x = xa in allE)
apply (subst Set.Diff_iff)
apply (erule impE_fert2, elim conjE, assumption)
apply (subst VDMMaps.f_in_dom_ar_apply_subsume)

apply (intro conjI) 
 apply assumption
  apply (erule impE_fert2) apply assumption
apply (subst VDMMaps.f_in_dom_ar_apply_subsume)


(* the other strand of this inv po*)
prefer 4
apply (elim conjE)+ apply (intro conjI)+
(* some simple sg are dischared by assumption*)
apply assumption 
apply assumption 
apply (rule refl)


thm munion_def2 l_locs_of_Locs_of_iff
(* unfolding munion*)
apply (subst munion_def2)   
apply simp apply (metis F1_inv_def l1_input_notempty_def l1_invariant_def l_disjoint_mapupd_keep_sep l_dom_ar_not_in_dom)
apply (subst munion_def2)   
apply simp apply (metis F1_inv_def l1_input_notempty_def l1_invariant_def l_disjoint_mapupd_keep_sep l_dom_ar_not_in_dom)
apply (subst munion_def2)   
apply simp apply (metis F1_inv_def l1_input_notempty_def l1_invariant_def l_disjoint_mapupd_keep_sep l_dom_ar_not_in_dom)
apply (subst munion_def2)   
apply simp apply (metis F1_inv_def l1_input_notempty_def l1_invariant_def l_disjoint_mapupd_keep_sep l_dom_ar_not_in_dom)

(* some rippling steps for the condition, then inst quantifier, and then apply pwf for implication *)
 apply (subst dom_domsub_dagger)+
 apply (subst in_sminus_sunion)+
 apply (subst HOL.imp_disjL)+
 (* inst quantifiers accordingly *)
 apply (rule allI) apply (erule_tac x = xa in allE) apply (intro conjI)
 (* pwf*)
  (* the condition part *)
  apply (erule impE_fert2, elim conjE) apply assumption
  (* the main body, a similar routine as the outer layer, i.e.  quantifiler + pwf *)
  apply (rule allI) apply (erule_tac x = xb in allE) apply (intro conjI) 
  apply (erule impE_fert2, elim conjE) apply assumption
  apply (erule impE_fert2) apply assumption
  (* unfodling def of Locs_of to locs_of *)
  apply (subst l_locs_of_Locs_of_iff) apply simp 
  apply (metis DiffI in_dagger_domL l_dom_dom_ar singletonD)
  apply (subst l_locs_of_Locs_of_iff) apply simp 
  apply (metis DiffI in_dagger_domL l_dom_dom_ar singletonD)
  apply (subst(asm) l_locs_of_Locs_of_iff, simp)+
 (* rippling steps *)
 thm domsub_dagger_apply
 apply (subst domsub_dagger_apply) apply simp apply simp apply metis
 apply (subst domsub_dagger_apply) apply simp apply simp apply metis
 (* fert *) apply assumption
oops



find_theorems "_ -\<triangleleft> _ \<dagger>   _" 
thm  munion_def  l_locs_of_Locs_of_iff l_dagger_apply
thm f_in_dom_ar_subsume



apply(subst VDMMaps.l_munion_dom_ar_singleton_subsume)
find_theorems "_\<union>m_"

thm VDMMaps.l_dom_dom_ar
thm Set.Diff_iff
apply (subst VDMMaps.l_dom_dom_ar)+
apply (subst Set.Diff_iff)+
apply (intro allI impI)+
apply (elim conjE)+
apply (erule_tac x = xa in allE )
(* pwf for imp *) apply (erule impE) apply assumption
(* elim allE for the inv hyp *) apply (erule_tac x = xb in allE)
(* pwf for imp *) apply (erule impE) apply assumption
(* pwf for imp *) apply (erule impE) apply assumption

(* a bit more tidy up on the definition of Locs_of *)
apply (subst  l_locs_of_Locs_of_iff)
apply (metis l_in_dom_ar)
apply (subst  l_locs_of_Locs_of_iff) apply (metis l_in_dom_ar)
apply (subst(asm)  l_locs_of_Locs_of_iff) apply metis
apply (subst(asm)  l_locs_of_Locs_of_iff) apply metis

(* alternatiely, we can show the seq inv *)
unfolding sep_def Ball_def
apply (intro allI impI)
apply (rotate_tac -4)
apply( erule_tac x = xa in allE)
apply (elim impE) apply (metis l_dom_ar_not_in_dom)
(* rippling *)
apply (subst VDMMaps.l_dom_dom_ar)+


ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
oops

end


context level1_dispose
begin

theorem locale1_dispose_FSB: "PO_dispose1_feasibility"

unfolding PO_dispose1_feasibility_def dispose1_postcondition_def
apply (insert  l1_invariant_def)
apply (simp add: dispose1_equiv)
unfolding dispose1_post2_def F1_inv_def
oops
end
end
