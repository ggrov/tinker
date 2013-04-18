(* contains graph combinators *)
signature GRAPH_COMB = 
sig

  type graph = PS_Theory.Graph.T

  exception then_exp of graph * V.name * V.name list * string;

  val graph_theng :  graph -> graph -> 
    ((PS_Theory.Graph.VertexCRnm.renaming * PS_Theory.Graph.EdgeCRnm.renaming) * graph)
  val graph_tensor :  graph -> graph -> 
    (PS_Theory.Graph.VertexCRnm.renaming * PS_Theory.Graph.EdgeCRnm.renaming) * graph

  (* use these *)
  val tensor_g :  graph -> graph -> graph
  val then_g :  graph -> graph -> graph
  val self_loops : graph -> graph

end; (* sig *)

structure GraphComb =
struct

  type graph = PS_Theory.Graph.T
  exception then_exp of graph * V.name * V.name list * string;
  structure GT = PS_Theory;
  structure Graph = GT.Graph;

  fun get_boundary_inputs g = 
    let val bvertexes = Graph.get_boundary g (* Vertex.NSet.T *)
        fun dest_name bv e = let val ((_,ed),(_,v)) = Graph.get_edge g e in (bv,(e,ed),v) end
        fun mk_pairs v = Graph.out_enames g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  fun get_boundary_outputs g = 
    let val bvertexes = Graph.get_boundary g (* Vertex.NSet.T *)
        fun src_name bv e =  let val ((_,ed),(v,_)) = Graph.get_edge g e in (v,(e,ed),bv) end
        fun mk_pairs v = Graph.in_enames g v 
                  |> E.NSet.list_of
                  |> map (fn e => src_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  (* collapsing of graph into a vertex *)
  fun collapse_graph_vertex rt_typ name g =
   let 
     val ins =  get_boundary_inputs g
     val outs =  get_boundary_outputs g
     val boundary = PS_Theory.Graph.get_boundary g
     val edges = PS_Theory.Graph.get_edges g |> E.NTab.get_nameset
     val vertices = PS_Theory.Graph.get_vertices g |> V.NTab.get_nameset
     val vertices_to_del = V.NSet.subtract vertices boundary;
     fun delete_edges g = E.NSet.fold (PS_Theory.Graph.delete_edge) edges g
     fun delete_vertices g = V.NSet.fold (PS_Theory.Graph.delete_vertex) vertices_to_del g
     (* the reasoning technique *)
     val rtechn = RTechn.id 
                |> rt_typ
                |> RTechn.set_name name
     (* new graph *)
     val simple_graph = g |> delete_edges |> delete_vertices
     val (v,g') = PS_Theory.Graph.add_vertex 
                    (PS_OVData.NVert (GraphSubstData.RT rtechn)) 
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

 (* tensor *)
 fun graph_tensor g1 g2 =
  let 
     (* rename vertices *)
     val v_rnm = V.Rnm.mk V.NSet.empty (Graph.get_vnames g1) V.NTab.empty;
     val (rnm, g2') = Graph.VertexCRnm.rename v_rnm g2;
     (* rename edges *)
     val e_rnm = E.Rnm.mk E.NSet.empty (Graph.get_enames g1) E.NTab.empty;
     val (rnme, g2'') = Graph.EdgeCRnm.rename e_rnm g2';
  in
     ((rnm,rnme),Graph.merge_by_vertices g1 g2'')
  end;

 fun tensor_g g1 g2 = graph_tensor g1 g2 |> snd;

 (* src, dest *)
 fun check_pluggable_el (_,(_,e1),_) (_,(_,e2),_) =
   DB_EdgeData.data_eq (e1,e2);

 fun check_pluggable src_b = filter (check_pluggable_el src_b);

 fun del_src_name name = filter (fn (name',_,_) => not(V.name_eq(name,name')))

 fun plug_one (src_b as (_,_,src_name)) (g,dest_bs) =
  case check_pluggable src_b dest_bs of
     [] => (g,dest_bs)
   | [(dest_name,_,_)] => 
    (Graph.do_plug_and_minimise src_name dest_name g,del_src_name dest_name dest_bs)
   | (dest_name,_,_)::xs => 
       (warning "more than one possible plugs";
       (Graph.do_plug_and_minimise src_name dest_name g,del_src_name dest_name dest_bs))
  (* raise then_exp (g,src_name,map (fn (v,_,_) => v) xs,"more than one possible plugs"); *)

 (*  Loop  *)
(*  fun rtechn_single_selfloop wire vname graph =
    ( add_single_edge th vname vname graph,th);
*)

 fun graph_theng g1 g2 = 
   let 
    fun check_rnm rnm name = 
      case V.Rnm.lookup rnm name of
        NONE => name
      | SOME n => n;
    fun check_rnm_tuple rnm (v1,e,v2) = (check_rnm rnm v1,e,check_rnm rnm v2)
    val ((rnv,rne),g) = graph_tensor g1 g2
    val src_out = get_boundary_outputs g1 
    val dest_in = map (check_rnm_tuple rnv) (get_boundary_inputs g2)
    val g' = fold plug_one src_out (g,dest_in) 
           |> fst
   in
     ((rnv,rne),g')
   end;

 fun then_g g1 g2 = graph_theng g1 g2 |> snd;

 (* essentially then without all the renaming... *)
 fun self_loops g =  
     fst (fold plug_one (get_boundary_outputs g) (g,get_boundary_inputs g));


  (* graph of a reasoning technique *)

  fun graph_of_node_edges node inedges outedges =  
     let
       val (v,g) = Graph.add_vertex (PS_OVData.NVert node) Graph.empty 
       fun in_wire edge g =
            g |> Graph.add_vertex PS_OVData.WVert
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed,edge) n v g)
              |> (fn (_,g') => g')
       fun out_wire edge g =
            g |> Graph.add_vertex PS_OVData.WVert
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, edge) v n g)
              |> (fn (_,g') => g')  
     in 
       (v, g |> fold in_wire inedges
             |> fold out_wire outedges)
     end;

  fun graph_of_rtechn_vertex rt ins outs =  
   graph_of_node_edges
      (GraphSubstData.RT rt) 
      (map GraphSubstData.GT ins)
      (map GraphSubstData.GT outs)

  fun graph_of_rtechn rt ins outs =   graph_of_rtechn_vertex rt ins outs |> snd;

end (* struct *)
