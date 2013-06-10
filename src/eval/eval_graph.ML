signature EVAL_GRAPH =
sig
  structure GoalTyp : BASIC_GOALTYPE
  structure Atomic : ATOMIC

end

functor EvalGraphFun(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Atomic = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Atomic;
  structure Theory = EData.PSGraph.PSTheory.PS_Theory;
  structure Graph = Theory.Graph;
  structure GData = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData;

  (* move into separate/different file? *) 
  structure Util =
  struct
      (* actual rewriting *)
    fun rewrite_lazy rule graph = 
      let 
        val graph' = Graph.normalise graph;
        val (rule',matches) = Theory.Rewriter.find_matches rule graph';
        fun rewr match = 
          Theory.Rewriter.rewrite_at rule' match
          |> snd
      in
        Seq.map rewr matches
      end;
    val rewrite = Seq.list_of oo rewrite_lazy;


  fun input_boundary g = 
    let val bvertexes = Graph.get_boundary g (* Vertex.NSet.T *)
        fun dest_name bv e = let val ((_,ed),(_,v)) = Graph.get_edge g e in (bv,(e,ed),v) end
        fun mk_pairs v = Graph.out_enames g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

    fun edge_dest g e = Graph.get_edge g e |> (snd o snd);
    fun edge_src g e = Graph.get_edge g e |> (fst o snd);
    fun edge_data g e = Graph.get_edge g e |> fst |> snd;

   (* checks data *)
    fun lookup_ivertex_data g v = 
      Graph.get_vertex_data g v 
      |> Graph.OVData.idata_of 

   val vertex_data = the oo lookup_ivertex_data;

   fun out_edges graph v = 
      Graph.out_enames graph v 
      |> E.NSet.list_of;

    fun insert_node_on_edge node edge graph0 =
      let val (l,graph') = Graph.add_vertex (Graph.OVData.NVert node) graph0
          val from = edge_src graph' edge
          val to = edge_dest graph' edge
          val edata = edge_data graph' edge
      in
        graph' |> Graph.delete_edge edge 
               |> Graph.doadd_edge (Graph.Directed,edata) from l
               |> Graph.doadd_edge (Graph.Directed,edata) l to
      end;

    (* assumes: 1/1 - so just replace by wire node *)
    val del_gnode = Graph.update_vertex_data (K Graph.OVData.WVert);

   fun mk_binput edata dest graph =
     graph |> Graph.add_vertex Graph.OVData.WVert
           |> (fn (n,g) => (n,Graph.add_to_boundary n g))
           |> (fn (n,g) => Graph.doadd_edge (Graph.Directed, edata) n dest g);

   fun mk_boutput edata source graph =
     graph |> Graph.add_vertex Graph.OVData.WVert
           |> (fn (n,g) => (n,Graph.add_to_boundary n g))
           |> (fn (n,g) => Graph.doadd_edge (Graph.Directed, edata) source n g);

   (* checks type *)
   fun is_gtyp graph e = 
     case edge_data graph e of (GData.GT _) => true | _ => false;
   fun is_rtechn graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.RT _) => true
       | _ => false; 
   fun is_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.GN _) => true
       | _ => false; 

   (* lookup node *)
   fun lookup_rtechn graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.RT rt) => SOME rt
       | _ => NONE; 
   fun lookup_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.GN gn) => SOME gn
       | _ => NONE; 

   (* projects goal types - exception if not existing *)
   fun gtyp_of graph e = 
     case edge_data graph e of (GData.GT g) => g   (* |  _ => raise error *);
   fun rtechn_of graph v = 
     case vertex_data graph v of (GData.RT rt) => rt; 
   fun gnode_of graph v = 
     case vertex_data graph v of (GData.GN gn) => gn
   fun single_gnode_of graph v = 
     case vertex_data graph v of (GData.GN [GData.GN_Node gnode]) => gnode;

   fun mk_single_gnode gnode = GData.GN [GData.GN_Node gnode];

   (* projects *)
   fun all_rtechns graph = 
     map fst (Graph.get_vertex_list graph)
     |> filter (is_rtechn graph);

   fun all_gnodes graph = 
     map fst (Graph.get_vertex_list graph)
     |> filter (is_gnode graph);

  end (* structure Util *)
 
  (* FIXME: makes one for each input - can be generalised by vars on the edges
     instead - then we only need on lhs per rule  *)
  fun mk_lhs graph v =
    let 
     val ins = Graph.in_enames graph v  
     val outs = Graph.out_enames graph v
     val gtyp = Util.gtyp_of
     val gnode = Graph.OVData.NVert (GData.GN [(GData.GN_Var "g")])
     val rtechn  = Util.rtechn_of graph v
     (* graph with rtechn *)
     val (v_rt,g) = Graph.empty
               |> Graph.add_vertex (Graph.OVData.NVert (GData.RT rtechn))
     (* adding goalnode variable *)
     val (v_gvar,g) = Graph.add_vertex gnode g 
     (* one lhs for each input node *)
     fun mk_lhs' inp = g
         |> Graph.doadd_edge (Graph.Directed,GData.GT (gtyp graph inp)) v_gvar v_rt
         |> Util.mk_binput (GData.GT (gtyp graph inp)) v_gvar
         |> E.NSet.fold (fn outp => Util.mk_boutput (GData.GT (gtyp graph outp)) v_rt) outs
         |> E.NSet.fold (fn o_inp => Util.mk_binput (GData.GT (gtyp graph o_inp)) v_rt) 
                        (E.NSet.delete' inp ins) 
    in 
     map mk_lhs' (E.NSet.list_of ins)      (* one match per input *)
   end;

  (* Should be one rtechn and one graph *)
  fun match_lhs graph lhs =
     Theory.Rewriter.find_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
     |> snd
     |> Seq.map (fn m => (Theory.Match.get_match_subst m, Graph.apply_data_subst (Theory.Match.get_match_subst m) lhs));
        
  fun matched_lhs graph v = Seq.maps (match_lhs graph) (mk_lhs graph v |> Seq.of_list)

 (* vertex list -> partition -> graph -> graph *)
 fun add_outs [] [] graph = graph
  |  add_outs  (i::is) (p::ps) graph = 
       add_outs is ps (Util.insert_node_on_edge p i graph);
      
end (* functor *)
