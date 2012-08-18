structure EvalAtomic =
struct

  exception atomic_eval_exp of V.name * string
  exception goalnode_exp of GoalNode.T * string * V.name

  val flush_io = RState.reset_io;

  fun in_edge_no_edge_point g e = 
    let
        val inp_node = GraphComb.edge_src g e
    in
     if GraphComb.is_vdata g inp_node
      then inp_node
      else case  E.NSet.list_of (RTechn_Theory.Graph.in_enames g inp_node) of
              [e] => in_edge_no_edge_point g e
            | _ => raise atomic_eval_exp (inp_node,"Vertex (or pre vertex) does not have 1 input")
   end;

  val dummy = Unsynchronized.ref [];

  fun apply_atomic (g,rst,v) = (* assumes v is atomic! *)  
    let val (vdata,(in_edges,out_edges)) = RTechn_Theory.Graph.get_vertex g v
        val th = ProofContext.theory_of (RState.get_ctxt rst)
        val rt = RTechn_Ctxt.RState.get_rtechn rst (GraphComb.v_to_rtechn g v) (* fixme: convert vdata directly  *)
                 handle _ => raise atomic_eval_exp (v,"Vertex not a reasoning technique")
        val in_edge = case E.NSet.tryget_singleton in_edges of
                         NONE => raise atomic_eval_exp (v,"Vertex has more than one input")
                       | SOME e => e
        val inp_node = in_edge_no_edge_point g in_edge 
        val (wname,gndnms) = GraphComb.v_to_goalnode g inp_node
                    handle _ => raise atomic_eval_exp (v,"Vertex input not a goalnode")
       val _ = dummy := [(g,rst,v)] @ (!dummy)
       val (gnode as (bw,gnds)) = 
            (GNode_Ctxt.Wire.get wname rst, (* wire name *)
             gndnms |> GNodeKey.NSet.list_of (* goal nodes *)
                    |> map (fn gname => GNode_Ctxt.get gname rst)
                    |> GNode.GoalSet.of_list) 
    in 
     if not (RTechn.is_atomic rt)
      then raise atomic_eval_exp (v,"Reasoning technqiue not atomic")
     else if GoalNode.is_empty gnode
      then raise atomic_eval_exp (v,"Empty goalnode")
     else 
      rst |> flush_io
          |> RState.set_inputs_value gnode
          |> RTechn.apply_atomic rt
          |> Seq.map (fn rst => (rst,(in_edge,inp_node),out_edges))
     end;

  fun delete_input_node (graph,rst) node (inp_edge,inp_node) =
   let
    val (gnode as (w,nds)) = GraphComb.v_to_goalnode graph inp_node
    val rst' = 
      GNodeKey.NSet.fold
        GNode_Ctxt.delete
        nds
        (GNode_Ctxt.Wire.delete w rst) 
    val graph' =
      E.NSet.fold (* should really be just one! *)
        (GraphComb.change_edge_dest node) 
        (RTechn_Theory.Graph.in_enames graph inp_node)
        graph
     |> RTechn_Theory.Graph.delete_edge inp_edge
     |> RTechn_Theory.Graph.delete_vertex inp_node
  in
    (graph',rst')
  end;

  (* 
    very simplified: only matches overall wire and not each gnode
     - should really match each individually and only match those
       that fully matches!!
     - should also match goal with "features"
  *)

  fun simple_edge_match (gw,_) e graph rst =
    let 
      val (w,_) = GraphComb.edge_data graph e
                |> FWire_Ctxt.RState.get_wire rst
    in
      BWire.wire_match w gw
    end;
 
  val default_gname = V.mk "G";

  fun move_gnode (gnode as (bw,nds)) edges rst0 graph0 =
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
    |> Seq.map (update_io v g);
    
end (* structure *)
