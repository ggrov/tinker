(* simple test of proof representation *)
theory hierarchy_test                                           
imports       
  "../build/BIsaP"     
begin

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
  PSGraph.PSTheory.write_dot "/u1/staff/gg112/test.dot" graph  
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
