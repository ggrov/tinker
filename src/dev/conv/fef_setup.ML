  use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");

  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/";
  val pspath = tinker_path ^ "src/dev/conv/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_64";
  
  set_guiPath guiPath sys;
  (*open_gui_single();*)

  val _ = LoggingHandler.active_all_tags ();


