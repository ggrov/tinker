signature Eval_APP =
sig
  structure EData : EVAL_DATA
  
  val apply_appf : 
        EData.T 
      -> string (* the name of the goal *)
      -> RTechn.atomic (* application function *)
      -> (EData.Atomic.pplan * EData.Atomic.pnode list) Seq.seq

  val apply_tactic :
        EData.T 
      -> string (* the name of the goal *)
      -> string (* the name of the tactic *)
      -> RTechn.tac_assms (* tactic assumption *)
      -> (EData.Atomic.pplan * EData.Atomic.pnode list) Seq.seq

end

functor EvalAppf(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Atomic = EData.Atomic;

  exception no_such_fact of string
  exception eval_appf_exp of string;

  fun lookup_fact edata node_name name = 
   case Atomic.lookup_fact name (EData.get_goal edata node_name) of
      NONE => raise no_such_fact name
    | SOME f => f

  fun try_lookup_fact edata node_name name = 
   case Atomic.lookup_fact name (EData.get_goal edata node_name) of
      NONE => []
    | SOME f => [f]

  fun fact_list edata node_name thm_nms =
      thm_nms 
      |> StrName.NSet.list_of 
      |> map (lookup_fact edata node_name)

   fun fact_seq edata node_name thm_nms =
     Seq.of_list (fact_list edata node_name thm_nms);

(*
    fun assms_seq edata gnode fact_nms =
      fact_nms 
      |> StrName.NSet.list_of 
      |> map (PNode.get_hyp (EData.get_goal edata (GNode.get_goal gnode)))
      |> Seq.of_list;
*)

(*
   fun thm_seq_of_bwire_nm edata gnode bwire_nm = 
     (case GNode.lookup_facts (SStrName.mk bwire_nm) gnode
         of NONE => GFact.NSet.empty
                 | (SOME ns) => ns)
      |> assms_seq edata gnode
*)



  fun apply_tactic edata gnode tac_name RTechn.TNoAsm = 
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
       in 
         Atomic.apply_tactic [] tac (pplan,pnode)
       end
   |  apply_tactic edata gnode tac_name RTechn.TAllAsm = 
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
         val facts = Atomic.get_all_facts pnode
       in 
         Atomic.apply_tactic facts tac (pplan,pnode)
       end
   |  apply_tactic edata gnode tac_name (RTechn.TClass class_name) =
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode);
         val

         fun lookup_fact fname = case GNode.lookup_facts (C.mk fname) gnode
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
