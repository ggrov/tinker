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

structure GraphComb_DB =
struct

  type graph = Strategy_Theory.Graph.T

  exception goalnode_exp of string * V.name;
  exception vertex_exp of string * V.name option;
  exception edge_exp of string * V.name option
  exception compose_exp of graph * graph * string
  exception plug_exp of graph * V.name * V.name * string;

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

(*
  fun is_goalnode_vertex (DB_VertexData.GoalNode _) = true
   |  is_goalnode_vertex _ = false;

  fun is_Strategy_vertex (DB_VertexData.StrategyNode _) = true
   |  is_Strategy_vertex _ = false;

  fun is_empty_goalnode_vertex (DB_VertexData.GoalNode (_,gs)) =
           StrIntName.NSet.is_empty gs
   |  is_empty_goalnode_vertex _ = false;

  fun is_goalnode g v = get_vdata g v 
                      |> is_goalnode_vertex
                      handle vertex_exp _ => false;

  fun is_Strategy g v = get_vdata g v 
                    |> is_Strategy_vertex
                    handle vertex_exp _ => false; 

  fun is_empty_goalnode g v = get_vdata g v |> is_empty_goalnode_vertex
                            handle vertex_exp _ => false;

  fun vertex_to_goalnode (DB_VertexData.GoalNode gnd) = SOME gnd
   |  vertex_to_goalnode _ = NONE;

  fun vertex_to_Strategy (DB_VertexData.StrategyNode rt) = SOME rt
   |  vertex_to_Strategy _ = NONE;

  fun v_to_goalnode g v =
    case vertex_to_goalnode (get_vdata g v) of
      NONE => raise vertex_exp ("not goalnode vertex",SOME v)
    | SOME gs => gs;

  fun v_to_Strategy g v =
    case vertex_to_Strategy (get_vdata g v) of
      NONE => raise vertex_exp ("not Strategy vertex",SOME v)
    | SOME gs => gs;

  fun get_Strategys_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_Strategy g)

  fun get_goalnodes_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_goalnode g)

 (* empty goalnodes *)
  fun empty_goalnode bwire = (bwire,StrIntName.NSet.empty);
  fun empty_goalnode_vertex bwire = Strategy_OVData.NVert (DB_VertexData.GoalNode (empty_goalnode bwire));
  val empty_default_goalnode = ("goal",StrIntName.NSet.empty);
  val empty_default_goalnode_vertex = Strategy_OVData.NVert (DB_VertexData.GoalNode empty_default_goalnode);
*)
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
(*
  fun lift_Strategy f     (Strategy_OVData.WVert)               = Strategy_OVData.WVert
   |  lift_Strategy f (Strategy_OVData.NVert (DB_VertexData.StrategyNode rt)) = Strategy_OVData.NVert (DB_VertexData.StrategyNode (f rt))
   |  lift_Strategy f      (Strategy_OVData.NVert v)             = Strategy_OVData.NVert v;

  fun lift_goalnode f     (Strategy_OVData.WVert)               = Strategy_OVData.WVert
   |  lift_goalnode f (Strategy_OVData.NVert (DB_VertexData.GoalNode l)) = Strategy_OVData.NVert (DB_VertexData.GoalNode (f l))
   |  lift_goalnode f      (Strategy_OVData.NVert v)             = Strategy_OVData.NVert v;
*)
  (* goalnodes  *)
(*
  fun update_goalnode_data gf = Graph.update_vertex_data (lift_goalnode gf);

  val set_goalnode_data = update_goalnode_data o K;
*)
  fun insert_and_get_vertex (e,g0) (name,node) =
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
  
(*
  fun insert_goalnode eg (n,gnd) = insert_vertex eg (n,DB_VertexData.GoalNode gnd);
*)
  (* graph projections *)



(*
  val get_input_types = 
    get_boundary_inputs 
    #> map (fn (_,(_,w),_) => w)
    #> StrName.NSet.of_list

  val get_output_types = 
    get_boundary_outputs 
    #> map (fn (_,(_,w),_) => w)
    #> StrName.NSet.of_list
*)

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

(*
  fun get_output_boundary_of_Strategy g v =
    if is_Strategy g v 
     then get_outputs_of_vertex g v
       |> filter (is_output_vertex g)
     else raise vertex_exp ("vertex not a reasoning technique",SOME v);

  fun get_input_boundary_of_Strategy g v =
    if is_Strategy g v 
     then get_inputs_of_vertex g v
       |> filter (is_input_vertex g)
     else raise vertex_exp ("vertex not a reasoning technique",SOME v);
*)
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

 local open Strategy_Theory.Graph in

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
   if graph_is_pluggable g v1 v2 (* Strategy_Theory.Graph.are_pluggable g v1 v2 *) 
    then(case (E.NSet.tryget_singleton (get_in_edges g v1), E.NSet.tryget_singleton (get_out_edges g v2)) of 
       (SOME s,SOME d) =>  DB_EdgeData.data_eq (edge_data g s,edge_data g d)
       | _ => false)
    else false;

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

(*
 fun add_single_edge th from to graph = 
   let 
    val poss_srcs = get_output_boundary_of_Strategy graph from 
    val poss_dests = get_input_boundary_of_Strategy graph to
   in
     single_plug (from,to) th poss_srcs poss_dests graph
   end;
*)

 (* randomly picks the one with most plugs... - should make it more deterministic *)
 fun plug_Strategys th from to graph = 
   let 
    val poss_srcs = get_output_boundary_of_Strategy graph from 
    val poss_dests = get_input_boundary_of_Strategy graph to
    val poss_plugs = plug th poss_srcs poss_dests graph
    fun num_new_plugs g = 
          length poss_srcs - length (get_output_boundary_of_Strategy g from);
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
  
   (* copies the input of Strategy v at g_dest to input edges of g_dest  *)
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



