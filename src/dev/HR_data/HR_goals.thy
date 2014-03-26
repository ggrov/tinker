theory HR_goals
imports 
  Main
  introstrat
begin

(* Repository of examples using the intro strategy for development  with the HR tool *)

lemma "A \<longrightarrow> A"
  (*apply (rule impI)*)
  apply (tactic "psgraph_intro @{context}")
  apply assumption+
done


lemma "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (erule conjE)
  apply (rule conjI)
  apply assumption+
done

lemma "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (erule conjE)
  apply (tactic "psgraph_shortintro @{context}")
  apply assumption
oops


lemma "(A \<and> B) \<longrightarrow> (A \<or> B)"
  apply (tactic "psgraph_intro @{context}")
  apply assumption
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done


lemma "((A \<or> B) \<or> C) \<longrightarrow> A \<or> (B \<or> C)"
  apply (rule impI)
  apply (erule disjE)
  apply (erule disjE)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)
  apply (rule disjI2)
  apply assumption
done


lemma "A \<longrightarrow> B \<longrightarrow> A"
  apply (rule impI)
  apply (rule impI)
  apply assumption
done


lemma "(A \<or> A) = (A \<and> A)"
  apply (rule iffI)
  apply (erule disjE)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done


lemma "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
  apply (rule impI)
  apply (rule impI)
  apply (rule impI)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done


lemma "(A \<longrightarrow> B) \<longrightarrow> (B \<longrightarrow> C) \<longrightarrow> A \<longrightarrow> C"
  apply (rule impI)
  apply (rule impI)
  apply (rule impI)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done


lemma "\<not>\<not>A \<longrightarrow> A"
  apply (rule impI)
  apply (rule classical)
  apply (erule notE)
  apply assumption
done


lemma "A \<longrightarrow> \<not>\<not>A"
  apply (rule impI)
  apply (rule notI)
  apply (erule notE)
  apply assumption
done


lemma "(\<not>A \<longrightarrow> B) \<longrightarrow> (\<not>B \<longrightarrow> A)"
  apply (rule impI)
  apply (rule impI)
  apply (rule classical)
  apply (erule impE)
  apply assumption
  apply (erule notE)
  apply assumption
done


lemma "((A \<longrightarrow> B) \<longrightarrow> A) \<longrightarrow> A"
  apply (rule impI)+
  apply (rule classical)
  apply (erule impE)
  apply (rule impI)
  apply (erule notE)
  apply assumption
  apply (erule notE)
  apply assumption
done


lemma "A \<or> \<not>A"
  apply (rule classical)
  apply (rule disjI2)
  apply (rule notI)
  apply (erule notE)
  apply (rule disjI1)
  apply assumption
done


lemma "(\<not>(A \<and> B)) = (\<not>A \<or> B)"
  apply (rule iffI)
  apply (rule classical)
  apply (erule notE)
  apply (rule conjI)
  apply (rule classical)
  apply (erule notE)
  apply (rule disjI1)
  apply assumption
  apply (rule classical)
  apply (erule notE)
  apply (rule disjI2)
  prefer 2
  apply (rule notI)
  apply (erule conjE)
  apply (erule disjE)
  apply (erule notE)
  apply assumption






end
