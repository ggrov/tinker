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

  fun match0 context term1 term2 = 
  let val reply = execute ("MATCH_TERMS",[("TERM1",term1),("TERM2",term2),("CONTEXT",context)])
      val result= getParam reply "RESULT"
  in
    case result of "true" => true
                | "false"=> false
                | other => raise error ("Matching term error: "^other)
  end 

  fun get_pnode_goal_tag pnode_name =
    let val reply=(execute  ("GET_PNODE_GOAL_TAG",[("NODE",pnode_name)]));
      in toInt (getParam reply "TAG")
    end


  fun get_goal_term pnode =
    let val reply= execute ("GET_GOAL_TERM",[("NODE",pnode)])
    in 
      getParam reply "TERM"
    end

  fun isExternalTac tactic = case tactic of 
  "APPLY_ON_GOAL" => true
  |  "APPLY_ON_HYP" => true
  | _ => false

  structure hypUtil =
  struct
    type pnode= string
    type hyp=string
    type symbol = string

    fun get_top_symbol term p = 
      let val reply=execute ("GET_TOP_SYMBOL",[("NODE",p),("TERM",term)])
      in
        getParam reply "SYMBOL"
      end;
  
    fun top_symbol_is context symb =
      let val reply= execute ("TOP_SYMBOL_IS", [("CONTEXT",context),("SYMBOL",symb)])
      in
          case getParam reply "RESULT" of "true" => true | _ => false
      end;
  
    fun get_hyps pnode =
      let val reply=execute ("GET_HYPS",[("NODE",pnode)])
      in
        getParamValues reply
      end

     fun get_symbols hyp node =
     let val reply= execute ("GET_SYMBOLS", [("NODE",node),("HYP",hyp)])
      in
          getParamValues reply
      end;
  end


  fun apply_on_hyp (args: string list) pnode = raise error "TODO"

  fun apply_on_goal (args: string list) pnode =
  let val tac_infos=(args)
      val tac_name=List.hd tac_infos
      val tac_param=List.hd(List.tl tac_infos) (* Second element is the parameter *)

      (* tactic conditions *)
      val new_args=[("REALTAC",tac_name), ("PARAM",tac_param)]
   in
    (new_args,"ON_GOAL",pnode)
   end

  fun externalTac  (args:string list) tactic pnode = 
  case tactic of "APPLY_ON_HYP" => apply_on_hyp args pnode
               | "APPLY_ON_GOAL"=> apply_on_goal args pnode
  | str => raise error ("SOME TACTIC "^ str ^" UNKNOWN")

end
