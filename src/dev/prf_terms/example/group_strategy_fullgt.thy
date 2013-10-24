theory group_strategy_fullgt
imports
  "../GroupAx"
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
begin

ML{*
structure FGT = FullGoalTyp;
structure GTD = GoalTypData;

*}


-- "path to write graphs to"
ML{*
val path = "/home/colin/Documents/phdwork/groupstrat/"
*}

-- "Goal Types"
ML{*

  val gt = FGT.default
          

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "zero"]] Class.top
                |> Class.rename (C.mk "goal_base");
  val gt_base = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "base");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "Suc"]] Class.top
                |> Class.rename (C.mk "goal_step");
  val gt_step = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "step");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "e"]] Class.top
                |> Class.rename (C.mk "goal_id");
  val gt_id = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "id");

  val goalclass = Class.add_item (SStrName.mk "inductable")[[GTD.Term @{term n}]] Class.top
                |> Class.rename (C.mk "goal_induct");
  val gt_induct = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "inductable");

*}
ML{*
IsaFeatures.has_symbols'
*}

-- "reasoning techniques"

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


-- "PSGraph"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
*}

ML{*
val psinduct = PSComb.LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val psbase = PSComb.LIFT ([gt_base],[]) (simp1a);
val psstep = PSComb.LIFT ([gt_step],[gt_id]) (simp2b);
val psid = PSComb.LIFT ([gt_id],[gt]) (id_revb);
val psasm = PSComb.LIFT ([gt],[]) (asm);
val psf = psinduct THENG psbase THENG psstep THENG psid THENG psasm;
(*val psgraph_idorder =   psf PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (IsaMethod.get_tacs @{theory}));*)
*}

ML{*
val psg_idorder = IsaMethod.init_psgraph psf @{context};
val psgraph_idorder = IsaMethod.apply_psgraph_tac psg_idorder;
*}


ML{*
val psf = psstep THENG psid THENG psasm;
val psg_step = IsaMethod.init_psgraph psf @{context};
val psgraph_idstep = IsaMethod.apply_psgraph_tac psg_step;
*}

-- "Examples"

lemma "gexp e n = e"
  apply (induct n)
  apply (rule l1)
  apply (tactic "psgraph_idstep @{context}")
oops

lemma "gexp e n = e"
  apply (tactic "psgraph_idorder @{context}")
oops

ML{*
val edata0 = EVal.init psg_step @{context} @{prop "gexp e n = e \<Longrightarrow> gexp e (Suc n) = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "partgraph0.dot") (EData.get_graph edata0)  
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"partgraph1.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"partgraph2.dot") (EData.get_graph edata2)   
*}



ML{*
val edata0 = EVal.init psg_idorder @{context} @{prop "gexp e n = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "fullgraph0.dot") (EData.get_graph edata0)  
*}


end
