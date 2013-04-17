signature PSGRAPH_COMB =
sig
  val THENG: PSGraph.psgraph * PSGraph.psgraph -> PSGraph.psgraph
  val TENSOR:PSGraph.psgraph * PSGraph.psgraph -> PSGraph.psgraph
  val OR: PSGraph.psgraph * PSGraph.psgraph -> PSGraph.psgraph
  val TRY_ORELSE: PSGraph.psgraph * PSGraph.psgraph -> PSGraph.psgraph 
  val NEST: string -> PSGraph.psgraph -> string * PSGraph.psgraph
end

structure PSComb =
struct

  fun THENG ps1 ps2 =
    PSGraph.combine ps1 ps2
    |> PSGraph.set_graph 
         (GraphComb.then_g (PSGraph.get_graph ps1) 
                           (PSGraph.get_graph ps2));

  fun TENSOR ps1 ps2 =
    PSGraph.combine ps1 ps2
    |> PSGraph.set_graph 
         (* fixme: may want to join input and output *)
         (GraphComb.tensor_g (PSGraph.get_graph ps1) 
                           (PSGraph.get_graph ps2));

   fun NEST name psg =
     let 
       val (rg,th1) = gf th0
       val rh = collapse_graph RTechn.set_hgraph_appf name rg
       val rule = PS_Theory.Rule.mk (rh,rg);
       val th' = PS_RS.Theory.add_nested rule th1
     in
       (rh,th')
     end;

(* for simplicity we assume all are non-equal! *)
 (* FIXME: need to check that disjoint output is preserved *)
 fun OR (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1 
     val (g1',g2') = (g1,g2) (* fix_io g1 g2 th2  *) 
     val (v1,rh1) = collapse_graph_vertex RTechn.set_or_appf "or" g1' 
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (v2,rh2) = collapse_graph_vertex RTechn.set_or_appf "or" g2' 
     val rh2' = PS_Theory.Graph.update_vertex_data
                 (K (PS_Theory.Graph.get_vertex_data rh1 v1))
                  v2
                 rh2;
     val rule1 = PS_Theory.Rule.mk (rh1,g1');
     val rule2 = PS_Theory.Rule.mk (rh2',g2');
     val th' = Strategy_RS.Theory.add_or rule1 rule2 th2
   in
     if check_disj_boundary g1' andalso check_disj_boundary g2'
      then (rh1,th')
      else raise combine_exp "new graphs does not have disjoint IO" 
   end

 fun TRY_ORELSE (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1     
     val (g1',g2') = (g1,g2) (* fix_io g1 g2 th2  *) 
     val (v1,rh1) = collapse_graph_vertex RTechn.set_or_appf "try-orelse" g1' 
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (v2,rh2) = collapse_graph_vertex RTechn.set_or_appf "try-orelse" g2' 
     val rh2' = PS_Theory.Graph.update_vertex_data
                 (K (PS_Theory.Graph.get_vertex_data rh1 v1))
                  v2
                 rh2;
     val rule1 = PS_Theory.Rule.mk (rh1,g1');
     val rule2 = PS_Theory.Rule.mk (rh2',g2');
     val th' = Strategy_RS.Theory.add_try rule1 rule2 th2
   in
     if check_disj_boundary g1' andalso check_disj_boundary g2'
      then (rh1,th')
      else raise combine_exp "new graphs does not have disjoint IO" 
   end

  fun LIFT g th = (g,th);
  val LIFTRT : RTechn.T -> theory -> graph * theory  = LIFT o graph_of_rtechn;

end; (* end struct *)

infixr 6 THENG;
val op THENG = GraphComb.THENG;
infixr 6 TENSOR;
val op TENSOR = GraphComb.TENSOR;
infixr 5 OR;
val op OR = GraphComb.OR;
infixr 5 TRY_ORELSE
val op OR = GraphComb.OR;
val LIFT = GraphComb.LIFT;
val LIFTRT = GraphComb.LIFTRT;
val NEST = GraphComb.NEST;
