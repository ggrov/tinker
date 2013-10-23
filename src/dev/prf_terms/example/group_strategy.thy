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
|> RTechn.set_name (RT.mk "rule gexp.simps(1)")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["gexp.simps(1)"]));

val simp2b =
RTechn.id
|> RTechn.set_name (RT.mk "subst gexp.simps(2)")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["gexp.simps(2)"]));

val id_revb =
RTechn.id
|> RTechn.set_name (RT.mk "subst id_rev")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["id_rev"]));
*}


-- "Goal Types"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;

 val gt_induct = "inductable"
 val gt = SimpleGoalTyp.default;
 val gt_base = "has_symbol(0)";
 val gt_step = "has_symbol(Suc n)";
 val gt_id = "has_symbol(e)";
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

setup {* PSGraphMethod.add_graph ("idorder",psgraph_idorder) *}
setup {* PSGraphMethod.add_graph ("id_step",psgraph_idorder_step) *}

ML{*
StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory});
*}

ML{*
PSGraph.load_atomics
*}
-- "examples"

fun
  gexp :: "G => nat => G"
where
  "gexp g 0 = e"
| "gexp g (Suc n) = (gexp g n) ** g" 

lemma gexp_id: "gexp e n = e"         
  apply (induct n)                    
  apply (rule gexp.simps(1))          
  apply (subst gexp.simps(2))                          
  apply (subst id_rev)                   
  apply assumption
  done           

lemma gexp_id_alt: "gexp e n = e"
  apply (psgraph idorder)
oops

lemma gexp_id_step: "gexp e n = e"
   apply (induct n)
   apply (rule gexp.simps(1))
   apply (psgraph id_step)
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



end
