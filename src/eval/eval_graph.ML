(*
   contains functionality linking the proof/tactic with the strategy graph (eval into rewriting)
*)
structure EvalGraph =
struct

  structure EData = EvalD_DF;

  (* actual rewriting *)
  fun rewrite_lazy rule graph = 
    let 
      val graph' = Strategy_Theory.Graph.normalise graph;
      val (rule',matches) = Strategy_Theory.RulesetRewriter.rule_matches rule graph';
      fun rewr match = 
        Strategy_Theory.GraphSubst.do_rewrite match (Strategy_Theory.Rule.get_rhs rule')
    in
      Seq.map rewr matches
    end;

  val rewrite = Seq.list_of oo rewrite_lazy;

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
  fun eval_var_mk_rule_aux graph graph_pat =
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
     val ins = Strategy_Theory.Graph.in_enames graph v  
     val outs = Strategy_Theory.Graph.out_enames graph v
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
