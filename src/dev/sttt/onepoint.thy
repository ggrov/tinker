theory onepoint
imports sttt_example
begin

lemma ""

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
end
