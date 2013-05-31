structure IsaAtomic : ATOMIC =
struct
  type fact = Thm.thm
  type pplan = PPlan.T
  type pnode = PNode.T
  type tactic = Proof.context -> Tactical.tactic
  type concl = Term.term  
  type context = Proof.context

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  fun apply_rule name thm (pnode,pplan) =
    PPlan.apply_tac (K (rtac thm 1)) (PNode.DRule name) (pnode,pplan);

  fun apply_erule name thm (pnode,pplan) =
    PPlan.apply_tac (K (etac thm 1)) (PNode.DErule name) (pnode,pplan);

  fun apply_frule  (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = 
     PPlan.add_fact (PNode.DFrule (fst_nm,snd_nm))  (fst_thm RS snd_thm) pplan pnode
     |> Seq.single;

  fun apply_subst name thm (pnode,pplan) = 
    PPlan.apply_tac (fn ctxt => EqSubst.eqsubst_tac ctxt [0] [thm] 1)  
                    (PNode.DSubst name) (pnode,pplan);

  (* to do: or raise exception? *)
  fun apply_subst_asm (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = Seq.empty 

  (* to do: add name of facts *)
  fun apply_tactic name thms tac (pnode,pplan) =
    let
      val ins_tac = Method.insert_tac thms 1
      fun full_tac ctxt = ins_tac THEN (tac ctxt)
    in
      PPlan.apply_tac full_tac (PNode.DTac (name,[])) (pnode,pplan) 
    end;

  fun lookup_fact pnode name = 
    case StrName.NTab.lookup (PNode.get_assms pnode) name of
      SOME thm => SOME thm
     | NONE => 
        SOME (Global_Theory.get_thm 
               (Proof_Context.theory_of (PNode.get_ctxt pnode))
               name)
        handle _ => NONE

   fun get_all_facts pnode =
       (PNode.get_assms pnode) 
       |> StrName.NTab.values;

   fun get_all_name_facts pnode =
       (PNode.get_assms pnode) 
       |> StrName.NTab.list_of;

  val get_pnode_name = PNode.get_name;
  
  val get_pnode_ctxt = PNode.get_ctxt
  
  val get_pnode_concl = PNode.get_goal
 

  (* OLD STUFF *)

   (* should also be split! *)
   fun old_erule_tac fact thm = 
      (Method.insert_tac [thm] 1)
      THEN
      (etac fact 1);

  (*
   FIXME: function to substitute in asm - must be a simpler way
    (note new fact will be added to assumption the way proof is working)  
    thm -> thm -> Proof.context -> tactic 
  *)
  fun old_subst_fact_tac thm thm_eq ctxt =
    let (* should always have at least one *)
      fun ngls thm = (Thm.prems_of thm |> hd |> Logic.count_prems) - 1;
    in
     (Method.insert_tac [thm] 1) (* insert fact *)
     THEN
     (fn thm => Tactic.rotate_tac (ngls thm) 1 thm) (* move fact to front *)
     THEN
     (EqSubst.eqsubst_asm_tac ctxt [1] [thm_eq] 1)
    end;

  structure Sharing =
  struct
    type fact = fact
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
    type context = context
    type concl = concl
  end

end;

