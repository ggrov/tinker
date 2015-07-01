structure RodinProver  : PROVER = 
struct
  exception gterm_exp
  type typ = string                                            
  type term = string
  type thm = string
  type context = string

  type tactic = string

  type pplan = string (* be the latest name of pnode *)

  type arg_data = string (* A_Const of string | A_Var of string | A_Trm of term *)
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  type env = env_data StrName.NTab.T 
  type env_tac =  env -> env 
  type pnode = { pname : string, env : env } 

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq  

  exception env_data_exp

  val default_ctxt = "Rodin ctxt"
  val exec_str = eval_text;
  val this_name="RodinProver";

  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = this_name^".EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = this_name^".Tac_ML_Exec");

  fun match context  (ta ,tb) = true    (*TODO : context -> (term * term) -> bool *)
  fun concl_of_thm  thm ="term" (* TODO: thm -> term *)
  fun asms_of_thm  thm = ["term","list"] (*: TODO:  thm -> term list ? *)

  fun toInt str= Option.getOpt (Int.fromString str, 0)

  fun nameAfter i prefix pn =
    if pn>0 then
    (Int.toString i, prefix^"G"^(Int.toString pn)) :: nameAfter (i+1) prefix (pn-1) 
    else []
  
 fun get_open_pnodes pplan = 
 let
     val cmd= (Rodin.execute  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]));
     val next = case Rodin.getCmdName cmd of
              "NEED_NAMING" =>  
                   let val num=toInt(Rodin.getParam cmd "NUM")
                       val prefix=Rodin.getParam cmd "PARENT";
                       val reply =(Rodin.execute ("NAME_OPEN_NODES", nameAfter 1 prefix num ))
                   in
                    reply
                   end
              | "NAMES" => cmd
              | _ => raise error "Wrong command"
     val nodes = Rodin.getParamValues next
  in  
      map (fn x=> {pname = x, env = StrName.NTab.empty }) nodes  
  end;

  fun apply_tactic args tactic ({pname, env}:pnode, pplan) = 
  let 
      val reply=Rodin.execute ("APPLY_TACTIC",[("TACTIC",tactic),("NODE",pname)]);
      val new_nodes = case Rodin.getCmdName reply of 
                  "NODE_CLOSED" =>[]
                   (*  let val reply= (Rodin.execute  ("GET_ALL_OPEN_NODES",[("PPLAN",pplan)]));
                    in
                      Rodin.getParamValues reply
                    end *)
                 | "NEED_NAMING" => 
                   let val num=toInt(Rodin.getParam reply "NUM");
                       val prefix=Rodin.getParam reply "PARENT";
                       val reply =(Rodin.execute ("NAME_OPEN_NODES", nameAfter 1 prefix num ))
                   in
                       Rodin.getParamValues reply
                   end
                 | "ERROR" => raise error (String.concat["Cannot Apply this Tactic: ",tactic, " ERROR: ", Rodin.getParam reply "ERROR_INFO"])
                 | _ => raise error (String.concat["Cannot Apply this Tactic: ",tactic])
  in
     Seq.single (map (fn x=> {pname = x, env = env}) new_nodes ,pplan)
  end;

  fun apply_env_tactic args env_tac (pnode, pname)= Seq.single ([pnode], pname);
 
  fun get_open_pnodes_num _  =
  let
      val cmd=(Rodin.execute ("GET_OPEN_DESCENDANTS_NUM",[])) ;
      val num=Rodin.getParam cmd "NUM"
  in
       Option.getOpt (Int.fromString num, 0)
  end;


  fun get_pnode_name pnode = #pname pnode;
  fun get_pnode_env ({env, ...} : pnode) = env;
  fun get_pnode_env_data pnode name = get_pnode_env pnode |> ( fn x => StrName.NTab.get x name)
  fun get_pnode_env_data_as_ML pnode name = 
    case get_pnode_env_data pnode name of (E_ML ml_code) => ml_code
    | _ => raise env_data_exp 

  fun get_pnode_concl pn =	"conclude"  (* return type concl which would be type term*)

  fun get_pnode_hyps  pn  =	["hyps"] (*Dummy *)

  val get_pnode_ctxt = get_pnode_name

  fun update_pnode_env f ({env, pname} : pnode) = {pname = pname, env = f env};
  val set_pnode_env = update_pnode_env o K;

  val trm_of_string = K I;
  val string_of_trm = K I;
  val encode_gui_to_prover = I;
  val encode_prover_to_gui = I;
  val pretty_pplan = Pretty.str;
  val pretty_pnode = Pretty.str o get_pnode_name;
  val pretty_trm = K Pretty.str


(* TODO :*)
  fun typ_of term = "any"
   (*  let val reply=Rodin.execute ("GET_PNODE_GOAL_TYPE",[("TERM",term)]);
        val typ=Rodin.getParam reply "TYPE";
    in
      typ
    end; *)

  fun  init _  _ _=  
let val {pname = init_node, env=_} = List.hd (get_open_pnodes "")
in
   ({pname=init_node,env=StrName.NTab.empty}, init_node)
end
 
  structure Sharing = 
  struct
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type env_data = env_data
    type env_tac = env_tac
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
  end

 
end


