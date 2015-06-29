
structure rodin_socket = 
struct
exception ec of string


    




  
fun send sock cmd =
  let 
  val _ =(TextSocket.write sock (cmd ^ "\n"));
  val _ =(TextSocket.flushOut sock )
  in
  sock
  end
  handle _ => raise ec cmd

fun connectRodin port = 
  let val _=TextSocket.close (TextSocket.safe_local_client port);
      val sock=  ( TextSocket.local_client port )
      val handshake=(send sock "TINKER_HAND_SHAKE" )
   in
      sock
   end   

fun reuse port = 
let val sock= TextSocket.safe_local_client port;
    val handshake=(send sock "TINKER_HAND_SHAKE" )
in 
    sock
end handle ec "TINKER_HAND_SHAKE" => raise ec "TINKER_HAND_SHAKE";

fun close sock =
  let 
  val _ =(send sock "TINKER_DISCONNECT");
  val _ =(TextSocket.close sock)
  in
  "Disconnected."
  end

fun read sock = 
let val result=TextSocket.read sock
in
  if result="CONNECTION_CLOSE" then
    let val _ = close sock in
    "{}"
    end
  else if result="ERROR" then
    "EXCEPTION" 
  else
    result
end   handle _ => raise ec ""

end

