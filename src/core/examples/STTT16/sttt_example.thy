theory sttt_example
imports sttt_setup
begin
section "the dist example"
thm conj_disj_distribR ex_disj_distrib

ML{*-
  TextSocket.safe_close();
*} 

lemma "\<exists>x y. (x = y \<or> x > y) \<and> (x*x + y*y = (50::nat))"
(*apply (subst conj_disj_distribR)
apply (subst ex_disj_distrib)+*)
apply (tinker disj)
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME disj) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
apply (rule disjI1)
apply (rule_tac x = 5 in exI)+
by simp


section "the telephone example"
declare Relation.Domain_Un_eq [wrule]
declare Set.Un_iff [wrule]
declare Relation.Un_Image [wrule]
declare HOL.conj_disj_distribL [wrule]
declare HOL.conj_disj_distribR [wrule]
declare HOL.imp_disjL [wrule]

typedecl Digitseq

lemma running_example: "callee = Domain(call :: Digitseq rel) \<Longrightarrow> 
       \<forall> x y. y \<in> call `` {x} \<longrightarrow> x \<noteq> y \<Longrightarrow>
       (s1 :: Digitseq) \<noteq> s2 \<Longrightarrow> 
       \<exists> callee' call'. (\<forall> x y. y \<in> call' `` {x} \<longrightarrow> x \<noteq> y) \<and>
         (callee' = Domain call') \<and> call' = call \<union> {(s1, s2)} "
apply (tinker onep)
ML_val {*-
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME onep) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
(* some intermediate steps to simp goals *)
apply (intro conjI) prefer 2 apply (rule refl) prefer 2 apply (rule refl) 
(*apply (tinker rippling)*)
ML_val {*- 
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME rippling) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
done




 
end
