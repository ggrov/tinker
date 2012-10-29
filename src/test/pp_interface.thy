theory pp_interface 
imports
  "../build/Parse"
  "../build/Eval"  
begin

ML{*
 val path = "/u1/staff/gg112/"
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

setup {*
Feature_Ctxt.add ("top-level-const",FeatureEnv.fmatch_top_level);
*}
setup {*
Feature_Ctxt.add ("consts",FeatureEnv.fmatch_const);
*}


(*
setup {*
Feature_Ctxt.add ("top-level-const",K (K (K true)));
*}
setup {*
Feature_Ctxt.add ("consts",K (K (K true)));
*} 
*)

(* add dummy output to end *)
ML{*
local open GraphEnv_DB in
    fun add_out_wire v g =
     if E.NSet.is_empty (get_out_edges g v)
       then
            g |> Graph.add_vertex boundary_vertex
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, DB_EdgeData.W Wire.default_wire) v n g)
              |> (fn (_,g') => g') 
       else 
           g
end;

fun upd_w_outs g = 
  fold add_out_wire (V.NSet.list_of (GraphEnv.get_rtechns_of_graph g)) g ;
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

ML{* 

 fun reachable g v1 v2 = true

 fun all_reachable_from g v1 vs = true;

 fun all_reachable g vs = true;
   
 fun naive_subgraphs g = 
   let 
      val ng = Strategy_Theory.Graph.normalise g
      val rts = GraphEnv.get_rtechns_of_graph ng
      val size = V.NSet.cardinality rts
   in
     rts
     |> V.NSet.powerset 
     |> filter (fn vs => V.NSet.cardinality vs > 1 andalso V.NSet.cardinality vs < size)
     |> filter (all_reachable ng)
     |> map (fn vs => Strategy_Theory.Graph.get_open_subgraph vs ng)
   end;

val [s1,s2,s3] = naive_subgraphs g2 |> map Strategy_Theory.Graph.minimise ;
*}

ML{*
Strategy_Dot.write_dot_to_file ( path ^ "/tmp.dot") s1;

*}
(* eval graph *)
ML{*
 structure EData = EvalD_DF;
val edata0 = RTechnEval.init @{theory} [@{prop "! x. P x --> P x"}] (fn th => (g2,th))
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);;

Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_1.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise); 
*}

ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_2.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}

ML{*
val edata2 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_3.dot") (EData.get_graph edata2 |> Strategy_Theory.Graph.minimise );
*}

ML{*
val edata3 = RTechnEval.eval_any edata2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_4.dot") (EData.get_graph edata3 |> Strategy_Theory.Graph.minimise );
*}

(*
ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata0)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

ML{*
val edata1 = RTechnEval.one_step edata0 r2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_2.dot") (EData.get_graph edata1); 
*}
*)

ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata1)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

ML{*
val edata2 = RTechnEval.one_step edata1 r2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_3.dot") (EData.get_graph edata2); 
*}

ML{*
val [r1,r2,r3] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata2)
|> V.NSet.list_of
(* |> maps (EvalAtomic.mk_match_graph g1); *)
*}

ML{*
val edata = edata2;
val graph_pat = g;
    val graph = EData.get_graph edata;
   (* match - FIXME: must be a better way than creating a dummy rule *)

(*
Strategy_Theory.Rule.mk (g,g);
*)
(*
    val subst = Strategy_Theory.RulesetRewriter.rule_matches 
                   (Strategy_Theory.Rule.mk (graph_pat,graph_pat))
                   graph
                |> snd
                |> Seq.map Strategy_Theory.Match.get_match_subst
    val gvars = GraphEnv.get_gvars_of_graph graph_pat;
*)
*}
(*
ML{*
EvalAtomic.eval_var_mk_rule_aux edata2 g
*}
*)



(* termination issue is with tactics!! *)
ML{*
val edata3 = RTechnEval.one_step edata2 r2  |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_3.dot") (EData.get_graph edata2); 
*}


ML{*
EData.get_pplan edata1
*}



ML{*

 EvalAtomic.eval_atomic edata0 r1
*}

ML{*
val pp = EvalAtomic.mk_match_graph (EData.get_graph edata0) r2 |> hd;
val (l,r) =  EvalAtomic.eval_var_mk_rule edata0 pp |> Seq.list_of |> hd |> snd |> hd;
*}
ML{*

EvalAtomic.eval_graph edata p1 |> Seq.list_of |> hd |> Seq.list_of |> hd;
*}

ML{*
Strategy_Dot.write_dot_to_file ( path ^ "/pp_test2_l1.dot") r; 

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


