theory StratGraphs
imports 
  "../../provers/basic_isabelle/build/BIsaMeth" 
begin

ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  val gt_true = "top_symbol(HOL.Trueprop)";
  val gt_imp_e = "top_symbol(HOL.implies)";
  val gt_not = "top_symbol(HOL.Not)";
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

  val TrueI = RTechn.id
          |> RTechn.set_name (RT.mk "rule TrueI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["TrueI"]));

  val impE = RTechn.id
          |> RTechn.set_name (RT.mk "erule impE")
          |> RTechn.set_atomic_appf (RTechn.ERule (StrName.NSet.of_list ["impE"]));

  val notI = RTechn.id
          |> RTechn.set_name (RT.mk "rule notI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["notI"]));

  val notE = RTechn.id
          |> RTechn.set_name (RT.mk "erule notE")
          |> RTechn.set_atomic_appf (RTechn.ERule (StrName.NSet.of_list ["notE"]));
*}

ML{*
(* psgraph: asm only *)
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psgraph_asm = psasm PSGraph.empty |> PSGraph.load_atomics [("assumption",K atac)];

(* psgraph: a simple psgraph containing only conjI, impI and asm*)
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psconjI0 THENG psconjI THENG psimpI THENG psasm2;
  val psgraph_simple = psf PSGraph.empty  |> PSGraph.load_atomics [("assumption",K atac)];
*}

ML{*
(* psgraph: psgraph containing conjI and TrueI *)
  val psconjt = PSComb.LIFT ([gt_conj],[gt_true]) (conjI);
  val pstrue = PSComb.LIFT ([gt_true],[]) (TrueI);
  val psf = psconjI THENG pstrue THENG pstrue;
  val psgraph_true = psf PSGraph.empty |> PSGraph.load_atomics [("assumption",K atac)];
*}

ML{*
(* psgraph: imp I/E and asm *)
  val psimpI1 = PSComb.LIFT ([gt_imp],[gt_imp]) (impI);
  val psimpI2 = PSComb.LIFT ([gt_imp],[gt_imp_e]) (impI);
  val psimpE1 = PSComb.LIFT ([gt_imp_e],[gt,gt_imp_e]) (impE);
  val psimpE2 = PSComb.LIFT ([gt_imp_e],[gt]) (impE);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psimpI1 THENG psimpI1 THENG psimpE1 THENG psasm THENG psimpE2 THENG psasm;
  val psgraph_impI_impE = psf PSGraph.empty |> PSGraph.load_atomics [("assumption", K atac)];
*}

ML{*
(* psgraph: graph containing impI, notI/E, asm*)
  val psimpI = PSComb.LIFT ([gt_imp],[gt_not]) (impI);
  val psnotI = PSComb.LIFT ([gt_not],[gt_not]) (notI);
  val psnotE = PSComb.LIFT ([gt_not],[gt,gt]) (notE);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psf = psimpI THENG psnotI THENG psnotE THENG psasm1;
  val psgraph_not = psf PSGraph.empty |> PSGraph.load_atomics [("assumption",K atac)];
*}

ML{*
(* psgraph: impI and asm *)
  val psimpI0 = PSComb.LIFT ([gt_imp],[gt_imp]) (impI);
  val psimpI1 = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psf = psimpI0 THENG psimpI1 THENG psasm;
  val psgraph_imp_asm = psf PSGraph.empty |> PSGraph.load_atomics [("assumption",K atac)];
*}


setup {* PSGraphMethod.add_graph ("asm",psgraph_asm) *}
setup {* PSGraphMethod.add_graph ("conj_impI",psgraph_simple) *}
setup {* PSGraphMethod.add_graph ("trueI",psgraph_true) *}
setup {* PSGraphMethod.add_graph ("notI",psgraph_not) *}
setup {* PSGraphMethod.add_graph ("impI_impE",psgraph_impI_impE) *}
setup {* PSGraphMethod.add_graph ("imp_asm",psgraph_imp_asm) *}
end
