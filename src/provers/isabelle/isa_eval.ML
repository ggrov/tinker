structure IsaEv  =
struct 
       (* actual application of proof technique *)
    fun get_thm edata gnode name =
      let 
         val th = gnode
                |> GNode.get_goal 
                |> EData.get_goal edata
                |> PNode.get_ctxt
                |> Proof_Context.theory_of
      in
        Global_Theory.get_thm th name
      end;  

  (*
   FIXME: function to substitute in asm - must be a simpler way
    (note new fact will be added to assumption the way proof is working)  
    thm -> thm -> Proof.context -> tactic 
  *)
  fun subst_fact_tac thm thm_eq ctxt =
    let (* should always have at least one *)
      fun ngls thm = (Thm.prems_of thm |> hd |> Logic.count_prems) - 1;
    in
     (Method.insert_tac [thm] 1) (* insert fact *)
     THEN
     (fn thm => Tactic.rotate_tac (ngls thm) 1 thm) (* move fact to front *)
     THEN
     (EqSubst.eqsubst_asm_tac ctxt [1] [thm_eq] 1)
    end;

   (* should also be split! *)
   fun erule_tac fact thm = 
      (Method.insert_tac [thm] 1)
      THEN
      (etac fact 1);



         PPlanEnv.apply_tactic (pnode,pplan) tac_name (tac [] (PNode.get_ctxt pnode))
end
