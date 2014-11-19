theory sock_test

imports Main
begin 
(* socket *)
ML_file "../debug_handler.ML"
ML_file "../interface/text_socket.ML"


ML{*
val s = TextSocket.local_client 1790; 
(*TextSocket.write s "hello from client"; *)
*}

ML{*TextSocket.read s; (* expect to be "can you hear me" *) *}
ML{* 
TextSocket.write s "say hello from the client\n"; 
TextSocket.flushOut s;
*}

(*{*-
TextSocket.close s;
*}*)

end
