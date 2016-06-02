theory eval_rippling
imports Rippling L
begin
ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/rippling/"
  val induct_ripple = PSGraph.read_json_file (SOME data) (pspath ^ "Rippling.psgraph");
*}


section " Peano Arithmetic Theorems "

ML{* -
  TextSocket.safe_close();
*}  

 
ML{* -
val thm = Tinker.start_ieval @{context} (SOME induct_ripple) (SOME []) (SOME @{prop "a + (suc b) = suc (a + b)"}) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}



end
