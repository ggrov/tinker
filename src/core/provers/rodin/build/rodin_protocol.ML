structure RodinHelper =
struct
  open RodinSock RJP
  fun toInt str= Option.getOpt (Int.fromString str, 0)

  fun execute command = 
    let val jstr= toJson command
        val reply= send jstr |> receive
    in
      RJP.fromJson reply
    end

  fun isExternalTac tactic = case tactic of 
  "SELECT_HYP_AND_INSTAN" => true
  | _ => false

  fun externalTac args tactic pnode = (["args"], "tactic", pnode)

end

structure SimpleNamer = 
struct
  val name_count : (int Unsynchronized.ref) = Unsynchronized.ref 0
  fun nameAfter pn =
    if pn>0 then
    let val i = (!name_count) + 1
        val _ = name_count:= i
        val node=(Int.toString pn, "G"^(Int.toString i)) in
          node:: nameAfter (pn-1)
    end
    else []
  fun init () =
             name_count:=0; 
end

structure Rodin : TPP_PROTOCOL=
struct
  open RJP RodinSock RodinHelper SimpleNamer

  type thm = string
  type term = string
  type arg = string
  type arg_data = string

  type context= string
  type pplan = string
  type typ = string
  type tactic = string

  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  type env = env_data StrName.NTab.T 
  type env_tac =  env -> env 

  type pnode =  string
  
  val prover_name = "Rodin"

  fun typ_of _ = "any"
  
 
    
  fun match context (term1, term2) = 
  let val reply = execute ("MATCH_TERMS",[("TERM1",term1),("TERM2",term2),("CONTEXT",context)])
      val result= getParam reply "RESULT"
  in
    case result of "true" => true
                | "false"=> false
                | other => raise error ("Matching term error: "^other)
  end


  fun get_all_open_nodes pplan  = 
   let
       val cmd= execute  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]);
       val next = case getInstruction cmd of
                "NEED_NAMING" =>  
                     let val num=toInt(getParam cmd "NUM")
                         val reply =execute ("NAME_OPEN_NODES", nameAfter num )
                     in
                      reply
                     end
                | "NAMES" => cmd
                | _ =>  
                    (RodinSock.send (toJson ("DISSCONNECT_WITH_ERROR",[("ERROR","Wrong Command")]));  
                     RodinSock.disconnect();
                     error "Wrong Command")

       val nodes = getParamValues next
    in  
        nodes
    end;

  fun initialise () =
    let val init_node = List.hd (get_all_open_nodes "")
    in

        init_node
    end;


  fun apply args tactic pnode = 
  let 
      val reply=execute ("APPLY_TACTIC",[("TACTIC",tactic),("NODE",pnode)]);
      val new_nodes = case getInstruction reply of 
                  "NODE_CLOSED" =>[]
                   (*  let val reply= (Rodin.execute  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]));
                    in
                      Rodin.getParamValues reply
                    end  *)
                 | "NEED_NAMING" => 
                   let val num=toInt(getParam reply "NUM");
                       val reply =(execute ("NAME_OPEN_NODES", nameAfter num ))
                   in
                       getParamValues reply
                   end
                 | "ERROR" =>
                    (RodinSock.send (toJson ("DISSCONNECT_WITH_ERROR",[("ERROR", getParam reply "ERROR_INFO")]));  
                     RodinSock.disconnect();
                      raise error (String.concat["Cannot Apply this Tactic: ",tactic, " ERROR: ", getParam reply "ERROR_INFO"]))
                 | str =>  
                    (RodinSock.send (toJson ("DISSCONNECT_WITH_ERROR",[("ERROR",str)]));  
                     RodinSock.disconnect();
                    raise error (String.concat["Cannot Apply this Tactic: ",tactic," with instruction:", str]))
  in
      new_nodes 
  end;

  fun apply_tactic args tactic pnode = 
    if isExternalTac(tactic) then
      let val (new_args, tac, pnode)=(externalTac args tactic pnode) 
      in 
       apply new_args tac pnode 
      end
    else
      apply args tactic pnode 
  
end
