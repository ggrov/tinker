theory nested_test 
imports
  "../build/Eval"             
begin

ML{*
 val path = "/u1/staff/gg112/";
 val wire = Wire.default_wire;
 val rt = RTechn.id_of wire;
 val gf = NEST "2id" (LIFTRT rt THENG LIFTRT rt);
 val edata0 = RTechnEval.init_f @{theory} [@{prop "A ==> A"}] gf;
 val g = RTechnEval.EData.get_graph edata0;
*}

ML{*
  val [edata1] = RTechnEval.eval_any edata0 |> Seq.list_of;
*}

ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "nested_works.dot") ( RTechnEval.EData.get_graph edata1)
*}

(* step by step *)
ML{*
 val [v] = GraphEnv.get_rtechns_of_graph g |> V.NSet.list_of;
 val [rule] = EvalNested.eval_nested_get_rules NONE edata0 v; 

 val[g'] = EvalNested.lhs_seq g v |> Seq.list_of;
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g';
 RTechnEval.eval_any edata0 |> Seq.list_of;
*}

ML{*
 val [g'] = EvalGraph.rewrite_lazy rule g' |> Seq.list_of;
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g';
 val edata1 = EvalNested.mk_nested_edata edata0 g';
*}

ML{*
val [res] = RTechnEval.eval_full edata1 |> Seq.list_of;
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") (RTechnEval.EData.get_graph res);
val [g]=  EvalNested.apply_inv_rule rule  (RTechnEval.EData.get_graph res |> Strategy_Theory.Graph.normalise) |> Seq.list_of;
 Strategy_Dot.write_dot_to_file false (path ^ "nested_fold.dot") g; 
*}

ML{*
val g' = (RTechnEval.EData.get_graph res |> Strategy_Theory.Graph.normalise);
val invrule = EvalNested.rule_inverse rule;
val (r,ss) = Strategy_Theory.RulesetRewriter.rule_matches invrule g';
Strategy_Dot.write_dot_to_file false (path ^ "nested_fold2.dot") (Strategy_Theory.Rule.get_lhs invrule);
Seq.list_of ss;
*}


end;


