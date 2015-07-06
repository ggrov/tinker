theory rtechn_test
imports "../build/basic/RTechn"
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
  val quickcheck_auto_r = 
    RTechn.id
    |> RTechn.set_name (RT.mk "quickcheck-auto")
    |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TNoAsm (* or TAllAsm *), "auto"))
*}
end
