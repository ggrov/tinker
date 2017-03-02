functor Graph (Data: GRAPH_DATA) : GRAPH =
struct
 structure Data = Data
 
 exception no_such_edge_exp of string * E.name
 exception no_such_vertex_exp of string * V.name
 exception dup_edge_exp of string * E.name
 exception dup_vertex_exp of string * V.name
 exception ill_form_json_graph of string * Json.json


 datatype T = G of {
  vdata  : Data.vdata VTab.T,
  edata  : Data.edata ETab.T,
  source : EVFn.T,
  target : EVFn.T }

 val empty = G {vdata = VTab.empty, edata = ETab.empty, source = EVFn.empty, target = EVFn.empty};

(* get, set and update*)
 fun update_vdata f (G g) = G {vdata = f(#vdata g), edata = #edata g, source = #source g, target = #target g}
 fun update_edata f (G g) = G {vdata = #vdata g, edata = f(#edata g), source = #source g, target = #target g}
 fun update_source f (G g) = G {vdata = #vdata g, edata = #edata g, source = f(#source g), target = #target g}
 fun update_target f (G g) = G {vdata = #vdata g, edata = #edata g, source = #source g, target = f(#target g)}

 fun get_vdata (G g) = #vdata g
 fun get_edata (G g) = #edata g
 fun get_source (G g) = #source g
 fun get_target (G g) = #target g

 fun set_vdata x = update_vdata (fn _ => x)
 fun set_edata x = update_edata (fn _ => x)
 fun set_source x = update_source (fn _ => x)
 fun set_target x = update_target (fn _ => x)

 fun is_empty g = get_vdata g |> VTab.is_empty

 fun has_vertex g v = get_vdata g |> (fn g => VTab.dom_contains g v)
 fun has_edge g v = get_edata g |> (fn g => VTab.dom_contains g v)

 fun get_vertices g = VTab.get_dom_set (get_vdata g)
 fun get_edges g = ETab.get_dom_set (get_edata g)

 fun get_boundary g = 
  get_vdata g |> VTab.list_of
  |> List.filter (Data.is_boundary o snd)
  |> map fst
  |> V.NSet.of_list;

(* inputs are those boundaries which do not have input edges *)
  fun get_inputs g = get_target g |> EVFn.get_dom_set |> V.NSet.subtract (get_boundary g)
(* output are those boundaries which do not have out edges *)
  fun get_outputs g = get_source g |> EVFn.get_dom_set |> V.NSet.subtract (get_boundary g)

  fun get_edge_source g n = EVFn.get (get_source g) n
  fun get_edge_target g n = EVFn.get (get_target g) n
  
  fun get_in_edges g n = EVFn.inv_img (get_target g) n
  fun get_out_edges g n = EVFn.inv_img (get_source g) n

  fun get_edge_data g n = 
    case (get_edata g |> (fn x => VTab.get_opt x n)) of 
     SOME x => x
   | NONE => raise no_such_edge_exp ("get_edge_data", n)

  fun get_vertex_data g n = 
    case (get_vdata g |> (fn x => VTab.get_opt x n)) of 
     SOME x => x
   | NONE => raise no_such_vertex_exp ("get_vertex_data" ,n)

  fun set_vertex_data data n g = 
    set_vdata (VTab.set (n, data) (get_vdata g)) g

  fun set_edge_data data n g = 
    set_edata (VTab.set (n, data) (get_edata g)) g

  fun update_vertex_data f n g = 
    if has_vertex g n then g |> update_vdata (VTab.map_entry f n)
    else raise no_such_vertex_exp ("update_vertex_data", n)

  fun update_edge_data f n g = 
    if has_edge g n then g |> update_edata (VTab.map_entry f n)
    else raise no_such_edge_exp ("udpate_edge_data", n)

  fun add_vertex data g = 
  let val fresh_name = V.NSet.new (get_vertices g) V.default_name in
  (fresh_name, update_vdata (VTab.add (fresh_name, data)) g) end

 (* TODO *)
  fun add_edge data from_vn to_vn  g = 
  let val fresh_name = V.NSet.new (get_edges g) E.default_name in
  (fresh_name, update_edata (VTab.add (fresh_name, data)) g) end

  fun delete_edge n g = g (* TODO *)
  fun delete_vertex n g = g (* TODO *)

  fun update_with_vertex_item id (Json.Object jobj) g =
   update_vdata (VTab.add (V.mk id, Json.get jobj "data" |> Data.vdata_from_json)) g
    | update_with_vertex_item _  json  _= raise ill_form_json_graph ("update_vertex_item", json)

  fun update_with_boundary_item id g = update_vdata (VTab.add (V.mk id, Data.Boundary)) g

  fun update_with_edge_item id (Json.Object jobj) g = 
   update_edata (VTab.add (E.mk id, Json.get jobj "data" |> Data.edata_from_json)) g
   |> update_source (EVFn.add (E.mk id, JsonInputUtils.get_string jobj "src" |> V.mk))  
   |> update_target (EVFn.add (E.mk id, JsonInputUtils.get_string jobj "tgt" |> V.mk))
   | update_with_edge_item _ json _ = raise ill_form_json_graph ("update_with_edge_item", json)

  fun from_json (Json.Object jobj) = 
   let 
   (* a list of (id, data) *)
    fun get_item_list name = 
      JsonInputUtils.get_obj jobj name
      |> (fn x => map  (fn y => (y, Json.get x y)) (Json.properties x))
    val dir_edges = get_item_list "dir_edges"
    val boundary_vertices = get_item_list "wire_vertices" |> map fst (* the data part does not matter *)
    val node_vertices = get_item_list "node_vertices"
   in
    List.foldr (fn (x,y) => update_with_vertex_item (fst x) (snd x) y) empty node_vertices
    |> (fn g =>  List.foldr (fn (x,y) => update_with_boundary_item x y) g  boundary_vertices)
    |> (fn g =>  List.foldr (fn (x,y) => update_with_edge_item (fst x) (snd x) y) g dir_edges)
   end
    | from_json j = raise ill_form_json_graph ("from josn", j)

  fun mk_node_vertices_json (v_list : (V.name * Data.vdata) list) = 
   Json.mk_object 
   (map 
     (fn (x,y) => 
       (V.string_of_name x, 
        Json.mk_object[("data", Data.vdata_to_json y)])) 
   v_list)
   |> (fn x => Json.mk_object [("node_vertices",x)])

  fun mk_wire_vertices_json l = 
   Json.mk_object 
   (map 
     (fn x => 
       (V.string_of_name x , 
        Json.mk_object[("annotation", Json.mk_object [("boundary", Json.Bool true)])])) 
    l)
   |> (fn x => Json.mk_object [("wire_vertices", x)])

  fun mk_dir_edges_json (e_list : (E.name * Data.edata) list) src_tbl tgt_tbl  =
   Json.mk_object 
   (map 
     (fn (x,y) => 
       (V.string_of_name x, 
        Json.mk_object
        [("data", Data.edata_to_json y), 
          ("src", EVFn.get src_tbl x |> V.string_of_name |> Json.String),
          ("tgt", EVFn.get tgt_tbl x |> V.string_of_name |> Json.String)])) 
   e_list)
   |> (fn x => Json.mk_object [("node_vertices",x)])


(* assume the given graph is well-formed  *)
  fun to_json g = 
  let 
   val edata = get_edata g 
   val vdata = get_vdata g 
   val src = get_source g 
   val tgt = get_target g 
   val edges = VTab.list_of edata
   val nodes = VTab.list_of vdata |> List.filter (fn (_,y) => not (Data.is_boundary y))
   val boundaries = VTab.list_of vdata |> List.filter (fn (_,y) => Data.is_boundary y) |> map fst
  in
   Json.mk_object[
     ("dir_edges" ,mk_dir_edges_json edges src tgt),
     ("wire_vertices", mk_wire_vertices_json boundaries),
     ("node_vertices", mk_node_vertices_json nodes)]
  end
  
  fun pretty g = to_json g |> Json.encode |> Pretty.str
  fun print g = to_json g |> Json.encode |>  writeln

 (*        .
    | from_json x = raise ill_form_json_graph ("Unexpected Json structure in Graph.from_json",  x)   

  fun to_json 
*)

(*
 val rename_vertex : V.name -> V.name -> T -> T
 val rename_edge   : E.name -> E.name -> T -> T

and json io
*)

 structure Sharing =
 struct
  type T = T
  structure Data = Data.Sharing
 end

end