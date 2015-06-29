theory ThyRippling                                          
imports BIsaMeth
begin

ML{*
(* setup simp tac *) 
  fun simp_tac (ctxt: Proof.context)  = 
    let
      val simps =  Simplifier.simpset_of ctxt;
    in
      (Simplifier.simp_tac simps) 
    end;
  val simp = RTechn.id
            |> RTechn.set_name (RT.mk "simp")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "simp"));

(* setup up fertlisation*)
  val (fert_tac : Proof.context -> int -> tactic) = 
    let val HOL_simps = Simplifier.simpset_of (Proof_Context.init_global @{theory "HOL"}) in 
    (fn _ => Simplifier.asm_simp_tac HOL_simps) end;

  fun  weak_fert_tac ctxt = 
    let val HOL_simps = Simplifier.simpset_of ctxt  in 
    (Simplifier.safe_asm_full_simp_tac HOL_simps ) end;

  val weak_fert = RTechn.id
            |> RTechn.set_name (RT.mk "weak_fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "weak_fert"));

  val strong_fert = RTechn.id
            |> RTechn.set_name (RT.mk "strong_fert")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "strong_fert"));

(* setup up induct *)
  val (induct_tac : Proof.context -> int -> tactic)  = 
    fn _ => InductRTechn.induct_tac(*InductRTechn.induct_on_nth_var_tac 1*);
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

  val default_tacs = 
    [("simp",simp_tac), ("induct", induct_tac), ("weak_fert", weak_fert_tac),
      ("strong_fert", fert_tac), ("rippling", ripple_tac), ("fert_checker", id_tac)];
*}


(* Goal types *)
ML{*
  val gt = SimpleGoalTyp.default;
  val gt_induct = "inductable";
  val gt_can_ripple = "hyp_embeds;measure_reducible";
  val gt_rippled = "not(measure_reducible);or(hyp_bck_res,hyp_subst)";
  val gt_weak_fert = "not(hyp_bck_res);hyp_subst;hyp_embeds"
  val gt_strong_fert = "hyp_bck_res;hyp_embeds"
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
(* psgraph: rippling *)
  val pssimp = PSComb.LIFT ([gt_not_embeds, gt],[]) (simp);
  val psinduct =  PSComb.LIFT ([gt_induct],[gt_can_ripple,gt_not_embeds]) (induct);
  val psrippling' =  PSComb.LIFT ([gt_can_ripple, gt_can_ripple],[gt_rippled,gt_can_ripple]) (rippling);
  val psrippling = PSComb.LOOP_WITH psrippling' gt_can_ripple;

  val psfertchecer = PSComb.LIFT ([gt_rippled],[gt_weak_fert, gt_strong_fert]) (fert_checker);
  val psweakf = PSComb.LIFT ([gt_weak_fert],[gt]) (weak_fert);
  val psstrongf = PSComb.LIFT ([gt_strong_fert],[]) (strong_fert)
  val psfert = 
    psfertchecer THENG psweakf THENG psstrongf
    |> PSComb.NEST "fertilisation"
    
  val psf = psinduct THENG psrippling THENG psfert THENG pssimp 
  val psgraph_induct_ripple = psf PSGraph.empty |> PSGraph.load_atomics default_tacs;

*}
lemma test: "l = l@ []" by auto;
ML{*
Thm.derivation_name @{thm "test"};
*}
(* setup wrule attribute *)
attribute_setup wrule = {* Attrib.add_del wrule_add wrule_del *} "maintaining a list of wrules"

setup {* PSGraphMethod.add_graph ("induct_ripple",psgraph_induct_ripple) *}
declare [[psgraph = induct_ripple]]

end



