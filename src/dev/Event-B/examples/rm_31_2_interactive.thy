(* File containing proof attempts.
Rename this file before editing because any changes will be overwritten when exporting next time. *)
theory "rm_31_2_interactive"       
imports  
  "../../../build/HOL_IsaP"    
  "rm_31_2"                                                                                                                     
uses  
 "../../../eval/basic_eval.ML"  
 "../../../eval/eval_atomic.ML"                               
 "../../../eval/rtechn_eval.ML" 
 "../init.ML"
 "../inst.ML"   
 "../subterms.ML"
 "../../../rtechn/basic/rtechn_prj.ML"   
begin
(* NOTE: this example is now (kind of) working *)
(* need to sort the problem of use of forward reasoning *)

datatype Test = test Test Test
              | t 
thm Test.size
print_theorems

thm Test.cases

(*
ML{*
sledgehammer_tac;
Sledgehammer_Tactics.sledgehammer_with_metis_tac;
Sledgehammer_Tactics.sledgehammer_as_oracle_tac;
*}
*)

ML{*

fun pp graph name  = graph
  |> RTechn_Theory.IO_Xml.Output.Graph.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".graph");

fun pp_rule rule name  = rule
  |> RTechn_Theory.IO_Xml.Output.Rule.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".rule");

fun pp_ruleset ruleset name  = ruleset
  |> RTechn_Theory.IO_Xml.Output.Ruleset.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".ruleset");
*}

(*
ML{*
val (g,pp) = PPlan.conj_string_at_top ("g1","P ==> (P \<longrightarrow> P)") (PPlan.init @{context});
val (g',pp') = PPlan.apply_rule_thm @{thm "impI"} "g1" pp |> Seq.list_of |> hd;
PPlan.print pp';
val (g'',pp'') = PPlanTac.apply_allasms_tac ("dummy",(fn th => Seq.single th)) "d" (["e"],pp') |> Seq.list_of |> hd;
val (g'',pp'') = PPlanTac.apply_allasms_tac ("assume",assume_tac 1) "d" (["g1a","e"],pp') |> Seq.list_of |> hd;
*}
*)

lemma "f \<in> tfun UNIV B ==> y \<in> B ==> f <+ {(x,y)} \<in> tfun UNIV B"
 by auto 

(* weirdly: auto just freezes.. *)
lemma aux1: "f \<in> tfun A B ==> x \<in> A \<Longrightarrow> y \<in> B ==> f <+ {(x,y)} \<in> tfun A B"
 apply simp
 apply blast
 done

lemma aux2: "r \<in> rel A B ==> x \<subseteq> A ==> y \<subseteq> B ==> r \<union> (x \<times> y) : rel A B"
 by auto

ML{*
val impIthm = @{thm "impI"};
val conjIthm = @{thm "conjI"};
val allIthm = @{thm "allI"};
val impI_rtechn = RTechnEnv.rule_wire WireNode.default_wire WireNode.default_wire impIthm;
*}

ML{*
val auxthm = @{thm "aux1"};
val aux_rtechn = RTechnEnv.rule_wire WireNode.default_wire WireNode.default_wire auxthm;
*}

ML{*
open RTechnPrj;
*}

ML{*
val res_wire = BWire.of_string "res.resolve";
fun pred rst (g,t) gnode = matches_hyp (GNode.get_goal gnode) rst (g,t);
val prj_res_rtechn = project_prem_rtechn pred res_wire WireNode.default_wire WireNode.default_wire
*}

ML{*
val twire = (BWire.of_string "goal.resolvable",FWire.default_wire);
val fwire = (BWire.of_string "goal.not_resolvable",FWire.default_wire);

fun pred rst (g,t) gnode = matches_hyp (GNode.get_goal gnode) rst (g,t);

val hyps_of =  project_and_filter_facts pred;
val res_wire = BWire.of_string "res.resolve";
fun res_pred gnode rst = case hyps_of rst gnode of
     [] => NONE
    | x => SOME (GNode.add_facts (res_wire,Goaln.NSet.of_list x) gnode);
       
val if_res_rtechn = if_rtechn ("resolvable",res_pred) WireNode.default_wire twire fwire;


val tswire = (BWire.of_string "goal.contains_symbs",FWire.default_wire);
val fswire = (BWire.of_string "goal.not_contains_symbs",FWire.default_wire);

fun symb_pred gnode rst =
  if contains_symb "Collect" (goal_concl_term (GNode.get_goal gnode) (RState.get_pplan rst))
   then (SOME gnode)
   else NONE;

val if_symb_rtechn = if_rtechn ("contains_symb",symb_pred) fwire tswire fswire;

*}

ML{*
val apply_resolveable_rtechn = RTechnEnv.bck_res_wire res_wire twire WireNode.default_wire;
*}


ML{*
val collect_thm = @{thm "Collect_def"};
val collect_rtechn = RTechnEnv.unfold_rtechn tswire tswire [collect_thm];
*}

ML{*
val collect_wire = BWire.of_string "collect"
fun filter_collect_symb _ t _ = ((contains_symb' "Collect") t);
val project_collect_rtechn = project_prem_rtechn filter_collect_symb collect_wire tswire tswire;
*}

ML{*
val colmain = BWire.of_string "goal.collect_unf";
val owire = (colmain,FWire.default_wire);
val subst_collect = RTechnEnv.subst_result_thm_from_wire "subst" (collect_wire,tswire) (collect_wire,owire) tswire collect_thm false;
*}
thm Collect_def

ML{*
val gf = 
  lift impI_rtechn compose 
  lift aux_rtechn compose
  lift if_res_rtechn compose
  (lift apply_resolveable_rtechn tensor
  (lift if_symb_rtechn
   compose 
    (lift (RTechnEnv.auto_on fswire) (* (RTechnEnv.blast fswire) *)
     tensor
    (lift collect_rtechn compose
     lift project_collect_rtechn compose
     lift subst_collect compose
     lift (RTechnEnv.simp_all_asm_full_on owire)))));
*}
(* compose
  lift (RTechnEnv.blast fswire) *)

declare Collect_def[simp]

ML{*
val (t as (g,rst,es)) =
EB_Init.init_rst_from_locale
 ([@{thm "rm_31_2.discover_dn_inv2_INV_goal_def"},@{thm "rm_31_2.discover_dn_inv2_INV_hyps_def"}] @ @{thms "rm_31_2.AUX"})
 "rm_31_2.discover_dn_inv2_INV"
 @{theory} 
 (WireNode.default_wire,gf);
*}

ML{*
pp g "ab1";
*}

ML{*
RTechnComb.get_gnodes rst g;
*}


ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
auxthm;
PPlan.apply_rule_thm auxthm ("d") (RState.get_pplan rst) |> Seq.list_of |> hd;
RTechnEnv.rule_wire WireNode.default_wire WireNode.default_wire auxthm

*}


ML{*
RTechnComb.get_gnodes rst g;
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}


ML{*
RTechnComb.get_gnodes rst g |> hd |> snd |> GNode.GoalSet.list_of;
*}

ML{*
RTechnComb.get_gnodes rst g ;
*}
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
pp g "ab2"
*}
ML{*
RTechnComb.get_gnodes rst g ;
*}

ML{*
RTechnComb.get_gnodes rst g  |> tl |> hd |> snd |> GNode.GoalSet.list_of;
pp g "abrial1";
*}

ML{*
RTechnComb.get_gnodes rst g ;
*}
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;

PPlan.print (RState.get_pplan rst);
*}

ML{*
pp g "ab3"
*}

ML{*
RTechnComb.get_gnodes rst g ;
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [f,s] = en;
val [(t as (g,rst,en))] =
RTechnEval.step_df (g,rst,[s,f]) |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}

ML{*
Prf.get_fixed_full_goal_thm (RState.get_pplan rst) "n"
*}

(* blast fails -- unequal length raised ~~ same issue as with assume tac! *)

(*
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
PPlan.print (RState.get_pplan rst);
*}
*)

ML{*
RTechnComb.get_gnodes rst g ;
*}


ML{*
RTechnComb.get_gnodes rst g |> hd |> snd |> GNode.GoalSet.list_of;
*}

declare [[smt_solver=remote_z3]]

(* discover_dn_inv2_INV *)
sublocale "discover_dn_inv2_INV_hyps" < "discover_dn_inv2_INV_goal"
apply (insert discover_dn_inv2_INV_hyps_axioms)
unfolding "discover_dn_inv2_INV_goal_def" "discover_dn_inv2_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro impI)
apply (elim HOL.conjE)
(* almost identical: would AU work? *)
apply (rule aux1)
apply assumption
apply auto[1] (* or blast *)
apply (unfold Collect_def)
apply simp
done

(* discover_dn_inv4_INV *)
sublocale "discover_dn_inv4_INV_hyps" < "discover_dn_inv4_INV_goal"
apply (insert discover_dn_inv4_INV_hyps_axioms)
unfolding "discover_dn_inv4_INV_goal_def" "discover_dn_inv4_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro impI)
apply (elim HOL.conjE)

(* again - same as previously *)
apply (rule aux2)
apply assumption
apply blast
apply (unfold Collect_def)
apply simp
done


(* discover_dn_inv7_INV *)
sublocale "discover_dn_inv7_INV_hyps" < "discover_dn_inv7_INV_goal"
apply (insert discover_dn_inv7_INV_hyps_axioms)
unfolding "discover_dn_inv7_INV_goal_def" "discover_dn_inv7_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro allI)
apply (intro impI)
apply (elim HOL.conjE)
apply simp
apply (intro impI)
apply (rule iffI)
apply simp
apply (erule disjE)
back
prefer 2
apply assumption
apply simp
apply (elim conjE)
by (metis arith3.eq_plus_number(7) arith3.solve_eq_minus(1) number_of_is_id zadd_0 zadd_assoc zadd_commute zle_add1_eq_le zless_le)


(* discover_dn_inv9_INV *)
sublocale "discover_dn_inv9_INV_hyps" < "discover_dn_inv9_INV_goal"
apply (insert discover_dn_inv9_INV_hyps_axioms)
unfolding "discover_dn_inv9_INV_goal_def" "discover_dn_inv9_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro allI)
apply (intro impI)
apply (elim HOL.conjE)

(* exact the same as: discover_up_inv9_INV *)
apply (case_tac "l=l0")
prefer 2
apply simp
apply simp
apply (case_tac "x = age ' l0 + 1")
apply arith
(* by (metis arith3.solve_eq_plus(2) zadd_commute zle_diff1_eq zless_le) *)
apply (subgoal_tac "((n0, l0), x) \<in> n_net")
prefer 2
apply simp
apply (subgoal_tac "x \<le> age ' l0")
apply arith

apply (elim allE) (* only \<forall>n l x. ((n, l), x) \<in> n_net \<longrightarrow> x \<le> age ' l *)
apply blast 
done

(* discover_dn_inv10_INV *)
sublocale "discover_dn_inv10_INV_hyps" < "discover_dn_inv10_INV_goal"
apply (insert discover_dn_inv10_INV_hyps_axioms)
unfolding "discover_dn_inv10_INV_goal_def" "discover_dn_inv10_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro allI)
apply (intro impI)
apply (elim HOL.conjE)
apply (case_tac "(n,l) = (n0,l0)")

apply simp
apply simp
apply (intro impI)
apply (elim conjE)
(* by (metis arith3.solve_eq_minus(1) zadd_commute zle_diff1_eq zless_le) *)
apply (subgoal_tac "l_age ' (n0, l) \<le> age ' l")
prefer 2
apply (drule spec)+
apply assumption
apply arith
done

(* discover_dn_inv11_INV *)
sublocale "discover_dn_inv11_INV_hyps" < "discover_dn_inv11_INV_goal"
apply (insert discover_dn_inv11_INV_hyps_axioms)
unfolding "discover_dn_inv11_INV_goal_def" "discover_dn_inv11_INV_hyps_def" "AUX"
apply ebsimp'
apply (intro allI)
apply (intro impI)
apply (elim HOL.conjE)
apply (simp (no_asm))
apply (intro conjI)
apply (intro impI)
prefer 2
apply (intro impI)

(* should be similar to strategy for: discover_up_inv11_INV *)
prefer 2 (* first subgoal identical ! *)
apply (rule ccontr)
apply simp
(* would prove first subgoal: apply (metis zle_add1_eq_le zless_le) *)
(* sledgehammer gets Unification bound exceeded on second *)
(* how do I know that this is the required inst? *)
apply (drule_tac x = "n" in spec,
       drule_tac x = "l" in spec,
       drule_tac x = "age ' l + 1" in spec)+
apply simp

(*
WAS: - so very slight difference...
apply simp
apply (elim conjE)
apply (rule disjI2)
*)
apply simp
apply (elim conjE)
apply (rule impI)
apply (rule disjI2)

(* by (metis zle_add1_eq_le) *)

apply (drule_tac x = "n0" in spec,drule_tac x = "l" in spec)+
(* by (metis zle_add1_eq_le) *)
apply (subgoal_tac "l_age ' (n0, l) \<le> age ' l")
prefer 2
apply (elim allE)
apply assumption
apply (subgoal_tac "l_age ' (n0, l) < age ' l + 1")
apply arith
apply arith
done


end
