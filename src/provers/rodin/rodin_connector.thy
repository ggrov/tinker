 
theory rodin_connector

imports Main
begin   
(* socket *) 
ML_file "../../debug_handler.ML"  
ML_file "../../interface/text_socket.ML"

ML{*

(* Connect to Rodin, and return the socket *)

fun connectRodin port =
   ( TextSocket.safe_local_client port )

fun send sock cmd =
  let 
  val msg=(TextSocket.write sock cmd);
  val msg=(TextSocket.flushOut sock)
  in
  "Command Sent"
  end
fun close sock =
  let 
  val termination=(send sock "TINKER_DISCONNECT");
  val termination=(TextSocket.close sock)
  in
  "Disconnected."
  end

val rodin = connectRodin(1991); 
send rodin "lasoo";

close rodin;
*}

end
