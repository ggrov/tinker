theory ai4fm
imports "../../core/provers/isabelle/clausal/CIsaP"  

begin
ML{*
  (* change this to the location of your local copy *)
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/" 
  val pspath = tinker_path ^ "src/dev/psgraph/"; (* where all psgraph under dev are located here *)
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}
(* a quick test *)
ML{* val ps = PSGraph.read_json_file (pspath^"test.psgraph") *}
ML{* -
Tinker.start_ieval @{context} (SOME ps) (SOME []) (SOME @{prop "P\<longrightarrow> P"});
*}
ML{*-
  TextSocket.safe_close();
*}


end

 
