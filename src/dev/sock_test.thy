theory sock_test

imports Main
begin 
(* socket *)
ML_file "../debug_handler.ML"
ML_file "../interface/text_socket.ML"   

ML{*-
val s = TextSocket.local_client 1797; 
(*TextSocket.write s "hello from client"; *)
*}

ML{*TextSocket.read s; (* expect to be "can you hear me" *) *}
ML{* 
TextSocket.write s "hello from the client\n"; 
;*}

ML{*- TextSocket.read s;*}
ML{*
TextSocket.flush s;
*}
ML{*-
TextSocket.close s;
*}

end
