theory nested_test 
imports
  "../build/Eval"             
begin

ML{*
TacticTab.get_all_tactics @{theory}
*}

ML{*
 val path = "/Users/gudmund/";
 val wire = Wire.default_wire;
 val rt = RTechn.id_of wire;
 val gf = NEST "2id" (LIFTRT rt THENG LIFTRT rt);
 val edata0 = RTechnEval.init_f @{theory} [@{prop "A ==> A"}] gf;
 val g = RTechnEval.EData.get_graph edata0;
*}

ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g
*}

ML{*
TacticTab.get_all_tactics @{theory}
*}
(* fails: why? *)
ML{*
 RTechnEval.eval_any edata0 |> Seq.list_of;
*}




ML{*
val g2 = Strategy_Theory.RulesetRewriter.apply (Strategy_RS.Ctxt.get_ruleset (RTechnEval.EData.get_ctxt edata0)) g
 |> Seq.list_of |> hd |> snd;
*}
ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g2
*}

ML{*
val g3 = Strategy_Theory.RulesetRewriter.apply (Strategy_RS.Theory.get_ruleset th) g2
 |> Seq.list_of |> hd |> snd;
*}
ML{*
 Strategy_Dot.write_dot_to_file false (path ^ "nested1.dot") g3
*}
end;


