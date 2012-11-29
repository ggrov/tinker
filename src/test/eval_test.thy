theory eval_test 
imports
  "../build/Eval"         
begin

-- "setup of technique"
ML{*

 val path = "/u1/staff/gg112/";
 structure EData = EvalD_DF;
*}

ML{*

Induct.induct_tac;
*}

-- "eval of merge"
ML{*
 GraphEnv.edge_data;

  val rule = eval_merge_rule_of Wire.default_wire;
  val g = Strategy_Theory.Rule.get_rhs rule;
*}

ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "imptest.dot") g;
*}

(* problem seems to occur when output set is empty!! - weird... *) 

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

(* tactic *)

ML{*
 val artechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
            |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
            |> RTechn.set_outputs (W.NSet.single Wire.default_wire);
val gf = LIFT (GraphEnv.graph_of_rtechn artechn);

(* shouldn't need to add atac anymore *)
val edata0 = RTechnEval.init @{theory} [@{prop "A ==> A"}] gf
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);
Strategy_Dot.write_dot_to_file (path ^ "tactest.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise);
*}

ML{*
val [r1] = GraphEnv.get_rtechns_of_graph (EData.get_graph edata0)
|> V.NSet.list_of;
val graph_pat = EvalAtomic.mk_match_graph (EData.get_graph edata0) r1 |> hd;
Strategy_Dot.write_dot_to_file (path ^ "tmp1.dot") (EData.get_graph edata0); 
*}

ML{*
val [gv] = GraphEnv.get_goalnodes_of_graph  (EData.get_graph edata0 )|> V.NSet.list_of ;
val g = GraphEnv.v_to_gnode (EData.get_graph edata0 ) gv;
val rt = GraphEnv.v_to_rtechn (EData.get_graph edata0 ) r1;
val (SOME ra) = RTechn.get_atomic rt;
EvalAppf.apply_appf edata0 g ra |> Seq.list_of;
*}

(* empty *)
ML{*
EvalAtomic.eval_atomic edata0 r1 |> Seq.list_of
*}

(* empty *)
ML{*
EvalAtomic.eval_var_mk_rule_aux edata0 graph_pat |> Seq.list_of
*}


ML{*
    val graph = EData.get_graph edata0
   (* match - FIXME: must be a better way than creating a dummy rule *)
    val subst = Strategy_Theory.RulesetRewriter.rule_matches 
                   (Strategy_Theory.Rule.mk(EData.get_graph edata0,EData.get_graph edata0))
                   (EData.get_graph edata0)
                |> snd
                |> Seq.map Strategy_Theory.Match.get_match_subst
   |> Seq.list_of
*}


ML{*
EvalAtomic.eval_mk_all_rules edata0 graph_pat;
*}
ML{*
EvalAtomic.eval_v_rtechn (gv,r1) (edata0,graph_pat)
*}

ML{*
Strategy_Theory.Rule.mk (graph_pat,graph_pat);
*}



ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of ;
Strategy_Dot.write_dot_to_file (path ^ "tactest.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise);
*}


(* succeeds *)
ML{*
 val artechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
val gf = LIFT (GraphEnv.graph_of_rtechn artechn);

val edata0 = RTechnEval.init @{theory} [@{prop "A ==> A"}] gf
           |> EData.set_tactics (StrName.NTab.of_list [("atac",K (K (atac 1)))]);
Strategy_Dot.write_dot_to_file (path ^ "tactest.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise);
*}


ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file (path ^ "tactest.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise);
*}

ML{*

val ( PPExpThm.EClosed g) = PPExpThm.export_name (EData.get_pplan edata1) "g";
Goal.conclude g; 
*}

ML{*
val prf = EData.get_pplan edata0;
val (SOME g) = PPlan.lookup_node prf "g";
val t = PNode.get_goal g;
PPlanEnv.apply_tactic (g,prf) (atac 1) |> Seq.list_of;
PPlan.apply_all_asm_tac (K (atac 1)) (g,prf) |> Seq.list_of;
*}



(* rules *)

ML{*

 val rtechn1 = RTechn.id
            |> RTechn.set_name "rule impI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);
 val rtechn2 = RTechn.id
            |> RTechn.set_name "rule conjI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "conjI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);

 val gf = LIFT (GraphEnv.graph_of_rtechn rtechn1) THENG LIFT (GraphEnv.graph_of_rtechn rtechn2);
val edata0 = RTechnEval.init @{theory} [@{prop "A --> A \<and> A"}] gf;
*}

-- "evaluate two steps"
ML{*
val edata1 = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
val edata2 = RTechnEval.eval_any edata1 |> Seq.list_of |> hd;
*}

-- "print"
ML{*
Strategy_Dot.write_dot_to_file (path ^ "aag1.dot") (EData.get_graph edata0 |> Strategy_Theory.Graph.minimise);
Strategy_Dot.write_dot_to_file (path ^ "aag2.dot") (EData.get_graph edata1 |> Strategy_Theory.Graph.minimise);
Strategy_Dot.write_dot_to_file (path ^ "aag3.dot") (EData.get_graph edata2 |> Strategy_Theory.Graph.minimise);
*}





(* OLD STUFF (need to delete when necessary) *)



ML{* 
fun lift_vertex node wire =
  let 
   val (v,g) = Strategy_Theory.Graph.empty
             |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert node)
  in
   g |> GraphEnv.add_boundary_from (DB_EdgeData.W wire) v
     |> GraphEnv.add_boundary_to (DB_EdgeData.W wire) v
  end;

fun lift_gnode gnode = lift_vertex (DB_VertexData.GN gnode);
*}

(* graph with goalnode *)
ML{*
val (pnode,pplan) = PPlan.init @{context} @{prop "A --> A"};
val gnode = GNode.mk_goal_no_facts (PNode.get_name pnode);
val (SOME w) = GraphEnv.get_input_wires g |> W.NSet.tryget_singleton;
val pg = lift_gnode gnode w;
val fg = GraphComb.theng pg g |> Strategy_Theory.Graph.normalise;
*}

ML{*
val ptab = StrName.NTab.ins (PNode.get_name pnode,pnode) (StrName.NTab.empty);
val edata = EvalD_DF.init_of pplan fg ptab [] @{theory};
*}

ML{*
 fun init_edata th graph wire term =
   let
     val ctxt = Proof_Context.init_global th;
     val (pnode,pplan) = PPlan.init ctxt term;
     (* need to add according to wire! *)
     val gnode = GNode.mk_goal_no_facts (PNode.get_name pnode);
     val graph_pnode = lift_gnode gnode wire; 
     val graph' = GraphComb.theng graph_pnode graph 
            |> Strategy_Theory.Graph.normalise;
     (* need to look up in context *)
     val ptab = StrName.NTab.ins (PNode.get_name pnode,pnode) (StrName.NTab.empty); 
     (* need to compute enabled *)
     val enabled = []
   in
     EvalD_DF.init_of pplan graph' ptab enabled th
   end;
*}


ML{*
val edata = init_edata @{theory} g Wire.default_wire @{prop "A --> A"};
val [p1,p2] = GraphEnv.get_rtechns_of_graph g
|> V.NSet.list_of
|> maps (EvalAtomic.mk_match_graph g);
*}

ML{*
val (l,r) = EvalAtomic.eval_var_mk_rule edata p1 |> Seq.list_of |> hd |> snd |> hd;
Strategy_Dot.write_dot_to_file "/Users/gudmund/left.dot" l;
Strategy_Dot.write_dot_to_file "/Users/gudmund/right.dot" r;
*}

ML{*
val (_,r1,[r2]) = EvalAtomic.eval_mk_all_rules edata l |> Seq.list_of |> hd;
*}

ML{*
 val l1 = EvalAtomic.rewrite r1 l |> hd;
Strategy_Dot.write_dot_to_file "/Users/gudmund/erewr1.dot" l1;
*}

ML{*
Strategy_Dot.write_dot_to_file "/Users/gudmund/e1l.dot" 
  (Strategy_Theory.Rule.get_lhs r1);
Strategy_Dot.write_dot_to_file "/Users/gudmund/e1r.dot" 
  (Strategy_Theory.Rule.get_rhs r1);

*}


ML{*
(* EvalAtomic.eval_var_mk_rule edata p1; *)
val edata' = EvalAtomic.eval_graph edata p1 |> Seq.list_of |> hd |> Seq.list_of |> hd;
val g = EvalAtomic.EData.get_graph edata;
val g' = EvalAtomic.EData.get_graph edata';
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_before.dot" g;
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_after.dot" g';
(* Unix.execute ("/usr/bin/dot",["-Tjpeg /Users/ggrov/eval_test.dot","-o /Users/ggrov/eval_test.pdf"])
|> Unix.reap
|> OS.Process.isSuccess; *)
(*
val p = Unix.execute ("/bin/ls",[]);
p |> Unix.reap
|> OS.Process.isSuccess;
*)
*}

(* TODO: fixes has to be updated when updating a node within a proof node! *)
ML{*
EvalAtomic.EData.get_pplan edata';
*}

ML{*
val (_,ri,[ros]) = EvalAtomic.eval_var_mk_all_rules edata p1 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test.dot" (Strategy_Theory.Rule.get_lhs ros); 
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test2.dot" (Strategy_Theory.Rule.get_rhs ros);    
*} 

(* rewriting doesn't work -- is it due to input? *)
(*
ML{*
val g = EvalD_DF.get_graph edata |> GraphEnv.add_boundary_to (DB_EdgeData.W Wire.default_wire) (V.mk "Vc")
|> Strategy_Theory.Graph.del_from_boundary (V.mk "Vc") ;
      val [m] = Strategy_Theory.RulesetRewriter.rule_matches ri g |> snd |> Seq.list_of;
val g' = Strategy_Theory.GraphSubst.rewrite g (Strategy_Theory.Rule.get_lhs ri) m (Strategy_Theory.Rule.get_rhs ri)
       |> snd;

(* val g' = EvalAtomic.rewrite ri g |> hd; *)
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test3.dot" g;   
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test4.dot" g'; 
*}
*)

(* doesn't seem to do the final merge of boundary vertices ! *)
(* maybe I need to add to boundary?? *)

ML{*
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_lhs.dot" ol1;   
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_rhs.dot" or2; 

Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test3.dot" g;   
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test4.dot" g'; 
  
*}

(*
ML{*
val g = EvalAtomic.eval_var_mk_rule_aux edata p1 |> Seq.list_of |> hd |> Strategy_Theory.Graph.normalise;
val g' = EvalAtomic.rewrite ri g |> hd;
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test3.dot" g; 
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test4.dot" g'; 
*}
*)

(*
ML{*
val (l,r) = EvalAtomic.eval_var_mk_rule edata p1 |> Seq.list_of |> hd |> snd |> hd;
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test.dot" l; 
Strategy_Dot.write_dot_to_file "/Users/ggrov/eval_test2.dot" r;
*}
*)


















(* match graph  *)
ML{*
val mg = GraphComb.theng (lift_vertex (DB_VertexData.GVar "g") w) 
                         (GraphEnv.graph_of_rtechn rtechn);
*}

(* extract goal node *)
ML{*
val rule = Strategy_Theory.Rule.mk (mg,mg);
val (DB_VertexData.GN gn) = 
   Strategy_Theory.RulesetRewriter.rule_matches rule fg |> snd |> Seq.list_of |> hd
   |> Strategy_Theory.Match.get_match_subst
   |> (fn tab => StrName.NTab.get tab "g");
*}


ML {*
fold;
fun rewrite rule graph = 
  let 
    val matches = Strategy_Theory.RulesetRewriter.rule_matches rule graph |> snd |> Seq.list_of;
    fun rewr match = Strategy_Theory.GraphSubst.rewrite graph (Strategy_Theory.Rule.get_lhs rule) match (Strategy_Theory.Rule.get_rhs rule)
  in
    map (snd o rewr) matches
  end;
*}

(* create a rewrite rule for a given vertex *)
(* needs input edges + output edges *)
(* for each input edge create a rule *)
(* have a map of the lhs of each rule *)
(* important: gnode variable needs to be instantiated 
   (could be identical technique both with goalnodes) 
*)
ML{*

*}


ML{*
;
val (edat,ri,[ro]) = EvalAtomic.eval_rtechn (gn,w) rtechn edata |> Seq.list_of |> hd;
*}


ML{*
Strategy_Dot.output (Strategy_Theory.Rule.get_lhs ro)
*}

(* match with subgraph - works as expected *)
ML{*
val rg = GraphEnv.graph_of_rtechn rtechn;
val rule = Strategy_Theory.Rule.mk (rg,rg);
*}

ML{*
val ms = Strategy_Theory.RulesetRewriter.rule_matches rule g |> snd |> Seq.list_of |> hd;
Strategy_Theory.Match.get_vmap ms;
*}

(* match with just vertex - does not work *)
ML{*
val (v,rg) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
              Strategy_Theory.Graph.empty;
val rule = Strategy_Theory.Rule.mk (rg,rg);
Strategy_Theory.RulesetRewriter.rule_matches rule g |> snd |> Seq.list_of |> length;
*}

(* matching with variable and edges works ~ doesn't work! *)
ML{*
  val (v,rg) = GraphEnv.graph_of_rtechn_vertex rtechn;
  val rg = Strategy_Theory.Graph.update_vertex_data (K (Strategy_OVData.NVert (DB_VertexData.RVar "x")))
           v rg;
  val rule = Strategy_Theory.Rule.mk (rg,rg);
*}

ML{*
val m = Strategy_Theory.RulesetRewriter.rule_matches rule g |> snd |> Seq.list_of |> hd
*}

(* don't really need it! 
    -> we can project the match then create a rewrite rule to delete it! *)

(* can we also get vertex name of it? *)
ML{*
;
*}

(* matching with variable vertex only ~ doesn't work! *)
ML{*
  val (v,rg) = Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RVar "x"))
              Strategy_Theory.Graph.empty;
  val rule = Strategy_Theory.Rule.mk (rg,rg);
*}

ML{*
Strategy_Theory.RulesetRewriter.rule_matches rule g |> snd |> Seq.list_of
*}


(*
methods are stored in Method.Methods which are hidden!
  - how can I get hold of it?
  - maybe via Method.method @{theory} ??
  - need to read upon on out syntax parsing first!
*)

consts x :: "nat" 
       y :: nat

lemma test: "x=y" sorry

lemma test2: "P x"
 apply (tactic "EqSubst.eqsubst_tac @{context} [0] [@{thm test}] 1")
 sorry

ML{*
EqSubst.eqsubst_asm_tac @{context} [0] [@{thm test}] 1 @{thm test2} |> Seq.list_of;
EqSubst.eqsubst_tac;
*}
(* 

eqsubst_asm_tac ctxt occL inthms
eqsubst_tac ctxt occL inthms

*)

end;


