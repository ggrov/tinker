(*
functor GraphJSON(
  structure Graph : BANG_GRAPH
        and InputVertexData : INPUT_JSON
        and InputEdgeData : INPUT_JSON
        and OutputVertexData : OUTPUT_JSON
        and OutputEdgeData : OUTPUT_JSON
  sharing type InputVertexData.data = OutputVertexData.data = Graph.nvdata
  sharing type InputEdgeData.data = OutputEdgeData.data = Graph.edata
) : 

*)

functor PSGraph_Theory_IOFun (structure PSTheory : PS_THEORY) : PSGRAPH_THEORY_IO =
struct
  structure Data = PSTheory.Data
  structure PS_Theory = PSTheory
  structure PSDataIO = PSTheory.PSDataIO

(*   datatype nvdata = T_Atomic of { name : string, args : arg_typ}
                  | T_Graph of { name : string, args : arg_typ, is_or : bool}
                  | T_Identity | G_Break | G of GoalTyp.gnode | T_Var of string 
                  | G_Var of string 
*)

  structure InputVertexData : INPUT_JSON = 
  struct
      exception bad_input_exp of string*string;
      type T = Json.json
      type data = Data.nvdata
      val input = Data.nvdata_from_json
  end 
  
  structure OutputVertexData : OUTPUT_JSON =
    struct
     type T = Json.json
     type data = Data.nvdata
     val output = Data.nvdata_to_json
    end 

  structure InputEdgeData : INPUT_JSON = 
    struct
      exception bad_input_exp of string*string;
      type T = Json.json
      type data = Data.edata;
      val input = Data.edata_from_json
    end; 

  structure OutputEdgeData : OUTPUT_JSON =
    struct
      type T = Json.json
      type data = Data.edata;
      val output = Data.edata_to_json
    end;

  structure GraphJSON = GraphJSON (structure Graph = PS_Theory.Theory.Graph
                                   structure InputVertexData = InputVertexData
                                   structure InputEdgeData = InputEdgeData
                                   structure OutputVertexData = OutputVertexData
                                   structure OutputEdgeData = OutputEdgeData);

  structure OutputGraphDot = OutputGraphDot(
    structure Graph = PS_Theory.Theory.Graph
    structure DotStyle = PSDataIO.DotStyle
  );

  val dot_graph = OutputGraphDot.output

  val out_json = GraphJSON.output
  val in_json = GraphJSON.input

 (* always rewrite the opened file *)
 (* fix it : currently output some unecessary string on the top of dot fule, a new version of Graphz is needed ? *)
 fun write_dot path g = File_Io.write_string path (dot_graph g)

 fun write_json_file path g =  File_Io.write_string path (out_json g |> Json.encode);
 
 structure Sharing = 
 struct
  structure Data = PSTheory.Sharing.Data
 end
end
