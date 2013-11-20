theory pt_strat_comb
imports
    "../GroupAx"
    "../../../build/isabelle/Eval"
    "../../../provers/isabelle/full/build/IsaP"
    "../../../provers/isabelle//full/build/Parse"
    group_strategy_fullgt
begin

ML_val{* proofs := 2 *}

ML{*
val path = "/home/colin/Documents/phdwork/graphs/pt_comp/"
*}


lemma idorder_basic: "gexp e n = e"   full_prf
  apply (induct n)                    full_prf
  apply (rule l1)                     full_prf
  apply (subst l2)                    full_prf
  apply (subst id_rev)                full_prf
  apply assumption                    full_prf
done

full_prf idorder_basic

ML{*
val basictree = PTParse.build_tree (PTParse.prf @{thm idorder_basic})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) basictree;

PSGraph.PSTheory.write_dot (path ^ "basicgraph") graph
 *}


lemma idorder_strat: "gexp e n = e"               full_prf
  apply (tactic "psgraph_idorder @{context}")     full_prf
  apply assumption                                full_prf
  apply assumption                                full_prf       
done

full_prf idorder_strat

ML{*
val strattree = PTParse.build_tree (PTParse.prf @{thm idorder_strat})

val graph = PTParse.mk_graph (fn top => GoalTyp.top) strattree;

   PSGraph.PSTheory.write_dot (path ^ "stratgraph") graph
 *}


ML{*

*}
end
