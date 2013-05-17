signature EVAL_GRAPH =
sig
  structure GoalTyp : GOAL_TYP
  structure Atomic : ATOMIC
  (* should go somewhere else *)
  val lift : GoalTyp.T -> GNode.T -> Atomic.pplan -> Atomic.pnode -> GNode.T option


  exception partition_exp of Atomic.pnode

  (* return value : outer list - each branch: singleton 
                    middle list - one branch same length as goaltype input list
                    inner list - matching goal nodes for given goaltype
    invariant result = partition goal_typs pplan pnds 
       all res in result: length res  = length goal_typs (and they pairwise match)
                          
       outer list is all the possible options -> should be a singleton list if orthogonal
       length (result) > 0
  *)
  val partition : GoalType.T list -> Atomic.pplan -> Atomic.pnode list -> GNode.T list list list
   (* raises partition_exp *)
end

functor EvalGraphFun(EData : EVAL_DATA) =
struct
  structure EData = EData;
  structure Theory = EData.PSGraph;
  structure PSTheory = EData.PSGraph.PSTheory
  structure Graph = EData.PSGraph.PSTheory.Graph;
  structure GData = PSTheory.PS_GraphParam.GraphSubstData;

  (* move into separate/different file? *) 
  structure Util =
  struct
      (* actual rewriting *)
    fun rewrite_lazy rule graph = 
      let 
        val graph' = Graph.normalise graph;
        val (rule',matches) = Theory.RulesetRewriter.rule_matches rule graph';
        fun rewr match = 
          Theory.GraphSubst.do_rewrite match (Theory.Rule.get_rhs rule')
      in
        Seq.map rewr matches
      end;
    val rewrite = Seq.list_of oo rewrite_lazy;

    fun edge_dest g e = Graph.get_edge g e |> (snd o snd);
    fun edge_src g e = Graph.get_edge g e |> (fst o snd);
    fun edge_data g e = Graph.get_edge g e |> fst |> snd;

    fun insert_node_on_edge node edge graph0 =
      let val (l,graph') = Graph.add_vertex (Graph.OVData.NVert node) graph0
          val from = edge_src graph' edge
          val to = edge_dest graph' edge
          val edata = edge_data graph' edge
      in
        graph' |> Graph.delete_edge edge 
               |> Graph.doadd_edge (Graph.Directed,edata) from l
               |> Graph.doadd_edge (Graph.Directed,edata) l to
      end;

    (* assumes: 1/1 - so just replace by wire node *)
    val del_gnode = Graph.update_vertex_data (K Graph.OVData.WVert);

  end (* structure Util *)
  
  fun lift goal_typ gnode pnode  =  NONE

  exception partition_exp of Atomic.pnode

  (* need some filtering of empty here *)
  fun partition_one' [] _ _ _ [] = [] (* fails to lift for this branch *)
  fun partition_one' (gt::gts) gnode pnode bres (r::ares) = 
    case lift gt gnode pnode of
      (* fails to lift *)
      NONE => partition_one' gts gnode pnode (bres@[r]) ares
      (* succeeds, and check for further successes *)
    | (SOME g') =>
        (* adds the succeded to the current result *)
        (bres @ [g'::r] @ ares) ::
        (* goes through and see if more succeeds (thus branching) *)
         partition_one' gts gnode pnode (bres@[r]) ares;

  (* raises exception if one proof nodes fails *)
  fun partition_one goal_typs gnode pnode res =
    case partition_one' goal_typs gnode pnode res [] of
       [] => raise partition_exp pnode
     | xs => xs
  
  (* partition all possible inputs *)
  fun partition []     _       _     = []
   |  partition pnds gnode goal_typs =
        [map (fn _ => []) goal_typs] (* empty list to start *)
        |> fold (fn pnd => map (partition_one goal_typs gnode pnd)) pnds

  val partition_to_gnodes = map GData.GN;

  (* add output nodes *) 
  




   (* begin simple output gnode *)

  fun try_add_one_output_gnode gnode pnode edata graph edge = 
    let 
      val wire = case GraphEnv.edge_data graph edge of
                    (DB_EdgeData.W wire) => wire
                  | _ => raise EvalOutput.gnode_exp ("edge not a valid wire");
      val maybe_gnode = EvalOutput.upd_by_wire (EData.get_fmatch edata) gnode pnode wire
    in
      case maybe_gnode of
         NONE => []
       | (SOME (_,gn)) => [GraphEnv.insert_vertex (edge,graph) (DB_VertexData.GN gn)]
    end;

  fun add_one_output_gnode v_rt gnode pnode edata graph = 
   let 
     val gnode' = gnode
                |> GNode.set_prev (SOME gnode)
                |> GNode.set_goal (PNode.get_name pnode)
   in
     GraphEnv.Graph.out_enames graph v_rt
     |> E.NSet.list_of
     |> maps (try_add_one_output_gnode gnode' pnode edata graph)
   end;

  fun add_outputs gnode pnds edata graph = 
    let
      val v_rt = (case V.NSet.tryget_singleton (GraphEnv.get_rtechns_of_graph graph)
                    of NONE => raise EvalOutput.gnode_exp ("graph does not have exactly one rtechn")
                     | SOME v => v)
      fun add_one' pnode g = add_one_output_gnode v_rt gnode pnode edata g
      fun add_one pnode g = case add_one' pnode g of
                            [] => raise EvalOutput.gnode_exp ("nothing matches node: " ^ PNode.get_name pnode)
                          | [x] => [x]
                          | xs => (warning "many outputs matches for node .."; xs)
    in
      fold (fn pn => maps (add_one pn)) pnds [graph]
    end;

   (* end simple output gnode *)

  (* consume of input and generation of output nodes *)  

  fun mk_delete_input_rule w node = 
    let
      val (inp,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                   |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
      val (outp,g1) = g0
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                    |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
      val rhs = g1
             |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) inp outp
             |> snd
      val (v,g2) = g1
                 |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert node) 
      val lhs = g2 
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) inp v
              |> snd
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v outp
              |> snd
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;  

  fun delete_inputvar_rule w = mk_delete_input_rule w (DB_VertexData.GVar "g");

  fun delete_inputgnode_rule (gnode,w) = mk_delete_input_rule w (DB_VertexData.GN gnode);


  (* I don't understand this! *)
  fun output_gnode (wr,rtechn) (w,gnode) = 
    let
      val (v_rt,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
      val (outp,g1) = g0
                    |> GraphEnv.add_boundary_to (DB_EdgeData.W wr) v_rt (* input edge *)
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert
                    |> (fn (n,g) => (n,Strategy_Theory.Graph.add_to_boundary n g));
      val lhs = g1
             |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v_rt outp
             |> snd
      val (v,g2) = g1
                 |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GN gnode)) 
      val rhs = g2 
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v_rt v
              |> snd
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v outp
              |> snd
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;     

  (* finds and instantiates the goal node *)
  (* was  eval_var_mk_rule_aux *)
  fun eval_match_and_instantiate_rhs graph graph_pat =
   let 
   (* match - FIXME: must be a better way than creating a dummy rule *)
    val subst = Strategy_Theory.RulesetRewriter.rule_matches 
                   (Strategy_Theory.Rule.mk(graph_pat,graph_pat))
                   graph
                |> snd
                |> Seq.map Strategy_Theory.Match.get_match_subst
    val gvars = GraphEnv.get_gvars_of_graph graph_pat;
    fun inst sub v g = 
      (case StrName.NTab.lookup sub (GraphEnv.v_to_gvar g v)
             of NONE => g
             | (SOME vdata) => Strategy_Theory.Graph.update_vertex_data 
                                (K (Strategy_OVData.NVert vdata)) v g)    
  in
    subst |> Seq.map (fn sub => V.NSet.fold (inst sub) gvars graph_pat)
  end 

  fun mk_eval_merge_rule_of_size edge n =
    let 
      val (v,g) = GraphEnv.lift_edgemerge_vertex n edge
      val in_edge = Strategy_Theory.Graph.in_enames g v  
                  |> E.NSet.get_local_bot
                  |> the (* should always succeed *)
      val out_edge = Strategy_Theory.Graph.out_enames g v
                  |> E.NSet.get_local_bot
                  |> the (* should always succeed *)
      val lhs = GraphEnv.insert_vertex (in_edge,g) (DB_VertexData.GVar "g");
      val rhs = GraphEnv.insert_vertex (out_edge,g) (DB_VertexData.GVar "g");
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;

  fun mk_eval_merge_rule_of edge =
    let 
      val g = GraphEnv.lift_edgemerge 2 edge;
      val (bb,g) = Strategy_Theory.Graph.add_bbox_named_like (B.mk "omerge") g;
      val [(ivb1,(ie1,_),_),(ivb2,_,_)] = GraphEnv.get_boundary_inputs g;
      (* assume no renaming of vertices *)
      val (vs,g) = Strategy_Theory.Graph.add_to_bbox bb (V.NSet.single ivb2) g;
      val [(_,(oe,_),_)] = GraphEnv.get_boundary_outputs g;
      val lhs = GraphEnv.insert_vertex (ie1,g) (DB_VertexData.GVar "g");
      val rhs = GraphEnv.insert_vertex (oe,g) (DB_VertexData.GVar "g");
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;

  (* creates a graph to match *)
  fun mk_match_graph graph v =
    let 
     val ins = Graph.in_enames graph v  
     val outs = Graph.out_enames graph v


     val get_wire = GraphEnv.e_to_wire graph
     val rtechn = GraphEnv.v_to_rtechn graph v
     (* graph with rtechn *)
     val (v_rt,g) = Strategy_Theory.Graph.empty
               |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.RT rtechn))
     (* adding goalnode variable *)
     val (v_gvar,g) = 
            Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GVar "g")) g
     fun mk_match_graph' inp = g
         |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W (get_wire inp)) v_gvar v_rt
         |> snd
         |> GraphEnv.add_boundary_to (DB_EdgeData.W (get_wire inp)) v_gvar
         |> E.NSet.fold (fn outp => GraphEnv.add_boundary_from (DB_EdgeData.W (get_wire outp)) v_rt) outs
         (* empty input for remaining input (so rewriting works) *)
         |> E.NSet.fold (fn o_inp => GraphEnv.add_boundary_from (DB_EdgeData.W (get_wire o_inp)) v_rt) 
                        (E.NSet.delete' inp ins) 
   in
     map mk_match_graph' (E.NSet.list_of ins)
   end;
    
end (* structure *)
