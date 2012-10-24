theory pp_interface 
imports
  "../build/Parse"
  "../build/Eval"
begin

ML{*
 val path = "/Users/ggrov/"
*}

lemma lem1: "! x y. P x \<and> P y --> P x \<and> P y"
 apply (rule allI)
 apply (rule allI)
 apply (rule impI)
 apply (rule conjI)
 apply (erule conjE)
  apply assumption
  apply (erule conjE)
 apply assumption
 done

lemma lem2: "! x. P x --> P x"
 apply (rule allI)
 apply (rule impI)
 apply assumption
 done

(* fixme change to Feature_Theory *)
(* fixme: add dynamically within feature lib *)

(*
setup {*
Feature_Ctxt.add ("top-level-const",FeatureEnv.fmatch_top_level);
*}
setup {*
Feature_Ctxt.add ("consts",FeatureEnv.fmatch_const);
*}
*) 


setup {*
Feature_Ctxt.add ("top-level-const",K (K (K true)));
*}
setup {*
Feature_Ctxt.add ("consts",K (K (K true)));
*} 


ML{*
val g1 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml")
       |> GraphTransfer.graph_of_goal @{context};

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test1.dot") g1;
*}

ML{*
val g2 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml")
       |> GraphTransfer.graph_of_goal @{context};

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2.dot") g2;
*} 


(* eval graph *)
ML{*
 structure EData = EvalD_DF;
val edata0 = RTechnEval.init @{theory} [@{prop "! x. P x --> P x"}] (fn th => (g2,th));

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_1.dot") (EData.get_graph edata0);
*}


(* doesn't terminate!! *)
(* is it features or application ~ the latter by the looks of things... *)
(*
ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
*}
*)



ML{*
Context.theory_of;
Global_Theory.get_thm @{theory} "allI";

Facts.named "HOL.allI";

*}


ML{*

exists;
@{term "F"} = @{term "FG"}
*}

(* example similar lemmas *)







ML{*
 val t1 = @{term " P x \<and> P y \<Longrightarrow> P x"};
 val t2 = @{term "\<And>x y. P x \<and> P y \<Longrightarrow> P x"};
*}
ML{*
 GraphTransfer.get_missing_hyps @{context} ("\<And>x y. P x \<and> P y \<Longrightarrow> P x",["\<And>x y. P x \<and> P y \<Longrightarrow> P x"]);
*}

ML{*
val rtechn_l1 = GraphTransfer.rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
val rtechn_l2 = GraphTransfer.rtechns_of_file @{context} (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml");
*}

(* next: start making graph! *)


ML{*
 val g2 = ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml");
 val graph = GraphTransfer.graph_of_goal @{context} g2;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test1adsf.dot") graph 
(*     dot -Tpdf pp_test1.dot -o pp_test1.pdf 
*)
*}

end;


