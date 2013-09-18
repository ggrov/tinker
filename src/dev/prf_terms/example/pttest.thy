theory pttest
imports  
   "../../../provers/isabelle/build/Parse"
   "../StratGraphs"
begin

ML_val{* proofs := 2 *}



ML{*print_depth 20*}


ML{*
 fun left (A %% _) = A;
 fun right (_ %% A) = A;
*}


-- "examples"

lemma conj_ex:
  fixes A B shows "A \<and> B \<longrightarrow> B \<and> A"             full_prf
  proof -                                       full_prf
    have g: "A \<and> B \<Longrightarrow> B \<and> A"                   full_prf
    proof -                                     full_prf
      assume h: "A \<and> B"                         full_prf
      have i: B                                 full_prf
      proof -                                   full_prf
        from h have o: B by (frule conjunct2)   full_prf
        from o show ?thesis by assumption       full_prf
      qed                                       full_prf
      have j: A                                 full_prf
      proof -                                   full_prf
        from h have n: A by (frule conjunct1)   full_prf
        from n show ?thesis by assumption       full_prf
      qed                                       full_prf
      from i j show ?thesis by (rule conjI)     full_prf
    qed                                         full_prf
    from g show ?thesis by (rule impI)          full_prf
  qed                                           

full_prf conj_ex

ML{*
val treec = PTParse.build_tree (PTParse.prf @{thm conj_ex})
*}




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
*}

ML{*
val graph = PTParse.mk_graph (fn top => GoalTyp.top) treep;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm1.dot" graph
 *}

lemma p1: "C \<Longrightarrow> D \<Longrightarrow> (D \<and> C) \<and> (C \<and> D)"
  apply (psgraph conj_impI)
done




lemma q: "True \<and> True"
  apply (rule conjI)
  apply (rule TrueI)
  apply (rule TrueI)
  done

full_prf q

lemma q1: "True \<and> True"
  apply (psgraph trueI)

oops
ML{*
val treeq = PTParse.build_tree (PTParse.prf @{thm q})
*}


ML{*
val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeq;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm2.dot" graph
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

lemma r1: "(A \<longrightarrow> B \<longrightarrow> C) \<longrightarrow> (A \<longrightarrow> B) \<longrightarrow> A \<longrightarrow> C"
  apply (psgraph  impI_impE)
oops

ML{*
val treer = PTParse.build_tree (PTParse.prf @{thm r})
*}

ML{*
val graph = PTParse.mk_graph (fn top => GoalTyp.top) treer;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm3.dot" graph
 *}



lemma s: "A \<longrightarrow> \<not>\<not>A"
  apply (rule impI)
  apply (rule notI)
  apply (erule notE)
  apply assumption
 done

full_prf s

lemma s1: "A \<longrightarrow> \<not>\<not>A"
  apply (psgraph notI)

oops

ML{*
val trees = PTParse.build_tree (PTParse.prf @{thm s})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) trees;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm4.dot" graph
 *}


lemma mc: "A \<Longrightarrow> B \<Longrightarrow> C \<Longrightarrow> A \<and> B \<and> C"
  by auto

full_prf mc

ML{*
val treemc = PTParse.build_tree (PTParse.prf @{thm mc})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treemc;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm5.dot" graph
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

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeml;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm6.dot" graph
 *}


lemma u: "A \<Longrightarrow> A"  full_prf
apply assumption  full_prf
done

full_prf u

ML{*
val treeu = PTParse.build_tree (PTParse.prf @{thm u})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treeu;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm7.dot" graph
 *}


lemma u1: "B \<Longrightarrow> B"
  apply (psgraph  asm)
done

lemma v: "A \<longrightarrow> B \<longrightarrow> A"
  apply (rule impI)
  apply (rule impI)
  apply assumption
done

lemma v1: "A \<longrightarrow> B \<longrightarrow> A"
  apply (psgraph imp_asm)
oops

full_prf v

ML{*
val treev = PTParse.build_tree (PTParse.prf @{thm v})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treev;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm8.dot" graph
 *}


lemma z: "A \<longrightarrow> A"
 apply auto
done

full_prf z

ML{*
val treez = PTParse.build_tree (PTParse.prf @{thm z})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treez;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm9.dot" graph
 *}


lemma y: "A \<longrightarrow> A"
  apply (rule impI)
  apply assumption
done

full_prf y

ML{*
val treey = PTParse.build_tree (PTParse.prf @{thm y})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treey;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm10.dot" graph
 *}


lemma x: "A \<longrightarrow> A"
 apply (rule impI)
 apply simp
done

full_prf x

ML{*
val treex = PTParse.build_tree (PTParse.prf @{thm x})
*}

ML{*val graph = PTParse.mk_graph (fn top => GoalTyp.top) treex;

   PSGraph.PSTheory.write_dot "/home/colin/Documents/phdwork/proofterms/pterm11.dot" graph
 *}

end
