(* simple test of proof representation *)
theory method_test                                           
imports       
  "../build/BIsaMeth"    
begin

ML{*

  val default_tacs = 
    [("atac",K atac), (* assumption *)
     ("simp",Simplifier.simp_tac o Simplifier.simpset_of), (* simp *) 
     ("clarsimp",clarsimp_tac), (* clarsimp *)
     ("all",K (K all_tac)), (* always succeeds *)
     ("no",K (K all_tac)) (* always fails *)
    ] 
    |> StrName.NTab.of_list;
*}

(* Pre-setup: some init for rippling *)
lemma rev_cons: "rev (x # xs) = rev xs @ [x]"
by auto
ML{*
  val thms = [("app_cons", @{thm "List.append_Cons"}), 
             ("rev_cons", @{thm "rev_cons"}), 
             ("List.append_assoc", @{thm "List.append_assoc"}),
             ("app_cons(sym)", Substset.mk_sym_thm @{thm "List.append_Cons"}), 
             ("rev_cons(sym)", Substset.mk_sym_thm @{thm "rev_cons"}), 
             ("List.append_assoc(sym)", Substset.mk_sym_thm @{thm "List.append_assoc"}),
             ("List.append_assoc(sym)", Substset.mk_sym_thm @{thm "List.append_assoc"}),
             ("Int_iff", @{thm "Int_iff"}),
              ("Int_iff(sym)", Substset.mk_sym_thm @{thm "Int_iff"})
             ];
  BasicRipple.init_wrule_db();
  BasicRipple.add_wrules thms;
*}

(*  Tactics and RTechns for Demo *)
ML{*
(* setup some basic tacs *)
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "assumption"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

   val intro = RTechn.id
            |> RTechn.set_name (RT.mk "rule impI | conjI")
            |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI","conjI"]));
   

(* setup simp tac *) 
  val (simp_tac : Proof.context -> int -> tactic) = 
    let
      val simps =  Simplifier.simpset_of (Proof_Context.init_global @{theory});
    in
      (fn _ => Simplifier.simp_tac simps) 
    end;
  val simp = RTechn.id
            |> RTechn.set_name (RT.mk "simp")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));

(* setup up fertlisation*)
  val (fert_tac : Proof.context -> int -> tactic) = 
    let val HOL_simps = Simplifier.simpset_of (Proof_Context.init_global @{theory "HOL"}) in 
    (fn _ => Simplifier.asm_simp_tac HOL_simps) end;
  val weak_fert = RTechn.id
            |> RTechn.set_name (RT.mk "weak_fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "weak_fert"));
  val strong_fert = RTechn.id
            |> RTechn.set_name (RT.mk "strong_fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "strong_fert"));

(* setup up induct *)
  val (induct_tac : Proof.context -> int -> tactic)  = fn _ => InductRTechn.induct_on_first_var_tac;
  val induct = RTechn.id
              |> RTechn.set_name (RT.mk "induct")
              |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "induct"));
 
(* setup up rippling *)
   val ripple_tac = BasicRipple.ripple_tac
   val rippling = RTechn.id
               |> RTechn.set_name (RT.mk "rippling")
               |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "rippling"));

  fun id_tac _ _ thm = Seq.single(thm);
  val fert_checker = RTechn.id
            |> RTechn.set_name (RT.mk "fert_checker")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "fert_checker"));

  val default_tacs = PSGraphMethod.default_tacs @
    [("assumption",K atac), ("simp",simp_tac), ("induct", induct_tac), 
      ("weak_fert",fert_tac), ("strong_fert", fert_tac), ("rippling", ripple_tac), ("fert_checker", id_tac)];
*}

(* Goal types *)
ML{*
  val gt = SimpleGoalTyp.default;
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  val gt_induct = "inductable";
  val gt_ripple = "hyp_embeds;measure_reduces";
  val gt_rippled = "not(measure_reduces);or(hyp_bck_res,hyp_subst)";
  val gt_weak_fert = "not(hyp_bck_res);hyp_subst;hyp_embeds"
  val gt_strong_fert = "hyp_bck_res;hyp_embeds"
  val gt_embeds = "hyp_embeds"
  val gt_not_embeds = "not(hyp_embeds)"
  val gt_hyps = "hyp_embeds"
*}

(* Tactic combinators *)
ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
*}

(* Setup psgraphs *)
ML{*
(* psgraph: asm only *)
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psgraph_asm = psasm PSGraph.empty |> PSGraph.load_atomics default_tacs;

(* psgraph: a simple psgraph containing only conjI, impI and asm*)
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psconjI0 THENG  psconjI THENG psimpI THENG psasm2;
  val psgraph_simple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;

(* psgraph: rippling *)
  val pssimp = PSComb.LIFT ([gt_not_embeds],[]) (simp);
  val psinduct =  PSComb.LIFT ([gt_induct],[gt_ripple,gt_not_embeds]) (induct);
  val psrippling' =  PSComb.LIFT ([gt_ripple, gt_ripple],[gt_rippled,gt_ripple]) (rippling);
  val psrippling = PSComb.LOOP_WITH psrippling' gt_ripple;

  val psfertchecer = PSComb.LIFT ([gt_rippled],[gt_weak_fert, gt_strong_fert]) (fert_checker);
  val psweakf = PSComb.LIFT ([gt_weak_fert],[gt_not_embeds]) (weak_fert);
  val psstrongf = PSComb.LIFT ([gt_strong_fert],[]) (strong_fert)
  val psfert = 
    psfertchecer THENG psweakf THENG psstrongf THENG pssimp
    |> PSComb.NEST "fertilisation"
    
  val psf = psrippling THENG psfert
  val psgraph_ripple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;

  val psf = psinduct THENG psrippling THENG pssimp THENG psfert
  val psgraph_induct_ripple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;

(* psgraph: nested *)
  val psintro = PSComb.LIFT ([gt],[gt]) (intro);
  val psasm = PSComb.LIFT ([gt],[]) (asm);
  val psfg3 = psintro THENG  psintro;
  val psfg4 = PSComb.NEST "intr_twice" psfg3;
  val psfg5 = psfg4 THENG psasm;
  val psgraph_nest = psfg5 PSGraph.empty |> PSGraph.load_atomics default_tacs;

*}

setup {* PSGraphMethod.add_graph ("asm",psgraph_asm) *}
setup {* PSGraphMethod.add_graph ("simple",psgraph_simple) *}
setup {* PSGraphMethod.add_graph ("rippling",psgraph_ripple) *}
setup {* PSGraphMethod.add_graph ("induct_ripple",psgraph_induct_ripple) *}
setup {* PSGraphMethod.add_graph ("hierarchical",psgraph_nest) *}

(* DEMO1: a extremely trivial example *)
  declare [[psgraph = asm]]
  lemma "A \<Longrightarrow> A" 
  (*apply (psgraph (interactive) )*)
  oops

(* DEMO2: a slightly life-like example *)
  declare [[psgraph = simple]]
  lemma "A \<Longrightarrow> (A \<and> A)  \<and> (A \<longrightarrow> A)"
  (*apply (ipsgraph simple)*)
  oops

(* DEMO3: induct and rippling *)
  declare [[psgraph = induct_ripple]]
  lemma "rev (l1 @ l2) = rev l2 @ rev l1"
  -apply (ipsgraph induct_ripple)
  oops

(* Demo 3.a : rippling with strong fert*)
  lemma "x : A ==> x : (A \<inter> A)"
  (*apply (psgraph (interactive) rippling)*)
  oops

(* Demo 4: hierarchical*)
  declare [[psgraph = hierarchical]]
  lemma "A \<longrightarrow> A \<and> A"
 (* apply ipsgraph*)
  oops
 
(* Demo 5: passsive mode *)
  lemma "A \<longrightarrow> (A \<and> A) " 
  (*apply (ipsgraph passive)*) 
  oops

end



