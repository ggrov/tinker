
structure EvalOutput =
struct

  exception gnode_exp of string

  fun matching_hyps fmap pnode bwire = 
    StrName.NSet.filter 
      (fn hname => WMatch.bwire_match fmap (PNode.get_ctxt pnode) bwire 
                                      (StrName.NTab.get (PNode.get_assms pnode) hname))
      (PNode.get_lassms pnode)

  fun upd_hyp fmap pnode bwire gnode =
     matching_hyps fmap pnode bwire
     |> (fn gs => GNode.add_facts (bwire,gs) gnode)

  fun upd_hyps_by_wire fmap gnode pnode wire =
    BW.NSet.fold 
     (upd_hyp fmap pnode)
     (Wire.get_facts wire)
     gnode;

  (* make gnode into a function *)
  fun upd_goal_by_wire fmap gnode pnode wire = 
    if WMatch.bwire_match 
             fmap 
             (PNode.get_ctxt pnode) (Wire.get_goal wire) (PNode.get_goal pnode) 
    then SOME gnode 
    else NONE
    handle _ => NONE;

  fun upd_by_wire fmap gnode pnode wire =
    case upd_goal_by_wire fmap gnode pnode wire 
     of NONE => NONE
     |  (SOME gn) => SOME (wire,upd_hyps_by_wire fmap gn pnode wire);

  (* what if there are more than one? or none? 
      -> currently fails! 
  *)  
  fun lift_gnode_by_wires fmap gnode wset pnode =
    let 
      fun prj_unique [] = raise gnode_exp "no matching outputs"
       |  prj_unique [SOME g] = g
       |  prj_unique _ = raise gnode_exp "many matching outputs"
    in 
      map (upd_by_wire fmap gnode pnode) (W.NSet.list_of wset)
      |> filter (Option.isSome)
      |> prj_unique
    end;

  fun lift_pnode_by_wires fmap wset pnode =
    lift_gnode_by_wires fmap (GNode.mk_goal_no_facts (PNode.get_name pnode)) wset pnode

  fun upd_by_wires fmap gnode wset pnode =
    let 
      val gnode' = gnode
                 |> GNode.set_prev (SOME gnode)
                 |> GNode.set_goal (PNode.get_name pnode)
    in
      lift_gnode_by_wires fmap gnode' wset pnode
    end;

end (* structure *)

structure FROMEVALGRAPH =
struct





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

 
end (* struct *)
