theory heap_example
imports Rippling "heap/HEAP1" "heap/HEAP1Lemmas"
begin  

ML{*         
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/rippling/"
  val ps_file = "heap_rippling.psgraph";

  val clause_def = "";
  val data =  data  
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val rippling = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);
*}

setup {* PSGraphIsarMethod.add_graph ("rippling",rippling) *}

thm F1_inv_def
thm Disjoint_def
thm sep_def
thm nat1_map_def

declare  VDMMaps.l_dom_dom_ar [wrule]
lemma finite_Diff[wrule]: "finite A \<Longrightarrow> finite (A - B) = finite A"
by (metis finite_Diff)

(* the first simple rippling example in the book *)
lemma "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"
apply (elim conjE)+ 
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (tinker rippling)
done

ML{*-
TextSocket.safe_close();
*}

thm l_disjoint_dispose1_ext
(* the current example *)
(* The PO of new fsb *)
context level1_new
begin

theorem locale1_new_FSB: "PO_new1_feasibility"
unfolding PO_new1_feasibility_def new1_postcondition_def
apply (insert l1_new1_precondition_def)
unfolding new1_pre_def new1_post_def

unfolding PO_new1_feasibility_def new1_postcondition_def 
unfolding new1_post_def new1_post_eq_def new1_post_gr_def 
apply (subst HOL.conj_disj_distribR) 
apply (subst HOL.ex_disj_distrib)+
(* hidden cases *)
find_theorems "_ \<le> _ = ((_ < _) \<or> _)"
apply (elim bexE)
apply (subst(asm) Orderings.order_class.order.order_iff_strict, erule disjE)
apply (rule disjI2) prefer 2
apply (rule disjI1) prefer 2
apply (subst ex_comm) apply (rule_tac x = l in exI) prefer 2
apply (subst ex_comm) apply (rule_tac x = l in exI) prefer 2

(* one point rule *)
(* TODO, it seems that we need to do more rearrange for the one point rule in PSGraph  *)
apply (subst HOL.conj_commute) apply (subst HOL.conj_commute)
apply (subst HOL.conj_assoc)+
apply (subst HOL.simp_thms(39)) prefer 2
apply (subst HOL.conj_commute) apply (subst HOL.conj_commute)
apply (subst HOL.conj_assoc)+
apply (subst HOL.simp_thms(39)) prefer 2
apply simp_all

apply (insert l1_invariant_def)
unfolding F1_inv_def  apply(elim conjE) prefer 2 apply(elim conjE) prefer 2
apply(intro conjI) 
(* solve the other sgs using sledgehammer *)
prefer 2  
apply (metis k_sep_dom_ar_munion l1_input_notempty_def) prefer 2
apply (metis k_nat1_map_dom_ar_munion l1_input_notempty_def) prefer 2
apply (metis k_finite_dom_ar_munion l1_input_notempty_def) 
(* rippling *)
unfolding Disjoint_def Set.Ball_def
find_theorems "_ \<union>m_"
find_theorems "disjoint (locs_of _ _) (locs _)"


unfolding Locs_of_def


prefer 2


 

apply simp

unfolding F1_inv_def

thm nat1_map_def sep_def
oops

end
end
