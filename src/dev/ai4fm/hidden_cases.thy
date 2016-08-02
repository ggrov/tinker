theory hidden_cases
imports ai4fm_setup
begin
ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val ps_file = "hiddenCase.psgraph";
*}

ML{*
  val hca = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);*}


ML{*-
TextSocket.safe_close();*}  

ML{*-
val g = @{prop "m \<ge> (2::nat) \<Longrightarrow>  P"};
val thm = Tinker.start_ieval @{context} (SOME hca) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}


ML{*
val g = @{prop "m \<ge> (2::nat) \<Longrightarrow>  P"};
val e = EVal.init hca @{context} [] g |> hd; *}

ML{*
IEVal.eval_any e; 
*}
end
