theory example_taut
imports taut_tac_setup
begin

ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val taut_tac = PSGraph.read_json_file (SOME data) (pspath ^ "taut_tac.psgraph");
*}

ML{* -
  TextSocket.safe_close();
*}  

 
ML{* -
val thm = Tinker.start_ieval @{context} (SOME taut_tac) (SOME []) (SOME @{prop "A\<longrightarrow> B \<longrightarrow> (B \<and> A)"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
end
