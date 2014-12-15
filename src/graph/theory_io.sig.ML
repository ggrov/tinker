signature PSGRAPH_THEORY_IO_SHARING = 
sig
  structure Data : PSGRAPH_DATA_SHARING
end

signature PSGRAPH_THEORY_IO =
sig

  structure Theory : GRAPHICAL_THEORY 
  structure OutputGraphDot : OUTPUT_DOT 
  structure GraphJSON : GRAPH_JSON 

  sharing type Theory.Graph.T = OutputGraphDot.data = GraphJSON.Graph.T

  val out_json : Theory.Graph.T -> Json.json
  val in_json : Json.json -> Theory.Graph.T

  val dot_graph : Theory.Graph.T -> string
  val write_dot : string -> Theory.Graph.T -> unit
  val write_json_file: string -> Theory.Graph.T  -> unit

  structure Sharing : PSGRAPH_THEORY_IO_SHARING

end
