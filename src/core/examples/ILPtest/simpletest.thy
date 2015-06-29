theory simpletest
imports "../../provers/basic_isabelle/build/BIsaMeth"
begin

-- "basic definitions"
ML{*
  infixr 6 THENG;
  infix 5 TENSOR;
  val op THENG = PSComb.THENG;
  val op TENSOR = PSComb.TENSOR;
  val LIFT = PSComb.LIFT;
  val gt = SimpleGoalTyp.default;

  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));
*}

-- "simple version: no goal types"
ML{*
val psgraphfn1 =
  (LIFT ([gt],[gt,gt]) RTechn.id)
  THENG
    ((LIFT ([gt],[gt]) impI)
    TENSOR
    (LIFT ([gt],[gt]) conjI))
  THENG
  (LIFT ([gt,gt],[]) asm);
val psgraphfn2 =
  (LIFT (["G1"],["G2","G3"]) RTechn.id)
  THENG
    ((LIFT (["G2"],["G4"]) impI)
    TENSOR
    (LIFT (["G3"],["G5"]) conjI))
  THENG
  (LIFT (["G4","G5"],[]) asm);
val psgraphfn3 =
  (LIFT (["top_level(conj) or top_level(imp)"],["top_level(conj)","top_level(imp)"]) RTechn.id)
  THENG
    ((LIFT (["top_level(imp)"],["any"]) impI)
    TENSOR
    (LIFT (["top_level(conj)"],["any"]) conjI))
  THENG
  (LIFT (["any","any"],[]) asm);
val psgraph1 = psgraphfn3 PSGraph.empty;
val graph1 = PSGraph.get_graph psgraph1;

 PSGraph.PSTheory.write_dot "/Users/ggrov/simple1.dot" graph1

*}



ML{*
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";


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
*}

setup {* PSGraphMethod.add_graph ("asm",psgraph_asm) *}
setup {* PSGraphMethod.add_graph ("conj_impI",psgraph_simple) *}  

end
