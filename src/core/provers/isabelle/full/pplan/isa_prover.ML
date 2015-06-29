structure IsaProver : PROVER (*: ATOMIC *) =
struct
  type pos = int list
  type typ = typ
  type term = Term.term  
  type thm = Thm.thm
  type context = Proof.context

  type fact = thm
  type concl = thm
  type pnode = PNode.T
    (* could also hold the thm? *)
  type pplan = PPlan.T

  type tactic = Proof.context -> Tactical.tactic
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  datatype Object =  Fact of fact | Concl of concl

  exception gterm_exp

  val current_ctxt = @{context}
  val typ_of = Term.type_of
  fun match ctxt = Pattern.matches (Context.Proof_Context.theory_of ctxt)
  fun eq_pos (pos1, pos2) = 
    let 
      fun if_eq pos1 (x :: xs) = if ( hd pos1 = x) then if_eq (tl pos1) xs else false
        | if_eq _ [] = true
    in 
      if List.length pos1 = List.length pos2 then if_eq pos1 pos2 else false
    end
  fun root_of_trm trm = fst (Term.strip_comb trm)
  fun subtrm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(Term.strip_comb t), x))) pos trm
  fun trm_of_pos pos trm = fold (fn x => (fn t => List.nth (snd(Term.strip_comb t), x))) pos trm 
                           |> Term.strip_comb 
                           |> fst;

  (*val trm_of_thm = Thm.prop_of;*)

  val trm_of_string = Syntax.parse_term;
  val string_of_trm = Syntax.string_of_term;
  val pretty_trm = Syntax.pretty_term;

  fun intlist_of_pos pos = pos
  fun pos_of_intlist il = il
  
  val asms_of_thm = Thm.prems_of
  val concl_of_thm = Thm.concl_of

(* Atomi part *)
  exception atomic_exp of string

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
       (PNode.get_all_assms pnode);

   fun get_all_name_facts pnode =
       (PNode.get_assms pnode) 
       |> StrName.NTab.list_of;

  val get_pnode_name = PNode.get_name;
  val get_pnode_concl = PNode.get_goal;
  val get_pnode_ctxt = PNode.get_ctxt;

  fun init_with_assm _ _ _ =   (* a dummy init which is not used in isabelle by LYH*)
    raise atomic_exp "init_with_assm should not be used in isabelle"

  val get_all_assms = get_all_facts;

  (* will not fail gracefully, but all open nodes should be in pplan *)
  fun get_open_pnodes pplan = PPlan.get_open_nms pplan
                             |> StrName.NSet.list_of
                             |> map (the o PPlan.lookup_node pplan)
  handle _ => [];

  fun get_all_named_facts_pair pnode =
     PNode.get_assms pnode 
     |> StrName.NTab.list_of;

  val init = PPlan.init

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
    type pos = pos
    type typ = typ
    type term = term
    type thm = thm
    type context = context
    type tactic = tactic
    type concl = concl
    type fact = fact
    type pplan = pplan
    type pnode = pnode
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

