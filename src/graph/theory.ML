signature PS_THEORY = 
sig
  (* todo: sharing *)
  structure PS_GraphParam : PS_GRAPH_PARAM
  structure PS_Theory : GRAPHICAL_THEORY
  structure PS_Comb : GRAPH_COMB
  sharing type PS_Comb.Graph.T = PS_Theory.Graph.T
  sharing type PS_GraphParam.GraphSubstData.vdata = PS_Theory.Graph.OVData.IData.data
  sharing type PS_GraphParam.GraphSubstData.edata = PS_Theory.Graph.SharingBasicGraph.Param.EData.data
  sharing PS_Comb.Graph.EData = PS_Theory.Graph.SharingBasicGraph.Param.EData

  val out_json : PS_Theory.Graph.T -> Json.json
  val dot_graph : PS_Theory.Graph.T -> string
  val write_dot : string -> PS_Theory.Graph.T -> unit

  (* structure PS_TheoryIO :*)
end (* signature *)

functor PSTheoryFun(structure GoalTyp : BASIC_GOALTYPE) (*: PS_THEORY *) =
struct
(*  PS_Theory.Graph.OVData.IData.data is PS_GraphParam.VData *)
  structure PS_GraphParam = PSGraphParamFun(GoalTyp);

  structure PS_VertexComponentData_Param 
      = PS_GraphParam.PSVertexData.VComponentData_Param;
  structure PS_EdgeComponentData_Param 
      = PS_GraphParam.PSEdgeData.EComponentData_Param;

  structure PS_OVData = OVertexData(PS_GraphParam.VData);(* OVData *)
  structure PS_OGraphParam = OGraphParam(
    structure Param = PS_GraphParam 
          and OVData = PS_OVData);

  structure PS_OVertexComponentData_Param = OVertexComponentData_Param(
     structure VertexDataParam = PS_VertexComponentData_Param
     structure OVData = PS_OVData);

  structure PS_OVertexComponentData = 
     ElementComponentData(PS_OVertexComponentData_Param);

  structure PS_EdgeComponentData = 
    ElementComponentData(PS_EdgeComponentData_Param);

  (* Graphical theory *)
  structure PS_Theory = GraphicalTheory(
    structure OParam = PS_OGraphParam (*OVData is in here*)
    structure VComponentData = PS_OVertexComponentData
    structure EComponentData = PS_EdgeComponentData
  );

  structure PS_Graph = PS_Theory.Graph;
  (* COMBINATORS *)
  structure PS_Comb = GraphCombFun(PS_Graph);

  (* JSON IO *)
  structure PS_ComponentDataIO : GRAPH_COMPONENT_DATA_IO
  = struct
     type vdata = PS_GraphParam.PSVertexData.data;
     type edata = PS_GraphParam.PSEdgeData.data;
     structure GraphSubstData = PS_GraphParam.GraphSubstData;
     structure GoalTyp = GraphSubstData.GoalTyp;

      (* vertex data
         { type : RT | GN | TVar | GVar
           data : string | rtechn | array }
      *)
      structure IVDataInputJSON : INPUT_JSON =
       struct
         open JsonInputUtils
         type data = vdata;
         local open Json in

           fun inp_gnode (Object jobj) = 
              (case get jobj "gtype" of
                (String "GN_Node") => 
                      GraphSubstData.GN_Node (GoalTyp.gnode_from_json (get jobj "gdata"))
              | (String "GN_Var") => GraphSubstData.GN_Var (case get jobj "gdata" of (String n) => n)
              | (String "GN_Empty") => GraphSubstData.GN_Empty
              (* TO DO: fixme: basically linked list -> or convert to list?? *)
              | (String "GN_Pair") => GraphSubstData.GN_Empty);

           fun input (Object jobj) = 
             (case get jobj "type" of
                (String "RT") => GraphSubstData.RT (RTechnJSON.rtechn_from_json (Object jobj)(*(get jobj "data")*))
              | (String "GN") => GraphSubstData.GN (inp_gnode (Object jobj))
              | (String "TVar") => GraphSubstData.TVar (case get jobj "data" of (String n) => n))
      end; (* local open *)
        fun input _ = GraphSubstData.RT RTechn.id; (* RTechnJSON.rtechn_from_json *)
     end; (* struct *)

     structure IVDataOutputJSON : OUTPUT_JSON =
     struct
       open JsonInputUtils
       type data = vdata;

       fun out_gnode (GraphSubstData.GN_Node gn) =
             Json.mk_object [("gtype", Json.String "GN_Node"), ("gdata", GoalTyp.gnode_to_json gn)]
        |  out_gnode (GraphSubstData.GN_Var v) =
             Json.mk_object [("gtype", Json.String "GN_Var"), ("gdata",Json.String v)]
        |  out_gnode (GraphSubstData.GN_Empty) = Json.mk_object [("gtype", Json.String "GN_Empty")]
        (* fixme: should be like a linked list -> or turn to list and just use array? *)
        |  out_gnode (GraphSubstData.GN_Pair _) =Json.mk_object [("gtype", Json.String "GN_Empty")]

       fun output (GraphSubstData.RT rt) =
              Json.mk_object [("type", Json.String "RT"), ("data", RTechnJSON.rtechn_to_json rt)] 
         | output (GraphSubstData.GN gn) = 
              Json.mk_object [("type", Json.String "GN"), ("data", out_gnode gn)] 
         | output (GraphSubstData.TVar tv) =
             Json.mk_object [("type", Json.String "TVar"), ("data", Json.String tv)]


     end; (* structure *)

     (* edge data ( could have made var just a string to simplify but need (future) support for short data):
        { type : Evar | GT
          data : string | goaltype 
        }   
     *)
    structure EDataInputJSON : INPUT_JSON =
    struct
      open JsonInputUtils;
      type data = edata;
      local open Json in
        fun input (Object jobj) = 
          (case get jobj "type" of
              (String "EVar") => GraphSubstData.EVar (case get jobj "data" of (String n) => n)
            | (String "GT") => GraphSubstData.GT (GoalTyp.from_json ( Object jobj) (*(get jobj "data")*)));
      end; (* local *)
    end; (* struct *)

    structure EDataOutputJSON : OUTPUT_JSON =
    struct
      open JsonInputUtils
      type data = edata;
      fun output (GraphSubstData.EVar var) =
            Json.mk_object [("type", Json.String "EVar"), ("data", Json.String var)]
       |  output (GraphSubstData.GT gt)  = GoalTyp.to_json gt
            (*Json.mk_object [("type", Json.String "GT"), ("data",GoalTyp.to_json gt)];*)
    end; (* struct *)

    structure DotStyle : DOT_STYLE =
    struct
      type vdata = vdata;
      fun style_for_ivertex_data (GraphSubstData.RT _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=square]"
        | style_for_ivertex_data (GraphSubstData.GN _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=circle]"
        | style_for_ivertex_data (GraphSubstData.TVar _) =
            "[style=filled,fillcolor=yellow,fontcolor=red,shape=square]"
    end; (* struct DotStyle *)
  end; (* struct PS_ComponentDataIO *)

  structure PS_TheoryIO = GraphicalTheoryIO(
     structure Theory = PS_Theory
     structure GraphComponentDataIO = PS_ComponentDataIO );

  val out_json = PS_TheoryIO.OutputGraphJSON.output;

 structure GraphDot =
 struct
  structure Graph = PS_Theory.Graph;
  structure GData = PS_GraphParam.GraphSubstData;

  fun pretty_node g v = V.dest v
  fun pretty_edge g e = Pretty.string_of (GData.pretty_edata (Graph.get_edge_data g e));

  fun is_rtechn (GData.RT _) = true
   |  is_rtechn (GData.TVar _) = true
   |  is_rtechn _ = false;

  val node_str = GData.pretty_vdata #> Pretty.string_of;

  fun node_style g v = 
     case Graph.get_vertex_data g v of 
       (Graph.OVData.NVert node) => 
        (if is_rtechn node 
          then " [style=filled,fillcolor=white,fontcolor=black,shape=box,label=\"" ^ (node_str node) ^ "\"]"
          else  " [style=filled,fillcolor=white,fontcolor=black,shape=circle,label=\"" ^ (node_str node) ^ "\"]")
      | _ => " [style=filled,fillcolor=gray,shape=box,width=0,height=0,fontcolor=white]"

  fun node_block graph = 
   let
     fun single_node nm list = 
        (pretty_node graph nm)
        ^ (node_style graph nm)
        ^ ";\n"
        ^ list
  in (V.NSet.fold_rev single_node (Graph.get_unbboxed graph) "")
  end
  
  fun edge_block graph = let
    fun f nm str = let
      val (_, (s,t)) = Graph.get_edge graph nm
    in (pretty_node graph s)
       ^ " -> "
       ^ (pretty_node graph t)
       ^  " [label=\""
       ^ (pretty_edge graph nm)
       ^ "\"];\n" 
       ^ str
    end
  in E.NSet.fold_rev f (Graph.get_enames graph) ""
  end
  
  fun output graph = 
     "digraph G {\n" 
      ^ (node_block graph)
      ^ (edge_block graph)
      ^ "}\n";

  fun write_dot_to_file fname graph =
     let 
       val str = Print_Mode.setmp [] (fn () => output graph) ();
       val outs = TextIO.openOut fname; 
       val _ = TextIO.output (outs,str)
     in 
       TextIO.closeOut outs
     end;
 end (* end graphdot*)

 val dot_graph = GraphDot.output;
 val write_dot = GraphDot.write_dot_to_file;

end (* end functor *)


(* structure Strategy_Controller = Controller(Strategy_Theory); *)
