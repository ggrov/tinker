theory socket_communication_gui
imports Main
begin
ML_file "../debug_handler.ML"
ML_file "../interface/text_socket.ML"

ML{*
 datatype State = Idle | Connected | Proving | Drawing | Failure;
 datatype C = ConnectData of {
  state : State,
  socket : Socket.active INetSock.stream_sock,
  sin : TextIO.instream,
  sout: TextIO.outstream
 }

 
 Synchronized.change sock (fn _ => Proving);

 fun connect() =
  let
    val localhost =
      NetHostDB.getByName "localhost" 
      |> Option.valOf |>  NetHostDB.addr
    val addr = INetSock.toAddr(localhost, 1790)
    val sock = INetSock.TCP.socket()
    val _ = Socket.connect(sock, addr)
    val (sin, sout) = make_streams sock;
  in
    ConnectData { state = Connected, sock = sock, sin = sin, sout = sout }
  end
 handle OS.SysErr (msg, _) => raise Fail (msg ^ "\n")
*}  
(*
init connection -- create client socket on port 1790 and try to connect with server
  |--- when connection made listen

listen -- wait for message from server
  |--- when message receive read

read -- reading a message string from socket
  |--- when full message execute command
  |--- when command fullfilled send eventual response
  |--- listen
  
send -- sending things to gui through socket

disconnect -- close sockets
  |--- better to send "CLOSE_CONNECT" message ?
  |--- re-run init connection ?
end*)

end
