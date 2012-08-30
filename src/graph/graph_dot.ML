(*
  based on Quantomatics: OutputGraphDot functor 

    to do: simplify output, remove whitespace, update name in rtechn when parsing
*)
structure Strategy_Dot =
struct
  structure Graph = Strategy_Theory.Graph
  structure DotStyle = Strategy_DotStyle
 


  fun pretty_node g v =
    case Strategy_OVData.idata_of (Graph.get_vertex_data g v) of
       NONE => V.pretty_name v
     | (SOME v) => DB_VertexData.pretty_node v;
  
  fun pretty_edge g e =
   DB_EdgeData.pretty_node (Graph.get_edge_data g e); 

  fun node_block graph = let
    val boxtab = Graph.get_bbox_table graph
    fun sty nm = case Graph.get_vertex graph nm
                   of (Graph.OVData.NVert data, _) => " " ^ (DotStyle.style_for_ivertex_data data)
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
       (Pretty.str " [label=")::
       (pretty_edge graph nm)::
       (Pretty.str "];\n")::list
    end
  in E.NSet.fold_rev f (Graph.get_enames graph) []
  end
  
  fun output graph = Pretty.string_of (Pretty.block (
    [Pretty.str "digraph G {\n"] @
    node_block graph @
    edge_block graph @
    [Pretty.str "}\n"]
  ))

  fun write_dot_to_file fname graph =
     let 
       val str = Print_Mode.setmp [] (fn () =>output graph) ();
       val outs = TextIO.openOut fname; 
       val _ = TextIO.output (outs,str)
     in 
       TextIO.closeOut outs
     end;


end
