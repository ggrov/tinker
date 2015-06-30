signature RODIN =
sig
    type connection
    type command
    type commandsimple

    type param
    type params
    exception rodin_error of string
    exception unhandled_type of string
    exception connection_close of string


    val buildCommand : string -> params -> command
    
    val close : string -> string
    val getCmdName : command -> string
    val getParam : command -> string -> string
    val getParamKeys : command -> string list

    val getParamValues : command -> string list


    val toJsonStr : commandsimple -> string

(*     val fromRodin : connection -> command
    val toRodin : commandsimple -> connection *)
    val execute : commandsimple -> command

end                                                                                          

structure Rodin : RODIN= 
struct 
  open JsonInputUtils  rodin_socket IO
  type connection = TextSocket.T

  type param = (string * string) (* only consider string for now*)
  type params = param list
  type command = Json.jobj
  type commandsimple = (string * params)

  exception rodin_error of string
  exception unhandled_type of string
  exception connection_close of string

  fun connect port = connectRodin port


  fun getInstance port = 
  let 
       val result=connect port;
  in result 
  end
  handle ec "TINKER_HAND_SHAKE" =>  raise ec "HAND_SHAKE_FAILED"    (* connect port *)

  fun instance _ = getInstance 1991 

  fun sendstr rodin str = 
  let 
    val _  =rodin_socket.send rodin str
  in
    rodin
  end
  
  fun cmd_end rodin =
  let 
  val _ =(sendstr rodin "COMMAND_END");
  val _ =(TextSocket.close rodin) 
  in
  "Command Finished."
  end

  fun close _ =
  let 
  val ins=instance "";
  val _ =(sendstr ins "TINKER_DISCONNECT");
  val _ =(TextSocket.close ins) 
  in
  "Disconnected."
  end

  fun receivestr rodin =
  let val result=read rodin
  in
    if result="CONNECTION_CLOSE" then
      let val _ = close rodin in
      raise connection_close("closed")
      end
    else if result="ERROR" then
      raise rodin_error("Rodin error")
    else
      result
  end;

  fun getCmdName cmd = get_string cmd "CMD"
  fun getParams cmd = Json.Object( get_obj cmd "PARAMS" )

 
  fun getParamKeys cmd = 
  let val params=case  getParams cmd of  Json.Object p => p | _ => raise unhandled_type "Only handle string";
       val r= Json.properties params
    in
    r
    end;

  fun getParam cmd key = 
    let  open JsonInputUtils;
          val params= getParams cmd;
         val param= case params of Json.Object params => get params key
                                                                             | _ => raise bad_input_exp (key^" key is not found","");
         val value=case param of Json.String v => v     | _ => raise unhandled_type "Only handle string"
         in
         UnicodeHelper.replaceEUC value
    end

  fun getParamValues cmd = map (getParam cmd) (getParamKeys cmd) 

  fun build_jsonParams_from_params ((key, value)::xs) = 
      let val objval=  Json.String (UnicodeHelper.replaceUC value)
      in
      (key,  objval) :: build_jsonParams_from_params xs 
      end
  |  build_jsonParams_from_params [] = []


  fun buildCommand str rawparams = 
    let val Json.Object r=Json.mk_object [("CMD", (Json.String str)),
                                          ("PARAMS",  Json.mk_object (build_jsonParams_from_params rawparams))] 
    in r end
  
  fun toJsonStr (str, rawparams) =
    let 
        val json_params=  build_jsonParams_from_params rawparams
    in
        Json.encode (Json.mk_object [("CMD", (Json.String str)), ("PARAMS",  Json.mk_object json_params )])
    end

  fun fromRodin ins = 
    let
        val str= receivestr ins;
        val result= case Json.of_string str of  Json.Object obj =>  obj 
                                                           | _ => raise unhandled_type "Wrong input";
        val _ = cmd_end ins
        in 
        result
    end

  fun toRodin cmdsimp = 
  let val ins=instance "SEND" ;
      val _ = sendstr ins (toJsonStr cmdsimp)
  in
      ins
  end;

  fun execute cmdsimp=
  let val ins=toRodin cmdsimp;
      val reply=fromRodin ins;
  in 
    reply
  end;

end
