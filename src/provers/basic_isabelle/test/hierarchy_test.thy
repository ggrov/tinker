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
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test3.dot" (EData.get_graph edata2)   
*}

-- "add assumption tactic"
ML{*
val edata2 = EData.update_psgraph (PSGraph.update_atomics (StrName.NTab.ins ("atac",K atac))) edata2
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test4.dot" (EData.get_graph edata3)    
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
  val gt_rippled = "not(ripplling)"
  val gt_not_embeds = "not(hyp_embeds)"
  fun load_tactics tacs ps = 
    fold
     (fn (str, tac) => PSGraph.update_atomics (StrName.NTab.doadd (str, tac)))
     tacs ps;

  val HOL_simps = Simplifier.simpset_of (Proof_Context.init_global @{theory "HOL"});

(* setup simp *)
  val simp_tac = (fn _ => Simplifier.simp_tac HOL_simps);
  val simp = RTechn.id
            |> RTechn.set_name (RT.mk "simp")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));
  val pssimp = PSComb.LIFT ([gt_not_embeds],[]) (simp);

(* setup up fertlisation, maybe we can use asm_lr_simp_tac to implement weak fert *)
  val fert_tac = (fn _ => Simplifier.asm_simp_tac Simplifier.empty_ss) 
  val fert = RTechn.id
            |> RTechn.set_name (RT.mk "fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "fert"));
  val psfert = PSComb.LIFT ([gt_rippled],[]) (fert);

(* setup up induct *)
  val induct_tac = fn _ => InductRTechn.induct_on_first_var_tac;
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
  
  val psf = psinduct THENG psrippling THENG psfert THENG pssimp

  val tacs = [("simp",simp_tac), ("induct", induct_tac), ("fert",fert_tac), ("rippling", ripple_tac)];
  val psgraph = psf PSGraph.empty |> load_tactics tacs;
  val graph = PSGraph.get_graph psgraph;
  PSGraph.PSTheory.write_dot (path ^ "rippling.dot") graph;
*}

lemma rev_cons: "rev (x # xs) = rev xs @ [x]"
by auto

lemma "rev (l1 @ l2) = rev l2 @ rev l1"
apply (induct l1)
apply simp
apply (subst List.append_Cons)
apply (subst rev_cons)
apply (subst rev_cons)

thm List.append_Cons List.rev.simps(2)
oops

(* setup wrules db*)
ML{* 
 val thms = [ ("app_cons", @{thm "List.append_Cons"}), ("rev_cons", @{thm "rev_cons"})];
 BasicRipple.init_wrule_db();
 BasicRipple.add_wrules thms;
*}

(* create a new proof node *)     
ML{*
val edata0 = EVal.init psgraph @{context} @{prop "rev (l1 @ l2) = rev l2 @ rev l1"} |> hd; 
PSGraph.PSTheory.write_dot (path ^"ripple0.dot") (EData.get_graph edata0); 
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"ripple1.dot") (EData.get_graph edata1)   
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
