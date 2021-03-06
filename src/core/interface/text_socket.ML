signature TEXT_SOCKET =
sig
  type T
  val local_server : int -> T (* setup a serve to port *)
  val local_client : int -> T (* setup a client to port *)
  val write : T -> string -> unit (* write to stream, but yet to be flushout *)
  val flushOut: T -> unit (* flush to the other end *)
  val read : T -> string (* read from stream *)
  val close : T -> unit (* close stream *)

  val safe_local_server : int -> T (* connects to port *)
  val safe_local_client: int -> T
  val safe_close : unit -> unit

  val get_instream : T -> TextIO.instream
  val get_outstream : T -> TextIO.outstream
  val get_io_stream : T -> TextIO.instream * TextIO.outstream
  val get_socket : T -> Socket.active INetSock.stream_sock
  
  val get_current_instream : unit -> TextIO.instream option
  val get_current_outstream : unit -> TextIO.outstream option
  val get_current_stream : unit -> (TextIO.instream * TextIO.outstream) option
  val get_current_socket : unit -> Socket.active INetSock.stream_sock option
end
 
functor TextSocket_FUN  (structure Prover : PROVER) : TEXT_SOCKET =
struct
  structure Prover = Prover
(* this func ensures computation without interruption,
  a way to prevernt isabelle from interrupt a thread, *)
  fun run_in_atomic func = 
   let
    val m = Mutex.mutex ();   
    val attr = Thread.getAttributes () ;     
   in 
    (Thread.setAttributes 
      [Thread.EnableBroadcastInterrupt false, 
       Thread.InterruptState Thread.InterruptDefer];
    Mutex.lock m;  
    func ())
    |> (fn x => (Mutex.unlock m ; x))
    |> (fn x => (Thread.setAttributes attr; x))
   end

  (* debugging, can be turned off or on *)
  fun server_print str = ()(*writeln str*);

  datatype T = SockData of { 
   sock : Socket.active INetSock.stream_sock,
   passive : Socket.passive INetSock.stream_sock option,
   sin : TextIO.instream,
   sout : TextIO.outstream}

  fun get_instream (SockData rep) = #sin rep;
  fun get_outstream (SockData rep) = #sout rep;
  fun get_io_stream (SockData rep) = (#sin rep, #sout rep);
  fun get_socket (SockData rep) = #sock rep;
  fun get_passive (SockData rep) = #passive rep;
  
  (* export elements of array to a list *)
  fun arrayToList0 l idx char_arr =
    if idx < CharArray.length char_arr
    then arrayToList0 ((CharArray.sub(char_arr, idx)) :: l) (idx + 1) char_arr
    else (rev l);
  val arrayToList = arrayToList0 [] 0;
  
  (* in WR: send vector *)
  fun sendVec0 sock char_slice = 
    let
      (* char slice to byte slice *)
      val (str, i, sz) = CharVectorSlice.base char_slice;
      val byte_slice = Word8VectorSlice.slice (Byte.stringToBytes str, i ,SOME sz)
    in
      Socket.sendVec(sock, byte_slice)
    end
  
  (* in WR: send array *)
  fun sendArr0 sock char_slice = 
    let
      (* char slice to byte slice *)
      val (char_array, i, sz) = CharArraySlice.base char_slice;
      val word_array = 
        arrayToList char_array 
        |> map Char.ord 
        |> map Word8.fromInt
        |> Word8Array.fromList;
      val byte_slice = Word8ArraySlice.slice ( word_array, i ,SOME sz)
    in
      Socket.sendArr(sock, byte_slice)
    end
  
  (* with given sock, init TEXT_IO stream for input and output *)
  fun make_streams sock =
    let
      val bufsize = (*Unsynchronized.ref*) (*1024*64*) 4096;
      val buffering = IO.BLOCK_BUF;
      val socket_name = "text_socket";
      val reader = TextPrimIO.RD {
        name      = "text_socket",
        chunkSize = bufsize,
        readVec   =  SOME (fn vec => Byte.bytesToString(Socket.recvVec(sock, vec))),
        readArr   =  NONE, (* would this be a problem ??*)
        readVecNB = NONE,
        readArrNB = NONE,                          
        block     = NONE,
        canInput  = NONE,
        avail     = fn() => NONE,
        getPos    = NONE,
        setPos    = NONE,
        endPos    = NONE,
        verifyPos = NONE,
        close     = (fn () => Socket.close sock),
        ioDesc    = NONE };
  
      val writer = TextPrimIO.WR {
        name       = socket_name,
        chunkSize  = bufsize,
        writeVec   = SOME(sendVec0 sock) (* don't think it's used anywhere*),                    
        writeArr   = SOME (sendArr0 sock),
        writeVecNB = NONE,
        writeArrNB = NONE,
        block      = NONE,
        canOutput  = NONE,
        getPos     = NONE,
        setPos     = NONE,
        endPos     = NONE,
        verifyPos  = NONE,
        close      = fn () => Socket.close sock,
        ioDesc     = NONE };
      val input = TextIO.mkInstream(TextIO.StreamIO.mkInstream(reader, ""));
      val output = TextIO.mkOutstream(TextIO.StreamIO.mkOutstream(writer, buffering));
    in
      (input, output)
    end

(* setup a passive socket server *)
  fun init_socket0 port _ =
    let
      val sock = INetSock.TCP.socket ();
      val _ = Socket.Ctl.setREUSEADDR (sock, true);
      val addr = INetSock.any port;
      val _ = Socket.bind (sock, addr); 
      val _ = Socket.listen (sock, 5);
    in sock end;

  fun init_socket port = run_in_atomic (init_socket0 port)

  fun local_client0 port _  =
    let
      val localhost =
        NetHostDB.getByName "localhost" 
        |> Option.valOf |>  NetHostDB.addr;
      val addr = INetSock.toAddr(localhost, port)
      val sock = INetSock.TCP.socket()
      (*val _ = Socket.Ctl.setREUSEADDR (sock, true);*)
      (*val _ = Socket.bind (sock, addr); *)
      val _ = Socket.connect(sock, addr)
      val (sin, sout) = make_streams sock;
    in
      SockData { sock = sock, passive = NONE (*dummy*),
                sin = sin, sout = sout} end
   (*handle OS.SysErr (msg, _) => raise RunCallFail (msg ^ "\n")*)
 
  fun local_client port =
    run_in_atomic (local_client0 port)

  fun local_server0 port _ =
   let  
    val passive_sock = init_socket0 port ();
    val (sock, _) = Socket.accept passive_sock;
    val (sin, sout) = make_streams sock;
   in
    SockData { sock =  sock, passive = SOME passive_sock, sin =  sin, sout =  sout }
   end

  fun local_server port  = run_in_atomic (local_server0 port)

  fun write s_data msg = TextIO.output (get_outstream s_data, Prover.encoding_to_gui msg);
  fun flushOut s_data = TextIO.flushOut (get_outstream s_data);

  fun read s_data = TextIO.input (get_instream s_data) |> Prover.encoding_from_gui;

  fun close0 s_data _ =
    (TextIO.closeOut (get_outstream s_data) handle _ => warning ("can't close output stream");
    TextIO.closeIn (get_instream s_data) handle _ => warning ("can't close input stream");
    Socket.close (get_socket s_data) handle _ => warning ("can't close active socket");
    case (get_passive s_data) 
      of NONE => ()
      | SOME passive => (Socket.close passive
          handle _ =>  warning ("can't close passive socket")));

  fun close s_data = 
    run_in_atomic (close0 s_data)  

  val current_sock : (T option) Synchronized.var = Synchronized.var "current socket" NONE;

  val socket_tracing = K;

  fun clear_current_sock0 _ =
    let
      val _ = socket_tracing "clear current sock"
    in 
      (case Synchronized.value current_sock 
        of NONE => ()
        | SOME s_data =>
          close0 s_data ());
      Synchronized.change current_sock (fn _ => NONE)
    end
  handle _ =>  
    (Synchronized.change current_sock 
      (fn _ => NONE) ;
    LoggingHandler.logging "SOCKET" "Faile to clear up last socket ")

  fun clear_current_sock _ = run_in_atomic  clear_current_sock0

  exception exp_text_socket of string

  fun get_current_instream _ = 
    Synchronized.value current_sock 
    |> Option.valOf
    |> get_instream
    |> SOME
  handle _ => NONE

  fun get_current_outstream  _ = 
    Synchronized.value current_sock 
    |> Option.valOf
    |> get_outstream
    |> SOME
  handle _ => NONE

  fun get_current_stream _ = 
    Synchronized.value current_sock 
    |> Option.valOf
    |> get_io_stream
    |> SOME
  handle _ => NONE

  fun get_current_socket  _ =
    Synchronized.value current_sock 
    |> Option.valOf
    |> get_socket
    |> SOME
  handle _ => NONE

(*  
  fun safe_close0 data  _ = 
    let val _ = socket_tracing "cleaning by it self" in
    (close0 data ();
     Synchronized.change 
      current_sock 
      (fn _ => NONE)) end
  fun safe_close0 data = run_in_atomic (safe_close data)
*)
  val safe_close =  clear_current_sock

(* safe client always try to reuse the current connection *)
  fun safe_local_client port = 
    let 
      val _ = socket_tracing "start safe client"
      (* get the synchornised sock *)
      fun obtain_new_socket  _ = 
        let 
          val new_socket = local_client0 port () 
          val sin'=  get_instream new_socket 
          val sout' =  get_outstream new_socket
          val sock' =  get_socket new_socket
        in
         ((Synchronized.change current_sock 
           (fn _ => 
              SockData {sock = sock', passive = NONE (*dummy*), sin = sin', sout = sout' } |> SOME ));
              (SockData {sock = sock', passive = NONE (*dummy*), sin = sin', sout = sout' }))
         end
    in
      case Synchronized.value current_sock
      (* exists a current connecntion, just return the current one*)
        of (SOME s_data) => s_data
      (* does not exist, create one *)
        | NONE => (run_in_atomic obtain_new_socket)
    end

(* safe server always clear the current connection *)
  fun safe_local_server0 port _ = 
    let  
      val _ = clear_current_sock0 ();
      val _ = socket_tracing "start safe server"
      val passive_sock = init_socket0 port ();
      (* a time out is working here *)
      val sock0 = 
        let 
          val timer = Timer.startRealTimer ()
          fun accept_until_timeout t = 
            if  (Timer.checkRealTimer timer|> Time.toSeconds) > t (* time out *)
            then raise exp_text_socket "time out for socket: no incoming connection"
            else 
              (case Socket.acceptNB passive_sock 
                of SOME ret => fst ret
                | _ => accept_until_timeout t)             
        in
          accept_until_timeout 8 (* timeout for 8 s *)
        end
      val (sin0, sout0) = make_streams sock0;
      val _ =  
        Synchronized.change    
          current_sock 
          (fn _ =>
            SockData {sock = sock0, passive = SOME passive_sock, sin = sin0, sout = sout0} |> SOME)
    in
      SockData { sock = sock0, passive = SOME passive_sock, sin = sin0, sout = sout0}
    end  
  handle exp_text_socket msg => (clear_current_sock0 () ; raise exp_text_socket msg) (* timeout , stop trying *)
        | _                  => (clear_current_sock0 () ;raise exp_text_socket "socket in use")
 
  fun safe_local_server port = run_in_atomic (safe_local_server0 port)
    
  
   
end (* struct *)

