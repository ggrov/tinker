local 
val _ = Trm.drop_var_args_flag := false;

val _ = use_thy "examples/L"; val thry = theory "L";
val rst0 = RstPP.init thry;

val (g,rst0) = 
    rst0 |> RstPP.new_conj_of_str_at_top
         ("step case", 
          "(!! e. rev d @ e = qrev d e) ==> rev (c # d) @ aa = qrev (c # d) aa");

val rst = rst0;

val _ = reset show_types;

val (rsts as (rst::_)) = Seq.list_of (RippleRTechn.startr_on_goal g rst);

val [rst1,rst2] = Seq.list_of (Seq.maps (fn dtac => RTechnEnv.apply_dtac_to_g dtac g rst) 
                                               (RippleCInfo.applicable_dtacseq_of rst g));
val [g2] = (RState.get_goalnames rst2);
val [rst2] = Seq.list_of (RippleCInfo.update g g2 rst2);
val _ = RippleCInfo.print rst g;
val _ = RippleCInfo.print rst2 g2;

val skelt = RstPP.goal_concl rst2 

val [(skeln,t1)] = PPlan.get_varified_lasm_nctrms (RState.get_pplan rst2) g2;
val t2 = RstPP.goal_concl rst2 g2;
val ectxt = 
  Embed.Ectxt.init (PPlan.get_ienv (RState.get_pplan rst2)) ParamRGraph.empty;

val _ = TermDbg.writeterm t1;
val _ = TermDbg.writeterm t2;

val t1_lhs = (((Const("L.append", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 ((Const("L.rev", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])]))) $
 (Free("d", Type("L.list", [TFree("'a", ["HOL.type"])]))))) $
 (Var( ("e",0), Type("L.list", [TFree("'a", ["HOL.type"])]))));

val t1_rhs = (((Const("L.qrev", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 (Free("d", Type("L.list", [TFree("'a", ["HOL.type"])])))) $
 (Var( ("e",0), Type("L.list", [TFree("'a", ["HOL.type"])]))));

val t2_lhs = (((Const("L.append", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 ((Const("L.rev", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])]))) $
 (((Const("L.list.Cons", Type("fun", [TFree("'a", ["HOL.type"]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 (Free("c", TFree("'a", ["HOL.type"])))) $
 (Free("d", Type("L.list", [TFree("'a", ["HOL.type"])])))))) $
 (Free("aa", Type("L.list", [TFree("'a", ["HOL.type"])]))));

val t2_rhs = (((Const("L.qrev", Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 (Free("d", Type("L.list", [TFree("'a", ["HOL.type"])])))) $
 (((Const("L.list.Cons", Type("fun", [TFree("'a", ["HOL.type"]), Type("fun", [Type("L.list", [TFree("'a", ["HOL.type"])]), Type("L.list", [TFree("'a", ["HOL.type"])])])]))) $
 (Free("c", TFree("'a", ["HOL.type"])))) $
 (Free("aa", Type("L.list", [TFree("'a", ["HOL.type"])])))));

val [e1] = Seq.list_of (Embed.embed ectxt t1_lhs t2_lhs);

val [e2] = Seq.list_of (Embed.embed (Embed.get_ectxt e1) t1_rhs t2_rhs);

in
val _ = writeln "Test completed: test/rippling_in.ML"
end;

(* val e2s = Seq.list_of (Embed.embed ectxt t1_rhs t2_rhs); *)

(* map Embed.print_ectxt_of e2s;

Embed.print_ectxt_of e1; *)

(* 
val (rsts as (rst::_)) = Seq.list_of (RippleRTechn.rsteps_on_goal g rst);
*)

(* 
RippleCInfo.applicable_dtacseq_of rst goal
RTechnEnv.apply_dtac_to_g dtac goal

PolyML.exception_trace (fn ()           );
*)
