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

ML{*
val (id_tac : Proof.context -> tactic) = 
  fn _ => Tactical.all_tac;
*}

setup {*
PSGraphMethod.add_tac ("identity_tac",id_tac);
*}



ML{*
  val psid = RTechn.id


  val psconj = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val psimp = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

  val psdisj = RTechn.id
          |> RTechn.set_name (RT.mk "rule disjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["disjI1","disjI2"]));

*}





end
