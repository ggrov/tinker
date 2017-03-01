functor Graph (Data: GRAPH_DATA) : GRAPH =
struct
 structure Data = Data

 exception no_such_edge_exp of string * E.name
 exception no_such_vertex_exp of string * V.name
 exception dup_edge_exp of string * E.name
 exception dup_vertex_exp of string * V.name

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

  fun add_edge data from_v to_v  g = 
  let val fresh_name = V.NSet.new (get_edges g) E.default_name in
  (fresh_name, update_edata (VTab.add (fresh_name, data)) g) end

  fun delete_edge n g = g
  fun delete_vertex n g = g
(*
 val rename_vertex : V.name -> V.name -> T -> T
 val rename_edge   : E.name -> E.name -> T -> T
*)

 structure Sharing =
 struct
  type T = T
  structure Data = Data.Sharing
 end

end