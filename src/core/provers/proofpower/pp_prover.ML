structure PPProver : PROVER =
struct
  local open LoggingHandler (*ProverUtils*) in 
  type pos = PPTermLib.pos
  type typ = TYPE
  type term = TERM
  type thm = THM
  type context = string list * string (* context string list * theory string *)
  
  val default_ctxt = get_current_pc (); (* used in those place need context in general *)

    
  fun pretty_trm _ trm = String.concat (PrettyPrinter.format_term true trm) |> Pretty.str

  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
  
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list

  fun pretty_env_data _ (E_Str str) =  [ "E_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Trm trm) = [ "E_Trm(", pretty_trm ctxt trm |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Thm thm) =  [ "E_Thm(", concl thm |> pretty_trm ctxt |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_ML str) =  [ "E_ML(",  str,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_L l) =  
        Pretty.str (String.concat [ "E_L(",
                      str_chunks (map (Pretty.string_of o pretty_env_data ctxt) l),
                       ")"]);

  type env = env_data StrName.NTab.T
  
  
  fun pretty_env ctxt env = 
    let fun pretty_pair (n, env_data) = String.concat [n, ": ", pretty_env_data ctxt env_data |> Pretty.string_of] in
    StrName.NTab.list_of env
    |> map pretty_pair
    |> (fn xs => str_chunks (( "ENV_DATA: [" :: xs) @ [ "]"]) )
    |> Pretty.str
    end
  
  type tactic = arg_data list -> TACTIC (* TODO: need pc ? *)
  type env_tac = arg_data list -> env -> env list
  
  (* atomic part *)
  type pnode = 
      {pname : string (* goal ref in psg *), 
       g: GOAL (* ([ams], concl ) *), 
       pctxt : context,
       global : string list (* referece used in subgoal system in pp, it's defnied as string list, but only the first one is used *),
       env : env} 
  
  (* TODO: maybe to add a table to store some meta info, e.g. hints? measures? *)
  type pplan = 
      {opengs : pnode StrName.NTab.T, 
      usedgs : StrName.NSet.T}
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq (* in pp, tactic is deteminted, seq is always singleton *)
   
  (* get_current_pc () open_theory, set_pc *)
  
   
  exception env_data_exp
  val exec_str = use_string;

  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = "PPProver.EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = "PPProver.Tac_ML_Exec");

  exception gterm_exp
  
  val typ_of = type_of
  fun match _ = (op ~=$) 

  val eq_pos = PPTermLib.eq_pos
    
  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
  val root_of_trm = PPTermLib.root_of_trm
  val subtrm_of_pos = PPTermLib.subtrm_of_pos
  val trm_of_pos = PPTermLib.trm_of_pos
  
  val concl_of_thm = concl
  val asms_of_thm =  asms
  (* get asm of thm - asms*)
  fun trm_of_string _ = mk_string 
  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm |> String.concat


  fun get_all_assms (pnode : pnode)  = (#g pnode) 
  			      |> fst (* a list of term *)
  			      |> map asm_rule (* to thm type *)			      
  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_concl (pnode:pnode) = (#g pnode) |> snd;
  fun get_pnode_hyps (pnode:pnode) = (#g pnode) |> fst;
  fun get_pnode_ctxt (pnode:pnode) = (#pctxt pnode) ;
  fun get_open_pnodes (pplan:pplan) = StrName.NTab.list_of (#opengs pplan) |> map snd (* should return some goals as top_goals () *)
  fun get_open_pnode_by_name (pplan : pplan) name = StrName.NTab.get (#opengs pplan) name

  fun set_open_goals_pplan (pplan : pplan) ogs  = {opengs = ogs, usedgs = #usedgs pplan}
  fun set_pnode_pplan pnode (pplan : pplan) = 
   let
    val _ = get_open_pnode_by_name pplan (get_pnode_name pnode)
   in
    (#opengs pplan)
    |> StrName.NTab.update (get_pnode_name pnode, pnode)
    |> set_open_goals_pplan pplan
   end
   handle StrName.Tab.UNDEF n => 
   (logging "FAILURE" ("Can not find the pnode of open goal for " ^ n ^ " to update") ;
    raise tinker_fail true)


  fun get_pnode_env (pnode:pnode) = #env pnode;
  fun update_pnode_env f {pname,g,pctxt,global,env}  = 
    {pname = pname, g = g, pctxt = pctxt, global = global, env = f env};
  val set_pnode_env = update_pnode_env o K;
  fun get_pnode_env_data pnode name = get_pnode_env pnode |> ( fn x => StrName.NTab.get x name)
  fun get_pnode_env_data_as_ML pnode name = 
    case get_pnode_env_data pnode name of (E_ML ml_code) => ml_code
    | _ => raise env_data_exp 
    
  structure THM_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = thm val struct_name = "PPProver.THM_ML_Exec");
  fun get_thm_by_name _ str = THM_ML_Exec.eval_ml str
  
  exception atomic_exp of string
  val psgraph_prover_i = "proofpower";
  (* there is no interface to init a pnode and pplan ?*)
  (* if paralle evalation then it would be problematic*)
  
  fun init ctxt asms_trms concl_trm : (pnode * pplan) =
    let
      val (pcs, thy) = ctxt
      val _ = (set_merge_pcs pcs; set_goal (asms_trms, concl_trm)); (* setup goal *)
      val goal = top_goal ();
      val ctxt' = get_current_pc();
      val name = StrName.NSet.new StrName.NSet.empty "g"
      val pnode = {pname = name, g = goal,  pctxt = ctxt', global = [], env = StrName.NTab.empty};
      val pplan = {opengs = StrName.NTab.of_list [((#pname pnode), pnode)],
      			 usedgs = StrName.NSet.add name StrName.NSet.empty}
    in
      (pnode, pplan)
    end;
      
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  fun update  (tac : TACTIC) (env_tac : env -> env list) (pnode : pnode, pplan : pplan)  : (pnode list * pplan) list = 
    let 
      fun gen_fresh_psgname nset (g : (string list * GOAL)) = 
        if (fst g) = [""] (* the case of single goal *)
        then 
          (StrName.NSet.new nset "g",  g) (* following this convesion to gen nwe goal name *)
        else
          (hd (fst g), g) (* otherwise, use the name from pp *)
      (*val _ = writeln ("called set label on pname "  ^ (#pname pnode))*) 
      (*val _ = Pretty.writeln  (Pretty.chunks (map Pretty.str ((#global pnode))))*)
      (* set current goal and apply tactic then get the list of goals in the format of :
      	string list * (term list * term) list *)
      val sgs = (((if (#global pnode) = [] then () else set_labelled_goal (hd (#global pnode)));
      		SubgoalPackage.apply_tactic tac); top_goals())
      val ctxt = get_current_pc();   
      fun filter_goals plist name = 
        filter 
        (fn (x : pnode) => 
          (case String.compare ((#pname x), name) of EQUAL => false 
          | _ => true))
        plist
      fun gen_pnode (name, g) = ({pname = name, pctxt = ctxt, g = snd g, global = fst g, env = get_pnode_env pnode});
    in
      if (List.length sgs) = 0 (* no sgs *) 
      then 
        [([], {opengs = StrName.NTab.empty, usedgs = (#usedgs pplan)})]
      else((* a list of sgs *)
        let
          val sgs' = map (gen_fresh_psgname (#usedgs pplan)) sgs 
          val all_pnodel = map gen_pnode sgs' (* all open subgoals *)
          (* filter out new goals *)
          val new_pnodel_l = 
            List.foldr
            (fn (n, pns) =>
                filter 
                (fn x => (case String.compare ((#pname x), n) 
                    of EQUAL => false 
                    | _ => true))
                pns)
                  all_pnodel
            (StrName.NSet.list_of (#usedgs pplan))
            |> (fn [x] => (map (fn y => [set_pnode_env y x]) (env_tac (get_pnode_env x))) (* either the case of env updat or the single node *)
                | xs => [xs] ) (* if mul pnodes, no need to update env *)
            (* update env from the consumed one:
            this will be a g list list, -> branch of goal list*)
         fun mk_new_opengs new_pnodel =  (* del old consumed goal then add new goals *)
          (#opengs pplan)
          |> StrName.NTab.delete (#pname pnode)
          |> (fn n => List.foldr (fn (x,y) => StrName.NTab.ins ((#pname x), x) y) n new_pnodel)
         fun mk_new_pplan new_pnodel = 
          {opengs = mk_new_opengs new_pnodel, (* get all current sgs name *)
           usedgs = StrName.NSet.add_list (map fst sgs') (#usedgs pplan)}
        (*val _ = [Pretty.str "new sg list: ["] @ (map (Pretty.str o get_pnode_name) new_pnodel) @ [Pretty.str "]"] 
          	   |> Pretty.chunks |> Pretty.writeln
         val _ = [Pretty.str "new opengs status: ["] @ (StrName.NTab.keys new_opengs|> map Pretty.str)@ [Pretty.str "]"]
	           |> Pretty.chunks |> Pretty.writeln*)
     in
	    map (fn npl => (npl, mk_new_pplan npl)) new_pnodel_l  
	   end 
	  )
   end
    

  fun apply_tactic args tac (pnode,pplan) = 
    (*let val (tac : tactic)  = build_tac_code_with_arg tac_code args |> Tac_ML_Exec.eval_ml in*)
    update (tac args) (fn x => [x]) (pnode,pplan)
    (*|> (fn (l,p) => ((get_open_pnodes p |> map pretty_pnode |> Pretty.chunks |> Pretty.writeln) ; (l,p)))*)
    |> Seq.of_list 
    handle BasicError.Fail msg => 
      (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ BasicError.get_message msg); 
               raise tinker_fail false) ;
    (*end*)

  (* Update the env and then apply a dummy id tac in isabelle *)
  fun apply_env_tactic args env_tac (pnode,pplan) = 
    (*let val (env_tac : env_tac)  = build_tac_code_with_arg env_tac_code args |> EnvTac_ML_Exec.eval_ml in*)
    update (id_tac) (env_tac args) (pnode,pplan)
    (*|> (fn (l,p) => ((get_open_pnodes p |> map pretty_pnode |> Pretty.chunks |> Pretty.writeln) ; (l,p)))*)
    |> Seq.of_list
    handle BasicError.Fail msg => 
      (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ BasicError.get_message msg); 
               raise tinker_fail false) ;
    (*end*)  
  
    fun pretty_pnode pnode = 
    String.concat
    ["[ Goal ", 
    (get_pnode_name pnode),
    " : ",
    pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode) |> Pretty.string_of,
    " ]"] |> Pretty.str;

  fun pretty_goal pnode = pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode)
  fun pretty_pplan pnode = Pretty.str "Pretty PPLAN TOTO";
  
(*  
  val encode_gui_to_prover = implode o map unicode_to_pp o utf8_string_to_unicode;
  fun encode_prover_to_gui str =
   (set_flag ("output_in_utf8", true);
    ReaderWriter.translate_for_output str)
   |> (fn x => (set_flag ("output_in_utf8", false); x));
*)   

  val encode_prover_to_gui = I;
  val encode_gui_to_prover = I;
  fun get_goal_thm pplan = raise RunCall.Fail "TODO"; 
  

  structure Sharing = 
  struct   
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
    type env_data = env_data
    type env_tac = env_tac
  end (* end of local open *) end
end
