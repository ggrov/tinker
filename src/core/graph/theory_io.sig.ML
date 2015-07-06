signature PSGRAPH_THEORY_IO_SHARING = 
sig
  structure Data : PSGRAPH_DATA_SHARING
end

signature PSGRAPH_THEORY_IO =
sig

  structure PS_Theory : PS_THEORY 
  structure OutputGraphDot : OUTPUT_DOT 
  structure GraphJSON : GRAPH_JSON 

  sharing type PS_Theory.Theory.Graph.T = OutputGraphDot.data = GraphJSON.Graph.T

  val out_json : PS_Theory.Theory.Graph.T -> Json.json
  val in_json : Json.json -> PS_Theory.Theory.Graph.T

  val dot_graph : PS_Theory.Theory.Graph.T -> string
  val write_dot : string -> PS_Theory.Theory.Graph.T -> unit
  val write_json_file: string -> PS_Theory.Theory.Graph.T  -> unit

  structure Sharing : PSGRAPH_THEORY_IO_SHARING

end
