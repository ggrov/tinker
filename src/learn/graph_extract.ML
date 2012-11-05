structure GraphExtract = 
struct

 (*
   returns (V.NSet.T,V.NSet.T V.NTab.T)
 *) fun compute_next_graph g =
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

 fun connected_subgraphs (min_nodes,use_min) (max_nodes,use_max) g = 
   let 
      val ng = Strategy_Theory.Graph.normalise g
      val rts = GraphEnv.get_rtechns_of_graph ng
      val size = V.NSet.cardinality rts
      fun add_boundary g =
         V.NSet.fold 
           Strategy_Theory.Graph.add_to_boundary
           (GraphEnv.get_halfedges g)
           g;
      fun filter_size vs = 
         V.NSet.cardinality vs < size
         andalso
         (if use_min then V.NSet.cardinality vs >= min_nodes else true)
         andalso
         (if use_max then max_nodes >= V.NSet.cardinality vs else true);
   in
     rts
     |> V.NSet.powerset 
     (* not interested in full graph or single nodes *)
     |> filter filter_size
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
(*
     fun rtechns m = Strategy_Theory.RulesetRewriter.instantiate_rule m r
                   |> Strategy_Theory.Rule.get_lhs
                   |> GraphEnv.get_rtechns_of_graph
*)
     fun disjoint_rule m1 m2 = 
       let 
         (* avoids exception that vertex is not in graph -- assuming all existing are *)
         fun has_node g v = case Strategy_Theory.Graph.lookup_vertex g v of
                                 NONE => false | _ => true;
         val v1 = m1 
                |> Strategy_Theory.Match.get_vmap 
                |> VInjEndo.get_codset
                |> V.NSet.filter (has_node g)
                |> V.NSet.filter (GraphEnv.is_rtechn (Strategy_Theory.Match.get_tgt m1))
         val v2 = m2 
                |> Strategy_Theory.Match.get_vmap 
                |> VInjEndo.get_codset
                |> V.NSet.filter (has_node g)
                |> V.NSet.filter (GraphEnv.is_rtechn (Strategy_Theory.Match.get_tgt m2))
       in
          V.NSet.is_empty (V.NSet.intersect v1 v2)
       end;
(*     fun disjoint_rule m1 m2 = 
       V.NSet.is_empty (V.NSet.intersect (rtechns m1) (rtechns m2))
*)
     fun disjoint_one cur x xs = 
       let
          val res = x::filter (disjoint_rule x) xs
       in  
         if length res <= length cur then cur else res
       end
     fun disjoint cur [] = cur
      |  disjoint cur (x::xs) = disjoint (disjoint_one cur x xs) xs
   in 
       (rule,r,disjoint [] (Seq.list_of ms))
   end
  
  fun disjoint_matches graph sub_g = 
    (sub_g,GraphEnv.collapse_graph RTechn.set_hgraph_appf "fixname" sub_g)
    |> Strategy_Theory.Rule.mk
    |> disjoint_matches' graph;

  val sort_res = 
   let
    fun opposite_order ((_,_,ms1),(_,_,ms2)) = 
      case Int.compare (length ms1,length ms2) of
        LESS => GREATER
      | GREATER => LESS
      | x => x
   in
     sort opposite_order
   end;

  (* 
      args: pairs (int,bool) where in is size and bool highlight if this should be used
         (min_nodes,use_minm) - minimum number of rtechns
         (max_match,use_maxm) - maximum number of rtechns
         (min_match,use_minm) - minimum number of disjoint matches
  *)
  fun get_matching_sub (min_nodes,use_minm) (max_match,use_maxm) (min_match,use_minmatch) g =
   g |> connected_subgraphs (min_nodes,use_minm) (max_match,use_maxm)
     |> map (disjoint_matches g) 
     |> (fn xs => if use_minmatch then filter (fn (_,_,rs) => length rs >= min_match) xs else xs)
     |> sort_res; (* sorted on number of matches, could be a combination of number of boxes etc *)
  (* this is really more heuristic ! *)


  (* projects rule only *)
  val get_matching_sub_rule =  (map (fn (r,_,_) => r)) oooo get_matching_sub 


  (* functions to rewrite and return the hierarchical rule *)
  val rewrite = EvalAtomic.rewrite;

  fun REPEAT_MAX' rule gs = 
    let
      val gs' = maps (rewrite rule) gs
    in
     case gs' of
       [] => gs
      | gs' => REPEAT_MAX' rule gs'
    end;

  (* FIXME: need to find a way to give the hierarchical box a new name! *)
  fun generalise_max g rule = 
    let 
     val newgs = REPEAT_MAX' rule [g]
     val newrule = Strategy_Theory.Rule.mk (Strategy_Theory.Rule.get_rhs rule,Strategy_Theory.Rule.get_lhs rule)
    in 
     (newrule,newgs)
    end;

  (* finds best matching applies generalisation and returns unfold rule with updated graph(s) *)
  fun generalise_best min_nds max_nds min_match graph =
     graph |> get_matching_sub_rule min_nds max_nds min_match
           |> hd
           |> generalise_max graph;

   
end;



