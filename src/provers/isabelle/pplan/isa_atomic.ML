structure IsaAtomic : ATOMIC =
struct

  exception atomic_exp of string

  type fact = Thm.thm
  type assm = Thm.thm
  type pplan = PPlan.T
  type pnode = PNode.T
  type context = Proof.context
  type tactic = Proof.context -> Tactical.tactic
  type concl = Thm.thm

  datatype Object =  Fact of fact | Assm of assm | Concl of concl (*| Pair of (Object * Object) *)

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
  val get_pnode_concl = PNode.get_goal;
  val get_pnode_ctxt = PNode.get_ctxt;

  fun init_with_assm _ _ _ =   (* a dummy init which is not used in isabelle by LYH*)
    raise atomic_exp "init_with_assm should not be used in isabelle"

  fun get_all_assms _ = []

  fun get_open_pnodes pplan = [] (* ??? list of pnode*)

  fun get_all_named_facts_pair pnode = [] (* ??? *)

  fun init ctxt thm =
    PPlan.init ctxt (Thm.concl_of thm)

  val psgraph_prover_i = "isabelle";
 
  fun intf_pprint pretty = Pretty.writeln pretty
 
  fun pretty_concl pnode = 
    Pretty.block
     [Pretty.str "[ Goal ",
     Pretty.str (get_pnode_name pnode),
     Pretty.str " : ",
     Syntax.pretty_term (get_pnode_ctxt pnode) (get_pnode_concl pnode|> Thm.prop_of),
     Pretty.str " ]"]

 
  structure Sharing =
  struct
    type fact = fact
    type tactic = tactic
    type pplan = pplan
    type pnode = pnode
    type context = context
    type concl = concl
    type assm = assm
    type Object = Object
  end

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

end;

