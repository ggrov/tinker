theory test                                           
imports       
  "../CIsaP"  
begin

ML{*- 
  val path = "/u1/staff/gg112/";
  val guiPath = "/u1/staff/gg112/tinker/src/tinkerGUI/release/";
*}

ML{*
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/"
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "osx_32"
*}

ML{*-
  val tinker_path ="/home/pierre/Documents/HW/Tinker/tinkerGit/tinker/" 
  val path = tinker_path ^ "src/dev/psgraph/";
  val guiPath = tinker_path ^ "src/tinkerGUI/release/";
  val sys = "linux"
*}

ML{*
  set_guiPath guiPath sys;
*}

ML{*-
  open_gui_single();
*}

ML{*-
 close_gui_single ();
*}
ML{*
  LoggingHandler.active_all_tags ();
  LoggingHandler.print_active();
*}


