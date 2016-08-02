theory one_point_rule
imports ai4fm_setup
begin
ML{* 
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val ps_file = "one_point.psgraph";
*}
 
ML{*
data;
  val onep = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);
*}


ML{*-
TextSocket.safe_close();*}  


ML{* -
val g = @{prop "\<exists>z y x. ((y > x) \<and> (x = (2::int)) \<and> (x + y = 5))"};
val thm = Tinker.start_ieval @{context} (SOME onep) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}


ML{*-
val g = @{prop "\<exists>x y. ((y > x) \<and> (x = (2::int)) \<and> (x + y = 5))"};
val e = EVal.init onep @{context} (IsaProver.G_TERM ([], g)) |> hd; 
e|> EData.get_pplan |> IsaProver.get_goal_thm;
*}

ML{*
   val (pnode,pplan) = IsaProver.init @{context} (IsaProver.G_TERM ([], g));                         
*}
ML{*
 Clause_GT.type_check data pnode (Clause_GT.scan_goaltyp @{context} "is_top(concl)");


*}        



ML{*
val IEVal.Cont e1 = IEVal.eval_any e; 
e1|> EData.get_pplan |> IsaProver.get_goal_thm;

*}
end
