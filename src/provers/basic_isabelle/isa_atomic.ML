structure BIsaAtomic : ATOMIC =
struct
  type fact = Thm.thm

  type pnode = string * Thm.thm
  datatype pplan' = Closed of pnode * (pplan list)
                  | Open of pnode (* string is the name *)
  
  datatype pplan = StrName.NSet.T * pplan'

  type tactic = Proof.context -> Tactical.tactic

  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  fun apply_rule name thm (pnode,pplan) = Seq.empty;

  fun apply_erule name thm (pnode,pplan) = Seq.empty;

  fun apply_frule  (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = Seq.empty;

  fun apply_subst name thm (pnode,pplan) = Seq.empty;

  fun apply_subst_asm (fst_nm,fst_thm) (snd_nm,snd_thm) (pnode,pplan) = Seq.empty 

  fun apply_tactic name thms tac (pnode,pplan) = Seq.empty;

  fun lookup_fact pnode name = 
    Global_Theory.get_thm 
         (Proof_Context.theory_of (PNode.get_ctxt pnode)) name)
        handle _ => NONE

  fun get_all_facts pnode = []

  fun get_all_name_facts pnode = []

  val get_pnode_name = PNode.get_name;
  
  val get_pnode_goal = PNode.get_goal
