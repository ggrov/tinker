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

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "inv"]] Class.top
                |> Class.rename (C.mk "goal_inv");
  val gt_inv = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "inv");

  val gt_induct = FGT.default

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "="]] Class.top
                |> Class.rename (C.mk "goal_refl");
  val gt_ref = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "refl");

(*  val goalclass = Class.add_item (SStrName.mk "inductable")[[GTD.Term @{term n}]] Class.top
                |> Class.rename (C.mk "goal_induct");
  val gt_induct = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "inductable");
*)
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

val ax3sb =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax3s")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax3s"]));

val ax2sb =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax2s")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax2s"]));

val inv_revb =
RTechn.id
|> RTechn.set_name (RT.mk "subst inv_rev")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["inv_rev"]));

val ax1b =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax1")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax1"]));

val refla =
RTechn.id
|> RTechn.set_name (RT.mk "rule refl")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["refl"]));

val back =
RTechn.id
|> RTechn.set_name (RT.mk "back")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "back"));
*}


-- "PSGraph"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val NEST = PSComb.NEST;
 val LOOP = PSComb.LOOP_WITH;
 val LIFT = PSComb.LIFT;
 val OR = PSComb.OR;
*}

(* id_rev sub-strategy *)

ML{*
val psax3s = PSComb.LIFT ([gt_id],[gt_inv]) (ax3sb)
val psback = LIFT ([gt_inv],[gt_inv])(back)
val psax3s_alt = psax3s THENG psback
val psax2s = PSComb.LIFT ([gt_inv],[gt_inv]) (ax2sb)
val psinv = PSComb.LIFT ([gt_inv], [gt_id]) (inv_revb)
val psax1 = PSComb.LIFT ([gt_id], [gt]) (ax1b)
val psf_idrev = psax3s_alt THENG psax2s THENG psinv THENG psax1;
val psg_idrev = IsaMethod.init_psgraph psf_idrev @{context};
val psgraph_idrev = IsaMethod.apply_psgraph_tac psg_idrev;
*}

ML{*
val id_rev_h = NEST "ind" psf_idrev;
*}

ML{*
val psinduct = PSComb.LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val psbase = PSComb.LIFT ([gt_base],[]) (simp1a);
val psstep = PSComb.LIFT ([gt_step],[gt_id]) (simp2b);
val psid = PSComb.LIFT ([gt_id],[gt]) (id_revb);
val psasm = PSComb.LIFT ([gt],[]) (asm);
val psf = psinduct THENG psbase THENG psstep THENG psid (*THENG psasm*);
(*val psgraph_idorder =   psf PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (IsaMethod.get_tacs @{theory}));*)

val psf_hier = psinduct THENG psbase THENG psstep THENG id_rev_h(* THENG psasm*);

*}

ML{*
val psf_asm = PSComb.LIFT ([gt],[]) (asm);
val psg_asm = IsaMethod.init_psgraph psf_asm @{context};
val psgraph_asm = IsaMethod.apply_psgraph_tac psg_asm;
*}

ML{*
val psg_idorder = IsaMethod.init_psgraph psf @{context};
val psgraph_idorder = IsaMethod.apply_psgraph_tac psg_idorder;
*}

ML{*
val psg_idorder_hier = IsaMethod.init_psgraph psf_hier @{context};
val psgraph_idorder_hier = IsaMethod.apply_psgraph_tac psg_idorder_hier;
*}

ML{*
val psf_step = psstep THENG psid (*THENG psasm*);
val psg_step = IsaMethod.init_psgraph psf_step @{context};
val psgraph_idstep = IsaMethod.apply_psgraph_tac psg_step;
*}

ML{*
val ps_induct = LIFT ([gt_induct], [gt_base, gt_step]) (induct);
val ps_base = LIFT ([gt_base],[gt_ref]) (simp2b);
val ps_step1 = LIFT ([gt_step],[gt_step]) (simp2b);
val ps_step2 = LIFT ([gt_step],[gt_ref]) (simp2b);
val ps_step = LIFT ([gt_step, gt_step, gt_base],[gt_step, gt_ref]) (simp2b);
val ps_simp_loop = LOOP ps_step gt_step;
val ps_ref = LIFT ([gt_ref], []) (refla);
val psf_Suc = ps_induct THENG ps_base THENG ps_ref THENG ps_step1 THENG ps_step1 THENG ps_step2 THENG ps_ref;
val psf_Suc_alt = ps_induct THENG  ps_simp_loop THENG ps_ref
val psg_Suc = IsaMethod.init_psgraph psf_Suc_alt @{context};
val psgraph_Suc = IsaMethod.apply_psgraph_tac psg_Suc;
*}

(* Combined strategy *)

ML{*
val ps_induct = LIFT ([gt_induct],[gt_base,gt_step]) (induct);
val ps_base1 = LIFT ([gt_base],[]) (simp1a);
val ps_step1 = LIFT ([gt_step],[gt_id]) (simp2b);
val ps_step2 = LIFT ([gt_step,gt_step,gt_base],[gt_step,gt_ref]) (simp2b);
val ps_step_loop = LOOP ps_step2 gt_step;
val ps_base_choice = OR (ps_base1,ps_step_loop);
val ps_step_choice = OR (ps_step1,ps_step_loop);
val ps_id = LIFT ([gt_id],[gt]) (id_revb)
val ps_ref = LIFT ([gt_ref],[]) (refla)
val psf_combined = ps_induct THENG ps_base_choice THENG ps_step_choice 
                    THENG ps_id THENG ps_ref;
val psg_combined = IsaMethod.init_psgraph psf_combined @{context};
val psgraph_combined = IsaMethod.apply_psgraph_tac psg_combined;
*}




-- "Examples"

ML{*
eval_interactive;
val [edata] = EVal.init psg_Suc @{context} @{prop "gexp g n ** g = gexp g (Suc n)"};
*}

ML{*
eval_interactive
*}

ML{*
EData.get_pplan edata;
*}

lemma "a ** e = a"
  apply (tactic "psgraph_idrev @{context}")
oops


lemma "gexp e n = e"
  apply (induct n)
  apply (rule l1)
  apply (tactic "psgraph_idstep @{context}")
  apply assumption
  apply assumption
  apply assumption
done

lemma "gexp e n = e"
  apply (tactic "psgraph_idorder @{context}")
  apply assumption
  apply assumption
  apply assumption
done

lemma "gexp e n = e"
  apply (induct n)
  apply (rule l1)
  apply (subst l2)
 
  apply (tactic "psgraph_idrev @{context}")

  apply (subst ax3s) 
  back
  apply (subst ax2s)
  apply (subst inv_rev)
  apply (subst ax1)

  apply assumption
done


lemma "gexp e n = e"
  apply (tactic "psgraph_idorder_hier @{context}")
oops

lemma "gexp g n ** g = gexp g (Suc n)"
  apply (tactic "psgraph_Suc @{context}")
oops



ML{*
val edata0 = EVal.init psg_Suc @{context} @{prop "gexp g n ** g = gexp g (Suc n)"} |> hd;
PSGraph.PSTheory.write_dot (path ^ "Sucgraph0.dot") (EData.get_graph edata0)
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^ "Sucgraph1.dot") (EData.get_graph edata1)   
*}
(* Short strategy *)

ML{*
val edata0 = EVal.init psg_step @{context} @{prop "gexp e n = e \<Longrightarrow> gexp e (Suc n) = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "partgraph0.dot") (EData.get_graph edata0)  
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^ "partgraph1.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"partgraph2.dot") (EData.get_graph edata2)   
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"partgraph3.dot") (EData.get_graph edata3)   
*}


(* No hierarchy *)

ML{*
val edata0 = EVal.init psg_idorder @{context} @{prop "gexp e n = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "fullgraph0.dot") (EData.get_graph edata0)  
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"fullgraph1.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"fullgraph2.dot") (EData.get_graph edata2)   
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"fullgraph3.dot") (EData.get_graph edata3)   
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot (path ^"fullgraph4.dot") (EData.get_graph edata4)   
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot (path ^"fullgraph5.dot") (EData.get_graph edata5)   
*}


(* With hierarchy *)

ML{*
val edata0 = EVal.init psg_idorder_hier @{context} @{prop "gexp e n = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "hiergraph0.dot") (EData.get_graph edata0)  
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"hiergraph1.dot") (EData.get_graph edata1)   
*}

ML{*
val (EVal.Cont edata2) = EVal.evaluate_any edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path ^"hiergraph2.dot") (EData.get_graph edata2)   
*}

ML{*
val (EVal.Cont edata3) = EVal.evaluate_any edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path ^"hiergraph3.dot") (EData.get_graph edata3)   
*}

ML{*
val (EVal.Cont edata4) = EVal.evaluate_any edata3;
val edata4 = EVal.normalise_gnode edata4;
PSGraph.PSTheory.write_dot (path ^"hiergraph4.dot") (EData.get_graph edata4)   
*}

ML{*
val (EVal.Cont edata5) = EVal.evaluate_any edata4;
val edata5 = EVal.normalise_gnode edata5;
PSGraph.PSTheory.write_dot (path ^"hiergraph5.dot") (EData.get_graph edata5)   
*}

ML{*
val (EVal.Cont edata6) = EVal.evaluate_any edata5;
val edata6 = EVal.normalise_gnode edata6;
PSGraph.PSTheory.write_dot (path ^"hiergraph6.dot") (EData.get_graph edata6)   
*}

ML{*
val (EVal.Cont edata7) = EVal.evaluate_any edata6;
val edata7 = EVal.normalise_gnode edata7;
PSGraph.PSTheory.write_dot (path ^"hiergraph7.dot") (EData.get_graph edata7)   
*}
end
