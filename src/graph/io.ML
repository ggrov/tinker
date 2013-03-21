structure Strategy_ComponentDataIO : GRAPH_COMPONENT_DATA_IO
= struct
  type vdata = Strategy_VertexData.data;
  type edata = Strategy_EdgeData.data;

  structure IVDataInputJSON : INPUT_JSON =
  struct
    open JsonInputUtils
    type data = vdata;
    fun input _ = GraphSubstData.RT RTechn.id;
  end;
  structure IVDataOutputJSON : OUTPUT_JSON =
  struct
    open JsonInputUtils
    type data = vdata;
    fun output _ =  Json.of_string "to do";
  end;
  structure EDataInputJSON : INPUT_JSON =
  struct
    open JsonInputUtils
    type data = edata;
    fun input (Json.String t) = GraphSubstData.GT GoalTyp.top;
  end;
  structure EDataOutputJSON : OUTPUT_JSON =
  struct
    open JsonInputUtils
    type data = edata;
    fun output _ = Json.of_string "to do";
  end;

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
  end;
end;




(* OLD STUFF *)

structure Strategy_DotStyle (* : DOT_STYLE *) =
struct
  structure Graph = Strategy_Theory.Graph
  fun style_for_ivertex_data x = "[style=filled,fillcolor=white,fontcolor=black,shape=circle]"
end;

(*
structure Strategy_OutputGraphDot = OutputGraphDot(structure DotStyle = Strategy_DotStyle)
*)
