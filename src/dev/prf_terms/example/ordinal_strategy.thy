theory ordinal_strategy
imports
    "../../../build/isabelle/Eval"
    "../../../provers/isabelle/full/build/IsaP"
    "../../../provers/isabelle//full/build/Parse"
    "../../../../../../src/HOL/Ordinal/OrdinalRec"
begin

(* Examples of strategies built to evaluate some of the proofs found in the 
"Countable Ordinals" entry of the AFP. *)

ML_val{* proofs := 2 *}

ML{*
structure FGT = FullGoalTyp;
structure GTD = GoalTypData;
*}

-- "path to write graphs to"
ML{*
val path = "/home/colin/Documents/phdwork/graphs/ordinals/"
*}

-- "Goal Types"
ML{*
  val gt = FGT.default;

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ < _ + _) = (_ < _ \<or> _ < _)"]] Class.top
                |> Class.rename (C.mk "goal_init");
  val gt_init = FGT.set_gclass goalclass FGT.default
              |> FGT.set_name (G.mk "initial goal");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ < _ \<Longrightarrow> _ < _"]] Class.top
                |> Class.rename (C.mk "goal_ineq");
  val gt_ineq = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "inequality");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ + 0 \<le> _"]] Class.top
                |> Class.rename (C.mk "goal_plus0L");
  val gt_zeroL = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "+0 on LHS");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ \<le> _"]] Class.top
                |> Class.rename (C.mk "goal_refl");
  val gt_refl = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "LHS = RHS");

  val goalclass = Class.add_item (SStrName.mk "has_symbols") [[GTD.String "_ \<le> _ + _"]] Class.top
                |> Class.rename (C.mk "goal_plusR");
  val gt_plusR = FGT.set_gclass goalclass FGT.default
                |> FGT.set_name (G.mk "+ on RHS");

*}
-- "Reasoning Techniques"
ML{*
val safe =
RTechn.id
|> RTechn.set_name (RT.mk "safe")
|> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, "safe"));

val erule_set = 
RTechn.id
|> RTechn.set_name (RT.mk "erule application")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["order_less_le_trans"]));

val subst_set = 
RTechn.id
|> RTechn.set_name (RT.mk "subst application")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["ordinal_plus_0"]))

val rule_set =
RTechn.id
|> RTechn.set_name (RT.mk "rule application")
|> RTechn.set_atomic_appf (RTechn.Rule (StrName.NSet.of_list ["order_refl","ordinal_le_plusL",
                                         "ordinal_le_plusR"]))

*}

-- "Strategies"
ML{*
 infixr 6 THENG;
 val op THENG = PSComb.THENG;
 val NEST = PSComb.NEST;
 val LOOP = PSComb.LOOP_WITH;
 val LIFT = PSComb.LIFT;
 val op OR = PSComb.OR;
*}

ML{*
val ps_init = LIFT ([gt_init],[gt_ineq]) (safe);
val ps_erules = LIFT ([gt_ineq],[gt_zeroL, gt_plusR])(erule_set);
val ps_substs = LIFT ([gt_zeroL],[gt_refl]) (subst_set);
val ps_rules = LIFT ([gt_plusR, gt_refl],[]) (rule_set);

val psf_plusnot = ps_init THENG ps_erules THENG ps_substs THENG ps_rules;
val psg_plusnot = IsaMethod.init_psgraph psf_plusnot @{context};
val psgraph_plusnot = IsaMethod.apply_psgraph_tac psg_plusnot;
*}


-- "Test Examples"

instantiation ordinal :: plus
begin

definition
  "op + = (\<lambda>x. ordinal_rec x (\<lambda>p. oSuc))"

instance ..

end

lemma normal_plus: "normal (op + x)"
  apply (simp add: plus_ordinal_def)
  apply (simp add: normal_ordinal_rec)
done

lemma ordinal_plus_0 [simp]: "x + 0 = (x::ordinal)"
  apply (simp add: plus_ordinal_def)
done

lemma ordinal_plus_oSuc [simp]: "x + oSuc y = oSuc (x + y)"
  apply (simp add: plus_ordinal_def)
done

lemma ordinal_plus_oLimit [simp]: "x + oLimit f = oLimit (\<lambda>n. x + f n)"
by (simp add: normal.oLimit normal_plus)

lemma ordinal_0_plus [simp]: "0 + x = (x::ordinal)"
  apply (rule_tac a=x in oLimit_induct)
  apply (rule ordinal_plus_0)
  apply (subst ordinal_plus_oSuc)
  apply (simp_all)
done

lemma ordinal_plus_assoc:
"(x + y) + z = x + (y + z::ordinal)"
  apply (rule_tac a=z in oLimit_induct)
  apply (subst ordinal_plus_0)+
  apply (rule refl)
  apply (subst ordinal_plus_oSuc)+
  apply (simp_all)
done

lemma ordinal_plus_monoL [rule_format]:
"\<forall>x x'. x \<le> x' \<longrightarrow> x + y \<le> x' + (y::ordinal)"
 apply (rule_tac a=y in oLimit_induct)
 apply (subst ordinal_plus_0)+
 apply (simp_all)
 apply clarify
 apply (rule oLimit_leI, clarify)
 apply (rule_tac n=n in le_oLimitI)
 apply simp
done

lemma ordinal_plus_monoR: "y \<le> y' \<Longrightarrow> x + y \<le> x + (y'::ordinal)"
  apply (rule normal.monoD[OF normal_plus])
  apply assumption
done


lemma ordinal_plus_mono:
"\<lbrakk>x \<le> x'; y \<le> y'\<rbrakk> \<Longrightarrow> x + y \<le> x' + (y'::ordinal)"
  apply (rule order_trans[OF ordinal_plus_monoL ordinal_plus_monoR])
  apply assumption+
done


lemma ordinal_plus_strict_monoR: "y < y' \<Longrightarrow> x + y < x + (y'::ordinal)"
  apply (rule normal.strict_monoD[OF normal_plus])
  apply assumption
done

lemma ordinal_le_plusL [simp]: "y \<le> x + (y::ordinal)"
  apply (cut_tac ordinal_plus_monoL[OF ordinal_0_le])
  apply simp
done

lemma ordinal_le_plusR [simp]: "x \<le> x + (y::ordinal)"
  apply (cut_tac ordinal_plus_monoR[OF ordinal_0_le])
  apply simp
done

lemma ordinal_less_plusR: "0 < y \<Longrightarrow> x < x + (y::ordinal)"
  apply (drule_tac ordinal_plus_strict_monoR)
  apply simp
done

lemma ordinal_plus_left_cancel [simp]:
"(w + x = w + y) = (x = (y::ordinal))"
  apply (rule normal.cancel_eq[OF normal_plus])
done

lemma ordinal_plus_left_cancel_le [simp]:
"(w + x \<le> w + y) = (x \<le> (y::ordinal))"
  apply (rule normal.cancel_le[OF normal_plus])
done

lemma ordinal_plus_left_cancel_less [simp]:
"(w + x < w + y) = (x < (y::ordinal))"
  apply (rule normal.cancel_less[OF normal_plus])
done

lemma ordinal_plus_not_0: "(0 < x + y) = (0 < x \<or> 0 < (y::ordinal))"
  apply safe
  apply (erule order_less_le_trans)
  apply (subst ordinal_plus_0)
  apply (rule order_refl)
  apply (erule order_less_le_trans)
  apply (rule ordinal_le_plusR)
  apply (erule order_less_le_trans)
  apply (rule ordinal_le_plusL)
done

ML{*
val [edata] = EVal.init psg_plusnot @{context} @{prop "(0 < x + y) = (0 < x \<or> 0 < y)"};
*}

ML{*
eval_interactive
*}


lemma not_inject: "(\<not> P) = (\<not> Q) \<Longrightarrow> P = Q"
by auto

lemma ordinal_plus_eq_0:
"((x::ordinal) + y = 0) = (x = 0 \<and> y = 0)"
  apply (rule not_inject)
  apply (simp add: ordinal_plus_not_0)
done




end
