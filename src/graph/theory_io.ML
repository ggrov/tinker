signature PSGRAPH_THEORY_IO =
sig

  structure Theory : GRAPHICAL_THEORY 
  structure OutputGraphDot : OUTPUT_DOT 
  sharing type Theory.Graph.T = OutputGraphDot.data
(*
  val out_json : Theory.Graph.T -> Json.json
  val in_json : Json.json -> Theory.Graph.T
*)
  val dot_graph : Theory.Graph.T -> string
  val write_dot : string -> Theory.Graph.T -> unit
  val write_json_file: string -> Theory.Graph.T  -> unit

end

functor PSGraph_Theory_IOFun (structure PSTheory : PS_THEORY) : PSGRAPH_THEORY_IO =
struct
  structure Data = PSTheory.Data
  structure Theory = PSTheory.Theory
  structure PSDataIO = PSTheory.PSDataIO

  structure OutputGraphDot = OutputGraphDot(
    structure Graph = Theory.Graph
    structure DotStyle = PSDataIO.DotStyle
  );
  
  val dot_graph = OutputGraphDot.output

 (* always rewrite the opened file *)
 (* fix it : currently output some unecessary string on the top of dot fule, a new version of Graphz is needed ? *)
 fun write_dot path g = File_Io.write_string path (dot_graph g)

  fun write_json_file path g = ();
end
