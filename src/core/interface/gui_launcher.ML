signature GUI_LANUCHER = 
sig
   exception gui_launcher_exp of string
   val close_gui_single : unit -> unit 
   val open_gui_single : unit -> unit
   val set_guiPath : string (*path*)-> string (*system : osx linux or win*) -> bool 
end

structure GUI_Launcher : GUI_LANUCHER = 
struct
  local open CInterface in
  exception gui_launcher_exp of string
  val guiPath : (string * string) option Unsynchronized.ref =  Unsynchronized.ref NONE;
  val guiPID : int option Unsynchronized.ref =  Unsynchronized.ref NONE;
  val version = "0.4"
  fun get_guiPath _ = 
    case !guiPath
      of NONE 
        => raise gui_launcher_exp "GUI Path has not been initialised !"
      | SOME path => path

  fun set_guiPath path sys = 
   let
    val if_valid_path =  (OS.FileSys.fileId (path ^"guiLauncher_" ^ sys ^".so"); true)
    handle  OS.SysErr _ => false;
   in
    if if_valid_path then (guiPath := SOME (path, sys); true)
    else false
   end

  fun get_guiPID _ =    
    case !guiPID
      of NONE 
        => raise gui_launcher_exp "Fail to get gui PID, GUI has not been launched !"
      | SOME pid => pid

  fun set_guiPID pid = guiPID := SOME pid
  fun reset_guiPID _ =  guiPID := NONE

  fun get _  = 
   let val (path, sys) = get_guiPath () in
     CInterface.get_sym (path ^"guiLauncher_" ^ sys ^".so") end

  fun open_gui_single _ = 
   let 
     val if_gui_open : bool =  (get_guiPID () ; true) handle gui_launcher_exp _ => false
   in
     if if_gui_open then LoggingHandler.logging "GUI_LAUNCHER" "No new GUI will be launched, as it has been open."
     else call2 (get () "openGUI") (STRING,STRING) INT (get_guiPath() |> fst,version) |> set_guiPID
   end

  fun close_gui_single _ = 
     ((call1 (get () "closeGUI") (INT) INT (get_guiPID ()) ; reset_guiPID ())
     handle gui_launcher_exp _ => raise gui_launcher_exp "Fail to close GUI, as no GUI is open.")
  end (* local open *)
end

open GUI_Launcher

