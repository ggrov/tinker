(*
 for evaluation of hierarchical rule
*)
structure EvalNested =
struct

  structure EData = EvalD_DF;
  exception graph_exp of string * Strategy_Theory.Graph.T

 fun eval_nested_rule evalf edata v rule = 
    let
      val inv_rule = Strategy_Theory.Rule.mk 
                        (Strategy_Theory.Rule.get_lhs rule,
                         Strategy_Theory.Rule.get_rhs rule);
      val graph = EData.get_graph edata
      val lhs_seq = v 
              |> EvalGraph.mk_match_graph graph
              |> Seq.of_list
              |> Seq.maps (EvalGraph.eval_var_mk_rule_aux graph)
              |> Seq.map GraphEnv.half_edge_to_boundary
      fun v_gnode g = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph g)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 goalnode",g)
                    | SOME v => v)
      fun v_rtechn g = (case V.NSet.tryget_singleton (GraphEnv.get_rtechns_of_graph g)
                     of NONE => raise graph_exp ("graph does not contain exactly 1 rtechn",g)
                     | (SOME v) => v)
      fun eval_one' lhs =
        let 
           val gnode = (GraphEnv.v_to_gnode lhs (v_gnode lhs))
           fun mk_edata g = edata
                          |> EData.set_graph g
                          |> EData.set_goals StrName.NTab.empty
                          |> EData.add_goal (EData.get_goal edata (GNode.get_goal gnode))
           fun mk_eval_rules edata' = 
              EvalGraph.rewrite_lazy inv_rule (EData.get_graph edata')
              |> Seq.map (fn rhs => Strategy_Theory.Rule.mk (lhs,rhs))
           fun update_old_edata edata' graph' =
              edata |> EData.set_pplan (EData.get_pplan edata') (* updates proof in context *)
                    |> EData.del_goal (GNode.get_goal gnode) (* deletes goal from ctxt (now in prf) *)
                    |> EData.add_goals (EData.get_goals edata' |> StrName.NTab.values)
                    |> EData.set_graph graph'
           fun update_parent edata' =
             edata' |> mk_eval_rules
                    |> Seq.maps (fn r => EvalGraph.rewrite_lazy r graph)
                    |> Seq.map (update_old_edata edata')
        in
          lhs |> EvalGraph.rewrite_lazy rule
              |> Seq.map mk_edata
              |> Seq.maps evalf
              |> Seq.maps update_parent
        end
    in
      Seq.maps eval_one' lhs_seq
    end;

  (* could make it more efficient: by checking first which rules contains v's data *)
  fun eval_nested evalf tag edata v =
    let 
       val rulenames = case tag of 
          NONE => Strategy_Theory.Ruleset.get_all_rule_names_list (EData.get_ruleset edata)
         |  (SOME t) => (Strategy_Theory.Ruleset.get_rules_in_tag (EData.get_ruleset edata) t
                         |> R.NSet.list_of)
       val rulelist = map (Strategy_Theory.Ruleset.get_rule (EData.get_ruleset edata)) rulenames
   in
     Seq.maps (eval_nested_rule evalf edata v) (Seq.of_list rulelist)
  end;

end (* struct *)


