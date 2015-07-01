theory rodin_test                                           
imports       
  "./TinkeringRodin"
begin


ML{*
LoggingHandler.active_all_tags ();
LoggingHandler.print_active();
  val path2= "F:/Library/Documents/git/tinker/src/tinkerGUI/release/tinker_library/";
*}
ML{*

*}
(* read and load a psgraph created by gui *)
ML{* 
 
  val ps = PSGraph.read_json_file (path2^"demo_rodin.psgraph"); 
  PSGraph.write_json_file (path2^"demo_rodin.psgraph") ps;  s
*}




ML{*
  TextSocket.safe_close();               
*}
ML{*  
Tinker.start_ieval "" ps [] "";              
Rodin.close ""; 
*} 
