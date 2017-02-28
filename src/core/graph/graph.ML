functor Graph (Data: GRAPH_DATA) : GRAPH =
struct
 structure Data = Data

 datatype T = G of {
  vdata  : Data.vdata VTab.T,
  edata  : Data.edata ETab.T,
  source : EVFn.T,
  target : EVFn.T }


 structure Sharing =
 struct
  type T = T
  structure Data = Data.Sharing
 end

end