structure RodinProver  : PROVER = 
struct
  exception gterm_exp

  (* Third Party Prover *)
  open RodinHelper;
  structure tpp = Rodin

  type term = string
  type typ = string

  type thm = string
  type context = string

  type tactic = tpp.tactic

  type pplan = tpp.pplan (* be the latest name of pnode *)
  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
 
  
 datatype env_data = 
    E_Str of string | 
    E_Trm of term |
    E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  type env = env_data StrName.NTab.T 
  type env_tac =  env -> env 
  type pnode = { pname : string, env : env } 

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq  

  exception env_data_exp

  val this_name=tpp.prover_name;
  val default_ctxt = this_name^" ctxt"
  val exec_str = eval_text;


  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = this_name^".EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = this_name^".Tac_ML_Exec");

  fun match context  (ta ,tb) = (tpp.match context (ta,tb))    (*TODO : context -> (term * term) -> bool *)

  
  fun get_thm_by_name _ thm = thm
  fun concl_of_thm  _ ="term" (* TODO: thm -> term *)
  fun asms_of_thm  _ = ["term","list"] (*: TODO:  thm -> term list ? *)

  
  fun get_open_pnodes pplan = 
  let
     val nodes = tpp.get_all_open_nodes pplan
  in  
      map (fn x=> {pname = x, env = StrName.NTab.empty }) nodes  
  end;

  fun arg_data_to_string arg = case arg of 
    A_Const str => str 
  | A_Var str => str
  | A_Trm str => str
  | A_Thm str => str
  | A_Str str =>str

  fun args_convert (args:arg_data list)  = 
  let
       val strlist= map arg_data_to_string args
  in strlist end;

  fun apply_tactic args tactic ({pname, env}:pnode, pplan) = 
  let 
      val new_nodes= tpp.apply_tactic (args_convert args) tactic pname
  in
     Seq.single (map (fn x=> {pname = x, env = env}) new_nodes ,pplan)
  end;



  fun apply_env_tactic _ _ (pnode, pname)= Seq.single ([pnode], pname);

  fun get_pnode_name pnode = #pname pnode;
  fun get_pnode_env ({env, ...} : pnode) = env;
  fun get_pnode_env_data pnode name = get_pnode_env pnode |> ( fn x => StrName.NTab.get x name)
  fun get_pnode_env_data_as_ML pnode name = 
    case get_pnode_env_data pnode name of (E_ML ml_code) => ml_code
    | _ => raise env_data_exp 

  fun get_pnode_concl {pname:string, env=_} =  (* return type concl which would be type term*)
      let val r=  get_goal_term pname ;
      in 
        r
      end


  fun get_pnode_hyps  {pname:string, env=_}  = hypUtil.get_hyps pname (*Dummy *)
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
  val pretty_goal = pretty_pnode

(* TODO :*)
  fun typ_of term =tpp.typ_of term
   (*  let val reply=Rodin.execute ("GET_PNODE_GOAL_TYPE",[("TERM",term)]);
        val typ=Rodin.getParam reply "TYPE";
    in
      typ
    end; *)

  fun  init _  _ _=  
    let val init_node=tpp.initialise()
    in
       ({pname=init_node,env=StrName.NTab.empty}, init_node)
    end;

  fun get_goal_thm pplan = raise Fail "TODO"; 
  val prop_of_string = trm_of_string
  fun pretty_env _ _ = Pretty.str "dummy" 
  fun pretty_env_data _ _ = Pretty.str "dummy"
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


