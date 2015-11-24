theory demo
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin
ML{*
  (* change this to the location of your local copy *)
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/" 
  val pspath = tinker_path ^ "src/dev/ai4fm/"; (* where all psgraph under dev are located here *)
  val pspath = tinker_path ^ "src/dev/psgraph/";
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}
    
ML{* val ps = PSGraph.read_json_file NONE (prj_path ^"demo.psgraph"); 
     val prop = @{prop "\<exists> x y z. P \<and> 0 = z"};
*}  
  

ML{*-
Tinker.start_ieval @{context} (SOME ps) (SOME []) (SOME prop);    
*}

ML{*-
  TextSocket.safe_close();  
*}

end
