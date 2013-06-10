theory eval_test 
imports
  "../build/Prf"          
begin

(* proof of A \<and> B \<longrightarrow> B \<and> A *)
lemma "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (elim conjE) (* FIXME: won't work in strategy - need to know which asm to use *)
  apply (rule conjI)
  apply assumption
  apply assumption 
  done

lemma "A \<and> B \<longrightarrow> B \<and> A"
  apply (rule impI)
  apply (rule conjI)
  apply (frule conjunct2)
  apply assumption
  apply (frule conjunct1)
  apply assumption 
  done

(* tactics -- to do atac has to be registered! *)
ML{*
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));

   val intro = RTechn.id
            |> RTechn.set_name (RT.mk "rule impI | conjI")
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI","conjI"]));

   val frule = RTechn.id
            |> RTechn.set_name (RT.mk "frule conjuncts")
            |> RTechn.set_atomic_appf (RTechn.FRule (C.mk "conj",StrName.NSet.of_list ["conjunct1","conjunct2"]));
*}

(* goaltyp: need to keep all assumptions (with and in them) *)
ML{*

  val gt = GoalTyp.top

*}

(* psgraph *)
ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;

  val psintro = PSComb.LIFT ([gt],[gt]) (intro);
  val psfrule = PSComb.LIFT ([gt],[gt]) (frule);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psfg3 = psintro THENG psintro THENG psfrule THENG psasm;
*}

(* evaldata *)
ML{*
  val psgraph = psfg3 PSGraph.empty;
  val (pnode,pplan) = PPlan.init @{context} @{prop "A \<and> B \<longrightarrow> B \<and> A"};
  (* get graph and insert pnode  *)

  val edata = EData.init psgraph pplan StrName.NTab.empty [];
*}

(* test evaluation - doesn't terminate... *)

 ML{*
EVal.evaluate_any edata |> Seq.list_of;
*} 

(* test part of it *)
ML{*
val graph = EData.get_graph edata;
val [a,b,c,d] = EVal.EGraph.Util.all_rtechns graph;
*}

(*



(* test instantiation *)
ML{*
structure Theory = EData.PSGraph.PSTheory.PS_Theory;
val [lhs] = EVal.EGraph.mk_lhs graph a;
val rule = Theory.Rule.mk(lhs,lhs);
*}

(* 

  fun match_lhs graph lhs =
     Theory.RulesetRewriter.rule_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
     |> snd
     |> Seq.map (fn m => (Theory.Match.get_match_subst m, Graph.apply_data_subst (Theory.Match.get_match_subst m) lhs));
        
*)
end;


