structure PpAtomic : ATOMIC  =
struct
  type fact = PpProver.thm
  type tactic = TACTIC
  type context = PpProver.context
  type concl = PpProver.term
  type assm = PpProver.term
  
  type pnode = {pname : string, pctxt : context, gs: GOAL_STATE, glabel : string} 
  type pplan = {opengs : pnode list, usedgs : StrName.NSet.T }
  
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  exception atomic_exp of string
  
  (* there is no interface to init a pnode and pplan ?*)
  (* if paralle evalation then it would be problematic*)
  fun init _ _  = raise atomic_exp "init is not expected to be called in pp"
  fun init_with_assm ctxt asms_trms concl_trm : (pnode * pplan) =
    let
      val (pcs, thy) = ctxt
      val gs = ((*open_theory thy;*) set_merge_pcs pcs; set_goal (asms_trms, concl_trm) ; top_goal_state());
      val ctxt = get_current_pc();
      val pname = StrName.NSet.new StrName.NSet.empty "g"
      val pnode = {pname = pname , pctxt = ctxt, gs = gs, glabel = ""};
      val pplan = {opengs = [pnode], usedgs = StrName.NSet.add pname StrName.NSet.empty}
    in
      (pnode, pplan)
    end;
    
  (*fun update _ _ = ([], {opengs = [], usedgs = StrName.NSet.empty})*)
  
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  
  fun update (tac : tactic) (pnode : pnode, pplan : pplan)  : (pnode list * pplan) = 
  let 
      fun filter_goals plist name = 
        filter 
        (fn x => 
          (case String.compare ((#pname x), name) of EQUAL => false 
          | _ => true))
        plist
      val gs = (push_goal_state (#gs pnode); apply_tactic tac; top_goal_state());
      val sgs = top_goals(); (* string * (term list * term) list *)
      val gstr_list = map (fn (a, _) => a) sgs
      val ctxt = get_current_pc();   
      fun lift_to_pnode (name, (strl, _)) = 
      	{pname = name, 
      	 pctxt = ctxt, 
      	 gs = (set_labelled_goal(hd strl) ; top_goal_state()),
      	 glabel = hd strl};
      fun gen_name (0, i) (newnamel, nameset) = (newnamel, nameset)
      	| gen_name (i, j) (newnamel, nameset) = 
      	let val fresh = StrName.NSet.new nameset ((#pname pnode) ^ Int.toString (j + 1 -i)) in
      	  gen_name (i - 1, j) (fresh :: newnamel, StrName.NSet.add fresh nameset) end
   in
    if (List.length gstr_list) = 0 (* no sgs *) 
    then 
       ([], {opengs = filter_goals (#opengs pplan) (#pname pnode), usedgs = (#usedgs pplan)})
    else(
      if (List.length gstr_list) = 1(* only one goal *) 
      then(
        let 
          val newname = StrName.NSet.new (#usedgs pplan) (#pname pnode);
          val new_pnode = lift_to_pnode (newname, (hd sgs));
          val new_pplan = {opengs = [new_pnode] @ (#opengs pplan), usedgs = StrName.NSet.add newname (#usedgs pplan)}
        in
          ([new_pnode], {opengs = filter_goals (#opengs new_pplan) (#pname pnode), usedgs = (#usedgs new_pplan)})
        end)
      else((* a list of sgs*)
        let 
          val newnames = (* generate a list of fresh name, based on: (previous_gname ^ order_of_sg) *)
           gen_name (List.length sgs, List.length sgs) ([], #usedgs pplan);
          fun zip [] [] = []
            | zip (x :: xs) (y :: ys) = (x,y) :: (zip xs ys);
          val new_pnodel = map lift_to_pnode (zip (fst newnames) sgs);
          val new_pplan = {opengs = new_pnodel @ (#opengs pplan), usedgs = snd newnames}
        in
          (new_pnodel,  {opengs = filter_goals (#opengs new_pplan) (#pname pnode), usedgs = (#usedgs new_pplan)}) 
        end
      )
    )
   end
  
  (* TACTIC in pp is always determined, no branching ?? *)
  fun apply_rule _ thm pinfo = update (bc_thm_tac thm) pinfo |> Seq.single
 
  fun apply_erule _ _ _ = raise atomic_exp "apply_erule is not supported"
  
  (* first assumption, next rule, but in pp ,it's applied blindly *)
  fun apply_frule _ (_ , thm) pinfo =  update (all_fc_tac [thm]) pinfo |> Seq.single
  
  fun apply_subst _ thm pinfo = update (rewrite_tac [thm]) pinfo|> Seq.single
  
  (* first assumption, second the equality rule *)
  fun apply_subst_asm _ (_ , thm) pinfo = update (rewrite_tac [thm]) pinfo |> Seq.single
  
  fun apply_tactic _ _ tactic pinfo = update tactic pinfo |> Seq.single

  (* only look up *)
  fun lookup_fact pnode key = 
    (get_axiom (snd (#pctxt pnode)) key |> SOME
    handle _ => 
      (get_thm (snd (#pctxt pnode)) key |> SOME
       handle _ => NONE))

  fun get_all_assms pnode  = (push_goal_state (#gs pnode) ; top_goal()) 
  			      |> fst (* a list of term *)
  			      |> map asm_rule (* to thm type *)
  			      
  (* need to think about more for this,  in order *)			 
  fun get_all_named_facts_pair _ = [] (*pnode -> (string * fact) list*)

  fun get_pnode_name (pnode:pnode) = #pname pnode;
  
  fun get_pnode_concl pnode = (push_goal_state (#gs pnode) ; top_goal()) |> snd
  
  fun get_pnode_ctxt (pnode:pnode) = #pctxt pnode;
  
  structure Sharing =
  struct
    type fact = fact
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
    type context = context
    type concl = concl
    type assm = assm
  end

end
