(* simple test of proof representation *)
theory eval_test                                           
imports        
  "../build/BIsaP"    
begin

ML{*
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_32"
*}
 
ML{*-

val test = Json.mk_object [("symbol", Json.String "\<longrightarrow>help \<in>")]|> Json.encode 
|> IsaProver.encode_unicode |> IsaProver.decode_unicode;

 File_Io.write_string (path^"test.psgraph") test;

  File_Io.read_string (path^"scratch.psgraph") |> IsaProver.encode_unicode; 

  val ps = PSGraph.read_json_file (path^"scratch.psgraph");

*}


ML{*

val env = StrName.NTab.ins ("x", IsaProver.E_Trm @{term "5 :: nat"}) StrName.NTab.empty
  |> StrName.NTab.ins ("y", IsaProver.E_Trm @{term "6 :: nat"});
IsaProver.pretty_env @{context} env |> Pretty.writeln;

val abbrv = "?z := @{term \"1 + 3  + 4 + ?x + 5 + ?y + ?x\" }";

val env = Env_Tac_Utils.scan_abbrv_env_tac @{context} abbrv env |> hd;
IsaProver.pretty_env @{context} env |> Pretty.writeln;
*}

ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}


ML{*
  RawSource.source Symbol.stopper
    (Parser.p_top_level >> single) NONE
      (RawSource.raw_stream (fn c => c = "}" orelse c = "]") instream)
  |> RawSource.set_prompt ""
*}


ML{* -
  TextSocket.safe_close();
*}
 
ML{*-    
Tinker.start_ieval @{context}  NONE (SOME []) (SOME @{prop "(C \<longrightarrow> ((A \<longrightarrow> A) \<and> (B \<longrightarrow> B)))"})
*}


end



