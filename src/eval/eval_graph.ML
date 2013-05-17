signature EVAL_GRAPH =
sig
  structure GoalTyp : GOAL_TYP
  structure Atomic : ATOMIC

end

functor EvalGraphFun(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Atomic = EData.Atomic;
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
        val (rule',matches) = Theory.RulesetRewriter.rule_matches rule graph';
        fun rewr match = 
          Theory.GraphSubst.do_rewrite match (Theory.Rule.get_rhs rule')
      in
        Seq.map rewr matches
      end;
    val rewrite = Seq.list_of oo rewrite_lazy;

    fun edge_dest g e = Graph.get_edge g e |> (snd o snd);
    fun edge_src g e = Graph.get_edge g e |> (fst o snd);
    fun edge_data g e = Graph.get_edge g e |> fst |> snd;

   fun vertex_data g v = 
     Graph.get_vertex_data g v 
     |> Graph.OVData.idata_of 
     |> the;

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


   (* projects goal types - exception if not existing *)
   fun gtyp_of graph e = 
     case edge_data graph e of (GData.GT g) => g   (* |  _ => raise error *);
   fun rtechn_of graph v = 
     case vertex_data graph v of (GData.RT rt) => rt; 
   fun gnode_of graph v = 
     case vertex_data graph v of (GData.GN gn) => gn

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

  (* add output nodes - fixme: this is based on partition now moved
     to eval atomic! *) 
(*
  fun add_outs gnode pnds goal_typs graph v =
   let
     val ins = Graph.in_enames graph v 
             |> E.NSet.list_of
     val parts = ins 
               |> map (Util.gtyp_of graph)
               |> partition pnds gnode 
               |> map partition_to_gnode;
     fun mk_out' g   []      []    = g
      |  mk_out' g (i::is) (p::ps) =
           mk_out' (Util.insert_node_on_edge p i g) is ps;
  in
    map (mk_out' graph ins) parts
  end;     
 *)  
      


end (* structure *)
