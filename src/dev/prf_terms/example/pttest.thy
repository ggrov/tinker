theory pttest
imports  
   "../build/Parse"
begin

ML_val{* proofs := 2 *}

ML_file "../../../parse/proof_term_parse.ML"

ML{*print_depth 20*}


ML{*
 fun left (A %% _) = A;
 fun right (_ %% A) = A;
*}

-- "examples"


lemma p: "A \<Longrightarrow> B \<Longrightarrow> (B \<and> A) \<and> (A \<and> B)"
  apply (rule conjI)
  apply (rule conjI)
  apply assumption
  apply assumption
  apply (rule conjI)
  apply assumption
  apply assumption
done

full_prf p


ML{*
val treep = PTParse.build_tree (PTParse.prf @{thm p})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm1.dot" graph
 *}


lemma q: "True \<and> True"
  apply (rule conjI)
  apply (rule TrueI)
  apply (rule TrueI)
  done

full_prf q

ML{*
val treeq = PTParse.build_tree (PTParse.prf @{thm q})
*}


lemma r:  "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"  full_prf
  apply (rule impI)   full_prf
  apply (rule impI)   full_prf
  apply (rule impI)   full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply (erule impE)  full_prf
  apply assumption    full_prf
  apply assumption    full_prf
done

full_prf r

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm r})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm2.dot" graph
 *}



lemma s: "A \<longrightarrow> \<not>\<not>A"
  apply (rule impI)
  apply (rule notI)
  apply (erule notE)
  apply assumption
 done

full_prf s

ML{*
val trees = PTParse.build_tree (PTParse.prf @{thm s})
*}

lemma mc: "A ==> B ==> C ==> A \<and> B \<and> C"
  by auto

full_prf mc

ML{*
val treemc = PTParse.build_tree (PTParse.prf @{thm mc})
*}

lemma ml: "True \<and> True \<and> (True \<and> True)"
  apply (rule mc)
  apply (rule TrueI)
  apply (rule TrueI)  full_prf
 apply (rule conjI) full_prf
 apply (rule TrueI)
 apply (rule TrueI)
 done

full_prf ml

ML{*
val treeml = PTParse.build_tree (PTParse.prf @{thm ml})
*}

lemma u: "A \<Longrightarrow> A"  full_prf
apply assumption  full_prf
done

full_prf u

ML{*
val treeu = PTParse.build_tree (PTParse.prf @{thm u})
*}


lemma v: "A \<longrightarrow> B \<longrightarrow> A"
  apply (rule impI)
  apply (rule impI)
  apply assumption
done

full_prf v

ML{*
val treev = PTParse.build_tree (PTParse.prf @{thm v})
*}


lemma z: "A \<longrightarrow> A"
 apply auto
done

full_prf z

ML{*
val treez = PTParse.build_tree (PTParse.prf @{thm z})
*}


lemma y: "A \<longrightarrow> A"
  apply (rule impI)
  apply assumption
done

full_prf y

ML{*
val treey = PTParse.build_tree (PTParse.prf @{thm y})
*}


end
