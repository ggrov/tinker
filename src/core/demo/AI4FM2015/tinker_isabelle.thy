theory tinker_isabelle                                 
imports       
  "./setup_isabelle"    
begin 
 
(* read and load a psgraph created by gui *)
 
ML{*
  val ps_simple = PSGraph.read_json_file (path ^"demo_simple.psgraph");   
  val ps_eval = PSGraph.read_json_file (path ^"demo_eval.psgraph");
*}
 
ML{*-
  TextSocket.safe_close();
*}    
  

ML{*-
val thm = Tinker.start_ieval @{context} (SOME ps_simple) (SOME []) (SOME @{prop "P  \<longrightarrow>  P"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}


ML{* -
val thm = Tinker.start_ieval @{context} (SOME ps_eval) (SOME []) (SOME @{prop "P  \<longrightarrow>   (P \<and>  P \<and> (Q \<longrightarrow> Q))"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

ML{*- 
val thm = Tinker.start_ieval @{context} NONE NONE NONE (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

