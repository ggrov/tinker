theory sttt_example
imports sttt_setup
begin
section "the dist example"
thm conj_disj_distribR ex_disj_distrib

ML{*-
(* a command to reset the GUI connection, if needed. No need to run this if everything goes well *)
  TextSocket.safe_close();
*} 

lemma "\<exists>x y. (x = y \<or> x > y) \<and> (x*x + y*y = (50::nat))"
(*apply (subst conj_disj_distribR)
apply (subst ex_disj_distrib)+*)
  (* auto mode, no need to launch GUI *)
  apply (tinker disj)
 (* interactive mode for debugging *)
 (*apply (itinker disj)*)   
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
  apply (tinker onep) (*  apply (itinker onep) *)
(* some intermediate steps to simp goals *)
  apply (intro conjI) prefer 2 apply (rule refl) prefer 2 apply (rule refl) 
  apply (tinker rippling) (*apply (itinker rippling)*)
  done

end
