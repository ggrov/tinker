(*
 for evaluation of hierarchical rule
*)
structure EvalNested =
struct

  structure EData = EvalD_DF;
  exception graph_exp of string * Strategy_Theory.Graph.T
 
  fun lhs_seq graph v = 
    v |> EvalGraph.mk_match_graph graph
      |> Seq.of_list
      |> Seq.maps (EvalGraph.eval_match_and_instantiate_rhs graph)
      |> Seq.map GraphEnv.half_edge_to_boundary

  fun v_gnode g = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph g)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 goalnode",g)
                     | SOME v => v)
  fun v_rtechn g = (case V.NSet.tryget_singleton (GraphEnv.get_rtechns_of_graph g)
                     of NONE => raise graph_exp ("graph does not contain exactly 1 rtechn",g)
                     | (SOME v) => v)

  fun mk_nested_edata old_edata graph = 
    old_edata
    |> EData.set_graph graph
    |> EData.set_goals StrName.NTab.empty
    |> EData.add_goal (EData.get_goal old_edata (GNode.get_goal (GraphEnv.v_to_gnode graph (v_gnode graph))))

  fun rule_inverse rule = 
    Strategy_Theory.Rule.mk (Strategy_Theory.Rule.get_rhs rule,
                             Strategy_Theory.Rule.get_lhs rule)
  val apply_inv_rule  =
    EvalGraph.rewrite_lazy o rule_inverse;

  fun eval_nested_rule evalf edata v rule = 
    let
      val graph = EData.get_graph edata
      fun eval_one' lhs =
        let 
           val gnode = (GraphEnv.v_to_gnode lhs (v_gnode lhs))
           fun mk_eval_rules edata' = 
              apply_inv_rule rule (EData.get_graph edata')
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
              |> Seq.map (mk_nested_edata edata)
              |> Seq.maps evalf
              |> Seq.maps update_parent
        end
   in
      Seq.maps eval_one' (lhs_seq graph v)
   end;

  (* assume not represented as a variable *)
  fun eval_nested_get_rules tag edata v =
    let 
       val rt = GraphEnv.v_to_rtechn (EData.get_graph edata) v  
       val rulenames = case tag of 
          NONE => Strategy_Theory.Ruleset.get_all_rule_names_list (EData.get_ruleset edata)
         |  (SOME t) => (Strategy_Theory.Ruleset.get_rules_in_tag (EData.get_ruleset edata) t
                         |> R.NSet.list_of)
       val rulelist = map (Strategy_Theory.Ruleset.get_rule (EData.get_ruleset edata)) rulenames
       fun isvalid rule = (Strategy_Theory.Rule.get_lhs rule)
                        |> GraphEnv.get_rtechns_of_graph
                        |> V.NSet.list_of
                        |> map (GraphEnv.v_to_rtechn (Strategy_Theory.Rule.get_lhs rule))
                        |> exists (fn rt' => RTechn.eq (rt,rt'))
   in
     filter isvalid rulelist
  end;  


  fun eval_nested evalf tag edata v =
    let 
       val rulelist = eval_nested_get_rules tag edata v
   in
     Seq.maps (eval_nested_rule evalf edata v) (Seq.of_list rulelist)
  end;

end (* struct *)


