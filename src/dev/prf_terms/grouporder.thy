theory grouporder
imports GroupAx
        GroupStratGraphs
begin

axiomatization
  FG :: "G set"
where
 fax: "finite FG"



fun
  gexp :: "G => nat => G"
where
  "gexp g 0 = e"
| "gexp g (Suc n) = (gexp g n) ** g" 

lemma gexp_id: "gexp e n = e"         full_prf
  apply (induct n)                    full_prf
  apply (rule gexp.simps(1))          full_prf
  apply (subst gexp.simps(2))                          full_prf
  apply (subst id_rev)                   full_prf
  apply assumption
  done                                

full_prf gexp_id

lemma gexp_id_alt: "gexp e n = e"

 apply (psgraph group)

oops



lemma gexp_order_plus: "gexp g n ** gexp g m = gexp g (n + m)"
  apply (induct m)
  apply (subst Nat.add_0_right)
  apply (subst gexp.simps(1))
  apply (rule id_rev)
  apply (subst add_Suc_right)
  apply (subst gexp.simps(2))
  apply (subst gexp.simps(2))
  apply (subst ax2[symmetric])
  apply simp
done

full_prf gexp_order_plus


lemma gexp_order_plus_alt: "gexp g n ** gexp g m = gexp g (n + m)"
  apply (psgraph group)

oops


lemma gexp_order_plus_comm: "gexp g (n + m) = gexp g (m + n)"
  apply (simp add: nat_add_commute)
done

full_prf gexp_order_plus_comm


lemma gexp_order_mult: "gexp (gexp g m) n = gexp g (m * n)"
  apply (induct n)
  apply (subst mult_0_right)
  apply (subst gexp.simps(1))
  apply (subst gexp.simps(1))
  apply (rule refl)
  apply (subst gexp.simps(2))
  apply (subst mult_Suc_right)
  apply (subst nat_add_commute)
  apply (simp add: gexp_order_plus)
done

lemma gexp_order_mult_alt: "gexp (gexp g m) n = gexp g (m * n)"
  apply (psgraph group)
oops

lemma gexp_order_mult_comm: "gexp g (m * n) = gexp (gexp g m) n"
  apply (simp only: gexp_order_mult)
done

lemma gexp_order_Suc: "gexp g n ** g = gexp g (Suc n)"
  apply (induct n)
  apply (subst gexp.simps(2))
  apply (rule refl)
  apply (subst gexp.simps(2))
  apply (subst gexp.simps(2))
  apply (subst gexp.simps(2))
  apply (rule refl)
  done

lemma gexp_order_Suc_alt: "gexp g n ** g = gexp g (Suc n)"
  apply (psgraph group)
oops


(* removing auto/simp - in progress *)

lemma gexp_inv: "inv (gexp g n) = gexp (inv g) n"
  apply (induct n)
  apply (subst gexp.simps(1))
  apply (subst gexp.simps(1))
  apply (rule inv_id)

  apply (subst Suc_eq_plus1)
  apply (subst Suc_eq_plus1)
  apply (subst One_nat_def)
  apply (subst One_nat_def)
  apply (subst add_Suc_shift[symmetric])
  apply (subst add_Suc_shift[symmetric])
  apply (subst gexp_order_plus[symmetric])
  apply (subst gexp.simps(1))
  apply (subst id_rev)
  apply (subst gexp.simps(2))
  apply (subst Suc_eq_plus1)
  apply (subst gexp_order_plus[symmetric])
  apply (subst gexp.simps(1))
  apply (subst id_rev)
  apply (subst gexp_order_plus[symmetric])
  
  

 
  
  


sledgehammer

  apply simp
  apply (rule inv_id)
  apply simp
  apply (rule inv_unique[symmetric])
  apply (subst lat_sq)
  apply auto
     
apply  (metis add_Suc add_Suc_right ax2 gexp.simps(2) gexp_order_plus inv_comm inv_inv inv_rev lat_sq)
done

full_prf gexp_inv 




definition 
  iexp :: "G => int => G"
where
 "iexp g n \<equiv> if n < 0 then inv (gexp g (nat (-n))) else gexp g (nat n)"


lemma iexp_neg_int: "iexp g (-n) = inv (iexp g n)"
  apply (unfold iexp_def)
  apply simp
  apply (rule conjI)
  apply (simp only: inv_inv)
  apply (metis)
  apply (simp only: inv_id)
  apply (metis)
done

lemma shows "iexp (iexp g m) n = iexp g (m * n)"
  apply (rule int_induct[where P="\<lambda> m. iexp (iexp g m) n = iexp g (m * n)" and k=1])
  apply auto[1]
  apply (unfold iexp_def)
  apply (simp add: ax1)
  apply simp
  apply auto
  apply (simp add: gexp_inv)
  apply (simp add: gexp_order_mult)
  apply (metis comm_semiring_1_class.normalizing_semiring_rules(7) gexp_inv less_int_def minus_mult_left nat_mult_commute nat_mult_distrib neg_0_less_iff_less)
  apply (metis add_strict_increasing2 comm_semiring_1_class.normalizing_semiring_rules(7) int_one_le_iff_zero_less less_int_def mult_pos_neg2 zero_less_one)
  apply (simp add: gexp_order_mult)
  apply (subst gexp_inv)
  apply (metis add1_zle_eq int_one_le_iff_zero_less less_int_def mult_eq_0_iff mult_le_0_iff not_square_less_zero)
  apply (metis comm_semiring_1_class.normalizing_semiring_rules(7) gexp_order_mult nat_mult_distrib not_leE)
  apply (simp add: gexp_inv)
  apply (simp add: inv_inv)
  apply (simp add: gexp_order_mult)
  apply (simp add: gexp_inv[symmetric])
  apply (rule inv_unique)
  apply (metis (hide_lams, mono_tags) comm_semiring_1_class.normalizing_semiring_rules(7) diff_self int_one_le_iff_zero_less less_int_def  mult_le_0_iff neg_0_less_iff_less neg_equal_0_iff_equal order_antisym_conv zle_diff1_eq)
  apply (simp add: gexp_inv)
  apply (simp add: inv_inv)
  apply (simp add: gexp_order_mult)
  prefer 5
  apply (simp add: gexp_id)
  prefer 4
  apply (simp add: gexp_id)
  apply (simp add: inv_id)
  prefer 3
  apply (simp add: gexp_inv)
  apply (simp add: gexp_order_mult)
  apply (simp add: gexp_inv[symmetric])
  apply (metis comm_semiring_1_class.normalizing_semiring_rules(7) iexp_def iexp_neg_int less_iff_diff_less_0 linorder_neqE_linordered_idom mult_pos_neg mult_zero_left transfer_nat_int_numerals(1) uminus_int_code(1))
  prefer 2
  apply (simp add: gexp_inv)
  apply (simp add: gexp_order_mult)
  apply (simp add: gexp_inv[symmetric])
  

oops


lemma  shows "iexp g n ** iexp g (m) = iexp g (n + m)"
  apply (rule int_induct)
  apply auto
  apply (subst iexp_def)+
  apply simp
  apply auto
  

oops
 
declare [[ show_types ]]
thm int_induct
  
lemma fixes x :: int
  assumes h1: "P (0::int)"
  and h2: "!! x. P x ==> P (x + 1)"
  and h3: "!! x. P x ==> P (x - 1)"
  shows "P x"
  apply (rule int_induct)
  using h1 h2 h3 by auto



lemma  "\<exists> x. gexp a x = e"
    apply (rule_tac x = "0" in exI) 
    apply (subst gexp.simps)
    apply (rule refl)
    done


thm gexp.simps

lemma   assumes h1: "a : FG"
  and h2: "gexp a k : FG"
  shows "\<exists> x. x \<noteq> 0 \<and> gexp a x = e"
     

 oops
        

lemma  "a : FG ==> \<exists> k. gexp a k = e"
 oops


definition 
  order :: "G => nat"
where
 "order g \<equiv> LEAST k. gexp g k = e"


