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
  val tensor_g :  graph -> graph -> graph
  val then_g :  graph -> graph -> graph

  val THENG: ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory
  val TENSOR: ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory
  val OR: ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory
  val TRY_ORELSE: ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory 
  val NEST: string -> (theory -> graph*theory) -> theory -> graph * theory
  val LIFT: graph -> theory -> graph * theory
  val LIFTRT: RTechn.T -> theory -> graph * theory

end; (* sig *)

structure GraphComb_DB =
struct

  type graph = Strategy_Theory.Graph.T

  exception then_exp of graph * V.name * V.name list * string;

  structure GT = Strategy_Theory;
  structure Graph = GT.Graph;

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
   | xs => raise then_exp (g,src_name,map (fn (v,_,_) => v) xs,"more than one possible plugs");

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
    val src_out = GraphEnv.get_boundary_outputs g1 
    val dest_in = map (check_rnm_tuple rnv) (GraphEnv.get_boundary_inputs g2)
    val g' = fold plug_one src_out (g,dest_in) 
           |> fst
   in
     ((rnv,rne),g')
   end;

 fun then_g g1 g2 = graph_theng g1 g2 |> snd;
 
 (* add OR, etc -- now in graph_comb at the end *)

  (* combinators *)
  fun THENG (f1,f2) th =
    let 
      val (g1,th1) = f1 th
      val (g2,th2) = f2 th1
    in
      (then_g g1 g2,th2)
    end; 

 (* fixme: may want to join input and output *)
  fun TENSOR (f1,f2) th =
    let 
      val (g1,th1) = f1 th
      val (g2,th2) = f2 th1
    in
       (tensor_g g1 g2,th2)
    end; 

 val NEST = GraphEnv.nest_graph;


(* for simplicity we assume all are non-equal! *)
 (* FIXME: need to check that disjoint output is preserved *)
 fun OR (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1 
     val (g1',g2') = (g1,g2) (* fix_io g1 g2 th2  *) 
     val (v1,rh1) = GraphEnv.collapse_graph_vertex RTechn.set_or_appf "or" g1' 
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (v2,rh2) = GraphEnv.collapse_graph_vertex RTechn.set_or_appf "or" g2' 
     val rh2' = Strategy_Theory.Graph.update_vertex_data
                 (K (Strategy_Theory.Graph.get_vertex_data rh1 v1))
                  v2
                 rh2;
     val rule1 = Strategy_Theory.Rule.mk (rh1,g1');
     val rule2 = Strategy_Theory.Rule.mk (rh2',g2');
     val th' = Strategy_RS.Theory.add_or rule1 rule2 th2
   in
     if GraphEnv.check_disj_boundary g1' andalso GraphEnv.check_disj_boundary g2'
      then (rh1,th')
      else raise GraphEnv.combine_exp "new graphs does not have disjoint IO" 
   end

 (* FIXME: same issues as OR graph *)
 fun TRY_ORELSE (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1     
     val (g1',g2') = (g1,g2) (* fix_io g1 g2 th2  *) 
     val (v1,rh1) = GraphEnv.collapse_graph_vertex RTechn.set_or_appf "try-orelse" g1' 
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (v2,rh2) = GraphEnv.collapse_graph_vertex RTechn.set_or_appf "try-orelse" g2' 
     val rh2' = Strategy_Theory.Graph.update_vertex_data
                 (K (Strategy_Theory.Graph.get_vertex_data rh1 v1))
                  v2
                 rh2;
     val rule1 = Strategy_Theory.Rule.mk (rh1,g1');
     val rule2 = Strategy_Theory.Rule.mk (rh2',g2');
     val th' = Strategy_RS.Theory.add_try rule1 rule2 th2
   in
     if GraphEnv.check_disj_boundary g1' andalso GraphEnv.check_disj_boundary g2'
      then (rh1,th')
      else raise GraphEnv.combine_exp "new graphs does not have disjoint IO" 
   end

  fun LIFT g th = (g,th);
  
  val LIFTRT : RTechn.T -> theory -> graph * theory  = LIFT o GraphEnv.graph_of_rtechn;

end; (* end struct *)

structure GraphComb : GRAPH_COMB  = GraphComb_DB 

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
