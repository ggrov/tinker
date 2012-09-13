theory socket_test 
imports
  Main      
begin


ML{*
INetSock.TCP.socket();
Socket.accept;
*}
ML{*
fun mkServerSocket () =
    let
      val server = INetSock.TCP.socket();
      val _ = Socket.bind(server, INetSock.any 8080);
      val _ = Socket.Ctl.setREUSEADDR(server,true);
      val saddr = INetSock.fromAddr(Socket.Ctl.getSockName server);
      val _ = Socket.listen(server,128);
    in (saddr,server) end;

fun readLoop active_socket =
    let
      val s = Byte.bytesToString(Socket.recvVec(active_socket,80));
      val _ = PolyML.print s; (* print to output *)
    in
      (PolyML.print "about to read...\n"; readLoop active_socket)
    end;

fun main() =
    let
      val (saddr, server_socket) = mkServerSocket ()
      val (active_socket, active_socket_addr) =
          Socket.accept server_socket
    in
      readLoop active_socket
    end;
*}


end;


