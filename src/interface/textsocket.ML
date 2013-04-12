signature TEXT_SOCKET =
sig
  type T
  val local_connect : int -> T (* connects to port *)
  val write : T -> string -> unit (* write to stream *)
  val read : T -> string (* read from stream *)
  val close : T -> unit (* close stream *)
end (* signature *)

structure TextSocket : TEXT_SOCKET =
struct

 datatype T = SockData of { 
   sock : Socket.active INetSock.stream_sock,
   passive : Socket.passive INetSock.stream_sock,
   sin : TextIO.instream,
   sout : TextIO.outstream
 }

 fun make_streams sock =
  let
   val slice_conv = CharVectorSlice.vector #> Byte.stringToBytes #> Word8VectorSlice.full;
    val (haddr, port) = INetSock.fromAddr (Socket.Ctl.getSockName sock);
    val sock_name =
      implode [ NetHostDB.toString haddr, ":", string_of_int port ];
    val rd =
      TextPrimIO.RD {
        name = sock_name,
        chunkSize = Socket.Ctl.getRCVBUF sock,
        readVec = SOME (fn sz => Byte.bytesToString (Socket.recvVec (sock, sz))),
        readArr = NONE, (* FIXME: (TextPrimIO.array_slice -> int) option -- (fn buffer => Socket.recvArr (sock, buffer)) *)
        readVecNB = NONE,
        readArrNB = NONE,
        block = NONE,
        canInput = NONE,
        avail = fn () => NONE,
        getPos = NONE,
        setPos = NONE,
        endPos = NONE,
        verifyPos = NONE,
        close = fn () => Socket.close sock,
        ioDesc = NONE
      };
    val wr =
      TextPrimIO.WR {
        name = sock_name,
        chunkSize = Socket.Ctl.getSNDBUF sock,
        writeVec = SOME (fn buffer => Socket.sendVec (sock, slice_conv buffer)), 
        writeArr = NONE, (* FIXME : (fn buffer => Socket.sendArr (sock, buffer))  *)
        writeVecNB = NONE,
        writeArrNB = NONE,
        block = NONE,
        canOutput = NONE,
        getPos = NONE,
        setPos = NONE,
        endPos = NONE,
        verifyPos = NONE,
        close = fn () => Socket.close sock,
        ioDesc = NONE
      };
    val in_strm =
      TextIO.mkInstream (
        TextIO.StreamIO.mkInstream (rd, ""));
    val out_strm =
      TextIO.mkOutstream (
        TextIO.StreamIO.mkOutstream (wr, IO.BLOCK_BUF))
  in
    (in_strm,out_strm)
  end;

 fun init_server_socket opt_host port =
  let
    val sock = INetSock.TCP.socket ();
    val addr =
      (case opt_host of
         NONE => INetSock.any port
       | SOME host =>
           NetHostDB.getByName host
           |> the
           |> NetHostDB.addr
           |> rpair port
           |> INetSock.toAddr
           handle Option => raise Fail ("Cannot resolve hostname: " ^ host));
    val _ = Socket.bind (sock, addr);
    val _ = Socket.listen (sock, 5);
  in sock end;

 fun local_connect port =
  let  
   val passive_sock = init_server_socket (SOME "localhost") port;
   val (sock, _)= Socket.accept passive_sock;
   val (sin, sout) = make_streams sock;
  in
   SockData { sock = sock, passive = passive_sock, sin = sin, sout = sout }
  end;

 fun write (SockData data) msg = TextIO.output (#sout data,msg);
 fun read (SockData data) = TextIO.input (#sin data);

 fun close (SockData data) =
      (TextIO.closeOut (#sout data) handle e => ();
      TextIO.closeIn (#sin data) handle e => ();
      Socket.close (#sock data) handle e => ();
      Socket.close (#passive data) handle _ => ());
end (* struct *)
