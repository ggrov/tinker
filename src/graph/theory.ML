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

  (* structure PS_TheoryIO :*)
end (* signature *)

functor PSTheoryFun(GoalTyp : GOAL_TYP) : PS_THEORY =
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
     structure GTJson = GTJsonFun(GoalTyp);

      (* vertex data
         { type : RT | GN | TVar | GVar
           data : string | rtechn | array }
      *)
      structure IVDataInputJSON : INPUT_JSON =
       struct
         open JsonInputUtils
         type data = vdata;
         local open Json in
           fun input (Object jobj) = 
             (case get jobj "type" of
                (String "RT") => GraphSubstData.RT (RTechnJSON.rtechn_from_json (get jobj "data"))
              | (String "GN") => let 
                                   fun prj (String n) = GNode.mk_goal_no_facts n
                                   val (Array arr) = get jobj "data"
                                 in GraphSubstData.GN (map prj arr) end
              | (String "TVar") => GraphSubstData.TVar (case get jobj "data" of (String n) => n)
              | (String "GVar") => GraphSubstData.GVar (case get jobj "data" of (String n) => n));
        end; (* local open *)
        fun input _ = GraphSubstData.RT RTechn.id; (* RTechnJSON.rtechn_from_json *)
     end; (* struct *)

     structure IVDataOutputJSON : OUTPUT_JSON =
     struct
       open JsonInputUtils
       type data = vdata;
       fun output (GraphSubstData.RT rt) =
              Json.mk_object [("type", Json.String "RT"), ("data", RTechnJSON.rtechn_to_json rt)]
         | output (GraphSubstData.GN gnds) = Json.Array (map (Json.String o GNode.get_goal) gnds)
         | output (GraphSubstData.TVar tv) =
             Json.mk_object [("type", Json.String "TVar"), ("data", Json.String tv)]
         | output (GraphSubstData.GVar gv) =
            Json.mk_object [("type", Json.String "GVar"), ("data", Json.String gv)]
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
            | (String "GT") => GraphSubstData.GT (GTJson.from_json (get jobj "data")));
      end; (* local *)
    end; (* struct *)

    structure EDataOutputJSON : OUTPUT_JSON =
    struct
      open JsonInputUtils
      type data = edata;
      fun output (GraphSubstData.EVar var) =
            Json.mk_object [("type", Json.String "EVar"), ("data", Json.String var)]
       |  output (GraphSubstData.GT gt)  = 
            Json.mk_object [("type", Json.String "GT"), ("data", GTJson.to_json gt)];
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
        | style_for_ivertex_data (GraphSubstData.GVar _) =
            "[style=filled,fillcolor=yellow,fontcolor=red,shape=circle]";
    end; (* struct DotStyle *)
  end; (* struct PS_ComponentDataIO *)

  structure PS_TheoryIO = GraphicalTheoryIO(
     structure Theory = PS_Theory
     structure GraphComponentDataIO = PS_ComponentDataIO );

end (* end functor *)


(* structure Strategy_Controller = Controller(Strategy_Theory); *)
