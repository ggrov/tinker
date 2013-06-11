(* 
  contains functionality for working with the graph
*)
signature GRAPH_COMB = 
sig
i
  type graph = Strategy_Theory.Graph.T
  exception goalnode_exp of string * V.name
  exception vertex_exp of string * V.name option
  exception edge_exp of string * V.name option
  exception compose_exp of graph * graph * string
  exception plug_exp of graph * V.name * V.name * string;

  (* default stuff  *)
  val default_vertex_name : V.name
  val boundary_vertex : Strategy_OVData.external_data

  (* vertex predicates and projections *)
  val is_vdata : graph -> V.name -> bool 
  val get_vdata : graph -> V.name -> DB_VertexData.data  (* raises vertex_exp *)
  val is_goalnode_vertex :  DB_VertexData.data -> bool 
  val is_Strategy_vertex : DB_VertexData.data -> bool
  val is_empty_goalnode_vertex : DB_VertexData.data -> bool 
  val is_goalnode :  graph -> V.name -> bool 
  val is_Strategy : graph -> V.name -> bool
  val is_empty_goalnode : graph -> V.name -> bool 
(*
  val vertex_to_goalnode : DB_VertexData.data -> (StrName.name * StrIntName.NSet.T) option
  val vertex_to_Strategy : DB_VertexData.data -> StrategyKey.name option
  val v_to_goalnode : graph -> V.name -> (StrName.name * StrIntName.NSet.T) (* raises vertex_ex *)
  val v_to_Strategy : graph -> V.name -> StrategyKey.name (* raises vertex_ex *)
*)
  (* projects goalnodes and Strategys of a graph *)
  val get_Strategys_of_graph :  graph -> V.NSet.T
  val get_goalnodes_of_graph : graph -> V.NSet.T

 (* empty/default goalnodes *)
  val empty_goalnode : StrName.name -> (StrName.name * StrIntName.NSet.T)
  val empty_goalnode_vertex : StrName.name ->  Strategy_OVData.external_data
  val empty_default_goalnode : (StrName.name * StrIntName.NSet.T)
  val empty_default_goalnode_vertex :  Strategy_OVData.external_data

  (* edges *)
  val edge_src :  graph -> E.name -> V.name
  val edge_dest : graph -> E.name -> V.name
  val edge_data :  graph -> E.name -> StrName.name
  val get_in_edges : graph -> V.name -> E.NSet.T
  val get_out_edges : graph -> V.name -> E.NSet.T
  val update_edge_wire : (string -> string) -> E.name -> graph -> graph
  val add_edge : V.name -> StrIntName.name -> V.name -> graph -> graph
  val change_edge_src : V.name -> E.name -> graph -> graph
  val change_edge_dest : V.name -> E.name -> graph -> graph

  val add_dummy_edge : string -> graph -> V.name * V.name * graph
  val add_dummy_input : string -> graph -> graph
  val add_dummy_output : string -> graph -> graph

  val prj_edge : 
    string * V.name option -> (* error message when no edges *)
    string * V.name option -> (* error message when many edges *)
    E.NSet.T -> (* edge set *)
    E.name

  (* goalnodes *)
  val update_goalnode_data : ((StrName.name * StrIntName.NSet.T) -> (StrName.name * StrIntName.NSet.T)) -> V.name -> graph -> graph  (* raises goalnode_exp *)
  val set_goalnode_data : (StrName.name * StrIntName.NSet.T) -> V.name -> graph -> graph  (* raises goalnode_exp *)

  val insert_and_get_vertex : (E.name * graph) -> (V.name * Strategy_VertexData.data) -> V.name * graph
  val insert_vertex : (E.name * graph) -> (V.name * Strategy_VertexData.data) -> graph
  val insert_goalnode :  (E.name * graph) -> (V.name * (StrName.name * StrIntName.NSet.T)) -> graph

  (* graph *)
  val get_boundary_inputs : graph -> (V.name * (E.name * StringData.data) * V.name) list
  val get_boundary_outputs : graph -> (V.name * (E.name * StringData.data) * V.name) list
  val get_input_types : graph -> StrName.NSet.T
  val get_output_types : graph -> StrName.NSet.T

  (* vertices *)
  val is_output_vertex : graph -> V.name -> bool
  val is_input_vertex : graph -> V.name -> bool
  val get_inputs_of_vertex : graph -> V.name -> V.name list
  val get_outputs_of_vertex : graph -> V.name -> V.name list
  val get_output_boundary_of_Strategy : graph -> V.name -> V.name list (* raises vertex_exp *)
  val get_input_boundary_of_Strategy : graph -> V.name -> V.name list  (* raises vertex_exp *)
  val prj_vertex : 
    string * V.name option -> (* error message when no vertices *)
    string * V.name option -> (* error message when many vertices *)
    V.NSet.T -> (* edge set *)
    V.name

  (* combinators *)
  val graph_compose : theory -> graph -> graph -> 
    ((Strategy_Theory.Graph.VertexCRnm.renaming * Strategy_Theory.Graph.EdgeCRnm.renaming) * graph) list
  val graph_tensor : theory -> graph -> graph -> 
    (Strategy_Theory.Graph.VertexCRnm.renaming * Strategy_Theory.Graph.EdgeCRnm.renaming) * graph
  (* use these *)
  val tensor : theory -> graph -> graph -> graph
  val compose : theory -> graph -> graph -> graph
  val theng : theory -> graph -> graph -> graph
 
  (* adds a single edge between two vertices *)
  val add_single_edge : theory -> V.name -> V.name -> graph -> graph (* raises plug_exp *)
  (* plugs one Strategy into another *)
  val plug_Strategys : theory -> V.name -> V.name -> graph -> graph (* raises plug_exp *)

  (* copies input goalnodes of given vertex of src graph to input goalnodes of dest graph
     (used when evaluating hierarical graphs) *)
  val copy_input : (V.name * (theory * graph)) -> (theory * graph) -> graph
  (* copies output goalnodes of given src graph to input goalnodes of vertex of given dest graph
     (used when evaluating hierarical graphs) *)  
  val copy_output : (theory * graph) -> (V.name * (theory * graph))  -> graph

end;

structure GraphEnv_DB =
struct

  type graph = Strategy_Theory.Graph.T

  exception goalnode_exp of string * V.name;
  exception vertex_exp of string * V.name option;
  exception edge_exp of string * V.name option
  exception compose_exp of graph * graph * string
  exception plug_exp of graph * V.name * V.name * string;

  exception just_edge_exp of string
  exception combine_exp of string

  structure GT = Strategy_Theory;
  structure Graph = GT.Graph;

  val default_vertex_name = V.mk "l";
  val boundary_vertex = Strategy_OVData.WVert;

  (* vertex predicates and projections *)

  fun is_vdata g v = Graph.get_vertex_data g v 
                   |> Strategy_OVData.is_internal_data

  fun get_vdata g v =
   let fun prj (SOME vd) = vd
        |  prj NONE = raise vertex_exp ("not internal vertex",SOME v)
    in
      Graph.get_vertex_data g v 
      |> Strategy_OVData.idata_of 
      |> prj
    end;


  fun is_gnode_vertex (DB_VertexData.GN _) = true
   |  is_gnode_vertex _ = false;

  fun is_rtechn_vertex (DB_VertexData.RT _) = true
   |  is_rtechn_vertex _ = false;

  fun is_gvar_vertex (DB_VertexData.GVar _) = true
   |  is_gvar_vertex _ = false;

  fun is_rvar_vertex (DB_VertexData.RVar _) = true
   |  is_rvar_vertex _ = false;


  fun is_gnode g v = get_vdata g v 
                      |> is_gnode_vertex
                      handle vertex_exp _ => false;

  fun is_rtechn g v = get_vdata g v 
                    |> is_rtechn_vertex
                    handle vertex_exp _ => false; 

  fun is_rvar g v = get_vdata g v 
                    |> is_rvar_vertex
                    handle vertex_exp _ => false; 

  fun is_gvar g v = get_vdata g v 
                    |> is_gvar_vertex
                    handle vertex_exp _ => false; 

  fun vertex_to_gnode (DB_VertexData.GN gnd) = SOME gnd
   |  vertex_to_gnode _ = NONE;

  fun vertex_to_rtechn (DB_VertexData.RT rt) = SOME rt
   |  vertex_to_rtechn _ = NONE;

  fun vertex_to_rvar (DB_VertexData.RVar rt) = SOME rt
   |  vertex_to_rvar _ = NONE;

  fun vertex_to_gvar (DB_VertexData.GVar gnd) = SOME gnd
   |  vertex_to_gvar _ = NONE;

  fun v_to_gnode g v =
    case vertex_to_gnode (get_vdata g v) of
      NONE => raise vertex_exp ("not goalnode vertex",SOME v)
    | SOME gs => gs;

  fun v_to_rtechn g v =
    case vertex_to_rtechn (get_vdata g v) of
      NONE => raise vertex_exp ("not rtechn vertex",SOME v)
    | SOME gs => gs;

  fun v_to_gvar g v =
    case vertex_to_gvar (get_vdata g v) of
      NONE => raise vertex_exp ("not goal variable vertex",SOME v)
    | SOME gs => gs;

  fun v_to_rvar g v =
    case vertex_to_rvar (get_vdata g v) of
      NONE => raise vertex_exp ("not rtechn variable vertex",SOME v)
    | SOME gs => gs;
  

  fun get_rtechns_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_rtechn g)

  fun get_goalnodes_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_gnode g)

  fun get_rvars_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_rvar g)

  fun get_gvars_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_gvar g)

  fun get_halfedges g =
    Graph.get_vnames g |> V.NSet.filter (not o (is_vdata g))

  fun half_edge_to_boundary g =
      V.NSet.fold 
        Strategy_Theory.Graph.add_to_boundary
        (get_halfedges (Strategy_Theory.Graph.minimise g))
        (Strategy_Theory.Graph.minimise g);

  (* edges *)

  fun edge_dest g e = Graph.get_edge g e |> (snd o snd);
  fun edge_src g e = Graph.get_edge g e |> (fst o snd);

  fun edge_data g e = Graph.get_edge g e 
   |> fst
   |> snd;


  fun edge_to_wire (DB_EdgeData.W w) = SOME w
   |  edge_to_wire _ = NONE

  fun e_to_wire g e = case edge_to_wire (edge_data g e) 
       of NONE => raise just_edge_exp "edge not a wire"
       | SOME w => w;   

  fun get_in_edges g v = Graph.get_vertex g v 
    |> snd
    |> fst

  fun get_out_edges g v = Graph.get_vertex g v 
    |> snd
    |> snd

  val update_edge_wire = Graph.update_edge_data;

  fun add_edge from_name wire to_name graph =
     Graph.add_edge (Graph.Directed,fst wire) from_name to_name graph |> snd ;    

  fun change_edge_src from edge g = 
    let val data = edge_data g edge
        val dest = edge_dest g edge
    in
      g |> Graph.delete_edge edge
        |> Graph.add_edge (Graph.Directed,data) from dest
        |> snd
    end;

  fun change_edge_dest to edge g = 
    let val data = edge_data g edge
        val src = edge_src g edge
    in
      g |> Graph.delete_edge edge
        |> Graph.add_edge (Graph.Directed,data) src to
        |> snd
    end;

    (* for adding dummy input and output to a graph *)
    (* w is assumed to be in the context! *)
    fun add_dummy_edge w g0 =
      let       
        val (from,g1) = Graph.add_vertex boundary_vertex g0
        val (to,g2) = Graph.add_vertex boundary_vertex g1
        val (_,g3) = Graph.add_edge (Graph.Directed,DB_EdgeData.W w) from to g2
      in
         (from,to,g3)
      end;

    (* w is assumed to be in the context! *)
    fun add_dummy_input w g0 =
      let 
         val (from,to,g1) = add_dummy_edge w g0
      in
        g1 |> Graph.add_to_boundary from
           |> Graph.del_from_boundary to
      end;

    (* w is assumed to be in the context! *)
    fun add_dummy_output w g0 =
      let 
         val (from,to,g1) = add_dummy_edge w g0
      in
        g1 |> Graph.del_from_boundary from
           |> Graph.add_to_boundary to   
      end;

  fun prj_edge error_empty error_many eset =
    if E.NSet.is_empty eset
      then raise edge_exp error_empty
    else if not (E.NSet.is_singleton eset)
      then raise edge_exp error_many
       else case E.NSet.get_min eset of 
               NONE   => raise edge_exp ("cannot get single (min) element",NONE) (* shouldn't happen *)
            | (SOME e) => e

  fun insert_and_get_vertex (e,g0) node =
    let val (l,g1) = Graph.add_vertex (Strategy_OVData.NVert node) g0
        val from = edge_src g1 e
        val to = edge_dest g1 e
        val edata = edge_data g1 e
        val g2 = g1 |> Graph.delete_edge e 
                    |> Graph.add_edge (Graph.Directed,edata) from l
                    |> snd (* fixme: maybe write a combinator to do this? *)
                    |> Graph.add_edge (Graph.Directed,edata) l to
                    |> snd
    in
        (l,g2)
    end;

  val insert_vertex = snd oo insert_and_get_vertex;
  

  (* graph projections *)

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

  fun filter_edge (DB_EdgeData.W wire) = [wire]
   |  filter_edge _ = []

  val get_input_wires = 
    get_boundary_inputs 
    #> map (fn (_,(_,w),_) => w)
    #> maps filter_edge
    #> W.NSet.of_list

  val get_output_wires = 
    get_boundary_outputs 
    #> map (fn (_,(_,w),_) => w)
    #> maps filter_edge
    #> W.NSet.of_list

  (* vertices *)

  fun is_output_vertex g v =
   g |> get_boundary_outputs
     |> List.exists (fn (_,_,v') => V.name_eq (v',v));

  fun is_input_vertex g v =
   g |> get_boundary_inputs
     |> List.exists (fn (v',_,_) => V.name_eq (v,v'));

  fun get_inputs_of_vertex g v =
    Graph.in_enames g v 
     |> E.NSet.list_of
     |> map (edge_src g);

  fun get_outputs_of_vertex g v =
    Graph.out_enames g v 
     |> E.NSet.list_of
     |> map (edge_dest g);


  fun get_output_boundary_of_rtechn g v =
    if is_rtechn g v 
     then get_outputs_of_vertex g v
       |> filter (is_output_vertex g)
     else raise vertex_exp ("vertex not a reasoning technique",SOME v);

  fun get_input_boundary_of_rtechn g v =
    if is_rtechn g v 
     then get_inputs_of_vertex g v
       |> filter (is_input_vertex g)
     else raise vertex_exp ("vertex not a reasoning technique",SOME v);

  fun prj_vertex error_empty error_many vset =
    if V.NSet.is_empty vset
      then raise vertex_exp error_empty
    else if not (V.NSet.is_singleton vset)
      then raise vertex_exp error_many
       else case V.NSet.get_min vset of 
               NONE   => raise vertex_exp ("cannot get single (min) element",NONE) (* shouldn't happen *)
            | (SOME v) => v

 local open Strategy_Theory.Graph in

  fun get_only_edge' (OVData.WVert,(ins,outs)) =
    (case (E.NSet.is_empty ins,E.NSet.is_empty outs) of
          (true,false) => E.NSet.tryget_singleton outs
        | (false,true) => E.NSet.tryget_singleton ins
        | _            => NONE)
    | get_only_edge' (OVData.NVert _,_) = NONE;

  val get_only_edge = get_only_edge' oo get_vertex;

  fun graph_is_pluggable g v1 v2 =
    case (get_only_edge g v1,get_only_edge g v2) of
         (SOME e1,SOME e2) =>
            (case (get_edge g e1,get_edge g e2) of
                  (((UnDirected,d1),_),((UnDirected,d2),_)) =>
                    true
                | (((Directed,d1),(e1s,e1t)),((Directed,d2),(e2s,e2t))) =>
                    if (V.name_eq (e1s,v1) andalso V.name_eq (e2t,v2))
                    then true
                    else if (V.name_eq (e1t,v1) andalso V.name_eq (e2s,v2))
                    then true
                    else true
                | _ => false
            )
       | _ => false
   end

(*
   fun copy_input (v_src,(th_src,g_src)) (th_dest,g_dest) = 
     let 
        val in_edges = Graph.in_enames g_src v_src
        val inputs = get_boundary_inputs g_dest (* (V.name * (E.name * EData.data) * V.name) list *)
        fun match_with w = filter (fn (_,(_,wd),_) => valid_wiring' (th_src,w) (th_dest,wd)) inputs (* dest must be more general *)
                         |> map (fn (_,(w,_),_) => w) 
        (* adds one vertex *)
        fun add_vertex e g = 
          let 
            val ((_,wire),(v,_)) = Graph.get_edge g_src e
            val gnode = get_vdata g_src v
            val valid_ins_dest = match_with wire 
            fun ins_v ed g1 = insert_vertex (ed,g1) (v,gnode)
          in 
            if is_goalnode g_src v (* check if empty? *)
             then fold ins_v valid_ins_dest g
             else g
          end          
     in
       E.NSet.fold add_vertex in_edges g_dest
     end

   fun copy_output (th_src,g_src) (v_dest,(th_dest,g_dest)) = 
     let 
        val out_edges = Graph.out_enames g_dest v_dest
        val outputs = get_boundary_outputs g_src
                    |> filter (fn (v,(_,_),_) => is_goalnode g_src v)
                    |> map (fn (v,(_,w),_) => (v,get_vdata g_src v,w))
        (* not sure which way to do this matching ?? *)
        fun match_with w = E.NSet.filter (fn e => valid_wiring' (th_src,w) (th_dest,Graph.get_edge_data g_dest e)) out_edges
        val dest_edges = get_out_edges g_dest v_dest
        (* adds one vertex *)
        fun add_vertex (v,node,w) g = 
          let 
            val edges = match_with w
            fun ins_v ed g1 = insert_vertex (ed,g1) (v,node)
          in 
            E.NSet.fold ins_v edges g
          end          
     in
       fold add_vertex outputs g_dest
     end
*)

  fun graph_of_node_edges node inedges outedges =  
     let
       val (v,g) = Graph.add_vertex (Strategy_OVData.NVert node) Graph.empty 
       fun in_wire edge g =
            g |> Graph.add_vertex boundary_vertex
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed,edge) n v g)
              |> (fn (_,g') => g')
       fun out_wire edge g =
            g |> Graph.add_vertex boundary_vertex
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, edge) v n g)
              |> (fn (_,g') => g')  
     in 
       (v, g |> fold in_wire inedges
             |> fold out_wire outedges)
     end;

  fun graph_of_rtechn_vertex rt =  
   graph_of_node_edges
      (DB_VertexData.RT rt) 
      (map DB_EdgeData.W (W.NSet.list_of (RTechn.get_inputs rt)))
      (map DB_EdgeData.W (W.NSet.list_of (RTechn.get_outputs rt)))
(*
     let
       val (v,g) = Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rt)) Graph.empty 
       fun in_wire wire g =
            g |> Graph.add_vertex boundary_vertex
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed,DB_EdgeData.W wire) n v g)
              |> (fn (_,g') => g')
       fun out_wire wire g =
            g |> Graph.add_vertex boundary_vertex
              |> (fn (n,g) => (n,Graph.add_to_boundary n g))
              |> (fn (n,g) => Graph.add_edge (Graph.Directed, DB_EdgeData.W wire) v n g)
              |> (fn (_,g') => g')  
     in 
       (v, g |> W.NSet.fold in_wire (RTechn.get_inputs rt)
             |> W.NSet.fold out_wire (RTechn.get_outputs rt))
     end;
*)

 val graph_of_node = snd ooo graph_of_node_edges;
 val graph_of_rtechn = snd o graph_of_rtechn_vertex;

 fun add_boundary_to data dest graph =
   graph |> Strategy_Theory.Graph.add_vertex boundary_vertex
         |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g))
         |> (fn (n,g) => Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed, data) n dest g)
         |> snd;

 fun add_boundary_from data source graph =
   graph |> Strategy_Theory.Graph.add_vertex boundary_vertex
         |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g))
         |> (fn (n,g) => Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed, data) source n g)
         |> snd;

 fun lift_edgemerge_vertex n edge =
   let 
      fun repeat 0 = []
       |  repeat n = edge :: repeat (n-1)
      val rtechn = RTechn.merge 
                 |> RTechn.set_name "merge"
   in
      graph_of_node_edges (DB_VertexData.RT rtechn) (repeat n) [edge]
   end

(*
 fun lift_edgemerge_vertex n edge =
   let 
      val name = "merge"
      val rtechn = RTechn.merge 
                 |> RTechn.set_name name
      val (l,g) = graph_of_rtechn_vertex rtechn
      fun add_inp 0 g = g
       |  add_inp 1 g = g
       |  add_inp n g = add_inp (n-1) (add_boundary_to edge l g);
   in
     (l,add_inp n g)
   end;
*)

 fun lift_edgemerge n wire = lift_edgemerge_vertex n wire |> snd;

 fun lift_merge_vertex n wire = lift_edgemerge_vertex n (DB_EdgeData.W wire);

 fun lift_merge n wire = lift_edgemerge n (DB_EdgeData.W wire);

 (* lifting of fanout *)

 fun lift_fanout_vertex n wire =
   let 
      val name = "fanout_" ^ (Int.toString n)
      val rtechn = RTechn.id_of wire 
                 |> RTechn.set_name name
      val (l,g) = graph_of_rtechn_vertex rtechn
      fun add_outp 0 g = g
       |  add_outp 1 g = g
       |  add_outp n g = add_outp (n-1) (add_boundary_from (DB_EdgeData.W wire) l g);
   in
     (l,add_outp n g)
   end;

 fun lift_fanout n wire = lift_fanout_vertex n wire |> snd;

  fun lift_vertex node wire =
    let 
     val (v,g) = Strategy_Theory.Graph.empty
               |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert node)
    in
      g |> add_boundary_from (DB_EdgeData.W wire) v
        |> add_boundary_to (DB_EdgeData.W wire) v
    end;

  fun lift_gnode gnode = lift_vertex (DB_VertexData.GN gnode);

  (* collapsing of graph into a vertex *)
  fun collapse_graph_vertex rt_typ name g =
   let 
     val ins =  get_boundary_inputs g
     val outs =  get_boundary_outputs g
     val boundary = Strategy_Theory.Graph.get_boundary g
     val edges = Strategy_Theory.Graph.get_edges g |> E.NTab.get_nameset
     val vertices = Strategy_Theory.Graph.get_vertices g |> V.NTab.get_nameset
     val vertices_to_del = V.NSet.subtract vertices boundary;
     fun delete_edges g = E.NSet.fold (Strategy_Theory.Graph.delete_edge) edges g
     fun delete_vertices g = V.NSet.fold (Strategy_Theory.Graph.delete_vertex) vertices_to_del g
     (* the reasoning technique *)
     val rtechn = RTechn.id 
                |> rt_typ
                |> RTechn.set_name name
                |> RTechn.set_inputs (get_input_wires g)
                |> RTechn.set_outputs (get_output_wires g);
     (* new graph *)
     val simple_graph = g |> delete_edges |> delete_vertices
     val (v,g') = Strategy_Theory.Graph.add_vertex 
                    (Strategy_OVData.NVert (DB_VertexData.RT rtechn)) 
                    simple_graph
     fun insert_in_edge (bv,(en,ed),_) g = 
           Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed, ed) bv v g |> snd
     fun insert_out_edge (_,(en,ed),bv) g = 
           Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed, ed) v bv g |> snd
     val g'' = g' |> fold insert_in_edge ins |> fold insert_out_edge outs
   in 
     (v,g'')
   end;

   fun collapse_graph rt_typ name g  = collapse_graph_vertex rt_typ name g 
                                     |> snd; 

   fun nest_graph name gf th0 =
     let 
       val (rg,th1) = gf th0
       val rh = collapse_graph RTechn.set_hgraph_appf name rg
       val rule = Strategy_Theory.Rule.mk (rh,rg);
       val th' = Strategy_RS.Theory.add_nested rule th1
     in
       (rh,th')
     end;


  fun check_disjoint_wires [] = true
   | check_disjoint_wires (x::xs) =
       if exists (fn y => Wire.eq(x,y)) xs
        then false
        else check_disjoint_wires xs

  fun check_disjoint_edges [] = true
   | check_disjoint_edges (x::xs) =
       if exists (fn y => DB_EdgeData.data_eq(x,y)) xs
        then false
        else check_disjoint_edges xs

 fun fix_io g1 g2 th =
  let
    val insl1 = get_boundary_inputs g1 |> map (fn (_,(_,x),_) => x)
              |> maps filter_edge
    val ins1 = W.NSet.of_list insl1
    val insl2 = get_boundary_inputs g2 |> map (fn (_,(_,x),_) => x)
              |> maps filter_edge
    val ins2 = W.NSet.of_list insl2

    val outp1 = get_output_wires g1
    val outp2 = get_output_wires g2
    val missing1 = W.NSet.subtract outp2 outp1;
    val missing2 = W.NSet.subtract outp1 outp2;
    val g1' = fold add_dummy_output (W.NSet.list_of missing1) g1
    val g2' = fold add_dummy_output (W.NSet.list_of missing2) g2

    val outsl1 = get_boundary_outputs g1' |> map (fn (_,(_,x),_) => x)
    val outsl2 = get_boundary_outputs g2' |> map (fn (_,(_,x),_) => x)
  in
    if check_disjoint_wires insl1 andalso check_disjoint_wires insl2
     then if check_disjoint_edges outsl1 andalso check_disjoint_edges outsl2
       then (if W.NSet.eq ins1 ins2  
            then (g1',g2')
            else raise combine_exp "inputs not the same so cannot fix io")
      else raise combine_exp "outputs not disjoint"
     else raise combine_exp "inputs not disjoint"
  end

 fun check_disj_boundary' g  =
   let 
    val ins =  get_boundary_inputs g
            |> map (fn (_,(_,x),_) =>x)
    val outs =  get_boundary_outputs g 
            |> map (fn (_,(_,x),_) => x)
  in
    if check_disjoint_edges ins
     then if check_disjoint_edges outs
           then NONE
           else SOME "outputs not disjoint"
     else SOME "inputs not disjoint"
  end;

 fun check_disj_boundary g  =
   case check_disj_boundary' g  of 
    NONE => true
    | _ => false;

end; (* end struct *)

structure GraphEnv (* : GRAPH_COMB  *) = GraphEnv_DB 


(*
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
*)

(* combines rtechn and graphs *)
signature RTECHN_COMB =
sig

  exception combine_exp of string

  type graph = Strategy_Theory.Graph.T;

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
  val lift_merge_vertex : int -> W.NSet.T -> theory -> V.name * graph * theory
  val lift_merge : int -> W.NSet.T -> theory -> graph * theory
  val lift_fanout_vertex : int -> W.NSet.T -> theory -> V.name * graph * theory
  val lift_fanout : int -> W.NSet.T -> theory -> graph * theory

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

