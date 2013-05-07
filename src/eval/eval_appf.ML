(* 
  Contains link between application of rule/tac/.. and the update of the proof object.a
*)
structure EvalAppf =
struct

  exception eval_appf_exp of string;

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

    fun thm_list edata gnode thm_nms =
      thm_nms 
      |> StrName.NSet.list_of 
      |> map (get_thm edata gnode)

    fun thm_seq edata gnode thm_nms =
     Seq.of_list (thm_list edata gnode thm_nms);

    fun assms_seq edata gnode fact_nms =
      fact_nms 
      |> StrName.NSet.list_of 
      |> map (PNode.get_hyp (EData.get_goal edata (GNode.get_goal gnode)))
      |> Seq.of_list;

   fun thm_seq_of_bwire_nm edata gnode bwire_nm = 
     (case GNode.lookup_facts (SStrName.mk bwire_nm) gnode
         of NONE => GFact.NSet.empty
                 | (SOME ns) => ns)
      |> assms_seq edata gnode

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

  fun apply_tactic edata gnode tac_name RTechn.TNoAsm = 
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode)
         val pplan = EData.get_pplan edata
         val tac = StrName.NTab.get (EData.get_tactics edata) tac_name
       in 
         PPlanEnv.apply_tactic (pnode,pplan) tac_name (tac [] (PNode.get_ctxt pnode))
       end
   |  apply_tactic edata gnode tac_name RTechn.TAllAsm = 
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode)
         val pplan = EData.get_pplan edata
         val tac = StrName.NTab.get (EData.get_tactics edata) tac_name
       in 
         PPlanEnv.apply_tactic_all_asm (pnode,pplan) tac_name (tac [])
       end
   |  apply_tactic edata gnode tac_name (RTechn.TClass bwire_nms) =
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode);
         fun lookup_fact fname = case GNode.lookup_facts (SStrName.mk fname) gnode
                                  of NONE => GFact.NSet.empty
                                   | (SOME ns) => ns
         val fnames =
           StrName.NSet.fold 
             (fn wn => GFact.NSet.union_merge (lookup_fact wn))
             GFact.NSet.empty
             bwire_nms
         val facts = map (StrName.NTab.get (PNode.get_assms pnode))
                         (GFact.NSet.list_of fnames);
         val tac = StrName.NTab.get (EData.get_tactics edata) tac_name
       in
         pnode
         |> PNode.get_ctxt
         |> tac facts
         |> PPlanEnv.apply_tactic (pnode, EData.get_pplan edata) tac_name
       end;


  (* Fixme: update so that proof captures rules *)
  fun apply_appf edata gnode (RTechn.Rule thm_nms) =
     thm_seq edata gnode thm_nms
     |> Seq.maps (fn thm => PPlanEnv.apply_rule (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata)
                                                (Thm.derivation_name thm)
                                                 thm)
(*
   |  apply_appf edata gnode (RTechn.ERule (bwire_nm,thm_nms)) =
         let
          val thms = thm_list edata gnode thm_nms
          val new_hyps = thm_seq_of_bwire_nm edata gnode bwire_nm |> Seq.list_of
        in
          fold 
            (fn hyp => fn (gs,prf) => Seq.maps (erule_tac fact) thms)
            new_hyps
        end
*)
   (* TODO: fixme - needs testing! *)
   |  apply_appf edata gnode (RTechn.FRule (bwire_nm,thm_nms)) =
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
   |  apply_appf edata gnode (RTechn.Subst thm_nms) = 
       thm_list edata gnode thm_nms
       |> PPlanEnv.apply_subst (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata) "subst(FIXME)"
      (* should I capture failure here or should we just let it fail? *)
   |  apply_appf edata gnode (RTechn.SubstAsm (bwire_nm,thm_nms)) =  (* why not a wire? *)
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
   |  apply_appf edata gnode (RTechn.Tactic (tac_data,name)) =
        apply_tactic edata gnode name tac_data
   |  apply_appf _ _ _ = raise eval_appf_exp "unknown application type";

end (* structure *)
