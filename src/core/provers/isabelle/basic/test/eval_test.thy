(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin


ML{*
(* only support the following return types: term list, thm list, term, thm *)
scan_env_tac StrName.NTab.empty "?x := @{term \" x + y  \"}"
*}

end



