structure RodinSock : WSOCK =
struct
  open LoggingHandler
  type socket = TextSocket.T
  val default_port = 1991;
  exception Rodin_cancellation

  val sock : (socket option) Synchronized.var = Synchronized.var "rodin socket" NONE;
  (* val sock : (socket option) Unsynchronized.ref = Unsynchronized.ref NONE  *)

  fun connect () =
    let val ins = TextSocket.local_client default_port
        (* val _ = TextSocket.write ins "TINKER_HAND_SHAKE\n"
        val _ = TextSocket.flushOut ins *)
    in 
       (* sock := SOME ins; *)
       Synchronized.change sock (fn _ => ins |> SOME);
       ins 
    end
   handle IO.Io _ => 
  (Synchronized.change sock (fn _ => NONE); 
    TextSocket.safe_close();
    PolyML.print "ERROR Io";
    connect()) 

  fun getInstance() = case Synchronized.value sock of  SOME ins  => ins | NONE => connect () 

  fun send str = 
  let val ins=getInstance()
      val _ = TextSocket.write ins (str^"\n")
      val _ = TextSocket.flushOut ins
      val _ =logging "RODIN" ("SEND:"^str)
  in 
    ()
  end   handle IO.Io  {name = _, function = _, cause = exn} => 
  case exn of IO.ClosedStream =>
  (TextSocket.close (getInstance()); 
   Synchronized.change sock (fn _ => NONE); 
(*    connect ();
   send str *)
   raise exn
   ) 
  |  OS.SysErr (a(* "Broken pipe" *),b) => 
  (  TextSocket.close (getInstance()); 
    Synchronized.change sock (fn _ => NONE); 
   (* raise OS.SysErr(a,b)) *)
   (* connect ();
   send str *)
   raise exn
   ) 
  | _ => raise exn  
  
  fun receive() = 
  let val str=TextSocket.read (getInstance())
      val  _ = logging "RODIN" ("RECEIVE:"^str)
    in
      if str="RODIN_CANCEL" then
        raise Rodin_cancellation
      else
        str
  end


  fun disconnect() = case Synchronized.value sock of  
                      SOME ins  =>  (TextSocket.close ins;
                                    Synchronized.change sock (fn _ => NONE);
                                     LoggingHandler.logging "RODIN" ("DISCONNECTED");
                                    "Disconnected")
                     |NONE => "Already Disconnected"


end
