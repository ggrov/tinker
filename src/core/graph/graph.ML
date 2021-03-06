functor GraphFun (Data: GRAPH_DATA) : GRAPH =
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
  target : EVFn.T,
  coord  : real list VTab.T (* cooirdination for vertices *) }

 val empty = G {vdata = VTab.empty, edata = ETab.empty, source = EVFn.empty, target = EVFn.empty, coord = VTab.empty};


(**********************************************************
*  Basic record OP: Get, Set and Update
***********************************************************)
 fun update_vdata f (G g) = G {vdata = f(#vdata g), edata = #edata g, source = #source g, target = #target g, coord = #coord g}
 fun update_edata f (G g) = G {vdata = #vdata g, edata = f(#edata g), source = #source g, target = #target g, coord = #coord g}
 fun update_source f (G g) = G {vdata = #vdata g, edata = #edata g, source = f(#source g), target = #target g, coord = #coord g}
 fun update_target f (G g) = G {vdata = #vdata g, edata = #edata g, source = #source g, target = f(#target g), coord = #coord g}
 fun update_coord f (G g) = G {vdata = #vdata g, edata = #edata g, source = #source g, target = #target g, coord = f(#coord g)}

 fun get_vdata (G g) = #vdata g
 fun get_edata (G g) = #edata g
 fun get_source (G g) = #source g
 fun get_target (G g) = #target g
 fun get_coord (G g) = #coord g

 fun set_vdata x = update_vdata (fn _ => x)
 fun set_edata x = update_edata (fn _ => x)
 fun set_source x = update_source (fn _ => x)
 fun set_target x = update_target (fn _ => x)
 fun set_coord x =  update_coord (fn _ => x)

 fun is_empty g = get_vdata g |> VTab.is_empty

(**********************************************************
* Node, Edge and Boundary getter and setter at graph level
***********************************************************)
 fun has_vertex g v = get_vdata g |> (fn g => VTab.dom_contains g v)
 fun has_edge g v = get_edata g |> (fn g => VTab.dom_contains g v)

 fun get_vertices g = VTab.get_dom_set (get_vdata g)
 fun get_edges g = ETab.get_dom_set (get_edata g)

 fun get_boundaries g = 
  get_vdata g |> VTab.list_of
  |> List.filter (Data.is_boundary o snd)
  |> map fst
  |> V.NSet.of_list;

(* inputs are those boundaries which do not have input edges *)
  fun get_inputs g = get_target g |> EVFn.get_dom_set |> V.NSet.subtract (get_boundaries g)
(* output are those boundaries which do not have out edges *)
  fun get_outputs g = get_source g |> EVFn.get_dom_set |> V.NSet.subtract (get_boundaries g)

  fun get_edge_source g n = EVFn.get (get_source g) n
  fun get_edge_target g n = EVFn.get (get_target g) n
  
  fun get_in_edges g n = EVFn.inv_img (get_target g) n
  fun get_out_edges g n = EVFn.inv_img (get_source g) n

  fun lookup_edge_data g n =  VTab.get_opt (get_edata g) n 
  fun lookup_vertex_data g n = VTab.get_opt (get_vdata g) n 

  fun get_edge_data g n = 
    case lookup_edge_data g n of 
     SOME x => x
   | NONE => raise no_such_edge_exp ("get_edge_data", n)

  fun get_vertex_data g n = 
    case lookup_vertex_data g n of 
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

  fun add_edge data from_vn to_vn  g = 
  let val fresh_name = V.NSet.new (get_edges g) E.default_name in
  (fresh_name, 
   update_edata (VTab.add (fresh_name, data)) g (* add edge data, then add src and tgt*)
   |> update_source (EVFn.add(fresh_name, from_vn))
   |> update_target (EVFn.add(fresh_name, to_vn))) end

(* both delete operations will deeply clean data, so back the data before procede *)
  fun delete_edge e g = 
   update_edata (VTab.delete e) g 
   |> update_source (EVFn.delete e)
   |> update_target (EVFn.delete e) (* no need to del coord info ? it will be ignored when exporting to json *)

  fun delete_vertex v g = 
  update_vdata (VTab.delete v) g 
   |> update_source (EVFn.inv_delete v)
   |> update_target (EVFn.inv_delete v) 

  fun delete_1on1_node gnode g = 
    let 
     val in_edge = get_in_edges g gnode |> V.NSet.list_of |> hd
     val out_edge = get_out_edges g gnode |> V.NSet.list_of |> hd
     val next_vertex = EVFn.get (get_target g) out_edge
    in
     delete_vertex gnode g
     |> delete_edge out_edge
     |> update_target (EVFn.add (in_edge, next_vertex))
    end

(**********************************************************
* High level graph operations
***********************************************************)
  fun input_boundary g = 
  let 
   val bvertexes = get_inputs g (* Vertex.NSet.T *)
   fun dest_name bv e =(bv,(e,get_edge_data g e), get_edge_target g e)
   fun mk_pairs v = 
    get_out_edges g v
    |> E.NSet.list_of
    |> map (fn e => dest_name v e)
  in  
   V.NSet.fold (fn v => fn xs => xs @ (mk_pairs v)) bvertexes []
  end;

  fun output_boundary g = 
   let 
    val bvertexes = get_outputs g (* Vertex.NSet.T *)
    fun dest_name bv e =(get_edge_source g e,(e, get_edge_data g e),bv)
    fun mk_pairs v = 
     get_out_edges g v
     |> E.NSet.list_of
     |> map (fn e => dest_name v e)
    in  
     V.NSet.fold (fn v => fn xs => xs @ (mk_pairs v)) bvertexes []
    end;

  fun insert_node_on_edge node edge graph0 =
   let 
    val (l,graph') = add_vertex node graph0
    val from' = get_edge_source graph' edge
    val to' = get_edge_target graph' edge
    val edata = get_edge_data graph' edge
    val graph' = delete_edge edge graph'
    val (src, graph') = add_edge edata from' l graph'
    val (dest, graph') = add_edge edata l to' graph'
   in
    (src, dest, graph')
   end; 

  fun add_edges_tgts [] [] graph = graph
  |   add_edges_tgts  (i::is) (p::ps) graph =  add_edges_tgts is ps (#3 (insert_node_on_edge p i graph))
  |   add_edges_tgts _ _ _ = raise RunCallFail "Undefined input for add_edges_tgts";

(**********************************************************
*  JSON IO
***********************************************************)
  fun coord_from_json (Json.Object jobj) = 
    JsonInputUtils.get_obj jobj "annotation" 
    |> (fn x => JsonInputUtils.get_array x "coord")
    |> map (fn (Json.Real r) => r | x => raise ill_form_json_graph ("coord_from_json", x) )
  |   coord_from_json x = raise ill_form_json_graph ("coord_from_json", x)

  fun update_with_vertex_item id (Json.Object jobj) g =
   update_vdata (VTab.add (V.mk id, Json.get jobj "data" |> Data.vdata_from_json)) g
   |> update_coord (VTab.add (V.mk id, coord_from_json (Json.Object jobj)))
  |   update_with_vertex_item _  json  _= raise ill_form_json_graph ("update_vertex_item", json)

  fun update_with_boundary_item id (Json.Object jobj) g = 
   update_vdata (VTab.add (V.mk id, Data.Boundary)) g
   |> update_coord (VTab.add (V.mk id, coord_from_json (Json.Object jobj)))
 |  update_with_boundary_item _ json _ = raise ill_form_json_graph ("update_with_boundary_item", json)

  fun update_with_edge_item id (Json.Object jobj) g = 
   update_edata (VTab.add (E.mk id, Json.get jobj "data" |> Data.edata_from_json)) g
   |> update_source (EVFn.add (E.mk id, JsonInputUtils.get_string jobj "src" |> V.mk))  
   |> update_target (EVFn.add (E.mk id, JsonInputUtils.get_string jobj "tgt" |> V.mk))
  |   update_with_edge_item _ json _ = raise ill_form_json_graph ("update_with_edge_item", json)

  fun from_json (Json.Object jobj) = 
   let 
   (* a list of (id, data) *)
    fun get_item_list name = 
      JsonInputUtils.get_obj jobj name
      |> (fn x => map  (fn y => (y, Json.get x y)) (Json.properties x))
    val dir_edges = get_item_list "dir_edges"
    val boundary_vertices = get_item_list "wire_vertices"
    val node_vertices = get_item_list "node_vertices"
   in
    List.foldr (fn (x,y) => update_with_vertex_item (fst x) (snd x) y) empty node_vertices
    |> (fn g =>  List.foldr (fn (x,y) => update_with_boundary_item (fst x) (snd x) y) g  boundary_vertices)
    |> (fn g =>  List.foldr (fn (x,y) => update_with_edge_item (fst x) (snd x) y) g dir_edges)
   end
    | from_json j = raise ill_form_json_graph ("from josn", j)

  fun mk_node_vertices_json (v_list : (V.name * Data.vdata) list) coord =
   let 
    fun mk_node_json id vdata = 
     case VTab.get_opt coord id of
      SOME c => 
       [("annotation", Json.mk_object [("coord", map Json.Real c |> Json.Array)]),
         ("data", Data.vdata_to_json vdata)]
    | NONE  => [("data", Data.vdata_to_json vdata)]
   in
    Json.mk_object 
    (map 
      (fn (x,y) => 
        (V.string_of_name x, 
         Json.mk_object (mk_node_json x y))) 
    v_list)
    (*|> (fn x => Json.mk_object [("node_vertices",x)])*)
   end

  fun mk_wire_vertices_json l coord = 
   let 
    fun mk_anno_json id  = 
     case VTab.get_opt coord id of 
       SOME c => [("coord", map Json.Real c |> Json.Array), ("boundary", Json.Bool true)]
     | NONE   =>  [("boundary", Json.Bool true)]
  in
   Json.mk_object 
   (map 
     (fn x => 
       (V.string_of_name x , 
        Json.mk_object[("annotation", Json.mk_object (mk_anno_json x))])) 
    l)
 (*  |> (fn x => Json.mk_object [("wire_vertices", x)])*)
  end

  fun mk_dir_edges_json (e_list : (E.name * Data.edata) list) src_tbl tgt_tbl  =
   Json.mk_object 
   (map 
     (fn (x,y) => 
       (V.string_of_name x, 
        Json.mk_object
        [("data", Data.edata_to_json y),
         ("tgt", EVFn.get tgt_tbl x |> V.string_of_name |> Json.String),
         ("src", EVFn.get src_tbl x |> V.string_of_name |> Json.String)])) 
   e_list)
   (*|> (fn x => Json.mk_object [("node_vertices",x)])*)


(* assume the given graph is well-formed  *)
  fun to_json g = 
  let 
   val coord = get_coord g
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
     ("node_vertices", mk_node_vertices_json nodes coord),
     ("wire_vertices", mk_wire_vertices_json boundaries coord)]
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