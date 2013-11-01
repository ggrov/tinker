theory assm_test
imports
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
begin

(* Test file - failure of assumption tactics *)



ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val LIFT = PSComb.LIFT;
*}


-- "Goal types"

ML{*
  val gt = FullGoalTyp.default 
*}


-- "Reasoning techniques"

ML{*
val asm = 
RTechn.id
|> RTechn.set_name (RT.mk "assumption")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));
*}


-- "Strategies"

  (* Assumption only *)
ML{*
val ps_asm = LIFT ([gt],[]) (asm)
val psg_asm = IsaMethod.init_psgraph ps_asm @{context};
val psgraph_asm = IsaMethod.apply_psgraph_tac psg_asm;
*}

lemma "A \<Longrightarrow> A"
  apply (tactic "psgraph_asm @{context}")
oops

ML{*
val [edata] = EVal.init psg_asm @{context} @{prop "A \<Longrightarrow> A"};
*}



end
