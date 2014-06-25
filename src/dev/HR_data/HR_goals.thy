theory HR_goals
imports 
  basicintrostrat
begin

(* Repository of examples using the intro strategy for development  with the HR tool *)

lemma a1: "A \<longrightarrow> A"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply assumption
done

lemma a2: "A \<longrightarrow> A"
  apply (rule impI)
  apply assumption
done


lemma b1: "A \<and> B \<longrightarrow> B \<and> A"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (erule conjE)
  (*apply (rule conjI)*)
  apply (psgraph  intro_simp)
  apply assumption+
done

lemma b2: "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (erule conjE)
  apply (rule conjI)
  apply assumption+
done


lemma c1: "(A \<and> B) \<longrightarrow> (A \<or> B)"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (erule conjE)
 (* apply (rule disjI1)*)
 apply (psgraph intro_simp)
  apply assumption
done

lemma c2: "(A \<and> B) \<longrightarrow> (A \<or> B)"
  apply (rule impI)
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done


(* The next example requires use of the GUI to manually step through the proof and 
backtrack where necessary. Blindly applying the strategy leads to only disjI1 being 
used, which leads to the failures shown.*)

lemma d1: "((A \<or> B) \<or> C) \<longrightarrow> A \<or> (B \<or> C)"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (erule disjE)
  apply (erule disjE)
  (*apply (rule disjI1)*)
  apply (psgraph  intro_simp)
  apply assumption
  (*apply (rule disjI2)*)
  apply (psgraph  intro_simp)
  (*apply (rule disjI1)*)
  apply assumption
  (*apply (rule disjI2)
  apply (rule disjI2)*)
  apply assumption
(*done*)
oops

lemma d2: "((A \<or> B) \<or> C) \<longrightarrow> A \<or> (B \<or> C)"
  apply (rule impI)
  apply (erule disjE)
  apply (erule disjE)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)
  apply (rule disjI1)
  apply assumption
  apply (rule disjI2)+
  apply assumption
done


lemma e1: "A \<longrightarrow> B \<longrightarrow> A"
  (*apply (rule impI)*)
 (* apply (rule impI)*)
 apply (psgraph intro_simp)
 apply (psgraph intro_simp)
  apply assumption
done

lemma e2: "A \<longrightarrow> B \<longrightarrow> A"
  apply (rule impI)+
  apply assumption
done


lemma f1: "(A \<or> A) = (A \<and> A)"
  apply (rule iffI)
  apply (erule disjE)
(*  apply (rule conjI)*)
  apply (psgraph intro_simp)
  apply assumption
  apply assumption
  (*apply (rule conjI)*)
  apply assumption
  apply assumption
  apply (erule conjE)
  (*apply (rule disjI1)*)
  apply assumption
done

lemma f2: "(A \<or> A) = (A \<and> A)"
  apply (rule iffI)
  apply (erule disjE)
  apply (rule conjI)
  apply assumption+
  apply (rule conjI)
  apply assumption+
  apply (erule conjE)
  apply (rule disjI1)
  apply assumption
done


lemma g1: "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
 (* apply (rule impI)
  apply (rule impI)
  apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (psgraph intro_simp)
  apply (psgraph intro_simp)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done

lemma g2: "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
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


lemma h1: "(A \<longrightarrow> B) \<longrightarrow> (B \<longrightarrow> C) \<longrightarrow> A \<longrightarrow> C"
  (*apply (rule impI)
  apply (rule impI)
  apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (psgraph intro_simp)
  apply (psgraph intro_simp)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
oops

lemma h2: "(A \<longrightarrow> B) \<longrightarrow> (B \<longrightarrow> C) \<longrightarrow> A \<longrightarrow> C"
  apply (rule impI)
  apply (rule impI)
  apply (rule impI)
  apply (erule impE)
  apply assumption
  apply (erule impE)
  apply assumption
  apply assumption
done


lemma i1: "\<not>\<not>A \<longrightarrow> A"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (rule classical)
  apply (erule notE)
  apply assumption
done

lemma i2: "\<not>\<not>A \<longrightarrow> A"
  apply (rule impI)
  apply (rule classical)
  apply (erule notE)
  apply assumption
done


lemma j1: "A \<longrightarrow> \<not>\<not>A"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (rule notI)
  apply (erule notE)
  apply assumption
done

lemma j2: "A \<longrightarrow> \<not>\<not>A"
  apply (rule impI)
  apply (rule notI)
  apply (erule notE)
  apply assumption
done


lemma k1: "(\<not>A \<longrightarrow> B) \<longrightarrow> (\<not>B \<longrightarrow> A)"
  (*apply (rule impI)
  apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (psgraph intro_simp)
  apply (rule classical)
  apply (erule impE)
  apply assumption
  apply (erule notE)
  apply assumption
done

lemma k2: "(\<not>A \<longrightarrow> B) \<longrightarrow> (\<not>B \<longrightarrow> A)"
  apply (rule impI)
  apply (rule impI)
  apply (rule classical)
  apply (erule impE)
  apply assumption
  apply (erule notE)
  apply assumption
done


lemma l1: "((A \<longrightarrow> B) \<longrightarrow> A) \<longrightarrow> A"
  (*apply (rule impI)*)
  apply (psgraph intro_simp)
  apply (rule classical)
  apply (erule impE)
  (*apply (rule impI)*)
  apply (psgraph intro_simp)[1]
  apply (erule notE)
  apply assumption
  apply (erule notE)
  apply assumption
done

lemma l2: "((A \<longrightarrow> B) \<longrightarrow> A) \<longrightarrow> A"
  apply (rule impI)
  apply (rule classical)
  apply (erule impE)
  apply (rule impI)
  apply (erule notE)
  apply assumption
  apply (erule notE)
  apply assumption
done


(* Manual backtracking required for first strategy application*)

lemma m1: "A \<or> \<not>A"
  apply (rule classical)
  (*apply (rule disjI2)*)
  apply (psgraph intro_simp)
  apply (rule notI)
  apply (erule notE)
(*  apply (rule disjI1)*)
  apply (psgraph intro_simp)
  apply assumption
(*done*)
oops

lemma m2: "A \<or> \<not>A"
  apply (rule classical)
  apply (rule disjI2)
  apply (rule notI)
  apply (erule notE)
  apply (rule disjI1)
  apply assumption
done


lemma n1: "(\<not>(A \<and> B)) = (\<not>A \<or> B)"
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
oops





end
