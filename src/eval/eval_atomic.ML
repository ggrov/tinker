structure EvalAtomic =
struct

  exception rtechn_exp of RTechn.T * string
  exception gnode_exp of string
 
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

    fun thm_seq edata gnode thm_nms =
      thm_nms 
      |> StrName.NSet.list_of 
      |> map (get_thm edata gnode)
      |> Seq.of_list;

  fun apply_appf edata wset gnode (RTechn.Rule thm_nms) =
     thm_seq edata gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_rule (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata))
     |> Seq.map (upd_rule wset edata gnode)
(*   |  apply_appf ctxt (RTechn.ERule (nbwire,thm_nms)) gnode =
     thm_seq gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_erule (gnode,prf) nbwire);
   |  apply_appf ctxt (RTechn.FRule (nbwire,thm_nms)) gnode =
     thm_seq gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_frule (gnode,prf) nbwire);
   |  apply_appf ctxt (RTechn.Subst thm_nms) gnode =
   |  apply_appf ctxt (RTechn.SubstAsm (nbwire,thm_nms)) gnode =
   |  apply_appf ctxt (RTechn.Tactic (bwire_nms,tac_name)) gnode =  *);

  
  fun delete_input_rule (gnode,w) = 
    let
      val (inp,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
      val (outp,g1) = g0
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
      val rhs = g1
             |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) inp outp
             |> snd
      val (v,g2) = g1
                 |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GN gnode)) 
      val lhs = g2 
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) inp v
              |> snd
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v outp
              |> snd
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;  

  fun output_gnode rtechn (w,gnode) = 
    let
      val (v_rt,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
      val (outp,g1) = g0
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
      val lhs = g1
             |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v_rt outp
             |> snd
      val (v,g2) = g1
                 |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GN gnode)) 
      val rhs = g2 
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v_rt v
              |> snd
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v outp
              |> snd
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;     

  fun mk_result (gnode,w) rtechn (edata,outgs) =
    (edata,delete_input_rule (gnode,w), map (output_gnode rtechn) outgs)
  
  fun eval_rtechn (gnode,w) rtechn edata =
   case RTechn.get_atomic rtechn
   of (SOME atom) => apply_appf edata (RTechn.get_outputs rtechn) gnode atom
                    |> Seq.map (mk_result (gnode,w) rtechn)
   | NONE => raise rtechn_exp (rtechn,"not atomic technique");

  (* lookup gnode and rtechn and eval and then apply eval_rtechn *)
  fun eval_v_rtechn (v_gnode,v_rtechn) (edata,graph) =
   let 
     val gnode = GraphEnv.v_to_gnode graph v_gnode
     val wire = case E.NSet.tryget_singleton (Strategy_Theory.Graph.out_enames graph v_gnode)
                of NONE => raise gnode_exp ("gnode does not have single output")
                | SOME e => GraphEnv.e_to_wire graph e
     val rtechn = GraphEnv.v_to_rtechn graph v_rtechn 
   in
    eval_rtechn (gnode,wire) rtechn edata
   end;
    
 

  (* maybe assume a subgraph with one gnode and one rtechn? *)


  (*   fun delete_input_node (v_techn,v_gnode,g) =
     E.NSet.fold
        (GraphComb.change_edge_dest node) 
        (RTechn_Theory.Graph.in_enames graph inp_node)
        graph
     |> RTechn_Theory.Graph.delete_edge inp_edge
     |> RTechn_Theory.Graph.delete_vertex inp_node
   *)

(*  fun move_gnode (gnode as (bw,nds)) edges rst0 graph0 =
    E.NSet.fold
    (fn e => fn (status,(graph,rst)) =>
       if simple_edge_match gnode e graph rst
         then
           let 
             val wname = bw
                       |> BWire.string_of
                       |> GNode_Ctxt.Wire.of_str
                       |> GNode_Ctxt.Wire.fresh_name rst
             val rst1 = GNode_Ctxt.Wire.add (wname,bw) rst0
             fun mk_node_ctxt gn (gs,rst) = 
                let 
                  val gnm = GNode.get_goal gn |> GNode_Ctxt.of_str |> GNode_Ctxt.fresh_name rst
                  val rst' = GNode_Ctxt.add (gnm,gn) rst
                in
                 (gs @ [gnm],rst')
                end;
             val (gnms,rst2) = GNode.GoalSet.fold mk_node_ctxt nds ([],rst1)
                             |> (fn (ls,rst) => (StrIntName.NSet.of_list ls,rst))
             val graph' = GraphComb.insert_goalnode (e,graph) (default_gname,(wname,gnms))
            in
              (true,(graph',rst2))
            end
         else (status,(graph,rst))) 
    edges
    (false,(graph0,rst0));


  fun delete_empty_gnodes gs = gs
    |> GoalNode.G.NSet.list_of
    |> filter (fn (_,gs) => not (GNode.GoalSet.is_empty gs))
    |> GoalNode.G.NSet.of_list;


  fun move_output v edges (graph0,rst0) =
    GoalNode.G.NSet.fold
    (fn gnode => fn (graph,rst) =>
       case move_gnode gnode edges rst graph of
         (true,graphrst) => graphrst
       | (false,_) => raise goalnode_exp (gnode,"no matching output wires",v))
    (delete_empty_gnodes (RState.get_outputs rst0))
    (graph0,rst0);
        
  fun update_io v g (rst,inps,out_edges) =
    delete_input_node (g,rst) v inps
    |> move_output v out_edges

  fun eval_atomic (g,rst,v) =
       apply_atomic (g,rst,v)
    |> Seq.map (update_io v g); *)
    
end (* structure *)
