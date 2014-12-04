(* simple test of proof representation *)
theory eval_test                                           
imports       
  "../build/BIsaP"    
begin


ML{*-
  val path = "/u1/staff/gg112/";
*}
ML{*-
  val path = "/Users/yuhuilin/Desktop/" ;
*}
(* test more complicated comb *)
ML{*
  val asm = RTechn.id
          |> RTechn.set_name (RT.mk "assumption")
          |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));
  
  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));
  
  
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psfg3 = psconjI0 THENG  psconjI THENG psimpI THENG psasm2;
  val psgraph = psfg3 PSGraph.empty;

  PSGraph.PSTheory.write_dot (path ^ "graph.dot") ( PSGraph.get_graph psgraph);
*}

ML{*
val edata0 = EVal.init psgraph @{context} @{prop "A \<Longrightarrow>(A \<and> A)  \<and> (A \<longrightarrow> A)"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "graph0.dot") (EData.get_graph edata0)  
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



