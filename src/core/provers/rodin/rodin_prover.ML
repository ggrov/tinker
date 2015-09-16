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

  type tactic = string

  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
 
  
 datatype env_data = 
    E_Str of string | 
    E_Trm of term |
    E_Thm of thm |
    E_ML of string | 
    E_L of env_data list

  type env = env_data StrName.NTab.T 


  type pnode = { pname : string, env : env } 
  type pplan = {name: tpp.pplan, env: env } (* be the latest name of pnode *)

  type env_tac = arg_data list -> env -> env list
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
     val name= #name pplan
     val nodes = tpp.get_all_open_nodes name
  in  
      map (fn x=> {pname = x, env = ( (#env pplan) ) }) nodes  
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

  

  fun int_list i = 
    if i>0 then (int_list (i-1)) @ [i] else []

  fun add_index_to_args args=
  let val l=List.length args
      val indices=int_list l                             
      val result = map (fn x => List.nth (args, x-1) |> (fn b => (Int.toString x,b))) indices
  in
    result
  end

  fun apply_tactic args tactic ({pname, env}:pnode, pplan) = 
  let 
      val (real_args, realtactic, tac_type) = case tactic of 
      "on_goal" => ((args_convert args |> List.tl  |> add_index_to_args), args_convert args |> List.hd, "ON_GOAL")
      |"auto_tactic" => ([] ,args_convert args |> List.hd, "AUTO_TACTIC")
      |"on_hyp" => ([("HYP","FIRST")], args_convert args |> List.hd , "ON_HYP")
      |"autoprove" => ([],"autoProver", "AUTO_TACTIC")
      | _ => raise error "unknown tac"
     val rodin_tac= {tac_name = realtactic, tac_type= tac_type}
     val _ = writeln ("APPLY TAC ON : "^pname )
      val new_nodes= tpp.apply_tactic real_args rodin_tac pname
  in
     Seq.single (map (fn x=> {pname = x, env = env}) new_nodes ,pplan)
  end;

  fun update_pnode_env f ({env, pname} : pnode) = {pname = pname, env = f env};

  fun get_open_pnode_by_name pplan name = {pname = name , env = #env pplan}(*  {pname=(#name pplan),env= (#env pplan) } *)
  fun set_pnode_pplan pnode pplan = 
    (writeln ("USE set_pnode_pplan : " ^ (#pname pnode)) ;pplan)

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

  val set_pnode_env = update_pnode_env o K;

  val trm_of_string = K I;
  val string_of_trm = K I;
  val encode_unicode = I;
  val decode_unicode = I;
  fun pretty_pplan pplan = Pretty.str (#name pplan);
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
       ({pname=init_node,env=StrName.NTab.empty}, {name=init_node, env = StrName.NTab.empty} )
    end;

  fun apply_env_tactic args envtac (pnode, pplan) = raise Fail "unsuppported env tac" 
  fun subst_trm_vars x y = raise Fail "unsuppported env tac"
(*   let val {pname , env} = pnode 
      val new_env=  envtac args env pname
  in 
    Seq.single ([{pname=pname, env=new_env}], pplan)
  end
 *)

  fun get_goal_thm pplan = "dummy"; 
  val prop_of_string = trm_of_string
  fun pretty_env _ _ = Pretty.str "dummy" 
  fun pretty_env_data _ _ = Pretty.str "dummy"
  fun antiquto_handler _ _ = "dummy"
  fun parse_env_data _ _  = raise Fail "not supported env data parsing"
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


