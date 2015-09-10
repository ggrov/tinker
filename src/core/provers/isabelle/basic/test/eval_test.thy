(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin

ML{*

Env_Tac_Utils.scan_env_vars  (Symbol.explode "this is a string ?y star ?x ? z ?y s ?z");

*}

ML{*-
Env_Tac_Utils.scan_env_vars;
 (Symbol.explode "this is a string ?y star ?x s");

(* pattern space ? letter space \<longrightarrow> remove space *)
val scan_letter = Scan.one Symbol.is_ascii_identifier;

fun scan_def0 handler = 
      Scan.finite Symbol.stopper (Scan.this_string "@{" |> scan_until) -- 
      (fn [] =>  (fn x => ("", x)) []| l => scan_antiquto' handler l ) >> append_pair;
*}

ML{*
val t = IsaProver.trm_of_string @{context} "?x + ?y + 1";
Term.subst_Vars [(("x",0), @{term "3"})] t |> Syntax.pretty_term @{context} |> Pretty.writeln;

IsaProver.trm_of_string @{context} "x + 1";
*}
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}

ML{* 
  TextSocket.safe_close();
*}
 
ML{*  -
Tinker.start_ieval @{context}  NONE (SOME []) (SOME @{prop "(C \<longrightarrow> ((A \<longrightarrow> A) \<and> (B \<longrightarrow> B)))"})
*}


end



