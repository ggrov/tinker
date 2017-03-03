signature GRAPH_SHARING = 
sig
 type T
 structure Data : GRAPH_DATA_SHARING
end

signature GRAPH  =
sig
 structure Data : GRAPH_DATA

 type T
(* Naming convention: vertex = nodes + boundary, edges *)
 exception no_such_edge_exp of string * E.name
 exception no_such_vertex_exp of string * V.name
 exception dup_edge_exp of string * E.name
 exception dup_vertex_exp of string * V.name
 exception ill_form_json_graph of string * Json.json

 val empty : T 

(* graph is empty *)
 val is_empty : T -> bool

(* containment checks *)
 val has_vertex : T -> V.name -> bool
 val has_edge : T -> E.name -> bool
 val get_vertices : T -> V.NSet.T
 val get_edges : T -> E.NSet.T
 val get_boundaries : T -> V.NSet.T
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
 val lookup_vertex_data : T -> V.name -> Data.vdata option
 val lookup_edge_data   : T -> E.name -> Data.edata option


 val add_vertex    : Data.vdata -> T -> V.name * T 
 val add_edge      : Data.edata -> V.name -> V.name -> T -> E.name * T
 val delete_edge   : E.name -> T -> T
 val delete_vertex : V.name -> T -> T
 val delete_1on1_node: V.name -> T -> T

 val add_edges_tgts : E.name list -> Data.vdata list -> T -> T 

 val input_boundary : T -> (V.name * (E.name * Data.edata) * V.name) list
 val output_boundary : T -> (V.name * (E.name * Data.edata) * V.name) list

 val insert_node_on_edge : Data.vdata -> E.name -> T -> E.name * E.name * T

 val to_json : T -> Json.json
 val from_json : Json.json -> T

 val pretty : T -> Pretty.T
 val print : T -> unit

 structure Sharing : GRAPH_SHARING
end