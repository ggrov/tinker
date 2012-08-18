theory HOL_ripple_test                                        
imports         
  "../build/HOL_IsaP"                                     
 N 
uses
 "../eval/basic_eval.ML"  
 "../eval/eval_atomic.ML"                                 
 "../eval/rtechn_eval.ML"                                
begin

ML{*

val path = "/Users/ggrov/Desktop/graphs/";

fun pp graph name  = graph
  |> RTechn_Theory.IO_Xml.Output.Graph.output
  |> XMLWriter.write_to_file 
       (path ^ name ^ ".graph");

fun pp_rule rule name  = rule
  |> RTechn_Theory.IO_Xml.Output.Rule.output
  |> XMLWriter.write_to_file 
       (path ^ name ^ ".rule");

fun pp_ruleset ruleset name  = ruleset
  |> RTechn_Theory.IO_Xml.Output.Ruleset.output
  |> XMLWriter.write_to_file 
       (path ^ name ^ ".ruleset");
*}

ML{*
fun pp_active_rs rst =
  pp_ruleset (RTechn_RS.RState.get_ruleset rst) "active"; 
*}

ML{*
val gf = RippleRTechn.induct_and_ripple;
val (t as (g,rst,v)) = RTechnEval.init @{theory} (RTechnEval.StringGoals ["x + 0 = (x::N)"]) InductRTechn.induct_wire gf;
*}

ML{*
fun myfilter (g,rst,v) =
  ((RTechnEval.eval_step (g,rst,v) |> Seq.list_of |> hd);true)
  handle GNode_Ctxt.Wire.wire_notincontext_exp _ => false;
*}

(* Problem: extra goalnode is present in one of search path that shouldn't be there!
    - seems like it gets send down both active and not active wire!
    - I wonder if this is a rippling specific problem! don't think so.. seems to be goalnodes
 *)

ML{*
EvalAtomic.dummy := []; 
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;   
*} 

ML{*
val z = filter myfilter (!EvalAtomic.dummy); 
EvalAtomic.dummy := [];  
*}

ML{*
length z;
length z;
*}


ML{*
 val x1 = hd z;
 val x2 = hd (tl z);
 val x3 = hd (tl (tl z));
 val x4 = hd (tl (tl (tl z)));
 val x5 = hd (tl (tl (tl (tl z))));
 val x6 = hd (tl (tl (tl (tl (tl z)))));
 val x7 = hd (tl (tl (tl (tl (tl (tl z))))));
 val x8 = hd (tl (tl (tl (tl (tl (tl (tl z)))))));
 val x9 = hd (tl (tl (tl (tl (tl (tl (tl (tl z))))))));
 val x10 = hd (tl (tl (tl (tl (tl (tl (tl (tl (tl z)))))))));

*}

(* fail arises - need to use x2? *)
ML{*
fun trd (_,_,c) = c;
val (g,rst) =  RTechnEval.eval_step x1 |> Seq.list_of |> hd;
pp g "mytest1";
val [v1,v2] = GraphComb.get_rtechns_of_graph g |> V.NSet.list_of;
pp g "mytest";

val (g,rst) = RTechnEval.eval_step (g,rst,v1) |> Seq.list_of |> hd;
(* RTechnEval.eval_step (g,rst,v2) |> Seq.list_of |> hd; *)
*}

ML{*
fun trd (_,_,c) = c; 
val (g,rst) =  RTechnEval.eval_step x8 |> Seq.list_of |> hd;
pp g "mmytest1";
val [v1,v2] = GraphComb.get_rtechns_of_graph g |> V.NSet.list_of;
pp g "mmytest";

*}



ML{*
 PPlan.print (RState.get_pplan rst);
 RState.get_outputs rst |> GoalNode.G.NSet.list_of |> tl |> hd |> snd |> GNode.GoalSet.list_of;
 RState.get_outputs rst |> GoalNode.G.NSet.list_of;
*}

ML{*
val aout = GraphComb.get_out_edges g v |> E.NSet.list_of |> hd;
val x = RState.get_outputs rst |> GoalNode.G.NSet.list_of |> tl |> hd;
EvalAtomic.simple_edge_match x aout g rst
*}

ML{*
GraphComb.get_out_edges g v |> E.NSet.list_of |> map (GraphComb.edge_data g);

GraphComb.get_goalnodes_of_graph g |> V.NSet.list_of |> map (GraphComb.v_to_goalnode g);

val (g',rst') = RTechnEval.eval_step (g,rst,v) |> Seq.list_of |> hd;
RTechnEval.eval_step (g',rst',v);

*}


ML{*
GNode_Ctxt.Wire.Ctxt.get (RState.get_ctxt rst);
 PPlan.print (RState.get_pplan rst);
RTechn_Theory.Graph.get_vertex_data g v;
 pp g "error1";
 pp bg "error2";
 pp bbg "error3";
*}

ML{*
val v = bbg |> GraphComb.get_rtechns_of_graph (* maybe only for input wires *)
           |> V.NSet.list_of 
           |> filter (RTechnEval.is_enabled bbrst bbg);

RTechn_Theory.Graph.get_vertex_data bbg |> (fn f => map f v)
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (bbg,bbrst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (g,rst,h) = RTechnEval.get_hgraph (g,rst,hd v);
 pp g "n1";  
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na2";  
 PPlan.print (RState.get_pplan rst);
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "na1";  
 PPlan.print (RState.get_pplan rst);
*}

(* try to unfold graph : this works so problem is within hierarchies - is it a different type
of wire there may? (shouldn't be the case since unfolding works!) *)
ML{*
val rs = (RTechn_RS.RState.get_ruleset rst);
*}
ML{*
val ng = RTechn_Theory.RulesetRewriter.apply rs g |> Seq.list_of |> tl |> hd |> snd;
pp ng "ng"; 

val v = ng |> GraphComb.get_rtechns_of_graph (* maybe only for input wires *)
           |> V.NSet.list_of 
           |> filter (RTechnEval.is_enabled rst ng)
           |> tl;

RTechn_Theory.Graph.get_vertex_data ng |> (fn f => map f v)
*}
ML{*

val (t as (g,rst,v)) = RTechnEval.step_df (ng,rst,v) |> Seq.list_of |> hd;
 pp g "aaa4";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
RTechn_Theory.Graph.get_vertex_data g |> (fn f => map f v);
RTechn_Theory.Graph.get_vertex_data g (V.mk "Vaq");
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df (g,rst,v) |> Seq.list_of |> hd;
 pp g "aaa5";  
 PPlan.print (RState.get_pplan rst);
*}



ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
 pp g "aaa4";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
 pp g "aaa4";  
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
 pp g "aaa4";  
 PPlan.print (RState.get_pplan rst);
*}


ML{*
open RTechnEval;
*}

ML{*
val v = hd v;
      val rt_name = GraphComb.v_to_rtechn g v;
      val rs = RTechn_RS.RState.get_ruleset rst;
      val rs_nms = RTechn_RS.rs_get_unfold rs;
      val rule = lookup_hgraph_rule rt_name rs rs_nms
      val dest_g = RTechn_Theory.Rule.get_rhs rule;
      fun th_of st = RState.get_ctxt st |> Proof_Context.theory_of
      val th = th_of rst
*}

ML{*
      val (t as (g,rst,v)) = GraphComb.copy_input (v,(th,g)) (th,dest_g)
             |> init_hgraph rst;

 pp g "a01";  
*}

ML{*
GSearch.depth_fs (is_terminated EvalDF.is_empty) (EvalDF.apply eval_step get_next_all_enabled) t 
 |> Seq.list_of
*}

ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
 pp g "a02";
*}

ML{*
is_terminated EvalDF.is_empty (g,rst,v)
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}

ML{*

      val new_gseq = (g',rst',v')
             |> GSearch.depth_fs (is_terminated EvalDF.is_empty) (EvalDF.apply eval_step get_next_all_enabled)
      fun upd (dest_g',rst',_) =
        GraphComb.copy_output (th_of rst',dest_g') (v,(th_of rst',g))
        |> delete_inputs v
        |> (fn final_g => (final_g,rst'));


*}

(* actual test *)
ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
 pp g "aaa3";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}


ML{*
 pp g "aaa4";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd; 
*}


ML{*
 pp g "aaa5";    
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa6";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa7";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa8";    
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa9";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa10";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val (t as (g,rst,v)) = RTechnEval.step_df t |> Seq.list_of |> hd;
*}
ML{*
 pp g "aaa11";   
 PPlan.print (RState.get_pplan rst);
*}

(* done *)




ML{*
val wire = WireNode.default_wire;
val simp = RTechnEnv.simp_all_asm_full_on wire;
val gf = (RTechnComb.lift_split 3 wire) compose (RTechnComb.lift_merge 3 wire) compose (lift simp);
val (t as (g,rst,v)) = RTechnEval.init @{theory} (RTechnEval.StringGoals ["Suc (a::nat) = Suc b"]) wire gf;
*}

ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
 pp g "sm0"; 
*}

ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
 pp g "sm1";
*}


ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
 pp g "sm2"; 
*}

ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
 pp g "sm3";
*}

ML{*
PPlan.print (RState.get_pplan rst);
*}

ML{*

val (g,th) = RippleRTechn.ripple_step @{theory};

 pp g "rstep4";
*}

ML{*
 RTechn.merge_of WireNode.default_wire;
*}

ML{*
open RippleRTechn;open RTechn; open RTechnEnv; open RTechnComb;
*}


ML{*
open GraphComb;
*}


ML{*
val (g,th) = RippleRTechn.ripple_step @{theory};
pp g "rstep2";
val (newg,th') = RTechnComb.collapse_graph "ripple" g th;

val rule = RTechn_Theory.Rule.mk (g,newg);
val (rn1,rs) = RTechn_Theory.Ruleset.add_fresh_rule (R.mk "fold_rstep",rule) RTechn_Theory.Ruleset.empty;
val rule = RTechn_Theory.Rule.mk (newg,g);
val (rn2,rs) = RTechn_Theory.Ruleset.add_fresh_rule (R.mk "unfold_rstep",rule) rs

val rs' = RTechn_Theory.Ruleset.set_active (R.NSet.of_list [rn1,rn2]) rs;
pp_ruleset rs' "rs_ripple" 
*}

ML{*
val (g,th) = RippleRTechn.ripple_stepcase (InductRTechn.hyp_wire,InductRTechn.stepcase_wire) @{theory};
 pp g "rstep3";

*}

ML{*
val (g,th) = RippleRTechn.induct_and_ripple @{theory};
 pp g "induct_ripple";
*}
end;
