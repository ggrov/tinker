structure EvalGraph =
struct

  (* consume of input and generation of output nodes *)  

  fun delete_input_rule (gnode,w) = 
    let
      val (inp,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                   |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
      val (outp,g1) = g0
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                    |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
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

  fun output_gnode (wr,rtechn) (w,gnode) = 
    let
      val (v_rt,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
      val (outp,g1) = g0
                    |> GraphEnv.add_boundary_to (DB_EdgeData.W wr) v_rt (* input edge *)
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                    |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
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

  (* creates a graph to match *)
  fun mk_match_graph graph v =
    let 
     val ins = Strategy_Theory.Graph.in_enames graph v  
     val outs = Strategy_Theory.Graph.out_enames graph v
     val get_wire = GraphEnv.e_to_wire graph
     val rtechn = GraphEnv.v_to_rtechn graph v
     (* graph with rtechn *)
     val (v_rt,g) = Strategy_Theory.Graph.empty
               |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
     (* adding goalnode variable *)
     val (v_gvar,g) = 
            Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GVar "g")) g
     fun mk_match_graph' inp = g
         |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W (get_wire inp)) v_gvar v_rt
         |> snd
         |> GraphEnv.add_boundary_to (DB_EdgeData.W (get_wire inp)) v_gvar
         |> E.NSet.fold (fn outp => GraphEnv.add_boundary_from (DB_EdgeData.W (get_wire outp)) v_rt) outs
         (* empty input for remaining input (so rewriting works) *)
         |> E.NSet.fold (fn o_inp => GraphEnv.add_boundary_from (DB_EdgeData.W (get_wire o_inp)) v_rt) 
                        (E.NSet.delete' inp ins) 
   in
     map mk_match_graph' (E.NSet.list_of ins)
   end;
    
end (* structure *)
