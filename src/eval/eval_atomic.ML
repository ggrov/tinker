structure EvalAtomic =
struct

  exception rtechn_exp of RTechn.T * string
  exception gnode_exp of string
  exception graph_exp of string * Strategy_Theory.Graph.T
 
  (* should be a functor - df is default *)
  structure EData = EvalD_DF;

(*
  fun get_pnode ctxt gnode = PNode_Ctxt.get_goal ctxt (GNode.get_goal gnode);
*)
  fun upd_gnode_goal goal gnode = gnode
                                |> GNode.set_prev (SOME gnode)
                                |> GNode.set_goal (PNode.get_name goal);

  fun matching_hyps fmap gnode pnode bwire = 
    StrName.NSet.filter 
      (fn hname => WMatch.bwire_match fmap (PNode.get_ctxt pnode) bwire 
                                      (StrName.NTab.get (PNode.get_assms pnode) hname))
      (PNode.get_lassms pnode)

  fun upd_hyp fmap pnode bwire gnode =
     matching_hyps fmap gnode pnode bwire
     |> (fn gs => GNode.add_facts (bwire,gs) gnode)

  fun upd_hyps_by_wire fmap gnode pnode wire =
    BW.NSet.fold 
     (upd_hyp fmap pnode)
     (Wire.get_facts wire)
     gnode;

  fun upd_goal_by_wire fmap gnode pnode wire = 
    if WMatch.bwire_match 
             fmap 
             (PNode.get_ctxt pnode) (Wire.get_goal wire) (PNode.get_goal pnode) 
    then SOME (upd_gnode_goal pnode gnode) 
    else NONE
    handle _ => NONE;

  fun upd_by_wire fmap gnode pnode wire =
    case upd_goal_by_wire fmap gnode pnode wire 
     of NONE => NONE
     |  (SOME gn) => SOME (wire,upd_hyps_by_wire fmap gn pnode wire);

  (* what if there are more than one? or none? 
      -> currently fails! 
  *)  
  fun upd_by_wires fmap gnode wset pnode =
    let 
      fun prj_unique [] = raise gnode_exp "no matching outputs"
       |  prj_unique [SOME g] = g
       |  prj_unique _ = raise gnode_exp "many matching outputs"
    in 
      map (upd_by_wire fmap gnode pnode) (W.NSet.list_of wset)
      |> filter (Option.isSome)
      |> prj_unique
    end;

  (* ignores hyps and wire *)
  fun upd_rule wset edata gnode (pnds,prf) = 
    let
     val edata' = edata
               |> EData.set_pplan prf (* updates proof in context *)
               |> EData.del_goal (GNode.get_goal gnode) (* deletes goal from ctxt (now in prf) *)
               |> EData.add_goals pnds
   in
      (edata',map (upd_by_wires (EData.get_fmatch edata) gnode wset) pnds)
   end

   (* actual application of proof technique *)
    fun get_thm edata gnode name =
      let 
         val th = gnode
                |> GNode.get_goal 
                |> EData.get_goal edata
                |> PNode.get_ctxt
                |> Proof_Context.theory_of
      in
        Global_Theory.get_thm th name
      end;  

    fun thm_seq edata gnode thm_nms =
      thm_nms 
      |> StrName.NSet.list_of 
      |> map (get_thm edata gnode)
      |> Seq.of_list;

  fun apply_appf edata wset gnode (RTechn.Rule thm_nms) =
     thm_seq edata gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_rule (EData.get_goal edata (GNode.get_goal gnode), EData.get_pplan edata))
     |> Seq.map (upd_rule wset edata gnode)
(*   |  apply_appf ctxt (RTechn.ERule (nbwire,thm_nms)) gnode =
     thm_seq gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_erule (gnode,prf) nbwire);
   |  apply_appf ctxt (RTechn.FRule (nbwire,thm_nms)) gnode =
     thm_seq gnode thm_nms
     |> Seq.maps (PPlanEnv.apply_frule (gnode,prf) nbwire);
   |  apply_appf ctxt (RTechn.Subst thm_nms) gnode =
   |  apply_appf ctxt (RTechn.SubstAsm (nbwire,thm_nms)) gnode =
   |  apply_appf ctxt (RTechn.Tactic (bwire_nms,tac_name)) gnode =  *);

  
  fun delete_input_rule (gnode,w) = 
    let
      val (inp,g0) = Strategy_Theory.Graph.empty
                   |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
      val (outp,g1) = g0
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
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
                    |> Strategy_Theory.Graph.add_vertex Strategy_OVData.WVert;
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
   of (SOME atom) => apply_appf edata (RTechn.get_outputs rtechn) gnode atom
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
      val matches = Strategy_Theory.RulesetRewriter.rule_matches rule graph' |> snd;
      fun rewr match = Strategy_Theory.GraphSubst.rewrite graph' (Strategy_Theory.Rule.get_lhs rule) match (Strategy_Theory.Rule.get_rhs rule)
    in
      Seq.map (snd o rewr) matches
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

   fun eval_rules (edata,rules) =  Seq.map (eval_rule edata) (Seq.of_list rules);

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
    
end (* structure *)
