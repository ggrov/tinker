theory autostrat
imports
(*  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
  "../../../provers/isabelle/full/build/Parse" *)
   "../../../provers/isabelle/basic/build/BIsaMeth" 
begin
(*
ML_file "../../../../../../src/Provers/clasimp.ML"
*)
ML_file "AutoTacs.ML"  


declare [[simp_trace]]

ML{*
structure SGT = SimpleGoalTyp
(* structure FGT = FullGoalTyp; 
structure GTD = GoalTypData;*)
*}

-- "path to write graphs to"
ML{*
val path = "/home/colin/Documents/phdwork/graphs/autotesting/"
*}

--"Goal Type"

(*Need to update with names if using simple types*)

ML{*
val gt = SGT.default

(* val gt_full = FGT.default *)
*}

--"Tactic Setup"

(*Use these to register tactics - need to update*)

ML{*
val (simp_tac : Proof.context -> int -> tactic) =
     fn ctxt => Simplifier.asm_full_simp_tac (simpset_of ctxt)
*}

setup {*PSGraphMethod.add_tac ("simplifier",simp_tac)*}

ML{*
val (depth_tac : Proof.context -> int -> tactic) =
    fn _ => Blast.depth_tac @{context} 4
*}

setup {*PSGraphMethod.add_tac ("blast_depth",depth_tac)*}

ML{*
val (nodup_tac : Proof.context -> int -> tactic) =
    fn _ => AInt.nodup_depth_tac (addss @{context}) 2
*}

setup {*PSGraphMethod.add_tac ("nodup_tac", nodup_tac)*}

ML{*
safe_tac;
val (safe_tac1 : Proof.context -> int -> tactic) = 
  fn ctxt => fn _ => safe_tac ctxt
*}

setup {*PSGraphMethod.add_tac ("safe_tac", (fn ctxt => fn _ => safe_tac ctxt))*}



ML{*
val (prune_tac : Proof.context -> int -> tactic) =
    fn ctxt =>  fn _ => prune_params_tac
*}

setup {*PSGraphMethod.add_tac ("prune_tac", prune_tac)*}


--"Reasoning Techniques"
ML{*
val simp =
RTechn.id
|> RTechn.set_name (RT.mk "simplifier")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simplifier"));

val safe = 
RTechn.id
|> RTechn.set_name (RT.mk "safe_tac")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "safe_tac"))

val blast = 
RTechn.id
|> RTechn.set_name (RT.mk "blast")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "blast_depth"))

val nodup =
RTechn.id
|> RTechn.set_name (RT.mk "nodup_depth_tac")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "nodup_tac"))

val prune =
RTechn.id
|> RTechn.set_name (RT.mk "prune_params_tac")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "prune_tac"))
*}

--"Strategy Graphs"

ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val NEST = PSComb.NEST;
 val LOOP = PSComb.LOOP_WITH;
 val LIFT = PSComb.LIFT;
 infixr 5 ORELSE;
 val op ORELSE = PSComb.ORELSE;
*}

ML{*
val pssimp = LIFT ([gt],[gt,gt]) (simp);
val pssafe = LIFT ([gt],[gt]) (safe)
val psblast = LIFT ([gt,gt],[gt,gt]) (blast)
val psndt = LIFT ([gt,gt],[gt,gt]) (nodup)
val psmain = psblast ORELSE psndt
val psprune = LIFT ([gt,gt],[]) (prune)

val psf_auto = pssimp THENG pssafe THENG psmain THENG pssafe THENG psprune;

val psg_auto =   psf_auto PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));

val psg_simp =   pssimp PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
 

(*val psg_auto = IsaMethod.init_psgraph psf_auto @{context};
val psgraph_auto = IsaMethod.apply_psgraph_tac psg_auto;*)
*}

setup {* PSGraphMethod.add_graph ("psgraph_auto",psg_auto) *}
setup {* PSGraphMethod.add_graph ("psgraph_simp",psg_simp) *}

--"Examples"

ML{*
val [edata] = EVal.init psg_auto @{context} @{prop "A \<longrightarrow> A"};
*}
(*
ML{*
eval_interactive 
*}

ML{*
EData.get_pplan edata ;
*}
*)


lemma a: "A \<longrightarrow> A"
  apply (psgraph  psgraph_auto) 
done

lemma a1: "A \<longrightarrow> A"
 apply (tactic {* Simplifier.asm_full_simp_tac (simpset_of @{context}) 1 *})
 (* 
  apply (psgraph (interactive)  psgraph_auto)
*)
oops




lemma b: "A \<and> B \<longrightarrow> B \<and> A"
  apply auto
done

lemma b1: "A \<and> B \<longrightarrow> B \<and> A"
  apply (tactic "psgraph_auto @{context}")
oops

end
