structure GraphExtract = 
struct

 (*
   returns (V.NSet.T,V.NSet.T V.NTab.T)
 *)
 fun compute_next_graph g =
   let 
     val g' = Strategy_Theory.Graph.minimise g
     val rts = GraphEnv.get_rtechns_of_graph g'
     val outs = GraphEnv.get_outputs_of_vertex g' #> V.NSet.of_list;
     fun add v = V.NTab.ins (v,outs v)
  in
     (rts,V.NSet.fold add rts V.NTab.empty)
  end

 fun is_reachable_dest vtab seen from to =
   if V.name_eq (from,to) then true
   else if V.NSet.contains seen from then false
   else case V.NTab.lookup vtab from
         of NONE => false
        | (SOME vs) => V.NSet.exists (fn v => is_reachable_dest vtab (V.NSet.add from seen) v to) vs;

 fun is_reachable_both vtab seen from to =
   if is_reachable_dest vtab seen from to
    then true
    else is_reachable_dest vtab seen to from;

 fun is_reachable vtab rtechns from =
   V.NSet.forall (is_reachable_both vtab V.NSet.empty from) (V.NSet.delete from rtechns);

 fun all_reachable g = 
   let 
     val (rtechns,vtab) = compute_next_graph g
   in
     V.NSet.forall (is_reachable vtab rtechns) rtechns
   end;

 fun connected_subgraphs min_nodes g = 
   let 
      val ng = Strategy_Theory.Graph.normalise g
      val rts = GraphEnv.get_rtechns_of_graph ng
      val size = V.NSet.cardinality rts
      fun add_boundary g =
         V.NSet.fold 
           Strategy_Theory.Graph.add_to_boundary
           (GraphEnv.get_halfedges g)
           g;
   in
     rts
     |> V.NSet.powerset 
     (* not interested in full graph or single nodes *)
     |> filter (fn vs => V.NSet.cardinality vs >= min_nodes andalso V.NSet.cardinality vs < size)
     |> map (fn vs => Strategy_Theory.Graph.get_open_subgraph vs ng)
     |> map Strategy_Theory.Graph.minimise
     (* only interested in graphs that are connected *)
     |> filter all_reachable
     |> map add_boundary
   end;

 (* returns the list *)
 fun disjoint_matches' g rule =
   let 
     val (r,ms) = Strategy_Theory.RulesetRewriter.rule_matches rule g
     fun rtechns m = Strategy_Theory.RulesetRewriter.instantiate_rule m r
                   |> Strategy_Theory.Rule.get_lhs
                   |> GraphEnv.get_rtechns_of_graph
     fun disjoint_rule m1 m2 = 
       V.NSet.is_empty (V.NSet.intersect (rtechns m1) (rtechns m2))
     fun disjoint_one cur x xs = 
       let
          val res = filter (disjoint_rule x) xs
       in  
         if length xs <= length cur then cur else res
       end
     fun disjoint cur [] = cur
      |  disjoint cur (x::xs) = disjoint (disjoint_one cur x xs) xs
   in 
       (rule,r,disjoint [] (Seq.list_of ms))
   end
  
  fun disjoint_matches graph sub_g = 
    (sub_g,GraphEnv.collapse_graph RTechn.set_or_appf "or" sub_g)
    |> Strategy_Theory.Rule.mk
    |> disjoint_matches' graph;

  fun get_matching_sub (min_nodes,min_match) g =
   g |> connected_subgraphs min_nodes
     |> map (disjoint_matches g)
     |> filter (fn (_,_,rs) => length rs >= min_match);
 
end;



