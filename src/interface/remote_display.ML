(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ./interface/remote_display.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Some code to send strings through a socket to be displayed remotely. 
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature REMOTE_DISPLAY 
= sig
  val port : int
  val send_str : string -> int
  val slice_of_pretty :
      Pretty.T -> {i: int, sz: int option, buf: Word8Vector.vector}
  val slice_of_string :
      string -> {i: int, sz: int option, buf: Word8Vector.vector}
  val slice_of_word8vector :
      Word8Vector.vector ->
      {i: int, sz: int option, buf: Word8Vector.vector}
  val gxl_test_plan : string;
end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RemoteDisplay 
: REMOTE_DISPLAY
= struct

val port = 33000;

(* General functions to fill the gaps in the basis library for PolyML. 
   In Particular, PolyML is missing: Word8VectorSlice.slice;
*)
fun slice_of_word8vector s = 
    let val n = (Word8Vector.length s) in 
      {buf = s, i = 0, sz = SOME (n - 1)}
    end;
val slice_of_string = slice_of_word8vector o Byte.stringToBytes;
val slice_of_pretty = slice_of_string o Pretty.string_of;


(* basic network/socket setup *)
fun send_str s = 
    let 
      val entry = the (NetHostDB.getByName
                         (NetHostDB.getHostName()));
      val addr = NetHostDB.addr entry;
      val family = NetHostDB.addrType entry;
      val sock_addr = INetSock.toAddr (addr,port);
      val tcp_sock = INetSock.TCP.socket() 
                     : Socket.active INetSock.stream_sock;
      val ignore = Socket.connect (tcp_sock, sock_addr);
      val slice = slice_of_string ("<display>" ^ s ^ "</display>");
      val result = Socket.sendVec (tcp_sock, slice);
    in (Socket.close tcp_sock; result) end;



local
  fun str s = 
      implode (map (fn "<" => "&lt;" | ">" => "&gt;" | x => x) 
                   (explode s))
  fun name n = 
      "\n<attr name=\"description\"><string>" ^ (str n) ^ "</string></attr>";
  fun goal g = 
      "\n<attr name=\"goal\"><string>"
      ^ (str g) ^ "</string></attr>";
  fun node id s = 
      "\n<node id=\"n" ^ (string_of_int id) ^ "\">" ^ (name s) ^ "</node>\n";
  fun graph id s s2 = 
      ("\n<graph id=\"g" ^ (string_of_int id) ^ "\">" 
       ^ (node id s) ^ s2 ^ "</graph>\n");
  fun edge id1 id2 s = 
      "\n<edge id=\"e" ^ id1 ^ "_" ^ id2 ^ "\" from=\"n" 
         ^ id1 ^ "\" to=\"n" ^ id2 ^ "\">" ^ s ^ "</edge>\n";
in
fun gxl_test_plan () = 
    "\n<gxl xmlns:xlink=\"http://www.w3.org/1999/xlink\">"
    ^ (graph 0 "Induction"
        ^ (goal "a + b = b + a")
        ^ (graph 
             1 "Evaluate the Base Case"
             
(goal "0 + b = b + 0")
                ^ (node 
                     11 ((name "Simplification")
                        ^ (goal "No Subgoals!"))) 
          ))
        ^ (graph 
             2 ((name "Ripple the Step Case")
                ^ (goal "!! a. ALL b. a + b = b + a ==> Suc a + b = b + Suc a")
                ^ (node 
                     3 ((name "Ripple Step")
                        ^ (goal "!! a. ALL b. a + b = b + a ==> Suc (a + b) = b + Suc a")))
                ^ (node 
                     4 ((name "Ripple Step")
                        ^ (goal "!! a. ALL b. a + b = b + a ==> Suc (a + b) = Suc (b + a)")))
                ^ (node 
                     5 ((name "Ripple Step")
                        ^ (goal "!! a. ALL b. a + b = b + a ==> a + b = b + a")))
          ))
        ^ (graph 
             6 ((name "Strong Fertilisation") 
                ^ (goal "No Subgoals!")))))
      ^ "\n</gxl>";
end;

end;


(* Example 

to view the string in the shell: 
   writeln RemoteDisplay.gxl_test_plan;

to send the text_gxl: 
   val r = RemoteDisplay.send_str RemoteDisplay.gxl_test_plan;

*)