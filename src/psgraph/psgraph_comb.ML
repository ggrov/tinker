signature PS_COMB =
sig
  structure PSGraph : PS_GRAPH

  type psgraphfn = PSGraph.T -> PSGraph.T
  type goaltyp = PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.T 
  type tactic = PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp.Prover.tactic

 (* working with graph part of a psgraph *)
  val collapse_graph : 
     (RTechn.T -> RTechn.T) (* type of rtechn *)
     -> SStrName.src (* name of rtechn *)
     -> PSGraph.PSTheory.PS_Theory.Graph.T (* old graph *)
     ->  PSGraph.PSTheory.PS_Theory.Graph.T (* new graph *)
  val collapse_graph_vertex : 
     (RTechn.T -> RTechn.T) (* type of rtechn *)
     -> SStrName.src (* name of rtechn *)
     -> PSGraph.PSTheory.PS_Theory.Graph.T (* old graph *)
     -> V.name * PSGraph.PSTheory.PS_Theory.Graph.T (* new graph with vertex name *)


  val THENG: psgraphfn * psgraphfn -> psgraphfn
  val TENSOR: psgraphfn * psgraphfn -> psgraphfn
  val LOOP_WITH: psgraphfn -> goaltyp -> psgraphfn
  val OR: psgraphfn * psgraphfn -> psgraphfn
  val ORELSE: psgraphfn * psgraphfn -> psgraphfn 
  val NEST': string -> psgraphfn -> PSGraph.T -> string * PSGraph.T
  val NEST:string -> psgraphfn -> psgraphfn

  (* merges all outputs that are the same *)
  val MERGE_OUT : psgraphfn -> psgraphfn
  val THENM: psgraphfn * psgraphfn -> psgraphfn
  val TENSORM: psgraphfn * psgraphfn -> psgraphfn

  val LIFTtac' : goaltyp list * goaltyp list -> (RTechn.T * tactic) -> PSGraph.T
  val LIFTtac : goaltyp list * goaltyp list -> (RTechn.T * tactic) -> psgraphfn  

  val LIFT' : goaltyp list * goaltyp list -> RTechn.T -> PSGraph.T
  val LIFT : goaltyp list * goaltyp list -> RTechn.T -> psgraphfn
end

functor PSCombFun(PSGraph : PS_GRAPH) : PS_COMB =
struct
  structure PSGraph = PSGraph
  structure PS_Theory = PSGraph.PSTheory.PS_Theory;
  structure Comb = PSGraph.PSTheory.PS_Comb;
  structure Graph =  PSGraph.PSTheory.PS_Theory.Graph;
  structure GraphSubstData = PSGraph.PSTheory.PS_GraphParam.GraphSubstData;
  structure GraphComb = PSGraph.PSTheory.PS_Comb;

  type psgraphfn = PSGraph.T -> PSGraph.T
  type goaltyp = GraphSubstData.GoalTyp.T 
  type tactic = GraphSubstData.GoalTyp.Prover.tactic

  infixr 6 THENG;
  infixr 5 TENSOR;

  (* collapsing of graph into a vertex *)
  fun collapse_graph_vertex rt_typ name g =
   let 
     val ins =  Comb.boundary_inputs g
     val outs =  Comb.boundary_outputs g
     val boundary = PS_Theory.Graph.get_boundary g
     val edges = PS_Theory.Graph.get_edges g |> E.NTab.get_nameset
     val vertices = PS_Theory.Graph.get_vertices g |> V.NTab.get_nameset
     val vertices_to_del = V.NSet.subtract vertices boundary;
     fun delete_edges g = E.NSet.fold (PS_Theory.Graph.delete_edge) edges g
     fun delete_vertices g = V.NSet.fold (PS_Theory.Graph.delete_vertex) vertices_to_del g
     (* the reasoning technique *)
     val rtechn = RTechn.id 
                |> rt_typ
                |> RTechn.set_name (RT.mk name)
     (* new graph *)
     val simple_graph = g |> delete_edges |> delete_vertices
     val (v,g') = PS_Theory.Graph.add_vertex 
                    (PS_Theory.Graph.OVData.NVert (PSGraph.PSTheory.PS_GraphParam.GraphSubstData.RT rtechn)) 
                    simple_graph
     fun insert_in_edge (bv,(en,ed),_) g = 
           PS_Theory.Graph.add_edge (PS_Theory.Graph.Directed, ed) bv v g |> snd
     fun insert_out_edge (_,(en,ed),bv) g = 
           PS_Theory.Graph.add_edge (PS_Theory.Graph.Directed, ed) v bv g |> snd
     val g'' = g' |> fold insert_in_edge ins |> fold insert_out_edge outs
   in 
     (v,g'')
   end;

   fun collapse_graph rt_typ name g  = collapse_graph_vertex rt_typ name g 
                                     |> snd; 


  (* graph of a reasoning technique *)

  fun graph_of_node_edges_vertex node inedges outedges =  
     let
       val (v,g) = Graph.add_vertex (Graph.OVData.NVert node) Graph.empty 
       fun in_wire edge g =
            g |> Graph.add_vertex Graph.OVData.WVert
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed,edge) n v g)
              |> (fn (_,g') => g')
       fun out_wire edge g =
            g |> Graph.add_vertex Graph.OVData.WVert
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, edge) v n g)
              |> (fn (_,g') => g')  
     in 
       (v, g |> fold in_wire inedges
             |> fold out_wire outedges)
     end;

  fun graph_of_node_edges node ins outs = graph_of_node_edges_vertex node ins outs |> snd;

  fun graph_of_rtechn_vertex rt ins outs =  
   graph_of_node_edges_vertex
      (GraphSubstData.RT rt) 
      (map GraphSubstData.GT ins)
      (map GraphSubstData.GT outs)

  fun graph_of_rtechn rt ins outs =   graph_of_rtechn_vertex rt ins outs |> snd;


  fun THENG (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val g' = GraphComb.THEN g1 g2
  in
    ps2 |> PSGraph.set_graph g'
  end;

  fun TENSOR (psf1,psf2) ps =
   let 
     val ps1 = psf1 ps
     val g1 = PSGraph.get_graph ps1
     val ps2 = psf2 ps1
     val g2 = PSGraph.get_graph ps2
     val g' = GraphComb.TENSOR g1 g2
  in
    ps2 |> PSGraph.set_graph g'
  end;

  fun LOOP_WITH psfn gt ps =
    let
      val ps1 = psfn ps
      val graph = PSGraph.get_graph ps1
      val edge = GraphSubstData.GT gt
      val graph' = GraphComb.LOOP_WITH graph edge
    in
     PSGraph.set_graph graph' ps1
   end;

  fun NEST' name psf ps = 
    let 
      val ps' = psf ps
      val g = PSGraph.get_graph ps'
      val name' = PSGraph.fresh_name ps' name
      val g' = collapse_graph (RTechn.set_appf (RTechn.HGraph NONE)) name' g
      val rule = PS_Theory.Rule.mk (g',g);
      val ps'' = ps' |> PSGraph.set_graph g'
                     |> PSGraph.update_g_tacs (StrName.NTab.ins (name',rule))
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
     val g' = collapse_graph (RTechn.set_appf RTechn.Or) name' g1
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
     val g' = collapse_graph (RTechn.set_appf RTechn.OrElse) name' g1
  in
    ps2 |> PSGraph.set_graph g'
        |> PSGraph.update_orelse_tacs (StrName.NTab.ins (name',(g1,g2)))
  end; 

  fun LIFT (ins,outs) rt ps = 
    ps |> PSGraph.set_graph (graph_of_rtechn rt  ins outs);

  fun LIFT' (ins,outs) rt = 
     PSGraph.of_graph (graph_of_rtechn rt ins outs);

  fun LIFTtac (ins,outs) (rt,tac) ps =
   case RTechn.get_tactic rt of
     NONE => LIFT (ins,outs) rt ps
     | (SOME n) => ps
          |> PSGraph.update_atomics (StrName.NTab.doadd (n,tac))
          |> LIFT (ins,outs) rt;

  fun LIFTtac' (ins,outs) (rt,tac) =
   case RTechn.get_tactic rt of
     NONE => PSGraph.of_graph (graph_of_rtechn rt ins outs)
     | (SOME n) => 
          PSGraph.of_graph (graph_of_rtechn rt ins outs)
          |> PSGraph.update_atomics (StrName.NTab.doadd (n,tac));

  (* computes list of multiple outputs for merging *)

  (* noneq is used to remove duplicates *)
  fun mk_merge res [] = res
   |  mk_merge (c,n,noneq) (x::xs) =
        if GraphSubstData.edata_eq (c,x)
          then mk_merge (c,n+1,noneq) xs
          else mk_merge (c,n,x::noneq) xs;

  fun mk_merges [] = []
   |  mk_merges (x::xs) = 
        let
          val (c,n,xs') = mk_merge (x,1,[]) xs
        in (* if more than one output of same type *)
          if n > 1 then (c,n)::mk_merges xs' else mk_merges xs'
        end;

 (* MERGE *)
  fun MERGE_OUT psf ps =
   let 
     val ps' = psf ps
     val g = PSGraph.get_graph ps'
     val outs = GraphComb.boundary_outputs g 
              |> map (fn (_,(_,d),_) => d)
     fun mk_in_list e 0 = []
      |  mk_in_list e n = e :: mk_in_list e (n-1);
     fun mk_mgraph (e,n) =
       PSGraph.set_graph 
         (graph_of_node_edges (GraphSubstData.RT (RTechn.id)) (mk_in_list e n) [e]);
     val merges = mk_merges outs
                |> map mk_mgraph
     (* cannot be empty *)
     fun merge_tensored (x::[]) = x
      |  merge_tensored (x::y::[]) = x TENSOR y
      |  merge_tensored (x::y::ys) = (x TENSOR y) TENSOR (merge_tensored ys)
  in
   (case merges of
        [] => ps'
      | xs => (psf THENG (merge_tensored xs)) ps)
  end; 

  fun THENM (x,y) = MERGE_OUT (x THENG y);
  fun TENSORM (x,y) = MERGE_OUT (x TENSOR y); 
 

end; (* end struct *)

(* TO DO: this has to be done for each structore of the functor *)
(*
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
*)
