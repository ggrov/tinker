(* for communication with a GUI *)
structure GUI_Socket =
struct
  datatype cmd = CMD_EXIT | CMD_NEXT | CMD_BACK | CMD_PPLAN | CMD_GRAPH 
               | CMD_INVALID (* error case *); 
  val PORT = 4444;
  
  fun get_cmd 0 = CMD_EXIT
   |  get_cmd 1 = CMD_NEXT
   |  get_cmd 2 = CMD_BACK
   |  get_cmd 3 = CMD_PPLAN
   |  get_cmd 4 = CMD_GRAPH
   |  get_cmd _ = CMD_INVALID;

  fun mkServerSocket () =
    let
      val server = INetSock.TCP.socket();
      val _ = Socket.bind(server, INetSock.any PORT);
      val _ = Socket.Ctl.setREUSEADDR(server,true);
      val saddr = INetSock.fromAddr(Socket.Ctl.getSockName server);
      val _ = Socket.listen(server,128);
  in 
     saddr 
  end;

  val connect = Socket.accept #> snd;

  fun close_socket socket = Socket.close(active_socket);

  val mk_message = 
    Byte.stringToBytes 
    #> (fn vec => Word8VectorSlice.slice (vec,1,NONE));

  fun send_msg sock msg = 
    Socket.sendVec(sock, mk_message msg) |> ignore;

  fun send_graph socket = 
    send_msg socket "this is the graph";

  fun mainLoop edata active_socket =
    let
      val _ = writeln "wating for input...";
      val s = Byte.bytesToString(Socket.recvVec(active_socket,80));
      val _ = writeln s; (* print to output *)
      val cmd = (case Int.fromString s of
                NONE => raise exception
              | SOME n => get_cmd n)
      fun apply_cmd CMD_EXIT = (close_socket(active_socket); edata)
       |  apply_cmd CMD_NEXT = (mainLoop (edata_next edata) active_socket);
       |  apply_cmd CMD_BACK = (mainLoop (edata_back edata) active_socket); 
       |  apply_cmd CMD_PPLAN = (send_pplan edata socket; mainLoop active_socket);
       |  apply_cmd CMD_GRAPH = (send_graph edata socket; mainLoop active_socket); 
       |  apply_cmd CMD_INVALID = 
    in
      apply_cmd cmd
    end;

   
end;
