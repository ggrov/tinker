theory autostrat
imports
(*  "../../../build/isabelle/Eval"
  "../../../provers/isabelle/full/build/IsaP"
  "../../../provers/isabelle/full/build/Parse" *)
   "../../../provers/isabelle/basic/build/BIsaMeth" 
   "../GroupAx"
   "../grouporder"
begin
(*
ML_file "../../../../../../src/Provers/clasimp.ML"
*)
ML_file "AutoTacs.ML"  




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
val gt = SGT.default;
val gt_safe = "label (use_safe)";
val gt_blast = "label (use_blast)";
val gt_depth = "label (use_depth)";
val gt_prune = "label (use_prune)";

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
    fn ctxt => Blast.depth_tac ctxt 4
*}

setup {*PSGraphMethod.add_tac ("blast_depth",depth_tac)*}

ML{*
val (nodup_tac : Proof.context -> int -> tactic) =
    fn ctxt => AInt.nodup_depth_tac (addss ctxt) 2
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
 val TENSOR = PSComb.TENSOR;
 infixr 5 OR;
 val op OR = PSComb.OR;
 infixr 5 ORELSE;
 val op ORELSE = PSComb.ORELSE;
*}

ML{*
val pssimp = LIFT ([gt],[gt_safe,gt_blast,gt_depth]) (simp);
val pssafe = LIFT ([gt_safe],[gt_blast,gt_depth]) (safe);
val psblast = LIFT ([gt_blast,gt_blast],[]) (blast);
val psndt = LIFT ([gt_depth,gt_depth],[gt_safe,gt_prune]) (nodup);
val pssafe2 = LIFT ([gt_safe],[gt_prune]) (safe);
val psprune = LIFT ([gt_prune,gt_prune],[gt]) (prune);
*}

ML{*
val psf_auto = pssimp THENG pssafe THENG psblast THENG psndt THENG pssafe2 THENG psprune;

val psg_auto =   psf_auto PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}


ML{*
val psf_tenstest = TENSOR (psblast, psndt);

val psg_tenstest = psf_tenstest PSGraph.empty
    |>  PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));

*}

ML{*
(*val psg_auto = IsaMethod.init_psgraph psf_auto @{context};
val psgraph_auto = IsaMethod.apply_psgraph_tac psg_auto;*)
*}

setup {* PSGraphMethod.add_graph ("psgraph_auto",psg_auto) *}
setup {* PSGraphMethod.add_graph ("psgraph_tens",psg_tenstest) *}

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
  apply (psgraph psgraph_auto) 
done


lemma b: "A \<and> B \<longrightarrow> B \<and> A"
  apply (psgraph  psgraph_auto)
done



ML{*
val inv_rev =
RTechn.id
|> RTechn.set_name (RT.mk "subst inv_rev")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["inv_rev"]));

val ax3s =
RTechn.id
|> RTechn.set_name (RT.mk "subst ax3s")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["ax3s"]));
*}

ML{*
val psinv = LIFT ([gt],[gt]) (inv_rev);
val psax3s = LIFT ([gt],[gt]) (ax3s);
*}

ML{*
val psf_autoext = psinv THENG psax3s THENG psf_auto;

val psg_autoext =   psf_autoext PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}

setup {* PSGraphMethod.add_graph ("psgraph_autoext",psg_autoext) *}


lemma inv_comm_alt: "a ** inv a = inv a ** a"
  apply (psgraph psgraph_autoext)
done





ML{*
val (induct_tac : Proof.context -> int -> tactic) = 
  fn _ => InductRTechn.induct_tac;
*}

setup {* PSGraphMethod.add_tac ("induct",induct_tac) *}


ML{*
val induct =
RTechn.id
|> RTechn.set_name (RT.mk "induct")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "induct"));

val id_rev =
RTechn.id
|> RTechn.set_name (RT.mk "subst id_rev")
|> RTechn.set_atomic_appf (RTechn.Subst (StrName.NSet.of_list ["id_rev"]));
*}

ML{*
val psinduct = LIFT ([gt],[gt,gt]) (induct);
val psidrev = LIFT ([gt],[gt]) (id_rev);

val psf_inductauto = psinduct THENG psf_auto THENG psidrev THENG psf_auto;

val psg_inductauto  =   psf_inductauto PSGraph.empty 
      |> PSGraph.load_atomics (StrName.NTab.list_of (PSGraphMethod.get_tacs @{theory}));
*}

setup {* PSGraphMethod.add_graph ("psgraph_inductauto",psg_inductauto) *}

lemma gexp_id: "gexp e n = e"        
  apply (psgraph  psgraph_inductauto)
  apply (induct n)                    
  apply auto
  apply (subst id_rev)                   
  apply auto
  done    


(*lemma c: "f x = u \<Longrightarrow> (\<forall> x. P x g \<Longrightarrow> g (f x) = x) \<Longrightarrow> P x \<Longrightarrow> x = g u"
apply (psgraph psgraph_auto)
oops
*)
end
