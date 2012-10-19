structure EvalAtomic =
struct

  exception rtechn_exp of RTechn.T * string
  exception gnode_exp of string
  exception graph_exp of string * Strategy_Theory.Graph.T
 
  (* should be a functor - df is default *)
  structure EData = EvalD_DF;

  (* ignores hyps and wire *)
  fun upd_rule wset edata gnode (pnds,prf) = 
    let
     val edata' = edata
               |> EData.set_pplan prf (* updates proof in context *)
               |> EData.del_goal (GNode.get_goal gnode) (* deletes goal from ctxt (now in prf) *)
               |> EData.add_goals pnds
   in
      (edata',map (EvalOutput.upd_by_wires (EData.get_fmatch edata) gnode wset) pnds)
   end
  
  fun delete_input_rule (gnode,w) = 
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
                 |> Strategy_Theory.Graph.add_vertex (Strategy_OVData.NVert (DB_VertexData.GN gnode)) 
      val lhs = g2 
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) inp v
              |> snd
              |> Strategy_Theory.Graph.add_edge (Strategy_Theory.Graph.Directed,DB_EdgeData.W w) v outp
              |> snd
    in
      Strategy_Theory.Rule.mk (lhs,rhs)
    end;  

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

  fun mk_result (gnode,w) rtechn (edata,outgs) =
    (edata,delete_input_rule (gnode,w), map (output_gnode (w,rtechn)) outgs)

  fun eval_rtechn (gnode,w) rtechn edata =
   case RTechn.get_atomic rtechn
   of (SOME atom) => EvalAppf.apply_appf edata gnode atom
                    |> Seq.map (upd_rule (RTechn.get_outputs rtechn) edata gnode)
                    |> Seq.map (mk_result (gnode,w) rtechn)
   | NONE => raise rtechn_exp (rtechn,"not atomic technique");


  (* lookup gnode and rtechn and eval and then apply eval_rtechn *)
  fun eval_v_rtechn (v_gnode,v_rtechn) (edata,graph) =
   let 
     val gnode = GraphEnv.v_to_gnode graph v_gnode
     val wire = case E.NSet.tryget_singleton (Strategy_Theory.Graph.out_enames graph v_gnode)
                of NONE => raise gnode_exp ("gnode does not have single output")
                | SOME e => GraphEnv.e_to_wire graph e
     val rtechn = GraphEnv.v_to_rtechn graph v_rtechn 
   in
    eval_rtechn (gnode,wire) rtechn edata
   end;

  fun rewrite_lazy rule graph = 
    let 
      val graph' = Strategy_Theory.Graph.normalise graph;
      val (rule',matches) = Strategy_Theory.RulesetRewriter.rule_matches rule graph';
      fun rewr match = Strategy_Theory.GraphSubst.do_rewrite graph' (Strategy_Theory.Rule.get_lhs rule') match (Strategy_Theory.Rule.get_rhs rule')
    in
      Seq.map rewr matches
    end;

  val rewrite = Seq.list_of oo rewrite_lazy;
  (* FIXME: this is just the rewrite rule!!! *)

  (* evaluated graph (of only one gnode and one rtech) *)
  fun eval_mk_all_rules edata lhs =
   let
     val v_gnode = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph lhs)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 goalnode",lhs)
                    | SOME v => v)
      val v_rtechn = (case V.NSet.tryget_singleton (GraphEnv.get_rtechns_of_graph lhs)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 rtechn",lhs)
                    | (SOME v) => v)  
   in
      (eval_v_rtechn (v_gnode,v_rtechn) (edata,lhs))
   end

  fun eval_mk_rule edata lhs =
   let
      fun apply_subst rws = fold (fn r => maps (rewrite r)) rws [lhs]
      fun update (edata',ri,ros) =  (edata',map (fn r => (lhs,r)) (apply_subst (ri::ros)))  
   in
      Seq.map update (eval_mk_all_rules edata lhs)
   end

  fun eval_var_mk_rule_aux edata graph_pat =
   let 
    val graph = EData.get_graph edata
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

  fun eval_var_mk_rule edata graph_pat =
   Seq.maps (eval_mk_rule edata) (eval_var_mk_rule_aux edata graph_pat);

  (* almost the same as above - just used for debugging *)
  fun eval_var_mk_all_rules edata graph_pat =
   Seq.maps (eval_mk_all_rules edata) (eval_var_mk_rule_aux edata graph_pat);

   fun eval_rule edata rule = 
     rewrite_lazy (Strategy_Theory.Rule.mk rule) (EData.get_graph edata)
     |> Seq.map (fn g => EData.set_graph g edata)

   fun eval_rules (edata,rules) = Seq.maps (eval_rule edata) (Seq.of_list rules);

   fun eval_graph edata lhs =
     eval_var_mk_rule edata lhs
     |> Seq.maps eval_rules;    

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

  (* makes match graphs and evaluates *)
  fun eval_atomic edata v = 
    v |> mk_match_graph (EData.get_graph edata)
      |> Seq.of_list
      |> Seq.maps (eval_graph edata);
    
end (* structure *)
