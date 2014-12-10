theory sock_test

imports Main
begin   
(* socket *) 
ML_file "../debug_handler.ML"  
ML_file "../interface/text_socket.ML"

ML{*   
TextSocket.safe_close; 
val s = TextSocket.safe_local_client 1797; 
TextSocket.write s "hello from client \n"; 
TextSocket.flushOut s;
*}

ML{*
TextSocket.read s; (* expect to be "can you hear me" *) 
*}

ML{*  
TextSocket.write s "say hello from the client\n"; 
TextSocket.flushOut s;
*}

ML{*
val s = TextSocket.safe_local_client 1790; 
TextSocket.write s "hello 2 from client \n"; 
TextSocket.flushOut s;
TextSocket.read s; (* expect to be "can you hear me" *)

TextSocket.write s "say hello 2  from the client\n"; 
TextSocket.flushOut s;
*}
 
ML{*-
TextSocket.write s "CMD_CLOSE\n";
TextSocket.flushOut s;
*}
(*{*-
TextSocket.close s;
*}*)

end
