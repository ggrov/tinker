(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin
ML{*-
  val path = "/u1/staff/gg112/";
*}
ML{*
  val path = "/Users/yuhuilin/Desktop/" ;
*}
ML{*
val vnode =  Data.T_Atomic {name = "hello9", args = [[]]};
val vnode1 =  Data.T_Atomic {name = "hello1", args = [[]]};
val vnode2 =  Data.T_Atomic {name = "hello2", args = [[]]};
val ins = [Data.GT "a", Data.GT "b", Data.GT "c"]
val outs = [Data.GT "d", Data.GT "e"]
val ins1 = [Data.GT "a", Data.GT "b"]
val ins2 = [Data.GT "c", Data.GT "d"]
val outs1 = [Data.GT "c", Data.GT "d"]
val outs2 = [Data.GT "e", Data.GT "c"]
*}

ML{*
val g = PSComb.graph_of_node_edges vnode ins outs;
PSComb.boundary_inputs g;
PSComb.boundary_outputs g; 
PSComb.graph_tensor g g |> snd |> Theory_IO.write_dot (path^"test2.dot");

val g1 = PSComb.graph_of_node_edges vnode ins1 outs1;
val g2 = PSComb.graph_of_node_edges vnode ins2 outs2;
PSComb.graph_then g1 g2 |> snd |> Theory_IO.write_dot (path^"test_then1.dot");
PSComb.LOOP_WITHG g2 (Data.GT "c") |> Theory_IO.write_dot (path^"test_loop_with.dot");

val ps1 = PSComb.LIFT (ins1, outs1) vnode1;
val ps2 = PSComb.LIFT (ins2, outs2) vnode2;
PSComb.THEN (ps1, ps1) |> PSGraph.get_graph |> Theory_IO.write_dot (path^"test_psthen.dot");;
*}


(* todo: fail to apply atac, error BIND *)

(* test more complicated comb *)
ML{*
  fun at_impI_tac ctxt i args = rtac @{thm impI} i;
  fun at_conjI_tac ctxt i args = rtac @{thm conjI} i;
  fun at_atac ctxt i args = atac i;
  fun at_all_tac  ctxt i args = all_tac

*}
ML{*
  val asm =  Data.T_Atomic {name = "atac", args = [[]]}; 
  val allT =  Data.T_Atomic {name = "all_tac", args = [[]]}; 
  val impI =  Data.T_Atomic {name = "impI", args = [[]]}; 
  val conjI =  Data.T_Atomic {name = "conjI", args = [[]]}; 

  fun load_atom ps =  PSGraph.load_atomics 
    [("all_tac", at_all_tac), ("atac", at_atac), ("impI", at_impI_tac), ("conjI", at_conjI_tac)] 
    ps;

  val gt = Data.GT SimpleGoalTyp.default;
  val gt_imp =  Data.GT "top_symbol(HOL.implies)";
  val gt_conj = Data.GT "top_symbol(HOL.conj)";
  
  infixr 6 THENG; 
  val op THEN = PSComb.THEN;

  
  val psasm =  PSComb.LIFT ([gt],[gt]) (asm);
  val psall =  PSComb.LIFT ([gt],[gt]) (allT);
  val psimpI = PSComb.LIFT ([gt_imp, gt_imp],[gt_imp, gt]) (impI);
  val psconjI =  PSComb.LIFT ([gt_conj],[gt_imp]) (conjI);

  val ps = psconjI THEN ((PSComb.LOOP_WITH gt_imp psimpI) THEN psasm)
    |> load_atom;

 Theory_IO.write_dot (path ^ "graph.dot") ( PSGraph.get_graph ps);
*}

ML{*
val edata0 = EVal.init ps @{context} @{prop "(B \<longrightarrow> B)  \<and> (B\<longrightarrow> A \<longrightarrow> A)"} |> hd; 

Theory_IO.write_dot (path ^ "graph0.dot")
*}

ML{*
val (IEVal.Cont edata1) = IEVal.eval_any edata0;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph1.dot") (EData.get_graph edata1) ; 
*}

ML{*
val (IEVal.Cont edata2) = IEVal.eval_any edata1;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph2.dot") (EData.get_graph edata2) ; 
*}
ML{*
val (IEVal.Cont edata3) = IEVal.eval_any edata2;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph3.dot") (EData.get_graph edata3) ; 
*}
ML{*
val (IEVal.Cont edata4) = IEVal.eval_any edata3;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph4.dot") (EData.get_graph edata4) ; 
*}
ML{*
val (IEVal.Cont edata5) = IEVal.eval_any edata4;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph5.dot") (EData.get_graph edata5) ; 
*}
ML{*
val (IEVal.Cont edata6) = IEVal.eval_any edata5;
(* val edata1 = EVal.normalise_gnode edata1; *)
Theory_IO.write_dot (path ^"graph6.dot") (EData.get_graph edata6) ; 
*}
ML{*
IEVal.eval_any edata6;
*}



ML{*
val edata0 = edata1;
*}

ML{*
    val graph = (EData.get_graph edata0) ;
    fun update_branches edata branches = 
      let val new_branches = branches @ (EData.get_branches edata) in
        case new_branches of 
          [] => IEVal.Bad (* should never happen *)
          | (x::xs) => (* fixme: this should be based on the search strategy *)
               IEVal.Cont (edata 
                    |> EData.set_current x 
                    |> EData.set_branches xs)  end
*}
ML{*
val gnode =  EVal.Util.all_gnodes graph |> tl |> hd;
fun proc gnode = EVal.Util.gnode_of graph gnode |> EVal.Theory.GoalTyp.goal_name 
  |> (fn g => EVal.eval_goal_atomic true g edata0
                       |> Seq.list_of
                       |> map fst);
proc gnode;
val ret = 

     EVal.Util.all_gnodes graph
       |> map (EVal.Util.gnode_of graph)
       |> map (EVal.Theory.GoalTyp.goal_name)
       |> map (fn g => EVal.eval_goal_atomic true g edata0
                       |> Seq.list_of
                       |> map fst)
       |> List.concat
       |> update_branches edata0


*}


ML{*
  fun eval_any edata = 
   let 
    val graph = (EData.get_graph edata) 
    fun update_branches edata branches = 
      let val new_branches = branches @ (EData.get_branches edata) in
        case new_branches of 
          [] => IEVal.Bad (* should never happen *)
          | (x::xs) => (* fixme: this should be based on the search strategy *)
               IEVal.Cont (edata 
                    |> EData.set_current x 
                    |> EData.set_branches xs)
      end
   in
    if EVal.has_terminated edata then
     (case EData.parent_lhs edata of
       NONE =>  IEVal.Good edata
       | _ =>  IEVal.Good edata) (* fixme: this should be hie one *)
    else
   (* todo: hierichecal one *)
     EVal.Util.all_gnodes graph
       |> map (EVal.Util.gnode_of graph)
       |> map (EVal.Theory.GoalTyp.goal_name)
       |> map (fn g => EVal.eval_goal_atomic true g edata
                       |> Seq.list_of
                       |> map fst)
       |> List.concat
       |> update_branches edata
  end;

*}

ML{*
 val graph = (EData.get_graph edata0); 
val g = EVal.Util.all_gnodes graph |> hd  |> EVal.Util.gnode_of graph;
val gname = g;
val gnode = EVal.Util.all_gnodes graph
             |> filter (fn gn => gname =  EData.PSGraph.Theory.Data.GoalTyp.goal_name (EVal.Util.gnode_of graph gn))
             |> (fn [x] => x) (* raise exception: log if not singleton list *)
val goal = EVal.Util.gnode_of graph gnode;

 val tnode = EVal.get_next_tnode graph gnode
          

(*EVal.eval_goal_atomic true g edata0;*)
*}

ML{*
val g = EVal.Util.all_gnodes graph |> hd |> EVal.Util.gnode_of graph;
val gname = g;
val graph = EData.get_graph edata0
val gnode = EVal.Util.all_gnodes graph
         |> filter (fn gn => gname = EVal.GoalTyp.goal_name (EVal.Util.gnode_of graph gn))
         |> (fn [x] => x) (* raise exception: log if not singleton list *)
val goal = EVal.Util.gnode_of graph gnode
val tnode = EVal.get_next_tnode graph gnode

*}


ML{*
 val graph = EData.get_graph edata0
     val goal = EVal.Util.gnode_of graph gnode
     val (SOME tactic) = EVal.Util.lookup_ivertex_data graph tnode
     val out_edges = EVal.Util.out_edges graph tnode
     val out_goaltypes = map (EVal.Util.goaltype_of graph) out_edges
     (* (EData.branch * EData.PSGraph.Theory.Data.GoalTyp.gnode list list list) Seq.seq *)
     val result = EVal.apply_atomic edata0 goal tactic out_goaltypes
     val graph' = EVal.Util.del_gnode gnode graph ;

*}

ML{*
 fun del_gnode gnode g = Theory.Graph.update_vertex_data (K Theory.Graph.WVert) gnode g 
      |> Theory.Graph.minimise;

Theory_IO.write_dot (path ^ "dgraph.dot")  graph'
*}
ML{*
EVal.eval_goal_atomic true gname edata0 |> Seq.pull |> Option.valOf |> #1 |> #1
|> EData.get_bgraph
|>Theory_IO.write_dot (path ^ "fgraph.dot") ; 
*}

ML{*
result |> Seq.pull |> Option.valOf |> #1 |> #2
*}

ML{*
     fun add_gnode n e g =
        let 
          val (from,_,g') = EVal.Util.insert_node_on_edge n e g 
        in
          (from,g')
       end
    fun add_f gn (e,gr) = add_gnode (Theory.Data.G gn) e gr;
    fun add_gnodes (edge::edges) (res::ress) graph = 
       fold (fn gn => fn (e,gr) => add_gnode (Theory.Data.G gn) e gr) res (edge,graph)
       |> #2
       |> add_gnodes edges ress
    | add_gnodes [] _ graph = graph
    | add_gnodes _ [] graph = graph
*}

ML{*

 Seq.maps (fn (b,rs) 
        => (map (fn res => (EData.set_bgraph (add_gnodes out_edges res graph') b,rs)) rs) 
            |> Seq.of_list) result 
*}

ML{*
val testg = Seq.pull result |> Option.valOf |> #1 |> #1 |> EData.get_bgraph;
Theory_IO.write_dot (path ^ "graphx.dot") testg; 
*}

ML{*
eval_any edata0;
(* val edata1 = EVal.normalise_gnode edata1; *)
PSGraph.PSTheory.write_dot (path ^"graph1.dot") (EData.get_graph edata1)   
*}

ML{* - 
(* do we need to normalise ? *) 
val del_empty_gnode = 
  let
    val edge = Data.GT_Var "e";
    (*val node = Data.G (GData.GN_Empty);*) (*do we still neeed this ? *)
    val (inp,g0) = Theory.Graph.add_vertex Theory.Graph.WVert Theory.Graph.empty;
    val (outp,g0) = Theory.Graph.add_vertex Theory.Graph.WVert g0;
    val (bn,left) = Graph.add_vertex (Graph.OVData.NVert node) g0; 
    val left = left |> Graph.doadd_edge (Graph.Directed,edge) inp bn
                    |> Graph.doadd_edge (Graph.Directed,edge) bn outp;
    val right = Graph.doadd_edge (Graph.Directed,edge) inp outp g0
  in
     Theory.Rule.mk (left,right)
  end;
 val gnode_rs = Theory.Ruleset.empty
            |> Theory.Ruleset.add_fresh_rule (R.mk "del_empty",del_empty_gnode)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)
            |> Theory.Ruleset.add_fresh_rule (R.mk "split_pair",split_gnode_pairs)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)

 val gnode_one_step  = Theory.RulesetRewriter.apply gnode_rs
                     #> Seq.map snd;

 fun normalise_gnode g = 
   case Seq.pull (gnode_one_step g) of
      NONE => g
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"graph1.dot") (EData.get_graph edata1)   
*}

ML{*
local open EVal in


    
  fun evaluate edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) then eval_atomic edata v rt 
       else if (RTechn.is_merge rt) then raise evaluate_exp (SOME v, "merge not supported")
       else if (RTechn.is_identity rt) then raise evaluate_exp (SOME v, "identity not supported")
       else if (RTechn.is_hgraph rt) then eval_nested edata v
       else if (RTechn.is_or rt) then eval_or edata v
       else if (RTechn.is_orelse rt) then raise evaluate_exp (SOME v, "orelse not supported")
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     ;
   fun evaluate_any edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> Seq.of_list
     |> Seq.maps (evaluate edata)
     |> update_branches edata

end

*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"graph1.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"graph2.dot")  (EData.get_graph edata2)   
*}

ML{*
val edata2 = EData.update_psgraph (PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac))) edata2;
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"graph3.dot")  (EData.get_graph edata3)   
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot  (path ^"graph4.dot")  (EData.get_graph edata4)   
*}

ML{*
EVal.evaluate_any edata4; 
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot  (path ^"graph5.dot")  (EData.get_graph edata5);  
val (EVal.Cont edata6) = EVal.evaluate_any edata5;
val edata6 = EVal.normalise_gnode edata6;
PSGraph.PSTheory.write_dot  (path ^"graph6.dot")  (EData.get_graph edata6) ;
val (EVal.Good edata7) = EVal.evaluate_any edata6;
PSGraph.PSTheory.write_dot  (path ^"graph7.dot")  (EData.get_graph edata7)   
(* proof completed *)
*}

(* create a new graph *)
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

   val gt = SimpleGoalTyp.default;

  infixr 6 THENG;
  val op THENG = PSComb.THENG;

  val psintro = PSComb.LIFT ([gt],[gt]) (intro);
  val psfrule = PSComb.LIFT ([gt],[gt]) (frule);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psfg3 = psintro THENG  psintro THENG psfrule THENG psasm;
  val psgraph = psfg3 PSGraph.empty;
*}

(* create a new proof node *)     
ML{*
val edata0 = EVal.init psgraph @{context} @{prop "A \<and> B \<longrightarrow> B \<and> A"} |> hd;
*}

ML{*
val pp = EData.get_pplan edata0;
val gn = EData.get_goals edata0 |> StrName.NTab.values |> hd;
*}
ML{*
BIsaAtomic.apply_rule "test" @{thm "impI"} (gn,pp) |> Seq.list_of;
open BIsaAtomic_DB;
*}

(* show graph *)
ML{*
PSGraph.PSTheory.write_dot (path ^ "test.dot") (EData.get_graph edata0)
*}


(* maybe have a debug mode? could spit out a lot of details *)
ML{*
EVal.EGraph.Util.all_rtechns (EData.get_graph edata0)
*}


ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^ "test2.dot") (EData.get_graph edata1) 
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot  (path ^ "test3.dot") (EData.get_graph edata2); 
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot  (path ^ "test4.dot") (EData.get_graph edata3) 
*}

-- "add assumption tactic"
ML{*
val edata3 = EData.update_psgraph (PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac))) edata3
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot (path ^ "test5.dot") (EData.get_graph edata4) 
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot  (path ^ "test6.dot") (EData.get_graph edata5) 
*}

ML{*
val (EVal.Cont edata6) = EVal.evaluate_any edata5;
val edata6 = EVal.normalise_gnode edata6;
PSGraph.PSTheory.write_dot  (path ^ "test7.dot") (EData.get_graph edata6) 
*}

ML{*
val (EVal.Good edata7) = EVal.evaluate_any edata6;
PSGraph.PSTheory.write_dot  (path ^ "test8.dot") (EData.get_graph edata7) 
*}

-- "Proof COMPLETED!!!"

section "Random debug code"


ML{*
val g = EData.get_graph edata5;
val [a,b,c,d] = EVal.EGraph.Util.all_rtechns g;
*}
ML{*
EVal.EGraph.Graph.get_vertex_data g d;
val subst = EVal.EGraph.matched_lhs g d |> Seq.list_of |> hd |> fst;
structure D = EVal.EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData;
val SOME (D.GN_Node c) = D.lookup_gsubst subst "g";
val at = RTechn.Tactic (RTechn.TAllAsm, "atac")
val edata = edata5;
*}

ML{*
open EVal;
*}

ML{*
 val rt = asm;
 val v = d;
  val graph = EData.get_graph edata
  val lhs_seq = EGraph.matched_lhs (EData.get_graph edata) v
  fun update (edata,(lhs,rhs)) =
       Seq.map (fn g => EData.set_graph g edata)
               (EGraph.Util.rewrite_lazy (Theory.Rule.mk (lhs,rhs)) graph);

 val (_,x)=   lhs_seq |> Seq.list_of |> hd;
  val y = Seq.maps ((mk_atomic_rhs edata rt) o snd) lhs_seq |> Seq.list_of;
 val t = Seq.maps update;
 val lhs = x;  
*}

ML{*
    val out_edges = 
        GComb.boundary_outputs lhs 
        |> map (fn (_,(x,_),_) => x)
      val out_types = map (EGraph.Util.gtyp_of lhs) out_edges;
      val [gnode_name] = EGraph.Util.all_gnodes lhs;
      val gnode = EGraph.Util.single_gnode_of lhs gnode_name
      val result_seq = EAtom.apply_atomic edata gnode rt out_types
      val result = Seq.list_of result_seq;
      fun apply_one ((edata':EData.T),part) = 
           lhs |> EGraph.Util.del_gnode gnode_name
               |> EGraph.add_outs out_edges part 
               |> (fn rhs => (edata',(lhs,rhs)));

      fun apply_all ((edata':EData.T),[]) = (* no subgoals *)
          lhs |> EGraph.Util.del_gnode gnode_name
              |> (fn rhs => (edata',(lhs,rhs)))
              |> Seq.single      
        | apply_all (edata',parts) =
              parts
              |> map EAtom.partition_to_gnodes
              |> Seq.of_list
              |> Seq.map (fn p => apply_one (edata',p));
 
   apply_all result |> Seq.list_of;
*}

ML{*
EGraph.add_outs [] [];
apply_one;
val (e,p) = result;
map EAtom.partition_to_gnodes
*}

ML{*
 mk_atomic_rhs edata rt x |> Seq.list_of
*}

ML{*
EVal.EAtom.apply_atomic edata c asm [] |> Seq.list_of |> hd;
(* EVal.EAtom.apply_appf edata c at |> Seq.list_of |> hd; *)
*}

ML{*
val edata4 = EVal.evaluate_any edata4 |> Seq.list_of |> hd |> EVal.normalise_gnode;; 
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test5.dot" (EData.get_graph edata4) 
*}


ML{*
val edata = EVal.evaluate_any edata3 |> Seq.list_of |> hd |> EVal.normalise_gnode;; 
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test5.dot" (EData.get_graph edata4) 
*}
       

(* various code used for debugging *)

ML{*
val g = EData.get_graph edata2;

*}

ML{*
val [a,b,c,d] = EVal.EGraph.Util.all_rtechns g;
EVal.EGraph.Graph.get_vertex_data g c;
val subst = EVal.EGraph.matched_lhs g c |> Seq.list_of |> hd |> fst;
structure D = EVal.EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData;
val SOME (D.GN_Node c) = D.lookup_gsubst subst "g";
val at = RTechn.FRule (SStrName.mk "conj", StrName.NSet.of_list ["conjunct1","conjunct2"]);
val edata = edata2;
*}

ML{*
  structure Atomic = BIsaAtomic_DB;
  exception no_such_fact of string

  fun lookup_fact node name = 
   case Atomic.lookup_fact node name of
      NONE => raise no_such_fact name
    | SOME f => (name,f)

  fun try_lookup_fact node name = 
   case Atomic.lookup_fact node name of
      NONE => []
    | SOME f => [(name,f)]

  fun fact_list (node:Atomic.pnode) fact_nms =
      fact_nms 
      |> StrName.NSet.list_of 
      |> map (lookup_fact node)

  val fact_seq = Seq.of_list oo fact_list;
*}

ML{*
  structure GoalTyp = SimpleGoalTyp;
  val gnode = c;
  val class_nm = SStrName.mk "conj";
  val fact_nms =  StrName.NSet.of_list ["conjunct1","conjunct2"]
  val pnode = EData.get_goal edata (GoalTyp.goal_name gnode);
  val pplan = EData.get_pplan edata
*}

ML{*
  val hyps = GoalTyp.get_fact_names class_nm gnode |> fact_seq pnode;
  val facts = fact_seq pnode fact_nms;

          (* one application of a frule of a fact to a hyp *)
          fun apply_frule' hyp fact = Atomic.apply_frule  hyp fact (pnode,pplan)
          (* application of all facts to a hyp *)
          fun apply_frule hyp = Seq.maps (apply_frule' hyp) facts;
Seq.maps apply_frule hyps |> Seq.list_of |> length; 
*}
(* problem seems to be evaluation *)
ML{*
EVal.EAtom.apply_appf edata2 c at |> Seq.list_of |> length;
*}

end



