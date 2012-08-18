header {* Some handy theorems used by critics*}
theory IsaPHOLUtils
imports HOL 
begin

(* A theorem for splitting if-statements in IsaPlanner *)
theorem "IsaP_split_if":  "\<lbrakk> Q \<Longrightarrow> P(x); ~Q \<Longrightarrow> P(y) \<rbrakk> \<Longrightarrow> P (if Q then x else y)"
by simp

(* Theorem to use in Synthesis instead of standard reflexivity rule *)
theorem "IsaP_reflexive" : "(x = x) = True"
by simp

theorem "IsaP_eq_commute" : "(x = y) = (y = x)"
by auto

lemmas subst_bool = ssubst[of _ _ "%x. x"]

(* useful cleaning up elim rules that are for some reason missing from HOL *)
lemma trueE[elim!]: "True ==> P ==> P" .
lemma nonFalseE[elim!]: "~ False ==> P ==> P" .

end
