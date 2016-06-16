theory taut_tac
imports taut_tac_setup
begin
ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val ps_file = "simple_taut.psgraph";
  val taut = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);
*}


ML{*-
TextSocket.safe_close();*}  

ML{*-
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME @{prop "(A \<and> A \<and> B) \<longrightarrow> (B \<and> A \<and> True)"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

ML{*-
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME @{prop "\<not> ( False \<and> (\<not>True))"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

ML{* -
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME @{prop "(A \<or> B) \<longrightarrow> (B \<or> A)"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
end
