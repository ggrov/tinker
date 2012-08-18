theory full_test                                        
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
val gf = RippleRTechn.induct_and_ripple;
val (t as (g,rst,v)) = RTechnEval.init @{theory} (RTechnEval.StringGoals ["0 + x = (x::N)"]) InductRTechn.induct_wire gf;
*}

ML{*
 pp g "init_tech";   
 PPlan.print (RState.get_pplan rst);
*}

ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}
ML{*
val [(t as (g,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
*}

ML{*
val [(t as (g1,rst,v))] = RTechnEval.step_df t |> Seq.list_of;
val s = hd v;
val th1 = RState.get_ctxt rst |> Proof_Context.theory_of;  

val gf2 = lift RippleRTechn.ripple_step';
val (g2,th2) = gf2 th1;  
val d = GraphComb.get_rtechns_of_graph g2 |> V.NSet.tryget_singleton |> the;  
*}

ML{*
 pp g1 "a0src1";   
 PPlan.print (RState.get_pplan rst);
*}


ML{*
pp g2 "a0dest1"
*}

(* need to delete input too!!! *)
ML{*
val ng2 = GraphComb.copy_input (s,(th1,g1)) (th2,g2);
pp ng2 "a0tmp1";
val (ng3,rst,v) = RTechnEval.step_df (ng2,rst,[d]) |> Seq.list_of |> hd;
pp ng3 "a0tmp2";
val g1' = GraphComb.copy_output (th2,ng3) (s,(th2,g1));
 pp g1' "a0src2";  
(*
   fun copy_input (v_src,(th_src,g_src)) (th_dest,g_dest) = 
copy_output (th_src,g_src) (v_dest,(th_dest,g_dest)
*)
*}










(* doesn't terminate - strange no extra loops*)
ML{*
RTGraph.get_boundary_inputs g;
RTGraph.get_boundary_outputs g;
RTE.apply_evaldf_searchdf @{context} InductRTechn.induct_wire g ["a + b = b + (a::N)"]
*}

ML{*
fun mydefer [] = []
 |  mydefer (x::xs) = xs@[x];
*}

(* test conj *)
ML{*
val g = RippleLemCalc_dsum.induct_and_ripple_lemcalc;
val (g1,rst1,enabled1) = RTE.init @{context} ["a + b = b + (a::N)"] (InductRTechn.induct_wire) g EvalDF.of_list;   
*}
ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
*}

ML{*
val enabled1 = mydefer enabled1;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
*}
ML{*
enabled1;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
*}
ML{*
enabled1;
RState.get_pplan rst1 |> PPlan.print; 
*}


(* test of counter example checker *)
ML{*
val g = RTechn.mk_graph BasicConjRTechn.ccex_rtechn;
val (g1,rst1,enabled1) = RTE.init @{context} ["a = b"] (BasicConjRTechn.goal_wire) g EvalDF.of_list;  
*}




ML{*
val rst = rst1;
fun get_term gname = RstPP.goal_concl rst gname 
    fun check_goal gname = 
       is_some (CounterExCInfo.timed_quickcheck_term 
                     (RstPP.get_ctxt rst) (CounterExCInfo.default_codegen_params, []) 
                     (Trm.change_vars_to_fresh_frees (get_term gname)) (Time.fromSeconds 1));

check_goal "g1";

val t =  RstPP.goal_concl rst1 "g1";
(*
 fun count_ex_app rst = 
  let
    fun get_term gname = RstPP.goal_concl rst gname 
    fun check_goal gname = 
       is_some (CounterExCInfo.timed_quickcheck_term 
                     (RstPP.get_ctxt rst) (CounterExCInfo.default_codegen_params, []) 
                     (Trm.change_vars_to_fresh_frees (get_term gname)) (Time.fromSeconds 1))
    val check_all = Goaln.NSet.forall check_goal (RState.get_names_of_wire rst goal_conj_wire)
   in 
      if check_all
       then Seq.single rst
       else Seq.empty
   end;
*)
*}

ML{*
RTE.apply_evaldf_searchdf @{context} BasicConjRTechn.goal_wire BasicConjRTechn.conj ["a + 0 = (a::N)"]
|> Seq.list_of |> length;   
*}


ML{*
val g =  BasicConjRTechn.conj;
val (g1,rst1,enabled1) = RTE.init @{context} ["Nsuc a = Nsuc b"] (BasicConjRTechn.goal_wire) g EvalDF.of_list;  
*}
ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

 ML{*
val t = RTechn.id |> RTechn.set_inputs (RState.Wire.NSet.of_list [RState.Wire.of_string "goal.a"])
          |> RTechn.set_outputs (RState.Wire.NSet.of_list [RState.Wire.of_string "goal.a.a",RState.Wire.of_string "goal.a.b"])
      |> RTechn.mk_graph
*}

ML{*
val g = BasicConjRTechn.conj;
val (g1,rst1,enabled1) = RTE.init @{context} ["a + 0 = (a::N)"] (BasicConjRTechn.goal_wire) g EvalDF.of_list; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
RTGraph.get_boundary_outputs g1;
*}


ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}


ML{*
val g = BasicConjRTechn.conj;
val (g1,rst1,enabled1) = RTE.init @{context} ["a + 0 = (a::N)"] (RState.Wire.of_string "goal.not_trivial") g EvalDF.of_list; 
*}

ML{*
RTGraph.get_boundary_inputs g
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}


ML{*
BasicConjRTechn.conj
*}

ML{*
 RippleRTechn.induct_and_ripple_rtechn |> RTGraph.get_boundary_outputs;
 RippleRTechn.induct_and_ripple_rtechn |> RTGraph.get_boundary_inputs;

 fun swap [x,y] = [y,x];
*}



(*
ML{*
val g = RippleRTechn.induct_and_ripple_rtechn;
val (rst1,g1,enabled1) = RTE.init @{context} ["a + b = b + (a::N)"] RState.Wire.default_wire g; 
RState.get_pplan rst1 |> PPlan.print;
*}
*)
ML{*
val eval_df = EvalDF.apply RTE.eval_atomic RTE.get_next_all_enabled;
val eval_bf = EvalBF.apply RTE.eval_atomic RTE.get_next_all_enabled;
fun step evalf = evalf RTE.eval_atomic RTE.get_next_all_enabled;
RTE.get_next_all_enabled;   
*}

(*
eval : (vname -> (rst * graph) -> graph * rst seq) -> (vname -> graph -> vname list) -> T -> rst -> graph -> (graph * rst * T) seq
fun eval appf enabf enabled rst graph =
  let val x = pop enabled
  in
    eval rst graph 
*)
(*
ML{*
RTabEnv.add_rtechn InductRTechn.induct_rtechn; 
RTabEnv.merge_with RippleRTechn.rtechns;
*}
*)
ML{* 


RTabEnv.get_all_rtechns ();
GSearch.depth_fs;
RTE.apply_evaldf_searchdf @{context} RState.Wire.default_wire RippleRTechn.induct_and_ripple_rtechn ["a + 0 = (a::N)"]
|> Seq.list_of |> hd |> (fn (_,rst,_) => RState.get_pplan rst) |> PPlan.print;  
*}



ML{*
val g = RippleRTechn.induct_and_ripple_rtechn;
val (g1,rst1,enabled1) = RTE.init @{context} ["a + 0 = (a::N)"] RState.Wire.default_wire g EvalDF.of_list; 
*}

ML{*


*}

ML{*
val g = RippleRTechn.induct_and_ripple_rtechn;
val (g1,rst1,enabled1) = RTE.init @{context} ["a + 0 = (a::N)"] RState.Wire.default_wire g EvalDF.of_list; 
RState.get_pplan rst1 |> PPlan.print;
*}


ML{*

val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val t = conj_from_gname rst1 "j" |> Seq.list_of |> map (fn (_,(_,t)) => t) |> hd;
val (conjname,rst2) = RstPP.new_conj_at_top ("lem_a", t) rst1;
RState.get_pplan rst2 |> PPlan.print;
PPlan.apply_res_bck "lem_a" "j" (RState.get_pplan rst2) |> Seq.list_of |> hd |> snd |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_df (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print;
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}

ML{*
val xs = Seq.list_of (RTE.step_bf (g1,rst1,enabled1));
val (g1,rst1,enabled1) = hd xs;
RState.get_pplan rst1 |> PPlan.print; 
*}



end



