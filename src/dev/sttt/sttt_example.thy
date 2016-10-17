theory sttt_example
imports sttt_setup
begin
typedecl Digitseq

lemma running_example: "callee = Domain(call :: Digitseq rel) \<Longrightarrow> 
       \<forall> x y. x \<in> callee \<and> y \<in> call `` {x} \<longrightarrow> x \<noteq> y \<Longrightarrow>
       (s1 :: Digitseq) \<noteq> s2 \<Longrightarrow> 
       \<exists> callee' call'. (\<forall> x y. x \<in> callee' \<and> y \<in> call' `` {x} \<longrightarrow> x \<noteq> y) \<and>
         (callee' = Domain call') \<and> call' = call \<union> {(s1, s2)} "

ML_val {*- 
  val st =  Thm.cprem_of (#goal @{Isar.goal}) 1 |> Thm.term_of;
  val ps_thm = Tinker.start_ieval @{context} (SOME onep0) (SOME []) (SOME st) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
oops
ML{*-
  TextSocket.safe_close();
*} 




 
end
