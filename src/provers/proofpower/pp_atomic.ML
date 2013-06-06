structure PpAtomic : ATOMIC  =
struct
  type fact = PpProver.thm
  type tactic = TACTIC
  type context = PpProver.context
  type concl = PpProver.term
  
  type pnode = {pname : string, pctxt : context, gs: GOAL_STATE} 
  type pplan = {opengs : pnode list, usedgs : StrName.NSet.T }
  
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  exception atomic_exp of string
  
  (* there is no interface to init a pnode and pplan ?*)
  (* if paralle evalation then it would be problematic*)

  fun init asms_trms concl_trm : (pnode * pplan) =
    let
      val gs = (set_goal (asms_trms, concl_trm) ; top_goal_state());
      val ctxt = get_current_pc();
      val pname = "g" ^ top_current_label();
      val pnode = {pname = pname , pctxt = ctxt, gs = gs};
      val pplan = {opengs = [pnode], usedgs = StrName.NSet.add pname StrName.NSet.empty}
    in
      (pnode, pplan)
    end;
    
  fun update _ _ = ([], {opengs = [], usedgs = StrName.NSet.empty})
  
  (*val update : TACTIC -> (pnode * pplan) -> (pnode list * pplan) *)
  (*
  fun update (pnode, pplan) (tac : tactic) : (pnode list * pplan) Seq.seq = 
  let 
      val gs = (push_goal_state (#gs pnode); apply_tactic tac; top_goal_state());
  *)
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
  			      
  (* need to think about more for this *)			 
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
  end

end
