(* transfer a string graph into a strategy graph *)
signature STRING_TRANSFER =
sig
  val to_strategy_graph : theory -> StringVE_Theory.Graph.T -> Strategy_Theory.Graph.T
  val to_string_graph : Strategy_Theory.Graph.T -> theory -> (StringVE_Theory.Graph.T * theory)
  val parse_string_graph : string -> StringVE_Theory.Graph.T
end (* signature *)
structure StringTransfer =
struct

  structure WireData = Theory_Data(
   struct 
    type T = Wire.T StrName.NTab.T
    val empty = StrName.NTab.empty;
    val extend = I;
    fun merge (a,b) = StrName.NTab.merge_disjoint a b
  end);

  structure RTechnData = Theory_Data(
   struct 
    type T = RTechn.T StrName.NTab.T
    val empty = StrName.NTab.empty;
    val extend = I;
    fun merge (a,b) = StrName.NTab.merge_disjoint a b
  end);

 val get_wire = (StrName.NTab.get o WireData.get);
 val get_rtechn =  (StrName.NTab.get o RTechnData.get);

 (* will override existing... *)
 val add_wire = WireData.map o StrName.NTab.doadd;
 val add_rtechn = RTechnData.map o StrName.NTab.doadd

 fun to_strategy_graph th str_graph =
   let 
     val get_edata = get_wire th 
                   #> DB_EdgeData.W;
     val get_ivdata = get_rtechn th #> DB_VertexData.RT ;
     fun get_vdata vdata = case StringVE_OVertex.idata_of vdata of
                        NONE => Strategy_OVData.WVert
                      | SOME d => Strategy_OVData.NVert (get_ivdata d);
     val vertices = str_graph
                  |> StringVE_Theory.Graph.get_vertices
                  |>  V.NTab.list_of
                  |> map (fn (n,(d,(_,_))) => (n,d));
     val edges = str_graph
               |> StringVE_Theory.Graph.get_edges 
               |> E.NTab.list_of;
     fun add_vertex (name,data) =
        Strategy_Theory.Graph.add_named_vertex name (get_vdata data);
     fun trans_dir dir = case dir of 
            StringVE_Theory.Graph.Directed => Strategy_Theory.Graph.Directed
            | StringVE_Theory.Graph.UnDirected => Strategy_Theory.Graph.UnDirected;
     fun add_edge (name,((dir,data),(from,to))) =
        Strategy_Theory.Graph.add_named_edge name (trans_dir dir,get_edata data) from to; 
   in
     Strategy_Theory.Graph.empty (* create an empty graph *)
     |> fold add_vertex vertices
     |> fold add_edge edges
   end;

 exception transfer_exp of string

 fun to_string_graph strat_graph th0 =
   let 
     fun get_edata th data = 
       let 
         val wire = case data of 
                     DB_EdgeData.W wire => wire
                    | _ => raise transfer_exp ("wire variables not allowed");
         val wname = Wire.get_name wire |> SStrName.dest
         val th' = add_wire (wname,wire) th (* should only add if not there *)
       in
         (wname,th')
       end; 
     fun get_ivdata th data = 
       let 
         val rtechn = case data of 
                     DB_VertexData.RT rt => rt
                    | _ => raise transfer_exp ("graph can only contain rtechn vertices");
         val rtname = RTechn.get_name rtechn
         val th' = add_rtechn (rtname,rtechn) th (* should only add if not there *)
       in
         (StringVE_OVertex.NVert rtname,th')
       end; 
     fun get_vdata th vdata = case Strategy_OVData.idata_of vdata of
                        NONE => (StringVE_OVertex.WVert,th)
                      | SOME d => get_ivdata th d
     val vertices = strat_graph
                  |> Strategy_Theory.Graph.get_vertices
                  |>  V.NTab.list_of
                  |> map (fn (n,(d,(_,_))) => (n,d));
     val edges = strat_graph
               |> Strategy_Theory.Graph.get_edges 
               |> E.NTab.list_of;
     fun trans_dir dir = case dir of 
            Strategy_Theory.Graph.Directed => StringVE_Theory.Graph.Directed
            | Strategy_Theory.Graph.UnDirected => StringVE_Theory.Graph.UnDirected;

     fun add_vertex (name,data) (g,th) =
      let
        val (vdata,th') = get_vdata th data
      in 
        (StringVE_Theory.Graph.add_named_vertex name vdata g,th')
      end
    fun add_edge (name,((dir,data),(from,to))) (g,th) =
      let
        val (edata,th') = get_edata th data
      in 
        (StringVE_Theory.Graph.add_named_edge name (trans_dir dir,edata) from to g,
         th')
      end 
   in
     (StringVE_Theory.Graph.empty,th0) (* create an empty graph, and initial theory *)
     |> fold add_vertex vertices
     |> fold add_edge edges
   end;

 (* turns given filename into a string graph *)
 val parse = Json.read_file #> StringVE_IO.InputGraphJSON.input #> fst;

 fun parse_and_translate fname th = 
  let 
    (* remove file type and full path *)
    val gname = String.tokens (fn c => c = #".") fname 
              |> hd
              |> String.tokens (fn c => c = #"/")
              |> List.last
              |> String.tokens (fn c => c = #"\\") (* in case of windows.. *)
              |> List.last;
    val string_graph = parse fname;
    val strat_graph = to_strategy_graph th string_graph;
  in
    (gname,strat_graph)
  end;

 fun register_graph fname th0 = 
  let 
    (* remove file type and full path *)
    val (gname,strat_graph) = parse_and_translate fname th0
    val th' = EvalTac.add_graph (gname,strat_graph) th0
  in
    tracing (gname ^ " registered"); th'
  end;

 fun register_nested fname th0 = 
  let 
    (* remove file type and full path *)
    val (gname,strat_graph) = parse_and_translate fname th0
    val (g',th') = NEST gname (fn th => (strat_graph,th)) th0;
  in
    tracing ("Nested technique: " ^ gname ^ " registered"); th'
  end;

end


