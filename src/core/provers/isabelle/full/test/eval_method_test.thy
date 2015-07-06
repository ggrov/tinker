theory eval_method_test 
imports
  "../build/IsaP"          
begin

(* ML_file   "../isa_method.ML"             *) 

ML{*

  val gt = FullGoalTyp.default;

  val auto = RTechn.id
            |> RTechn.set_name (RT.mk "auto")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "auto"));

  val psauto = PSComb.LIFT ([gt],[]) (auto);
*}

ML{*

  val gt = FullGoalTyp.default;

  val r1 = RTechn.id
            |> RTechn.set_name (RT.mk "r1")
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"));

  val psr1 = PSComb.LIFT ([gt],[gt]) r1;
*}

setup {* IsaMethod.add_tac ("dummy",K no_tac) *} 

-- "test of method"
ML{*
val psg = IsaMethod.init_psgraph psr1 @{context};
val mytac = IsaMethod.apply_psgraph_tac psg;
*}

lemma "A \<longrightarrow> A"
  apply (tactic "mytac @{context}")
  oops

ML{*
 val [ed] = 
   IsaMethod.init_with_named_assms 
    psauto (* psgraph function *)
    @{context} (* context *)
    @{prop "A"} (* the goal *)
    [("a",Thm.map_tags (Properties.put ("useful","no")),@{prop "A"})]; (* list of named and labeled assms *)
*} 
ML{*
 PPlan.init_goal;
 IsaMethod.init;
 EData.get_pplan ed;
*}


end;


