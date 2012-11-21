theory socket_test  
imports
  "../build/Graph"       
begin

(*
1. Look at http://www.standardml.org/Basis/posix-file-sys.html#SIG:POSIX_FILE_SYS.mkfifo:VAL for making a UNIX named pipe
2. Open the pipe using TextIO, and pass it to Protocol_Interface.run_in_textstreams (in core/interface/protocol.ML) - this may need to be in a separate thread
3. Run the GUI - something like "java quanto.gui.QuantoApp --core-socket=/path/to/fifo" (you can add the --core-socket argument in the debug/run configuration in Eclipse)
*)
ML{*
 val pmode = Posix.FileSys.S.irwxu;
 Posix.FileSys.mkfifo ("/Users/ggrov/fifdotest",pmode); 
*}

(*
ML{*
TextIO.openIn "/Users/ggrov/fifdotest";
TextIO.openOut "/Users/ggrov/fifdotest";
*}
*)

ML{*
ProtocolInterface.run_in_textstreams;
open Future;

*}

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


