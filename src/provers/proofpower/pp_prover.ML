structure PPProver : PROVER =
struct
  local open LoggingHandler ProverUtils in 
  type pos = PPTermLib.pos
  type typ = TYPE
  type term = TERM
  type thm = THM
  type tactic = TACTIC
  type context = string list * string (* context string list * theory string *)

  (* get_current_pc () open_theory, set_pc *)
  
  type arg_data = string (* A_Const of string | A_Var of string | A_Trm of term *)
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  type env = env_data StrName.NTab.T 
  type env_tac =  env -> env 

  exception gterm_exp
  
  val default_ctxt = get_current_pc (); (* used in those place need context in general *)
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
  fun pretty_trm _ trm = Pretty.block (map Pretty.str (PrettyPrinter.format_term true trm))

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
  exception env_data_exp

  fun get_all_assms (pnode : pnode)  = (#g pnode) 
  			      |> fst (* a list of term *)
  			      |> map asm_rule (* to thm type *)			      
  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_concl (pnode:pnode) = (#g pnode) |> snd;
  fun get_pnode_hyps (pnode:pnode) = (#g pnode) |> fst;
  fun get_pnode_ctxt (pnode:pnode) = (#pctxt pnode) ;
  fun get_open_pnodes (pplan:pplan) = StrName.NTab.list_of (#opengs pplan) |> map snd (* should return some goals as top_goals () *)
  fun get_pnode_env (pnode:pnode) = #env pnode;
  fun update_pnode_env f {pname,g,pctxt,global,env}  = 
    {pname = pname, g = g, pctxt = pctxt, global = global, env = f env};
  val set_pnode_env = update_pnode_env o K;
  fun get_pnode_env_data pnode name = get_pnode_env pnode |> ( fn x => StrName.NTab.get x name)
  fun get_pnode_env_data_as_ML pnode name = 
    case get_pnode_env_data pnode name of (E_ML ml_code) => ml_code
    | _ => raise env_data_exp 
  
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq (* in pp, tactic is deteminted, seq is always singleton *)

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
    
  (*fun update _ _ = ([], {opengs = [], usedgs = StrName.NSet.empty})*)
  
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  
  fun update (tac : tactic) (pnode : pnode, pplan : pplan)  : (pnode list * pplan) = 
    let 
      fun gen_fresh_psgname nset (g : (string list * GOAL)) = 
        if (fst g) = [""] 
        then 
          (StrName.NSet.new nset "g",  g)
        else
          (hd (fst g), g)
      (*val _ = writeln "called update"*)
      val _ = ((if (#global pnode) = [] then () else set_labelled_goal (hd (#global pnode)));
      		apply_tactic tac); (* set current goal and apply tactic*)
      val sgs = top_goals(); (* string list * (term list * term) list *)
      val ctxt = get_current_pc();   
      fun filter_goals plist name = 
        filter 
        (fn (x : pnode) => 
          (case String.compare ((#pname x), name) of EQUAL => false 
          | _ => true))
        plist
      fun gen_pnode (name, g) = ({pname = name, pctxt = ctxt, g = snd g, global = fst g});
    in
      if (List.length sgs) = 0 (* no sgs *) 
      then 
        ([], {opengs = StrName.NTab.empty, usedgs = (#usedgs pplan)})
      else((* a list of sgs*)
        let
          val sgs' = map (gen_fresh_psgname (#usedgs pplan)) sgs
	  val new_pnodel = map gen_pnode sgs' (* all open subgoals *)
	  val new_pnodel' = 
	    List.foldr
	    (fn (n, pns) =>
	        filter 
	        (fn x => (case String.compare ((#pname x), n) 
	        		of EQUAL => false 
	        		| _ => true))
        	pns)
            new_pnodel
	    (StrName.NSet.list_of (#usedgs pplan))

          val new_pplan = 
            {opengs = (map (fn x => ((#pname x), x)) new_pnodel) 
        		 |> StrName.NTab.of_list, (* get all current sgs name *)
             usedgs = StrName.NSet.add_list (map fst sgs') (#usedgs pplan)  }
	in
	  (new_pnodel', new_pplan) 
	end

      )
     end
  

  fun apply_tactic args (tac_code : string) (pnode,pplan) = 
    let val (tac : tactic)  = build_tac_code_with_arg tac_code args |> Tac_ML_Exec.eval_ml in
    tac (#pctxt pnode) (get_index pnode pplan) (#goal pplan)
    |> Seq.singleton(update (pnode,pplan))
    |> Seq.map (fn (x,y) => (map (set_pnode_env (get_pnode_env pnode)) x,y)) (* inherit env *)
    |> (fn x => 
        (case Seq.pull x of NONE 
           => (logging "TACTIC" ("Fail to apply tactic for pnode " ^ get_pnode_name pnode); 
               raise tinker_fail) 
           | _ => x ))
    end
  (* Update the env and then apply a dummy id tac in isabelle *)
  fun apply_env_tactic args env_tac_code (pnode,pplan) = 
    let val (env_tac : env_tac)  = build_tac_code_with_arg env_tac_code args |> EnvTac_ML_Exec.eval_ml in
    apply_tactic args "(K (K all_tac))" (update_pnode_env env_tac pnode, pplan)
    end
   
  val exec_str = use_string;

  fun pretty_pnode pnode = 
    Pretty.block
    [Pretty.str "[ Goal ", 
    Pretty.str (get_pnode_name pnode),
    Pretty.str " : ",
    pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode),
    Pretty.str " ]"];
  
  fun pretty_pplan pnode = Pretty.str "Pretty PPLAN TOTO";
  val encode_gui_to_prover = implode o map unicode_to_pp o utf8_string_to_unicode;
  fun encode_prover_to_gui str =
   (set_flag ("output_in_utf8", true);
    ReaderWriter.translate_for_output str)
   |> (fn x => (set_flag ("output_in_utf8", false); x));

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
