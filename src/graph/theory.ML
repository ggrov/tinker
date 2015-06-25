signature PS_THEORY_SHARING = 
sig
  structure Data : PSGRAPH_DATA_SHARING
end

signature PS_THEORY = 
sig
  structure Data : PSGRAPH_DATA
  structure GoalTyp : BASIC_GOALTYPE
  structure Theory : GRAPHICAL_THEORY
  structure PSDataIO : GRAPH_COMPONENT_DATA_IO
  include GRAPHICAL_THEORY
  structure Graph_Utils : 
  sig 
    val add_outs : E.name list -> Graph.nvdata list -> Graph.T -> Graph.T 
    val all_gnodes : Graph.T -> V.name list
    val all_tactics : Graph.T -> V.name list 
    val del_gnode : V.name -> Graph.T -> Graph.T
    val edge_data : Graph.T -> E.name -> Graph.edata 
    val edge_dest : Graph.T -> E.name -> V.name
    val edge_src : Graph.T -> E.name -> V.name 
    val get_vertex_list : Graph.T -> V.NSet.name list
    val gnode_of : Graph.T -> V.name -> GoalTyp.gnode
    val goaltype_of : Graph.T -> E.name -> GoalTyp.T
    val in_edges : Graph.T -> V.name -> E.NSet.name list
    val input_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
    val insert_node_on_edge : Graph.nvdata -> E.name -> Graph.T -> E.name * E.name * Graph.T
    val is_gnode : Graph.T -> V.name -> bool 
    val is_gtyp : Graph.T -> E.name -> bool
    val is_hgragh_with_graph_name : Graph.T -> string -> V.name -> bool
    val is_tactic : Graph.T -> V.name -> bool
    val lookup_gnode : Graph.T -> V.name -> GoalTyp.gnode option 
    val lookup_hgragh_by_graph_name : Graph.T -> string -> V.name
    val lookup_ivertex_data : Graph.T -> V.name -> Graph.nvdata option
    val match_lhs : Graph.T -> Graph.T -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val matched_lhs : Graph.T -> V.name -> (Graph.subst * (Graph.subst * Graph.T)) Seq.seq
    val mk_binput : Graph.edata -> V.name -> Graph.T -> Graph.T 
    val mk_boutput : Graph.edata -> V.name -> Graph.T -> Graph.T
    val mk_gnode : GoalTyp.gnode -> Data.nvdata 
    val mk_lhs : Graph.T -> V.name -> Graph.T list
    val out_edges : Graph.T -> V.name -> E.NSet.name list
    val output_boundary : Graph.T -> (V.name * (E.name * Graph.edata) * V.name) list
    val rewrite : Rule.T -> Graph.T -> Graph.T list 
    val rewrite_lazy : Rule.T -> Graph.T -> Graph.T Seq.seq
    val symmetric_rule : Rule.T -> Rule.T
    val vertex_data : Graph.T -> V.name -> Graph.nvdata 
    val is_env_tactic_name : string -> bool
    val is_env_tactic : Graph.T -> V.name -> bool
    val parse_env_var_name : string -> string option
  end

  sharing type Graph.T = Theory.Graph.T
  sharing type Graph.nvdata = Data.nvdata
  sharing type Graph.edata = Data.edata
  sharing type PSDataIO.nvdata = Data.nvdata
  sharing type PSDataIO.edata = Data.edata
  sharing type Theory.Graph.Sharing.nvdata = Data.nvdata
  sharing type Theory.Graph.Sharing.edata = Data.edata
  sharing GoalTyp.BasicSharing = Data.Sharing.GoalTyp

  structure Sharing : PS_THEORY_SHARING
    sharing Sharing.Data = Data.Sharing


end (* signature *)

functor PSGraph_TheoryFun (structure GoalTyp : BASIC_GOALTYPE
                           structure  Data : PSGRAPH_DATA
                           sharing GoalTyp.BasicSharing = Data.Sharing.GoalTyp ) : PS_THEORY=
struct
  structure GoalTyp = GoalTyp;

  (* may need some sharing stuff here *)
  structure Data = Data (*PSGraphDataFun(GoalTyp);*);
  structure PSDataIO = PSGraphIOFun(structure Data = Data);


  structure Theory = GraphicalTheory(
    structure Data = Data
    structure DataIO = PSDataIO
  );
  open Theory;

 structure Graph_Utils =
  struct local open LoggingHandler in
    (* actual rewriting *)
    fun rewrite_lazy rule graph = 
      let 
        val graph' = Graph.normalise graph;
        val matches = Theory.Rewriter.find_matches rule graph';
        fun rewr match = 
          Theory.Rewriter.rewrite_at rule match
          |> snd
      in
        Seq.map rewr matches
      end;

    val rewrite = Seq.list_of oo rewrite_lazy;

  (* simplify ? *)
  fun input_boundary g = 
    let val bvertexes = Graph.get_inputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(bv,(e,Graph.get_edge_data g e),Graph.get_edge_target g e)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

  fun output_boundary g = 
    let val bvertexes = Graph.get_outputs g (* Vertex.NSet.T *)
        fun dest_name bv e =(Graph.get_edge_source g e,(e,Graph.get_edge_data g e),bv)
        fun mk_pairs v = Graph.get_out_edges g v 
                  |> E.NSet.list_of
                  |> map (fn e => dest_name v e)
    in  
      V.NSet.fold
        (fn v => fn xs => xs @ (mk_pairs v))
        bvertexes
        []
    end;

    fun edge_dest g e = Graph.get_edge_target g e;
    fun edge_src g e = Graph.get_edge_source g e;
    fun edge_data g e = Graph.get_edge_data g e;

   (* checks data *)
    fun lookup_ivertex_data g v = 
      case Graph.get_vertex_data g v of 
          (Graph.NVert nv) => SOME nv
        | _ => NONE

    fun lookup_ivertex_data g v = 
      case Graph.get_vertex_data g v of 
          (Graph.NVert nv) => SOME nv
        | _ => NONE

   val vertex_data = the oo lookup_ivertex_data;

   fun out_edges graph v = 
      Graph.get_out_edges graph v 
      |> E.NSet.list_of;

   fun in_edges graph v = 
      Graph.get_in_edges graph v 
      |> E.NSet.list_of;

    fun insert_node_on_edge node edge graph0 =
      let val (l,graph') = Graph.add_vertex (Graph.NVert node) graph0
          val from' = edge_src graph' edge
          val to' = edge_dest graph' edge
          val edata = edge_data graph' edge
          val graph' = Graph.delete_edge edge graph'
          val (src, graph') = Graph.add_edge (Directed,edata) from' l graph'
          val (dest, graph') = Graph.add_edge (Directed,edata) l to' graph'
      in
        (src,dest,graph')
      end;

   (* assumes: 1/1 - so just replace by wire node *)
   fun del_gnode gnode g = Graph.update_vertex_data (K Theory.Graph.WVert) gnode g |> Theory.Graph.minimise;

   fun mk_binput edata dest graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) n dest g);

   fun mk_boutput edata source graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) source n g);

   fun is_gtyp graph e = 
     case edge_data graph e of (Data.GT _) => true | _ => false;

   fun is_tactic graph v = 
   case lookup_ivertex_data graph v of 
       SOME (Data.T_Atomic _) => true
     | SOME (Data.T_Graph _) => true
     | SOME Data.T_Identity => true
     | _ => false; 

   fun is_hgragh_with_graph_name graph n v = 
     case lookup_ivertex_data graph v of 
       SOME (Data.T_Graph name) => n = name
       | _ => false; 

   fun is_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (Data.G _) => true
       | _ => false; 

   fun lookup_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (Data.G gn) => SOME gn
       | _ => NONE; 

   fun goaltype_of graph e = 
     case edge_data graph e of (Data.GT g) => g   
     |  _ => (logging "GRAPH" ("Unknown goaltype type in edge" ^ (E.string_of_name e)); raise tinker_fail)

   fun gnode_of graph v = 
     case vertex_data graph v of (Data.G gn) => gn
     | _ => (logging "GRAPH" ("This is not a goal node" ^ (V.string_of_name v)); raise tinker_fail) 

   fun mk_gnode gnode = Data.G gnode;

   fun get_vertex_list graph =  
     Graph.get_vertices graph
     |> V.NSet.list_of

   fun all_tactics graph = 
     get_vertex_list graph
     |> filter (is_tactic graph);

   fun all_gnodes graph = 
     get_vertex_list graph
     |> filter (is_gnode graph);
(*
   fun all_hgraghs graph =  
     Graph.get_vertices graph
     |> filter (is_hgragh graph);
*)
   fun lookup_hgragh_by_graph_name graph graph_name =  
     get_vertex_list graph
     |> filter (is_hgragh_with_graph_name graph graph_name)
     |> (fn x => (case x of 
                   [] => 
                   	(logging "GRAPH" ("Fail to find hgraph by name:" ^ graph_name); 
                   	raise tinker_fail) 
                   
                 | [h] => h
                 | _ => 
                 	(logging "GRAPH" ("ERR: fail to find hgraph by name, more than one result are returned: " ^ graph_name); 
                 	raise tinker_fail)))
 
   (* FIXME: makes one for each input - can be generalised by vars on the edges  instead - then we only need on lhs per rule  *)
   fun mk_lhs graph v =
     let 
      val ins = Graph.get_in_edges graph v  
      val outs = Graph.get_out_edges graph v
      val gnode = Graph.NVert (Data.G_Var "g")
      val (v_rt,g) = Graph.empty
                   |> Graph.add_vertex (Graph.get_vertex_data graph v)
      (* adding goalnode variable *)
      val (v_gvar,g) = Graph.add_vertex gnode g 
      (* one lhs for each input node *)
      fun mk_lhs' inp = g
          |> Graph.add_edge_anon (Directed,Data.GT (goaltype_of graph inp)) v_gvar v_rt
          |> mk_binput (Data.GT (goaltype_of graph inp)) v_gvar
          |> E.NSet.fold (fn outp => mk_boutput (Data.GT (goaltype_of graph outp)) v_rt) outs
          |> E.NSet.fold (fn o_inp => mk_binput (Data.GT (goaltype_of graph o_inp)) v_rt) 
                         (E.NSet.delete' inp ins) 
     in 
       map mk_lhs' (E.NSet.list_of ins)    (* one match per input *)
     end;

   (* Should be one tactic and one graph *)
   fun match_lhs graph lhs =
     Theory.Rewriter.find_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
      |> Seq.map (fn m => (Theory.Match.get_subst m, Graph.apply_data_subst (Theory.Match.get_subst m) lhs));
        
   fun matched_lhs graph v = Seq.maps (match_lhs graph) (mk_lhs graph v |> Seq.of_list)

   (* vertex list -> partition -> graph -> graph *)
   fun add_outs [] [] graph = graph
    |  add_outs  (i::is) (p::ps) graph = 
       add_outs is ps (#3 (insert_node_on_edge p i graph));

   fun symmetric_rule rule = Theory.Rule.mk (Theory.Rule.get_rhs rule,Theory.Rule.get_lhs rule);

(* environment tactics and variables *)
  fun is_env_tactic_name name = 
  let
    fun is_env_tactic_name0 name = 
    let val _ =  Symbol.explode name |> Scan.this_string "ENV_" in
    true end;
  in
    Scan.catch (is_env_tactic_name0) name
    handle _ => false
  end

 (* is a tactic node and also follows the name convension that has a prefix of ENV *)
  fun is_env_tactic g v = 
    let
      fun gey_tactic_node_name graph vgraph = 
        case lookup_ivertex_data graph vgraph of 
           SOME (Data.T_Atomic n ) => n
           | _ => raise tinker_fail (*"This is not a tatic node"*) (* no need to logging this, as it won't happen *)
    in
      is_tactic g v andalso is_env_tactic_name (gey_tactic_node_name g v)
    end

(* check the format is "?_" *)
  fun parse_env_var_name str = 
  let
    fun get_env_arg_name0 str = 
      str |> Symbol.explode 
      |> $$ "?"
      |> snd
      |> implode
      |> SOME;
  in
    Scan.catch (get_env_arg_name0) str
    handle Fail _ => NONE
  end
  end (* end of local open *)
  end (* structure Util *)

  structure Sharing = 
  struct
    structure Data = Data.Sharing
  end
end


