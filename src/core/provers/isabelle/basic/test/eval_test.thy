(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}

ML{* -
  TextSocket.safe_close();
*}
 
ML{* 
Tinker.start_ieval @{context}  NONE (SOME []) (SOME @{prop "(C \<longrightarrow> ((A \<longrightarrow> A) \<and> (B \<longrightarrow> B)))"})
*}


end



