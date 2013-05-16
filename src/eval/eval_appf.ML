signature EVAL_APP =
sig
  structure EData : EVAL_DATA
  
  val apply_appf : 
        EData.T 
      -> GNode.T (* the goal node  *)
      -> RTechn.atomic (* application function *)
      -> (EData.Atomic.pplan * EData.Atomic.pnode list) Seq.seq

  val apply_tactic :
        EData.T 
      -> GNode.T (* the goal node *)
      -> string (* the name of the tactic *)
      -> RTechn.tac_assms (* tactic assumption *)
      -> (EData.Atomic.pplan * EData.Atomic.pnode list) Seq.seq

end

functor EvalAppf(EData : EVAL_DATA) : EVAL_APP =
struct
  structure EData = EData;
  structure Atomic = EData.Atomic;

  exception no_such_fact of string
  exception eval_appf_exp of string;

  fun lookup_fact node name = 
   case Atomic.lookup_fact node name of
      NONE => raise no_such_fact name
    | SOME f => f

  fun try_lookup_fact node name = 
   case Atomic.lookup_fact node name of
      NONE => []
    | SOME f => [f]

  fun fact_list node fact_nms =
      fact_nms 
      |> StrName.NSet.list_of 
      |> map (lookup_fact node)

  val fact_seq = Seq.of_list oo fact_list;

  fun fact_seq_of_gnode edata gnode fact_nms =
    let 
      val pnode = EData.get_goal edata (GNode.get_goal gnode)
    in
     Seq.of_list (fact_list pnode fact_nms)
    end;

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
   |  apply_tactic edata gnode tac_name (RTechn.TClass class_nms) =
       let 
         val pnode = EData.get_goal edata (GNode.get_goal gnode)
         val pplan = EData.get_pplan edata
         val tac = EData.get_tactic edata tac_name
         fun lookup_fact fname = case GNode.lookup_fact_names fname gnode
                                  of NONE => StrName.NSet.empty
                                   | (SOME ns) => ns
         (* combines names of facts from all classes *)
         val fact_nms = C.NSet.fold 
                         (fn wn => StrName.NSet.union_merge (lookup_fact wn))
                         class_nms
                         StrName.NSet.empty
         (* get the actual facts *)
         val facts = fact_list pnode fact_nms
       in
         Atomic.apply_tactic facts tac (pplan,pnode)
       end;


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

  (* Fixme: update so that proof captures rules *)
  fun apply_appf edata gnode (RTechn.Rule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GNode.get_goal gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn fact => Atomic.apply_rule fact (pplan,pnode)) facts
        end
    |  apply_appf edata gnode (RTechn.ERule fact_nms) =
        let 
          val pnode = EData.get_goal edata (GNode.get_goal gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn fact => Atomic.apply_erule fact (pplan,pnode)) facts
        end
   |  apply_appf edata gnode (RTechn.FRule (class_nm,fact_nms)) =
        let 
          val pnode = EData.get_goal edata (GNode.get_goal gnode)
          val pplan = EData.get_pplan edata
          val hyps = GNode.get_fact_names class_nm gnode 
                     |> fact_seq pnode 
          val facts = fact_seq pnode fact_nms
          (* one application of a frule of a fact to a hyp *)
          fun apply_frule' hyp fact = Atomic.apply_frule hyp fact (pplan,pnode)
          (* application of all facts to a hyp *)
          fun apply_frule hyp = Seq.maps (apply_frule' hyp) facts
        in
           Seq.maps apply_frule hyps
        end
   |  apply_appf edata gnode (RTechn.Subst fact_nms) = 
        let 
          val pnode = EData.get_goal edata (GNode.get_goal gnode)
          val pplan = EData.get_pplan edata
          val facts = fact_seq pnode fact_nms
        in
          Seq.maps (fn fact => Atomic.apply_subst fact (pplan,pnode)) facts
        end
   |  apply_appf edata gnode (RTechn.SubstAsm (class_nm,fact_nms)) =  (* why not a wire? *)
         let 
          val pnode = EData.get_goal edata (GNode.get_goal gnode)
          val pplan = EData.get_pplan edata
          val hyps = GNode.get_fact_names class_nm gnode 
                     |> fact_seq pnode 
          val eqs = fact_seq pnode fact_nms
          (* one application of subst of a eq to a fact *)
          fun apply_subst_asm' hyp eq = Atomic.apply_subst_asm hyp eq (pplan,pnode)
          (* application of all equalities to a hyp *)
          fun apply_subst_asm hyp = Seq.maps (apply_subst_asm' hyp) eqs
        in
           Seq.maps apply_subst_asm hyps
        end
   |  apply_appf edata gnode (RTechn.Tactic (tac_data,name)) =
        apply_tactic edata gnode name tac_data
   |  apply_appf _ _ _ = raise eval_appf_exp "unknown application type";

end (* structure *)
