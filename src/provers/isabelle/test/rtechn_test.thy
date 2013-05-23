theory rtechn_test
imports "../build/RTechn"
begin

(*a simple rtechn*)
ML{*
 val asm_rtechn = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));
*}

ML{*
 val impI_rtechn = RTechn.id
            |> RTechn.set_name (RT.mk "rule impI")
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"));
*}

ML{*
  val psfg1 = LIFT ([GoalTyp.top],[GoalTyp.top]) (impI)
  val psfg2 = LIFT ([GoalTyp.top],[GoalTyp.top]) (RTechn.id)
  val psfg3 = psfg1 THENG psfg2;
*}
end
