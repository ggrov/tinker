(* for communication with a GUI *)
structure GUISocket =
struct

val connected = Synchronized.var "connected" false;

fun try_connect true = (false,true)
 |  try_connect false = (true,true);

exception guisocket_exp of string;


(* copied from Isabelle repo: Socket_Util *)

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

fun make_streams sock =
  let
    val (haddr, port) = INetSock.fromAddr (Socket.Ctl.getSockName sock);
    val sock_name =
      implode [ NetHostDB.toString haddr, ":", string_of_int port ];
    val rd = (* TextPrimIO *)
      BinPrimIO.RD {
        name = sock_name,
        chunkSize = Socket.Ctl.getRCVBUF sock,
        readVec = SOME (fn sz => Socket.recvVec (sock, sz)), (* convert *)
        readArr = SOME (fn buffer => Socket.recvArr (sock, buffer)),
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
    val wr = (* TextPrimIO *)
      BinPrimIO.WR {
        name = sock_name,
        chunkSize = Socket.Ctl.getSNDBUF sock,
        writeVec = SOME (fn buffer => Socket.sendVec (sock, buffer)), (* decode *)
        writeArr = SOME (fn buffer => Socket.sendArr (sock, buffer)),
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
      BinIO.mkInstream ( (* "" *)
        BinIO.StreamIO.mkInstream (rd, Word8Vector.fromList []));
    val out_strm =
      BinIO.mkOutstream (
        BinIO.StreamIO.mkOutstream (wr, IO.BLOCK_BUF));
    in 
      (in_strm, out_strm) 
    end;

  fun print_cmd 0 = tracing "exit"
   |  print_cmd 1 = tracing "next"
   |  print_cmd 2 = tracing "back"
   |  print_cmd 3 = tracing "pplan"
   |  print_cmd 4 = tracing "graph"
   |  print_cmd n = tracing ("Invalid option: " ^ (Int.toString n))

  exception guisocket_exp of string;

  fun get_cmd s = 
     (case Int.fromString s of
        NONE => raise guisocket_exp ("not valid command: " ^ s)
      | SOME n => n)

  fun get_dot_str edata =
     Print_Mode.setmp [] (fn () => 
      Strategy_Dot.output false (RTechnEval.EData.get_graph edata |> Strategy_Theory.Graph.minimise)) 
      ();

  fun get_pplan_str edata =
     Print_Mode.setmp [] (fn () => 
      edata |> RTechnEval.EData.get_pplan |> PPlan.pretty |> Pretty.string_of)
      ();

  fun run' edata0 =
   let
     val passive_sock = init_server_socket (SOME "localhost") 4444;
     val (sock, _)= Socket.accept passive_sock;
     val (sin, sout) = make_streams sock;
     fun send' msg = (BinIO.output (sout, Byte.stringToBytes msg); BinIO.flushOut sout; tracing "message written...");
     fun send msg = send' (msg ^ "\n ENDMSG\n") 
     fun receive () = (BinIO.input sin) 
                     |> Byte.bytesToString 
                     |> get_cmd;
     fun close () = 
           ( BinIO.closeOut sout handle e => warning ("cannot close");
             BinIO.closeIn sin handle e => warning ("cannot close");
             Socket.close sock handle e => warning ("cannot close");
             Socket.close passive_sock handle _ => warning ("error closing");
             Synchronized.change connected (K false));
     fun loop (edatas as (edata :: rest)) =
       let
         fun apply_cmd 0 = (close (); edata)
          |  apply_cmd 1 = (* next *)
              (case RTechnEval.eval_any edata |> Seq.list_of of
                 [] => (send "FAIL : not possible to make step";loop edatas)
               | xs => (send "OK"; loop (xs @ rest))) (* keep rest? keep last? *)
          |  apply_cmd 2 =  (* back *)
               ( case rest of 
                   [] => (send "FAIL : no more data"; loop edatas)
                 | _ => (send "OK"; loop rest))
          |  apply_cmd 3 = (send (get_pplan_str edata); loop edatas) (* pplan *)
          |  apply_cmd 4 = (send (get_dot_str edata); loop edatas) (* graph *)
          |  apply_cmd _ = (tracing "error option"; close (); raise guisocket_exp ("not valid cmd option"))  
         val receive = receive();
       in
          (print_cmd receive; apply_cmd receive)
       end
   in
      loop [edata0] handle e => (tracing "exception "; close(); raise e)
   end

 fun run edata = run' edata;
(*
   if Synchronized.change_result connected try_connect
    then run' edata
    else raise guisocket_exp "already connected to GUI";
*)
end;
