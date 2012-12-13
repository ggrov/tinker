theory pp_interface  
imports
  "../build/Parse"
uses
  "../learn/graph_rewrite.ML" 
  "../learn/graph_extract.ML"                           
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

(* parse lemma 1 *)
ML{*
val g1 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem1.yxml")
       |> GraphTransfer.graph_of_goal @{context};
Strategy_Dot.write_dot_to_file false ( path ^ "/ai4fmtalk.dot") g1;    
*}

ML{*
val g = GraphExtract.generalise_best (2,true) (0,false) (2,true) g1 |> snd |> hd
      |> Strategy_Theory.Graph.minimise;
*}

ML{*
Strategy_Dot.write_dot_to_file true ( path ^ "/ai4fmtalk2.dot") g

*}

ML{*
 structure EData = EvalD_DF;
val edata0 = RTechnEval.init_f @{theory} [@{prop "! x y. P x \<and> P y --> P x \<and> P y"}] (fn th => (g1,th))
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);;

Strategy_Dot.write_dot_to_file true ( path ^ "/mmtemp0.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise); 
*} 

(* Debugging: execute internally only, i.e. rewrite graph! *)
ML{*
val [c1,c2] =
maps ((EvalAtomic.debug_eval_tactic edata0)) (GraphEnv.get_rtechns_of_graph (EData.get_graph edata0) |> V.NSet.list_of)
;
val c1' = snd c1;
val c2' = snd c2;
val (gnode,_,rt) = fst c1;
val wset = RTechn.get_outputs rt;
val (SOME outs) = RTechn.get_outputs rt |> W.NSet.tryget_singleton;
val ([pn],pr) = c1';
val ([pn],pr) = c2';
val (pnds,prf) = c2';
*}

ML{*
EvalAtomic.upd_rule wset edata0 gnode (pnds,prf)
*}

ML{*
EvalOutput.upd_by_wire (EData.get_fmatch edata0) gnode pn outs;
*}

ML{*
val (SOME (x,xs)) = Seq.maps (EvalAtomic.eval_atomic edata0) (GraphEnv.get_rtechns_of_graph (EData.get_graph edata0) |> V.NSet.seq_of)
|> Seq.pull;
*}

ML{*
Seq.pull xs
*}


(* end: debugging *)

(* Note: fails for top-level symbol!! *)
ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file true ( path ^ "/mtemp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}

(* Note: fails for symbols (why?) 
    -> is this related to assumption?? *)
ML{*
val edata1 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file true ( path ^ "/mtemp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}
ML{*
val edata1 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file false ( path ^ "/mtemp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}





ML{*
val edata1 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file true ( path ^ "/mtemp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}
(* raises empty: why! -> should just fail because two output fits *)
ML{*
RTechnEval.EData.get_goal edata1 "j"
|> PNode.get_goal
|> rtac @{thm "HOL.conjI"} 1 
|> Seq.list_of
*}
ML{*
val edata1 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/mtemp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}

(* parse lemma 2 *)
ML{*
val g2 =  ParseTree.parse_file (path ^ "/Stratlang/src/parse/examples/attempt_lem2.yxml")
       |> GraphTransfer.graph_of_goal @{context};

Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") g2;
*}

ML{*
GraphEnv.v_to_rtechn;
GraphEnv.get_rtechns_of_graph g2
|> V.NSet.list_of
|> map (GraphEnv.v_to_rtechn g2)
*}


(* eval graph *)
ML{*
 structure EData = EvalD_DF;
val edata0 = RTechnEval.init @{theory} [@{prop "! x. P x --> P x"}] (fn th => (g2,th))
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);;

Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise); 
*} 

ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise );
*}

ML{*
val edata2 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") (EData.get_graph edata2 |> Strategy_Theory.Graph.minimise );
*}

ML{*
val edata3 = RTechnEval.eval_any edata2 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") (EData.get_graph edata3 |> Strategy_Theory.Graph.minimise );
*}

(* graph extraction *)


ML{*
GraphExtract.generalise_best (2,true) (0,false) (2,true) g1;
*}

ML{*

Int.compare;
fun opposite_order ((_,_,ms1),(_,_,ms2)) = 
  case Int.compare (length ms1,length ms2) of
    LESS => GREATER
  | GREATER => LESS
  | x => x;

(sort opposite_order) [("","",[1,2]),("","",[1,2,3])];

sort ;
val [x1,x2] = GraphExtract.get_matching_sub_rule (2,true) (0,false) (2,true) g1;
*}

ML{*
Strategy_Dot.write_dot_to_file ( path ^ "/etemp00.dot") (GraphExtract.generalise_max x1 g1 |> snd |> hd)

*}
(* need to compare the two rules as well *)


ML{*

val xs = GraphExtract.get_matching_sub (2,true) (2,false) (1,true) g1;


val rule = nth xs 0 |>  (fn (r,_,_) => r) |> (Strategy_Theory.Rule.get_lhs);
Strategy_Dot.write_dot_to_file ( path ^ "/etemp0.dot") rule
(*
 |> map (fn (r,_,_) => r) |> map (Strategy_Theory.Rule.get_lhs);
Strategy_Dot.write_dot_to_file ( path ^ "/etemp0.dot") (nth xs 1);  

Strategy_Dot.write_dot_to_file ( path ^ "/etemp0.dot") (nth xs 2);  
*) 
*}

ML{*
fun disjoint_matches g m1 m2 = 
  let 
    fun has_node g v =  case Strategy_Theory.Graph.lookup_vertex g v of
                            NONE => false | _ => true;
    val v1 = m1 
           |> Strategy_Theory.Match.get_vmap 
           |> VInjEndo.get_codset
           |> V.NSet.filter (has_node g) 
           |> V.NSet.filter (GraphEnv.is_rtechn g)
    val v2 = m2 
           |> Strategy_Theory.Match.get_vmap 
           |> VInjEndo.get_codset
           |> V.NSet.filter (has_node g) 
           |> V.NSet.filter (GraphEnv.is_rtechn g)
  in
     V.NSet.is_empty (V.NSet.intersect v1 v2)
  end;
*}

ML{*
val (r,ms) = Strategy_Theory.RulesetRewriter.rule_matches rule g1;
val [m1,m2] = Seq.list_of ms;
*}

ML{*

*}

ML{*
m1 |> Strategy_Theory.Match.get_vmap 
   |> VInjEndo.get_codset 
   |> V.NSet.filter (has_node g1)  
   |> V.NSet.filter (GraphEnv.is_rtechn g1)
*}

ML{*
disjoint_matches g1 m1 m2;
*}

ML{*
fun not_empty [] = false
 |  not_empty _ = true;

val ms = GraphExtract.get_matching_sub (2,true) (0,false) (0,false) g1  |> filter (fn (r,_,ms) => not_empty ms) 
*}

ML{*


type t = VInjEndo.T;
VInjEndo.get_codset;
(* returns targets of match in source graph ~ should be disjoint! *)
Strategy_Theory.Match.get_vmap test |> VInjEndo.get_codset;
*}

(* try to match x2 with g1 *)
ML{*
val g1' = Strategy_Theory.Graph.normalise g1;
val (a,ls) = Strategy_Theory.RulesetRewriter.rule_matches x2 g1';
Strategy_Dot.write_dot_to_file ( path ^ "/etemp0.dot") (Strategy_Theory.Rule.get_lhs x2);  
*}
ML{*
ls |> Seq.list_of |> length
*}

(* 
  fixme: common doesn't work
*)

(* 5 and 6 should be equal*)
ML{*
val g1' = Strategy_Theory.Graph.normalise g1;
val xs = GraphExtract.get_matching_sub (2,true) (2,true) (0,false) g1' |> map (fn (r,_,_) => r);
Strategy_Dot.write_dot_to_file ( path ^ "/extract1.dot") (nth xs 5 |> Strategy_Theory.Rule.get_lhs);
*}

ML{*
val rule = nth xs 5;

*}

(* first rewrite *)
ML{*
val (a,ls) = Strategy_Theory.RulesetRewriter.rule_matches rule g1';
(* check that they disjoint! *)
val [m1,m2] = Seq.list_of ls;
 val g = Strategy_Theory.GraphSubst.do_rewrite m2 (Strategy_Theory.Rule.get_rhs a);
Strategy_Dot.write_dot_to_file ( path ^ "/newg.dot") (g);
*}
(* second rewrite *)
ML{*
val g' = Strategy_Theory.Graph.normalise g;
val (a,ls) = Strategy_Theory.RulesetRewriter.rule_matches rule g';
val [m1] = Seq.list_of ls;
val g = Strategy_Theory.GraphSubst.do_rewrite m1 (Strategy_Theory.Rule.get_rhs a);
Strategy_Dot.write_dot_to_file ( path ^ "/newg.dot") (Strategy_Theory.Graph.minimise g);
*}


ML{*
val [t1,t2] = GraphExtract.get_matching_sub (2,0) g1 |> map (fn (r,_,_) => r) |> map (Strategy_Theory.Rule.get_lhs);
Strategy_Dot.write_dot_to_file ( path ^ "tmp1.dot") t1;
Strategy_Dot.write_dot_to_file ( path ^ "tmp2.dot") t2; 
*}
 
(* eval lemma 2 *)
ML{*
 structure EData = EvalD_DF;
val edata = RTechnEval.init @{theory} [@{prop "! x y. P x \<and> P y --> P x \<and> P y"}] (fn th => (g1,th))
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);;

Strategy_Dot.write_dot_to_file ("/Users/gudmund/etemp0.dot") (EData.get_graph edata |> Strategy_Theory.Graph.minimise); 
*} 

ML{*
val edata = RTechnEval.eval_any edata |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file ( path ^ "/temp0.dot") (EData.get_graph edata |> Strategy_Theory.Graph.minimise );
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


