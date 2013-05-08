theory eval_test 
imports
  "../build/Eval"         
begin

-- "setup of technique"
ML{*
 val path = "/u1/staff/gg112/";
 structure EData = EvalD_DF;
*}


-- "the conjunction wire"
ML{*
 val conj_feature = Feature.Strings (StrName.NSet.single "HOL.conj","top-level-const");
 val conj_bwire = BWire.default_wire 
                |> BWire.set_pos (F.NSet.single conj_feature)
                |> BWire.set_name (SStrName.mk "asm_conj");
 val conj_wire =  Wire.default_wire
               |> Wire.set_name (SStrName.mk "asm_conj")
               |> Wire.set_facts (BW.NSet.single conj_bwire);

 val imp_feature = Feature.Strings (StrName.NSet.single "HOL.imp","top-level-const");
 val imp_bwire = BWire.default_wire 
                |> BWire.set_pos (F.NSet.single imp_feature)
                |> BWire.set_name (SStrName.mk "asm_imp");
 val imp_wire =  Wire.default_wire
               |> Wire.set_name (SStrName.mk "asm_imp")
               |> Wire.set_facts (BW.NSet.single conj_bwire);

*}


-- "the reasoning techniques"
ML{*
val impI = 
 RTechn.id
 |> RTechn.set_name "impI"
 |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_outputs (W.NSet.of_list [conj_wire (* ,Wire.default_wire *)])
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.impI"));

val conjI = 
 RTechn.id
 |> RTechn.set_name "conjI"
 |> RTechn.set_inputs (W.NSet.single conj_wire)
 |> RTechn.set_outputs (W.NSet.single conj_wire)
 |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "HOL.conjI"));

val fwd_conjunct = 
 RTechn.id
 |> RTechn.set_name "fwd_conjunct"
 |> RTechn.set_inputs (W.NSet.single conj_wire)
 |> RTechn.set_outputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_atomic_appf (RTechn.FRule ("asm_conj",StrName.NSet.of_list ["conjunct1","conjunct2"]));

 val artechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"))
            |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
            |> RTechn.set_outputs (W.NSet.single Wire.default_wire);

*}

ML{*
  (* set path to where you want the graphs written *)
  val path = "/u1/staff/gg112/";
*}

-- "short example"
ML{*
val gf = LIFTRT impI THENG LIFTRT artechn;
val edata0 = RTechnEval.init_f @{theory} [@{prop "A --> A"}] gf;
*}

ML{*
EvalAtomic.eval_mk_rule;
EvalGraph.add_outputs;
*}

ML{*
  RTechnEval.EData.print edata0;
  val [edata,_] = RTechnEval.eval_any edata0 |> Seq.list_of;
  Strategy_Dot.write_dot_to_file false (path ^ "vsimplex00.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
  RTechnEval.EData.print edata
*}

ML{*
  val [edata] = RTechnEval.eval_any edata |> Seq.list_of; 
  Strategy_Dot.write_dot_to_file false (path ^ "vsimplex00.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
  RTechnEval.EData.print edata;
  PPExpThm.export_name  (RTechnEval.EData.get_pplan edata) "g";
*}

(* to do (Colin) 
    - use pplan object (see proof/pplan.ML and proof/pnode.ML)
    - try to turn the tree into a structured proof
*)
ML{*
val pplan = RTechnEval.EData.get_pplan edata;
(* root node (name) *)
val roots = PPlan.get_root_nms pplan;
(* turn into a singleton list *)
val [rootname] = StrName.NSet.list_of roots;
(* get the actual root node *)
val (SOME root) = PPlan.lookup_node pplan rootname;
(* get the children (now using proof node) *)
val childnames = PNode.get_result root;

val script = Pretty.block 
               [Pretty.str "lemma: ",
                Syntax.pretty_term (PNode.get_ctxt root) (Thm.concl_of (PNode.get_goal root))];

val script = Pretty.block [script,Pretty.fbrk,Pretty.str "proof -",Pretty.fbrk,Pretty.str "qed"];

Pretty.writeln (Print_Mode.setmp [] (fn () => script) ())
*}

(*
;
*)



(* fixme: fails in exporting *)
ML{*
PPExpThm.export_name (RTechnEval.EData.get_pplan edata) "g" |> PPExpThm.prj_thm
*}


-- "long example"
ML{*
val gf = LIFTRT impI THENG LIFTRT conjI THENG LIFTRT fwd_conjunct THENG LIFTRT artechn;
val edata0 = RTechnEval.init_f @{theory} [@{prop "A \<and> B --> B \<and> A"}] gf;
*}

ML{*

  (* creates a dot file (open with graphviz) *)
 Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") 
   (RTechnEval.EData.get_graph edata0 |> Strategy_Theory.Graph.minimise);
*}

ML{*
  val [edata] = RTechnEval.eval_any edata0 |> Seq.list_of;
  Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*
  val [edata] = RTechnEval.eval_any edata |> Seq.list_of; 
  Strategy_Dot.write_dot_to_file false (path ^ "simplexdebug.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*


RTechnEval.EData.print edata;
*}
ML{*
PPlan.print (RTechnEval.EData.get_pplan edata)
*}

(* problem is facts is not working *)
ML{*
val graph = RTechnEval.EData.get_graph edata;
val gns = GraphEnv.get_goalnodes_of_graph graph |> V.NSet.list_of;
val [g1,g2] = map (GraphEnv.v_to_gnode graph) gns;
*}

ML{*
val pplan = RTechnEval.EData.get_pplan edata;
val (SOME goal) = PPlan.lookup_node pplan "j";
val assms = PNode.get_assms goal;
val lassms = PNode.get_lassms goal;
val th1 = StrName.NTab.get assms "h";
val th2 = [@{thm conjunct1},@{thm conjunct2}];
*}

ML{*
WMatch.bwire_match (RTechnEval.EData.get_fmatch edata) (PNode.get_ctxt goal) conj_bwire th1
*}


ML{*
val (_,prf) = PPlanEnv.apply_frule (goal,pplan) [th1] th2;
PPlan.print prf
*}

ML{*
  val [edata] = RTechnEval.eval_any edata |> Seq.list_of; 
  Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*
  val edata = RTechnEval.eval_any edata |> Seq.list_of |> hd; 
  Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*
  val edata = RTechnEval.eval_any edata |> Seq.list_of |> hd; 
  Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*
  val edata = RTechnEval.eval_any edata |> Seq.list_of |> hd; 
  Strategy_Dot.write_dot_to_file false (path ^ "simplex.dot") (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise);
*}

ML{*
PPlan.print (RTechnEval.EData.get_pplan edata)
*}
















(* from here *)

ML{*
append;
curry (op ::);
val gf = LIFT (GraphEnv.lift_merge 3 Wire.default_wire);
val (g,th) = gf @{theory};
val g = GraphComb.self_loops g;
val edata0 = RTechnEval.init_g @{theory} [@{prop "A \<and> A"}] g;
Strategy_Dot.write_dot_to_file false (path ^ "test2.dot") (RTechnEval.EData.get_graph edata0); 
*}


ML{*
 val edata = RTechnEval.eval_any edata0 |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file false (path ^ "test2.dot") (RTechnEval.EData.get_graph edata);
*}

ML{*
 val edata = RTechnEval.eval_any edata |> Seq.list_of |> hd;
Strategy_Dot.write_dot_to_file false (path ^ "test2.dot") (RTechnEval.EData.get_graph edata);
*}

ML{*
PPlan.print (RTechnEval.EData.get_pplan edata)
*}



ML{*
Induct.induct_tac;
*}

-- "eval of identity"

ML{*
val test = RTechn.id
 |> RTechn.set_name "test"
 |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_outputs (W.NSet.single Wire.default_wire);

val gf = LIFTRT test THENG LIFTRT test;
val edata0 = RTechnEval.init_f @{theory} [@{prop "A \<and> A"}] gf;
Strategy_Dot.write_dot_to_file false (path ^ "test.dot") (RTechnEval.EData.get_graph edata0);
*}

ML{*
val v = GraphEnv.get_rtechns_of_graph (RTechnEval.EData.get_graph edata0) |> V.NSet.list_of |> hd;
val [rule] = RTechnEval.mk_eval_identity_rule' edata0 v ;
val lhs = Strategy_Theory.Rule.get_rhs rule;
Strategy_Dot.write_dot_to_file false (path ^ "test2.dot") (lhs); 
*}

(* note that we need to get the input wire type *)
ML{*
val rule = EvalGraph.delete_inputvar_rule Wire.default_wire;
Strategy_Dot.write_dot_to_file false (path ^ "test.dot") (Strategy_Theory.Rule.get_lhs rule);
*}
ML{*
val g = EvalGraph.rewrite rule lhs |> hd;
Strategy_Dot.write_dot_to_file false (path ^ "test.dot") (g);
*}

(* add output nodes *)

ML{*


*}

ML{*
val g = lhs;
val v = GraphEnv.get_rtechns_of_graph lhs |> V.NSet.list_of |> hd;
val vgn = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph g)
                    of NONE => raise RTechnEval.graph_exp ("graph does not contain exactly 1 goalnode",g)
                     | SOME v => v);
val gn = GraphEnv.v_to_gnode g vgn;
val (SOME pnode) = PPlan.lookup_node (RTechnEval.EData.get_pplan edata0) (GNode.get_goal gn) ;
*}

ML{*
     val gnode' = gn
                |> GNode.set_prev (SOME gn)
                |> GNode.set_goal (PNode.get_name pnode)
*}

ML{*
     GraphEnv.Graph.out_enames g v
     |> E.NSet.list_of
*}
ML{*
EvalOutput.upd_by_wire (RTechnEval.EData.get_fmatch edata0) gnode' pnode Wire.default_wire;
*}
ML{*
val [newg] = add_outputs v gn [pnode] edata0 g;
Strategy_Dot.write_dot_to_file false (path ^ "test.dot") (g);
*}

ML{*
 RTechnEval.eval_any edata0 |> Seq.list_of
*}

ML{*
 val imp = "HOL.implies";
 val conj = "HOL.conj";
 val all = "HOL.All";

 fun mk_wire name is_pos feature =
   Wire.default_wire
   |> Wire.set_name (SStrName.mk name)
   |> Wire.set_goal 
      (BWire.default_wire |> (if is_pos then BWire.set_pos (F.NSet.single feature) 
                                         else BWire.set_neg (F.NSet.single feature)));

 val comb_feature = Feature.Strings (StrName.NSet.of_list [imp,conj,all],"top-level-const");
 val imp_feature = Feature.Strings (StrName.NSet.single imp,"top-level-const");
 val conj_feature = Feature.Strings (StrName.NSet.single conj,"top-level-const");
 val all_feature = Feature.Strings (StrName.NSet.single all,"top-level-const"); 

 val comb_wire = mk_wire "neg_comb" false comb_feature;
 val imp_wire = mk_wire "imp" true imp_feature;
 val conj_wire = mk_wire "conj" true conj_feature;
 val all_wire = mk_wire "all" true all_feature;
*}

-- "the reasoning techniques"
ML{*
val split1 = 
 RTechn.id
 |> RTechn.set_name "split1"
 |> RTechn.set_inputs (W.NSet.single Wire.default_wire)
 |> RTechn.set_outputs (W.NSet.of_list [comb_wire,imp_wire,conj_wire,all_wire]);
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


