(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin

ML{*
Env_Tac_Utils.scan_env_vars  (Symbol.explode "this is a string ?y star ?x ? z ?y s ?z");

Term.subst_Vars;

val t = IsaProver.trm_of_string @{context} "?x + 1 + ?y";

subst_trm_vars [("?x", @{term "3"}), ("?y", @{term "4"})] t |> Syntax.check_term @{context}
|> Syntax.pretty_term @{context} |> Pretty.writeln;
*}

ML{*
LoggingHandler.logging "FAILURE" "this";
*}
ML{*

val env = StrName.NTab.ins ("x", IsaProver.E_Trm @{term "5 :: nat"}) StrName.NTab.empty
  |> StrName.NTab.ins ("y", IsaProver.E_Trm @{term "6 :: nat"});
IsaProver.pretty_env @{context} env |> Pretty.writeln;

val abbrv = "?z := @{term \"1 + 3  + 4 + ?x + 5 + ?y + ?x\" }";

val env = Env_Tac_Utils.scan_abbrv_env_tac @{context} abbrv env |> hd;
IsaProver.pretty_env @{context} env |> Pretty.writeln;
*}

ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}

ML{* -
  TextSocket.safe_close();
*}
 
ML{*  -
Tinker.start_ieval @{context}  NONE (SOME []) (SOME @{prop "(C \<longrightarrow> ((A \<longrightarrow> A) \<and> (B \<longrightarrow> B)))"})
*}


end



