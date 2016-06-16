structure IsaProver : PROVER =
struct 
   
  local open LoggingHandler in 
  type typ = typ
  type term = Term.term  
  type thm = Thm.thm
  type context = Proof.context

  val default_ctxt = @{context}

  fun term_to_string ctxt t =
   let
    val ctxt' = Config.put show_markup false ctxt;
   in Print_Mode.setmp [] (Syntax.string_of_term ctxt') t end;
  fun trm_of_string ctxt str = Syntax.parse_term ctxt str |> Syntax.check_term ctxt;
  fun prop_of_string ctxt x = 
    Syntax.parse_term ctxt x 
    |> (fn t => (Const ("HOL.Trueprop", dummyT) $ t))
    |> Syntax.check_term ctxt
  val string_of_trm = (*Syntax.string_of_term*) term_to_string;
  fun get_thm_by_name ctxt name = 
    Find_Theorems.find_theorems ctxt NONE NONE false [(true, Find_Theorems.Name name)]
    |> snd |> hd |> snd
   handle _ => (logging "FAILURE" ("Fail to get thm by name: " ^ name); raise tinker_fail true)
  val pretty_trm = Syntax.pretty_term;

  fun subst_trm_vars vts trm = 
   let
     val vts' = map (fn (n, trm) => ((String.extract (n,1,NONE), 0), trm)) vts
   in
     Term.subst_Vars vts' trm 
   end

  fun antiquto_handler env (typ, content) = 
   let 
     val typ' = Symbol.explode typ |> List.filter (not o member (op =) [" ","\n","\t"]) |> String.concat;
   in
     case typ' of "term" => "(IsaProver.trm_of_string @{context} \"" ^ content ^ "\")"
     | "thm" => "(IsaProver.get_thm_by_name @{context} \"" ^ content ^ "\")"
     | "prop" => "(IsaProver.prop_of_string @{context} \"" ^ content ^ "\")"
     | _ => (logging "FAILURE" (typ' ^ " is not a supported type for env variable") ; raise (tinker_fail true))
   end

  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
      | A_L_Thm of thm list | A_L_Trm of term list | A_L of arg_data list | A_Conv of term -> thm 
      | A_CConv1 of (term -> thm) -> (term -> thm)
 
  datatype env_data = 
    E_Str of string | 
    E_Trm of term | E_Thm of thm |
    E_ML of string | 
    E_Conv of term -> thm |
    E_L of env_data list |
    E_CConv1 of (term -> thm) -> (term -> thm) 


  fun pretty_env_data _ (E_Str str) =  [ "E_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Trm trm) = [ "E_Trm(", string_of_trm ctxt trm,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_Thm thm) =  [ "E_Thm(", Thm.prop_of thm |> string_of_trm ctxt,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_ML str) = [ "E_ML(",  str,  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_Conv c) = [ "E_Conv(",  "Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data _ (E_CConv1 cc) = [ "E_CConv1(",  "Conv -> Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_env_data ctxt (E_L l) =  
        Pretty.str (String.concat [ "E_L(",
                      str_chunks (map (Pretty.string_of o pretty_env_data ctxt) l),
                       ")"]);

  fun pretty_arg_data _ (A_Str str) =  [ "A_Str(", str, ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_Trm trm) = [ "A_Trm(", string_of_trm ctxt trm ,  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_Thm thm) =  [ "A_Thm(", Thm.prop_of thm |> pretty_trm ctxt |> Pretty.string_of,  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L_Trm trm_l) = [ "A_L_Trm("] @ (map (fn trm => string_of_trm ctxt trm |> (fn x => x ^ " | "))trm_l) @ [")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L_Thm thm_l) =  [ "A_L_Thm("]@ (map (fn thm => Thm.prop_of thm |> string_of_trm ctxt |> (fn x => x ^ " | ")) thm_l) @ [")"] |> String.concat |> Pretty.str
  |   pretty_arg_data _ (A_Conv c) = [ "A_Conv(",  "Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data _ (A_CConv1 cc) = [ "A_CConv1(",  "Conv -> Conv",  ")"] |> String.concat |> Pretty.str
  |   pretty_arg_data ctxt (A_L l) =  
        Pretty.str (String.concat [ "A_L(",
                      str_chunks (map (Pretty.string_of o pretty_arg_data ctxt) l),
                       ")"]);

  fun env_to_arg (E_Str str) = A_Str str
  |   env_to_arg (E_Trm trm) = A_Trm trm
  |   env_to_arg (E_Thm thm) = A_Thm thm
  |   env_to_arg env = (logging "FAILURE" ("Do not suppport the conversion from env to arg: " ^ (pretty_env_data default_ctxt env|> Pretty.string_of)) ;
      raise tinker_fail true)

  fun arg_to_env (A_Str str) = E_Str str
  |   arg_to_env (A_Trm trm) = E_Trm trm
  |   arg_to_env (A_Thm thm) = E_Thm thm
  |   arg_to_env arg = (logging "FAILURE" ("Do not suppport the conversion from arg to env: " ^ (pretty_arg_data default_ctxt arg|> Pretty.string_of)) ;
      raise tinker_fail true)

  type env = env_data StrName.NTab.T
  
  fun pretty_env ctxt env = 
    let fun pretty_pair (n, env_data) = 
     String.concat [n, ": ", pretty_env_data ctxt env_data |> Pretty.string_of] in
    StrName.NTab.list_of env
    |> map pretty_pair
    |> (fn xs => str_chunks (( "ENV_DATA: [" :: xs) @ [ "]"]) )
    |> Pretty.str
    end

  type env_tac = context -> arg_data list -> env -> env list
  fun id_env_tac _ _ env = [env] 
  fun id_env_tac_f env : env_tac= (fn c => (fn args => fn _ => id_env_tac c args env))

  type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term, env : env } 
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }
  type tactic =  arg_data list  -> Proof.context -> int -> Tactical.tactic
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  exception env_data_exp

  val exec_str = eval_text;
  
  fun parse_env_data ctxt (typ,def) vts = 
    case typ of "term" => trm_of_string ctxt def 
      |> (let val vts' = map (fn (n, E_Trm t) => (n,t) | (n, _) 
       => (logging "FAILURE" ("Only E_trm is supported as args, in parsing env var: " ^ n) ;
       raise tinker_fail true)) vts in
       subst_trm_vars vts' end) 
      |> Syntax.check_term ctxt |> E_Trm
    | "prop" => prop_of_string ctxt def |> E_Trm
    | "thm" => get_thm_by_name ctxt def |> E_Thm
    | "string" => E_Str def
    | "dummy" => snd (hd vts)
    | illform => (logging "FAILURE" ("Unsupported env data type: " ^ illform) ;
    raise tinker_fail true)

  structure Arg_ML_Exec =  ML_Exec_Func (val exec_str = exec_str type ret = arg_data val struct_name = "IsaProver.Arg_ML_Exec");
  structure EnvTac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = env_tac val struct_name = "IsaProver.EnvTac_ML_Exec");
  structure Tac_ML_Exec = ML_Exec_Func (val exec_str = exec_str type ret = tactic val struct_name = "IsaProver.Tac_ML_Exec");

  fun parse_ML_arg def typ =  (logging "FAILURE" ("Unknown arg data typ in : " ^ typ ^ " with def: " ^ def); raise tinker_fail true)

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

  fun update (env_tac : env -> env list) (pnode,pplan) newgoal = 
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
    fun mk_new_goal_status ctxt ngs plan new_env = 
      let 
         val (newgoals,goalset) = to_goal_nms ctxt ngs new_env plan
         val ogoals = b @ newgoals @ a
         val pplan' = {goal = newgoal, opengs = ogoals, usedgs = goalset}
      in
            (newgoals,pplan')
      end    
  in
    map (mk_new_goal_status (#pctxt pnode) newgoals' (#usedgs pplan)) (env_tac cur_env)
    |> Seq.of_list
  end;

 (* fun get_all_assms _ = []
  fun get_all_named_facts_pair _ = [] *)
  fun fix_alls_in_term alledt = 
    let
      val t = Term.strip_all_body alledt;
      val alls = rev (Term.strip_all_vars alledt);
      val varnames = map (fst o fst o Term.dest_Var) (Misc_Legacy.term_vars t)
      val names = Misc_Legacy.add_term_names (t,varnames);
      val fvs = map Free 
                    (Name.variant_list names (map fst alls)
                       ~~ (map snd alls));
    in ((subst_bounds (fvs,t))) end;

  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_ctxt (pnode:pnode) = #pctxt pnode;

  fun get_pnode_concl (pnode:pnode) = #ptrm pnode |> fix_alls_in_term |> Logic.strip_imp_concl;
  fun get_pnode_hyps (pnode:pnode) = #ptrm pnode |> fix_alls_in_term |> Logic.strip_imp_prems;

  fun get_open_pnodes (pplan : pplan) = (#opengs pplan)
  fun get_open_pnode_by_name (pplan : pplan) name = 
   get_open_pnodes pplan
   |> map (fn pn => (get_pnode_name pn, pn))
   |> StrName.NTab.of_list
   |> (fn x => StrName.NTab.get x name)
   
  fun set_open_goals_pplan (pplan : pplan) ogs  = {goal = #goal pplan, opengs = ogs, usedgs = #usedgs pplan}
  fun set_pnode_pplan pnode pplan = 
   let
    val _ = get_open_pnode_by_name pplan (get_pnode_name pnode)
    val idx = get_index pnode pplan
    fun list_to_seq _ seq []  = seq
    |   list_to_seq idx seq (x::xs)  = list_to_seq (idx+1) (StrName.NTab.ins (Int.toString idx, x) seq) xs
   in
    get_open_pnodes pplan
    |> list_to_seq 1 StrName.NTab.empty
    |> StrName.NTab.update  (Int.toString idx, pnode)
    |> StrName.NTab.list_of |> rev (* use the ntab to order the list *)
    |> map snd
    |> set_open_goals_pplan pplan
   end
   handle StrName.Tab.UNDEF n => 
   (logging "FAILURE" ("Can not find the pnode of open goal for " ^ n ^ " to update") ;
    raise tinker_fail true)

  fun pretty_goal pnode = string_of_trm (get_pnode_ctxt pnode)  (get_pnode_concl pnode) |> Pretty.str
  fun pretty_pnode pnode = 
    String.concat
     [ "[ Goal ",
     (get_pnode_name pnode),
      " : ",
     term_to_string (get_pnode_ctxt pnode) (get_pnode_concl pnode),
     " ]"] |> Pretty.str

  fun pretty_pplan _ = Pretty.str "Pretty PPLAN TOTO";
  fun restore_pplan _ = ();
   
  fun apply_tactic args (tac : tactic) (pnode,pplan) = 
    (*let val (tac : tactic)  = build_tac_code_with_arg tac_code args |> Tac_ML_Exec.eval_ml in*)
    tac args (#pctxt pnode) (get_index pnode pplan)  (#goal pplan)
    (*|> (fn x =>( writeln "DEBUG: ";Seq.list_of x |> map Thm.prop_of|> map (pretty_trm (#pctxt pnode)) |>map  Pretty.writeln ;x))*)
    |> Seq.maps (update (fn x => [x]) (pnode,pplan))
    |> (fn x => 
        (case Seq.pull x of NONE 
           => (logging "FAILURE" ("Fail to apply tactic for pnode " ^ get_pnode_name pnode ^ ", empty seqence"); 
               raise tinker_fail false) 
           | _ => x ))
    (*end*)
  (* Update the env and then apply a dummy id tac in isabelle *)
  fun apply_env_tactic args (env_tac : env_tac) (pnode,pplan) = 
    (*let val (env_tac : env_tac)  = build_tac_code_with_arg env_tac_code args |> EnvTac_ML_Exec.eval_ml in*)
    (K (K all_tac)) (#pctxt pnode) (get_index pnode pplan) (#goal pplan)
    |> Seq.maps (update (env_tac  (#pctxt pnode)  args) (pnode,pplan))
    |> (fn x => 
        (case Seq.pull x of NONE 
           => (logging "FAILURE" ("Fail to apply env tactic for pnode " ^ get_pnode_name pnode ^  ", empty seqence"); 
               raise tinker_fail false) 
           | _ => x ))
   (* end*)
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

  val unicode_symb = [
   ("\\\<longrightarrow>", "<_uni_symb_implies_>"),
  
   ("\\\<nat>", "<_uni_symb_bbN_>"),

   ( "\\\<not>" ,"<_uni_symb_lnot_>"),
   ("\\\<and>", "<_uni_symb_land_>"),
   ("\\\<or>", "<_uni_symb_lor_>"),

   ("\\\<forall>", "<_uni_symb_forall_>"),
   ("\\\<exists>", "<_uni_symb_exists_>"),

   ("\\\<noteq>", "<_uni_symb_neq_>"),

   ("\\\<union>", "<_uni_symb_union_>"),
   ("\\\<inter>", "_uni_symb_inter_"),
   ("\\\<in>", "<_uni_symb_in_>"),
   ("\\\<notin>", "<_uni_symb_notin_>"),
   ("\\\<subset>", "<_uni_symb_lsubset_>"),
   ("\\\<supset>", "<_uni_symb_rsubset_>"),
   ("\\\<subseteq>", "<_uni_symb_lsubseteq_>"),
   ("\\\<supseteq>", "<_uni_symb_rsubseteq_>"),
   ("\\\<lhd>", "<_uni_symb_domres_>"),
   ("\\\<rhd>", "<_uni_symb_ranres_>"),
   
   ("\\\<Longrightarrow>", "<_uni_symb_metaimpies_>"),
   ("\\\<lambda>", "<_uni_symb_lambda_>")
  ];
  
  structure unicode_helper = UnicodeHelperFUN (val symb_tab  = unicode_symb);

  val encoding_from_prover = unicode_helper.encode_prover_json;
  val encoding_to_prover = unicode_helper.decode_prover_json;
  val encoding_from_gui = unicode_helper.encode_gui_json;
  val encoding_to_gui = unicode_helper.decode_gui_json;

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
