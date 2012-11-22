(*
   contains stuff releated to lifted a pnode to a gnode and add it to a wire
*)
structure EvalOutput =
struct

  exception gnode_exp of string

  fun matching_hyps fmap pnode bwire = 
    StrName.NSet.filter 
      (fn hname => WMatch.bwire_match fmap (PNode.get_ctxt pnode) bwire 
                                      (StrName.NTab.get (PNode.get_assms pnode) hname))
      (PNode.get_lassms pnode)

  fun upd_hyp fmap pnode bwire gnode =
     matching_hyps fmap pnode bwire
     |> (fn gs => GNode.add_facts (bwire,gs) gnode)

  fun upd_hyps_by_wire fmap gnode pnode wire =
    BW.NSet.fold 
     (upd_hyp fmap pnode)
     (Wire.get_facts wire)
     gnode;

  (* make gnode into a function *)
  fun upd_goal_by_wire fmap gnode pnode wire = 
    if WMatch.bwire_match 
             fmap 
             (PNode.get_ctxt pnode) (Wire.get_goal wire) (PNode.get_goal pnode) 
    then SOME gnode 
    else NONE
    handle _ => NONE;

  fun upd_by_wire fmap gnode pnode wire =
    case upd_goal_by_wire fmap gnode pnode wire 
     of NONE => NONE
     |  (SOME gn) => SOME (wire,upd_hyps_by_wire fmap gn pnode wire);

  (* what if there are more than one? or none? 
      -> currently fails! 
  *)  
  fun lift_gnode_by_wires fmap gnode wset pnode =
    let 
      fun prj_unique [] = raise gnode_exp "no matching outputs"
       |  prj_unique [SOME g] = g
       |  prj_unique _ = raise gnode_exp "many matching outputs"
    in 
      map (upd_by_wire fmap gnode pnode) (W.NSet.list_of wset)
      |> filter (Option.isSome)
      |> prj_unique
    end;

  fun lift_pnode_by_wires fmap wset pnode =
    lift_gnode_by_wires fmap (GNode.mk_goal_no_facts (PNode.get_name pnode)) wset pnode

  fun upd_by_wires fmap gnode wset pnode =
    let 
      val gnode' = gnode
                 |> GNode.set_prev (SOME gnode)
                 |> GNode.set_goal (PNode.get_name pnode)
    in
      lift_gnode_by_wires fmap gnode' wset pnode
    end;

end (* structure *)
