theory rodinv2_test                                           
imports       
  "./TinkeringRodin"
begin


ML{*
LoggingHandler.active_all_tags ();
LoggingHandler.print_active();
  val path2 = "F:/Library/Documents/git/tinker/src/tinkerGUI/release/tinker_library/rodin/";
*}
ML{*

*}
(* read and load a psgraph created by gui *)
ML{* 
 
  val ps = PSGraph.read_json_file (path2^"demo_rodin.psgraph");  
  PSGraph.write_json_file (path2^"demo_rodin.psgraph") ps;  
*}




ML{*

*}  
ML{*
open RJP;      

fun disconn_gui() = 
let open Json;
  val jobj=(Json.mk_object[("cmd", Json.mk_object[("name", Json.String  "CMD_END_EVAL_SESSION")])])
  in
    TextSocket.write (TextSocket.safe_local_client 1790) (Json.encode jobj)

end

fun finish () =
  (RodinSock.send (toJson ("DISCONNECT_NORMALLY",[]));
   RodinSock.disconnect ());   
 
fun finish_with_ex e = 
  (RodinSock.send (toJson ("DISSCONNECT_WITH_ERROR",[("ERROR",e)]));
   RodinSock.disconnect ());     
       
*}
ML{*-
   RodinSock.disconnect ();
*}
ML{*-
  TextSocket.safe_close();   
*}

ML{*
  TextSocket.close ;   
*}
ML{*
SimpleNamer.init();    
 
Tinker.start_ieval "" ps [] ""  handle exn =>   
(finish_with_ex "SOME SOCKET ERROR"; 
disconn_gui();    
TextSocket.safe_close();      
raise exn);           
val _ = finish();    

*} 