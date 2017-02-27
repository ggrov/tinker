functor Graph (Data: GRAPH_DATA) : GRAPH=
struct
 structure graph_data = Data

 datatype T = G of {
  vdata  : Data.nvdata VTab.T,
  edata  : Data.edata ETab.T,
  source : EVFn.T,
  target : EVFn.T }


 structure Sharing =
 struct
  type T = T
  structure data = Data.Sharing
 end

end