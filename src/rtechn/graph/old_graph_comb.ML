signature GRAPH_COMB = 
sig

  type graph = RTechn_Theory.Graph.T

  exception goalnode_exp of string * V.name
  exception vertex_exp of string * V.name option
  exception edge_exp of string * V.name option

  val default_vertex_name : V.name (* was goalnode_name *)

  val is_goalnode :  graph -> V.name -> bool 
  val is_rtechn : graph -> V.name -> bool
  val is_empty_goalnode : graph -> V.name -> bool (* raises goalnode_exp *)
  val v_to_goalnode : graph -> V.name -> GoalNode.T (* raises node_ex *)
  val v_to_rtechn : graph -> V.name -> RTName.name (* raises node_ex *)

  (* get functions from type *)
  val get_rtechns_of_graph :  graph -> V.NSet.T
  val get_goalnodes_of_graph : graph -> V.NSet.T

  val empty_goalnode : BWire.name -> GoalNode.T
  val empty_goalnode_vertex : BWire.name ->  OVData.data

  val empty_default_goalnode : GoalNode.T
  val empty_default_goalnode_vertex : OVData.data

  val boundary_vertex : OVData.data

  val add_edge : V.name -> WireNode.T -> V.name -> graph -> graph

  val compose : bool (* true: inputs(g2) < output(g1) still allowed (i.e. boundary kept) *) 
                -> graph -> graph -> graph
  val tensor : graph -> graph -> graph

  val edge_src :  graph -> E.name -> V.name
  val edge_dest : graph -> E.name -> V.name
  val get_in_edges : graph -> V.name -> E.NSet.T
  val get_out_edges : graph -> V.name -> E.NSet.T

  val get_edge_wire :  graph -> E.name -> WireNode.T
  val update_edge_wire : (WireNode.T -> WireNode.T) -> E.name -> graph -> graph
  val update_goalnode_data : (GoalNode.T -> GoalNode.T) -> V.name -> graph -> graph  (* raises goalnode_exp *)
  val set_goalnode_data : GoalNode.T -> V.name -> graph -> graph  (* raises goalnode_exp *)
  val add_to_goalnode_data : GoalNode.T -> V.name -> graph -> graph  (* raises goalnode_exp *)

  val insert_goalnode : (E.name * graph) -> graph

  val get_boundary_inputs : graph -> (V.name * (E.name * EData.data) * V.name) list
  val get_boundary_outputs : graph -> (V.name * (E.name * EData.data) * V.name) list

  val get_input_types : graph -> WireNode.W.NSet.T
  val get_output_types : graph -> WireNode.W.NSet.T

  val is_vdata : graph -> V.name -> bool 
  val get_vdata : graph -> V.name -> RTData.data

  val add_goalnode_goalnode_edge : V.name -> V.name -> graph -> graph
  val add_goalnode_goalnode_edge_and_restrict_input : V.name -> V.name -> graph -> graph
  val add_single_edge : bool -> WireNode.T -> V.name -> V.name -> graph -> graph

  val change_edge_src : V.name -> E.name -> graph -> graph
  val copy_edge_src : V.name -> E.name -> graph -> graph
  val change_and_del_edge_src : V.name -> E.name -> graph -> graph
  val change_edge_dest : V.name -> E.name -> graph -> graph
  val copy_edge_dest : V.name -> E.name -> graph -> graph
  val change_and_del_edge_dest : V.name -> E.name -> graph -> graph

  val rename_conflicting_edges : graph -> graph -> graph 
  val rename_conflicting_vertices : graph -> graph -> graph 
  val find_eq_edges : E.NSet.T -> E.NSet.T -> graph -> E.NSet.T list
end;


structure GraphComb : GRAPH_COMB =
struct

  type graph = RTechn_Theory.Graph.T

  exception goalnode_exp of string * V.name;
  exception vertex_exp of string * V.name option;
  exception edge_exp of string * V.name option

  structure GT = RTechn_Theory;
  structure Graph = GT.Graph;

  fun is_vdata g v =
   let fun prj (OVData.IVert _) = true
        |  prj _ = false
    in
       Graph.get_vertex_data g v |> prj
    end;

  fun get_vdata g v =
   let fun prj (OVData.IVert vd) = vd
        |  prj _ = raise vertex_exp ("not internal vertex",SOME v)
    in
       Graph.get_vertex_data g v |> prj
    end;

  val default_vertex_name = V.mk "l";

  fun is_goalnode g v = get_vdata g v |> RTData.is_goalnode handle vertex_exp _ => false;
  fun is_rtechn g v = get_vdata g v |> RTData.is_rtechn handle vertex_exp _ => false;  
 
 (* handle and raise exception ?? *) 
  fun is_empty_goalnode g v = get_vdata g v |> RTData.is_empty_goalnode;

  fun v_to_goalnode g v = get_vdata g v 
                    |> RTData.data_to_goalnode

  fun v_to_rtechn g v = get_vdata g v 
                    |> RTData.data_to_rtechn

  fun get_rtechns_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_rtechn g)

  fun get_goalnodes_of_graph g =
    Graph.get_vnames g |> V.NSet.filter (is_goalnode g)

  val boundary_vertex = OVData.EVert;

  fun empty_goalnode bwire = GoalNode.empty_goalnode bwire
  fun empty_goalnode_vertex bwire = OVData.IVert (RTData.GoalNode (empty_goalnode bwire));

  val empty_default_goalnode = GoalNode.default_goalnode;
  val empty_default_goalnode_vertex = OVData.IVert (RTData.GoalNode empty_default_goalnode);

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

  fun get_edge_wire g e = Graph.get_edge g e |> fst |> snd

  val update_edge_wire = Graph.update_edge_data;
    
  fun lift_rtechn f     (OVData.EVert)               = OVData.EVert
   |  lift_rtechn f (OVData.IVert (RTData.RTechnNode rt)) = OVData.IVert (RTData.RTechnNode (f rt))
   |  lift_rtechn f      (OVData.IVert v)             = OVData.IVert v;

  fun lift_goalnode f     (OVData.EVert)               = OVData.EVert
   |  lift_goalnode f (OVData.IVert (RTData.GoalNode l)) = OVData.IVert (RTData.GoalNode (f l))
   |  lift_goalnode f      (OVData.IVert v)             = OVData.IVert v;

  fun update_goalnode_data gf = Graph.update_vertex_data (lift_goalnode gf);

  fun add_to_goalnode_data gs = Graph.update_vertex_data (lift_goalnode (GoalNode.merge gs));

  val set_goalnode_data = update_goalnode_data o K;

  fun map_rtechn rtf graph =
     V.NSet.fold
       (Graph.update_vertex_data (lift_rtechn rtf))
       (Graph.get_vnames graph)
       graph;

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
    #> WireNode.W.NSet.of_list

  val get_output_types = 
    get_boundary_outputs 
    #> map (fn (_,(_,w),_) => w)
    #> WireNode.W.NSet.of_list

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

 fun is_pluggable g v1 v2 =
   case RTechn_Theory.Graph.boundary_coherence g v1 v2 of (* coherence in graph sense *)
     NONE => false
   | SOME _ => (* data matches *)
      case (E.NSet.tryget_singleton (GraphComb.get_in_edges g v1),
            E.NSet.tryget_singleton (GraphComb.get_out_edges g v2)) of 
      (* fixme: can also define this purely in terms of matching edge data to generalise *)
       (SOME s,SOME d) => (Graph.get_edge_data g s) <: (Graph.get_edge_data g d)
      | _ => false;

 (* assuming srscs and dest are boundary should 
    produce all possible pluggings (since an is_pluggable 
    will fail if the dest has already been plugged) *)
 fun plug [] _ g = [g] (* no more to plug *)
  |  plug _ [] g = [g] (* no more to plug *)
  |  plug (s::srcs) dest g =
      let 
        val poss_plugs = filter (is_pluggable g s) dest
        fun plug' d = Graph.plug_by_boundary s d g |> snd |> snd
        val newgs = map plug' poss_plugs
      in 
        maps (plug srcs dest) newgs
      end;

 fun graph_compose g1 g2 = 
   let 
    fun check_rnm rnm name = 
      case V.Rnm.lookup rnm name of
        NONE => name
      | SOME n => n;
    fun just_name (v,_,_) = v
    val ((rnv,rne),g) = graph_tensor g1 g2
    val poss_srcs = get_boundary_outputs g1 |> map just_name
    val poss_dests = map ((check_rnm rnv) o just_name) (get_boundary_inputs g2)
    val gs' = plug poss_srcs poss_dests g
   in
     map (fn g' => ((rnv,rne),g')) gs'
   end;

(* then *)
fun graph_then g1 g2 = 
  let
    val gcomposeds = graph_compose g1 g2
    (* fixme: only checks by length of input/output *)
    fun check_inp g = 
          length (get_boundary_outputs g1) = length (get_boundary_outputs g)
    fun check_outp g = 
          length (get_boundary_outputs g2) = length (get_boundary_outputs g)
    fun check (_,g) = check_inp g andalso check_outp g
  in
    filter check gcomposeds
  end

 fun num_plugs src_g dest_g new_g =
    length (get_boundary_outputs src_g) 
  + length (get_boundary_outputs dest_g)
  - length (get_boundary_outputs new_g);
 
 exception compose_exp of Graph.T * Graph.T * string

 fun graph_tensor' g1 g2 = graph_tensor g1 g2 |> snd
 fun graph_compose' g1 g2 = 
  case graph_compose g1 g2 of
    [] => raise compose_exp (g1,g2,"cannot compose") 
   | (x::xs) =>
      fold (fn (_,g') => fn g => 
             if num_plugs g1 g2 g < num_plugs g1 g2 g' then g' else g)
           xs
           (snd x);
    
 fun graph_then' g1 g2 =
  case graph_then g1 g2 of
    [] => raise compose_exp (g1,g2,"cannot then") 
   | (x::xs) => (snd x);
 

(* not sure about this *)

  fun insert_and_get_goalnode (e,g0) =
    let val (main_wire,_) = edge_data g0 e
        val (l,g1) = Graph.add_named_vertex default_vertex_name (empty_goalnode_vertex main_wire) g0
        val from = edge_src g1 e
        val to = edge_dest g1 e
        val edata = edge_data g1 e
        val g2 = g1 |> Graph.delete_edge e 
                    |> Graph.add_named_edge e (Graph.Directed,edata) from l
                    |> snd (* fixme: maybe write a combinator to do this? *)
                    |> Graph.add_named_edge e (Graph.Directed,edata) l to
                    |> snd
    in
        (l,g2)
    end;

  val insert_goalnode  = snd o insert_and_get_goalnode;

  fun insert_and_get_vertex (e,g0) (name,node) =
    let val (l,g1) = Graph.add_named_vertex name (OVData.IVert node) g0
        val from = edge_src g1 e
        val to = edge_dest g1 e
        val edata = edge_data g1 e
        val g2 = g1 |> Graph.delete_edge e 
                    |> Graph.add_named_edge e (Graph.Directed,edata) from l
                    |> snd (* fixme: maybe write a combinator to do this? *)
                    |> Graph.add_named_edge e (Graph.Directed,edata) l to
                    |> snd
    in
        (l,g2)
    end;

  val insert_vertex  = snd oo insert_and_get_vertex;

   (* assumes that g2 will be renamed first *)
   (* wire name shouldn't really matter since it is the actual wire that 
      is used for matching !! *)
   fun get_conflicting_edge_names g1 g2 = 
     let val g1_edges = Graph.get_edges g1 |> E.NTab.get_nameset
         val g2_edges = Graph.get_edges g2 |> E.NTab.get_nameset
     in
       (E.NSet.filter (E.NSet.contains g1_edges) g2_edges, (* conflicting - could just use set subtraction! *)
        E.NSet.union_merge g1_edges g2_edges) (* all *)
     end;

   fun get_conflicting_vertex_names g1 g2 = 
     let val g1_vertices = Graph.get_vertices g1 |> V.NTab.get_nameset
         val g2_vertices = Graph.get_vertices g2 |> V.NTab.get_nameset
     in
       (V.NSet.filter (V.NSet.contains g1_vertices) g2_vertices, (* conflicting *)
        V.NSet.union_merge g1_vertices g2_vertices)
     end;

   (* returns updated g2: renames edges in g2 so that g1 and g2 have disjoint edge names *)
   fun rename_conflicting_edges g1 g2 =
     let val (conf,init_all) = get_conflicting_edge_names g1 g2
         fun upd ename (all_enames,g) = (* refactor to use combinators *)
             let
                 val (ename',all_enames') = E.NSet.add_new ename all_enames 
             in 
                (all_enames',Graph.rename_ename ename ename' g)
             end 
      in 
         E.NSet.fold upd conf (init_all,g2)
        |> snd (* only returns graph (set is needed since same "fresh" name may be generated twice) *)
      end;

   (* returns updated g2: renames vertices in g2 so that g1 and g2 have disjoint vertex names *)
   fun rename_conflicting_vertices g1 g2 =
     let val (conf,init_all) = get_conflicting_vertex_names g1 g2
         fun upd vname (all_vnames,g) = (* refactor to use combinators *)
             let
                 val (vname',all_vnames') = V.NSet.add_new vname all_vnames 
             in 
                (all_vnames',Graph.rename_vname vname vname' g)
             end 
      in 
         V.NSet.fold upd conf (init_all,g2) 
        |> snd (* only returns graph (set is needed since same "fresh" name may be generated twice) *)
      end;

  (* assumes just one *)
  fun get_output_boundary_and_edge g v = 
    let
      fun find [] = raise vertex_exp ("no such boundary", SOME v)
       |  find ((v',(e,_),bv)::xs) = if V.name_eq (v,v') then (e,bv) else find xs
    in 
      find (get_boundary_outputs g)
    end;

  fun get_input_boundary_and_edge g v = 
    let
      fun find [] = raise vertex_exp ("no such boundary", SOME v)
       |  find ((bv,(e,_),v')::xs) = if V.name_eq (v,v') then (e,bv) else find xs
    in 
      find (get_boundary_inputs g)
    end;

  fun is_output_vertex g v =
   g |> get_boundary_outputs
     |> List.exists (fn (v',_,_) => V.name_eq (v',v));

  fun is_input_vertex g v =
   g |> get_boundary_inputs
     |> List.exists (fn (_,_,v') => V.name_eq (v,v'));

  fun get_inputs_of_vertex g v =
    Graph.in_enames g v 
     |> E.NSet.list_of
     |> map (edge_src g);

  fun get_outputs_of_vertex g v =
    Graph.out_enames g v 
     |> E.NSet.list_of
     |> map (edge_dest g);

  fun get_input_goalnodes_of_rtechn g v =
    if is_rtechn g v 
     then get_inputs_of_vertex g v
     else raise vertex_exp ("vertex not a reasoning technique",SOME v)

  fun get_output_goalnodes_of_rtechn g v =
    if is_rtechn g v 
     then get_outputs_of_vertex g v
     else raise vertex_exp ("vertex not a reasoning technique",SOME v)

  fun get_output_boundary_of_rtechn g v =
     get_output_goalnodes_of_rtechn g v 
     |> filter (is_output_vertex g);

  fun get_input_boundary_of_rtechn g v =
     get_input_goalnodes_of_rtechn g v 
     |> filter (is_input_vertex g);

  fun remove_from_input_boundary v g =
    if is_input_vertex g v 
     then let 
             val (e,bv) = get_input_boundary_and_edge g v
          in
            g |> Graph.delete_edge e 
              |> Graph.delete_vertex bv
          end
     else raise vertex_exp ("no such boundary", SOME v);
 
  fun try_remove_from_input_boundary v g = remove_from_input_boundary v g handle vertex_exp _ => g;  

  fun remove_from_output_boundary v g =
    if is_output_vertex g v 
     then let 
             val (e,bv) = get_output_boundary_and_edge g v
          in
            g |> Graph.delete_edge e 
              |> Graph.delete_vertex bv
          end
     else raise vertex_exp ("no such boundary", SOME v);

  fun try_remove_from_output_boundary v g = remove_from_output_boundary v g handle vertex_exp _ => g;

  fun prj_edge error_empty error_many eset =
    if E.NSet.is_empty eset
      then raise edge_exp error_empty
    else if not (E.NSet.is_singleton eset)
      then raise edge_exp error_many
       else case E.NSet.get_min eset of 
               NONE   => raise edge_exp ("cannot get single (min) element",NONE) (* shouldn't happen *)
            | (SOME e) => e

  fun prj_vertex error_empty error_many vset =
    if V.NSet.is_empty vset
      then raise vertex_exp error_empty
    else if not (V.NSet.is_singleton vset)
      then raise vertex_exp error_many
       else case V.NSet.get_min vset of 
               NONE   => raise vertex_exp ("cannot get single (min) element",NONE) (* shouldn't happen *)
            | (SOME v) => v

  (* only works if a single wire *)
  fun get_goalnode_src graph v = 
    if is_goalnode graph v 
     then Graph.in_enames graph v 
         |> prj_edge ("no inputs of goalnode",SOME v) ("many inputs of goalnode",SOME v)
     else raise goalnode_exp ("not a goalnode",v);

  (* only works if a single wire *)
  fun get_goalnode_dest graph v = 
    if is_goalnode graph v 
     then Graph.out_enames graph v
          |> prj_edge ("no inputs of goalnode",SOME v) ("many inputs of goalnode",SOME v)
     else raise goalnode_exp ("not a goalnode",v);

  fun add_goalnode_goalnode_edge from to graph =
    if not (is_goalnode graph from) 
     then raise goalnode_exp ("source vertex not a goalnode",from)
    else if not (is_goalnode graph to)
     then raise goalnode_exp ("target vertex not a goalnode",to)
    else if not (is_output_vertex graph from)
     then raise goalnode_exp ("from goalnode not a valid output",from) 
    else if not (is_input_vertex graph to)
     then raise goalnode_exp ("to goalnode not a valid input",to) 
    else
     let
       val inputs = get_in_edges graph from 
       val from_d = v_to_goalnode graph from
       fun wire_input input = Graph.get_edge_data graph input
       fun from_src input = edge_src graph input
       fun move_edge input graph = 
          graph |> Graph.delete_edge input
                |> Graph.add_named_edge input (Graph.Directed,wire_input input) (from_src input) to
                |> snd
     in 
       graph |> remove_from_output_boundary from
             |> E.NSet.fold move_edge inputs (* move all input edges *)
             |> Graph.delete_vertex from
             |> add_to_goalnode_data from_d to
     end;
 
  fun add_goalnode_goalnode_edge_and_restrict_input from to graph =
    add_goalnode_goalnode_edge from to graph
   |> remove_from_input_boundary to;

  (* fails if more than matches *)
  (* merge_input: does not remove input from boundary *)
  fun add_single_edge merge_input wire from to graph =
    let
      val inp_wire = get_goalnode_src graph #> Graph.get_edge_data graph
      val out_wire = get_goalnode_dest graph #> Graph.get_edge_data graph
      val to_goalnodes = get_input_boundary_of_rtechn graph to
                     |> filter (fn v => wire <: (out_wire v)) (* dest is more general than wire *)
                     |> V.NSet.of_list (* fixme: shouldn't need to do this conversion *)
      val from_goalnodes = get_output_boundary_of_rtechn graph from
                       |> filter (fn v => (inp_wire v) <: wire) (* wire more general than source *) 
                       |> V.NSet.of_list (* fixme: shouldn't need to do this conversion *)
      val to_goalnode = prj_vertex ("no matching destinations",SOME to) ("more than one matching destinations",SOME to) to_goalnodes
      val from_goalnode = prj_vertex ("no matching sources",SOME from) ("more than one matching sources",SOME from) from_goalnodes
    in
      if merge_input
        then add_goalnode_goalnode_edge from_goalnode to_goalnode graph
        else add_goalnode_goalnode_edge_and_restrict_input from_goalnode to_goalnode graph
    end;


  (* FIXME: goalnode should be from output buffers to input buffers?? *)
  (* note also inserts a goalnode *)
  fun add_edge from_name (fwire as (wire,_)) to_name graph =
     Graph.add_named_edge (E.mk (BWire.string_of wire)) (Graph.Directed,fwire) from_name to_name graph
     |> insert_goalnode;

  (* issue is what to do with buffer !!! *)
  fun change_edge_src from edge g = 
    let val data = get_edge_wire g edge
        val dest = edge_dest g edge
    in
      g |> Graph.delete_edge edge
        |> Graph.add_named_edge edge (Graph.Directed,data) from dest
        |> snd
    end;

  fun copy_edge_src from edge g = 
    let val data = get_edge_wire g edge
        val dest = edge_dest g edge
    in
      g |> Graph.add_named_edge edge (Graph.Directed,data) from dest
        |> snd
    end;

  fun change_and_del_edge_src from edge g = 
   let val src = edge_src g edge
   in 
     g |> change_edge_src from edge
       |> Graph.delete_vertex src
   end;

  (* issue is what to do with buffer !!! *)
  fun change_edge_dest to edge g = 
    let val data = get_edge_wire g edge
        val src = edge_src g edge
    in
      g |> Graph.delete_edge edge
        |> Graph.add_named_edge edge (Graph.Directed,data) src to
        |> snd
    end;

  fun copy_edge_dest to edge g = 
    let val data = get_edge_wire g edge
        val src = edge_src g edge
    in
      g |> Graph.add_named_edge edge (Graph.Directed,data) src to
        |> snd
    end;

  fun change_and_del_edge_dest to edge g = 
   let val dest = edge_dest g edge
   in 
     g |> change_edge_dest to edge
       |> Graph.delete_vertex dest
   end;

  fun is_equal_wires g (e1,e2)= 
    WireNode.WInfo.eq (get_edge_wire g e1,get_edge_wire g e2);

  (* fixm: move to wire?? *)
  (* list of same edges *)
  (* needs to be in both e1 and e2 so could be either *)
  fun find_eq_edge g eset e res_list =
    let fun ins_if_new el ss = if E.NSet.contains ss el then ss else E.NSet.ins_fresh el ss
        val res =  E.NSet.fold 
                     (fn e' => fn res => if is_equal_wires g (e,e') then ins_if_new e' res else res)
                     eset
                     E.NSet.empty
    in 
      if E.NSet.is_empty res then res_list else res_list @ [ins_if_new e res]
    end;
     
  (* list of eset where each edge of an eset has same edge *)
  (* should really be generalised to matching !! *)
  fun find_eq_edges eset1 eset2 g = 
    E.NSet.fold 
      (find_eq_edge g eset2)
      eset1
      [];  


(* 
 - should really 
     - rename
     - remove input boundary of g1
     - remove output boundary of g2
     - plug
     - add back input/output boundary (need to check with renaming!!)

*)

  fun compose flag g1 g2 = 
    let val g2' = g2 |> rename_conflicting_vertices g1 
                     |> rename_conflicting_edges g1
        val g1_outs = get_boundary_outputs g1
                   |> map (fn (l,(_,w),_) => (l,w))
        val g2_ins  = get_boundary_inputs g2'
                   |> map (fn (_,(_,w),l) => (w,l))
        fun match ws (wd,ld) res =
             if wd <: ws then ld::res else res
        (* returns [s,[d1,d2]] *)
        fun match_with_all (ls,w) res = 
           case fold (match w) g2_ins [] of
               [] => res
              | r => (ls,r)::res
        val all_matches = fold match_with_all g1_outs []
        fun plug (s,[]) g = raise goalnode_exp ("plugging to no-existent dest",s) (* should never happen *)
         |  plug (s,[d]) g = (* if flag then add_goalnode_goalnode_edge_and_restrict_input s d g 
                                else *) add_goalnode_goalnode_edge s d g
         |  plug (s,d::ds) g = 
              g |> E.NSet.fold (copy_edge_dest d) (get_in_edges g s)
                |> plug (s,ds)
        (* removes: try since it may already been removed -- or turn into set?? *)
        fun restrict_input g = all_matches
              |> maps (fn (_,ds) => ds)
              |> V.NSet.of_list
              |> (fn vs => V.NSet.fold remove_from_input_boundary vs g)
    in        
      g2' |> Graph.merge_by_vertices g1
          |> fold plug all_matches
          |> (fn g => if flag then (restrict_input g) else g)
    end;

(*
 Using renaming lib:

 val v_rnm = V.Rnm.mk V.NSet.empty (G.get_vnames g1) V.NTab.empty;
 val (rnm, g2') = G.VertexCRnm.rename v_rnm g2;
 val new_g = G.merge_by_vertices g1 g2'

 FIXME: would boundary be preserved?
 followed by combining those that are equaivalent!! (??)

*)

  fun tensor g1 g2 =
   let val g2' = g2 
               |> rename_conflicting_vertices g1 
               |> rename_conflicting_edges g1
       val g1_ins = get_boundary_inputs g1 
                  |> map (fn (_,(e,_),_) => e)
                  |> E.NSet.of_list
       val g2_ins = get_boundary_inputs g2'
                  |> map (fn (_,(e,_),_) => e)
                  |> E.NSet.of_list
       val g1_outs = get_boundary_outputs g1 
                  |> map (fn (_,(e,_),_) => e)
                  |> E.NSet.of_list
       val g2_outs = get_boundary_outputs g2'
                  |> map (fn (_,(e,_),_) => e)
                  |> E.NSet.of_list
    in
      Graph.merge_by_vertices g1 g2'
    end;



  (* replaces all boundary nodes with an empty goalnode *)
  
(* 
   val replace_with_goalnode = Graph.update_vertex_data (K (OVData.IVert RTData.empty_goalnode));
   fun close_graph g = V.NSet.fold replace_with_goalnode (Graph.get_boundary g) g;
*)

   (* move input between two graphs : to evaluate nested/critic without unpacking! *)
  
   (* copies the input of rtechn v at g_dest to input edges of g_dest  *)
   (* we should assume a 1-1 match, at least under subtyping *)
   fun copy_input (v_src,g_src) g_dest = 
     let 
        val in_edges = Graph.in_enames g_src v_src
        val inputs = get_boundary_inputs g_dest (* (V.name * (E.name * EData.data) * V.name) list *)
        fun match_with w = filter (fn (_,(_,wd),_) => w <: wd) inputs (* dest must be more general *)
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

   fun copy_output g_src (v_dest,g_dest) = 
     let 
        val out_edges = Graph.out_enames g_dest v_dest
        val outputs = get_boundary_outputs g_src
                    |> filter (fn (v,(_,_),_) => is_goalnode g_src v)
                    |> map (fn (v,(_,w),_) => (v,get_vdata g_src v,w))
        (* not sure which way to do this matching ?? *)
        fun match_with w = E.NSet.filter (fn e => w <: Graph.get_edge_data g_dest e) out_edges 
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


