signature EVAL_GRAPH =
sig
  structure GoalTyp : BASIC_GOALTYPE
  structure Prover : PROVER
end

functor EvalGraphFun(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Prover = EData.PSGraph.Theory.Data.GoalTyp.Prover;
  structure Theory = EData.PSGraph.Theory;
  structure Graph = Theory.Graph;
  structure GData = EData.PSGraph.Theory.Data;

  (* move into separate/different file? *) 
  structure Util =
  struct
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
    val del_gnode = Graph.update_vertex_data (K Graph.WVert);

   fun mk_binput edata dest graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) n dest g);

   fun mk_boutput edata source graph =
     graph |> Graph.add_vertex Graph.WVert
           |> (fn (n,g) => Graph.add_edge_anon (Directed, edata) source n g);

   (* checks type *)
   fun is_gtyp graph e = 
     case edge_data graph e of (GData.GT _) => true | _ => false;
   fun is_tactic graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.T_Atomic _) => true
       | SOME (GData.T_Graph _) => true
       | SOME GData.T_Identity => true
       | _ => false; 
   fun is_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.G _) => true
       | _ => false; 


   (* lookup node *)
   (* fun lookup_rtechn graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.RT rt) => SOME rt
       | _ => NONE; *)
   fun lookup_gnode graph v = 
     case lookup_ivertex_data graph v of 
         SOME (GData.G gn) => SOME gn
       | _ => NONE; 

   (* projects goal types - exception if not existing *)
   fun goaltype_of graph e = 
     case edge_data graph e of (GData.GT g) => g   (* |  _ => raise error *);
(*
   fun rtechn_of graph v = 
     case vertex_data graph v of (GData.RT rt) => rt; 
*)
   fun gnode_of graph v = 
     case vertex_data graph v of (GData.G gn) => gn
(*
   fun single_gnode_of graph v = 
     case vertex_data graph v of (GData.GN (GData.GN_Node gnode)) => gnode;
*)

   fun mk_gnode gnode = GData.G gnode;


   fun get_vertex_list graph =  
     Graph.get_vertices graph
     |> V.NSet.list_of

   (* projects *)
   fun all_tactics graph = 
     get_vertex_list graph
     |> filter (is_tactic graph);

   fun all_gnodes graph = 
     get_vertex_list graph
     |> filter (is_gnode graph);

(*
   fun prj_single_gnodes (GData.GN_Node gn) = [gn]
    |  prj_single_gnodes (GData.GN_Pair (g1,g2)) =
         prj_single_gnodes g1 @ prj_single_gnodes g2
    |  prj_single_gnodes _ = []

   fun all_single_gnodes graph = 
     all_gnodes graph
     |> map (gnode_of graph)
     |> maps prj_single_gnodes;
*)

  end (* structure Util *)
 
  (* FIXME: makes one for each input - can be generalised by vars on the edges
     instead - then we only need on lhs per rule  *)
  fun mk_lhs graph v =
    let 
     val ins = Graph.get_in_edges graph v  
     val outs = Graph.get_out_edges graph v
     val gtyp = Util.goaltype_of
     val gnode = Graph.NVert (GData.G_Var "g")
     (* val tactic  = Util.tactic_of graph v *)
     (* graph with rtechn *)
     val (v_rt,g) = Graph.empty
               |> Graph.add_vertex (Graph.get_vertex_data graph v)
     (* adding goalnode variable *)
     val (v_gvar,g) = Graph.add_vertex gnode g 
     (* one lhs for each input node *)
     fun mk_lhs' inp = g
         |> Graph.add_edge_anon (Directed,GData.GT (gtyp graph inp)) v_gvar v_rt
         |> Util.mk_binput (GData.GT (gtyp graph inp)) v_gvar
         |> E.NSet.fold (fn outp => Util.mk_boutput (GData.GT (gtyp graph outp)) v_rt) outs
         |> E.NSet.fold (fn o_inp => Util.mk_binput (GData.GT (gtyp graph o_inp)) v_rt) 
                        (E.NSet.delete' inp ins) 
    in 
     map mk_lhs' (E.NSet.list_of ins)      (* one match per input *)
   end;

  (* Should be one rtechn and one graph *)
  fun match_lhs graph lhs =
     Theory.Rewriter.find_matches
           (Theory.Rule.mk(lhs,lhs)) (* make a dummy rule *)
           graph
     |> Seq.map (fn m => (Theory.Match.get_subst m, Graph.apply_data_subst (Theory.Match.get_subst m) lhs));
        
  fun matched_lhs graph v = Seq.maps (match_lhs graph) (mk_lhs graph v |> Seq.of_list)

 (* vertex list -> partition -> graph -> graph *)
 fun add_outs [] [] graph = graph
  |  add_outs  (i::is) (p::ps) graph = 
       add_outs is ps (#3 (Util.insert_node_on_edge p i graph));

  (* RULES FOR REWRITING *)

(*
 val split_gnode_pairs = 
  let
    val edge = GData.GT_Var "e";
    val bnode = GData.GN (GData.GN_Pair (GData.GN_Var "h",GData.GN_Var "t"));
    val fnode = GData.GN (GData.GN_Var "h");
    val snode = GData.GN (GData.GN_Var "t");
    val (inp,g0) = Graph.add_vertex Graph.WVert Graph.empty;
    val (outp,g0) = Graph.add_vertex Graph.WVert g0;
    val (bn,left) = Graph.add_vertex (Graph.NVert bnode) g0; 
    val left = left |> Graph.add_edge_anon (Directed,edge) inp bn
                    |> Graph.add_edge_anon (Directed,edge) bn outp;
    val (fno,right) = Graph.add_vertex (Graph.NVert fnode) g0; 
    val (sno,right) = Graph.add_vertex (Graph.NVert snode) right;
    val right = right |> Graph.add_edge_anon (Directed,edge) inp sno
                      |> Graph.add_edge_anon (Directed,edge) sno fno
                      |> Graph.add_edge_anon (Directed,edge) fno outp;
  in
     Theory.Rule.mk (left,right)
  end;
*)

 fun symmetric_rule rule = Theory.Rule.mk (Theory.Rule.get_rhs rule,Theory.Rule.get_lhs rule);
(*
 val combine_gnodes_to_pair = symmetric_rule split_gnode_pairs;
*)

(*
 val del_empty_gnode = 
  let
    val edge = GData.GT_Var "e";
    val node = GData.GN (GData.GN_Empty);
    val (inp,g0) = Graph.add_vertex Graph.WVert Graph.empty;
    val (outp,g0) = Graph.add_vertex Graph.WVert g0;
    val (bn,left) = Graph.add_vertex (Graph.NVert node) g0; 
    val left = left |> Graph.add_edge_anon (Directed,edge) inp bn
                    |> Graph.add_edge_anon (Directed,edge) bn outp;
    val right = Graph.add_edge_anon (Directed,edge) inp outp g0
  in
     Theory.Rule.mk (left,right)
  end;
*)

(*
 val gnode_rs = Theory.Ruleset.empty
            |> Theory.Ruleset.add_fresh_rule (R.mk "del_empty",del_empty_gnode)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)
            |> Theory.Ruleset.add_fresh_rule (R.mk "split_pair",split_gnode_pairs)
            |> (fn (rn,rs) => Theory.Ruleset.activate_rule rn rs)

 val gnode_one_step  = Theory.RulesetRewriter.apply gnode_rs
                     #> Seq.map snd;

 fun normalise_gnode g = 
   case Seq.pull (gnode_one_step g) of
      NONE => g
     | SOME (g',_) => normalise_gnode g';

 fun normalise_combine_gnodes g = 
   case Seq.pull (Util.rewrite_lazy combine_gnodes_to_pair g) of
     NONE => g
   | SOME (g',_) => normalise_combine_gnodes g';

*)
      
end (* functor *)
