structure EnvTac_Lib = 
struct
(*
 fun ENV_get_%implies%_asm [PPProver.A_Var name, PPProver.A_Trm trm] env = 
  [StrName.NTab.update (name, dest_%implies% trm |> fst |> asm_rule |> PPProver.A_Thm) env]
 |   ENV_get_%implies%_asm _ _ = []
*)
end (* end of struct *)
open EnvTac_Lib;
