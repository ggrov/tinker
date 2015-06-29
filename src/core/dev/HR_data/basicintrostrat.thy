theory basicintrostrat
imports
  "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
begin

-- "Goal Types"

ML{*
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  val gt_disj = "top_symbol(HOL.disj)";
*}


-- "Reasoning Techniques"
(*
ML{*
val (id_tac : Proof.context  -> tactic) = 
  fn _ => Tactical.all_tac;
*}

setup {*
PSGraphMethod.add_tac ("identity_tac",id_tac);
*}
*)


ML{*
  val id = RTechn.id
          |> RTechn.set_name (RT.mk "identity")
          |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"all"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

  val disjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule disjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["disjI1","disjI2"]));

*}


-- "Strategy"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val LIFT = PSComb.LIFT;
*}


ML{*
val ps_idin = LIFT ([gt],[gt_conj,gt_disj,gt_imp]) (id);
val ps_conj = LIFT ([gt_conj],[gt]) (conjI);
val ps_disj = LIFT ([gt_disj],[gt]) (disjI);
val ps_imp = LIFT ([gt_imp],[gt]) (impI);
val ps_idout = LIFT ([gt,gt,gt],[gt]) (id);

val psf_intro = ps_idin THENG ps_conj THENG ps_disj THENG ps_imp THENG ps_idout;

val psgraph_introsimp =   psf_intro PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}

setup {* PSGraphMethod.add_graph ("intro_simp",psgraph_introsimp) *}


-- "Examples"

lemma "A \<longrightarrow> A"
  apply (psgraph  intro_simp)
  apply assumption
done

end
