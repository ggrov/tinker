
structure PS_ComponentDataIO : GRAPH_COMPONENT_DATA_IO
= struct
  type vdata = PS_VertexData.data;
  type edata = PS_EdgeData.data;

  (* vertex data
      { type : RT | GN | TVar | GVar
        data : string | rtechn | array
      }
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
                             in
                               GraphSubstData.GN (map prj arr)
                             end
          | (String "TVar") => GraphSubstData.TVar (case get jobj "data" of (String n) => n)
          | (String "GVar") => GraphSubstData.GVar (case get jobj "data" of (String n) => n));
    end;

    fun input _ = GraphSubstData.RT RTechn.id; (* RTechnJSON.rtechn_from_json *)
  end;
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
  end;

  (* edge data ( could have made var just a string to simplify but need (future)
     support for short data):
      { type : Evar | GT
        data : string | goaltype 
      }
    datatype edata = GT of GoalTyp.T  | EVar of string 
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
    end;
  end;
  structure EDataOutputJSON : OUTPUT_JSON =
  struct
    open JsonInputUtils
    type data = edata;
    fun output (GraphSubstData.EVar var) =
          Json.mk_object [("type", Json.String "EVar"), ("data", Json.String var)]
     |  output (GraphSubstData.GT gt)  = 
          Json.mk_object [("type", Json.String "GT"), ("data", GTJson.to_json gt)];
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

structure PS_GraphicalTheoryIO = GraphicalTheoryIO(
  structure Theory = PS_Theory
  structure GraphComponentDataIO = PS_ComponentDataIO
);

