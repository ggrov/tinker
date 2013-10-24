theory group_strategy
imports
  "../GroupAx"
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/basic/build/BIsaMeth"
begin


-- "path to write graphs to"
ML{*
val path = "/home/colin/Documents/phdwork/groupstrat/"
*}

-- "reasoning techniques"

ML{*
val (induct_tac : Proof.context -> int -> tactic) = 
  fn _ => InductRTechn.induct_tac;
*}

setup {* PSGraphMethod.add_tac ("induct",induct_tac) *}


ML{*
val induct =
RTechn.id
|> RTechn.set_name (RT.mk "induct")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "induct"));

val asm = 
RTechn.id
|> RTechn.set_name (RT.mk "assumption")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

val simp1a = 
RTechn.id
|> RTechn.set_name (RT.mk "rule l1")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["l1"]));

val simp2b =
RTechn.id
|> RTechn.set_name (RT.mk "subst l2")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["l2"]));

val id_revb =
RTechn.id
|> RTechn.set_name (RT.mk "subst id_rev")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["id_rev"]));

val refl = 
RTechn.id
|> RTechn.set_name (RT.mk "rule refl")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["refl"]));
*}
-- "Goal Types"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;

 infixr 6 LOOP_WITH;
 val op LOOP_WITH = PSComb.LOOP_WITH

 val gt_induct = "inductable"
 val gt = SimpleGoalTyp.default;
 val gt_base = "has_symbol(zero)";
 val gt_step = "has_symbol(Suc)";
 val gt_id = "has_symbol(e)";
 val gt_ref = "any";
*}

ML{*
@{term "0 + Suc n"}
*}

-- "PSGraph"

ML{*
val psinduct = PSComb.LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val psbase = PSComb.LIFT ([gt_base],[]) (simp1a);
val psstep = PSComb.LIFT ([gt_step],[gt_id]) (simp2b);
val psid = PSComb.LIFT ([gt_id],[gt]) (id_revb);
val psasm = PSComb.LIFT ([gt],[]) (asm);
val psf = psinduct THENG psbase THENG psstep THENG psid THENG psasm;
val psgraph_idorder =   psf PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}

ML{*
val psf2 = psstep THENG psid THENG psasm;
val psgraph_idorder_step = psf2 PSGraph.empty |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}

(* Setting up strategy with loop, need to use full goal type.

ML{*
val psloop = PSComb.LIFT ([gt_base, gt_step],[gt_base, gt_step, gt_ref]) (simp2b);
val psref = PSComb.LIFT ([gt_ref],[]) (refl);
val psf3 = psinduct THENG psloop LOOP_WITH gt_ref THENG psref;
*}
*)

setup {* PSGraphMethod.add_graph ("idorder",psgraph_idorder) *}
setup {* PSGraphMethod.add_graph ("id_step",psgraph_idorder_step) *}

ML{*
StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory});
*}

ML{*
PSGraph.load_atomics
*}
-- "examples"



lemma gexp_id: "gexp e n = e"         
  apply (induct n)                    
  apply (rule l1)          
  apply (subst gexp.simps(2))                          
  apply (subst id_rev)                   
  apply assumption
  done           

lemma gexp_id_alt: "gexp e n = e"
  apply (psgraph idorder)
done

lemma gexp_id_step: "gexp e n = e"
   apply (induct n)
   apply (rule gexp.simps(1))
   apply (psgraph id_step)
done


lemma gexp_order_Suc: "gexp g n ** g = gexp g (Suc n)"
 apply (induct n)
  apply (subst gexp.simps(2))
  apply (rule refl)
  apply (subst gexp.simps(2))
  apply (subst gexp.simps(2))
  apply (subst gexp.simps(2))
  apply (rule refl)
  done

lemma gexp_order_Suc_alt: "gexp g n ** g = gexp g (Suc n)"
  apply (psgraph  idorder)
oops


ML{*
val edata0 = EVal.init psgraph_idorder @{context} @{prop "gexp e n = e"} |> hd; 
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
PSGraph.PSTheory.write_dot (path ^"graph2.dot") (EData.get_graph edata2)   
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"graph3.dot") (EData.get_graph edata3)   
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot (path ^"graph4.dot") (EData.get_graph edata4)   
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot (path ^"graph5.dot") (EData.get_graph edata5)   
*}
end
