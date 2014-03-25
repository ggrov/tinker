theory introstrat
imports
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
  "../../../provers/isabelle/full/build/Parse" 
(*   "../../../provers/isabelle/basic/build/BIsaMeth" 
   "../GroupAx"
   "../grouporder" *)
begin


ML{*
structure FGT = FullGoalTyp;
structure GTD = GoalTypData;
*}

-- "Goal Types"
ML{*

  val gt = FGT.default
          

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "\<and>"]] Class.top
                |> Class.rename (C.mk "goal_conj");
  val gt_conj = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "has \<and>");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "\<or>"]] Class.top
                |> Class.rename (C.mk "goal_disj");
  val gt_disj = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "has \<or>");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "\<longrightarrow>"]] Class.top
                |> Class.rename (C.mk "goal_imp'");
  val gt_imp = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "has \<longrightarrow>'");            
*}


-- "reasoning techniques"

ML{*
val id =
RTechn.id
|> RTechn.set_name (RT.mk "identity")


val impI = 
RTechn.id
|> RTechn.set_name (RT.mk "rule impI")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

val conjI = 
RTechn.id
|> RTechn.set_name (RT.mk "rule conjI")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));

val disjI = 
RTechn.id
|> RTechn.set_name (RT.mk "rule disjI")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["disjI1","disjI2"]));
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


ML{*
val ps_idin = LIFT ([gt],[gt_conj,gt_disj,gt_imp]) (id);
val ps_conj = LIFT ([gt_conj],[gt]) (conjI);
val ps_disj = LIFT ([gt_disj],[gt]) (disjI);
val ps_imp = LIFT ([gt_imp],[gt]) (impI);
val ps_idout = LIFT ([gt,gt,gt],[gt]) (id);

val psf_intro = ps_idin THENG ps_conj THENG ps_disj THENG ps_imp THENG ps_idout;
*}

ML{*
val psg_intro = IsaMethod.init_psgraph psf_intro @{context};
val psgraph_intro = IsaMethod.apply_psgraph_tac psg_intro;
*}


-- "Examples"

ML{*
val [edata] = EVal.init psg_intro @{context} @{prop "A \<longrightarrow> A"};
*}

ML{*
eval_interactive 
*}






end
