theory io_test
imports Main
begin


ML{*
fun sendVec0 sock char_slice = 
  let
    (* char slice to byte slice *)
    val (str, i, sz) = CharVectorSlice.base char_slice;
    val byte_slice = Word8VectorSlice.slice (Byte.stringToBytes str, i ,SOME sz)
  in
    Socket.sendVec(sock, byte_slice)
  end

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

fun make_streams sock =
  let
    val bufsize = (*Unsynchronized.ref*) 4096;
    val buffering = IO.BLOCK_BUF;
    val socket_name = "psgraph_gui_socket";
    val reader = TextPrimIO.RD {
      name      = "psgraph_gui_socket",
      chunkSize = bufsize,
      readVec   =  SOME (fn vec => Byte.bytesToString(Socket.recvVec(sock, vec))),
      readArr   =  NONE,
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
      writeVec   = NONE (*SOME(sendVec0 sock)*) (* don't think it's used anywhere*),                    
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
*}

ML{*
(* STEP 1: setup a passive socket server *)
fun init_server_socket port =
  let
    val sock = INetSock.TCP.socket ();
    val _ = Socket.Ctl.setREUSEADDR (sock, true);
    val addr = INetSock.any port;
    val _ = Socket.bind (sock, addr); 
    val _ = Socket.listen (sock, 5);
  in sock end;

*}

ML{*
Socket.bind;
Socket.Ctl.setREUSEADDR;
fun server_print str = writeln str;

fun test str = 
  case str of "abc" => 1
    | "bbc" => 2
    | _ => 3;

test "bbc";
*}
ML{*
(* receive and send string with socket *)

(* STEP 2: accept a income connection to make it acitve *)

fun server_main port = 
  let (* demo here only receive then send them back *)
    val sock = init_server_socket port;
    val (active_socket, _) = Socket.accept sock;
    val (input,output) = make_streams active_socket;
    fun receive () = TextIO.input input;
    fun send str = (TextIO.output (output, str); TextIO.flushOut output);
    fun close () = 
      (TextIO.closeOut output handle _ => warning ("can't close output stream");
       TextIO.closeIn input handle _ => warning ("can't close input stream");
       Socket.close active_socket handle _ => warning ("can't close active socket");
       Socket.close sock handle _ => warning ("can't close passive socket"));
    fun loop () = 
      let 
        val msg = receive();
        fun handler msg = 
          case msg of "CMD_CLOSE\n" => close()
            | _ => (send ("Server return: " ^ msg); loop())
        fun msg_analysis str = 
          server_print("Received: " ^ str ^ 
            " Size: " ^  Int.toString (String.size str))
      in
        msg_analysis msg ; handler msg
      end
  in
    loop ()
  end
*}

ML{* -
server_main 4442;
*}


(* some useful pre-trying *)
ML{*
val char_arr = CharArray.fromList [#"a", #"b", #"c", #"d", #"e"];
Char.ord;
Word8.fromInt;

fun arrayToList0 l idx char_arr =
  if idx < CharArray.length char_arr
  then arrayToList0 ((CharArray.sub(char_arr, idx)) :: l) (idx + 1) char_arr
  else (rev l);
val arrayToList = arrayToList0 [] 0;


Socket.sendArr;
type writeArr = CharArraySlice.slice;

*}


end
