functor Graph (Data: GRAPH_DATA) : GRAPH =
struct
 structure Data = Data

 datatype T = G of {
  vdata  : Data.vdata VTab.T,
  edata  : Data.edata ETab.T,
  source : EVFn.T,
  target : EVFn.T }

 val empty = G {vdata = VTab.empty, edata = ETab.empty, source = EVFn.empty, target = EVFn.empty};

(* get, set and update*)
 fun update_vdata f g = G {vdata = f(#vdata g), edata = #edata g, source = #source g, target = #target g}
 fun update_edata f g = G {vdata = #vdata g, edata = f(#edata g), source = #source g, target = #target g}
 fun update_source f g = G {vdata = #vdata g, edata = #edata g, source = f(#source g), target = #target g}
 fun update_target f g = G {vdata = #vdata g, edata = #edata g, source = #source g, target = f(#target g)}

 fun get_vdata (G g) = #vdata g
 fun get_edata (G g) = #edata g
 fun get_source (G g) = #source g
 fun get_target (G g) = #target g

 fun set_vdata x = update_vdata (fn _ => x)
 fun set_edata x = update_edata (fn _ => x)
 fun set_source x = update_source (fn _ => x)
 fun set_target x = update_target (fn _ => x)

 fun is_empty g = get_vdata g |> VTab.is_empty

 structure Sharing =
 struct
  type T = T
  structure Data = Data.Sharing
 end

end