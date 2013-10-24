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

setup {* IsaMethod.add_tac ("dummy",K no_tac) *} 

ML{*
 val [ed] = 
   IsaMethod.init_with_named_assms 
    psauto (* psgraph function *)
    @{context} (* context *)
    @{prop "A"} (* the goal *)
    [("a",Thm.map_tags (Properties.put ("useful","no")),@{prop "A"})]; (* list of named and labeled assms *)
*} 
ML{*
 IsaMethod.init;
 EData.get_pplan ed;
*}


end;


