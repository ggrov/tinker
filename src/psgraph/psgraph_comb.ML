signature PSGRAPH_COMB =
sig
  type psgraphfn = PSGraph.T -> PSGraph.T
 
  val THENG: psgraphfn * psgraphfn -> psgraphfn
  val TENSOR: psgraphfn * psgraphfn -> psgraphfn
  val OR: psgraphfn * psgraphfn -> psgraphfn
  val ORELSE: psgraphfn * psgraphfn -> psgraphfn 
  val NEST': string -> psgraphfn -> PSGraph.T -> string * PSGraph.T
  val NEST:string -> psgraphfn -> psgraphfn
  
  val LIFT' : GoalTyp.T list * GoalTyp.T list -> RTechn.T -> PSGraph.T
  val LIFT : GoalTyp.T list * GoalTyp.T list -> RTechn.T -> psgraphfn
end

structure PSComb : PSGRAPH_COMB =
struct

  type psgraphfn = PSGraph.T -> PSGraph.T

  fun THENG (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val g' = GraphComb.then_g g1 g2
  in
    ps2 |> PSGraph.set_graph g'
  end;

  fun TENSOR (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val g' = GraphComb.tensor_g g1 g2
  in
    ps2 |> PSGraph.set_graph g'
  end;

  fun NEST' name psf ps = 
    let 
      val ps' = psf ps
      val g = PSGraph.get_graph ps'
      val name' = PSGraph.fresh_name ps' name
      val g' = GraphComb.collapse_graph (RTechn.set_appf (RTechn.HGraph NONE)) name' g
      val ps'' = ps' |> PSGraph.set_graph g'
                     |> PSGraph.update_g_tacs (StrName.NTab.ins (name',g))
    in
      (name',ps'')
    end;

   fun NEST name psf ps = NEST' name psf ps |> snd;

(* for simplicity we assume all are non-equal! *)
 (* FIXME: need to check that disjoint output is preserved *)
  fun OR (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val name' = PSGraph.fresh_name ps2 "orr"
     val g' = GraphComb.collapse_graph (RTechn.set_appf RTechn.Or) name' g1
  in
    ps2 |> PSGraph.set_graph g'
        |> PSGraph.update_or_tacs (StrName.NTab.ins (name',[g1,g2]))
  end;   

  fun ORELSE (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val name' = PSGraph.fresh_name ps2 "orelse"
     val g' = GraphComb.collapse_graph (RTechn.set_appf RTechn.OrElse) name' g1
  in
    ps2 |> PSGraph.set_graph g'
        |> PSGraph.update_orelse_tacs (StrName.NTab.ins (name',(g1,g2)))
  end; 

  fun LIFT (ins,outs) rt ps = 
    ps |> PSGraph.set_graph (GraphComb.graph_of_rtechn rt  ins outs);

  fun LIFT' (ins,outs) rt = 
     PSGraph.of_graph (GraphComb.graph_of_rtechn rt ins outs);

end; (* end struct *)

infixr 6 THENG;
val op THENG = PSComb.THENG;
infixr 6 TENSOR;
val op TENSOR = PSComb.TENSOR;
infixr 5 OR;
val op OR = PSComb.OR;
infixr 5 ORELSE
val op ORELSE = PSComb.OR;
val LIFT = PSComb.LIFT;
val LIFT' = PSComb.LIFT';
val NEST = PSComb.NEST;
val NEST' = PSComb.NEST';
