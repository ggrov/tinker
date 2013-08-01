structure GraphDot =
struct
  structure Graph = Strategy_Theory.Graph
  structure GData = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData;

  fun pretty_node g v = V.pretty_name v
  fun pretty_edge g e = GData.pretty_edata (Graph.get_edge_data g e);

  fun is_rtechn (GData.RT _) = true
   |  is_rtechn (GData.GN _) = true
   |  is_rtechn _ = false;

  val node_str = GData.pretty_vdata |> Pretty.string_of;

  fun node_style g v = 
     case Graph.get_vertex g v of 
       (Graph.OVData.NVert node) => 
        (if is_rtechn node 
          then " [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"" ^ (node_str node) ^ "\"]"
          else  " [style=filled,fillcolor=white,fontcolor=black,shape=circle,label=" ^ (node_str node) ^ "]")
      | _ => " [style=filled,fillcolor=gray,shape=box,width=0,height=0,fontcolor=white]"


  fun node_block graph = let
    val boxtab = Graph.get_bbox_table graph
    fun sty nm = case Graph.get_vertex graph nm
                   of (Graph.OVData.NVert (DB_VertexData.RT rt), _) => " [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"" ^(RTechn.get_name rt)^ "\"]"
                    | (Graph.OVData.NVert (DB_VertexData.GN gn), _) => " [style=filled,fillcolor=white,fontcolor=black,shape=circle,label=" ^(GNode.get_goal gn)^ "]"
                    | (Graph.OVData.NVert (DB_VertexData.GVar x), _) => node_str
                    | (Graph.OVData.NVert (DB_VertexData.RVar x), _) => " [style=filled,fillcolor=grey,fontcolor=black,shape=box,label=" ^x^ "]"
                    | (Graph.OVData.WVert, _) => " [style=filled,fillcolor=gray,shape=box,width=0,height=0,fontcolor=white]"
    fun f nm list = (pretty_node graph nm)::
                    (Pretty.str (sty nm))::
                    (Pretty.str ";\n")::
                    list
    fun box_f (box,vset) list = 
      (Pretty.str "subgraph cluster_")::
      (B.pretty_name box)::
      (Pretty.str " {\n")::
      (V.NSet.fold_rev f vset
      (Pretty.str "}\n"::list))
  in B.NTab.fold box_f boxtab (V.NSet.fold_rev f (Graph.get_unbboxed graph) [])
  end
  
  fun edge_block graph = let
    fun f nm list = let
      val (_, (s,t)) = Graph.get_edge graph nm
    in (pretty_node graph s)::
       (Pretty.str " -> ")::
       (pretty_node graph t)::
       (Pretty.str " [label=\"")::
       (pretty_edge graph nm)::
       (Pretty.str "\"];\n")::list
    end
  in E.NSet.fold_rev f (Graph.get_enames graph) []
  end
  
  fun output graph = Pretty.string_of (Pretty.block (
    [Pretty.str "digraph G {\n"] @
    node_block graph @
    edge_block graph @
    [Pretty.str "}\n"]
  ))

  fun write_dot_to_file wire_details fname graph =
     let 
       val str = Print_Mode.setmp [] (fn () => output wire_details graph) ();
       val outs = TextIO.openOut fname; 
       val _ = TextIO.output (outs,str)
     in 
       TextIO.closeOut outs
     end;
end
