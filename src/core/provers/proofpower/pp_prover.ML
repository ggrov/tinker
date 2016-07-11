(*TODO: add goal_state in pplan, top_goal_state to save it, drop_main_goal (); push_goal_state to load it when backtracking *)
(* goal_state, theory_name, pc *)

structure PPProver (*: PROVER *) (* has to be commented out, as Term_ML_exec need to be accessible *) =
struct
  local open LoggingHandler (*ProverUtils*) in 
  type pos = PPTermLib.pos
  type typ = TYPE
  type term = TERM
  type thm = THM
  type context = string list * string (* context string list * theory string *)
  
  val default_ctxt = get_current_pc (); (* used in those place need context in general *)
  
  val symbol_table = [("%and%", "&"), ("%implies%", "==>")] |> StrName.NTab.of_list;
  fun decode_str c = case StrName.NTab.lookup (symbol_table) (String.str c) 
    of (SOME str') => str'
      | NONE => (String.str c);
    
   
  fun pretty_trm _ trm = 
   String.concat (PrettyPrinter.format_term true trm) 
   |> String.translate decode_str 
   |> Pretty.str

  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string 
| A_L_Thm of thm list | A_L_Trm of term list | A_L of arg_data list | A_Conv of term -> thm
| A_CConv1 of (term -> thm) -> (term -> thm)
  
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_Conv of term -> thm |
    E_CConv1 of (term -> thm) -> (term -> thm) |
    E_L of env_data list


  fun pretty_env_data _ (E_Str str) =  [ "E_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Trm trm) = [ "E_Trm(", pretty_trm ctxt trm |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Thm thm) =  [ "E_Thm(", concl thm |> pretty_trm ctxt |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_ML str) = [ "E_ML(",  str,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_Conv c) = [ "E_Conv(",  "Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_CConv1 cc) = [ "E_CConv1(",  "Conv -> Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_L l) =  
        Pretty.str (String.concat [ "E_L(",
                      str_chunks (map (Pretty.string_of o pretty_env_data ctxt) l),
                       ")"]);

  fun pretty_arg_data _ (A_Str str) =  [ "A_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_Trm trm) = [ "A_Trm(", pretty_trm ctxt trm |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_Thm thm) =  [ "A_Thm(", concl thm |> pretty_trm ctxt |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L_Trm trm_l) = [ "A_L_Trm("] @ (map (fn trm => pretty_trm ctxt trm |> Pretty.string_of |> (fn x => x ^ " | ")) trm_l) @ [")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L_Thm thm_l) =  [ "A_L_Thm("]@ (map (fn thm => concl thm |> pretty_trm ctxt |> Pretty.string_of |> (fn x => x ^ " | ")) thm_l) @ [")"] |> String.concat |> Pretty.str
  |   pretty_arg_data _ (A_Conv c) = [ "A_Conv(",  "Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data _ (A_CConv1 cc) = [ "A_CConv1(",  "Conv -> Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L l) =  
        Pretty.str (String.concat [ "A_L(",
                      str_chunks (map (Pretty.string_of o pretty_arg_data ctxt) l),
                       ")"]);

  fun env_to_arg (E_Str str) = A_Str str
  |   env_to_arg (E_Trm trm) = A_Trm trm
  |   env_to_arg (E_Thm thm) = A_Thm thm
  |   env_to_arg (E_Conv c)   = A_Conv c
  |   env_to_arg (E_CConv1 cc) = A_CConv1 cc
  |   env_to_arg (E_L data) = A_L (map env_to_arg data)
  |   env_to_arg env = (logging "FAILURE" ("Do not suppport the conversion from env to arg: " ^ (pretty_env_data default_ctxt env|> Pretty.string_of)) ;
      raise tinker_fail true)

  fun arg_to_env (A_Str str) = E_Str str
  |   arg_to_env (A_Trm trm) = E_Trm trm
  |   arg_to_env (A_Thm thm) = E_Thm thm
  |   arg_to_env (A_L_Trm trm_l) = map E_Trm trm_l |> E_L
  |   arg_to_env (A_L_Thm thm_l) = map E_Thm thm_l |> E_L
  |   arg_to_env (A_Conv c)   = E_Conv c
  |   arg_to_env (A_CConv1 cc) = E_CConv1 cc
  |   arg_to_env (A_L data) = E_L (map arg_to_env data)
  |   arg_to_env env = (logging "FAILURE" ("Do not suppport the conversion from arg to env: " ^ (pretty_arg_data default_ctxt env|> Pretty.string_of)) ;
      raise tinker_fail true)

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
  fun id_env_tac _ env = [env] 
  fun id_env_tac_f env : env_tac= (fn args => fn _ => id_env_tac args env)
  (* atomic part *)
  type pnode = 
      {pname : string (* goal ref in psg *), 
       g: GOAL (* ([ams], concl ) *), 
       pctxt : context,
       global : string list (* referece used in subgoal system in pp, it's defnied as string list, this list is used to keep track of duplicated goals, which is a problem for us *),
       env : env} 
  
  (* TODO: maybe to add a table to store some meta info, e.g. hints? measures? *)
  type pplan = 
      {opengs : pnode StrName.NTab.T, 
      usedgs : StrName.NSet.T,
      gstate: GOAL_STATE (* used for backtracking *),
      nongs: (string list * GOAL) list (*non psg goal*)}
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq (* in pp, tactic is deteminted, seq is always singleton *)
   
   fun restore_pplan (pplan : pplan) = (logging "FAILURE" "Restoring pplan for backtracking" ; drop_main_goal (); push_goal_state (#gstate pplan))
  
  exception env_data_exp
  val exec_str = use_string;

  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = "PPProver.EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = "PPProver.Tac_ML_Exec");
  structure Thm_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = thm val struct_name = "PPProver.Thm_ML_Exec");
  structure Term_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = TERM val struct_name = "PPProver.Term_ML_Exec");
  structure CONV_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = CONV val struct_name = "PPProver.CONV_ML_Exec");
  structure CCONV1_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = CONV -> CONV val struct_name = "PPProver.CCONV1_ML_Exec");
  
  
  fun get_thm_by_name _ str = Thm_ML_Exec.eval_ml str
   handle _ => (logging "FAILURE" ("Fail to get thm by name: " ^ str); raise tinker_fail true);
  
  (* string -> string -> arg_data *)
  fun parse_ML_arg def typ =  
   case typ 
    of "conv" => (CONV_ML_Exec.eval_ml def |> A_Conv
      handle _ => (logging "FAILURE" ("Fail to parse conv from the string: " ^ def); raise tinker_fail true))
     | "cconv1" => (CCONV1_ML_Exec.eval_ml def |> A_CConv1
      handle _ => (logging "FAILURE" ("Fail to parse conv -> conv from the string: " ^ def); raise tinker_fail true))
     | _ => (logging "FAILURE" ("Unknown arg data typ in : " ^ typ ^ " with def: " ^ def); raise tinker_fail true)

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
  fun trm_of_string _ str = 
    let val str' = case str 
    of "true" => "T"
     | "false" => "F"
     | _ => str in 
    Term_ML_Exec.eval_ml ("%<%"^str'^"%>%") end
   handle _ => (logging "FAILURE" ("Fail to parse string to term: " ^ str); raise tinker_fail true);
   
  val prop_of_string = trm_of_string
  
(* TODO: how to print those fancy symbols in proofpower ?*)
  fun string_of_trm _ = fn trm => PrettyPrinter.format_term true trm |> String.concat 

  fun antiquto_handler env (typ, content) = 
   let 
     val typ' = Symbol.explode typ |> List.filter (not o member (op =) [" ","\n","\t"]) |> String.concat;
   in
(*   case typ' of "term" => "(PPProver.trm_of_string @{context} \"" ^ content ^ "\")"
     | "thm" => "(IsaProver.get_thm_by_name @{context} \"" ^ content ^ "\")"
     | "prop" => "(IsaProver.prop_of_string @{context} \"" ^ content ^ "\")"
     | _ =>  *)
     (logging "FAILURE" (typ' ^ " is not a supported type for env variable") ; raise (tinker_fail true))
   end

  fun parse_env_data ctxt (typ,def) vts = 
    case typ of "term" => 
      trm_of_string ctxt def 
      |> (let 
           val vts0 =  (* strip construtor in the list  and add ? back to the variable name *)
           map (fn (n, E_Trm t) => ("?"^n,t) | (n, _) => 
           (logging "FAILURE" ("Only E_trm is supported as args, in parsing env var: " ^ n) ;
             raise tinker_fail true)) 
           vts; 
           val vts' = 
            map (fn (n, t) => (t, 
             trm_of_string ctxt 
              ("(" ^ n ^") : " ^
               (fn str => String.extract (str, 1, SOME (String.size str - 2))) (* to strip the bracket annotation *)
               ((string_of_type o typ_of) t)))) 
            vts0
          in
         subst vts' end)
      |> E_Trm 
    | "prop" => prop_of_string ctxt def |> E_Trm
    | "thm" => 
      let val vts0 =  (* strip construtor in the list  and add ? back to the variable name *)
      map (fn (n, E_Trm t) => ("?"^n,t) | (n, _) => 
      (logging "FAILURE" ("Only E_trm is supported as args, in parsing env var: " ^ n) ;
        raise tinker_fail true)) 
      vts; 
      val vts' = map (fn (x, y) => (x, string_of_trm default_ctxt y)) vts0
      val def' = str_subst vts' def 
    in
      get_thm_by_name ctxt def' end |> E_Thm 
    | "dummy" => snd (hd vts) (* assignment *)
    | illform => (logging "FAILURE" ("Unsupported env data type: " ^ illform);
    raise tinker_fail true) 
  

  fun get_all_assms (pnode : pnode)  = (#g pnode) 
  			      |> fst (* a list of term *)
  			      |> map asm_rule (* to thm type *)			      
  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_concl (pnode:pnode) = (#g pnode) |> snd;
  fun get_pnode_hyps (pnode:pnode) = (#g pnode) |> fst;
  fun get_pnode_ctxt (pnode:pnode) = (#pctxt pnode) ;
  fun get_open_pnodes (pplan:pplan) = StrName.NTab.list_of (#opengs pplan) |> map snd (* should return some goals as top_goals () *)
  fun get_open_pnode_by_name (pplan : pplan) name = StrName.NTab.get (#opengs pplan) name

  fun set_open_goals_pplan (pplan : pplan) ogs  = {opengs = ogs, usedgs = #usedgs pplan, gstate = #gstate pplan, nongs = #nongs pplan}
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
    
  exception atomic_exp of string

  fun init ctxt asms_trms concl_trm : (pnode * pplan) =
    let
      val (pcs, thy) = ctxt
      val _ = if ((asms_trms, concl_trm) = ([], ¨falseÆ)) then set_merge_pcs pcs else(set_merge_pcs pcs; set_goal (asms_trms, concl_trm)); (* setup goal *)
      val goal = top_goal ();
      val allg = top_goals();
      val nongs = 
	if (List.length allg) = 1 
	then []
	else List.tl allg;
      val ctxt' = get_current_pc();
      val name = StrName.NSet.new StrName.NSet.empty "g"
      val pnode = {pname = name, g = goal,  pctxt = ctxt', global = [], env = StrName.NTab.empty};
      val pplan = {opengs = StrName.NTab.of_list [((#pname pnode), pnode)],
      			 usedgs = StrName.NSet.add name StrName.NSet.empty,
      			 gstate = top_goal_state(),
			 nongs = nongs}
    in
      (pnode, pplan)
    end;
      
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  fun update  (tac : TACTIC) (env_tac : env -> env list) (pnode : pnode, pplan : pplan)  : (pnode list * pplan) list = 
    let 
      val debug = false;
      fun gen_fresh_psgname nset (g : (string list * GOAL)) = 
        if (fst g) = [""] (* the case of single goal *)
        then 
          (StrName.NSet.new nset "g",  g) (* following this convesion to gen new goal name *)
        else
          (hd (fst g), g) (* otherwise, use the name from pp *)
        (*val _ = if debug then  writeln ("called set label on pname "  ^ (#pname pnode)) else ()
        val _ = if debug then Pretty.writeln  (Pretty.chunks (map Pretty.str ((#global pnode)))) else ()*)
      (* set current goal and apply tactic then get the list of goals in the format of :
      	string list * (term list * term) list *)
      fun get_all_psgs _ =  
	let
		fun filter_g l g = filter (fn x => not (x = g)) l;
		val nongs = (#nongs pplan);
		val allg = top_goals();
	in
		List.foldr (fn (a, b) => filter_g b a)
		allg nongs
	end
  
      fun filter_goals plist name = 
        filter 
        (fn (x : pnode) => 
          (case String.compare ((#pname x), name) of EQUAL => false 
          | _ => true))
        plist
(* in the case that applying psg in a middle of proof, so that multiply goal may exist, and only apply psg to the top one, the remaing goals are then non psg goals *)
      val sgs = (((if (#global pnode) = [] then () else set_labelled_goal (hd (#global pnode)));
      		SubgoalPackage.apply_tactic tac); get_all_psgs())
      val ctxt = get_current_pc();   

      fun gen_pnode (name, g) = ({pname = name, pctxt = ctxt, g = snd g, global = fst g, env = get_pnode_env pnode});
    in
      if (List.length sgs) = 0 (* no sgs *) 
      then 
        [([], {opengs = StrName.NTab.empty, usedgs = (#usedgs pplan), gstate = top_goal_state(), nongs = (#nongs pplan)})]
      else((* a list of sgs *)
        let
          val sgs' = map (gen_fresh_psgname (#usedgs pplan)) sgs 
          val all_pnodel = map gen_pnode sgs' (* all open subgoals *)
          val _ = if debug then  [Pretty.str "all new open sg list: ["] @ (map (Pretty.str o get_pnode_name) all_pnodel) @ [Pretty.str "]"] 
          	   |> Pretty.chunks |> Pretty.writeln else ()
          (* filter out new goals *)
          val used_names = (StrName.NSet.list_of (StrName.NSet.delete (get_pnode_name pnode)(#usedgs pplan))); (* remove the current pnode, because the tactic might change nothing *)
          val _ = if debug then  [Pretty.str "list of used name in ori pp: ["] @ (map (Pretty.str) used_names ) @ [Pretty.str "]"] 
            |> Pretty.chunks |> Pretty.writeln else ()
          val new_pnodel_l0 = 
            List.foldr
            (fn (n, pns) =>
                filter 
                (fn x => (not((get_pnode_name x) = n))) pns)
                  all_pnodel used_names
            val _ = if debug then [Pretty.str "new_pnodel_l0 after filtering: ["] @ (map (Pretty.str o get_pnode_name) new_pnodel_l0) @ [Pretty.str "]"] 
          	   |> Pretty.chunks |> Pretty.writeln else ()
            val new_pnodel_l = new_pnodel_l0 
            |> (
                  fn [x] => (map (fn y => [set_pnode_env y x]) (env_tac (get_pnode_env x))) (* either the case of env updat or the single node *)
                  | xs => [xs] 
               ) (* if mul pnodes, no need to update env, because env_update won't produce more than one sg, must be tac  *)
            (* update env from the consumed one:
            this will be a g list list, -> branch of goal list*)
        val _ = if debug then [Pretty.str "hd of new_pnodel_l: ["] @ (map (Pretty.str o get_pnode_name) (hd new_pnodel_l)) @ [Pretty.str "]"] 
          	   |> Pretty.chunks |> Pretty.writeln else ()
         fun mk_new_opengs new_pnodel =  (* del old consumed goal then add new goals *)
          (#opengs pplan)
          |> StrName.NTab.delete (#pname pnode)
          |> (fn n => List.foldr (fn (x,y) => StrName.NTab.ins ((#pname x), x) y) n new_pnodel)
         fun mk_new_pplan new_pnodel = 
         let
         val _ = if debug then [Pretty.str "new sg list: ["] @ (map (Pretty.str o get_pnode_name) new_pnodel) @ [Pretty.str "]"] 
          	   |> Pretty.chunks |> Pretty.writeln else ()
         val _ = if debug then [Pretty.str "new opengs status: ["] @ (StrName.NTab.keys (mk_new_opengs new_pnodel)|> map Pretty.str)@ [Pretty.str "]"]
	           |> Pretty.chunks |> Pretty.writeln else ()
         in
          {opengs = mk_new_opengs new_pnodel, (* get all current sgs name *)
           usedgs = StrName.NSet.add_list (map fst sgs') (#usedgs pplan),
           gstate = top_goal_state(), nongs = (#nongs pplan)}
          end

     in
	    map (fn npl => (npl, mk_new_pplan npl)) new_pnodel_l  
	   end 
	  )
   end 

  fun pretty_pnode pnode = 
  str_chunks_tab 1
  (["[ Goal " ^ (get_pnode_name pnode) ^ " : "] @
   (map (fn x => (tab 1) ^  (Pretty.string_of (pretty_trm (get_pnode_ctxt pnode) x))) (get_pnode_hyps pnode)) @
   [(tab 1) ^ ("Ù " ^ (pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode) |> Pretty.string_of)) ^ "]"])
  |> Pretty.str;

  fun apply_tactic args tac (pnode,pplan) = 
    (*let val (tac : tactic)  = build_tac_code_with_arg tac_code args |> Tac_ML_Exec.eval_ml in*)
    update (tac args) (fn x => [x]) (pnode,pplan)
    (*|> (fn x => (writeln "|||DEBUG: ";(map (fn (l,p) => (get_open_pnodes p |> map pretty_pnode |> Pretty.chunks |> Pretty.writeln)) x) ; x))*)
    |> Seq.of_list 
    handle BasicError.Fail msg => 
      (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ BasicError.get_message msg); 
               raise tinker_fail false (*Seq.empty*) )
    |  BasicError.Error msg => 
      (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ BasicError.get_message msg); 
               raise tinker_fail false) 
    | _ => (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ "Tactic fails"); 
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
               raise tinker_fail false) 
    |  BasicError.Error msg => 
      (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ BasicError.get_message msg); 
               raise tinker_fail false) 
    | _ => (logging "FAILURE" ("In pnode " ^ get_pnode_name pnode ^ ":" ^ "ENV Tactic fails"); 
               raise tinker_fail false);
    (*end*)  
  
  fun pretty_goal pnode = pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode)
  fun pretty_pplan pnode = Pretty.str "Pretty PPLAN TOTO";
  
  val unicode_symb = [
   ("≥", "<_uni_symb_lnot_>"),
   ("±","<_uni_symb_land_>"),
   ("≤","<_uni_symb_lor_>"),
   ("¥", "<_uni_symb_implies2_>"),
   ("§", "<_uni_symb_equiv2_>"),
   ("µ", "<_uni_symb_forall_>"),
   ("∂", "<_uni_symb_exists_>"),
   ("Ω", "<_uni_symb_neq_>"),
   ("æ", "<_uni_symb_geq_>"),
   ("º", "<_uni_symb_leq_>"),


   ("∑","<_uni_symb_blackdot_>"),
   ("ç", "<_uni_symb_in_>"),
   ("ß", "<_uni_symb_l_angle_brk_>"),
   ("¢", "<_uni_symb_r_angle_brk_>"),
   ("≠", "<_uni_symb_fun_>"),
   ("∏", "<_uni_symb_cross_>"),
   ("É", "<_uni_symb_bbU_>"),
   ("˙", "<_uni_symb_bbZ_>"),

   ("Ã", "<_uni_symb_lambda_>"),
   ("‘", "<_uni_symb_tau_>"),
   ("”", "<_uni_symb_sigma_>"),
   ("«", "<_uni_symb_gammar_>"),
   ("»", "<_uni_symb_eta_>"),
   ("â", "<_uni_symb_down_corner_>"),

   ("¨", "<_uni_symb_left_corner_>"),
   ("Æ", "<_uni_symb_right_corner_>"),
  
   ("Ò", "<_uni_symb_left_z_corner_>"),
   ("¶", "<_uni_symb_left_z_assign_>"),
   ("Ù", "<_uni_symb_vdash_>")
  ];

  
  structure unicode_helper = UnicodeHelperFUN (val symb_tab  = unicode_symb);

  val encoding_from_prover = unicode_helper.encode_prover_json;
  val encoding_to_prover = unicode_helper.decode_prover_json;
  val encoding_from_gui = unicode_helper.encode_gui_json;
  val encoding_to_gui = unicode_helper.decode_gui_json;

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