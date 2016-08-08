theory heap_example
imports "ai4fm_setup" "heap/HEAP1" "heap/HEAP1Lemmas"
begin  


ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val pre_post_file = "heap_pre_post.psgraph"
  val hca_file = "heap_hca.psgraph"
  val onep_file = "heap_onep.psgraph"
  val structure_file = "heap_structure.psgraph"
  val rippling_file = "heap_rippling.psgraph"; 
  val demo_rippling_file = "rippling/rippling.psgraph" 

 
  val clause_def = "";
  val data =  data   
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val demo_rippling =  PSGraph.read_json_file (SOME data) (pspath ^ demo_rippling_file);
  val pre_post = PSGraph.read_json_file (SOME data) (pspath ^ pre_post_file);
  val hca = PSGraph.read_json_file (SOME data) (pspath ^ hca_file);
  val onep = PSGraph.read_json_file (SOME data) (pspath ^ onep_file);
  val struct_break = PSGraph.read_json_file (SOME data) (pspath ^ structure_file);
  val rippling = PSGraph.read_json_file (SOME data) (pspath ^ rippling_file);
*}

setup {* PSGraphIsarMethod.add_graph ("demo_rippling", demo_rippling) *}
setup {* PSGraphIsarMethod.add_graph ("pre_post", pre_post) *}
setup {* PSGraphIsarMethod.add_graph ("hca", hca) *}
setup {* PSGraphIsarMethod.add_graph ("onep", onep) *}
setup {* PSGraphIsarMethod.add_graph ("struct_break", struct_break) *}
setup {* PSGraphIsarMethod.add_graph ("rippling", demo_rippling) *}

thm F1_inv_def
thm Disjoint_def
thm sep_def
thm nat1_map_def

thm VDMMaps.l_dom_dom_ar
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
lemma dummy: "(x = x) = True"  by auto
lemma dummy2: "(A \<and> True) = A"  by auto

lemma "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow> ((S -\<triangleleft> f) l) = (f l)"
 by (rule VDMMaps.f_in_dom_ar_apply_subsume)

(*declare VDMMaps.f_in_dom_ar_apply_subsume [wrule]*)
declare VDMMaps.f_in_dom_ar_the_subsume [wrule]

(* Now move on to the real heap example *)
(* The PO of new fsb *)
context level1_new
begin
lemmas pre_def = PO_new1_feasibility_def new1_pre_def
lemmas post_def = new1_postcondition_def new1_post_def new1_post_eq_def new1_post_gr_def Set.Ball_def Set.Bex_def
lemmas inv_def = F1_inv_def Disjoint_def  Set.Ball_def
theorem locale1_new_FSB: "PO_new1_feasibility"
(* setup the goal *)
apply (insert l1_new1_precondition_def l1_invariant_def)

(* Pattern: unfolding pre and post -- structure bd*)
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME pre_post) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (tinker pre_post) 
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

(* from here, only prove part of the PO, ignore other subgoals *) 

(* structure breakdown ? donesn't seem to fit here, only unfolding the inv_def *)
unfolding inv_def
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
apply (subst  l_locs_of_Locs_of_iff)
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
