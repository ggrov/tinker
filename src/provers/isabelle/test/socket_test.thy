theory socket_test  
imports Main
(*
uses "../interface/gui_socket.ML"             
*)
begin  
  

ML{*
val connected = Synchronized.var "connected" false;

fun change true = (false,true)
 |  change false = (true,true);

Synchronized.change_result connected change;
Synchronized.value connected;

Synchronized.change_result connected change;
Synchronized.value connected;

*}



ML{*
GUISocket.run ();                       
*} 


end;


