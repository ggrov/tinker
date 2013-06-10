(* simple test of proof representation *)
theory eval_test                                           
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

   val frule = RTechn.id
            |> RTechn.set_name (RT.mk "frule conjuncts")
            |> RTechn.set_atomic_appf (RTechn.FRule (C.mk "conj",StrName.NSet.of_list ["conjunct1","conjunct2"]));

   val gt = SimpleGoalTyp.default;

  infixr 6 THENG;
  val op THENG = PSComb.THENG;

  val psintro = PSComb.LIFT ([gt],[gt]) (intro);
  val psfrule = PSComb.LIFT ([gt],[gt]) (frule);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psfg3 = psintro THENG psfrule THENG psasm;
  val psgraph = psfg3 PSGraph.empty;
*}

(* create a new proof node *)     
ML{*
val edata0 = EVal.init psgraph @{context} @{prop "A \<and> B \<longrightarrow> B \<and> A"} |> hd;
*}

(* show graph *)
ML{*
PSGraph.PSTheory.write_dot "/u1/staff/gg112/test.dot" (EData.get_graph edata0)
*}


(* maybe have a debug mode? could spit out a lot of details *)
ML{*
EVal.EGraph.Util.all_rtechns (EData.get_graph edata0)
*}

(* *)
ML{*
EVal.evaluate_any edata0 |> Seq.list_of;
*}


       
end



