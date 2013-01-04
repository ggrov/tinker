theory socket_test  
imports
  "../build/Eval"    
uses
  "../interface/gui_socket.ML"            
begin  

ML{*
GUI_Socket.run ();         
*}
(*
-- "socket to interface" 

ML{*
Byte.stringToBytes #> (fn msg => Word8VectorSlice.slice (msg,1,NONE));
*}

ML{*
fun mkServerSocket () =
    let
      val server = INetSock.TCP.socket();
      val _ = Socket.bind(server, INetSock.any 4444);
      val _ = Socket.Ctl.setREUSEADDR(server,true);
      val saddr = INetSock.fromAddr(Socket.Ctl.getSockName server);
      val _ = Socket.listen(server,128);
    in 
     (saddr,server) 
    end;

fun readLoop active_socket =
    let
      val s = Byte.bytesToString(Socket.recvVec(active_socket,80));
      val _ = writeln s; (* print to output *)
    in
      (writeln "about to read...\n"; readLoop active_socket)
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
*)
ML{*
val msg = "hello world from tcpserver\n";
val buf = {buf = Byte.stringToBytes msg, i = 0, sz = NONE};
val x : Word8VectorSlice.slice = buf;
*}
ML{*
open
Word8VectorSlice
*}

ML{*
Word8Vector.fromList;
Socket.sendVec
*}


ML{*
val listener = INetSock.TCP.socket();
val (conn, conn_addr) = Socket.accept listener;

*}


ML{*
fun serve port =
let
    fun run listener =
    let
        fun accept() =
        let
            val (conn, conn_addr) = Socket.accept listener
        in
respond conn;
accept() end
and respond conn =
let
            val msg = "hello world from tcpserver\n"
            val buf = {buf = Byte.stringToBytes msg,
                       i = 0, sz = NONE}
        in
            (Socket.sendVec(conn, buf));
            Socket.close conn
        end
        handle x => (Socket.close conn; raise x)
    in
        Socket.Ctl.setREUSEADDR(listener, true);
        Socket.bind(listener, INetSock.any port);
        Socket.listen(listener, 9);
        accept()
end
    handle x => (Socket.close listener; raise x)
in
    run (INetSock.TCP.socket())
end
handle OS.SysErr (msg, _) => raise Fail (msg ^ "\n")

*}


ML{*
val localhost =  the (NetHostDB.fromString "127.0.0.1");
val addr = INetSock.toAddr(localhost, 4321)
val sock = INetSock.TCP.socket();


val msg = "hello world from tcpserver\n";
val buf = {buf = Byte.stringToBytes msg, i = 0, sz = NONE};

Socket.recvVec;
Socket.sendVec;


(* Socket.close sock; *)
Socket.connect(sock, addr);

*}

ML{*
open TextIO
*}

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


