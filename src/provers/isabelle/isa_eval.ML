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

apply_rule in isabelle

(fn thm => PPlanEnv.apply_rule (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata)
                                                (Thm.derivation_name thm)
                                                 thm)

apply_frule in isabelle

         let
          val snd_thms = thm_list edata gnode thm_nms
          val fst_thms = thm_seq_of_bwire_nm edata gnode bwire_nm |> Seq.list_of
        in
           PPlanEnv.apply_frule
              (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata) 
              fst_thms 
              snd_thms
           |> Seq.single
        end

apply subst_asm in isabelle
       let
          val thm_eqs = thm_seq edata gnode thm_nms
          val thms = thm_seq_of_bwire_nm edata gnode bwire_nm
        in
           Seq.maps (fn fact =>
             Seq.maps (fn eq =>
                 PPlanEnv.apply_ctxt_tactic
                  (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata) "subst-asm (FIXME: shouldn't be tac"
                  (subst_fact_tac fact eq)) 
                thm_eqs) 
             thms
        end

         PPlanEnv.apply_tactic (pnode,pplan) tac_name (tac [] (PNode.get_ctxt pnode))
end
