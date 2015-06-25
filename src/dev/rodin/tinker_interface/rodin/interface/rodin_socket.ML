
structure rodin_socket = 
struct

fun connectRodin port = 
  let val _ =TextSocket.close (TextSocket.safe_local_client port) in
   ( TextSocket.local_client port )
   end
  
fun send sock cmd =
  let 
  val _ =(TextSocket.write sock (cmd ^ "\n"));
  val _ =(TextSocket.flushOut sock)
  in
  "Command Sent"
  end

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
end;

end

