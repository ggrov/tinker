(* contains graph combinators *)
signature GRAPH_COMB = 
sig

  type graph = Strategy_Theory.Graph.T

  exception then_exp of graph * V.name * V.name list * string;

  val graph_theng :  graph -> graph -> 
    ((Strategy_Theory.Graph.VertexCRnm.renaming * Strategy_Theory.Graph.EdgeCRnm.renaming) * graph)
  val graph_tensor :  graph -> graph -> 
    (Strategy_Theory.Graph.VertexCRnm.renaming * Strategy_Theory.Graph.EdgeCRnm.renaming) * graph

  (* use these *)
  val tensor :  graph -> graph -> graph
  val theng :  graph -> graph -> graph
 
end; (* sig *)

structure GraphComb_DB =
struct

  type graph = Strategy_Theory.Graph.T

  exception then_exp of graph * V.name * V.name list * string;

  structure GT = Strategy_Theory;
  structure Graph = GT.Graph;

(* move to env *)
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

  (* end move to env *)

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

 fun tensor g1 g2 = graph_tensor g1 g2 |> snd;

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
   | xs => raise then_exp (g,src_name,map (fn (v,_,_) => v) xs,"more than one possible plugs");

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

 fun theng g1 g2 = graph_then g1 g2 |> snd;
 
 (* add OR, etc -- now in graph_comb at the end *)

end; (* end struct *)

structure GraphComb : GRAPH_COMB  = GraphComb_DB 


