theory sttt_example
imports sttt_setup
begin
section "the dist example"
thm conj_disj_distribR ex_disj_distrib

lemma "\<exists>x y. (x = y \<or> x > y) \<and> (x*x + y*y = (50::nat))"
(*apply (subst conj_disj_distribR)
apply (subst ex_disj_distrib)+*)
apply (tinker disj)
apply (rule disjI1)
apply (rule_tac x = 5 in exI)+
by simp




section "the telephone example"
typedecl Digitseq

lemma running_example: "callee = Domain(call :: Digitseq rel) \<Longrightarrow> 
       \<forall> x y. y \<in> call `` {x} \<longrightarrow> x \<noteq> y \<Longrightarrow>
       (s1 :: Digitseq) \<noteq> s2 \<Longrightarrow> 
       \<exists> callee' call'. (\<forall> x y. y \<in> call' `` {x} \<longrightarrow> x \<noteq> y) \<and>
         (callee' = Domain call') \<and> call' = call \<union> {(s1, s2)} "
apply (tinker onep)
ML_val {*- 
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME onep0) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

apply (intro conjI) prefer 2 apply (rule refl) prefer 2 apply (rule refl) 
find_theorems "(_ \<or> _)\<longrightarrow>_"
thm Relation.Domain_Un_eq  Set.Un_iff Relation.Un_Image
HOL.conj_disj_distribL HOL.conj_disj_distribR HOL.imp_disjL
apply (subst Relation.Un_Image)
apply (subst Set.Un_iff)+
apply (subst HOL.imp_disjL)

(* end of rippling, now pwf *)
apply (intro allI) apply(erule_tac x = x in allE) apply(erule_tac x = y in allE)
(* end of pwf forall *)
apply (rule conjI)
(*fertilisation*)
apply (simp only:)
(* auto *)
apply simp
ML{*-
  TextSocket.safe_close();
*} 




 
end
