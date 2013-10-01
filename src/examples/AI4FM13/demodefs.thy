theory demodefs                                          
imports       
  "../../provers/isabelle/basic/build/BIsaMeth"    
begin

lemma rev_cons: "rev (x # xs) = rev xs @ [x]"
by auto

ML{*
  val thms = [("app_cons", @{thm "List.append_Cons"}), 
             ("rev_cons", @{thm "rev_cons"}), 
             ("List.append_assoc", @{thm "List.append_assoc"}),
             ("app_cons(sym)", Substset.mk_sym_thm @{thm "List.append_Cons"}), 
             ("rev_cons(sym)", Substset.mk_sym_thm @{thm "rev_cons"}), 
             ("List.append_assoc(sym)", Substset.mk_sym_thm @{thm "List.append_assoc"})
             ];
  BasicRipple.init_wrule_db();
  BasicRipple.add_wrules thms;
*}

(*  Tactics and RTechns for Demo *)
ML{*
(* setup some basic tacs *)
  val asm = RTechn.id
            |> RTechn.set_name (RT.mk "assumption")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "atac"));

  val conjI = RTechn.id
          |> RTechn.set_name (RT.mk "rule conjI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["conjI"]));
  
  val impI = RTechn.id
          |> RTechn.set_name (RT.mk "rule impI")
          |> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["impI"]));

   val split = RTechn.id
           |> RTechn.set_name (RT.mk "split");

   val merge = RTechn.id
           |> RTechn.set_name (RT.mk "merge");


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
  val fert = RTechn.id
            |> RTechn.set_name (RT.mk "fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "fert"));

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

  val default_tacs = 
    [("atac",K atac), ("simp",simp_tac), ("induct", induct_tac), 
      ("fert",fert_tac), ("rippling", ripple_tac)];
*}

(* Goal types *)
ML{*
  val gt = SimpleGoalTyp.default;
  val gt_intro = "top_symbol(HOL.implies,HOL.conj)";
  val gt_nintro = "not(top_symbol(HOL.implies,HOL.conj))"
  val gt_imp = "top_symbol(HOL.implies)";
  val gt_conj = "top_symbol(HOL.conj)";
  val gt_induct = "inductable";
  val gt_ripple = "rippling";
  val gt_rippled = "rippled"
  val gt_not_embeds = "not(hyp_embeds)"
  val gt_hyps = "hyp_embeds"
*}

(* Tactic combinators *)
ML{*
  infixr 6 THENG;
  val op THENG = PSComb.THENG;
  infixr 6 TENSOR;
  val op TENSOR = PSComb.TENSOR;
*}

(* intro *)
ML{*
  val pssplit =  PSComb.LIFT ([gt_intro,gt_intro],[gt_conj, gt_imp]) split;
  val psconjI = PSComb.LIFT ([gt_conj],[gt_nintro,gt_intro]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt_nintro,gt_intro]) (impI); 
  val psmerge1 = PSComb.LIFT ([gt_intro,gt_intro],[gt_intro]) (merge); 
  val psmerge2 = PSComb.LIFT ([gt_nintro,gt_nintro],[gt_nintro]) (merge); 

  val intro' = pssplit THENG (psconjI TENSOR psimpI) THENG (psmerge1 TENSOR psmerge2);
  val intro'' = PSComb.LOOP_WITH intro' gt_intro;
  val intro = intro'' PSGraph.empty |> PSGraph.load_atomics default_tacs
*}

(* Setup psgraphs *)
ML{*
(* psgraph: a simple psgraph containing only conjI, impI and asm*)
  val psconjI0 =  PSComb.LIFT ([gt_conj],[gt_conj, gt_imp]) (conjI);
  val psconjI = PSComb.LIFT ([gt_conj],[gt]) (conjI);
  val psimpI = PSComb.LIFT ([gt_imp],[gt]) (impI);
  val psasm1 = PSComb.LIFT ([gt],[]) (asm);
  val psasm2 = PSComb.LIFT ([gt,gt],[]) (asm);
  val psf = psconjI0 THENG  psconjI THENG psimpI THENG psasm2;
  val psgraph_simple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;

*}

ML{*
(* psgraph: rippling *)
  val pssimp = PSComb.LIFT ([gt_not_embeds],[]) (simp);
  val psfert = PSComb.LIFT ([gt_rippled],[]) (fert);
  val psinduct =  PSComb.LIFT ([gt_induct],[gt_ripple,gt_not_embeds]) (induct);
  val psrippling' =  PSComb.LIFT ([gt_ripple, gt_ripple],[gt_rippled,gt_ripple]) (rippling);
  val psrippling = PSComb.LOOP_WITH psrippling' gt_ripple;
  val psf = psinduct THENG psrippling THENG psfert THENG pssimp
  val psgraph_ripple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;
*}

setup {* PSGraphMethod.add_graph ("intro",intro) *}
setup {* PSGraphMethod.add_graph ("induct_ripple",psgraph_ripple) *}

end



