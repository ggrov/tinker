(* simple test of proof representation *)
theory demo1                                           
imports       
  "../../provers/basic_isabelle/build/BIsaMeth"    
begin









(*  Tactics and RTechns for Demo *)
ML{*
(* setup some basic tacs *)
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

*}

(* Goal types *)
ML{*
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_nimp = "not(top_symbol(HOL.implies))";

*}

(* Tactic combinators *)
ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
*}

(* Setup psgraphs *)
ML{*

  val ps_imp = PSComb.LIFT ([gt_imp,gt_imp],[gt_imp,gt_nimp]) impI;
  val ps_imp_while = PSComb.LOOP_WITH ps_imp gt_imp;
  val ps_asm = PSComb.LIFT ([gt_nimp],[]) asm;
  val ps_imp_asmf = ps_imp_while THENG ps_asm;
  val ps_imp_asm = PSGraph.empty
                 |> ps_imp_asmf
                 |> PSGraph.load_atomics [("atac",K atac)];
 
*}

setup {* PSGraphMethod.add_graph ("ps",ps_imp_asm) *}

setup {* PSGraphMethod.read_graph ("test","/Users/ggrov/test.psgraph") *}  


  (* todo: one with branching? *)

  lemma "A \<longrightarrow> A \<longrightarrow> A "
  - apply (ipsgraph test) 
  oops

end



