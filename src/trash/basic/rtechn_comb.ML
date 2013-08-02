(* combines rtechn and graphs *)
signature RTECHN_COMB =
sig

  exception combine_exp of string

  type graph = RTechn_Theory.Graph.T;

  (* get vertices with same name as given rtechn *)
  val get_vertices_of_rtechn : RTechn.T -> graph -> V.NSet.T 
  val get_vertex_of_rtechn : RTechn.T -> graph -> V.name (* raise vertex_exp *)

  (* make graphs and lifting *)
  val graph_of_rtechn : RTechn.T -> theory -> V.name * graph * theory
  val mk_graph : RTechn.T -> theory -> graph * theory
  val lift_rtechn_and_bind : RTechn.T -> theory -> graph * theory
  val lift_rtechn_and_try_bind : RTechn.T -> theory -> graph * theory
  val lift_rtechn_and_try_bind_with_name : RTechn.T -> theory -> V.name * graph * theory

  (* merge and fanout *)
  val lift_merge_vertex : int -> WireNode.T -> theory -> V.name * graph * theory
  val lift_merge : int -> WireNode.T -> theory -> graph * theory
  val lift_fanout_vertex : int -> WireNode.T -> theory -> V.name * graph * theory
  val lift_fanout : int -> WireNode.T -> theory -> graph * theory

  (* collapsing of graph into a vertex *)
  val collapse_graph_vertex :
    (RTechn.T -> RTechn.T) -> (* to set the type of rtechn (HGraph,Or etc) *)
    string -> (* name of rtechn *)
    graph -> (* graph to collapse *)
    theory ->
    (RTechn.T * (* new rtechn *)
    (graph * theory)) (* graph of rtechn + boundary and updated theory *)
  (* same as collapse graph, but doesn't return new rtechn *)
  val collapse_graph : (RTechn.T -> RTechn.T) -> string -> graph -> theory ->
    (graph * theory) (* graph of rtechn + boundary and updated theory *)
  (* used to create hierarchy - as collapse, but also created rewrite rule to unfold *)
  val nest_graph : 
       string -> (* name *)
      (theory -> graph*theory) -> (* graph (function) *)
      theory ->
      graph * theory

  (* loop *)
  val rtechn_single_selfloop : V.name -> graph -> theory -> graph * theory

  (* combinators *)
  val th_compose : ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory
  val th_tensor : ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory

  val th_or : ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory
  val th_try_or_else : ((theory -> graph*theory) * (theory -> graph*theory)) -> theory -> graph * theory

end;


structure RTechnComb : RTECHN_COMB = struct

  type graph = RTechn_Theory.Graph.T;
  structure GT = RTechn_Theory;
  structure Graph = GT.Graph;

  exception combine_exp of string

  fun get_vertices_of_rtechn rt g =
    GraphComb.get_rtechns_of_graph g 
    |> V.NSet.filter (fn v => RTechn.get_name rt = GraphComb.v_to_rtechn g v);(* maybe use matching instead *)

  fun get_vertex_of_rtechn rt g =
    case (get_vertices_of_rtechn rt g |> V.NSet.list_of) of
       [v] => v
     | [] => raise GraphComb.vertex_exp("no rtechn: " ^ RTechn.get_name rt,NONE)
     | _ => raise GraphComb.vertex_exp("several vertices of rtechn: " ^ RTechn.get_name rt,NONE);

  fun create_edge th (fwire as (wire,_)) =
    if FWire_Ctxt.Theory.contains_name th (FWire_Ctxt.of_str (BWire.string_of wire))
     then (FWire_Ctxt.of_str (BWire.string_of wire),th)
     else 
       let 
         val new_edge = FWire_Ctxt.Theory.fresh_name th (FWire_Ctxt.of_str (BWire.string_of wire))
         val th' = FWire_Ctxt.Theory.add_wire (new_edge,fwire) th
       in  
         (new_edge,th')
       end;

  fun graph_of_rtechn rt th0 =  
     let val rtname = RTechn.get_name rt
         val (v,g) =  Graph.add_vertex (RTechn_OVData.NVert (DB_RTechn_VertexData.RTechnNode rtname)) Graph.empty
         fun in_wire (fwire as (wire,_)) (g,th) =
          let (* fixme: find a better way of generating edge(str/int) from actual wire *)
             val (new_edge,th') = create_edge th fwire
          in
            g |> Graph.add_vertex GraphComb.boundary_vertex
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, new_edge) n v g)
              |> (fn (_,g') => (g',th'))
          end
         fun out_wire (fwire as (wire,_)) (g,th) = 
          let
             val (new_edge,th') = create_edge th fwire
          in
            g |> Graph.add_vertex GraphComb.boundary_vertex
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, new_edge) v n g)
              |> (fn (_,g') => (g',th'))
          end
         val in_wires = WireNode.W.NSet.fold in_wire (RTechn.get_inputs rt)
         val out_wires = WireNode.W.NSet.fold out_wire (RTechn.get_outputs rt) 
         val (g',th') = (g,th0) |> in_wires |> out_wires        
     in 
       (v,g',th')
     end;

local open RTechn; in 

(*  val mk_graph = graph_of_rtechn #> snd; *)

  fun mk_graph rt th = graph_of_rtechn rt th |> (fn (_,g',th') => (g',th'));

  (* FIXME: this is a hack! Need to revisit wire to allow a more generic wire representation *)
  fun add_suffix suffix (wire,ss) = ((BWire.string_of wire) ^ suffix |> BWire.of_string,ss)

  (* there must be an easier way??? *)
  (* 1: consume/id box + id/consume box *)
  fun mk_orr_box_suffix name inp1 inp2 =
   let fun add_suff suff ws =
           ws |> WireNode.W.NSet.list_of 
              |> map (add_suffix suff)
              |> WireNode.W.NSet.of_list
      val outp1 = add_suff ".fst" inp1
      val outp2 = add_suff ".snd" inp2
      val appfst = RState.try_apply_output_of_input (add_suffix ".fst")
      val appsnd = RState.try_apply_output_of_input (add_suffix ".snd")
      fun appf rst = Seq.cons (appfst rst) (Seq.cons (appsnd rst) Seq.empty)
   in
    id |> set_name name
       |> set_inputs (WireNode.W.NSet.union_merge inp1 inp2) 
       |> set_outputs (WireNode.W.NSet.union_merge outp1 outp2) 
       |> RTechn.set_atomic_appf appf
   end;

  (* lifting *)

 fun lift_rtechn_and_try_bind_with_name rt th = 
   let 
      val th' = if RTechn_Ctxt.Theory.contains_name th (RTechn.get_name rt)
                 then th
                 else RTechn_Ctxt.Theory.add_rtechn rt th
   in 
      graph_of_rtechn rt th'
   end;

 fun lift_rtechn_and_bind rt th = 
   let 
     val name = RTechn_Ctxt.Theory.fresh_name th (RTechn.get_name rt)
     val rt' = rt |> RTechn.set_name name
     val (g,th') = mk_graph rt' th
   in
     (g,RTechn_Ctxt.Theory.add_rtechn rt' th')
   end;

 fun lift_rtechn_and_try_bind rt th = 
   if RTechn_Ctxt.Theory.contains_name th (RTechn.get_name rt)
    then mk_graph rt th
    else mk_graph rt th |> (fn (g,th') => (g,RTechn_Ctxt.Theory.add_rtechn rt th'));

 (* lifting of merge *)

 fun get_gnode rst (wname,gndnms) = 
     (GNode_Ctxt.Wire.get wname rst, (* wire name *)
      gndnms |> GNodeKey.NSet.list_of (* goal nodes *)
             |> map (fn gname => GNode_Ctxt.get gname rst)
             |> GNode.GoalSet.of_list);

  fun get_gnode_of_v rst g v = get_gnode rst (GraphComb.v_to_goalnode g v);

  fun get_gnodes rst g = 
    GraphComb.get_goalnodes_of_graph g   
    |> V.NSet.list_of
    |> map (get_gnode_of_v rst g);

 fun add_boundary_to name data dest graph =
   graph |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
         |> (fn (n,g) => RTechn_Theory.Graph.add_edge (RTechn_Theory.Graph.Directed, data) n dest g)
         |> snd;

 fun add_boundary_from name data source graph =
   graph |> RTechn_Theory.Graph.add_vertex GraphComb.boundary_vertex
         |> (fn (n,g) => RTechn_Theory.Graph.add_edge (RTechn_Theory.Graph.Directed, data) source n g)
         |> snd;

 fun lift_merge_vertex n wire th =
   let 
      val name = "merge_" ^ (Int.toString n)
      val rtechn = RTechn.merge_of wire |> RTechn.set_name name
      val (v,g,th') = lift_rtechn_and_try_bind_with_name rtechn th;
      val inedge = GraphComb.get_in_edges g v |> E.NSet.tryget_singleton |> the;
      val data = GraphComb.edge_data g inedge
      fun add_inp 0 g = g
       |  add_inp 1 g = g
       |  add_inp n g = add_inp (n-1) (add_boundary_to name data v g);
   in
     (v,add_inp n g,th')
   end;

 fun lift_merge n wire th = 
    let
      val (_,g,th) = lift_merge_vertex n wire th
    in
      (g,th)
    end;

 (* lifting of fanout *)

 fun lift_fanout_vertex n wire th =
   let 
      val name = "fanout_" ^ (Int.toString n)
      val rtechn = RTechn.id_of wire 
                 |> RTechn.set_name name
      val (v,g,th') = lift_rtechn_and_try_bind_with_name rtechn th;
      val outedge = GraphComb.get_out_edges g v |> E.NSet.tryget_singleton |> the;
      val data = GraphComb.edge_data g outedge
      fun add_outp 0 g = g
       |  add_outp 1 g = g
       |  add_outp n g = add_outp (n-1) (add_boundary_from name data v g);
   in
     (v,add_outp n g,th')
   end;

 fun lift_fanout n wire th = 
    let
      val (_,g,th) = lift_fanout_vertex n wire th
    in
      (g,th)
    end;

  (* collapsing of graph into a vertex *)
  fun collapse_graph_vertex rt_typ name g th =
   let 
     val ins = GraphComb.get_boundary_inputs g
     val outs = GraphComb.get_boundary_outputs g
     val boundary = RTechn_Theory.Graph.get_boundary g
     val edges = RTechn_Theory.Graph.get_edges g |> E.NTab.get_nameset
     val vertices = RTechn_Theory.Graph.get_vertices g |> V.NTab.get_nameset
     val vertices_to_del = V.NSet.subtract vertices boundary;
     fun delete_edges g = E.NSet.fold (RTechn_Theory.Graph.delete_edge) edges g
     fun delete_vertices g = V.NSet.fold (RTechn_Theory.Graph.delete_vertex) vertices_to_del g
     (* the reasoning technique *)
     val new_name = RTechn_Ctxt.Theory.fresh_name th name
     val in_wires = map (fn (_,(_,w),_) => FWire_Ctxt.Theory.get_wire th w) ins
                  |> WireNode.W.NSet.of_list
     val out_wires = map (fn (_,(_,w),_) => FWire_Ctxt.Theory.get_wire th w) outs
                  |> WireNode.W.NSet.of_list
     val rtechn = RTechn.id 
                |> rt_typ
                |> RTechn.set_name new_name
                |> RTechn.set_inputs in_wires
                |> RTechn.set_outputs out_wires;
     (* new graph *)
     val simple_graph = g |> delete_edges |> delete_vertices
     val (v,g') = RTechn_Theory.Graph.add_vertex 
                    (RTechn_OVData.NVert (DB_RTechn_VertexData.RTechnNode name)) 
                    simple_graph
     fun insert_in_edge (bv,(en,ed),_) g = 
           RTechn_Theory.Graph.add_edge  (RTechn_Theory.Graph.Directed, ed) bv v g |> snd
     fun insert_out_edge (_,(en,ed),bv) g = 
           RTechn_Theory.Graph.add_edge (RTechn_Theory.Graph.Directed, ed) v bv g |> snd
     val g'' = g' |> fold insert_in_edge ins |> fold insert_out_edge outs
   in 
     (rtechn,(g'',RTechn_Ctxt.Theory.add_rtechn rtechn th))
   end;

   fun collapse_graph rt_typ name g th = collapse_graph_vertex rt_typ name g th
                                      |> snd; 

   fun nest_graph name gf th0 =
     let 
       val (rg,th1) = gf th0
       val (rh,th2) = collapse_graph RTechn.set_hgraph_appf name rg th1
       val rule = RTechn_Theory.Rule.mk (rh,rg);
       val th' = RTechn_RS.Theory.add_nested rule th2
     in
       (rh,th')
     end;

 (*  Loop  *)
  fun rtechn_single_selfloop vname graph th =
    (GraphComb.add_single_edge th vname vname graph,th);

  (* combinators *)
  fun th_compose (f1,f2) th =
    let 
      val (g1,th1) = f1 th
      val (g2,th2) = f2 th1
    in
      (GraphComb.compose th2 g1 g2,th2)
    end;

 (* fixme: may want to join input and output *)
  fun th_tensor (f1,f2) th =
    let 
      val (g1,th1) = f1 th
      val (g2,th2) = f2 th1
    in
       (GraphComb.tensor th2 g1 g2,th2)
    end; 

  (* aux functions for or and try_or_else combinators *)

  (* FIXME: simplifies by only looking at equality *)
  fun compare_wset ws1 ws2 = 
    (WireNode.W.NSet.subtract ws2 ws1,WireNode.W.NSet.subtract ws1 ws2);
    
  val equal_wset = WireNode.W.NSet.eq

  fun check_disjoint [] = true
   | check_disjoint (x::xs) =
       if exists (fn y => x <: y orelse y <: x) xs
        then false
        else check_disjoint xs

 fun fix_io g1 g2 th =
  let
    val insl1 = GraphComb.get_boundary_inputs g1 
             |> map (fn (_,(_,x),_) => (FWire_Ctxt.Theory.get_wire th x))
    val ins1 = WireNode.W.NSet.of_list insl1
    val insl2 = GraphComb.get_boundary_inputs g2 
             |> map (fn (_,(_,x),_) => (FWire_Ctxt.Theory.get_wire th x))
    val ins2 = WireNode.W.NSet.of_list insl2

    (* to project name *)
    fun lookup_name [] w = raise combine_exp ("name of wire does not exists (should not happen)")
     |  lookup_name ((n,w)::nws) w' = if WireNode.WInfo.eq (w,w') then n else lookup_name nws w'

    val outp1 = GraphComb.get_boundary_outputs g1 
              |> map (fn (_,(_,x),_) => (x,FWire_Ctxt.Theory.get_wire th x))
    val outp2 = GraphComb.get_boundary_outputs g2 
              |> map (fn (_,(_,x),_) => (x,FWire_Ctxt.Theory.get_wire th x))
    val outs1 = outp1 |> map snd |> WireNode.W.NSet.of_list
    val outs2 = outp2 |> map snd |> WireNode.W.NSet.of_list
     
    val (missing1,missing2) =  compare_wset outs1 outs2
    val mis_names1 = map (lookup_name outp2) (WireNode.W.NSet.list_of missing1)
    val mis_names2 = map (lookup_name outp1) (WireNode.W.NSet.list_of missing2)
    val g1' = fold GraphComb.add_dummy_output mis_names1 g1
    val g2' = fold GraphComb.add_dummy_output mis_names2 g2
  in
    if check_disjoint insl1 andalso check_disjoint insl2
     then if check_disjoint (map snd outp1) andalso check_disjoint (map snd outp2)
       then (if equal_wset ins1 ins2 
            then (g1',g2')
            else raise combine_exp "inputs not the same so cannot fix io")
      else raise combine_exp "outputs not disjoint"
     else raise combine_exp "inputs not disjoint"
  end

 fun check_disj_boundary' g th =
   let 
    val ins = GraphComb.get_boundary_inputs g
            |> map (fn (_,(_,x),_) => (FWire_Ctxt.Theory.get_wire th x))
    val outs = GraphComb.get_boundary_outputs g 
            |> map (fn (_,(_,x),_) => (FWire_Ctxt.Theory.get_wire th x))
  in
    if check_disjoint ins
     then if check_disjoint outs
           then NONE
           else SOME "outputs not disjoint"
     else SOME "inputs not disjoint"
  end;

 fun check_disj_boundary g th =
   case check_disj_boundary' g th of 
    NONE => true
    | _ => false;

 (* or combinator *)

 (* for simplicity we assume all are non-equal! *)
 (* FIXME: need to check that disjoint output is preserved *)
 fun th_or (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1 
     val (g1',g2') = fix_io g1 g2 th2    
     val (rh1,th3) = collapse_graph RTechn.set_or_appf "or" g1' th2
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (rh2,th4) = collapse_graph RTechn.set_or_appf "or" g2' th3

     (* Ensures the same rtechn in both rules (FIXME: will not fail properly) *)
     val (SOME v1) = GraphComb.get_rtechns_of_graph rh1 |> V.NSet.tryget_singleton
     val rt1 = RTechn_Theory.Graph.get_vertex_data rh1 v1
     val (SOME v2) = GraphComb.get_rtechns_of_graph rh2 |> V.NSet.tryget_singleton 
     val rt2 = GraphComb.v_to_rtechn rh2 v2
     (* deletes rh2 graph and deletes rt2 from context *)
     val th5 = th4 (* FIXME: this causes exception on get_el! in init of eval: RTechn_Ctxt.Theory.delete_key rt2 th4 *)
     val rh2' = RTechn_Theory.Graph.update_vertex_data (K rt1) v2 rh2
     val rule1 = RTechn_Theory.Rule.mk (rh1,g1');
     val rule2 = RTechn_Theory.Rule.mk (rh2',g2');
     val th' = RTechn_RS.Theory.add_or rule1 rule2 th5
   in
     if check_disj_boundary g1' th5 andalso check_disj_boundary g2' th5
      then (rh1,th')
      else raise combine_exp "new graphs does not have disjoint IO" 
   end

 (* try_orelse combinator *)
 
 (* FIXME: same issues as OR graph *)
 fun th_try_or_else (fg1,fg2) th0 =
   let 
     val (g1,th1) = fg1 th0
     val (g2,th2) = fg2 th1     
     val (g1',g2') = fix_io g1 g2 th2 
     val (rh1,th3) = collapse_graph RTechn.set_try_appf "try orelse" g1' th2
     (* fixme: should be same rtechn -> need new version of collapse! *)
     val (rh2,th4) = collapse_graph RTechn.set_try_appf "try orelse" g2' th3

     (* Ensures the same rtechn in both rules (FIXME: will not fail properly) *)
     val (SOME v1) = GraphComb.get_rtechns_of_graph rh1 |> V.NSet.tryget_singleton
     val rt1 = RTechn_Theory.Graph.get_vertex_data rh1 v1
     val (SOME v2) = GraphComb.get_rtechns_of_graph rh2 |> V.NSet.tryget_singleton 
     val rt2 = GraphComb.v_to_rtechn rh2 v2
     (* deletes rh2 graph and deletes rt2 from context *)
     val th5 = th4 (* FIXME: this causes exception on get_el! in init of eval: RTechn_Ctxt.Theory.delete_key rt2 th4 *)
     val rh2' = RTechn_Theory.Graph.update_vertex_data (K rt1) v2 rh2
     val rule1 = RTechn_Theory.Rule.mk (rh1,g1');
     val rule2 = RTechn_Theory.Rule.mk (rh2',g2');
     val th' = RTechn_RS.Theory.add_try rule1 rule2 th5
   in
     if check_disj_boundary g1' th5 andalso check_disj_boundary g2' th5
      then (rh1,th')
      else raise combine_exp "new graphs does not have disjoint IO" 
   end
 end; (* open RTechn *)
end; (* struct *)

infixr 6 compose;
val op compose = RTechnComb.th_compose; 

infixr 6 tensor;
val op tensor = RTechnComb.th_tensor;

infixr 5 orr;
val op orr = RTechnComb.th_or;

infixr 5 tryorelse;
val op tryorelse = RTechnComb.th_try_or_else;

val lift = RTechnComb.lift_rtechn_and_bind;
val try_lift = RTechnComb.lift_rtechn_and_try_bind;
