
functor PSGraphIOFun(structure Data : PSGRAPH_DATA) : GRAPH_COMPONENT_DATA_IO =
struct
     type nvdata = Data.nvdata;
     type edata = Data.edata;

      (* vertex data
         { type : RT | GN | TVar | GVar
           data : string | rtechn | array }
      *)
      structure IVDataInputJSON : INPUT_JSON =
       struct
         open JsonInputUtils
         type data = nvdata;
         local open Json in

           fun input (Object jobj) = Data.T_Identity
(*
             (case get jobj "type" of
                (String "RT") => (GraphSubstData.RT (RTechnJSON.rtechn_from_json (Object jobj)))
              | (String "GN") => GraphSubstData.GN (inp_gnode (Object jobj))
              | (String "TVar") => GraphSubstData.TVar (case get jobj "data" of (String n) => n))
*)
      end; (* local open *)
       
     end; (* struct *)

     structure IVDataOutputJSON : OUTPUT_JSON =
     struct
       open JsonInputUtils
       type data = nvdata;
 
       fun output _ = Json.String "";     
(*
       fun output (GraphSubstData.RT rt) = RTechnJSON.rtechn_to_json rt 
         | output (GraphSubstData.GN gn) = 
              Json.mk_object [("type", Json.String "GN"), 
                              ("gn_name", Json.String (get_gnode_name gn)), 
                              ("gdata", out_gnode gn)] 
         | output (GraphSubstData.TVar tv) =
             Json.mk_object [("type", Json.String "TVar"), ("data", Json.String tv)]
*)

     end; (* structure *)

    structure EDataInputJSON : INPUT_JSON =
    struct
      open JsonInputUtils;
      type data = edata;
      local open Json in
        fun input (Object jobj) = 
          (case get jobj "type" of
              (String "GT_Var") => Data.GT_Var (case get jobj "data" of (String n) => n)
            | (String "GT") => Data.GT (Data.GoalTyp.from_json ( Object jobj) (*(get jobj "data")*)));
      end; (* local *)
    end; (* struct *)

    structure EDataOutputJSON : OUTPUT_JSON =
    struct
      open JsonInputUtils
      type data = edata;
      fun output (Data.GT_Var var) =
            Json.mk_object [("type", Json.String "GT_Var"), ("data", Json.String var)]
       |  output (Data.GT gt) = Data.GoalTyp.to_json gt
            (*Json.mk_object [("type", Json.String "GT"), ("data",GoalTyp.to_json gt)];*)
    end; (* struct *)
 
    structure DotStyle : DOT_STYLE =
    struct
      type nvdata = nvdata;
      fun style_for_ivertex_data (Data.T_Atomic _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=square]"
        | style_for_ivertex_data (Data.T_Graph _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=square]"
        | style_for_ivertex_data (Data.T_Identity) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=square]"
        | style_for_ivertex_data (Data.G _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=circle]"
        | style_for_ivertex_data (Data.G_Var _) =
            "[style=filled,fillcolor=green,fontcolor=black,shape=circle]"
        | style_for_ivertex_data (Data.T_Var _) =
            "[style=filled,fillcolor=yellow,fontcolor=red,shape=square]"
    end; (* struct DotStyle *)


end (* end functor *)


(*
signature PS_THEORY = 
sig

  structure PS_GraphParam : PS_GRAPH_PARAM
  structure PS_Theory : GRAPHICAL_THEORY
  structure PS_Comb : GRAPH_COMB
  sharing type PS_Comb.Graph.T = PS_Theory.Graph.T
  sharing type PS_GraphParam.GraphSubstData.vdata = PS_Theory.Graph.OVData.IData.data
  sharing type PS_GraphParam.GraphSubstData.edata = PS_Theory.Graph.SharingBasicGraph.Param.EData.data
  sharing PS_Comb.Graph.EData = PS_Theory.Graph.SharingBasicGraph.Param.EData

  val out_json : PS_Theory.Graph.T -> Json.json
  val in_json : Json.json -> PS_Theory.Graph.T
  val dot_graph : PS_Theory.Graph.T -> string
  val write_dot : string -> PS_Theory.Graph.T -> unit
  val write_json_file: string -> PS_Theory.Graph.T  -> unit

end 
*)
