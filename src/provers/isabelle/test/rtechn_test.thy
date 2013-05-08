theory rtechn_test
imports "../build/RTechn"
begin

(*a simple rtechn*)
ML{*
 val asm_rtechn = RTechn.id
            |> RTechn.set_name "assumption"
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm,"atac"));
*}

ML{*
 val impI_rtechn = RTechn.id
            |> RTechn.set_name "rule impI"
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.single "impI"))
*}
end
