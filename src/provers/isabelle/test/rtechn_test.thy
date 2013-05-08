theory rtechn_test
imports "../build/RTechn"
begin

(*a simple rtechn*)
ML{*
 val asm_rtechn = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,RT.mk "atac"));
*}

ML{*
 val impI_rtechn = RTechn.id
            |> RTechn.set_name (RT.mk "rule impI")
            |> RTechn.set_atomic_appf (RTechn.Rule (RT.NSet.single (RT.mk "impI")))
*}
end
