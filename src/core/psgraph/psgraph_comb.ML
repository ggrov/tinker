(* todo: add sharing stuffs *)
signature PS_COMB =
sig
  structure PSGraph : PS_GRAPH
end

functor PSCombFun(structure PSGraph : PS_GRAPH) (*: PS_COMB*) =
struct
  structure PSGraph = PSGraph
  structure Theory = PSGraph.Theory;
  structure Graph =  PSGraph.Theory.Graph;

  type psgraphfn = PSGraph.T -> PSGraph.T
  type goaltyp = PSGraph.Theory.Data.GoalTyp.T 
  type tactic = PSGraph.Theory.Data.GoalTyp.Prover.tactic

  fun graph_of_node_edges_vertex nvode inedges outedges =  
    let
      val (v,g) = Theory.Graph.add_vertex (Theory.Graph.NVert nvode) Theory.Graph.empty ;
      fun in_wire edge g =
       Theory.Graph.add_vertex Theory.Graph.WVert g
       |> (fn (n,g) => Theory.Graph.add_edge (Directed,edge) n v g)
       |> (fn (_,g') => g')
      fun out_wire edge g =
            g |> Theory.Graph.add_vertex Theory.Graph.WVert
              |> (fn (n,g) => Theory.Graph.add_edge (Directed, edge) v n g)
              |> (fn (_,g') => g')  
    in
       (v, g |> fold in_wire inedges
             |> fold out_wire outedges) 
    end

  fun graph_of_node_edges node ins outs = graph_of_node_edges_vertex node ins outs |> snd;

  fun boundary_inputs g = 
    let val bvertexes = Theory.Graph.get_boundary g (* Vertex.NSet.T *)
        fun dest_name bv e = let val ((_,ed),(_,v)) = Theory.Graph.get_edge_info g e in (bv,(e,ed),v) end
        fun mk_pairs v = Theory.Graph.get_out_dir_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  fun boundary_outputs g = 
    let val bvertexes = Theory.Graph.get_boundary g (* Vertex.NSet.T *)
        fun src_name bv e =  let val ((_,ed),(v,_)) = Theory.Graph.get_edge_info g e in (v,(e,ed),bv) end
        fun mk_pairs v = Theory.Graph.get_in_dir_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => src_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

(* tensor *)
  fun graph_tensor g1 g2 =
    let 
      val vrn = VSub.extend_fresh (Theory.Graph.get_vertices g2)
                                  (VSub.mk_from_avoids (Theory.Graph.get_vertices g1))
      val ern = ESub.extend_fresh (Graph.get_edges g2)
                                  (ESub.mk_from_avoids (Theory.Graph.get_edges g1))
      val brn = BSub.extend_fresh (Graph.get_bboxes g2)
                                  (BSub.mk_from_avoids (Theory.Graph.get_bboxes g1))
  (*
    val vrnm = VSub.extend_fixed (get_vertices rule)
    val ernm = ESub.extend_fixed (get_edges rule)
    val brnm =  BSub.extend_fixed (get_bboxes rule)
  *)
      val (rnm, g2') = (Theory.Graph.rename_bang_graph (vrn,ern,brn)) g2
  
    in
       (rnm,Theory.Graph.merge g1 g2')
    end;
   

  fun TENSORG g1 g2 = graph_tensor g1 g2 |> snd;
  
  (* src, dest *)
  fun check_pluggable_el (_,(_,e1),_) (_,(_,e2),_) =
   Theory.Graph.edata_eq (e1,e2);
  
  fun check_pluggable src_b = filter (check_pluggable_el src_b);
  
  fun del_src_name name = filter (fn (name',_,_) => not(V.name_eq(name,name')))

  fun plug_one (src_b as (_,_,src_name)) (g,dest_bs) =
    case check_pluggable src_b dest_bs of
       [] => (g,dest_bs)
     | [(dest_name,_,_)] => 
      (Theory.Graph.plug_and_minimise_anon src_name dest_name g,del_src_name dest_name dest_bs)
     | (dest_name,_,_)::xs => 
         ((* warning "more than one possible plugs"; *)
         (Theory.Graph.plug_and_minimise_anon src_name dest_name g,del_src_name dest_name dest_bs))
  (* raise then_exp (g,src_name,map (fn (v,_,_) => v) xs,"more than one possible plugs"); *)
  
  (*  Loop  *)
  (*  fun rtechn_single_selfloop wire vname graph =
    ( add_single_edge th vname vname graph,th);
  *)

  fun graph_then g1 g2 = 
    let 
      fun check_rnm rnm name = 
        case VSub.get_opt rnm name of
          NONE => name
        | SOME n => n;
      fun check_rnm_tuple rnm (v1,e,v2) = (check_rnm rnm v1,e,check_rnm rnm v2)
      val ((rnv,rne,rnb),g) = graph_tensor g1 g2
      val src_out = boundary_outputs g1 
      val dest_in = map (check_rnm_tuple rnv) (boundary_inputs g2)
      val g' = fold plug_one src_out (g,dest_in) 
             |> fst
    in
     ((rnv,rne,rnb),g')
    end;

  fun THENG g1 g2 = graph_then g1 g2 |> snd;
  
  (* essentially then without all the renaming... *)
  fun LOOPG g =  
     fst (fold plug_one (boundary_outputs g) (g,boundary_inputs g));
  
  (* DO TO: fixme - now hack: picks first *)
  fun LOOP_WITHG g e =
   let
    fun check_typ (_,(_,d),_) = Theory.Graph.edata_eq(e,d);
    val filter_typ = filter check_typ 
    val ins = filter_typ (boundary_inputs g)
    val outs = filter_typ (boundary_outputs g)
   in
     fst (fold plug_one [hd outs] (g,[hd ins]))
   end;

(* ---------------------- COMBOs for psgraph ---------------------- *)
(* todo and fixme: need to handle duplications *)
  fun THEN (ps1, ps2) =
     let 
       val g1 = PSGraph.get_top_graph ps1
       val g2 = PSGraph.get_top_graph ps2
       val g' = THENG g1 g2
    in
      PSGraph.merge_disjoint ps1 ps2 |> PSGraph.set_top_graph g' (* todo: merge and rename *)
    end;

  fun TENSOR (ps1, ps2) =
   let 
     val g1 = PSGraph.get_top_graph ps1
     val g2 = PSGraph.get_top_graph ps2
     val g = TENSORG g1 g2
  in
    PSGraph.merge_disjoint ps1 ps2 |> PSGraph.set_top_graph g
  end;

  fun LOOP_WITH  gt ps =
    let
      val graph = PSGraph.get_top_graph ps
      val graph' = LOOP_WITHG graph gt
    in
     PSGraph.set_top_graph graph' ps
   end;

  fun LIFT' (ins,outs) nvdata ps = 
    ps |> PSGraph.set_top_graph (graph_of_node_edges nvdata ins outs);

  fun LIFT (ins,outs) nvdata = 
     PSGraph.of_graph (graph_of_node_edges nvdata ins outs);


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
