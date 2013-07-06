(* simple test of proof representation *)
theory hierarchy_test                                           
imports       
  "../build/BIsaP"     
begin

ML{*
  val path = "/Users/yuhuilin/Desktop/" (*"/u1/staff/gg112/"*);
*}
(* create a new graph *)
ML{*
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));

   val intro = RTechn.id
            |> RTechn.set_name (RT.mk "rule impI | conjI")
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI","conjI"]));

   val gt = SimpleGoalTyp.default;

  infixr 6 THENG;
  val op THENG = PSComb.THENG;

  val psintro = PSComb.LIFT ([gt],[gt]) (intro);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psfg3 = psintro THENG  psintro;
  val psfg4 = PSComb.NEST "intr_twice" psfg3;
  val psfg5 = psfg4 THENG psasm;
  val psgraph = psfg5 PSGraph.empty;
*}

(* create a new proof node *)     
ML{*
val edata0 = EVal.init psgraph @{context} @{prop "A \<longrightarrow> A \<and> A"} |> hd;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test1.dot" (EData.get_graph edata0)  
*}


ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test2.dot" (EData.get_graph edata1) 
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test3.dot" (EData.get_graph edata2);  
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test4.dot" (EData.get_graph edata3)  
*}

-- "add assumption tactic"
ML{*
val edata3 = EData.update_psgraph (PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac))) edata3
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test5.dot" (EData.get_graph edata4) 
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test6.dot" (EData.get_graph edata5) 
*}

ML{*
val (EVal.Cont edata6) = EVal.evaluate_any edata5;
val edata6 = EVal.normalise_gnode edata6;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test7.dot" (EData.get_graph edata6) 
*}

ML{*
val (EVal.Good edata7) = EVal.evaluate_any edata6;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test7.dot" (EData.get_graph edata7) 
*}

-- "test loop"

ML{*
  val gt1 = "top_symbol(HOL.implies)";
  val gt2 = "not(top_symbol(HOL.implies))";
  val psintro = PSComb.LIFT ([gt1,gt1],[gt1,gt2]) (intro);
  val psf = PSComb.LOOP_WITH psintro gt1;
  val psasm = PSComb.LIFT ([gt2],[]) (asm);
  val psf = psf THENG psasm;
  val psgraph = psf PSGraph.empty;
  val graph = PSGraph.get_graph psgraph;
  PSGraph.PSTheory.write_dot "/Users/yuhuilin/Desktop/graph.dot" graph  
*}

(* create a new proof node *)     
ML{*
val edata0 = EVal.init psgraph @{context} @{prop "A \<longrightarrow> A \<longrightarrow> A"} |> hd; 
PSGraph.PSTheory.write_dot (path^"test1.dot") (EData.get_graph edata0)  
*}

ML{*
EVal.has_terminated edata0;
val vl = EVal.EGraph.Util.all_rtechns (EData.get_graph edata0) ;
val t = hd vl;
EVal.evaluate edata0 (t) |> Seq.list_of;
val t = hd (tl vl);
EVal.evaluate edata0 (t) |> Seq.list_of;
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path^"test2.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path^"test3.dot") (EData.get_graph edata2)   
*}

-- "add assumption tactic"
ML{*
val edata2 = EData.update_psgraph (PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac))) edata2
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path^"test4.dot") (EData.get_graph edata3)    
*}

ML{*
val (EVal.Good edata3) = EVal.evaluate_any edata3;  
*}


-- "test rippling"
ML{*
  val gt = SimpleGoalTyp.default;
  val gt_induct = "inductable";
  val gt_ripple = "rippling";
  val gt_rippled = "rippled"
  val gt_not_embeds = "not(hyp_embeds)"
  val gt_hyps = "hyp_embeds"
  fun load_tactics tacs ps = 
    fold
     (fn (str, tac) => PSGraph.update_atomics (StrName.NTab.doadd (str, tac)))
     tacs ps;

  val HOL_simps = Simplifier.simpset_of (Proof_Context.init_global @{theory "HOL"});
  val simps =  Simplifier.simpset_of (Proof_Context.init_global @{theory});

(* setup simp *)
  val simp_tac = (fn _ => Simplifier.simp_tac simps);
  val simp = RTechn.id
            |> RTechn.set_name (RT.mk "simp")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));
  val pssimp = PSComb.LIFT ([gt_not_embeds],[]) (simp);

(* setup up fertlisation, maybe we can use asm_lr_simp_tac to implement weak fert *)
  val fert_tac = (fn _ => Simplifier.asm_simp_tac HOL_simps) 
  val fert = RTechn.id
            |> RTechn.set_name (RT.mk "fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "fert"));
  val psfert = PSComb.LIFT ([gt_rippled],[]) (fert);

(* setup up induct *)
  val induct_tac = fn _ => InductRTechn.induct_on_first_var_tac(*induct_on_first_var_tac*)(*induct_tac*);
  val induct = RTechn.id
              |> RTechn.set_name (RT.mk "induct")
              |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "induct"));
  val psinduct =  PSComb.LIFT ([gt_induct],[gt_ripple,gt_not_embeds]) (induct);

(* setup up rippling *)
   val ripple_tac = BasicRipple.ripple_tac
   val rippling = RTechn.id
               |> RTechn.set_name (RT.mk "rippling")
               |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "rippling"));

  val psrippling' =  PSComb.LIFT ([gt_ripple, gt_ripple],[gt_rippled,gt_ripple]) (rippling);
  val psrippling = PSComb.LOOP_WITH psrippling' gt_ripple;
  val psrippling0 =  PSComb.LIFT ([gt_ripple],[gt_ripple]) (rippling);
  val psrippling1 =  PSComb.LIFT ([gt_ripple],[gt]) (rippling);

(* setup dummy, do nothing, just return the same goal, for debug uses *)
  fun dummy_tac _ _ thm  = Seq.single(thm) 
  val dummy = RTechn.id 
            |> RTechn.set_name (RT.mk "dummy")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "dummy"));
  val psdummy' = PSComb.LIFT ([gt_ripple, gt_ripple], [gt_ripple, gt_rippled]) (dummy);
  val psdummy = PSComb.LOOP_WITH psdummy' gt_ripple;
  val psf = psinduct THENG psrippling THENG psfert THENG pssimp

  val psf0 = (* psinduct THENG pssimp THENG*) psrippling0 THENG psrippling0 THENG psrippling1 THENG psfert
  val psf0 = psrippling THENG psfert
  val psf0 = psdummy THENG psdummy

  val tacs = [("simp",simp_tac), ("induct", induct_tac), ("fert",fert_tac), ("rippling", ripple_tac), ("dummy", dummy_tac)];
  val psgraph = psf PSGraph.empty |> load_tactics tacs;
  val graph = PSGraph.get_graph psgraph;
  PSGraph.PSTheory.write_dot (path ^ "rippling.dot") graph; 
*}

lemma rev_cons: "rev (x # xs) = rev xs @ [x]"
by auto

lemma buggy: "a @ b = b @ a"
oops

lemmas demosThms =  List.append_Cons List.rev.simps(2) List.append_assoc
thm demosThms
thm  List.append_assoc[symmetric]

lemma "rev (l1 @ l2) = rev l2 @ rev l1"
apply (induct l1)
apply simp
apply (simp (no_asm) only: List.append_Cons List.rev.simps(2) List.append_assoc)
oops

(* setup wrules db*)
ML{* 
 

 val thms = [("app_cons", @{thm "List.append_Cons"}), 
             ("rev_cons", @{thm "rev_cons"}), 
             ("List.append_assoc", @{thm "List.append_assoc"}),
             ("app_cons(sym)", Substset.mk_sym_thm @{thm "List.append_Cons"}), 
             ("rev_cons(sym)", Substset.mk_sym_thm @{thm "rev_cons"}), 
             ("List.append_assoc(sym)", Substset.mk_sym_thm @{thm "List.append_assoc"})
             ];
 BasicRipple.init_wrule_db();
 BasicRipple.add_wrules thms;
*}

(* create a new proof node *)     
ML{*   
val g = @{prop "rev (l1 @ l2) = rev l2 @ rev l1"};
val g0 = @{prop " rev (l1 @ l2) = rev l2 @ rev l1 \<Longrightarrow> rev ((a # l1) @ l2) = rev l2 @ rev (a # l1)"};
val g0 = @{prop "\<And>a l1. rev (l1 @ l2) = rev l2 @ rev l1 \<Longrightarrow> rev ((a # l1) @ l2) = rev l2 @ rev (a # l1)"};
val edata0 = EVal.init psgraph @{context} g |> hd; 
PSGraph.PSTheory.write_dot (path ^"ripple0.dot") (EData.get_graph edata0); 
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"ripple1.dot") (EData.get_graph edata1)   

*}


ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"ripple2.dot") (EData.get_graph edata2)   
*}


ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"ripple3.dot") (EData.get_graph edata3)   
*}


ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot (path ^"ripple4.dot") (EData.get_graph edata4)   
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot (path ^"ripple5.dot") (EData.get_graph edata5);
*}


ML{*
val (EVal.Cont edata6) = EVal.evaluate_any edata5;
val edata6 = EVal.normalise_gnode edata6;
PSGraph.PSTheory.write_dot (path ^"ripple6.dot") (EData.get_graph edata6);
*}

ML{*
val (EVal.Cont edata7) = EVal.evaluate_any edata6;
val edata7 = EVal.normalise_gnode edata7;
PSGraph.PSTheory.write_dot (path ^"ripple7.dot") (EData.get_graph edata7);
*}


ML{*
val (EVal.Good edata7) = EVal.evaluate_any edata7;
*}
-- "proof complete !"

lemma
--
ML{* 
edata0; 
EVal.has_terminated edata0; 
val vl = EVal.EGraph.Util.all_rtechns (EData.get_graph edata0);
val ve  = hd (vl); 
val vd = hd (tl vl);
val va = hd (tl (tl vl)); 
tracing "rock";
val rt = EVal.EGraph.Util.lookup_rtechn (EData.get_graph edata0) va |>( fn (SOME x) => x);
val lhs_seq = EVal.EGraph.matched_lhs (EData.get_graph edata0) va |> Seq.hd ; (* should be [] for those havn;t got goals to update *)
val lhs = snd lhs_seq;
      val out_edges = 
        EVal.GComb.boundary_outputs (snd lhs_seq) 
        |> map (fn (_,(x,_),_) => x);
      val out_types =  map (EVal.EGraph.Util.gtyp_of  (snd lhs_seq) ) out_edges;
      val [gnode_name] = EVal.EGraph.Util.all_gnodes lhs;
      val gnode =  EVal.EGraph.Util.single_gnode_of lhs gnode_name;

val result_seq = EVal.EAtom.apply_atomic edata0 gnode rt out_types |> Seq.hd;

(*val rhs_seq = ((EVal.mk_atomic_rhs edata0 rt) o snd) lhs_seq ;*)

(*val atomiv_avl = EVal.eval_atomic edata0 va rt |> Seq.pull; *)
tracing "here";

*}
ML{**}
--
ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"ripple2.dot") (EData.get_graph edata1)   
*}

ML{*
Thm.cterm_of;
fun myprint x = Syntax.pretty_term @{context} x |> Pretty.writeln;
@{term "(rev (l1 @ l2) = rev l2 @ rev l1) \<Longrightarrow> rev ((a # l1) @ l2) = rev l2 @ rev (a # l1) "};
@{term "\<And>a l1 l2. (\<And>l2. rev (l1 @ l2) = rev l2 @ rev l1) \<Longrightarrow> rev ((a # l1) @ l2) = rev l2 @ rev (a # l1) "}
|> myprint
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test3.dot" (EData.get_graph edata2)   
*}


(* debug stuff *)
ML{*
open BIsaAtomic_DB;
val pp = EData.get_pplan edata1;
val [a] = #opengs pp;
*}

ML{*
val x = #ptrm a;
*}

-- "Proof COMPLETED!!!"


ML{*
val (pn,pp) = BIsaAtomic_DB.init @{context} @{prop "A \<longrightarrow> A \<longrightarrow> A"};
*}
ML{*
SimpleGoalTyp.init_lift gt2 pn;
TermFeatures.top_level_str (#ptrm pn)
*}

ML{*
structure Graph = EVal.EGraph.Graph;
val rhs = EData.get_graph edata3;
val (SOME lhs) = EData.parent_lhs edata3;
val rhs' = EVal.EGraph.normalise_combine_gnodes rhs;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/testrhs.dot" rhs'
*}

ML{*
structure Rule = EVal.Theory.Rule;
val rule = EVal.EGraph.split_gnode_pairs;
val g = Rule.get_rhs rule;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test.dot" g 
*}

ML{*
Graph.get_boundary lhs |> V.NSet.list_of;
Graph.get_boundary rhs |> V.NSet.list_of;
*}
end
