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
psgraph_idstep @{context} st |> Seq.pull;
*}

(* just applying tactic works! *)
ML_val{*
val st = #goal @{Isar.goal};
val [edata] = IsaMethod.init_thm @{context} st psg_step ;
val t = EData.get_tactic edata "atac";
t @{context} st |> Seq.pull;
*}

apply (tactic "atac 1")
done

ML{*
val [edata] =  IsaMethod.init psasm @{context} @{prop "A ==> A"};
EVal.debug_get_appf_gnode edata;
EVal.debug_apply_appf edata;
*}

(* problem seems to be solves now -- was in prover (it uses get_all_assms and
not get_all_facts - was set to return [] so no fact to use! *)
ML{*
val pnode = EData.get_goal edata "g";
PNode.get_all_assms pnode;
 IsaProver.get_all_assms pnode;
val pplan = EData.get_pplan edata;
val tac = EData.get_tactic edata "assumption";
val facts = IsaProver.get_all_assms pnode;
IsaProver.apply_tactic "assumption" facts tac (pnode,pplan) |> Seq.list_of;
*}


lemma assumes a:"A" shows "A"
(* appling on pplan level seems to work *)
ML_val{*
val st = #goal @{Isar.goal};
val [edata] = IsaMethod.init_thm @{context} st psg_step ;
val t = EData.get_tactic edata "atac";
val pp = EData.get_pplan edata;

val (SOME g) = PPlan.lookup_node pp "h";
val [t] = (IsaProver.apply_tactic "bla" [@{thm "a"}] t) (g,pp) |> Seq.list_of;
t;
*}

ML_val{*
val st = #goal @{Isar.goal};
val [edata] = IsaMethod.init_thm @{context} st psg_step ;
EVal.debug_get_appf_gnode edata;
EVal.debug_apply_appf edata;
val pnode = EData.get_goal edata "h";
val pplan = EData.get_pplan edata;
val tac = EData.get_tactic edata "assumption";
val facts = IsaProver.get_all_assms pnode;
IsaProver.apply_tactic "assumption" facts tac (pnode,pplan);
*}
apply (rule a)
done


end
