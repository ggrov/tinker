  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");


  val env = StrName.NTab.ins ("x", PPProver.E_Trm ¬111®) StrName.NTab.empty |> StrName.NTab.ins ("y", PPProver.E_Trm ¬222®);

  PPProver.pretty_env PPProver.default_ctxt env |> Pretty.writeln;

  val abbrv = "?z := @{term \"1 + 3  + 4 + ?x + 5 + ?y + ?x\"}";

  val env = Env_Tac_Utils.scan_abbrv_env_tac PPProver.default_ctxt abbrv env |> hd;

  PPProver.pretty_env () env |> Pretty.writeln;

  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  open_gui_single();


  fun rule_tac (arg as [PPProver.A_Str pretty]) = (LoggingHandler.logging "TACTIC" pretty; step_strip_tac);
  fun impI_tac _ = step_strip_tac;
  fun conjI_tac _ = step_strip_tac;
  fun assm_tac  _ = step_strip_tac;


  val ps = PSGraph.read_json_file NONE (path^"scratch.psgraph");


(* read and load a psgraph created by gui *)
  val ps = PSGraph.read_json_file NONE (path^"demo.psgraph");
  val ps = PSGraph.read_json_file NONE (path^"demo_env.psgraph");

  PPIntf.set_psg_goal (SOME ([¬B : BOOL®], ¬A ´ (A ± B ± (C ´ C))®)) (NONE);

  TextSocket.safe_close();

======
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
val ps = File_Io.read_string (path^"scratch.psgraph");
PPProver.encoding_from_gui ps |>
PPProver.encoding_to_prover |>
PPProver.encoding_from_prover |>
PPProver.encoding_to_gui;
PSGraph.read_json_file NONE (path^"scratch.psgraph");

"\<impl>";
Json.string_of (Json.String "\\<impl>");