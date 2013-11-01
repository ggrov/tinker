theory debug_group_strategy
imports
  "../GroupAx"
  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
begin

ML{*
structure FGT = FullGoalTyp;
val gt = FGT.default

*}
-- "reasoning techniques"

ML{*
val asm = 
RTechn.id
|> RTechn.set_name (RT.mk "assumption")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));
*}

ML{*
val psasm = PSComb.LIFT ([gt],[]) (asm);
*}

ML{*
val psf =  psasm;
val psg_step = IsaMethod.init_psgraph psf @{context};
val psgraph_idstep = IsaMethod.apply_psgraph_tac psg_step;
*}

-- "Examples"
lemma "a ==> a "
ML_val {*
val st = #goal @{Isar.goal};
writeln (Proof_Display.string_of_goal @{context} st);
atac 1 st |> Seq.pull;
psgraph_idstep @{context} st |> Seq.pull
*}
apply (tactic "atac 1")
done



end
