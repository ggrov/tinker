theory group_strategy_fullgt
imports
  "../GroupAx"
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
  "../../../provers/isabelle/full/build/Parse"
begin

ML_file  "../../../provers/isabelle/termlib/rippling/basic_ripple.ML"


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
              |> FGT.set_name (G.mk "has 0");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "Suc"]] Class.top
                |> Class.rename (C.mk "goal_step");
  val gt_step = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "has Suc n");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ + Suc _"]] Class.top
                |> Class.rename (C.mk "goal_step'");
  val gt_step' = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "adds Suc n'");            

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "e"]] Class.top
                |> Class.rename (C.mk "goal_id");
  val gt_id = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "has identity");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "gexp ?a _ ** e"]] Class.top
                |> Class.rename (C.mk "goal_term_id");
  val gt_term_id = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "has term then identity");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "inv"]] Class.top
                |> Class.rename (C.mk "goal_inv");
  val gt_inv = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "has inverse");

  val gt_induct = FGT.default |> FGT.set_name (G.mk "inductable");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "="]] Class.top
                |> Class.rename (C.mk "goal_refl");
  val gt_ref = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "LHS = RHS");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ ** (_ **_)"]] Class.top
                |> Class.rename (C.mk "goal_presimp");
  val gt_presimp = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "re-bracketing");

(*  val goalclass = Class.add_item (SStrName.mk "inductable")[[GTD.Term @{term n}]] Class.top
                |> Class.rename (C.mk "goal_induct");
  val gt_induct = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "inductable");
*)
*}

ML{*
BasicRipple.ripple_tac @{context} 1
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

val ruleset = 
RTechn.id
|> RTechn.set_name (RT.mk "rule application")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["l1","l2","id_rev",
                                        "refl"]));

val substset = 
RTechn.id
|> RTechn.set_name (RT.mk "subst application")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["l1","l2","id_rev",
                                        "Nat.add_0_right","add_Suc_right","ax2s"]));

(*val simp2a = 
RTechn.id
|> RTechn.set_name (RT.mk "rule l2")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["l2"]));

val simp2b =
RTechn.id
|> RTechn.set_name (RT.mk "subst l2")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["l2"]));*)

val id_reva = 
RTechn.id
|> RTechn.set_name (RT.mk "rule id_rev")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["id_rev"]));

val id_revb =
RTechn.id
|> RTechn.set_name (RT.mk "subst id_rev")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["id_rev"]));

val ax3sb =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax3s")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax3s"]));

val ax3sb2 =
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

val ax1a =
RTechn.id
|> RTechn.set_name (RT.mk "rule ax1")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["ax1"]));

val ax1b =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax1")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax1"]));

val refla =
RTechn.id
|> RTechn.set_name (RT.mk "rule refl")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["refl"]));

val add_zerob = 
RTechn.id
|> RTechn.set_name (RT.mk "subst Nat.add_0_right")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["Nat.add_0_right"]));

val add_Suc_rb =
RTechn.id 
|> RTechn.set_name (RT.mk "subst add_Suc_right")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["add_Suc_right"]));

val simp =
RTechn.id
|> RTechn.set_name (RT.mk "simp")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));


(*val back =
RTechn.id
|> RTechn.set_name (RT.mk "back")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TClass, "back"));*)


(* setup rippling *)
   val ripple_tac = BasicRipple.ripple_tac;
   val rippling = RTechn.id
               |> RTechn.set_name (RT.mk "rippling")
               |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "rippling"));
*}



-- "PSGraph"

(* Combinators *)

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val NEST = PSComb.NEST;
 val LOOP = PSComb.LOOP_WITH;
 val LIFT = PSComb.LIFT;
 infixr 5 OR;
 val op OR = PSComb.OR;
*}

(* id_rev sub-strategy *)

ML{*
val psax3s = PSComb.LIFT ([gt_id],[gt_inv]) (ax3sb2)
val psax2s = PSComb.LIFT ([gt_inv],[gt_inv]) (ax2sb)
val psinv = PSComb.LIFT ([gt_inv], [gt_id]) (inv_revb)
(*val psinvchoice = OR (psax2s,psinv)
val psinvloop = LOOP psinvchoice gt_inv*)
val psax1a = PSComb.LIFT ([gt_id],[]) (ax1a)
val psax1b = PSComb.LIFT ([gt_id], [gt]) (ax1b)

val psf_idreva = psax3s THENG psax2s THENG psinv THENG psax1a;
val psg_idreva = IsaMethod.init_psgraph psf_idreva @{context};
val psgraph_idreva = IsaMethod.apply_psgraph_tac psg_idreva;

val psf_idrevb = psax3s THENG psax2s THENG psinv THENG psax1b;
val psg_idrevb = IsaMethod.init_psgraph psf_idrevb @{context};
val psgraph_idrevb = IsaMethod.apply_psgraph_tac psg_idrevb;
*}

ML{*
val id_rev_ha = NEST "rule id_rev" psf_idreva;
val id_rev_hb = NEST "subst id_rev" psf_idrevb;
*}


(* Basic strategy - gexp_id *)

ML{*
val psinduct = PSComb.LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val psbase = PSComb.LIFT ([gt_base],[]) (ruleset);
val psstep = PSComb.LIFT ([gt_step],[gt_id]) (substset);
val psid = PSComb.LIFT ([gt_id],[gt]) (id_revb);
val psasm = PSComb.LIFT ([gt],[]) (asm);
val psf_idorder = psinduct THENG psbase THENG psstep THENG psid THENG psasm;
(*val psgraph_idorder =   psf PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (IsaMethod.get_tacs @{theory}));*)

val psf_hier = psinduct THENG psbase THENG psstep THENG id_rev_hb THENG psasm;

*}

ML{*
val psf_asm = PSComb.LIFT ([gt],[]) (asm);
val psg_asm = IsaMethod.init_psgraph psf_asm @{context};
val psgraph_asm = IsaMethod.apply_psgraph_tac psg_asm;
*}

ML{*
val psg_idorder = IsaMethod.init_psgraph psf_idorder @{context};
val psgraph_idorder = IsaMethod.apply_psgraph_tac psg_idorder;
*}

ML{*
val psg_idorder_hier = IsaMethod.init_psgraph psf_hier @{context};
val psgraph_idorder_hier = IsaMethod.apply_psgraph_tac psg_idorder_hier;
*}

ML{*
val psf_step = psstep THENG psid THENG psasm;
val psg_step = IsaMethod.init_psgraph psf_step @{context};
val psgraph_idstep = IsaMethod.apply_psgraph_tac psg_step;
*}

(* Strategy with loops - gexp_Suc*)

ML{*
val ps_induct = LIFT ([gt_induct],[gt_base, gt_step]) (induct);
val ps_base = LIFT ([gt_base],[gt_ref]) (substset);
val ps_step1 = LIFT ([gt_step],[gt_step]) (substset);
val ps_step2 = LIFT ([gt_step],[gt_ref]) (substset);
val ps_step = LIFT ([gt_step, gt_step, gt_base],[gt_step, gt_ref]) (substset);
val ps_simp_loop = LOOP ps_step gt_step;
val ps_ref = LIFT ([gt_ref], []) (refla);
val psf_Suc = ps_induct THENG ps_base THENG ps_ref THENG ps_step1 THENG ps_step1 THENG ps_step2 THENG ps_ref;
val psf_Suc_alt = ps_induct THENG  ps_simp_loop THENG ps_ref
val psg_Suc = IsaMethod.init_psgraph psf_Suc_alt @{context};
val psgraph_Suc = IsaMethod.apply_psgraph_tac psg_Suc;
*}

(* gexp_order_plus strategy *)
ML{*
val ps_induct = LIFT ([gt_induct],[gt_base,gt_step']) (induct);
val ps_base1 = LIFT ([gt_base],[gt_base]) (add_zerob);
val ps_base2 = LIFT ([gt_base],[gt_id]) (substset);
val ps_id = id_rev_ha;
val ps_step1 = LIFT ([gt_step'],[gt_step])(add_Suc_rb);
val ps_step_int = LIFT ([gt_step,gt_step],[gt_step,gt_presimp]) (substset)
val ps_step2 = LOOP ps_step_int gt_step;
val ps_ax2 = LIFT ([gt_presimp],[gt]) (ax2sb);
val ps_simp = LIFT ([gt],[]) (simp);

val psf_plus = ps_induct THENG ps_base1 THENG ps_base2 THENG ps_id THENG ps_step1
                  THENG ps_step2 THENG ps_ax2 THENG ps_simp;
val psg_plus = IsaMethod.init_psgraph psf_plus @{context};
val psgraph_plus = IsaMethod.apply_psgraph_tac psg_plus;
*}


(* Combined strategy *)

ML{*
val ps_induct = LIFT ([gt_induct],[gt_base,gt_base,gt_step',gt_step]) (induct);
val ps_prebase =  LIFT ([gt_base],[gt_base]) (substset);
val ps_basea = LIFT ([gt_base],[]) (ruleset);
val ps_baseb = LIFT ([gt_base],[gt_id]) (substset);
val ps_baseh = NEST "base hierarchy" (ps_prebase THENG ps_baseb)
(*val ps_prestep = LIFT ([gt_step'],[gt_step])(substset);*)
val ps_step = LIFT ([gt_step',gt_step,gt_step,gt_presimp,gt_base,gt_base(*,gt_step*)],
                    [gt_step,gt_ref,gt_id,gt_presimp,gt,gt_base,gt_id]) (substset);
val ps_step_loop = LOOP ps_step gt_step;
(*val ps_step_loop1 = LOOP ps_step_loop gt_id;*)
val ps_step_loop1 = LOOP ps_step_loop gt_presimp;
val ps_step_loop2 = LOOP ps_step_loop1 gt_base;
val ps_step_loop3 = LOOP ps_step_loop2 gt_term_id;
val ps_ref = LIFT ([gt_ref],[]) (ruleset);
val ps_id = LIFT ([gt_id],[gt]) (substset);
val ps_asm = LIFT ([gt,gt],[]) (asm);
val ps_ax2 = LIFT ([gt_presimp],[gt]) (substset);
val ps_simp = LIFT ([gt,gt],[]) (simp);
val ps_or = OR (ps_basea, ps_baseh);
val ps_rules = LIFT ([gt_base,gt_ref,gt_id],[]) (ruleset);
val ps_tops = OR (ps_asm,ps_simp);
val psf_combined = ps_induct (*THENG ps_baseh  id_rev_ha*) THENG
                    (*ps_basea THENG ps_prestep THENG*) ps_step_loop2  
                      THENG id_rev_hb THENG ps_rules
                      THENG ps_tops (*THENG ps_ref THENG ps_ax2 THENG 
                      (*ps_tops*) ps_simp*);
val psg_combined = IsaMethod.init_psgraph psf_combined @{context};
val psgraph_combined = IsaMethod.apply_psgraph_tac psg_combined;
*}



-- "Examples"

ML{*
val [edata] = EVal.init psg_combined @{context} @{prop "gexp e n = e"};
*}

ML{*
eval_interactive
*}

ML{*
EData.get_pplan edata ;
*}

ML{*
BasicRipple.ripple_tac @{context} 1
*}


lemma gexp_order_plus: "gexp g n ** gexp g m = gexp g (n + m)"
apply (tactic "psgraph_combined @{context}")
oops

lemma "gexp e n = e"
  apply (tactic "psgraph_combined @{context}")
oops


lemma "gexp e n = e"
  apply (induct n)
  apply (rule l1)
  apply (tactic "psgraph_idstep @{context}")
  apply assumption
  apply assumption
done


lemma ex_working: "gexp e n = e"
  apply (tactic "ripple_tac @{context} 1")
  apply (induct n)
  apply (rule l1)
  apply (subst l2)
  apply (subst id_rev)
  apply assumption
done

lemma ex_working2: "gexp g n ** g = gexp g (Suc n)"
  apply (tactic "ripple_tac @{context} 1")
  apply (induct n)
  apply (tactic "ripple_tac @{context} 2")
  apply (subst l2)
  apply (rule refl)
  apply (subst l2)
  apply (subst l2)
  apply (subst l2)
  apply (rule refl)
done

ML{*
BasicRipple.ripple_tac @{context} 1 @{thm "ex_working"}
*}



lemma "gexp g n ** g = gexp g (Suc n)"
  apply (tactic "psgraph_combined @{context}")
oops


(* Loop strategy *)

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


(* Combined Strategy *)

ML{*
val edata0 = EVal.init psg_combined @{context} @{prop "gexp e n = e"} |> hd; 
PSGraph.PSTheory.write_dot (path ^ "combgraph0.dot") (EData.get_graph edata0)  
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_any edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path ^"combgraph1.dot") (EData.get_graph edata1)   
*}
end
