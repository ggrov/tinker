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


(*   fun sub_terms term pnode =
    let val reply= execute ("SUB_TERMS",[("TERM",term),("NODE",pnode)]);
    in 
      getParamValues reply
    end
 *)
  fun get_goal_term pnode =
    let val reply= execute ("GET_GOAL_TERM",[("NODE",pnode)])
    in 
      getParam reply "TERM"
    end

(* 
(* function test if s_term is in term, returns boolean *)
  fun has_sub_term pnode s_term term  =
    let (* val _ = raise error ("has sub term : "^ s_term ^","^ term) *)
        val t= case s_term of "GOAL" => get_goal_term pnode | _ =>s_term
        val subterms=sub_terms term pnode
     in List.exists (match0 pnode t) subterms end
 *)
  fun isExternalTac tactic = case tactic of 
  "APPLY_ON_GOAL" => true
  |  "APPLY_ON_HYP" => true
  | _ => false

(*   (* Given a list of hypothesis, a proof node, and a function of boolean *)
  fun select_hyps_with_function (hyp::hyps) pnode f=(
      (* raise error ("select_hyps_with_function : hyp="^ hyp ^" in node="^ pnode); *)
     case f hyp of true => hyp :: select_hyps_with_function hyps pnode f
                    | _ => select_hyps_with_function hyps pnode f)
   | select_hyps_with_function [] _ _ = []

  fun select_hyps (condition::conds) hyps pnode =
  (let val condname=List.hd condition
      val condval= List.hd(List.tl condition)
     
      val s_hyps=
        case condname of 
          "SUBTERM" => select_hyps_with_function hyps pnode (has_sub_term pnode condval)
         |"TOP_SYMB" => select_hyps_with_function hyps pnode (top_symbol_is condval)
         | _ => []
  in   writeln (String.concat s_hyps) ; select_hyps conds s_hyps pnode end)
  | select_hyps [] hyps _ = hyps *)
  
(* 
  fun apply_on_hyp (args: string  list) pnode =
  let val tac_infos=(List.hd args)
      val tac_name=List.hd tac_infos
      val tac_param=List.hd(List.tl tac_infos) (* Second element is the parameter *)

      (* tactic conditions *)
      val conditions=List.tl args(* Second list of the args list *)
      val hyps= get_hyps pnode; 
      
      val hyp= List.hd (select_hyps conditions hyps pnode)

      val new_args=[tac_name, hyp, tac_param]
   in
    (new_args,"ON_HYP",pnode)
   end *)
  structure hypUtil : hypQueryTPInterface =
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

  structure hypQuery : HYPQUERY =
  struct
    structure parser = hypQueryParser
    structure interface = hypUtil
    open parser
    type AST = parser.AST
    type pnode = string
    fun parse str = parser.parse str
    
    fun evalAND a b = if a andalso b then true else false
    fun evalOR a b = if a orelse b then true else false
    fun evalNOT a = if a then false else true

    fun getTag (parser.node (tag, _)) =tag
    fun getChildren (node (_,c)) = c


    fun getProp c = if List.length c > 1 then SOME (List.nth (c,1)) else NONE
    fun evalHAS pnode hyp ast = 
    let val c = (getChildren ast)
        val node (STR symb, _) = List.hd c
        val prop =getProp c
        val symbs = interface.get_symbols hyp pnode
    in
      case prop of 
        SOME subtree =>
          (case getTag subtree of 
            BEFORE => raise error "todo"
          )
        |NONE => 
          exists (fn x => x=symb) symbs
      
    end

    fun evaMATCH pnode hyp ast =  raise error "todo"
    fun evalIS pnode hyp ast =  raise error "todo"
    fun evalWITH pnode hyp ast =  raise error "todo"
    

    fun evalCondition pnode hyp (ast:AST) = 
    case getTag ast of
      HAS => evalHAS  pnode hyp ast
    | MATCH =>  evaMATCH  pnode hyp ast
    | IS =>  evalIS  pnode hyp ast
    | WITH =>  evalWITH  pnode hyp ast
    | _ => raise error "Unexpected TAG."


    fun evalConditions pnode hyp (ast:AST)   = 
      let open parser
          val (node (tag, children))=ast 
      in
            case tag of 
              AND => evalAND (List.hd children |> evalConditions hyp pnode) (List.nth (children,1) |> evalConditions hyp pnode)
            | OR => evalOR  (List.hd children |> evalConditions hyp pnode) (List.nth (children,1) |> evalConditions hyp pnode)
            | NOT => evalNOT (List.hd children |> evalConditions hyp pnode)
            | _ => evalCondition pnode hyp ast
      end
    
    
    fun evalTactic ast = 
      let open parser
          val node (tag, children) = ast 
           fun toString (x::xs) = x^(case xs of [] => "" | _ => ","^(toString xs))
      in
        (parser.tokenToLex tag, (map getTag children |> map tokenToLex |> toString) )
      end

    fun evalQuery ast pnode =
    let val (parser.node (_, children)) = ast 
        val (tac_name, tac_params) = evalTactic (List.hd children)
        val ast_cond = List.nth (children,1)
        val hyps = interface.get_hyps pnode
        val selected_hyp = List.find (fn hyp=>evalConditions pnode hyp ast_cond) hyps
    in
     case selected_hyp of SOME h =>
      (tac_name, tac_params, h)
      | NONE => raise error "NO HYP APPLICABLE"
    end

  end

  fun apply_on_hyp (args: string list) pnode = 
     let val query=List.hd args
         val ast =hypQuery.parse query
         val (tac_name, tac_params, hyp) = hypQuery.evalQuery ast pnode
         val new_args = [("REALTAC",tac_name), ("PARAM",tac_params),("HYP", hyp)]
     in
         (new_args,"ON_HYP",pnode)
     end

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

  type arg = string
  type typ = string
  type term = string 
  type thm = string
  type context= string
  type tactic = string

  (* arguments for atomic goal types and tactics *)
  type arg_data =  string

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

  val prover_name = "Rodin"

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
      val reply=execute ("APPLY_TACTIC",[("TACTIC",tactic),("NODE",pnode)] @ args);
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

  fun apply_tactic (args:string list) tactic pnode = 
  let  val c_args =args in
    if isExternalTac(tactic) then
      let
          val (new_args, tac, pnode)=(externalTac c_args tactic pnode) 
      in 
       apply new_args tac pnode 
      end
    else
      apply [] tactic pnode 
  end
end
