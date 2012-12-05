structure PPlanEnv = 
struct

  fun apply_rule (gnode,prf) thm = PPlan.apply_tac (K (rtac thm 1)) (gnode,prf)

   (* TODO: fixme - not sure this is really frule! *)
  fun apply_frule' (gnode,prf) new_thms = 
      PPlan.add_facts new_thms prf gnode;
  
  (* tries to combine all possible fsts with snds *)
  (* fixme: try both ways? *)
  fun combine_thms fst_thms snd_thms =
    fold 
      (fn fst_thm =>
          fold 
            (fn snd_thm => fn res => res @ [(fst_thm RS snd_thm)] handle _ => res ) 
             snd_thms)
       fst_thms
       [];
   (* TODO: fixme - not sure this is really frule! *)  

  (* note: fst_thms: facts snd_thms: rules *) 
  fun apply_frule (gnode,prf) fst_thms snd_thms = 
        apply_frule' (gnode,prf)  (combine_thms fst_thms snd_thms);

  fun apply_erule (gnode,prf) thm = PPlan.apply_tac (K (etac thm 1)) (gnode,prf)

  fun apply_subst (gnode,prf) thms = 
    PPlan.apply_tac (fn ctxt => EqSubst.eqsubst_tac ctxt [0] thms 1) (gnode,prf);

  (* why K combinator - shouldn't this be removed from the graph *)
  fun apply_tactic (gnode,prf) tac = PPlan.apply_tac (K tac) (gnode,prf) 

  fun apply_ctxt_tactic (gnode,prf) tac = PPlan.apply_tac tac (gnode,prf) 
    
  fun apply_tactic_all_asm (gnode,prf) tac = PPlan.apply_all_asm_tac tac (gnode,prf);

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
