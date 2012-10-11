structure EvalAtomic =
struct

  exception rtechn_exp of RTechn.T * string
  exception gnode_exp of string
  exception graph_exp of string * Strategy_Theory.Graph.T
 
  (* should be a functor - df is default *)
  structure EData = EvalD_DF;

(*
  fun get_pnode ctxt gnode = PNode_Ctxt.get_goal ctxt (GNode.get_goal gnode);
*)
  fun upd_gnode_goal goal gnode = gnode
                                |> GNode.set_prev (SOME gnode)
                                |> GNode.set_goal (PNode.get_name goal);

  fun matching_hyps fmap gnode pnode bwire = 
    StrName.NSet.filter 
      (fn hname => WMatch.bwire_match fmap (PNode.get_ctxt pnode) bwire 
                                      (StrName.NTab.get (PNode.get_assms pnode) hname))
      (PNode.get_lassms pnode)

  fun upd_hyp fmap pnode bwire gnode =
     matching_hyps fmap gnode pnode bwire
     |> (fn gs => GNode.add_facts (bwire,gs) gnode)

  fun upd_hyps_by_wire fmap gnode pnode wire =
    BW.NSet.fold 
     (upd_hyp fmap pnode)
     (Wire.get_facts wire)
     gnode;

  fun upd_goal_by_wire fmap gnode pnode wire = 
    if WMatch.bwire_match 
             fmap 
             (PNode.get_ctxt pnode) (Wire.get_goal wire) (PNode.get_goal pnode) 
    then SOME (upd_gnode_goal pnode gnode) 
    else NONE
    handle _ => NONE;

  fun upd_by_wire fmap gnode pnode wire =
    case upd_goal_by_wire fmap gnode pnode wire 
     of NONE => NONE
     |  (SOME gn) => SOME (wire,upd_hyps_by_wire fmap gn pnode wire);

  (* what if there are more than one? or none? 
      -> currently fails! 
  *)  
  fun upd_by_wires fmap gnode wset pnode =
    let 
      fun prj_unique [] = raise gnode_exp "no matching outputs"
       |  prj_unique [SOME g] = g
       |  prj_unique _ = raise gnode_exp "many matching outputs"
    in 
      map (upd_by_wire fmap gnode pnode) (W.NSet.list_of wset)
      |> filter (Option.isSome)
      |> prj_unique
    end;

  (* ignores hyps and wire *)
  fun upd_rule wset edata gnode (pnds,prf) = 
    let
     val edata' = edata
               |> EData.set_pplan prf (* updates proof in context *)
               |> EData.del_goal (GNode.get_goal gnode) (* deletes goal from ctxt (now in prf) *)
               |> EData.add_goals pnds
   in
      (edata',map (upd_by_wires (EData.get_fmatch edata) gnode wset) pnds)
   end

end (* structure *)
