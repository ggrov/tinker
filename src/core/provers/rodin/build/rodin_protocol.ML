

structure SimpleNamer = 
struct
  val name_count : (int Unsynchronized.ref) = Unsynchronized.ref 0
  fun nameAfter pn =
    if pn>0 then
    let val i = (!name_count) + 1
        val _ = name_count:= i
        val node=(Int.toString pn, "G"^(Int.toString i)) in
           nameAfter (pn-1) @ [node]
    end
    else []
  fun init () =
             name_count:=0; 
end

structure Rodin : TPP_PROTOCOL=
struct
  open RJP RodinSock RodinHelper SimpleNamer

  type arg = string
  type typ = string
  type term = string 
  type thm = string
  type context= string
  type tactic = {tac_name : string, tac_type : string}

  (* arguments for atomic goal types and tactics *)
  type arg_data =  string * string

  datatype env_data = 
    E_Str of string | 
    E_Trm of term | 
    E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  type env = env_data StrName.NTab.T 
  type env_tac =  env -> env 

  type pnode =  string
   type pplan = string

  val prover_name = "RodinProver"

  fun typ_of _ = "any"
  
  fun match  context (term1, term2)  = match0  context term1 term2
  
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


    
 (*  arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
  *)


  fun apply args tactic pnode = 
  let
      val {tac_name, tac_type} = tactic
      val reply=execute ("APPLY_TACTIC",[("TACTIC",tac_name),("NODE",pnode), ("TYPE",tac_type)] @ args);
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
                      raise error (String.concat["Cannot Apply this Tactic: ",tac_name, " ERROR: ", getParam reply "ERROR_INFO"]))
                 | str =>  
                    (RodinSock.send (toJson ("DISSCONNECT_WITH_ERROR",[("ERROR",str)]));  
                     RodinSock.disconnect();
                    raise error (String.concat["Cannot Apply this Tactic: ",tac_name," with instruction:", str]))
  in
      new_nodes 
  end;

  fun apply_tactic args tactic pnode = 
  let  val c_args =args in
(*     if isExternalTac(tactic) then
      let
          val (new_args, tac, pnode)=(externalTac c_args tactic pnode) 
      in 
       apply new_args tac pnode 
      end
    else *)
      apply c_args tactic pnode 
  end
end
