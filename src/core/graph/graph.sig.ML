signature GRAPH_SHARING = 
sig
 type T
 structure Data : GRAPH_DATA_SHARING
end

signature GRAPH  =
sig
 structure Data : GRAPH_DATA
 type T

 val empty : T 

(* graph is empty *)
 val is_empty : T -> bool

(* containment checks *)
 val has_vertex : T -> V.name -> bool
 val has_edge : T -> E.name -> bool
 val get_boundary : T -> V.NSet.T
 val get_inputs   : T -> V.NSet.T
 val get_outputs  : T -> V.NSet.T

 val get_edge_source : T -> E.name -> V.name
 val get_edge_target : T -> E.name -> V.name

 val get_in_edges  : T -> V.name -> E.NSet.T
 val get_out_edges : T -> V.name -> E.NSet.T

 val get_vertex_data : T -> V.name -> Data.vdata
 val get_edge_data   : T -> E.name -> Data.edata
 val set_vertex_data : Data.vdata -> V.name -> T -> T
 val set_edge_data   : Data.edata -> E.name -> T -> T
 val update_vertex_data : (Data.vdata -> Data.vdata) -> V.name -> T -> T
 val update_edge_data   : (Data.edata -> Data.edata) -> E.name -> T -> T

 val add_vertex    : Data.vdata -> T -> V.name * T 
 val add_edge      : Data.edata -> V.name -> V.name -> T -> E.name * T
 val delete_edge   : E.name -> T -> T
 val delete_vertex : V.name -> T -> T

 val rename_vertex : V.name -> V.name -> T -> T
 val rename_edge   : E.name -> E.name -> T -> T

 val pretty : T -> Pretty.T
 val print : T -> unit

 structure Sharing : GRAPH_SHARING
end