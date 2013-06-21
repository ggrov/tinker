(* contains graph combinators *)
signature GRAPH_COMB = 
sig

  structure Graph : BANG_GRAPH

  exception then_exp of Graph.T * V.name * V.name list * string;

  val boundary_inputs : Graph.T -> (V.name * (E.name * Graph.EData.data) * V.name) list
  val boundary_outputs : Graph.T -> (V.name * (E.name * Graph.EData.data) * V.name) list

  val graph_then :  Graph.T -> Graph.T -> 
    ((Graph.VertexCRnm.renaming * Graph.EdgeCRnm.renaming) * Graph.T)
  val graph_tensor :  Graph.T -> Graph.T -> 
    (Graph.VertexCRnm.renaming * Graph.EdgeCRnm.renaming) * Graph.T

  (* use these *)
  val TENSOR :  Graph.T -> Graph.T -> Graph.T
  val THEN :  Graph.T -> Graph.T -> Graph.T
  val LOOP : Graph.T -> Graph.T
  val LOOP_WITH : Graph.T -> Graph.EData.data -> Graph.T

end; (* sig *)

functor GraphCombFun(Graph : BANG_GRAPH) : GRAPH_COMB =
struct

  structure Graph = Graph;

  exception then_exp of Graph.T * V.name * V.name list * string;

  fun boundary_inputs g = 
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

  fun boundary_outputs g = 
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

 fun TENSOR g1 g2 = graph_tensor g1 g2 |> snd;

 (* src, dest *)
 fun check_pluggable_el (_,(_,e1),_) (_,(_,e2),_) =
   Graph.EData.data_eq (e1,e2);

 fun check_pluggable src_b = filter (check_pluggable_el src_b);

 fun del_src_name name = filter (fn (name',_,_) => not(V.name_eq(name,name')))

 fun plug_one (src_b as (_,_,src_name)) (g,dest_bs) =
  case check_pluggable src_b dest_bs of
     [] => (g,dest_bs)
   | [(dest_name,_,_)] => 
    (Graph.do_plug_and_minimise src_name dest_name g,del_src_name dest_name dest_bs)
   | (dest_name,_,_)::xs => 
       ((* warning "more than one possible plugs"; *)
       (Graph.do_plug_and_minimise src_name dest_name g,del_src_name dest_name dest_bs))
  (* raise then_exp (g,src_name,map (fn (v,_,_) => v) xs,"more than one possible plugs"); *)

 (*  Loop  *)
(*  fun rtechn_single_selfloop wire vname graph =
    ( add_single_edge th vname vname graph,th);
*)

 fun graph_then g1 g2 = 
   let 
    fun check_rnm rnm name = 
      case V.Rnm.lookup rnm name of
        NONE => name
      | SOME n => n;
    fun check_rnm_tuple rnm (v1,e,v2) = (check_rnm rnm v1,e,check_rnm rnm v2)
    val ((rnv,rne),g) = graph_tensor g1 g2
    val src_out = boundary_outputs g1 
    val dest_in = map (check_rnm_tuple rnv) (boundary_inputs g2)
    val g' = fold plug_one src_out (g,dest_in) 
           |> fst
   in
     ((rnv,rne),g')
   end;

 fun THEN g1 g2 = graph_then g1 g2 |> snd;

 (* essentially then without all the renaming... *)
 fun LOOP g =  
     fst (fold plug_one (boundary_outputs g) (g,boundary_inputs g));

 fun LOOP_WITH g e =
   let
    fun check_typ (_,(_,d),_) = Graph.EData.data_eq(e,d);
    val filter_typ = filter check_typ 
    val ins = filter_typ (boundary_inputs g)
    val outs = filter_typ (boundary_outputs g)
   in
     fst (fold plug_one outs (g,ins))
   end;

end (* struct *)
