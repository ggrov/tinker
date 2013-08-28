theory example_def
imports   "../../provers/basic_isabelle/build/BIsaMeth"  
begin

ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

(* psgraph: asm only *)
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psgraph_asm = psasm PSGraph.empty |> PSGraph.load_atomics [("assumption",K atac)];

(* psgraph: a simple psgraph containing only conjI, impI and asm*)
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psconjI0 THENG  psconjI THENG psimpI THENG psasm2;
  val psgraph_simple = psf PSGraph.empty  |> PSGraph.load_atomics [("assumption",K atac)];

  val psconjI0 =  PSComb.LIFT ([gt_conj],["not top_symbol(HOL.implies)", gt_imp]) (conjI);
  val passm1 =  PSComb.LIFT (["not top_symbol(HOL.implies)"], [gt]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psconjI0  THENG psimpI THENG passm1 THENG psasm2;
val psgraph_test =  psf PSGraph.empty  |> PSGraph.load_atomics [("assumption",K atac)];
*}

setup {* PSGraphMethod.add_graph ("asm",psgraph_asm) *}
setup {* PSGraphMethod.add_graph ("conj_impI",psgraph_simple) *}
setup {* PSGraphMethod.add_graph ("test",psgraph_test) *}

ML{*
val path = "/Users/yuhuilin/Desktop/";
val edata0 = EVal.init psgraph_test @{context} @{prop "A \<Longrightarrow> (A)  \<and> (A \<longrightarrow> A)"} |> hd;
PSGraph.PSTheory.write_dot (path^"test1.dot") (EData.get_graph edata0)  ;

val edata0 = EVal.init psgraph_simple @{context} @{prop "A \<Longrightarrow> (A & A)  \<and> (A \<longrightarrow> A)"} |> hd;
PSGraph.PSTheory.write_dot (path^"test1.dot") (EData.get_graph edata0)  ;
EData.get_evalf edata0;
val edata0 = EData.set_evalf "depth_first" edata0;
"depth_first";
*}

ML{*
val (EVal.Cont edata1) = EVal.evaluate_arbitrary edata0;
val edata1 = EVal.normalise_gnode edata1;
PSGraph.PSTheory.write_dot (path^"test2.dot") (EData.get_graph edata1) 
*}

ML{*  
val (EVal.Cont edata2) = EVal.evaluate_arbitrary edata1;
val edata2 = EVal.normalise_gnode edata2;
PSGraph.PSTheory.write_dot (path^"test3.dot") (EData.get_graph edata2) 
*}


ML{*
val (EVal.Cont edata3) = EVal.evaluate_arbitrary edata2;
val edata3 = EVal.normalise_gnode edata3;
PSGraph.PSTheory.write_dot (path^"test4.dot") (EData.get_graph edata3) 
*}

ML{*
val s = Seq.of_list [1,2,3,4];
fun addOne i = i + 1 |> (fn x => (writeln ("get result: " ^ (Int.toString(i+1))); x));
Seq.map addOne s |> Seq.pull |>( fn (SOME x) => x) |> snd |> Seq.pull;

fun add a b = a + b;
fold;
List.foldr
*}

ML{*
EVal.EGraph.mk_lhs;
EVal.EGraph.matched_lhs;
EVal.eval_atomic;
EVal.pick_first_branch;
EVal.update_branches;
EVal.evaluate_arbitrary;
EVal.evaluate_any;
EVal.evaluate_full_one;

EVal.mk_atomic_rhs;
EVal.EGraph.normalise_gnode;
Seq.pull;
structure x= EVal.EGraph.Util;
*}

end
