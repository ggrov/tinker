(* $Id: HEAP1ProofsIJW.thy 1677 2013-07-16 13:13:39Z iwhitesi $ *)
theory HEAP1ProofsIJW
imports  HEAP1
begin
(*
Inputs:

ST:  
assume "nat1_map f"
show nat1_conc: "nat1_map ({l} -\<triangleleft> f1)"

SL:
lemma restr_nat1_map:
  assumes *: "nat1_map f"
  shows "nat1_map  (s -\<triangleleft> f)"
     
TT:  
assume "nat1_map f"
show nat1_conc: "nat1_map (  ({l} -\<triangleleft> f) \<union>m [l + s \<mapsto> the (f l) - s])"

TL:

?
A variant of this...

lemma nat1_map_unionm:
  assumes nat1f: "nat1_map f"
(* Extra assumptions from proof...  
  and nat1y: "nat1 b"
  and disjdom: "dom f \<inter> dom [a \<mapsto> b] = {}" 
*) 
shows "nat1_map (f \<union>m [a \<mapsto> b])"

*)


(* Invariant simplification rules *)

lemma invF1_sep_weaken: "F1_inv f \<Longrightarrow> sep f"
  unfolding F1_inv_def by simp

lemma invF1_Disjoint_weaken: "F1_inv f \<Longrightarrow> Disjoint f"
  unfolding F1_inv_def by simp

lemma invF1_nat1_map_weaken: "F1_inv f \<Longrightarrow> nat1_map f"
  unfolding F1_inv_def by simp

lemma invF1_finite_weaken: "F1_inv f \<Longrightarrow> finite (dom  f)"
  unfolding F1_inv_def by simp

  lemma invF1E[elim!]: "F1_inv f \<Longrightarrow> (sep f \<Longrightarrow> Disjoint f \<Longrightarrow> nat1_map f \<Longrightarrow> finite (dom f) \<Longrightarrow> R) \<Longrightarrow> R"
  unfolding F1_inv_def by simp

lemma invF1I[intro!]: "sep f \<Longrightarrow> Disjoint f \<Longrightarrow> nat1_map f \<Longrightarrow> finite (dom f) \<Longrightarrow> F1_inv f"
unfolding F1_inv_def by simp


(* GENERAL (OFTEN SET THEORETIC ) LEMMAS *)

(* Elimination rule for dealing with union of quantifiers *)
lemma ballUnE[elim!]: "\<forall>x\<in>f\<union>g. P x \<Longrightarrow> (\<forall>x\<in> f. P x \<Longrightarrow> \<forall>x\<in>g. P x \<Longrightarrow> R) \<Longrightarrow> R"
by auto

lemma ballUnI[intro!]: "\<forall>x\<in>f. P x \<Longrightarrow> \<forall>x\<in>g. P x \<Longrightarrow> \<forall>x\<in>f\<union>g. P x"
by auto


lemma setminus_trans: "X - insert x F = (X - F) - {x}"
by (metis Diff_insert)



lemma UN_minus: "\<forall>x\<in>X-{y}. P x \<inter> P y = {} \<Longrightarrow> (\<Union> x \<in> X-{y}. P x) = (\<Union>x\<in>X. P x) - P y"
by blast


 (* Toolkit? *)

lemma restr_nat1_map:
  assumes *: "nat1_map f"
  shows "nat1_map  (s -\<triangleleft> f)"
unfolding nat1_map_def dom_antirestr_def
using * nat1_map_def by (simp add: domIff)

 (* Toolkit? *)
lemma antirestr_finite:
 assumes *: "finite (dom f)"
 shows "finite  (dom (s -\<triangleleft> f))"
proof(rule finite_subset)
 show "dom (s -\<triangleleft> f) \<subseteq> dom f" by (rule f_dom_ar_subset_dom)
 show "finite (dom f)" by (rule *)
qed

lemma restr_sep:
  assumes *:"sep f"
  shows " sep (s -\<triangleleft> f)"
  by (smt * f_in_dom_ar_subsume sep_def f_in_dom_ar_the_subsume)

lemma restr_Disjoint:
    assumes "Disjoint f"
    shows "Disjoint (s -\<triangleleft> f)" 
unfolding Disjoint_def
by (metis Disjoint_def Locs_of_def assms f_in_dom_ar_subsume f_in_dom_ar_the_subsume)

lemma F1_inv_restr:
  assumes inv: "F1_inv f1"
  shows "F1_inv ({l} -\<triangleleft> f1)"
proof -
  from inv show ?thesis
  proof  (* unpacking nvariant as elimination rule *)
    assume  disjf1: "Disjoint f1" 
    and sepf1: "sep f1"
    and nat1_mapf1: "nat1_map f1"  
    and finitef1: "finite (dom f1)"
    show ?thesis (* Packaged into an introduction rule *)
    proof 
      show nat1_conc: "nat1_map ({l} -\<triangleleft> f1)" using nat1_mapf1 by (rule restr_nat1_map)
      show finite_conc: "finite (dom ({l} -\<triangleleft> f1))" using finitef1 by (rule antirestr_finite)
      show "sep ({l} -\<triangleleft> f1)" using sepf1 by (rule restr_sep)
      show "Disjoint ({l} -\<triangleleft> f1)" using disjf1 by (rule restr_Disjoint)
    qed
  qed
qed



lemma nat1_map_dagger:
 "nat1_map f \<Longrightarrow> nat1_map g \<Longrightarrow> nat1_map (f \<dagger> g)"
unfolding nat1_map_def dagger_def by (metis (full_types) Un_iff dom_map_add map_add_dom_app_simps(1) map_add_dom_app_simps(3))

lemma nat1_map_dagger_upd:
  assumes nat1f: "nat1_map f"
  and nat1y: "nat1 b"  
shows "nat1_map (f \<dagger> [a \<mapsto> b])"
by (metis dom_empty empty_iff fun_upd_same l_inmapupd_dom_iff nat1_map_dagger nat1_map_def nat1f nat1y the.simps)

lemma nat1_map_unionm:
  assumes nat1f: "nat1_map f"
  and nat1y: "nat1 b"
  and disjdom: "dom f \<inter> dom [a \<mapsto> b] = {}"  
shows "nat1_map (f \<union>m [a \<mapsto> b])"
unfolding munion_def
by (metis (full_types) disjdom nat1_map_dagger_upd nat1f nat1y)



lemma dagger_finite:
 assumes *: "finite (dom f)"
 shows "finite  (dom (f \<dagger> [a \<mapsto> b]))"
 by (simp add: l_dagger_dom *)

lemma munion_finite:
 assumes *: "finite (dom f)"
 and disjdom: "dom f \<inter> dom [a \<mapsto> b] = {}"
 shows "finite  (dom (f \<union>m [a \<mapsto> b]))"
by (metis "*" dagger_finite disjdom munion_def)

lemma munion_finite_gen:
 assumes *: "finite (dom f)" "finite (dom g)"
 and disjdom: "dom f \<inter> dom g = {}"
 shows "finite  (dom (f \<union>m g))"
by (metis assms(1) assms(2) l_dagger_dom disjdom finite_UnI munion_def)




lemma dagger_sep:
  assumes *: "sep f"
  and **: "sep [a \<mapsto> b]" (* Can remove *)
  and ***: "\<forall>l\<in> dom f. l+the (f l) \<notin> dom ([a \<mapsto> b])"
  and ****: "a+b \<notin> dom f"
  and anotinf: "a \<notin> dom f"
  shows "sep (f \<dagger> [a \<mapsto> b])"
unfolding sep_def 
proof(subst l_dagger_dom, rule ballUnI)
  show " \<forall>l\<in>dom f. l + the ((f \<dagger> [a \<mapsto> b]) l) \<notin> dom (f \<dagger> [a \<mapsto> b])" 
    by (metis "*" "***" anotinf dagger_def domIff fun_upd_apply map_add_empty map_add_upd sep_def)
  next 
  show "\<forall>l\<in>dom [a \<mapsto> b]. l + the ((f \<dagger> [a \<mapsto> b]) l) \<notin> dom (f \<dagger> [a \<mapsto> b])" 
      by (smt "**" "****" dagger_def domIff fun_upd_same l_inmapupd_dom_iff 
              map_add_None map_add_dom_app_simps(1) sep_def the.simps)
qed

lemma munion_sep:
  assumes *: "sep f"
  and **: "sep [a \<mapsto> b]"
  and ***: "\<forall>l\<in> dom f. l+the (f l) \<notin> dom ([a \<mapsto> b])"
  and ****: "a+b \<notin> dom f"
  and anotinf: "a \<notin> dom f"
  and disjoint_dom:  "dom f \<inter> dom [a \<mapsto> b] = {}"
  shows "sep (f \<union>m [a \<mapsto> b])"
unfolding munion_def 
apply (simp only: disjoint_dom, simp, rule dagger_sep)
using assms by simp_all



lemma not_dom_not_locs_weaken: "nat1_map f \<Longrightarrow> x \<notin> locs f \<Longrightarrow> x \<notin> dom f"
apply (unfold locs_def)
apply simp
apply (cases "x\<in> dom f")
prefer 2
apply simp
apply (erule_tac x="x" in ballE)
prefer 2
apply simp
apply (unfold locs_of_def)
apply (subgoal_tac "nat1 (the (f x))")
apply simp
by (metis nat1_map_def)

lemma not_in_dom_restr: "finite (dom f) \<Longrightarrow> s \<inter> dom f = {} \<Longrightarrow> dom (s -\<triangleleft> f) = dom f"
apply (induct rule: finite_map_upd_induct)
apply (unfold dom_antirestr_def) apply simp
by (metis IntI domIff empty_iff)


lemma restr_locs: "finite(dom f) \<Longrightarrow> F1_inv f \<Longrightarrow> l\<in>dom f \<Longrightarrow> locs ({l} -\<triangleleft> f) = (locs f) - locs_of l (the (f l))"
proof (erule invF1E)
  assume ***: "finite (dom f)"
  and sepf: "sep f"
  and nat1: "nat1_map f"
  and disj: "Disjoint f" 
  and linf: "l \<in> dom f"
  have nat1map: "nat1_map ({l} -\<triangleleft> f)" by (metis nat1 restr_nat1_map)
  from nat1map nat1 show ?thesis 
  unfolding locs_def
  proof(simp)
    show "(\<Union>s\<in>dom ({l} -\<triangleleft> f). locs_of s (the (({l} -\<triangleleft> f) s))) = (\<Union>s\<in>dom f. locs_of s (the (f s))) - locs_of l (the (f l))" 
    proof -
      have "(\<Union>s\<in>dom ({l} -\<triangleleft> f). locs_of s (the (({l} -\<triangleleft> f) s))) = (\<Union>s\<in>(dom f - {l}). locs_of s (the (({l} -\<triangleleft> f) s)))"      
      by (simp add: l_dom_dom_ar)
      also have "... = (\<Union>s\<in>(dom f - {l}). locs_of s (the (f s)))"
      by (metis (lifting, no_types) SUP_cong UN_cong l_dom_dom_ar f_in_dom_ar_the_subsume)
     also have "... =  (\<Union>s\<in>dom f. locs_of s (the (( f) s))) - locs_of l (the(f l))"
     proof (rule UN_minus)
      show " \<forall>s\<in>dom f - {l}. locs_of s (the (f s)) \<inter> locs_of l (the (f l)) = {}"
      proof
        fix s
        assume snotl: "s\<in>dom f-{l}"
        show "locs_of s (the (f s)) \<inter> locs_of l (the (f l)) = {}" 
        proof -
          have snotl2: "s \<noteq> l" by (metis member_remove remove_def snotl)
          then show ?thesis
        apply (insert disj)
        apply (unfold Disjoint_def)
        apply (unfold disjoint_def)
        apply (erule_tac x="s" in ballE)
        apply (erule_tac x="l" in ballE)
        apply (erule impE)
        apply (rule snotl2)
        apply (subgoal_tac "s\<in>dom f")
        apply (subgoal_tac "l\<in>dom f")        
        apply (unfold Locs_of_def)
        apply simp
        apply simp
        apply (rule linf)
        apply (metis l_dom_dom_ar l_dom_ar_not_in_dom snotl)
        apply (metis linf)
        by (metis l_dom_dom_ar l_dom_ar_not_in_dom snotl)
qed
    qed
qed
  finally show "(\<Union>s\<in>dom ({l} -\<triangleleft> f). locs_of s (the (({l} -\<triangleleft> f) s))) = (\<Union>s\<in>dom f. locs_of s (the (f s))) - locs_of l (the (f l))" 
  by simp
qed
qed
qed


	
lemma k_locs_of_arithI:
	"nat1 n \<Longrightarrow> nat1 m \<Longrightarrow> a+n \<le> b \<or> b+m \<le> a \<Longrightarrow> locs_of a n \<inter> locs_of b m = {}"
unfolding locs_of_def
by auto


lemma k_locs_of_arithIff:
	"nat1 n \<Longrightarrow> nat1 m \<Longrightarrow> (locs_of a n \<inter> locs_of b m = {}) = (a+n \<le> b \<or> b+m \<le> a)"
unfolding locs_of_def
apply simp
apply (rule iffI)
apply (erule equalityE)
apply (smt disjoint_iff_not_equal mem_Collect_eq subset_empty)
apply (erule disjE)
apply (rule equals0I)
apply simp
apply (rule equals0I)
apply simp
done


lemma k_locs_of_arithE:
	"locs_of a n \<inter> locs_of b m = {} \<Longrightarrow> nat1 m \<Longrightarrow> nat1 n \<Longrightarrow> (a+n \<le> b \<or> b+m \<le> a \<Longrightarrow> nat1 n \<Longrightarrow> nat1 m  \<Longrightarrow> R) \<Longrightarrow> R"
by (metis k_locs_of_arithIff)


lemma dagger_Disjoint:
 assumes *: "Disjoint f"
  and **: "Disjoint [a \<mapsto> b]"
  and ***: "\<forall>l\<in> dom f. l+the (f l) \<notin> dom ([a \<mapsto> b])"
  and ****: "a+b \<notin> dom f"
  and anotinf: "a \<notin> dom f"
  and inv: "F1_inv f"
  and nat1b: "nat1 b"
  and disj: "\<forall>x\<in> dom f. locs_of x (the (f x)) \<inter> locs_of a b = {}"
  shows "Disjoint (f \<dagger> [a \<mapsto> b])"
unfolding Disjoint_def 
apply(subst l_dagger_dom)
apply(rule ballUnI)
apply (rule ballI) 
apply(subst l_dagger_dom)
apply(rule ballUnI)
apply (rule ballI)
apply (rule impI)
apply (simp only: disjoint_def Locs_of_def)
apply (subgoal_tac "aa \<in> dom (f \<dagger> [a \<mapsto> b])")
apply (subgoal_tac "ba \<in> dom (f \<dagger> [a \<mapsto> b])")
apply simp
apply (subgoal_tac "aa \<noteq> a")
apply (subgoal_tac "ba \<noteq> a")
apply (simp add:  the_dagger_mapupd_dom)
apply (insert *)
apply (metis Disjoint_def Locs_of_def disjoint_def)
apply (metis anotinf)
apply (metis anotinf)
apply (metis in_dagger_domL)
apply (metis in_dagger_domL)
apply(rule ballI)
apply (subgoal_tac "aa \<in> dom (f \<dagger> [a \<mapsto> b])")
apply (subgoal_tac "ba \<in> dom (f \<dagger> [a \<mapsto> b])")
apply (subgoal_tac "ba=a")
apply (simp only: disjoint_def Locs_of_def)
apply (simp)
apply (subgoal_tac "the ((f \<dagger> [a \<mapsto> b]) a) = b")
apply simp
apply (subgoal_tac " locs_of aa (the ((f \<dagger> [a \<mapsto> b]) aa)) =  locs_of aa (the (f aa))")
apply simp
prefer 2
apply (metis anotinf dagger_def fun_upd_apply map_add_empty map_add_upd)
prefer 2
apply (metis dagger_def fun_upd_same map_add_upd the.simps)
prefer 2
apply (metis dom_empty empty_iff l_inmapupd_dom_iff)
prefer 2
apply (metis in_dagger_domR)
prefer 2
apply (metis in_dagger_domL)
apply (rule impI)
  apply (metis disj)
apply(rule ballI)
apply(rule ballI)
apply (subgoal_tac "aa \<in> dom (f \<dagger> [a \<mapsto> b])")
prefer 2
 apply (metis in_dagger_domR)
apply (subgoal_tac "ba \<in> dom (f \<dagger> [a \<mapsto> b])")
prefer 2
  apply metis
apply (subgoal_tac "aa=a")
prefer 2
  apply (metis dom_empty empty_iff l_inmapupd_dom_iff)
apply (simp only: disjoint_def Locs_of_def)
apply (simp)
apply (subgoal_tac "the ((f \<dagger> [a \<mapsto> b]) a) = b")
prefer 2
  apply (metis dagger_def fun_upd_same map_add_upd the.simps)
apply simp
apply (rule impI)
apply (subgoal_tac " locs_of ba (the ((f \<dagger> [a \<mapsto> b]) ba)) =  locs_of ba (the (f ba))")
  prefer 2
  apply (metis the_dagger_mapupd_dom)
by (metis disj domIff inf_commute the_dagger_mapupd_dom)


lemma munion_Disjoint:
 assumes *: "Disjoint f"
  and **: "Disjoint [a \<mapsto> b]"
  and ***: "\<forall>l\<in> dom f. l+the (f l) \<notin> dom ([a \<mapsto> b])"
  and ****: "a+b \<notin> dom f"
  and anotinf: "a \<notin> dom f"
  and inv: "F1_inv f"
  and nat1b: "nat1 b"
  and disj: "\<forall>x\<in> dom f. locs_of x (the (f x)) \<inter> locs_of a b = {}"
  and disjoint_dom:  "dom f \<inter> dom [a \<mapsto> b] = {}"
shows "Disjoint (f \<union>m [a \<mapsto> b])"
unfolding munion_def
apply (simp only: disjoint_dom)
apply simp
using assms dagger_Disjoint apply simp
done


lemma l_plus_s_not_in_f:
assumes  inv: "F1_inv f" and lindom: "l \<in> dom f" 
  and f1biggers: "the(f l) > s"and nat1s: "nat1 s" 
  shows "l+s \<notin> dom f"
proof
  assume lsindom: "l + s \<in> dom f"
  then obtain y where "the (f (l+s)) = y" by auto
   have *: "nat1 (the(f(l+s)))" by (metis inv invF1_nat1_map_weaken lsindom nat1_map_def)
  from f1biggers have "l+ the(f l) > l+s" by auto
  from inv have inlocs:"l+s \<in> locs_of l (the(f l))" 
  proof
   have "nat1 (the(f l))" by (metis inv invF1_nat1_map_weaken lindom nat1_map_def)
   then show ?thesis 
    unfolding locs_of_def     
    by (simp add: f1biggers)    
  qed
  have notl: "l+s \<noteq> l" using nat1s by auto
  have notinlocs: "l+s \<notin> locs_of l (the(f l))"
  proof -
    have "locs_of (l+s) (the(f(l+s))) \<inter>   locs_of l (the(f l)) = {}"
      by (metis (full_types) Disjoint_def F1_inv_def Locs_of_def
        disjoint_def inv lindom lsindom notl)
      moreover have "l+s \<in> locs_of (l+s) (the(f(l+s)))"
        unfolding locs_of_def using * by simp
      ultimately show ?thesis  by auto
    qed
    from inlocs notinlocs show "False" by auto
qed

lemma top_locs_of: "nat1 y \<Longrightarrow> x + y - 1 \<in> locs_of x y"
unfolding locs_of_def
by simp

lemma  top_locs_of2: "(the (f l)) > s \<Longrightarrow> nat1 s \<Longrightarrow>  l + s - 1 \<in> locs_of l (the (f l))"
unfolding locs_of_def
  by auto

(* RENAME!! *)
lemma minor_sep_prop: "x \<in> dom f \<Longrightarrow> l \<in> dom f \<Longrightarrow> l<x \<Longrightarrow> F1_inv f \<Longrightarrow> l + the (f l) \<le> x" 
apply(erule invF1E)
 apply (unfold Disjoint_def)
apply(erule_tac x="x" in ballE)
apply(erule_tac x="l" in ballE)
apply (erule impE)
apply simp
apply (unfold disjoint_def)
apply (unfold Locs_of_def)
apply simp
apply (erule k_locs_of_arithE)
apply (metis nat1_map_def)
apply (metis nat1_map_def)
apply (metis add_leE not_less)
apply metis
by metis

lemma F1_inv_restr_unionm:
  assumes inv: "F1_inv f" 
  and nat1s: "nat1 s"
  and l_in_dom: "l \<in> dom f"
  and f_bigger_s: "the(f l) > s" (* Needed for the nat1 property? *)
  shows "F1_inv (({l} -\<triangleleft> f) \<union>m [l + s \<mapsto> the(f l) - s])"
  proof - 
  from inv show ?thesis
  proof  
  assume disjf1: "Disjoint f"
   and sepf1: "sep f" 
   and nat1_mapf1: "nat1_map f" 
   and finitef1: "finite (dom f)"
  have disjoint_dom: "dom ({l} -\<triangleleft> f) \<inter> dom [l + s \<mapsto> the (f l) - s] = {}"
   proof (rule l_dom_ar_disjoint_weakening)
      show " dom f \<inter> dom [l + s \<mapsto> the (f l) - s] = {}"
      proof (simp)
      show "l + s \<notin> dom  f"
      proof (rule l_plus_s_not_in_f)
        show "F1_inv f" by (metis inv)
        next
        show " l \<in> dom  f" by (metis l_in_dom)
        next
        show "s < the (f l)" by (metis f_bigger_s)
        next
        show "nat1 s" by (metis nat1s)
      qed
    qed
  qed
  have noteqls: "\<forall> x \<in> dom f. x + (the (f x)) \<noteq> l + s"
  apply (insert disjf1)
  apply (unfold Disjoint_def)
  apply (rule ballI)
  apply (erule_tac x="x" in ballE)
  prefer 2 apply simp
  apply (erule_tac x="l" in ballE)
  prefer 2 apply (metis l_in_dom)
  apply (case_tac "x=l")
  apply simp apply (metis f_bigger_s less_irrefl)
  apply simp 
  apply (simp add: l_in_dom disjoint_def Locs_of_def)
  apply (subgoal_tac  "x + the (f x) - 1  \<noteq> l + s - 1")
  apply metis
  apply (subgoal_tac "x + the (f x) - 1 \<in> locs_of x (the (f x))")
  apply (subgoal_tac " l + s - 1 \<in>  locs_of l (the (f l))")
  apply (metis disjoint_iff_not_equal)
  apply (metis f_bigger_s nat1s top_locs_of2)
 apply (metis nat1_map_def nat1_mapf1 top_locs_of)
   done
  show ?thesis
  proof
     show nat1_conc: "nat1_map ({l} -\<triangleleft> f \<union>m [l + s \<mapsto> the (f l) - s])"
  proof(rule nat1_map_unionm)
    show "nat1_map ({l} -\<triangleleft> f)" using nat1_mapf1 by (rule restr_nat1_map)
    next
    show "nat1 (the (f l) - s)" using f_bigger_s by simp
    show "dom ({l} -\<triangleleft> f) \<inter> dom [l + s \<mapsto> the (f l) - s] = {}" 
      by (rule disjoint_dom)
 qed
  show "finite (dom ({l} -\<triangleleft> f \<union>m [l + s \<mapsto> the (f l) - s]))"
  proof (rule munion_finite)
    show "finite (dom ({l} -\<triangleleft> f))"  using finitef1 by (rule antirestr_finite)
    next
    show " dom ({l} -\<triangleleft> f) \<inter> dom [l + s \<mapsto> the (f l) - s] = {}" by (rule disjoint_dom)
    qed
    next
  show "sep ({l} -\<triangleleft> f \<union>m [l + s \<mapsto> the (f l) - s])"
  proof (rule munion_sep)
     show "sep ({l} -\<triangleleft> f)" using sepf1 by (rule restr_sep)
    next
    show "sep [l + s \<mapsto> the (f l) - s]" unfolding sep_def 
      by (metis ab_semigroup_add_class.add_ac(1) add_diff_cancel_left' 
          add_diff_inverse dom_empty empty_iff f_bigger_s fun_upd_same
          l_inmapupd_dom_iff less_asym the.simps)
    next
    show "\<forall>la\<in>dom ({l} -\<triangleleft> f). la + the (({l} -\<triangleleft> f) la) \<notin> dom [l + s \<mapsto> the (f l) - s]"
    by (metis dom_eq_singleton_conv f_in_dom_ar_subsume f_in_dom_ar_the_subsume noteqls singletonE)   
   show " l + s + (the (f l) - s) \<notin> dom ({l} -\<triangleleft> f)"
    proof -
      have myfact: "l + the (f l)  \<notin> dom(f)" using l_in_dom sepf1 sep_def by auto
      have "l + the (f l) \<notin> dom({l} -\<triangleleft> f)" by (metis l_dom_ar_not_in_dom myfact)
      then show ?thesis by (smt f_bigger_s)
    qed
    next
    show "l + s \<notin> dom ({l} -\<triangleleft> f)"
      proof (rule  not_dom_not_locs_weaken)
        show "nat1_map ({l} -\<triangleleft> f)"  using nat1_mapf1 by (rule restr_nat1_map)
        next
        show  "l + s \<notin> locs ({l} -\<triangleleft> f)"
        proof (subst restr_locs,rule finitef1,rule inv, rule l_in_dom)
          have "nat1 (the (f l))" by (metis l_in_dom nat1_map_def nat1_mapf1)
          then have "l+s \<in> locs_of  l (the (f l))"
            unfolding locs_of_def by (simp add: f_bigger_s)
          then show "l + s \<notin> locs f - locs_of l (the (f l))" by auto
        qed
      qed
      show "dom ({l} -\<triangleleft> f) \<inter> dom [l + s \<mapsto> the (f l) - s] = {}" by (rule disjoint_dom) 
   qed
  next
  show "Disjoint ({l} -\<triangleleft> f \<union>m [l + s \<mapsto> the (f l) - s])"
  proof (rule munion_Disjoint)
    show "Disjoint ({l} -\<triangleleft> f)" using disjf1 by (rule restr_Disjoint)
    next
    show "Disjoint [l + s \<mapsto> the (f l) - s]" 
      unfolding Disjoint_def
      apply (rule ballI)+
      apply (subgoal_tac "a=b") 
      apply simp
      apply simp
      done
      next
      show " \<forall>la\<in>dom ({l} -\<triangleleft> f). la + the (({l} -\<triangleleft> f) la) \<notin> dom [l + s \<mapsto> the (f l) - s]" 
          by (metis dom_eq_singleton_conv f_in_dom_ar_subsume 
            f_in_dom_ar_the_subsume noteqls singletonE)
      next
      show "l + s + (the (f l) - s) \<notin> dom ({l} -\<triangleleft> f)" 
        by (metis DiffE ab_semigroup_add_class.add_ac(1) f_bigger_s l_dom_dom_ar 
            l_in_dom le_add_diff_inverse le_eq_less_or_eq sep_def sepf1)      next
      show "l + s \<notin> dom ({l} -\<triangleleft> f)"
          by (metis f_bigger_s f_in_dom_ar_subsume inv l_in_dom l_plus_s_not_in_f nat1s)          
      next
      show "F1_inv ({l} -\<triangleleft> f)" by (metis F1_inv_restr inv)
      next
      show " nat1 (the (f l) - s)" by (metis f_bigger_s nat1_def zero_less_diff) 
      next
      show " \<forall>x\<in>dom ({l} -\<triangleleft> f). locs_of x (the (({l} -\<triangleleft> f) x)) \<inter> locs_of (l + s) (the (f l) - s) = {}"
      proof
        fix x assume " x\<in>dom ({l} -\<triangleleft> f)"   
        show " locs_of x (the (({l} -\<triangleleft> f) x)) \<inter> locs_of (l + s) (the (f l) - s) = {}"
        proof - 
          have  " locs_of x (the (f x)) \<inter> locs_of (l + s) (the (f l) - s) = {}"
          proof (rule k_locs_of_arithI)
            show "nat1 (the (f x))" 
            by (metis (full_types) Diff_iff `x \<in> dom ({l} -\<triangleleft> f)` 
                l_dom_dom_ar nat1_map_def nat1_mapf1)
            next
            show "nat1 (the (f l) - s)" by( simp add: f_bigger_s)
            next
            show " x + the (f x) \<le> l + s \<or> l + s + (the (f l) - s) \<le> x"
            proof (cases "x>l")
              assume llessx: "l<x"
               have "l + the (f l) \<le> x"
              proof (rule minor_sep_prop)
                show "x\<in> dom f" by (metis `x \<in> dom ({l} -\<triangleleft> f)` f_in_dom_ar_subsume)
                show "l \<in> dom f" by (metis l_in_dom)
                show " l < x" by (rule llessx)
                show "F1_inv f" by (metis inv)
              qed
              thus ?thesis by (metis ab_semigroup_add_class.add_ac(1) f_bigger_s le_add_diff_inverse less_or_eq_imp_le)
             next
             assume "\<not> x > l"
             then have "l>x" by (metis `x \<in> dom ({l} -\<triangleleft> f)` l_dom_ar_not_in_dom2 insertI1 nat_neq_iff)
             then have " x + the (f x) \<le> l + s" 
              by (metis (full_types) `x \<in> dom ({l} -\<triangleleft> f)` inv 
                  l_dom_ar_not_in_dom l_in_dom minor_sep_prop trans_le_add1)      
              thus ?thesis by metis  
             qed           
            qed
        thus ?thesis by (metis `x \<in> dom ({l} -\<triangleleft> f)` f_in_dom_ar_the_subsume)
      qed
      qed
      next
      show " dom ({l} -\<triangleleft> f) \<inter> dom [l + s \<mapsto> the (f l) - s] = {}" by (metis disjoint_dom)
     qed
 qed
qed
qed
  
lemma (in level1_new) new1_post_feaseq:
 assumes pre_eq: "\<exists>l \<in> dom f1. the (f1 l) = s1"
 shows "\<exists> r f1new. new1_post_eq f1 s1 f1new r \<and> F1_inv f1new"
proof - 
	from pre_eq obtain l where ind: "l \<in> dom f1" and preinstance: "the (f1 l) = s1" ..
	obtain f1new where f1wit: "f1new = {l} -\<triangleleft> f1" by auto
	from ind and preinstance and f1wit have "l \<in> dom f1 \<and> the (f1 l) = s1 \<and> f1new = {l} -\<triangleleft> f1" by simp
	moreover from l1_invariant have "F1_inv f1new" by (simp only: F1_inv_restr f1wit)
	ultimately show ?thesis using new1_post_eq_def by auto
qed



lemma (in level1_new) new1_post_feasgr:
 assumes pre_gr: "\<exists>l \<in> dom f1. the (f1 l) > s1"
 shows "\<exists> r f1new. new1_post_gr f1 s1 f1new r \<and> F1_inv f1new"
proof - 
	from pre_gr obtain l where ind: "l \<in> dom f1" and preinstance: "the (f1 l) > s1" ..
	obtain f1new where f1wit: "f1new = ({l} -\<triangleleft> f1) \<union>m [l + s1 \<mapsto> the(f1 l) - s1]" by auto
	from ind and preinstance and f1wit 
	  have "l \<in> dom f1 \<and> the (f1 l) > s1 \<and> f1new = ({l} -\<triangleleft> f1) \<union>m [l + s1 \<mapsto> the(f1 l) - s1]" 
	  by simp
	moreover have "F1_inv f1new"
	proof - 
	have "F1_inv (({l} -\<triangleleft> f1) \<union>m [l + s1 \<mapsto> the(f1 l) - s1])"
	  by (rule F1_inv_restr_unionm, rule l1_invariant, rule l1_input_notempty, rule ind, rule preinstance) 
then show ?thesis by (simp only: f1wit)
  qed
	ultimately show ?thesis using new1_post_gr_def   by auto
qed


lemma (in level1_new)
  locale1_new_FSB: "new1_feasibility"
by (metis le_neq_implies_less 
          new1_feasibility_def 
          new1_post_def new1_post_feaseq 
          new1_post_feasgr 
          new1_postcondition_def 
          new1_pre_defs 
          new1_precondition)
(* FIXME: Write out properly in Isar. *)


(* ==================== Dispose 1 Feasibility =================== *)
(*
definition 
  sum_size :: "(Loc \<rightharpoonup> nat) \<Rightarrow> nat"
where
  "sum_size sm = (if sm \<noteq> empty then 
                      (\<Sum> x\<in>(dom sm) . the (sm x)) 
                  else 
                      undefined)" (*TODO: or 0? *)
*)
(* Dispose 1 lemmas *)


lemma sumsize2_mapupd: "finite (dom f) \<Longrightarrow>x \<notin> dom f \<Longrightarrow> f \<noteq> empty \<Longrightarrow> sum_size (f(x \<mapsto>y)) = (sum_size f) + y "
unfolding sum_size_def apply simp
by (smt setsum_cong2)

lemma setsum_mapupd: "finite (dom fa) \<Longrightarrow> e \<notin> dom fa \<Longrightarrow> fa \<noteq> empty \<Longrightarrow>(\<Sum>x\<in>dom (fa(e \<mapsto> r)). the ((fa(e \<mapsto> r)) x)) =  (\<Sum>x\<in>dom fa. the (fa x)) + r"
apply simp apply (subst add_commute)
by (smt setsum.F_cong)


(* This is the general lemma, but above I have nat1_map_unionm which is for map update. Fine for below  
lemma nat1_map_munion:
  "dom f \<inter> dom g = {} \<Longrightarrow> nat1_map f \<Longrightarrow> nat1_map g \<Longrightarrow> nat1_map (f \<union>m g)" 
  unfolding munion_def
*)


(* Alternative definitions for feasibility of dispose1 
definition dispose1_below :: "F1 \<Rightarrow> Loc \<Rightarrow> F1"
  where
  "dispose1_below f d \<equiv>  { x \<in> dom f . x + the(f x) = d } \<triangleleft> f" 

definition dispose1_above :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1"
  where
  "dispose1_above f d s \<equiv>  { x \<in> dom f . x = d + s } \<triangleleft> f" 

definition dispose1_ext :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1"
  where
  "dispose1_ext f d s \<equiv>  (dispose1_above f d s  \<union>m dispose1_below f d) \<union>m [d \<mapsto> s] "

definition 
   dispose1_post2 :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> bool"
where
   "dispose1_post2 f d s f' \<equiv> 
        (f' = ((dom (dispose1_below f d) \<union> dom (dispose1_above f d s)) -\<triangleleft> f) 
        \<union>m ([min_loc(dispose1_ext f d s) \<mapsto> sum_size(dispose1_ext f d s)]))"

definition (in level1_dispose)
  dispose1_postcondition2 :: "F1 \<Rightarrow> bool"
where
  "dispose1_postcondition2 f' \<equiv> dispose1_post2 f1 d1 s1 f' \<and> F1_inv f'"


definition (in level1_dispose)
  dispose1_feasibility2 :: "bool"
where
  "dispose1_feasibility2 \<equiv> (\<exists> f' . dispose1_postcondition2 f')"
*)


(* This lemma is crucial for simplifying the munion operator!

Quite a nice proof by case analysis on each set (dom) being empty
then by contradiction! 

 *)
lemma(in level1_dispose)  disjoint_above_below[simp] : "dom(dispose1_above f1 d1 s1) \<inter> dom(dispose1_below f1 d1) = {}"
unfolding dispose1_above_def dispose1_below_def
proof(rule l_dom_r_disjoint_weakening) (* Key weakening lemma *)
  show "{x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} = {}"
  proof (cases "{x \<in> dom f1. x = d1 + s1} = {}")
    assume "{x \<in> dom f1. x = d1 + s1} = {}" 
    then show " {x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} = {}" 
      by auto
    next
    assume *: "{x \<in> dom f1. x = d1 + s1} \<noteq> {}"
    show " {x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} = {}" 
    proof (cases " {x \<in> dom f1. x + the (f1 x) = d1} = {}")
    assume "{x \<in> dom f1. x + the (f1 x) = d1} = {}"
    then show  " {x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} = {}" 
      by auto
    next
    assume **: "{x \<in> dom f1. x + the (f1 x) = d1} \<noteq> {}"
    show  "{x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} = {}"
    proof(rule ccontr)
      assume nonempty: "{x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1} \<noteq> {}"
      from * ** obtain x where xinter: "x \<in> {x \<in> dom f1. x = d1 + s1} \<inter> {x \<in> dom f1. x + the (f1 x) = d1}"
          by (smt equals0I nonempty)
      from xinter have d1s1: "x = d1 + s1" by auto
      from xinter have d1: "x + the (f1 x) = d1" by auto
      from d1s1 d1 have "d1 + s1 + the (f1 x) = d1" by auto
      then have "s1 + the (f1 x) = 0" by auto
      then have "False" by (metis add_is_0 l1_input_notempty less_numeral_extra(3) nat1_def)      
      thus "False" ..
    qed
  qed
 qed
qed


lemma (in level1_dispose) finite_dispose1_above: "finite ( dom (dispose1_above f1 d1 s1))"
unfolding dispose1_above_def
apply (rule l_dom_r_finite)
by (metis invF1_finite_weaken l1_invariant)

lemma (in level1_dispose) finite_dispose1_below: "finite ( dom (dispose1_below f1 d1))"
unfolding dispose1_below_def
apply (rule l_dom_r_finite)
by (metis invF1_finite_weaken l1_invariant)


lemma (in level1_dispose) d1_not_dispose_above: "d1 \<notin> dom (dispose1_above f1 d1 s1)"
unfolding dispose1_above_def
proof (subst l_dom_r_subseteq)
  show " {x \<in> dom f1. x = d1 + s1} \<subseteq> dom f1"
    by auto
  next
  show " d1 \<notin> {x \<in> dom f1. x = d1 + s1}" 
    by (smt l1_input_notempty mem_Collect_eq nat1_def)
qed

lemma (in level1_dispose) d1_not_dispose_below: "d1 \<notin> dom (dispose1_below f1 d1)"
unfolding dispose1_below_def
proof (subst l_dom_r_subseteq)
  show " {x \<in> dom f1. x + the (f1 x) = d1} \<subseteq> dom f1"
    by auto
  next
  show " d1 \<notin> {x \<in> dom f1. x + the (f1 x) = d1}" 
    by (metis (lifting, mono_tags) invF1_sep_weaken l1_invariant mem_Collect_eq sep_def)
qed

lemma min_or: "min x y = x \<or> min x y = y"  by (metis min_def)

lemma sumsize2_weakening: "x \<notin> dom f \<Longrightarrow> finite (dom f) \<Longrightarrow> y>0 \<Longrightarrow> sum_size (f(x \<mapsto> y)) > 0" 
  unfolding sum_size_def
 by simp



lemma dagger_min: "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> f  \<noteq> empty \<Longrightarrow> g \<noteq> empty \<Longrightarrow> Min (dom (f \<dagger> g)) \<in> dom f \<or> Min (dom (f \<dagger> g)) \<in> dom g"
apply (simp add: l_dagger_dom)
apply (subst Min_Un)
apply simp_all
apply (subst Min_Un)
apply simp_all
by (metis (mono_tags) Min_in domIff emptyE less_imp_le min_max.inf_absorb2 min_max.le_iff_inf not_le)


lemma min_loc_munion: "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> f\<noteq>empty \<Longrightarrow>
 g \<noteq> empty \<Longrightarrow> dom f \<inter> dom g = {}  \<Longrightarrow> (min_loc (f \<union>m g)) \<in> dom f \<or> (min_loc (f \<union>m g)) \<in> dom g"
proof -
    assume finf: "finite (dom f)" and fing: "finite (dom g)" and
    fnotemp: "f\<noteq>empty" and gnotemp: "g \<noteq> empty" and disjoint_dom: "dom f \<inter> dom g = {}" 
  have " Min (dom (f \<union>m g)) \<in> dom f \<or>  Min (dom (f \<union>m g)) \<in> dom g"
      unfolding munion_def
      apply (simp add: disjoint_dom)
      apply  (rule dagger_min)
      by (simp_all add:  finf fing fnotemp gnotemp )
  then show "min_loc (f \<union>m g) \<in> dom f \<or> min_loc (f \<union>m g) \<in> dom g" 
    unfolding min_loc_def
    by (metis dagger_def dagger_notemp_munion disjoint_dom fnotemp map_add_None)
qed

lemma (in level1_dispose) d1_not_above_below: "d1 \<notin> dom (dispose1_above f1 d1 s1 \<union>m dispose1_below f1 d1)"
unfolding munion_def
  apply simp
  by (metis (full_types) Un_iff d1_not_dispose_above d1_not_dispose_below l_dagger_dom)

lemma (in level1_dispose) dispose1_ext_union: "dom (dispose1_ext f1 d1 s1) =  
    dom (dispose1_above f1 d1 s1) \<union>  dom (dispose1_below f1 d1) \<union> {d1}"
proof -
  have "dom (dispose1_ext f1 d1 s1) = dom (dispose1_above f1 d1 s1 \<union>m dispose1_below f1 d1) \<union> dom([d1 \<mapsto> s1])"
  unfolding dispose1_ext_def
  by (rule l_munion_dom, simp add: d1_not_above_below)
  also have "... =  dom( dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1) \<union> {d1}" 
    unfolding munion_def by simp
  finally show ?thesis by (simp add: l_dagger_dom) 
qed

lemma (in level1_dispose) dispose1_ext_notempty: " dispose1_ext f1 d1 s1 \<noteq> Map.empty "
   by (metis Un_commute Un_insert_left dispose1_ext_union dom_eq_empty_conv insert_not_empty)

lemma (in level1_dispose) dispose1_ext_dom_notempty: "dom ( dispose1_ext f1 d1 s1) \<noteq> {}" 
by (metis Un_insert_right dispose1_ext_union insert_not_empty)

lemma domf_in_locs: "nat1_map f \<Longrightarrow> dom f \<subseteq> locs f"
unfolding locs_def
apply simp
by (metis locs_def not_dom_not_locs_weaken subsetI)


lemma (in level1_dispose) d1notinf1: "d1 \<notin> dom f1" 
proof - 
  have "dom f1 \<subseteq> locs f1" 
  proof(rule domf_in_locs)
    show "nat1_map f1" by (metis invF1_nat1_map_weaken l1_invariant)
  qed
  moreover have "d1 \<in> locs_of d1 s1"
    unfolding locs_of_def apply (simp only: l1_input_notempty)
    by (smt l1_input_notempty mem_Collect_eq nat1_def)
  ultimately show ?thesis by (smt Collect_empty_eq Int_def disjoint_def
                dispose1_pre_def dispose1_precondition set_rev_mp)
qed

lemma (in level1_dispose) 
 nonzero_inter_dom: "dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1) \<inter>
    dom [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)] =
    {}" 
      proof -
        have "min_loc (dispose1_ext f1 d1 s1) = 
          min_loc (dispose1_above f1 d1 s1 \<union>m dispose1_below f1 d1 \<union>m [d1 \<mapsto> s1])"
          unfolding dispose1_ext_def by simp
          also have "... =  Min (dom (dispose1_above f1 d1 s1 \<union>m dispose1_below f1 d1 \<union>m [d1 \<mapsto> s1]))"
            unfolding min_loc_def 
            apply (fold dispose1_ext_def) 
            by (simp add: dispose1_ext_notempty)
          also have  "...= Min ((dom (dispose1_above f1 d1 s1)) \<union> (dom (dispose1_below f1 d1)) \<union> {d1})"
          apply (fold dispose1_ext_def) by (simp add: dispose1_ext_union)
          finally have *: "min_loc (dispose1_ext f1 d1 s1)
              = Min ((dom (dispose1_above f1 d1 s1)) \<union> (dom (dispose1_below f1 d1)) \<union> {d1})" by simp             
(* Now, because of the definition of Min, I need to apply case analysis *)
    show ?thesis
    proof(simp)
      show "min_loc (dispose1_ext f1 d1 s1) \<notin> dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1)"
      proof (rule l_dom_ar_notin_dom_or)
      show "min_loc (dispose1_ext f1 d1 s1) \<notin> dom f1 \<or>
    min_loc (dispose1_ext f1 d1 s1) \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"      
     proof((subst *)+,cases "dom (dispose1_above f1 d1 s1) = {}")
      assume above_empty: " dom (dispose1_above f1 d1 s1) = {}"
      show  " Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
    proof (cases "dom (dispose1_below f1 d1) = {}") 
      assume below_empty: "dom (dispose1_below f1 d1) = {}"
      show " Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
    using above_empty below_empty
    proof( simp)
        show "d1 \<notin> dom f1" by (rule d1notinf1) (* Simple case *)
    qed
     next
      assume below_notemp: "dom (dispose1_below f1 d1) \<noteq> {}"
      show "Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
    apply (subst above_empty)+ apply (subst Un_empty_left)+
    apply (subst Min_Un)
    apply (metis finite_dispose1_below)
    apply (metis below_notemp)
    apply (metis finite.emptyI finite_insert)
    apply (metis insert_not_empty)
    apply (subst Un_empty_right)
    apply (subst Min_Un)

    apply (metis finite_dispose1_below)
    apply (metis below_notemp)
    apply (metis finite.emptyI finite_insert)
    apply (metis insert_not_empty)
    apply (cut_tac x="(Min (dom (dispose1_below f1 d1)))" and y="Min {d1}" in min_or)
    apply (erule disjE) (* Case split *)
    apply (rule disjI2) apply simp apply (rule Min.closed)
    apply (metis finite_dispose1_below)
    apply (metis below_notemp)
    apply (metis Un_iff insert_def min_or singleton_iff sup_bot_right)
    (* Second case *)
    apply (rule disjI1) apply simp apply (rule d1notinf1)
    done
qed
next (* Now the possibility that dispose1_above is not empty and below is not empty *)
  assume above_notemp: "dom (dispose1_above f1 d1 s1) \<noteq> {}"
  show "Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
      proof (cases "dom (dispose1_below f1 d1) = {}") 
      assume below_empty: "dom (dispose1_below f1 d1) = {}"
     show "Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
       apply (subst below_empty)+ apply (subst Un_empty_right)+ apply (subst Un_empty_left)
    apply (subst Min_Un)
    apply (metis finite_dispose1_above)
    apply (metis  above_notemp)
    apply (metis finite.emptyI finite_insert)
    apply (metis insert_not_empty)

    apply (subst Min_Un)
    apply (metis finite_dispose1_above)
    apply (metis above_notemp)
    apply (metis finite.emptyI finite_insert)
    apply (metis insert_not_empty)

    apply (cut_tac x="(Min (dom (dispose1_above f1 d1 s1)))" and y="Min {d1}" in min_or)
    apply (erule disjE) (* Case split *)
    apply (rule disjI2) apply simp apply (rule Min.closed)
    apply (metis finite_dispose1_above)
    apply (metis above_notemp)
    apply (metis Un_iff insert_def min_or singleton_iff sup_bot_right)
    (* Second case *)
    apply (rule disjI1) apply simp apply (rule d1notinf1)
    done
next
  assume below_notemp: "dom (dispose1_below f1 d1) \<noteq> {}"
   show " Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1}) \<notin> dom f1 \<or>
    Min (dom (dispose1_above f1 d1 s1) \<union> dom (dispose1_below f1 d1) \<union> {d1})
    \<in> dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)"
 apply (subst Min_Un)
   apply (metis finite_Un finite_dispose1_above finite_dispose1_below)
apply (metis Un_empty below_notemp)
   apply (metis finite.emptyI finite_insert)
apply (metis insert_not_empty)
    apply (subst Min_Un)
    apply (metis finite_dispose1_above)
    apply (metis above_notemp)
    apply (metis finite_dispose1_below)
    apply (metis below_notemp)
 apply (cut_tac x="(min (Min (dom (dispose1_above f1 d1 s1))) (Min (dom (dispose1_below f1 d1))))" 
      and y=" (Min {d1})" in min_or)
 apply (erule disjE) (* Case split *)
prefer 2
apply (rule disjI1) apply simp apply (rule d1notinf1) (* Third simple case *)


 apply (cut_tac x="(Min (dom (dispose1_above f1 d1 s1)))" 
      and y="(Min (dom (dispose1_below f1 d1)))" in min_or)
apply (erule disjE)
apply (rule disjI2)
apply (simp add: Min.closed)
apply (rule disjI2)
apply (metis Min.insert_idem Min.union_idem Min_in above_notemp below_notemp 
      disjoint_above_below finite_dispose1_above finite_dispose1_below l_munion_dom 
        min_max.inf_commute munion_finite_gen sup_eq_bot_iff)
apply (rule disjI2)
apply simp 
apply (rule disjI1)
by (metis Min.insert_idem Min.union_idem Min_in Un_empty_left below_notemp disjoint_above_below 
      finite_dispose1_above finite_dispose1_below l_munion_dom min_max.inf_commute munion_finite_gen 
      sup_eq_bot_iff)
qed
qed
qed
qed
qed
 (* END OF THAT CASE ANALYSIS! *) 

(* Lemmas required for case-analysis on dispose1_ext *)
lemma munion_min_loc_nonempty: "dom f1 \<inter> dom f2 = {} \<Longrightarrow> finite (dom f1) \<Longrightarrow> finite (dom f2) \<Longrightarrow> f1 \<noteq> empty \<Longrightarrow> f2 \<noteq> empty \<Longrightarrow> min_loc (f1 \<union>m f2) = min (min_loc f1) (min_loc f2)"
unfolding min_loc_def munion_def apply (simp add: dagger_notemptyL)
by (metis Min.union_idem l_dagger_dom dom_eq_empty_conv)

lemma munion_min_loc_emptyf2: "f2 = empty \<Longrightarrow>  min_loc (f1 \<union>m f2) = min_loc f1"
by (metis Int_empty_right equals0D l_map_non_empty_dom_conv l_munion_apply)

lemma munion_min_loc_emptyf1: "f1 = empty \<Longrightarrow>  min_loc (f1 \<union>m f2) = min_loc f2"
by (metis (full_types) domIff dom_eq_empty_conv inf_bot_left l_dagger_apply munion_def)

lemma dagger_min_loc_nonempty: "dom f1 \<inter> dom f2 = {} \<Longrightarrow> finite (dom f1) \<Longrightarrow> finite (dom f2) \<Longrightarrow> f1 \<noteq> empty \<Longrightarrow> f2 \<noteq> empty \<Longrightarrow> min_loc (f1 \<dagger> f2) = min (min_loc f1) (min_loc f2)"
unfolding min_loc_def apply (simp add: dagger_notemptyL)
by (metis Min.union_idem l_dagger_dom dom_eq_empty_conv)

lemma dagger_min_loc_emptyf2: "f2 = empty \<Longrightarrow>  min_loc (f1 \<dagger> f2) = min_loc f1"
 by (metis dom_eq_empty_conv empty_iff l_dagger_apply)

lemma dagger_min_loc_emptyf1: "f1 = empty \<Longrightarrow>  min_loc (f1 \<dagger> f2) = min_loc f2"
by (metis (full_types) domIff l_dagger_apply)

lemma (in level1_dispose) nat1_dispose1_ext:  "nat1 (sum_size (dispose1_ext f1 d1 s1))"
 unfolding dispose1_ext_def
           apply (subst l_munion_upd)
           apply (simp add: l_munion_dom)
          apply (rule conjI)
          apply (rule d1_not_dispose_above)
          apply (rule d1_not_dispose_below)
          apply (unfold nat1_def)
          apply (rule sumsize2_weakening)
          apply (simp add: l_munion_dom)
          apply (rule conjI)
          apply (rule d1_not_dispose_above)
          apply (rule d1_not_dispose_below)
          apply (metis disjoint_above_below finite_Un finite_dispose1_above finite_dispose1_below l_munion_dom)
           by (metis l1_input_notempty nat1_def)
(* NEW1/DISPOSE1 property *)



lemma union_comp: "{x\<in>A \<union> B. P x} = {x\<in> A. P x} \<union>  {x\<in> B. P x}" 
by auto

lemma min_loc_singleton: "min_loc [x \<mapsto> y] = x"
  unfolding min_loc_def
by simp


lemma sum_size_singleton: "sum_size [x \<mapsto> y] = y"
  unfolding sum_size_def
by simp

lemma min_loc_dagger:  "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> f \<noteq> empty \<Longrightarrow> g \<noteq> empty \<Longrightarrow>min_loc (f \<dagger> g) 
                  = min (min_loc f) (min_loc g)"
unfolding min_loc_def
apply(simp add: dagger_notemptyL)
apply (subst l_dagger_dom)
apply (subgoal_tac "dom f \<noteq> {}")
apply (subgoal_tac "dom g \<noteq> {}")
apply (rule Min_Un)
apply (simp_all)
done


lemma setsum_dagger: "dom f \<inter> dom g = {} \<Longrightarrow>finite (dom f) \<Longrightarrow> (\<Sum>x\<in>dom f. the ((f \<dagger> g) x)) =  (\<Sum>x\<in>dom f. the (f x))"
apply (rule setsum_cong)
apply simp
apply (subst l_dagger_apply)
by auto

lemma sum_size_dagger_single: "finite (dom f) \<Longrightarrow> f \<noteq> empty \<Longrightarrow> x \<notin> dom f \<Longrightarrow>sum_size (f \<dagger> [x \<mapsto> y]) 
                  = (sum_size f) + y"
unfolding sum_size_def
apply (simp add: dagger_notemptyL)
apply (subst l_dagger_dom)
apply (subst setsum_Un_disjoint)
apply (simp)
apply simp
apply simp
apply simp
apply (subst setsum_dagger)
apply simp
apply simp
by (metis dagger_upd_dist map_upd_Some_unfold the.simps)


lemma sum_size_dagger:  "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> f \<noteq> empty \<Longrightarrow> g \<noteq> empty \<Longrightarrow> dom f \<inter> dom g = {} \<Longrightarrow>sum_size (f \<dagger> g) 
                  = (sum_size f) + (sum_size g)"
sorry (* Trivialish *)

lemma sum_size_munion:  "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> f \<noteq> empty \<Longrightarrow> g \<noteq> empty \<Longrightarrow> dom f \<inter> dom g = {} \<Longrightarrow>sum_size (f \<union>m g) 
                  = (sum_size f) + (sum_size g)"
unfolding sum_size_def
apply(simp add: munion_notempty_left)
apply (unfold munion_def)
apply simp
apply (subst l_dagger_dom)
apply (subst setsum_Un_disjoint)
apply (simp)
apply simp
apply simp
apply (simp add: setsum_dagger )
apply (subst l_dagger_commute)
apply simp
apply (subst setsum_dagger)
by auto


lemma sep_singleton: "y>0 \<Longrightarrow> sep [x \<mapsto> y]"
  unfolding sep_def by auto

lemma domrestr_singleton: "x \<in> dom f \<Longrightarrow> {x} \<triangleleft> f = [x \<mapsto> the(f x)]"
unfolding dom_restr_def by auto

lemma (in level1_dispose) min_loc_cases: "min_loc (dispose1_ext f1 d1 s1) = d1 
                                        \<or> min_loc (dispose1_ext f1 d1 s1) = d1 + s1
                                        \<or> min_loc (dispose1_ext f1 d1 s1) = d1"
oops (* Not quite right *)
(*
lemma "locs_of d1 s1 \<inter> locs f = {} \<Longrightarrow> \<forall> x \<in> dom f. x + the (f x)" sorry
*)

lemma nat_min_absorb1: "min ((x::nat) + y) x = x"
  by auto

(*
lemma below_dom:
  assumes below_notempty: "dispose1_below f1 d1 \<noteq> empty"
  shows "\<exists>x\<in> dom f1 . dom (dispose1_below f1 d1) = {x}"
unfolding dispose1_below_def
proof -
    have "\<exists> x \<in> dom f1. {x \<in> dom f1. x + the (f1 x) = d1} = {x}" 

lemma below_min_loc:
  assumes below_notempty: "dispose1_below f1 d1 \<noteq> empty""
  shows "min_loc (dispose1_below f1 d1) = x"
sorry
*)

lemma above_dom:
  assumes above_notempty: "(dispose1_above f1 d1 s1) \<noteq> empty"
  shows "dom (dispose1_above f1 d1 s1) = {d1 + s1}"
 proof -
  have "dispose1_above f1 d1 s1 = { x \<in> dom f1 . x = d1 + s1 } \<triangleleft> f1" 
    by (metis dispose1_above_def)
  then have " { x \<in> dom f1 . x = d1 + s1 } \<noteq> {}" 
    by (metis above_notempty l_dom_r_nothing)
  moreover have "dom (dispose1_above f1 d1 s1) = {d1 + s1}"
   unfolding dispose1_above_def
  proof (subst l_dom_r_iff)
    show "{x \<in> dom f1. x = d1 + s1} \<inter> dom f1 = {d1 + s1}"
      by (metis Collect_conj_eq Collect_conv_if Collect_mem_eq 
          calculation inf_commute singleton_conv)
  qed  
  thus ?thesis .
qed

lemma above_min_loc: 
assumes above_notempty: "(dispose1_above f1 d1 s1) \<noteq> empty"
shows "min_loc (dispose1_above f1 d1 s1) = d1 + s1" 
    unfolding min_loc_def
    by (metis Min_singleton assms above_dom)

lemma above_d1s1_in_f1:
assumes above_notempty: "(dispose1_above f1 d1 s1) \<noteq> empty"
shows "d1+s1 \<in> dom f1"
proof -
   have "dom (dispose1_above f1 d1 s1) \<subseteq> dom (f1)"
   unfolding dispose1_above_def by (simp add: l_dom_r_dom_subseteq)
   moreover have "{d1+s1} \<subseteq> dom f1" by (metis above_dom assms calculation)
   ultimately show ?thesis by auto
qed

lemma above_sumsize:
assumes above_notempty: "(dispose1_above f1 d1 s1) \<noteq> empty"
shows "sum_size (dispose1_above f1 d1 s1) = the (f1 (d1 + s1))"     
unfolding sum_size_def 
apply (simp add: above_notempty)
apply (subst above_dom)
apply (rule above_notempty)
unfolding dispose1_above_def
apply (subgoal_tac "{x. x = d1 + s1 \<and> x \<in> dom f1} = {d1+s1}") 
apply (simp)
apply (subst f_in_dom_r_apply_elem)
apply simp_all
by (metis Collect_conj_eq Collect_mem_eq Int_empty_left
    Int_insert_left_if1 above_d1s1_in_f1 assms singleton_conv)


lemmas  (in level1_dispose) dispose_proof_simps = finite_dispose1_above finite_dispose1_below d1_not_dispose_above
                       d1_not_dispose_below d1notinf1 nonzero_inter_dom

lemma (in level1_dispose) F1_inv_dispose:
  assumes f1inv: "F1_inv f1"
  shows "F1_inv ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<union>m
              [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
proof -
  from f1inv show ?thesis
  proof  
  assume disjf1: "Disjoint f1"
   and sepf1: "sep f1" 
   and nat1_mapf1: "nat1_map f1" 
   and finitef1: "finite (dom f1)"
 show ?thesis
proof
  show "nat1_map  ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 
       \<union>m [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
       proof (rule nat1_map_unionm)
        show "nat1_map ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1)"
          using nat1_mapf1 by (rule restr_nat1_map)
        next
        show "nat1 (sum_size (dispose1_ext f1 d1 s1))"
        by (rule nat1_dispose1_ext)
         next
         show nonzero_inter_dom: "dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1) \<inter>
    dom [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)] =
    {}" by (rule  nonzero_inter_dom) (* Originally had this in the main theorem, but realised it was
needed many times, so extracted as a lemma *)
(* END OF THE NAT1 PART OF THE PROOF! *)
qed
next
show "finite (dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<union>m
                 [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)]))"
  proof (rule munion_finite_gen)
    show "finite (dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1))"
      by (metis antirestr_finite finitef1)
    next
    show "finite (dom [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
      by (metis dom_empty dom_fun_upd finite.emptyI finite_insert option.distinct(1))
    next 
    show " dom ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1) \<inter>
    dom [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)] =
    {}" by (rule nonzero_inter_dom)
  qed
next  (*********** SEP ******************)
  show " sep ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<union>m
         [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
 proof -  
  have "sep( (dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<dagger>
              [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
  proof (cases "dispose1_below f1 d1 = empty")
    assume below_empty: "dispose1_below f1 d1 = empty"
    then show ?thesis
    proof (cases "dispose1_above f1 d1 s1 = empty")
      assume above_empty:  "dispose1_above f1 d1 s1 = empty"
      then show ?thesis (* BOTH ARE EMPTY *)
        unfolding dispose1_ext_def munion_def
      proof (simp add: below_empty l_dagger_empty_rhs  l_dagger_empty_lhs munion_def l_dom_ar_empty_lhs min_loc_singleton sum_size_singleton)
        show " sep (f1 \<dagger> [d1 \<mapsto> s1])"
        proof (rule dagger_sep) (* DAGGER SEP FIRST USE *)
          show "sep f1" by (rule sepf1)
          next
          show "sep [d1 \<mapsto> s1]" unfolding sep_def 
            using l1_input_notempty nat1_def by auto
         next
         show "\<forall>l\<in>dom f1. l + the (f1 l) \<notin> dom [d1 \<mapsto> s1]"
         proof
            fix l
            assume "l \<in> dom f1"
            have "l + the (f1 l) \<noteq> d1" 
            proof - 
                have "dispose1_below f1 d1 = { x \<in> dom f1 . x + the(f1 x) = d1 } \<triangleleft> f1"
                  unfolding dispose1_below_def by simp
                then have  "{ x \<in> dom f1 . x + the(f1 x) = d1 } = {}"                   
                  by (smt IntI below_empty dom_def dom_eq_empty_conv 
                          empty_Collect_eq l_dom_r_iff mem_Collect_eq)
                thus ?thesis by (smt `l \<in> dom f1` empty_Collect_eq)
            qed
             then show "l + the (f1 l) \<notin> dom [d1 \<mapsto> s1]"
              by simp
         qed
         next
         show "d1 + s1 \<notin> dom f1"
         proof -
            have "dispose1_above f1 d1 s1 =  { x \<in> dom f1 . x = d1 + s1 } \<triangleleft> f1"
                  unfolding dispose1_above_def by simp
            then have " { x \<in> dom f1 . x = d1 + s1 } = {}" 
              by (smt Collect_empty_eq above_empty disjoint_iff_not_equal 
                  dom_def l_dom_r_iff mem_Collect_eq)
           thus ?thesis by (smt empty_Collect_eq)
         qed
         next
         show "d1 \<notin> dom f1" by (rule d1notinf1)
       qed
     qed (* END OF BOTH EMPTY. COMPELTE. *)
     next
      assume above_notempty: "dispose1_above f1 d1 s1 \<noteq> Map.empty"
      then show ?thesis
        unfolding dispose1_ext_def munion_def
     proof(simp add: below_empty l_dagger_empty_rhs l_dagger_empty_lhs munion_def l_dom_ar_empty_lhs d1notinf1
        d1_not_dispose_above d1_not_dispose_below)
     show "sep (dom (dispose1_above f1 d1 s1) -\<triangleleft> f1
          \<dagger> [min_loc (dispose1_above f1 d1 s1 \<dagger> [d1 \<mapsto> s1]) \<mapsto> HEAP1.sum_size (dispose1_above f1 d1 s1 \<dagger> [d1 \<mapsto> s1])])"
     proof (subst dagger_min_loc_nonempty)
      show "dom (dispose1_above f1 d1 s1) \<inter> dom [d1 \<mapsto> s1] = {}" 
        by (metis d1_not_dispose_above dom_eq_singleton_conv dom_restrict k_munion_map_upd_wd)
      next
      show "finite (dom (dispose1_above f1 d1 s1))"  by (rule finite_dispose1_above)
      next
      show "finite (dom [d1 \<mapsto> s1])" by (metis dom_eq_singleton_conv finite.emptyI finite.insertI)
      next
      show "dispose1_above f1 d1 s1 \<noteq> Map.empty" by (rule above_notempty)
      next
      show " [d1 \<mapsto> s1] \<noteq> Map.empty" by simp
      next (* NOW TO GET THE GOAL I REALLY WANT TO SOLVE *)
      show "sep (dom (dispose1_above f1 d1 s1) -\<triangleleft> f1 \<dagger> [min (min_loc (dispose1_above f1 d1 s1)) (min_loc [d1 \<mapsto> s1]) \<mapsto> HEAP1.sum_size (dispose1_above f1 d1 s1 \<dagger> [d1 \<mapsto> s1])])"
      proof(simp add: above_dom above_min_loc above_notempty min_loc_singleton l1_input_notempty nat_min_absorb1)
        have "sum_size (dispose1_above f1 d1 s1 \<dagger> [d1 \<mapsto> s1]) = sum_size (dispose1_above f1 d1 s1) + s1"
        by (subst sum_size_dagger_single, rule finite_dispose1_above, 
            rule above_notempty, rule d1_not_dispose_above,simp)        
        also have "... = the(f1 (d1+s1)) + s1"  
          by (subst above_sumsize, rule above_notempty,rule refl)
        moreover have " sep ({d1 + s1} -\<triangleleft> f1 \<dagger> [d1 \<mapsto>  the(f1 (d1+s1)) + s1])"
        proof (rule dagger_sep) (* The work is here!!! *)
          show "sep ({d1 + s1} -\<triangleleft> f1)"  using sepf1 by (rule restr_sep)
          next
          show "sep [d1 \<mapsto> the (f1 (d1 + s1)) + s1]"
          proof (rule sep_singleton)
            show " 0 < the (f1 (d1 + s1)) + s1" by (metis add_gr_0 l1_input_notempty nat1_def)
          qed  
          next
          show " d1 \<notin> dom ({d1 + s1} -\<triangleleft> f1)"
          proof -
            have "d1 \<notin> dom f1" by (rule d1notinf1)
            thus ?thesis by (metis l_dom_ar_notin_dom_or)
          qed
          next (* First tough goal *)
          show " \<forall>l\<in>dom ({d1 + s1} -\<triangleleft> f1). 
                      l + the (({d1 + s1} -\<triangleleft> f1) l) 
                        \<notin> dom [d1 \<mapsto> the (f1 (d1 + s1)) + s1]" 
          proof
            fix l assume lindom: "l\<in>dom ({d1 + s1} -\<triangleleft> f1)"
            then have linf: "l\<in> dom f1" by (metis l_dom_ar_notin_dom_or)
            have "l + the (f1 l) \<noteq> d1" 
            proof - 
                have "dispose1_below f1 d1 = { x \<in> dom f1 . x + the(f1 x) = d1 } \<triangleleft> f1"
                  unfolding dispose1_below_def by simp
                then have  "{ x \<in> dom f1 . x + the(f1 x) = d1 } = {}"                   
                  by (smt IntI below_empty dom_def dom_eq_empty_conv 
                          empty_Collect_eq l_dom_r_iff mem_Collect_eq)
                thus ?thesis by (smt linf empty_Collect_eq)
            qed
            then have "l + the (({d1 + s1} -\<triangleleft> f1) l) \<noteq> d1" 
              by (metis f_in_dom_ar_apply_subsume lindom)
            thus " l + the (({d1 + s1} -\<triangleleft> f1) l) \<notin> dom [d1 \<mapsto> the (f1 (d1 + s1)) + s1]" by auto
          qed
          next (* Second tough goal *)
          show "d1 + (the (f1 (d1 + s1)) + s1) \<notin> dom ({d1 + s1} -\<triangleleft> f1)"
          proof -
            have "sep f1" by (rule sepf1)
            then have "\<forall>l\<in> dom f1. l + the (f1 l) \<notin> dom f1" 
              using sep_def by auto
            moreover have "(d1+s1) \<in> dom f1" using above_notempty by (rule above_d1s1_in_f1)
            moreover have "(d1 + s1) + the (f1 (d1+s1)) \<notin> dom f1" 
                by (metis calculation(1) calculation(2))
            ultimately show "d1 + (the (f1 (d1 + s1)) + s1) \<notin> dom ({d1 + s1} -\<triangleleft> f1)" 
              by (smt f_in_dom_ar_subsume) 
         qed
       qed
     ultimately show "sep ({d1 + s1} -\<triangleleft> f1 \<dagger> 
        [d1 \<mapsto> sum_size (dispose1_above f1 d1 s1 \<dagger> [d1 \<mapsto> s1])])"
        by simp
     qed
    qed
   qed
  qed
  next (* CASE WHERE BELOW IS NOT EMPTY!!! HALFWAY THERE. *) 
    assume below_notempty: "dispose1_below f1 d1 \<noteq> empty"
    show "sep ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1
      \<dagger> [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
    proof (cases "dispose1_above f1 d1 s1 = empty")
      assume above_empty:  "dispose1_above f1 d1 s1 = empty"
      then show ?thesis
        unfolding dispose1_ext_def munion_def
     proof(simp add: above_empty l_dagger_empty_rhs l_dagger_empty_lhs munion_def l_dom_ar_empty_lhs d1notinf1
        d1_not_dispose_above d1_not_dispose_below, subst dagger_min_loc_nonempty) 
      show " dom (dispose1_below f1 d1) \<inter> dom [d1 \<mapsto> s1] = {}" 
        by (metis Collect_conj_eq Collect_conv_if2 Collect_mem_eq d1_not_dispose_below 
          dom_eq_singleton_conv inf_commute singleton_conv2)   
     next
     show "finite (dom (dispose1_below f1 d1))" 
        by (rule finite_dispose1_below)
     next
     show " finite (dom [d1 \<mapsto> s1])" 
        by (metis dom_eq_singleton_conv finite.emptyI finite.insertI)
     next
     show "dispose1_below f1 d1 \<noteq> Map.empty" by (rule below_notempty)
     next
     show "[d1 \<mapsto> s1] \<noteq> Map.empty" by (metis map_upd_nonempty)
     next (* MAIN GOAL. NOW TO SIMPLIFY *)
     show "sep (dom (dispose1_below f1 d1) -\<triangleleft> f1 \<dagger>
           [min (min_loc (dispose1_below f1 d1)) (min_loc [d1 \<mapsto> s1]) 
            \<mapsto> sum_size (dispose1_below f1 d1 \<dagger> [d1 \<mapsto> s1])])"
     proof -  
        from below_notempty have "\<exists>x. x\<in>dom f1 \<and> x + the (f1 x) = d1"
        proof -
          have "dispose1_below f1 d1 \<noteq> empty" by (rule below_notempty)
          then have "{ x \<in> dom f1 . x + the(f1 x) = d1 } \<noteq> {}"
              by (metis (full_types) dispose1_below_def l_dom_r_nothing)
          thus ?thesis  by (smt empty_Collect_eq)
        qed  
        then obtain below where belowinf1: "below\<in>dom f1" and belowplusf1below: "below + the (f1 below) = d1"
          by metis
        then have "below \<in> dom(dispose1_below f1 d1)"
          unfolding dispose1_below_def
          proof (subst l_dom_r_iff)
            show "below \<in> {x \<in> dom f1. x + the (f1 x) = d1} \<inter> dom f1"
            by (smt Int_Collect belowinf1 belowplusf1below inf_commute)
          qed
        then have dom_below: "dom (dispose1_below f1 d1) = {below}"
          unfolding dispose1_below_def
        sorry  
        have min_loc_below: "min_loc  (dispose1_below f1 d1) = below"
          unfolding min_loc_def
          by (metis Min_singleton below_notempty dom_below)
        have sum_size_below: "sum_size (dispose1_below f1 d1) = the (f1 below)"
          unfolding sum_size_def 
        apply (simp add: below_notempty)
        apply (subst dom_below)
          unfolding dispose1_below_def
        apply (subgoal_tac "{x. x+the(f1 x)= d1 \<and> x \<in> dom f1} = {below}") 
        apply (simp)
        apply (subst f_in_dom_r_apply_elem)
        apply simp
        apply (rule conjI)
        apply (rule belowinf1)
        apply (rule  belowplusf1below)
        apply (rule refl)
          by (metis (no_types) Collect_conj_eq Collect_mem_eq dispose1_below_def 
                dom_below inf.right_idem inf_commute l_dom_r_iff)
        have sum_size_dagger_below: "sum_size ((dispose1_below f1 d1) \<dagger> [d1 \<mapsto> s1]) =  the (f1 below) + s1"
        apply (subst sum_size_dagger_single, rule finite_dispose1_below,rule below_notempty,rule d1_not_dispose_below)
        by (simp add: sum_size_below)
        have res: "sep ({below} -\<triangleleft> f1 \<dagger> [below \<mapsto>  the (f1 below) + s1])"
            (* THIS IS WHAT I WANT TO PROVE *)
        proof (rule dagger_sep)
            show "sep ({below} -\<triangleleft> f1)" using sepf1 by (rule restr_sep)
            next 
            show "sep [below \<mapsto> the (f1 below) + s1]" 
            proof (rule sep_singleton)
              show "0 < the (f1 below) + s1"
                by (metis add_gr_0 l1_input_notempty nat1_def)
            qed
            next
            show " below \<notin> dom ({below} -\<triangleleft> f1)" by (metis f_in_dom_ar_notelem)
            next
            show "\<forall>l\<in>dom ({below} -\<triangleleft> f1). 
                l + the (({below} -\<triangleleft> f1) l) \<notin> dom [below \<mapsto> the (f1 below) + s1]"
            proof
              fix l assume lin_restr_dom:"l \<in> dom ({below} -\<triangleleft> f1)"
                have "l \<in> dom f1" using lin_restr_dom by (metis l_dom_ar_not_in_dom)
                have "l + the (({below} -\<triangleleft> f1) l) \<noteq> below"
                    by (metis `l \<in> dom f1` belowinf1 f_in_dom_ar_apply_subsume 
                      lin_restr_dom sep_def sepf1)
                 thus "l + the (({below} -\<triangleleft> f1) l) \<notin> dom [below \<mapsto> the (f1 below) + s1]"
                 by (metis dom_empty empty_iff l_inmapupd_dom_iff)
            qed
            next
            show " below + (the (f1 below) + s1) \<notin> dom ({below} -\<triangleleft> f1)"
            proof -
              have "below + (the (f1 below)) = d1"
              by (metis belowplusf1below)
              then have "d1 +s1 \<notin> dom ({below} -\<triangleleft> f1)"
               proof -
                have "dispose1_above f1 d1 s1 =  { x \<in> dom f1 . x = d1 + s1 } \<triangleleft> f1"
                  unfolding dispose1_above_def by simp
                  then have " { x \<in> dom f1 . x = d1 + s1 } = {}" 
                  by (smt Collect_empty_eq above_empty disjoint_iff_not_equal 
                    dom_def l_dom_r_iff mem_Collect_eq)
                  thus ?thesis by (metis Collect_conj_eq Collect_mem_eq 
                      Un_empty_left f_in_dom_ar_apply_not_elem l_dom_ar_nothing 
                        domIff l_dom_ar_not_in_dom2 f_in_dom_ar_notelem inf_commute 
                          insert_def sup_commute)
               qed
             thus ?thesis by (metis belowplusf1below nat_add_commute nat_add_left_commute)
        qed
        qed
        show ?thesis
        apply (subst dom_below)
        apply (subst min_loc_below)
        apply (subst min_loc_singleton)
        apply (subgoal_tac "min below d1 = below")
        apply simp
        apply (subst sum_size_dagger_below)
        apply (rule res)
        by (metis belowplusf1below le_add1 min_max.inf_absorb1)
      qed
    qed
    next (* CASE WHERE NON ARE EMPTY!!! *)
    assume above_notempty: " dispose1_above f1 d1 s1 \<noteq> Map.empty "
    have disjoint_above_below_d1: "dom (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1) \<inter> dom [d1 \<mapsto> s1] = {}"
      by (simp add: dagger_simps d1_not_dispose_above d1_not_dispose_below)
    have "sep ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<dagger>
     [min_loc  (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1  \<dagger> [d1 \<mapsto> s1]) 
     \<mapsto> sum_size (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1  \<dagger>  [d1 \<mapsto> s1]) ])"
     proof -
       (* NOW INTRODUCE PROPERTIES OF THIS *)
          (* FIRST BELOW - repeated proof here. refactor out! *)
        from below_notempty have "\<exists>x. x\<in>dom f1 \<and> x + the (f1 x) = d1"
        proof -
          have "dispose1_below f1 d1 \<noteq> empty" by (rule below_notempty)
          then have "{ x \<in> dom f1 . x + the(f1 x) = d1 } \<noteq> {}"
              by (metis (full_types) dispose1_below_def l_dom_r_nothing)
          thus ?thesis  by (smt empty_Collect_eq)
        qed  
        then obtain below where belowinf1: "below\<in>dom f1" and belowplusf1below: "below + the (f1 below) = d1"
          by metis
        then have "below \<in> dom(dispose1_below f1 d1)"
          unfolding dispose1_below_def
          proof (subst l_dom_r_iff)
            show "below \<in> {x \<in> dom f1. x + the (f1 x) = d1} \<inter> dom f1"
            by (smt Int_Collect belowinf1 belowplusf1below inf_commute)
          qed
        then have dom_below: "dom (dispose1_below f1 d1) = {below}"
          unfolding dispose1_below_def
        sorry  
        have min_loc_below: "min_loc  (dispose1_below f1 d1) = below"
          unfolding min_loc_def
          by (metis Min_singleton below_notempty dom_below)
        have sum_size_below: "sum_size (dispose1_below f1 d1) = the (f1 below)"
          unfolding sum_size_def 
        apply (simp add: below_notempty)
        apply (subst dom_below)
          unfolding dispose1_below_def
        apply (subgoal_tac "{x. x+the(f1 x)= d1 \<and> x \<in> dom f1} = {below}") 
        apply (simp)
        apply (subst f_in_dom_r_apply_elem)
        apply simp
        apply (rule conjI)
        apply (rule belowinf1)
        apply (rule  belowplusf1below)
        apply (rule refl)
          by (metis (no_types) Collect_conj_eq Collect_mem_eq dispose1_below_def 
                dom_below inf.right_idem inf_commute l_dom_r_iff)
        (* NOW ABOVE - already exists as lemmas *)
        (* NOW BOTH  - for now make explicit *)
        have above_below_union: "(dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) = {below,d1+s1}"
        by (metis Un_insert_left above_dom above_notempty dom_below sup_bot_left)
        have d1s1_a_b_union: "d1+s1 \<in> (dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1))"
          by (metis above_below_union insert_iff)
        have below_a_b_union: "below \<in> (dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1))"
          by (metis above_below_union insert_iff)
        have min_loc_above_below_d1: "min_loc (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1 \<dagger> [d1 \<mapsto> s1])
                                      = below"
        proof (subst dagger_min_loc_nonempty)
          show "dom (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1) \<inter> dom [d1 \<mapsto> s1] = {}" 
              by (rule disjoint_above_below_d1)
          show "finite (dom (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1))" 
              by (metis VDMMaps.dagger_finite finite_dispose1_above finite_dispose1_below)
          show "finite (dom [d1 \<mapsto> s1])" by (rule finite_singleton)
          show "dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1 \<noteq> Map.empty" 
            by (metis below_notempty l_dagger_not_empty)
          show "[d1 \<mapsto> s1] \<noteq> Map.empty" by (metis map_upd_nonempty)
          next
          show "min (min_loc (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1)) (min_loc [d1 \<mapsto> s1]) = below"
          proof (subst dagger_min_loc_nonempty,simp_all add: dispose_proof_simps,
                        rule above_notempty, rule below_notempty)
          (* Have removed cases I didn't need to show *)
          from above_notempty show "min (min (min_loc (dispose1_above f1 d1 s1))
              (min_loc (dispose1_below f1 d1))) (min_loc [d1 \<mapsto> s1]) = below"
           proof (simp add: belowplusf1below above_min_loc min_loc_below min_loc_singleton)
             have "min (d1 + s1) below = below" 
              by (metis belowplusf1below leI min_absorb1 min_max.inf_commute not_add_less1 trans_le_add1)
              moreover have "min below d1 = below" by (metis belowplusf1below min_max.inf.commute nat_min_absorb1)
              ultimately show "min (min (d1 + s1) below) d1 = below" by simp 
          qed
          qed
         qed
         have sum_size_above_below_d1: "sum_size (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1 \<dagger> [d1 \<mapsto> s1])
                                      =   the (f1 (d1 + s1)) + the (f1 below) + s1"
         proof (subst sum_size_dagger_single, simp_all add: dispose_proof_simps)
          show "finite (dom (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1))" 
              by (metis VDMMaps.dagger_finite finite_dispose1_above finite_dispose1_below)
          next
          show " dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1 \<noteq> Map.empty" 
            by (metis below_notempty l_dagger_not_empty)
          next
          show " d1 \<notin> dom (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1)" 
              by (metis d1_not_dispose_above d1_not_dispose_below domIff l_dagger_apply)
          next    
          show "sum_size (dispose1_above f1 d1 s1 \<dagger> dispose1_below f1 d1) 
                = the (f1 (d1 + s1)) + the (f1 below)"
          by (subst sum_size_dagger,simp_all add: dispose_proof_simps, 
              rule above_notempty, rule below_notempty, simp add: sum_size_below above_sumsize above_notempty)
          qed
         (* GOAL TO SOLVE! *)
         have "sep ({below,d1+s1} -\<triangleleft> f1 \<dagger> [below \<mapsto> the (f1 (d1 + s1)) + the (f1 below) + s1])"
         proof (rule dagger_sep) 
            show " sep ({below, d1 + s1} -\<triangleleft> f1)" using sepf1 by (rule restr_sep)
            next
            show "sep [below \<mapsto> the (f1 (d1 + s1)) + the (f1 below) + s1]"
            proof (rule sep_singleton)
              show " 0 < the (f1 (d1 + s1)) + the (f1 below) + s1"
                by (metis add_gr_0 l1_input_notempty nat1_def)
            qed
            next
            show "\<forall>l\<in>dom ({below, d1 + s1} -\<triangleleft> f1).
                    l + the (({below, d1 + s1} -\<triangleleft> f1) l) 
                      \<notin> dom [below \<mapsto> the (f1 (d1 + s1)) + the (f1 below) + s1]"
             proof (* COPY PASTE FROM PREVIOUS! *)
              fix l assume lin_restr_dom:" l \<in> dom ({below, d1 + s1} -\<triangleleft> f1)"
                have "l \<in> dom f1" using lin_restr_dom by (metis l_dom_ar_not_in_dom)
                have "l + the (({below, d1 + s1} -\<triangleleft> f1) l) \<noteq> below"
                    by (metis `l \<in> dom f1` belowinf1 f_in_dom_ar_apply_subsume 
                      lin_restr_dom sep_def sepf1)
                 thus "l + the (({below,d1+s1} -\<triangleleft> f1) l) \<notin> dom [below \<mapsto> the (f1 (d1 + s1)) + the (f1 below) + s1]"
                 by (metis dom_empty empty_iff l_inmapupd_dom_iff)
            qed
            next
            show "below + (the (f1 (d1 + s1)) + the (f1 below) + s1) \<notin> dom ({below, d1 + s1} -\<triangleleft> f1)"
               proof -
              have "below + (the (f1 below)) = d1"
              by (metis belowplusf1below)
              
              then have "(d1 +s1) + (the (f1 (d1 + s1))) \<notin> dom ({below,d1+s1} -\<triangleleft> f1)"
               by (metis above_d1s1_in_f1 above_notempty l_dom_ar_notin_dom_or sep_def sepf1)
               thus ?thesis by (smt belowplusf1below)
               qed
            next
            show " below \<notin> dom ({below, d1 + s1} -\<triangleleft> f1)" 
              by (metis insertI1 l_dom_ar_notin_dom_or)
         qed   
         thus ?thesis by (metis above_below_union min_loc_above_below_d1 sum_size_above_below_d1 )          
     qed
     thus ?thesis  unfolding dispose1_ext_def munion_def
      by (smt disjoint_above_below disjoint_above_below_d1) 
  qed
 qed
    thus ?thesis 
      unfolding munion_def apply (simp only: nonzero_inter_dom) by simp
qed  (********************* DISJOINT ******************)
         show " Disjoint
     ((dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<union>m
      [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
      (* The proof approach for disjoint is similar to sep. Only slightly easier? I hope :-) *) 
      proof -  
  have "Disjoint( (dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<dagger>
              [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)])"
  proof (cases "dispose1_below f1 d1 = empty")
    assume below_empty: "dispose1_below f1 d1 = empty"
    then show ?thesis
    proof (cases "dispose1_above f1 d1 s1 = empty")
      assume above_empty:  "dispose1_above f1 d1 s1 = empty"
      then show ?thesis (* BOTH ARE EMPTY *)
        unfolding dispose1_ext_def munion_def
      proof (simp add: below_empty l_dagger_empty_rhs  l_dagger_empty_lhs munion_def l_dom_ar_empty_lhs min_loc_singleton sum_size_singleton)
        show "Disjoint (f1 \<dagger> [d1 \<mapsto> s1])"  
        proof (rule dagger_Disjoint) (* STEAL LEO's conditions as they are much simpler! :-) *)
                                     (* Name: l_disjoint_singleton_upd *)
      qed
      next
      assume above_notempty:  " dispose1_above f1 d1 s1 \<noteq> Map.empty "
      then show ?thesis
        sorry (* ABOVE NOT EMPTY; BELOW EMPTY *)
    qed
   next
    assume below_notempty: "dispose1_below f1 d1 \<noteq> Map.empty"
    then show ?thesis
    proof(cases  "dispose1_above f1 d1 s1 = empty")
     assume above_empty:  "dispose1_above f1 d1 s1 = empty"
     then show ?thesis (* BOTH ARE EMPTY *)
       unfolding dispose1_ext_def munion_def
       sorry
     next
     assume above_notempty:  " dispose1_above f1 d1 s1 \<noteq> Map.empty "
     then show ?thesis
      sorry (* ABOVE NOT EMPTY; BELOW EMPTY *)
    qed
   qed
   thus ?thesis unfolding munion_def by (simp only: nonzero_inter_dom,simp)
  qed
qed
qed
qed 

lemma (in level1_dispose)
  locale1_dispose_FSB: "dispose1_feasibility"
unfolding dispose1_feasibility_def dispose1_postcondition_def 
proof(subst dispose1_equiv)
 obtain f1new where f1wit: "f1new = (dom (dispose1_below f1 d1) \<union> dom (dispose1_above f1 d1 s1)) -\<triangleleft> f1 \<union>m
              [min_loc (dispose1_ext f1 d1 s1) \<mapsto> sum_size (dispose1_ext f1 d1 s1)] "
 by auto
  from f1wit F1_inv_dispose show " \<exists>f'. dispose1_post2 f1 d1 s1 f' \<and> F1_inv f'" 
  using dispose1_post2_def sorry (* STOPEED WORKING FOR SOME TRIVIAL REASON *)
qed



lemma new1_dispose_1_identity_isar: 
  assumes nat1n: "nat1 n" (* Needed to add? *)
  and n1_post: "new1_post f n f' r"
  and d1_post: "dispose1_post f' r n f''"
  and inv: "F1_inv f"
  shows "f = f''"
proof - 
  from n1_post show ?thesis
  unfolding new1_post_def
  proof
    assume n1_eq: "new1_post_eq f n f' r"
    then show "f = f''"
      unfolding new1_post_eq_def
    proof(elim conjE)
      assume r_in_dom: "r \<in> dom f"
      and eq_n: "the (f r) = n"
      and f'_restr: "f' = {r} -\<triangleleft> f"
      from inv have *: "{x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r} = {}"
        proof
          assume sepf: "sep f"
            have "{x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r}
               =  {x \<in> dom ({r} -\<triangleleft> f). x + the (f x) = r}" 
                by (metis f_in_dom_ar_apply_subsume)
            also have "... \<subseteq> {x \<in> dom (f). x + the (f x) = r}" 
                by (smt Collect_empty_eq f_in_dom_ar_subsume r_in_dom sep_def sepf subsetI)
            also have "... = {}"
              by (smt Collect_empty_eq r_in_dom sep_def sepf)
          finally show ?thesis by simp
        qed
      (* Shape of below *)
      then have below_shape: "dispose1_below ({r} -\<triangleleft> f) r = empty"
        unfolding dispose1_below_def
        by (metis l_dom_r_nothing) 
       from inv have *: "{x \<in> dom ({r} -\<triangleleft> f). x = r + n} = {}"
          proof
            assume sepf: "sep f"
              have "{x \<in> dom ({r} -\<triangleleft> f). x = r + n} \<subseteq> {x \<in> dom (f). x = r + n}" 
                by (smt Collect_mono f_dom_ar_subset_dom set_rev_mp)
              also have "... = {}" by (smt empty_Collect_eq eq_n r_in_dom sep_def sepf)
            finally show ?thesis by simp
          qed
       (* Shape of above *)
      then have above_shape: "dispose1_above ({r} -\<triangleleft> f) r n = empty"
      unfolding dispose1_above_def
       by (metis l_dom_r_nothing)
      (* Shape of min_loc *)
      have min_loc_shape:  "min_loc (dispose1_ext ({r} -\<triangleleft> f) r n) = r"
        unfolding dispose1_ext_def
      proof - 
        have "dispose1_above ({r} -\<triangleleft> f) r n \<union>m dispose1_below ({r} -\<triangleleft> f) r \<union>m [r \<mapsto> n]
             = [r \<mapsto> n]" 
              by (simp add: above_shape l_munion_empty_lhs below_shape)
        moreover have "min_loc [r \<mapsto> n] = r" 
          unfolding min_loc_def
          by simp
          ultimately show "min_loc (dispose1_above ({r} -\<triangleleft> f) r n 
                              \<union>m dispose1_below ({r} -\<triangleleft> f) r \<union>m [r \<mapsto> n]) = r"
           by simp
      qed
      (* Final shape rule *)
      have sum_size_shape:  "sum_size (dispose1_ext ({r} -\<triangleleft> f) r n) = the(f r)"
        unfolding dispose1_ext_def
      proof - 
        have "dispose1_above ({r} -\<triangleleft> f) r n \<union>m dispose1_below ({r} -\<triangleleft> f) r \<union>m [r \<mapsto> n]
             = [r \<mapsto> n]" 
              by (simp add: above_shape l_munion_empty_lhs below_shape)
        moreover have "sum_size [r \<mapsto> n] = n" 
          unfolding sum_size_def by simp
        moreover have "the (f r) = n"by (rule eq_n)
        ultimately show "sum_size (dispose1_above ({r} -\<triangleleft> f) r n
                \<union>m dispose1_below ({r} -\<triangleleft> f) r \<union>m [r \<mapsto> n]) = the (f r)"
             by simp
      qed
      (* We are now able to rewrite f'' *)
      from d1_post show ?thesis
      proof (simp only: dispose1_equiv, unfold dispose1_post2_def)
        assume "f'' = (dom (dispose1_below f' r) \<union> dom (dispose1_above f' r n)) -\<triangleleft> f' \<union>m
          [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"
        then have "f'' = ((dom (empty) \<union> dom (empty)) -\<triangleleft> f'
                    \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)])"
             by (simp add: f'_restr below_shape above_shape)
        then have "f'' = {} -\<triangleleft> f'
                    \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"
                    by simp (* For some reason also wasn't working here!!! *)
        also have " ... =  f'
                    \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"          
            by (simp add: l_dom_ar_empty_lhs)
       also have "...= f' \<union>m [r \<mapsto> the (f r)]"
          by (simp add: min_loc_shape sum_size_shape f'_restr)
       also have "... = ({r} -\<triangleleft> f) \<union>m [r \<mapsto> the (f r)]"
          by (simp add: f'_restr)
       also have "... =  ({r} -\<triangleleft> f) \<dagger> [r \<mapsto> the (f r)]"
          proof -
            have "dom ({r} -\<triangleleft> f) \<inter> dom [r \<mapsto> the (f r)] = {}"
              by (metis Int_iff all_not_in_conv l_dom_ar_not_in_dom2 dom_eq_singleton_conv)
            thus ?thesis by (simp add: munion_def)
          qed 
      also have "... = f" using r_in_dom by (rule antirestr_then_dagger)
      finally show ?thesis ..
    qed
  qed
  next
    assume "new1_post_gr f n f' r"
    then show ?thesis
      unfolding new1_post_gr_def
    proof(elim conjE)
      assume r_in_dom: "r \<in> dom f"
      and gr_n: "the (f r) > n"
      and f'_restr: "f' = {r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]"
      
      have disjoint_dom: " dom f \<inter> dom [r + n \<mapsto> the (f r) - n] = {}"
      proof (simp)
      show "r + n \<notin> dom  f"
      proof (rule l_plus_s_not_in_f)
        show "F1_inv f" by (metis inv)
        next
        show "r \<in> dom  f" by (rule r_in_dom)
        next
        show "n < the (f r)" by (rule gr_n)
        next
        show "nat1 n" by (rule nat1n)
      qed
    qed
      have disjoint_dom_antirestr: " dom ({r} -\<triangleleft> f) \<inter> dom [r + n \<mapsto> the (f r) - n] = {}"
          by (metis disjoint_dom l_dom_ar_disjoint_weakening)
          from inv have "{x \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]).
                  x + the (({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) x) = r} = {}"
          proof
            assume sepf: "sep f"
              have "({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n])
                            =({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) "
                          by (metis  disjoint_dom_antirestr munion_def)
              then have "{x \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]).
                  x + the (({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) x) = r}
                 = {x \<in> dom ({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]).
                 x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}"
                  by simp                  
             also have "... = {x \<in> dom ({r} -\<triangleleft> f).
                 x + the (({r} -\<triangleleft> f) x) = r} \<union> {x\<in> dom ([r + n \<mapsto> the (f r) - n]).
                          x + the  ([r + n \<mapsto> the (f r) - n] x) = r}"
             proof (subst l_dagger_dom)
                show "{x \<in> dom ({r} -\<triangleleft> f) \<union> dom [r + n \<mapsto> the (f r) - n]. 
                          x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}
                   =   {x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r} 
                     \<union> {x \<in> dom [r + n \<mapsto> the (f r) - n]. x + the ([r + n \<mapsto> the (f r) - n] x) = r}"
                proof (subst union_comp)
                  show "{x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}
                      \<union> {x \<in> dom [r + n \<mapsto> the (f r) - n]. x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}
                   =   {x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r} 
                     \<union> {x \<in> dom [r + n \<mapsto> the (f r) - n]. x + the ([r + n \<mapsto> the (f r) - n] x) = r}"
                  proof - 
                    have " {x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}
                      = {x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r}"
                        by (metis Int_iff `{r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n] = {r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]`
                       disjoint_dom_antirestr dom_eq_singleton_conv empty_iff f'_restr the_dagger_dom_left)
                   moreover have " {x \<in> dom [r + n \<mapsto> the (f r) - n]. x + the (({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]) x) = r}
                            = {x \<in> dom [r + n \<mapsto> the (f r) - n]. x + the ([r + n \<mapsto> the (f r) - n] x) = r}"
                            by (metis (lifting) l_dagger_apply)
                  ultimately show ?thesis by auto
                 qed
               qed
             qed
            also have "... = {}"
                proof - 
                  have "{x\<in> dom ([r + n \<mapsto> the (f r) - n]).
                          x + the  ([r + n \<mapsto> the (f r) - n] x) = r} = {}"
                   by (smt add_implies_diff comm_monoid_add_class.add.left_neutral 
                      diff_add_zero dom_empty empty_Collect_eq empty_iff gr_n fun_upd_same 
                      l_inmapupd_dom_iff less_nat_zero_code nat_add_commute the.simps)
                 moreover have "{x \<in> dom ({r} -\<triangleleft> f).
                 x + the (({r} -\<triangleleft> f) x) = r} = {}"
                 proof -  
                  have "{x \<in> dom ({r} -\<triangleleft> f). x + the (({r} -\<triangleleft> f) x) = r}
                    \<subseteq> {x \<in> dom (f). x + the (f x) = r}"
                      by (smt Collect_empty_eq f_in_dom_ar_subsume f_in_dom_ar_the_subsume r_in_dom sep_def sepf subsetI)
                  also have "... = {}"
                    by (smt Collect_empty_eq r_in_dom sep_def sepf)
                  finally show ?thesis by simp
                 qed
                ultimately show ?thesis by simp
            qed
            finally show ?thesis by simp
          qed
      (* Shape of below *)
      then have below_shape: "dispose1_below ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) r = empty"
         unfolding dispose1_below_def
        by (metis l_dom_r_nothing)
      have above_shape: "dispose1_above ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) r n = [r + n \<mapsto> the(f r) - n]"
      unfolding dispose1_above_def
      proof -
        have "{x \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]). x = r + n} = {r+n}"
        proof -
          have "{x \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]). x = r + n} =
                    {x \<in> dom ({r} -\<triangleleft> f \<dagger> [r + n \<mapsto> the (f r) - n]). x = r + n}"
                    unfolding munion_def by (subst disjoint_dom_antirestr, simp) 
          also have "... =  {x \<in> dom ({r} -\<triangleleft> f). x = r + n} \<union> 
                {x \<in> dom ([r + n \<mapsto> the (f r) - n]). x = r + n}"
                by(subst l_dagger_dom,rule union_comp)
          also have "... = {x \<in> dom ({r} -\<triangleleft> f). x = r + n} \<union> {r+n}"
            by auto
          also have "... = {r+n}"
          proof - 
            have " {x \<in> dom ({r} -\<triangleleft> f). x = r + n} = {}" 
              by (smt Collect_empty_eq f_in_dom_ar_subsume gr_n inv
                  l_plus_s_not_in_f nat1n r_in_dom)
            thus ?thesis by auto
         qed
         finally show ?thesis by simp
       qed
        moreover have "{r+n} \<triangleleft> ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) = [r + n \<mapsto> the (f r) - n]"
        proof (subst domrestr_singleton)
          show "r + n \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n])" 
            by (smt calculation empty_Collect_eq insert_compr)
         next
         show "[r + n \<mapsto> the (({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) (r + n))] 
                = [r + n \<mapsto> the (f r) - n]"
                by (metis dagger_upd_dist disjoint_dom_antirestr fun_upd_same munion_def the.simps)
        qed
        ultimately show " {x \<in> dom ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]). x = r + n} \<triangleleft> ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) = [r + n \<mapsto> the (f r) - n]"
        by auto
      qed
      have min_loc_shape: "min_loc (dispose1_ext ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) r n) = r"
        unfolding dispose1_ext_def
      proof ( simp add: above_shape below_shape)
        show "min_loc ([r + n \<mapsto> the (f r) - n] \<union>m Map.empty \<union>m [r \<mapsto> n]) = r"
        proof - 
            have without_empty: "[r + n \<mapsto> the (f r) - n] \<union>m Map.empty \<union>m [r \<mapsto> n]
            = [r + n \<mapsto> the (f r) - n] \<union>m [r \<mapsto> n]"
              by (metis l_munion_empty_rhs)
           then have "min_loc ([r + n \<mapsto> the (f r) - n] \<union>m [r \<mapsto> n]) 
                    = min_loc ([r + n \<mapsto> the (f r) - n] \<dagger> [r \<mapsto> n])"
           proof -
            have "dom ([r + n \<mapsto> the (f r) - n])\<inter> dom( [r \<mapsto> n]) = {r+n} \<inter> {r}"
              by auto
            also have "... = {}" using nat1n by auto
            finally show ?thesis by (simp add: munion_def)
           qed
           also have "...  = min (min_loc [r + n \<mapsto> the (f r) - n]) (min_loc [r \<mapsto> n])"
           by(rule min_loc_dagger,simp_all)
          also have "... = min (r+n) (r)" by (simp add: min_loc_singleton) 
          also have "... = r" by simp
          finally show ?thesis using without_empty by simp 
        qed
      qed
      have sum_size_shape: "sum_size (dispose1_ext ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n]) r n) = the(f r)"
        unfolding dispose1_ext_def
      proof ( simp add: above_shape below_shape)
        show "sum_size ([r + n \<mapsto> the (f r) - n] \<union>m empty \<union>m [r \<mapsto> n]) = the (f r)"
        proof - 
            have without_empty: "[r + n \<mapsto> the (f r) - n] \<union>m Map.empty \<union>m [r \<mapsto> n]
            = [r + n \<mapsto> the (f r) - n] \<union>m [r \<mapsto> n]"
              by (metis l_munion_empty_rhs)
            then have "sum_size ([r + n \<mapsto> the (f r) - n] \<union>m [r \<mapsto> n]) 
                 = sum_size ([r + n \<mapsto> the (f r) - n]) + sum_size ([r \<mapsto> n])"
                 apply (subst  sum_size_munion, simp_all)
                 by (metis nat1_def nat1n)
            also have "... = the (f r) - n + n" by (simp add: sum_size_singleton)
            also have "... = the (f r)"  by (metis gr_n le_add_diff_inverse
                                          nat_add_commute termination_basic_simps(5))
          finally show ?thesis using without_empty by simp 
        qed
     qed
       from d1_post show ?thesis
      proof (simp only: dispose1_equiv, unfold dispose1_post2_def)
      assume "f'' = (dom (dispose1_below f' r) \<union> dom (dispose1_above f' r n)) -\<triangleleft> f' 
          \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"
      then have "f'' = 
              {r+n}  -\<triangleleft> f' \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"
               by (simp add: f'_restr below_shape above_shape)
     also have "... = ({r} -\<triangleleft> f) \<union>m [min_loc (dispose1_ext f' r n) \<mapsto> sum_size (dispose1_ext f' r n)]"
        proof -
          have "{r+n} -\<triangleleft> f' = {r+n} -\<triangleleft> ({r} -\<triangleleft> f \<union>m [r + n \<mapsto> the (f r) - n])"
            by (simp add: f'_restr)
          also have "... =  {r+n} -\<triangleleft> ({r} -\<triangleleft> (f \<union>m [r + n \<mapsto> the (f r) - n]))"
          proof(subst l_munion_dom_ar_assoc)
            show " {r} \<subseteq> dom f" by (simp add: r_in_dom)
          next
            show " dom f \<inter> dom [r + n \<mapsto> the (f r) - n] = {}" by (rule disjoint_dom)
          next 
            show "{r + n} -\<triangleleft> {r} -\<triangleleft> (f \<union>m [r + n \<mapsto> the (f r) - n]) =
                  {r + n} -\<triangleleft> {r} -\<triangleleft> (f \<union>m [r + n \<mapsto> the (f r) - n])" ..
          qed
          also have "... =  {r} -\<triangleleft> ({r+n} -\<triangleleft> (f \<union>m [r + n \<mapsto> the (f r) - n]))"
            by (metis Un_commute above_shape l_dom_ar_insert f'_restr insert_is_Un)
           also have "... =  {r} -\<triangleleft> ({r+n} -\<triangleleft> (f \<dagger> [r + n \<mapsto> the (f r) - n]))"
            unfolding munion_def
            by (simp only: disjoint_dom,simp)
           also have "... =  {r} -\<triangleleft> f"
           proof (subst antirestr_then_dagger_notin)
            show "r+n \<notin> dom f" using disjoint_dom by auto
            next
            show " {r} -\<triangleleft> f = {r} -\<triangleleft> f" ..
           qed
           finally show ?thesis by simp
         qed
         also have "... =  ({r} -\<triangleleft> f) \<union>m [r \<mapsto> the (f r)]"
            by (simp add: min_loc_shape sum_size_shape f'_restr)
         also have "... =  ({r} -\<triangleleft> f) \<dagger> [r \<mapsto> the (f r)]"
          proof -
            have "dom ({r} -\<triangleleft> f) \<inter> dom [r \<mapsto> the (f r)] = {}"
              by (metis Int_iff all_not_in_conv l_dom_ar_not_in_dom2 dom_eq_singleton_conv)
            thus ?thesis by (simp add: munion_def)
          qed 
      also have "... = f" using r_in_dom by (rule antirestr_then_dagger)
      finally show ?thesis ..
    qed
  qed
qed
qed


end
