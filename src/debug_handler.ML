structure DebugHandler = 
struct

  datatype debug_level = 
    NO_INFO | (* no printing, for debug_level only *)
    ALL_INFO | (* print all, for debug_level only *)
    BASIC_INFO | (* will be printed if debug level is not set to NO_INFO*)
    GOALTYP |
    SUPERGRAPH|
    TACTIC|
    EVAL

  val debug_flag = Unsynchronized.ref NO_INFO;
  
  val set_debug_flag = fn x => debug_flag := x;

  fun debug_print level x = 
    case !debug_flag 
      of NO_INFO => ()
      | ALL_INFO => writeln x
      | _ => 
        if level = BASIC_INFO then writeln x
        else
        (if level = !debug_flag then writeln x
         else ())

  val (debug_msg: Pretty.T list Unsynchronized.ref) = Unsynchronized.ref [];
  fun clear_debug_msg _ = debug_msg := []
  fun add_debug_msg p = debug_msg := (p :: !debug_msg)
  fun get_debug_msg _ = Pretty.string_of (Pretty.chunks ([Pretty.str "[-------------"] @ !debug_msg @ [Pretty.str "-------------]"]));

  fun debug_warning x = writeln ("WARNING: " ^ x);
  fun debug_err () = writeln (get_debug_msg ());
  

end
