theory HOL_test                                                
imports        
  Main                              
  "../build/HOL_IsaP"                                     
uses  
 "../eval/basic_eval.ML"  
 "../eval/eval_atomic.ML"                               
 "../eval/rtechn_eval.ML"                                                                                                                             
begin

(* printing - (fixme: path hardcoded)*)
ML{*
fun pp graph name  = graph
  |> RTechn_Theory.IO_Xml.Output.Graph.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".graph");

fun pp_rule rule name  = rule
  |> RTechn_Theory.IO_Xml.Output.Rule.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".rule");

fun pp_ruleset ruleset name  = ruleset
  |> RTechn_Theory.IO_Xml.Output.Ruleset.output
  |> XMLWriter.write_to_file 
       ("/Users/ggrov/Desktop/graphs/" ^ name ^ ".ruleset");
*}

ML{*

*}
(* the graph *)
ML{*
val rt1 = RTechn.id_of WireNode.default_wire;
try_lift rt1  @{theory};
val gf = try_lift rt1 compose try_lift rt1;
val (g,_) = gf @{theory}
*}

ML{*

*}

(* extract subgraph *)
ML{*
 val vd = [V.mk "Vd"] |> V.NSet.of_list;
 val ng = RTechn_Theory.Graph.normalise g;
 val subg = RTechn_Theory.Graph.get_open_subgraph vd ng;
 pp subg "sub1"; 
 pp ng "norma";
*}

(* init state *)
ML{*
val (t as (g,rst,en)) = RTechnEval.init @{theory} (RTechnEval.StringGoals ["P"]) WireNode.default_wire gf;
PPlan.print (RState.get_pplan rst);
*}

ML{*
pp g "00test"
*}

section "Rewriting"

(* rewrite rule *)
ML{*
 val (rewr_g,_) = lift rt1 @{theory};
val rule = RTechn_Theory.Rule.mk (rewr_g,rewr_g);
*}

(* ruleset printing for quantomatic gui *)
ML{*
val (rn,rs) = RTechn_Theory.Ruleset.add_fresh_rule (R.mk "test",rule) RTechn_Theory.Ruleset.empty;
val rs' = RTechn_Theory.Ruleset.set_active (R.NSet.single rn) rs;
pp_ruleset rs' "test_rs"
*}

(* example of failure - FIXED! *)
ML{*
val (rn,rs) = RTechn_Theory.Ruleset.add_fresh_rule (R.mk "test",rule) RTechn_Theory.Ruleset.empty;
val match = RTechn_Theory.RulesetRewriter.rule_matches rule g |> snd |> Seq.list_of |> hd;
val g1 = RTechn_Theory.GraphSubst.rewrite g (RTechn_Theory.Rule.get_lhs rule) match (RTechn_Theory.Rule.get_rhs rule);
*}

section "Eval + printing of graph"

(* init graph *)
ML{*
pp g "test1"; 
*}

(* first eval *)
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
pp g "test2"; 
*}

(* snd eval *)
ML{*
val [(t as (g,rst,en))] =
RTechnEval.step_df t |> Seq.list_of;
pp g "test3"; 
*}













end



