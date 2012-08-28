(* 
  contains functionality for working with the graph
*)
signature GRAPH_COMB = 
sig

  type graph = Strategy_Theory.Graph.T

  exception goalnode_exp of string * V.name
  exception vertex_exp of string * V.name option
  exception edge_exp of string * V.name option
  exception compose_exp of graph * graph * string
  exception plug_exp of graph * V.name * V.name * string;

  (* default stuff  *)
  val default_vertex_name : V.name
  val boundary_vertex : RTechn_OVData.external_data

  (* vertex predicates and projections *)
  val is_vdata : graph -> V.name -> bool 
  val get_vdata : graph -> V.name -> DB_RTechn_VertexData.data  (* raises vertex_exp *)
  val is_goalnode_vertex :  DB_RTechn_VertexData.data -> bool 
  val is_rtechn_vertex : DB_RTechn_VertexData.data -> bool
  val is_empty_goalnode_vertex : DB_RTechn_VertexData.data -> bool 
  val is_goalnode :  graph -> V.name -> bool 
  val is_rtechn : graph -> V.name -> bool
  val is_empty_goalnode : graph -> V.name -> bool 
  val vertex_to_goalnode : DB_RTechn_VertexData.data -> (StrName.name * StrIntName.NSet.T) option
  val vertex_to_rtechn : DB_RTechn_VertexData.data -> RTechnKey.name option
  val v_to_goalnode : graph -> V.name -> (StrName.name * StrIntName.NSet.T) (* raises vertex_ex *)
  val v_to_rtechn : graph -> V.name -> RTechnKey.name (* raises vertex_ex *)

  (* projects goalnodes and rtechns of a graph *)
  val get_rtechns_of_graph :  graph -> V.NSet.T
  val get_goalnodes_of_graph : graph -> V.NSet.T

 (* empty/default goalnodes *)
  val empty_goalnode : StrName.name -> (StrName.name * StrIntName.NSet.T)
  val empty_goalnode_vertex : StrName.name ->  RTechn_OVData.external_data
  val empty_default_goalnode : (StrName.name * StrIntName.NSet.T)
  val empty_default_goalnode_vertex :  RTechn_OVData.external_data

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

  val insert_and_get_vertex : (E.name * graph) -> (V.name * RTechn_VertexData.data) -> V.name * graph
  val insert_vertex : (E.name * graph) -> (V.name * RTechn_VertexData.data) -> graph
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
  val get_output_boundary_of_rtechn : graph -> V.name -> V.name list (* raises vertex_exp *)
  val get_input_boundary_of_rtechn : graph -> V.name -> V.name list  (* raises vertex_exp *)
  val prj_vertex : 
    string * V.name option -> (* error message when no vertices *)
    string * V.name option -> (* error message when many vertices *)
    V.NSet.T -> (* edge set *)
    V.name

  (* combinators *)
  val graph_compose : theory -> graph -> graph -> 
    ((RTechn_Theory.Graph.VertexCRnm.renaming * RTechn_Theory.Graph.EdgeCRnm.renaming) * graph) list
  val graph_tensor : theory -> graph -> graph -> 
    (RTechn_Theory.Graph.VertexCRnm.renaming * RTechn_Theory.Graph.EdgeCRnm.renaming) * graph
  (* use these *)
  val tensor : theory -> graph -> graph -> graph
  val compose : theory -> graph -> graph -> graph
  val theng : theory -> graph -> graph -> graph
 
  (* adds a single edge between two vertices *)
  val add_single_edge : theory -> V.name -> V.name -> graph -> graph (* raises plug_exp *)
  (* plugs one rtechn into another *)
  val plug_rtechns : theory -> V.name -> V.name -> graph -> graph (* raises plug_exp *)

  (* copies input goalnodes of given vertex of src graph to input goalnodes of dest graph
     (used when evaluating hierarical graphs) *)
  val copy_input : (V.name * (theory * graph)) -> (theory * graph) -> graph
  (* copies output goalnodes of given src graph to input goalnodes of vertex of given dest graph
     (used when evaluating hierarical graphs) *)  
  val copy_output : (theory * graph) -> (V.name * (theory * graph))  -> graph

end;

structure GraphComb_DB =
struct

  type graph = Strategy_Theory.Graph.T

  exception goalnode_exp of string * V.name;
  exception vertex_exp of string * V.name option;
  exception edge_exp of string * V.name option
  exception compose_exp of graph * graph * string
  exception plug_exp of graph * V.name * V.name * string;

  structure GT = RTechn_Theory;
  structure Graph = GT.Graph;

  val default_vertex_name = V.mk "l";
  val boundary_vertex = RTechn_OVData.WVert;

  (* vertex predicates and projections *)

  fun is_vdata g v = Graph.get_vertex_data g v 
                   |> RTechn_OVData.is_internal_data

  fun get_vdata g v =
   let fun prj (SOME vd) = vd
        |  prj NONE = raise vertex_exp ("not internal vertex",SOME v)
    in
      Graph.get_vertex_data g v 
      |> RTechn_OVData.idata_of 
      |> prj
    end;

  fun is_goalnode_vertex (DB_RTechn_VertexData.GoalNode _) = true
   |  is_goalnode_vertex _ = false;

  fun is_rtechn_vertex (DB_RTechn_VertexData.RTechnNode _) = true
   |  is_rtechn_vertex _ = false;

  fun is_empty_goalnode_vertex (DB_RTechn_VertexData.GoalNode (_,gs)) =
           StrIntName.NSet.is_empty gs
   |  is_empty_goalnode_vertex _ = false;

  fun is_goalnode g v = get_vdata g v 
                      |> is_goalnode_vertex
                      handle vertex_exp _ => false;

  fun is_rtechn g v = get_vdata g v 
                    |> is_rtechn_vertex
                    handle vertex_exp _ => false; 

  fun is_empty_goalnode g v = get_vdata g v |> is_empty_goalnode_vertex
                            handle vertex_exp _ => false;

  fun vertex_to_goalnode (DB_RTechn_VertexData.GoalNode gnd) = SOME gnd
   |  vertex_to_goalnode _ = NONE;

  fun vertex_to_rtechn (DB_RTechn_VertexData.RTechnNode rt) = SOME rt
   |  vertex_to_rtechn _ = NONE;

  fun v_to_goalnode g v =
    case vertex_to_goalnode (get_vdata g v) of
      NONE => raise vertex_exp ("not goalnode vertex",SOME v)
    | SOME gs => gs;

  fun v_to_rtechn g v =
    case vertex_to_rtechn (get_vdata g v) of
      NONE => raise vertex_exp ("not rtechn vertex",SOME v)
    | SOME gs => gs;

  fun get_rtechns_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_rtechn g)

  fun get_goalnodes_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_goalnode g)

 (* empty goalnodes *)
  fun empty_goalnode bwire = (bwire,StrIntName.NSet.empty);
  fun empty_goalnode_vertex bwire = RTechn_OVData.NVert (DB_RTechn_VertexData.GoalNode (empty_goalnode bwire));
  val empty_default_goalnode = ("goal",StrIntName.NSet.empty);
  val empty_default_goalnode_vertex = RTechn_OVData.NVert (DB_RTechn_VertexData.GoalNode empty_default_goalnode);

  (* edges *)

  fun edge_dest g e = Graph.get_edge g e |> (snd o snd);
  fun edge_src g e = Graph.get_edge g e |> (fst o snd);

  fun edge_data g e = Graph.get_edge g e 
   |> fst
   |> snd;

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
        val (_,g3) = Graph.add_edge (Graph.Directed,w) from to g2
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

  (* auxiliary functions *)

  fun lift_rtechn f     (RTechn_OVData.WVert)               = RTechn_OVData.WVert
   |  lift_rtechn f (RTechn_OVData.NVert (DB_RTechn_VertexData.RTechnNode rt)) = RTechn_OVData.NVert (DB_RTechn_VertexData.RTechnNode (f rt))
   |  lift_rtechn f      (RTechn_OVData.NVert v)             = RTechn_OVData.NVert v;

  fun lift_goalnode f     (RTechn_OVData.WVert)               = RTechn_OVData.WVert
   |  lift_goalnode f (RTechn_OVData.NVert (DB_RTechn_VertexData.GoalNode l)) = RTechn_OVData.NVert (DB_RTechn_VertexData.GoalNode (f l))
   |  lift_goalnode f      (RTechn_OVData.NVert v)             = RTechn_OVData.NVert v;

  (* goalnodes  *)

  fun update_goalnode_data gf = Graph.update_vertex_data (lift_goalnode gf);

  val set_goalnode_data = update_goalnode_data o K;

  fun insert_and_get_vertex (e,g0) (name,node) =
    let val (l,g1) = Graph.add_vertex (RTechn_OVData.NVert node) g0
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
  
  fun insert_goalnode eg (n,gnd) = insert_vertex eg (n,DB_RTechn_VertexData.GoalNode gnd);

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

  val get_input_types = 
    get_boundary_inputs 
    #> map (fn (_,(_,w),_) => w)
    #> StrName.NSet.of_list

  val get_output_types = 
    get_boundary_outputs 
    #> map (fn (_,(_,w),_) => w)
    #> StrName.NSet.of_list

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

 (* aux function for plugging combinators *)

 (* check wiring - uses <: relation *)
(*
 fun valid_wiring (g,th) from to = 
      FWire_Ctxt.Theory.get_wire th (Graph.get_edge_data g from) <: FWire_Ctxt.Theory.get_wire th (Graph.get_edge_data g to);

 fun valid_wiring_wire th from to = 
      FWire_Ctxt.Theory.get_wire th from <: FWire_Ctxt.Theory.get_wire th to;
*)

 local open RTechn_Theory.Graph in
  fun get_only_edge' (OVData.WVert,(ins,outs)) =
    (case (E.NSet.is_empty ins,E.NSet.is_empty outs) of
          (true,false) => E.NSet.tryget_singleton outs
        | (false,true) => E.NSet.tryget_singleton ins
        | _            => NONE)
    | get_only_edge' (OVData.NVert _,_) = NONE;
  val get_only_edge = get_only_edge' oo get_vertex
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

  (*HACK!! graph_is_pluggable ignores type *)
 fun is_pluggable th g v1 v2 =
   if graph_is_pluggable g v1 v2 (* RTechn_Theory.Graph.are_pluggable g v1 v2 *) 
    then(case (E.NSet.tryget_singleton (get_in_edges g v1), E.NSet.tryget_singleton (get_out_edges g v2)) of 
       (SOME s,SOME d) =>  valid_wiring (g,th) s d
       | _ => false)
    else false;
(* was
 fun is_pluggable th g v1 v2 =
   case RTechn_Theory.Graph.boundary_coherence g v1 v2 of (* coherence in graph sense : was  *)
     NONE => false
   | SOME _ => (* data matches *)
      case (E.NSet.tryget_singleton (get_in_edges g v1),
            E.NSet.tryget_singleton (get_out_edges g v2)) of 
       (SOME s,SOME d) => 
         valid_wiring (g,th) s d
      | _ => false;
*)

 (* assuming srscs and dest are boundary should 
    produce all possible pluggings (since an is_pluggable 
    will fail if the dest has already been plugged) *)
 fun plug _ [] _ g = [g] (* no more to plug *)
  |  plug _ _ [] g = [g] (* no more to plug *)
  |  plug th (s::srcs) dest g =
      let 
        (* if not exception is raised when vertex does not exists *)
        fun filter_d n = case Graph.lookup_vertex g n of 
                           NONE => false | _ => true;
        val valid_dests = filter filter_d dest
        val poss_plugs = filter (is_pluggable th g s) valid_dests
        fun plug' d = Graph.do_plug_and_minimise s d g (* was Graph.plug_by_boundary s d g |> snd |> snd *)
        val newgs = map plug' poss_plugs
        (* other possibilities *)
        val newgs_ignore = plug th srcs dest g
      in  
        case newgs of [] => (case newgs_ignore of [] => [g] | _ => newgs_ignore)
                     | _ =>  (maps (plug th srcs valid_dests) newgs) @ newgs_ignore
      end;

 (* computes number of pluggings *)
 fun num_plugs src_g dest_g new_g =
    length (get_boundary_outputs src_g) 
  + length (get_boundary_outputs dest_g)
  - length (get_boundary_outputs new_g);

 (* combinators *)

 (* tensor *)
 fun graph_tensor th g1 g2 =
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

 fun tensor th g1 g2 = graph_tensor th g1 g2 |> snd;

 fun graph_compose th g1 g2 = 
   let 
    fun check_rnm rnm name = 
      case V.Rnm.lookup rnm name of
        NONE => name
      | SOME n => n;
    fun just_in_boundary (v,_,_) = v;
    fun just_out_boundary (_,_,v) = v;
    val ((rnv,rne),g) = graph_tensor th g1 g2
    val poss_srcs = get_boundary_outputs g1 |> map just_out_boundary
    val poss_dests = map ((check_rnm rnv) o just_in_boundary) (get_boundary_inputs g2)
    val gs' = plug th poss_srcs poss_dests g
   in
     map (fn g' => ((rnv,rne),g')) gs'
   end;

 (* then *)
 fun graph_then th g1 g2 = 
  let
    val gcomposeds = graph_compose th g1 g2
    (* fixme: only checks by length of input/output *)
    fun check_inp g = 
          length (get_boundary_outputs g1) = length (get_boundary_outputs g)
    fun check_outp g = 
          length (get_boundary_outputs g2) = length (get_boundary_outputs g)
    fun check (_,g) = check_inp g andalso check_outp g
  in
    filter check gcomposeds
  end
 
 fun compose th g1 g2 = 
  case graph_compose th g1 g2 of
    [] => raise compose_exp (g1,g2,"cannot compose") 
   | (x::xs) => (* fail if two are possible??, i.e. the two largest have the same number of plugs? *)
      fold (fn (_,g') => fn g => 
             if num_plugs g1 g2 g < num_plugs g1 g2 g' then g' else g)
           xs
           (snd x);
    
 fun theng th g1 g2 =
  case graph_then th g1 g2 of
    [] => raise compose_exp (g1,g2,"cannot then") 
   | (x::xs) => (snd x);

 (* to perform a single plug *)

 fun check_pluggable _ [] _ g = false
  |  check_pluggable _ _ [] g = false
  |  check_pluggable th (s::srcs) dest g =
      let 
        (* if not exception is raised when vertex does not exists *)
        fun filter_d n = case Graph.lookup_vertex g n of 
                           NONE => false | _ => true;
        val valid_dests = filter filter_d dest
        val can_plug_s = exists (is_pluggable th g s) valid_dests
      in
        if can_plug_s 
         then true
         else check_pluggable th srcs dest g
      end;

 (* performs a single plug - fails if there are many options *)
 fun single_plug (f,t) _ [] _ g = raise plug_exp(g,f,t,"no possible pluggings")
  |  single_plug (f,t) _ _ [] g = raise plug_exp (g,f,t,"no possible pluggings")
  |  single_plug (f,t) th (s::srcs) dest g =
      let 
        (* if not exception is raised when vertex does not exists *)
        fun filter_d n = case Graph.lookup_vertex g n of 
                           NONE => false | _ => true;
        val valid_dests = filter filter_d dest
        val poss_plugs = filter (is_pluggable th g s) valid_dests
      in  
        case poss_plugs of 
          [] => single_plug (f,t) th srcs dest g
        | [d] => if check_pluggable th srcs dest g
                  then raise plug_exp (g,f,t,"more than one possible pluggings")
                  else Graph.do_plug_and_minimise s d g (* was plug_by_boundary s d g |> snd |> snd *)
        | _ => raise plug_exp (g,f,t,"more than one possible pluggings")
      end;

 fun add_single_edge th from to graph = 
   let 
    val poss_srcs = get_output_boundary_of_rtechn graph from 
    val poss_dests = get_input_boundary_of_rtechn graph to
   in
     single_plug (from,to) th poss_srcs poss_dests graph
   end;

 (* randomly picks the one with most plugs... - should make it more deterministic *)
 fun plug_rtechns th from to graph = 
   let 
    val poss_srcs = get_output_boundary_of_rtechn graph from 
    val poss_dests = get_input_boundary_of_rtechn graph to
    val poss_plugs = plug th poss_srcs poss_dests graph
    fun num_new_plugs g = 
          length poss_srcs - length (get_output_boundary_of_rtechn g from);
   in  
      case poss_plugs of
       [] => graph
      | (x::xs) => (* fail if two are possible??, i.e. the two largest have the same number of plugs? *)
         fold (fn g' => fn g => 
             if num_new_plugs g < num_new_plugs g' then g' else g)
             xs
             x
   end;


  (* variant in different theories with the wire and not edge given *)
  fun valid_wiring' (thf,from) (tht,to) = 
      FWire_Ctxt.Theory.get_wire thf from <: FWire_Ctxt.Theory.get_wire tht to;

   (* move input between two graphs : to evaluate nested/critic without unpacking! *)
  
   (* copies the input of rtechn v at g_dest to input edges of g_dest  *)
   (* we should assume a 1-1 match, at least under subtyping *)
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


end; (* end struct *)

structure GraphComb : GRAPH_COMB  = GraphComb_DB 


