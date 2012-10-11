theory eval_test 
imports
  "../build/Eval"        
begin

consts
  f :: nat
  g :: nat
  P :: "nat => bool"

lemma test: "f = g" sorry

lemma t: "P f" sorry

ML{*

*}

ML{*
 val x = Unsynchronized.ref @{term "t"}; 
 Tactic.rotate_tac;
  
Thm.nprems_of @{thm t};
fun ngls thm = 
 (Thm.prems_of thm |> hd |> Logic.count_prems) - 1;

val ins = Method.insert_tac [@{thm t}] 1;
fun rot thm = Tactic.rotate_tac (ngls thm) 1 thm;
val sub = EqSubst.eqsubst_asm_tac @{context} [1] [@{thm test}] 1;

val mytac = ins THEN rot THEN sub;
*}

lemma "A ==> A  ==> B \<and> B"
  apply (rule conjI)
  apply (tactic "mytac")
  apply (insert t)
  apply (tactic "(fn thm => Tactic.rotate_tac (ngls thm) 1 thm)")
  apply (subst(asm) test)
  oops

ML{*
Logic.count_prems (!x)
*}

ML{*
EqSubst.eqsubst_asm_tac @{context} [0] [@{thm test}] 1 @{thm test} |> Seq.list_of;
*}
ML{*
 val rtechn = RTechn.id
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
            |> RTechn.set_io (W.NSet.single Wire.default_wire);

 val g = GraphComb.theng (GraphEnv.graph_of_rtechn rtechn) (GraphEnv.graph_of_rtechn rtechn);
*}

(* initialise evaluation *)

(* prove A --> A *)

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
Strategy_Dot.write_dot_to_file "/Users/ggrov/left.dot" l;
Strategy_Dot.write_dot_to_file "/Users/ggrov/right.dot" r;
*}

ML{*
val (_,r1,[r2]) = EvalAtomic.eval_mk_all_rules edata l |> Seq.list_of |> hd;
*}

ML{*
 val l1 = EvalAtomic.rewrite r1 l |> hd;
Strategy_Dot.write_dot_to_file "/Users/ggrov/erewr1.dot" l1;
*}

ML{*
Strategy_Dot.write_dot_to_file "/Users/ggrov/e1l.dot" 
  (Strategy_Theory.Rule.get_lhs r1);
Strategy_Dot.write_dot_to_file "/Users/ggrov/e1r.dot" 
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


