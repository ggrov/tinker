structure PPlanEnv = 
struct

  fun apply_rule (gnode,prf) thm = PPlan.apply_tac (K (rtac thm 1)) (gnode,prf)

  (* and vs or wires *)
  fun apply_frule (gnode,prf) bwire thm = PPlan.apply_tac (K (ftac thm 1)) (gnode,prf) 

  fun apply_erule (gnode,prf) thm = PPlan.apply_tac (K (etac thm 1)) (gnode,prf)

  fun apply_subst (gnode,prf) thms = 
    PPlan.apply_tac (fn ctxt => EqSubst.eqsubst_tac ctxt [0] thms 1) (gnode,prf);

  (* why K combinator - shouldn't this be removed from the graph *)
  fun apply_tactic (gnode,prf) tac = PPlan.apply_tac (K tac) (gnode,prf) 

  fun apply_ctxt_tactic (gnode,prf) tac = PPlan.apply_tac tac (gnode,prf) 
    

end (* struct *)

structure PNode_Ctxt_Data = Proof_Data(
   struct 
    type T = PNode.T StrName.NTab.T 
    fun init _ = StrName.NTab.empty 
   end);

structure PNode_Ctxt =
struct
  fun ins_tab pnode = StrName.NTab.ins (PNode.get_name pnode,pnode)
  val get_goal = StrName.NTab.lookup o PNode_Ctxt_Data.get;
  fun add_goal pnode = PNode_Ctxt_Data.map (ins_tab pnode)
  fun add_goals pnods = PNode_Ctxt_Data.map (fold ins_tab pnods);
  fun del_goal pname = PNode_Ctxt_Data.map (StrName.NTab.delete pname);
end;

structure Prf_Ctxt = Proof_Data(
   struct 
    type T = PPlan.T 
    fun init _ = PPlan.init_prf 
   end);
