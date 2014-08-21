structure IsaProver : PROVER =
struct 

  type typ = typ
  type term = Term.term  
  type thm = Thm.thm
  type context = Proof.context

  datatype arg_data =  Str of string | Trm of term | Thm of thm

  type pnode = { pname : string, pctxt : Proof.context, ptrm : Term.term } 
  type pplan = { goal : Thm.thm, opengs : pnode list, usedgs : StrName.NSet.T }

  type tactic = Proof.context -> int -> arg_data list -> Tactical.tactic
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  exception gterm_exp

  val default_ctxt = @{context}
  val typ_of = Term.type_of
  fun match ctxt = Pattern.matches (Context.Proof_Context.theory_of ctxt)

  (* fixme: I am not sure this will handle variables! *)
  val trm_of_string = Syntax.parse_term;
  val string_of_trm = Syntax.string_of_term;
  val pretty_trm = Syntax.pretty_term;

  val asms_of_thm = Thm.prems_of
  val concl_of_thm = Thm.concl_of


  exception atomic_exp of string


  fun init ctxt [] trm =
    let 
      val th = Proof_Context.theory_of ctxt
      val goal = Thm.cterm_of th trm
               |> Goal.init;
      val pnode = { pname = "g", pctxt = ctxt, ptrm = trm}
      val pplan = { goal = goal, opengs = [pnode], usedgs = StrName.NSet.single "g"}
   in
     (pnode,pplan)
   end;

  fun init_of_thm (ctxt : context) thm = 
    let 
      val prems = Thm.prems_of thm
      fun add prem (prms,nms) = 
          let 
             val (nm,nms') = StrName.NSet.add_new "g" nms
          in
            (prms @ [{ pname = nm, pctxt = ctxt, ptrm = prem}],nms')
          end
      val (pnds,usedgs) = fold add prems ([],StrName.NSet.empty)
      val pplan = { goal = thm, opengs = pnds, usedgs = usedgs}
   in
     (pnds,pplan)
   end;


  fun init_with_assm _ _ _ =   (* a dummy init which is not used in isabelle by LYH*)
    raise atomic_exp "init_with_assm should not be used in isabelle"

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

  fun to_goal_nms ctxt goals nameset = 
    let 
      fun ins t (gls,gset) =
       let 
        val (n,gset') = StrName.NSet.add_new "a" gset
        val g' = {pname = n,ptrm = t,pctxt = ctxt}
       in (gls@[g'],gset') end
    in
      fold ins goals ([],nameset)
    end;     

  fun update (pnode,pplan) newgoal = 
   let 
    val (b,ind,a) = othergs (#pname pnode) 1 (#opengs pplan) []; 
    (* 1 for current goal *)
    val numb = 1 + (Thm.nprems_of newgoal) - (Thm.nprems_of (#goal pplan))
    val prems = Thm.prems_of newgoal
    val newgoals' = 
      if numb > 0 
       then drop (ind-1) prems 
            |> take numb  
       else []
    val (newgoals,goalset) = to_goal_nms (#pctxt pnode) newgoals' (#usedgs pplan)
    val ogoals = b @ newgoals @ a
    val pplan' = {goal = newgoal,opengs = ogoals, usedgs = goalset}
  in
    (newgoals,pplan')
  end;




  fun get_all_assms _ = []

  fun get_all_named_facts_pair _ = []
  fun get_open_pnodes (pplan : pplan) = (#opengs pplan)

  fun get_pnode_name (pnode:pnode) = #pname pnode;
  fun get_pnode_ctxt (pnode:pnode) = #pctxt pnode;

  fun get_pnode_concl (pnode:pnode) = #ptrm pnode |> Logic.strip_imp_concl;
  fun get_pnode_hyps (pnode:pnode) = #ptrm pnode |> Logic.strip_imp_prems;

  fun pretty_pnode pnode = 
    Pretty.block
     [Pretty.str "[ Goal ",
     Pretty.str (get_pnode_name pnode),
     Pretty.str " : ",
     Syntax.pretty_term (get_pnode_ctxt pnode) (get_pnode_concl pnode),
     Pretty.str " ]"]

  fun pretty_pplan pnode = Pretty.str "Pretty PPLAN TOTO";
   
  fun apply_tactic args tac (pnode,pplan) = 
    tac (#pctxt pnode) (get_index pnode pplan) args (#goal pplan)
    |> Seq.map (update (pnode,pplan));

  (* SOME default tactics *)

  fun lookup_thm ctxt name =
    Global_Theory.get_thm (Proof_Context.theory_of ctxt) name;

  (* to do: debug etc *)
  fun rule_tac _ i ((Thm thm)::_) = rtac thm i
   |  rule_tac ctxt i ((Str name)::_) = rtac (lookup_thm ctxt name) i
   |  rule_tac _ _ _ = raise atomic_exp ("no such type")

  fun erule_tac _ i ((Thm thm)::_) = etac thm i
   |  erule_tac ctxt i ((Str name)::_) = etac (lookup_thm ctxt name) i
   |  erule_tac _ _ _ = raise atomic_exp ("no such type")

  val default_tacs = [("rule",rule_tac),("erule",erule_tac)];

  (**************
    Goal type related 
  ******************)
  fun symbols trm = StrName.NSet.list_of (TermFeatures.constants trm)
                  |> map TermFeatures.ignore_module;
  fun top_symbol trm = the (TermFeatures.top_level_str trm );

  (* END goal type *)

  structure Sharing = 
  struct
    type typ = typ
    type term = term
    type thm = thm
    type context = context
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
