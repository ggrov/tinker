structure IsaProver : PROVER =
struct 
   
  local open LoggingHandler ProverUtils in 
  type typ = typ
  type term = Term.term  
  type thm = Thm.thm
  type context = Proof.context

  fun term_to_string ctxt t =
   let
    val ctxt' = Config.put show_markup false ctxt;
   in Print_Mode.setmp [] (Syntax.string_of_term ctxt') t end;
  val trm_of_string = Syntax.parse_term;
  val string_of_trm = (*Syntax.string_of_term*) term_to_string;
  val pretty_trm = Syntax.pretty_term;


  type arg_data = string (* A_Const of string | A_Var of string | A_Trm of term *)
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_L of env_data list

  fun pretty_env_data _ (E_Str str) =  [ "E_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Trm trm) = [ "E_Trm(", string_of_trm ctxt trm,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Thm thm) =  [ "E_Thm(", Thm.prop_of thm |> string_of_trm ctxt,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_ML str) =  [ "E_ML(",  str,  ")"]|> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_L l) =  
        Pretty.str (String.concat [ "E_L(",
                      str_chunks (map (Pretty.string_of o pretty_env_data ctxt) l),
                       ")"]);

  type env = env_data StrName.NTab.T
  
  fun pretty_env ctxt env = 
    let fun pretty_pair (n, env_data) = 
     String.concat [n, ": ", pretty_env_data ctxt env_data |> Pretty.string_of] in
    StrName.NTab.list_of env
    |> map pretty_pair
    |> (fn xs => str_chunks (( "ENV_DATA: [" :: xs) @ [ "]"]) )
    |> Pretty.str
    end

  type env_tac =  env -> env 

  type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term, env : env } 
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }
  type tactic = Proof.context -> int -> Tactical.tactic (* Proof.context -> int -> arg_data list -> Tactical.tactic*)
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  exception env_data_exp

  val exec_str = eval_text;

  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = "IsaProver.EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = "IsaProver.Tac_ML_Exec");

 
  fun update_pnode_env f {pname,pctxt,ptrm,env} = {pname = pname ,pctxt = pctxt ,ptrm = ptrm ,env = f env};

  val set_pnode_env = update_pnode_env o K;
  fun get_pnode_env ({env, ...} : pnode) = env;
  fun get_pnode_env_data pnode name = get_pnode_env pnode |> ( fn x => StrName.NTab.get x name)
  fun get_pnode_env_data_as_ML pnode name = 
    case get_pnode_env_data pnode name of (E_ML ml_code) => ml_code
    | _ => raise env_data_exp 
 
  (* fixme: we need to rethink the allowed argument and when the vars should be instantiated! 
       E.g. rule(exI,?x) -> should the tactic instantiate ?x to what is has in the env or should we?
        also if it is not, then ?x may be instantiated and this updated env should be recorded in the 
        env \<rightarrow> where is this handled? Need to work out some examples first I think...
 *)
 
  exception gterm_exp

  val default_ctxt = @{context}
  val typ_of = Term.type_of
  fun match ctxt = Pattern.matches (Context.Proof_Context.theory_of ctxt)

  val asms_of_thm = Thm.prems_of
  val concl_of_thm = Thm.concl_of
  fun get_goal_thm pplan = #goal pplan

  exception atomic_exp of string

  fun init ctxt [] trm =
    let 
      val th = Proof_Context.theory_of ctxt
      val goal = Thm.cterm_of th trm
               |> Goal.init;
      val pnode = { pname = "g", pctxt = ctxt, ptrm = trm, env = StrName.NTab.empty}
      val pplan = { goal = goal, opengs = [pnode], usedgs = StrName.NSet.single "g"}
   in
     (pnode,pplan)
   end;

(*
  fun init_of_thm (ctxt : context) thm = 
    let 
      val prems = Thm.prems_of thm
      fun add prem (prms,nms) = 
          let 
             val (nm,nms') = StrName.NSet.add_new "g" nms
          in
            (prms @ [{ pname = nm, pctxt = ctxt, ptrm = prem, env = StrName.NTab.empty}],nms')
          end
      val (pnds,usedgs) = fold add prems ([],StrName.NSet.empty)
      val pplan = { goal = thm, opengs = pnds, usedgs = usedgs}
   in
     (pnds,pplan)
   end;
*)

(*
  fun init_with_assm _ _ _ =   (* a dummy init which is not used in isabelle by LYH*)
    raise atomic_exp "init_with_assm should not be used in isabelle"
*)
  fun get_ind str _ [] = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  get_ind str n (x::xs) = if str = (#pname x) then n else get_ind str (n+1) xs;

  fun othergs str _ [] _ = raise atomic_exp ("goal " ^ str ^ " does not exists")
   |  othergs str n (x::xs) b =
         if str = #pname x then (b,n,xs) else othergs str (n+1) xs (b@[x]);

  fun get_index (pnode:pnode) (pplan:pplan) = get_ind (#pname pnode) 1 (#opengs pplan);

(*
  fun insert_at 1 newgs allgs = newgs @ gs
   |  insert_at n newgs x::xs = x :: insert_at (n-1) newgs xs;
*)

  fun to_goal_nms ctxt goals new_env nameset = 
    let 
      fun ins t (gls,gset) =
       let 
        val (n,gset') = StrName.NSet.add_new "a" gset
        val g' = {pname = n,ptrm = t,pctxt = ctxt, env = new_env}
       in (gls@[g'],gset') end
    in
      fold ins goals ([],nameset)
    end;     

  fun update env_tac (pnode,pplan) newgoal = 
   let 
    val cur_env = get_pnode_env pnode
    val (b,ind,a) = othergs (#pname pnode) 1 (#opengs pplan) []; 
    (* 1 for current goal *)
    val numb = 1 + (Thm.nprems_of newgoal) - (Thm.nprems_of (#goal pplan))
    val prems = Thm.prems_of newgoal
    val newgoals' = 
      if numb > 0 
       then drop (ind-1) prems 
            |> take numb  
       else []
    val (newgoals,goalset) = to_goal_nms (#pctxt pnode) newgoals' (env_tac cur_env)(#usedgs pplan)
    val ogoals = b @ newgoals @ a
    val pplan' = {goal = newgoal,opengs = ogoals, usedgs = goalset}
  in
    (newgoals,pplan')
  end;

 (* fun get_all_assms _ = []
  fun get_all_named_facts_pair _ = [] *)
  fun get_open_pnodes (pplan : pplan) = (#opengs pplan)

  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_ctxt (pnode:pnode) = #pctxt pnode;

  fun get_pnode_concl (pnode:pnode) = #ptrm pnode |> Logic.strip_imp_concl;
  fun get_pnode_hyps (pnode:pnode) = #ptrm pnode |> Logic.strip_imp_prems;

  fun pretty_goal pnode = string_of_trm (get_pnode_ctxt pnode)  (get_pnode_concl pnode) |> Pretty.str
  fun pretty_pnode pnode = 
    String.concat
     [ "[ Goal ",
     (get_pnode_name pnode),
      " : ",
     pretty_trm (get_pnode_ctxt pnode) (get_pnode_concl pnode) |> Pretty.string_of,
     " ]"] |> Pretty.str

  fun pretty_pplan _ = Pretty.str "Pretty PPLAN TOTO";
   
  fun apply_tactic args (tac_code : string) (pnode,pplan) = 
    let val (tac : tactic)  = build_tac_code_with_arg tac_code args |> Tac_ML_Exec.eval_ml in
    tac (#pctxt pnode) (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update I (pnode,pplan))
    |> (fn x => 
        (case Seq.pull x of NONE 
           => (logging "TACTIC" ("Fail to apply tactic for pnode " ^ get_pnode_name pnode); 
               raise tinker_fail) 
           | _ => x ))
    end
  (* Update the env and then apply a dummy id tac in isabelle *)
  fun apply_env_tactic args env_tac_code (pnode,pplan) = 
    let val (env_tac : env_tac)  = build_tac_code_with_arg env_tac_code args |> EnvTac_ML_Exec.eval_ml in
    (K (K all_tac)) (#pctxt pnode) (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update env_tac (pnode,pplan))
    |> (fn x => 
        (case Seq.pull x of NONE 
           => (logging "TACTIC" ("Fail to apply env tactic for pnode " ^ get_pnode_name pnode); 
               raise tinker_fail) 
           | _ => x ))
    end
  (* SOME default tactics *)

  (*fun lookup_thm ctxt name =
    Global_Theory.get_thm (Proof_Context.theory_of ctxt) name;*)

  (* to do: debug etc 
  fun rule_tac _ i ((E_Thm thm)::_) = rtac thm i
   |  rule_tac ctxt i ((E_Str name)::_) = rtac (lookup_thm ctxt name) i
   |  rule_tac _ _ _ = raise atomic_exp ("no such type")

  fun erule_tac _ i ((E_Thm thm)::_) = etac thm i
   |  erule_tac ctxt i ((E_Str name)::_) = etac (lookup_thm ctxt name) i
   |  erule_tac _ _ _ = raise atomic_exp ("no such type")
  *)
 (* val default_tacs = [("rule",rule_tac),("erule",erule_tac)];*)

  (**************
    Goal type related 
  ******************)
(*  fun symbols trm = StrName.NSet.list_of (TermFeatures.constants trm)
                  |> map TermFeatures.ignore_module;
  fun top_symbol trm = the (TermFeatures.top_level_str trm );*)

  
  val encode_prover_to_gui = I;
  val encode_gui_to_prover = I;

  (* END goal type *)
  end (* end of local open *)
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
end (* struct *)

(* OLD STUFF

  fun apply_rule name thm (pnode,pplan) = 
    (debug_print EVAL ("rule " ^ name);
    rtac thm (get_index pnode pplan) (#goal pplan) 
    |> Seq.map (update (pnode,pplan)));

  fun apply_erule _ thm (pnode,pplan) =
    etac thm (get_index pnode pplan) (#goal pplan) 
    |> Seq.map (update (pnode,pplan));

  (* only second *)
  fun apply_frule (n1,fst_thm) (n2,snd_thm) (pnode,pplan) = 
    (debug_print EVAL ("frule with " ^ n1 ^ " and " ^ n2); 
    (* Seq.append (ftac fst_thm (get_index pnode pplan) (#goal pplan)) *)
               (ftac snd_thm (get_index pnode pplan) (#goal pplan))
    |> Seq.map (update (pnode,pplan)));

  fun apply_subst _ thm (pnode,pplan) =
    EqSubst.eqsubst_tac (#pctxt pnode) [0] [thm] (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update (pnode,pplan));

  (* is this correct? *)
  fun apply_subst_asm (_,fst_thm) (_,_) (pnode,pplan) =  
    EqSubst.eqsubst_asm_tac (#pctxt pnode) [0] [fst_thm] (get_index pnode pplan) (#goal pplan)
    |> Seq.map (update (pnode,pplan));
*)
