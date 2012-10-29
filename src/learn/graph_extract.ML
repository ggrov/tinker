structure GraphExtract = 
struct

 (* compute transitive closure ?? *)  

 fun reachable g v1 v2 = true

 fun all_reachable_from g v1 vs = true;

 fun all_reachable g vs = true;
   
 fun naive_subgraphs g = 
   let 
      val ng = Strategy_Theory.Graph.normalise g
      val rts = GraphEnv.get_rtechns_of_graph ng
      val size = V.NSet.cardinality rts
   in
     rts
     |> V.NSet.powerset 
     (* not interested in full graph or single nodes *)
     |> filter (fn vs => V.NSet.cardinality vs > 1 andalso V.NSet.cardinality vs < size)
     (* only interested in graphs that are connected *)
     |> filter (all_reachable ng)
     |> map (fn vs => Strategy_Theory.Graph.get_open_subgraph vs ng)
   end;


 
end;



