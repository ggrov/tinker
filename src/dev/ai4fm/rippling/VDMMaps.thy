(* $Id: VDMMaps.thy 1677 2013-07-16 13:13:39Z iwhitesi $ *)
theory VDMMaps
imports Map SMT
begin


(* chapter {* Heap Level 1 *}
*)
text {*  
      *}

(*========================================================================*)
section {* Extra map operators *}
(*========================================================================*)

definition
  dom_restr :: "'a set \<Rightarrow> ('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixr "\<triangleleft>" 110)
where
  [intro!]: "s \<triangleleft> m \<equiv> m |` s"

definition
  ran_restr :: "('a \<rightharpoonup> 'b) \<Rightarrow> 'b set \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixl "\<triangleright>" 105)
where
  "m \<triangleright> s \<equiv> (\<lambda>x . if (\<exists> y. m x = Some y \<and> y \<in> s) then m x else None)"

definition
  dom_antirestr :: "'a set \<Rightarrow> ('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixr "-\<triangleleft>" 110)
where
  "s -\<triangleleft> m \<equiv> (\<lambda>x. if x : s then None else m x)"

definition
  ran_antirestr :: "('a \<rightharpoonup> 'b) \<Rightarrow> 'b set \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixl "\<triangleright>-" 105)
where
  "m \<triangleright>- s \<equiv> (\<lambda>x . if (\<exists> y. m x = Some y \<and> y \<in> s) then None else m x)"

definition
  dagger :: "('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixl "\<dagger>" 100)
where
  [intro!]: "f \<dagger> g \<equiv> f ++ g"

definition
  munion :: "('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b) \<Rightarrow> ('a \<rightharpoonup> 'b)" (infixl "\<union>m" 90)
where
  [intro!]: "f \<union>m g \<equiv> (if dom f \<inter> dom g = {} then f \<dagger> g else undefined)"

text {* And by the way, this use of Isabelle's undefined value is a bit of
        a cheeky cheat. It basically means we shouldn't get to undefined,
        rather than we are handling undefinedness. That's because the value
        is comparable (see next lemma). In effect, if we ever reach undefined
        it means we have some partial function application outside its domain
        somewhere within any rewriting chain. As one cannot reason about this
        value, it can be seen as a flag for an error to be avoided.
      *}

(*
lemma silly : "undefined = undefined"
apply (rule refl)
oops 
*) (* NOT TRUE IN VDM! WE KNOW *)

(*========================================================================*)
section {* Set operators lemmas *}
(*========================================================================*)

lemma l_psubset_insert: "x \<notin> S \<Longrightarrow> S \<subset> insert x S"
by blast

lemma l_right_diff_left_dist: "S - (T - U) = (S - T) \<union> (S \<inter> U)"
by (metis Diff_Compl Diff_Int diff_eq)
  thm Diff_Compl
      Diff_Int
      diff_eq

(*========================================================================*)
section {* Map operators lemmas *}
(*========================================================================*)

lemma l_map_non_empty_has_elem_conv:
  "g \<noteq> empty \<longleftrightarrow> (\<exists> x . x \<in> dom g)"
by (metis domIff)

lemma l_map_non_empty_dom_conv:
  "g \<noteq> empty \<longleftrightarrow> dom g \<noteq> {}"
by (metis dom_eq_empty_conv)

lemma l_map_non_empty_ran_conv:
  "g \<noteq> empty \<longleftrightarrow> ran g \<noteq> {}"
by (metis empty_iff equals0I 
          fun_upd_triv option.exhaust 
          ranI ran_restrictD restrict_complement_singleton_eq)

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Domain restriction weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* Lemma: dom restriction set inter equiv [ZEVES-LEMMA] *)
lemma l_dom_r_iff: "dom(S \<triangleleft> g) = S \<inter> dom g"
by (metis Int_commute dom_restr_def dom_restrict)

(* Lemma: dom restriction set inter equiv [ZEVES-LEMMA] *)
lemma l_dom_r_subset: "(S \<triangleleft> g) \<subseteq>\<^sub>m g"
by (metis Int_iff dom_restr_def l_dom_r_iff map_le_def restrict_in)

(* Lemma: dom restriction set inter equiv [ZEVES-LEMMA] *)
lemma l_dom_r_accum: "S \<triangleleft> (T \<triangleleft> g) = (S \<inter> T) \<triangleleft> g"
by (metis Int_commute dom_restr_def restrict_restrict)

(* Lemma: dom restriction set inter equiv [ZEVES-LEMMA] *)
lemma l_dom_r_nothing: "{} \<triangleleft> f = empty"
by (metis dom_restr_def restrict_map_to_empty)

(* Lemma: dom restriction set inter equiv [ZEVES-LEMMA] *)
lemma l_dom_r_empty: "S \<triangleleft> empty = empty"
by (metis dom_restr_def restrict_map_empty)

(* FD: in specific dom subsumes application (over Some+None) [ZEVES-LEMMA] *)
(*
lemma f_in_dom_r_apply_elem: 
  "l \<in> dom f \<and> l \<in> S \<Longrightarrow> ((S \<triangleleft> f) l) = (f l)"
unfolding dom_restr_def
by (cases "l\<in>S", auto)
*)
(* IJW: Simplified as doesn't need the l:dom f case *)
lemma  f_in_dom_r_apply_elem: " x \<in> S \<Longrightarrow> ((S \<triangleleft> f) x) = (f x)"
by (metis dom_restr_def restrict_in)


(* IJW: TODO: classify; rename. *) 
lemma l_dom_r_disjoint_weakening: "A \<inter> B = {} \<Longrightarrow> dom(A \<triangleleft> f) \<inter> dom(B \<triangleleft> f) = {}"
by (metis dom_restr_def dom_restrict inf_bot_right inf_left_commute restrict_restrict)

(* IJW: TODO: classify; rename - refactor out for l_dom_r_iff? *)
lemma l_dom_r_subseteq: "S \<subseteq> dom f \<Longrightarrow> dom (S \<triangleleft> f) = S" unfolding dom_restr_def
by (metis Int_absorb1 dom_restrict)

(* IJW: TODO: classift; rename  - refactor out for l_dom_r_subset? *)
lemma l_dom_r_dom_subseteq: "(dom ( S \<triangleleft> f)) \<subseteq> dom f" 
unfolding dom_restr_def by auto

(* IJW: An experiment - not sure which are the best rules to choose! *)
lemmas restr_simps = l_dom_r_iff l_dom_r_accum l_dom_r_nothing l_dom_r_empty
                     f_in_dom_r_apply_elem l_dom_r_disjoint_weakening l_dom_r_subseteq
                     l_dom_r_dom_subseteq

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Domain anti restriction weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* FD: dom elem subsume dom ar *)
lemma f_in_dom_ar_subsume: "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow>  l \<in> dom f"
unfolding dom_antirestr_def
by (cases "l\<in>S", auto)

(* FD: in specific dom_ar cannot be what's filtered *)
lemma f_in_dom_ar_notelem: "l \<in> dom ({r} -\<triangleleft> f) \<Longrightarrow> l \<noteq> r"
unfolding dom_antirestr_def
by auto

(* FD: in specific dom_ar subsumes application (over Some) *)
lemma f_in_dom_ar_the_subsume: 
  "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow> the ((S -\<triangleleft> f) l) = the (f l)"
unfolding dom_antirestr_def
by (cases "l\<in>S", auto)

(* FD: in specific dom_ar subsumes application (over Some+None) *)
lemma f_in_dom_ar_apply_subsume: 
  "l \<in> dom (S -\<triangleleft> f) \<Longrightarrow> ((S -\<triangleleft> f) l) = (f l)"
unfolding dom_antirestr_def
by (cases "l\<in>S", auto)

(* FD: in specific dom subsumes application (over Some+None) [ZEVES-LEMMA] *)
(*
lemma f_in_dom_ar_apply_not_elem: 
  "l \<in> dom f \<and> l \<notin> S \<Longrightarrow> ((S -\<triangleleft> f) l) = (f l)"
unfolding dom_antirestr_def
by (cases "l\<in>S", auto)
*)
(* IJW: TODO: I had a more general lemma: *)
lemma f_in_dom_ar_apply_not_elem: "l \<notin> S \<Longrightarrow> (S -\<triangleleft> f) l = f l"
by (metis dom_antirestr_def)

(* FD: dom_ar subset dom [ZEVES-LEMMA] *)
lemma f_dom_ar_subset_dom:
	"dom(S -\<triangleleft> f) \<subseteq> dom f"
unfolding dom_antirestr_def dom_def
by auto

(* Lemma: dom_ar as set different [ZEVES-LEMMA] *)
lemma l_dom_dom_ar:
	"dom(S -\<triangleleft> f) = dom f - S"
unfolding dom_antirestr_def
by (smt Collect_cong domIff dom_def set_diff_eq)

(* Lemma: dom_ar accumulates to left [ZEVES-LEMMA] *)
lemma l_dom_ar_accum:
	"S -\<triangleleft> (T -\<triangleleft> f) = (S \<union> T) -\<triangleleft> f"
unfolding dom_antirestr_def
by auto

(* Lemma: dom_ar subsumption [ZEVES-LEMMA] *)
lemma l_dom_ar_nothing:
	"S \<inter> dom f = {} \<Longrightarrow> S -\<triangleleft> f = f"
unfolding dom_antirestr_def
apply (simp add: fun_eq_iff)
by (metis disjoint_iff_not_equal domIff)

(* NOTE: After finding fun_eq_iff, there is also map_le_antisym for maps!*)

(* Lemma: dom_ar nothing LHS [ZEVES-LEMMA] *)
lemma l_dom_ar_empty_lhs:
  "{} -\<triangleleft> f = f"
by (metis Int_empty_left l_dom_ar_nothing)

(* Lemma: dom_ar nothing RHS [ZEVES-LEMMA] *)
lemma l_dom_ar_empty_rhs:
  "S -\<triangleleft> empty = empty"
by (metis Int_empty_right dom_empty l_dom_ar_nothing)

(* Lemma: dom_ar all RHS is empty [ZEVES-LEMMA] *)
lemma l_dom_ar_everything:
  "dom f \<subseteq> S \<Longrightarrow> S -\<triangleleft> f = empty"
by (metis domIff dom_antirestr_def in_mono)

(* Lemma: dom_ar submap [ZEVES-LEMMA] *)
lemma l_map_dom_ar_subset: "S -\<triangleleft> f \<subseteq>\<^sub>m f"
by (metis domIff dom_antirestr_def map_le_def)

(* Lemma: dom_ar nothing RHS is f [ZEVES-LEMMA] *)
lemma l_dom_ar_none: "{} -\<triangleleft> f = f"
unfolding dom_antirestr_def
by (simp add: fun_eq_iff)

(* Lemma: dom_ar something RHS isn't f [ZEVES-LEMMA] *)
lemma l_map_dom_ar_neq: "S \<subseteq> dom f \<Longrightarrow> S \<noteq> {} \<Longrightarrow> S -\<triangleleft> f \<noteq> f"
apply (subst fun_eq_iff)
apply (insert ex_in_conv[of S])
apply simp
apply (erule exE)
unfolding dom_antirestr_def
apply (rule exI)
apply simp
apply (intro impI conjI)
apply simp_all
by (metis domIff set_mp)


(* IJW: TODO classify; rename *)
lemma l_dom_ar_not_in_dom:
  assumes *: "x \<notin> dom f"
  shows  "x \<notin> dom (s -\<triangleleft> f)"
by (metis * domIff dom_antirestr_def)

(* IJW: TODO: classify; rename *)
lemma l_dom_ar_not_in_dom2: "x \<in> F \<Longrightarrow> x \<notin> dom (F  -\<triangleleft> f)"
by (metis domIff dom_antirestr_def)

lemma l_dom_ar_notin_dom_or: "x \<notin> dom f \<or> x \<in> S \<Longrightarrow> x \<notin> dom (S -\<triangleleft> f)"
by (metis Diff_iff l_dom_dom_ar)

(* IJW: TODO: classify - shows conditions for being in antri restr dom *)
lemma l_in_dom_ar: "x \<notin> F \<Longrightarrow> x \<in> dom f \<Longrightarrow> x \<in> dom  (F  -\<triangleleft> f)"
by (metis f_in_dom_ar_apply_not_elem domIff) 


(* IJW: TODO: classify; fix proof; rename; decide whether needed?! *)
lemma l_dom_ar_insert: "((insert x F) -\<triangleleft> f) = {x} -\<triangleleft> (F-\<triangleleft> f)" 
proof
  fix xa
  show "(insert x F -\<triangleleft> f) xa = ({x} -\<triangleleft> F -\<triangleleft> f) xa"
  apply (cases "x= xa")
  apply (simp add: dom_antirestr_def)
  apply (cases "xa\<in>F")
  apply (simp add: dom_antirestr_def)
  apply (subst f_in_dom_ar_apply_not_elem)
  apply simp
  apply (subst f_in_dom_ar_apply_not_elem)
  apply simp
  apply (subst f_in_dom_ar_apply_not_elem)
  apply simp
  apply simp  
  done
qed


(* IJW: TODO: classify; rename?; subsume by l_dom_ar_accum? *)
(* IJW: Think it may also be unused? *)
lemma l_dom_ar_absorb_singleton: "x \<in> F \<Longrightarrow> ({x} -\<triangleleft> F -\<triangleleft> f) =(F -\<triangleleft> f)"
by (metis l_dom_ar_insert insert_absorb)

(* IJW: TODO: rename; classify; generalise? *)
lemma l_dom_ar_disjoint_weakening:
  "dom f \<inter> Y = {} \<Longrightarrow> dom (X -\<triangleleft> f) \<inter> Y = {}" 
 by (metis Diff_Int_distrib2 empty_Diff l_dom_dom_ar)

(* IJW: TODO: not used? *)
lemma l_dom_ar_singletons_comm: "{x}-\<triangleleft> {y} -\<triangleleft> f = {y}-\<triangleleft> {x} -\<triangleleft> f" 
    by (metis l_dom_ar_insert insert_commute)

lemmas antirestr_simps = f_in_dom_ar_subsume f_in_dom_ar_notelem f_in_dom_ar_the_subsume
f_in_dom_ar_apply_subsume f_in_dom_ar_apply_not_elem f_dom_ar_subset_dom
l_dom_dom_ar l_dom_ar_accum l_dom_ar_nothing l_dom_ar_empty_lhs l_dom_ar_empty_rhs
l_dom_ar_everything l_dom_ar_none l_dom_ar_not_in_dom l_dom_ar_not_in_dom2
l_dom_ar_notin_dom_or l_in_dom_ar l_dom_ar_disjoint_weakening

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Map override weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* Lemma: dagger associates [ZEVES-LEMMA] *)
lemma l_dagger_assoc:
  "f \<dagger> (g \<dagger> h) = (f \<dagger> g) \<dagger> h"
by (metis dagger_def map_add_assoc)
thm ext option.split fun_eq_iff (* EXT! Just found function extensionality! *)

(* Lemma: dagger application [ZEVES-LEMMA] *)
lemma l_dagger_apply:
	"(f \<dagger> g) x = (if x \<in> dom g then (g x) else (f x))"
unfolding dagger_def
by (metis (full_types) map_add_dom_app_simps(1) map_add_dom_app_simps(3))

(* Lemma: dagger domain [ZEVES-LEMMA] *)
lemma l_dagger_dom:
	"dom(f \<dagger> g) = dom f \<union> dom g"
unfolding dagger_def
by (metis dom_map_add sup_commute)

(* Lemma: dagger absorption LHS *)
lemma l_dagger_lhs_absorb:
  "dom f \<subseteq> dom g \<Longrightarrow> f \<dagger> g = g"
by (rule ext) (metis dagger_def l_dagger_apply map_add_dom_app_simps(2) set_rev_mp)

lemma l_dagger_lhs_absorb_ALT_PROOF:
  "dom f \<subseteq> dom g \<Longrightarrow> f \<dagger> g = g"
apply (rule ext)
apply (simp add: l_dagger_apply)
apply (rule impI)
find_theorems "_ \<notin> _ \<Longrightarrow> _" name:Set 
apply (drule contra_subsetD)
unfolding dom_def
by (simp_all)   (* NOTE: foun nice lemmas to be used: contra_subsetD*)

(* Lemma: dagger empty absorption lhs [ZEVES-LEMMA] *)
lemma l_dagger_empty_lhs:
  "empty \<dagger> f = f"
by (metis dagger_def empty_map_add)

(* Lemma: dagger empty absorption rhs [ZEVES-LEMMA] *)
lemma l_dagger_empty_rhs:
  "f \<dagger> empty = f"
by (metis dagger_def map_add_empty)

(* Interesting observation here:

A few times I have spotted this. I then to get these
lemmas and use them in Isar; whereas Leo, you don't seem
to use this variety. Probably because the automation takes
care of the reasoning?...
*)
(* IJW: TODO: Rename; classify *)
lemma dagger_notemptyL: "f \<noteq> empty \<Longrightarrow> f \<dagger> g \<noteq> empty" by (metis dagger_def map_add_None)

lemma dagger_notemptyR: "g \<noteq> empty \<Longrightarrow> f \<dagger> g \<noteq> empty" by (metis dagger_def map_add_None)


(* Lemma: dagger associates with dom_ar [ZEVES-LEMMA] *)
(* IJW: It's not really an assoc prop? Well, kinda, but also kinda distrib *)
lemma l_dagger_dom_ar_assoc:
	"S \<inter> dom g = {} \<Longrightarrow> (S -\<triangleleft> f) \<dagger> g = S -\<triangleleft> (f \<dagger> g)"
apply (simp add: fun_eq_iff)
apply (simp add: l_dagger_apply)
apply (intro allI impI conjI)
unfolding dom_antirestr_def
apply (simp_all add: l_dagger_apply)
by (metis dom_antirestr_def l_dom_ar_nothing)
thm map_add_comm
   (* NOTE: This should be provable, if only I know how to do map extensionality :-(. Now I do! fun_eq_iff! 
   			Thm map_add_comm is quite nice lemma two, and could be used here, yet l_dagger_apply seems nicer.
    *)

lemma l_dagger_not_empty:
  "g \<noteq> empty \<Longrightarrow> f \<dagger> g \<noteq> empty"
by (metis dagger_def map_add_None)

(* IJW TODO: Following 6 need renamed; classified? LEO: how do you do such choices? *)
lemma in_dagger_domL:
  "x \<in> dom f \<Longrightarrow> x \<in> dom(f \<dagger> g)" 
by (metis dagger_def domIff map_add_None)

lemma in_dagger_domR:
  "x \<in> dom g \<Longrightarrow> x \<in> dom(f \<dagger> g)" 
by (metis dagger_def domIff map_add_None)

lemma the_dagger_dom_right:
  assumes "x \<in> dom g"
  shows "the ((f \<dagger> g) x) = the (g x)"    
by (metis assms dagger_def map_add_dom_app_simps(1))

lemma the_dagger_dom_left:
  assumes  "x \<notin> dom g"
  shows "the ((f \<dagger> g) x) = the (f x)"
by (metis assms dagger_def map_add_dom_app_simps(3))    

lemma the_dagger_mapupd_dom: "x\<noteq>y \<Longrightarrow>  (f \<dagger> [y \<mapsto> z]) x = f x "
by (metis dagger_def fun_upd_other map_add_empty map_add_upd)

lemma dagger_upd_dist: "f \<dagger> fa(e \<mapsto> r) = (f \<dagger> fa)(e \<mapsto> r)" by (metis dagger_def map_add_upd)

(* IJW TOD): rename *)
lemma antirestr_then_dagger_notin: "x \<notin> dom f \<Longrightarrow> {x} -\<triangleleft> (f \<dagger> [x \<mapsto> y]) = f"
proof
  fix z
  assume "x \<notin> dom f"
  show "({x} -\<triangleleft> (f \<dagger> [x \<mapsto> y])) z = f z"
  by (metis `x \<notin> dom f`  domIff dom_antirestr_def fun_upd_other insertI1 l_dagger_apply singleton_iff)  
qed
lemma antirestr_then_dagger: "r\<in> dom f \<Longrightarrow> {r} -\<triangleleft> f \<dagger> [r \<mapsto> the (f r)] = f"
proof
  fix x
  assume *: "r\<in>dom f"
  show "({r} -\<triangleleft> f \<dagger> [r \<mapsto> the (f r)]) x = f x"
  proof (subst l_dagger_apply,simp,intro conjI impI)
    assume "x=r" then show "Some (the (f r)) = f r" using * by auto
    next
    assume "x \<noteq>r" then show " ({r} -\<triangleleft> f) x = f x" by (metis f_in_dom_ar_apply_not_elem singleton_iff)
  qed
qed 


(* IJW: TODO: rename; classify *)
lemma dagger_notin_right: "x \<notin> dom g \<Longrightarrow> (f \<dagger> g) x = f x" 
by (metis l_dagger_apply)
(* IJW: TODO: rename; classify *)

lemma dagger_notin_left: "x \<notin> dom f \<Longrightarrow> (f \<dagger> g) x = g x"
 by (metis dagger_def map_add_dom_app_simps(2))


lemma l_dagger_commute: "dom f \<inter> dom g = {} \<Longrightarrow>f \<dagger> g = g \<dagger> f"
  unfolding dagger_def 
apply (rule map_add_comm) by simp

lemmas dagger_simps = l_dagger_assoc l_dagger_apply l_dagger_dom l_dagger_lhs_absorb
l_dagger_empty_lhs l_dagger_empty_rhs dagger_notemptyL dagger_notemptyR l_dagger_not_empty
in_dagger_domL in_dagger_domR the_dagger_dom_right the_dagger_dom_left the_dagger_mapupd_dom
dagger_upd_dist antirestr_then_dagger_notin antirestr_then_dagger dagger_notin_right
dagger_notin_left

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Map update weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

text {* without the condition nitpick finds counter example TODO: ADD EXPLANATION/WHY-TAGS*}
lemma l_inmapupd_dom_iff:  
  "l \<noteq> x \<Longrightarrow> (l \<in> dom (f(x \<mapsto> y))) = (l \<in> dom f)"
by (metis (full_types) domIff fun_upd_apply)

lemma l_inmapupd_dom:  
  "l \<in> dom f \<Longrightarrow> l \<in> dom (f(x \<mapsto> y))"
by (metis dom_fun_upd insert_iff option.distinct(1))

lemma l_dom_extend: 
  "x \<notin> dom f \<Longrightarrow>  dom (f1(x \<mapsto> y)) = dom f1 \<union> {x}" 
by simp

lemma l_updatedom_eq: 
  "x=l \<Longrightarrow> the ((f(x \<mapsto> the (f x) - s)) l) = the (f l) - s"
by auto

lemma l_updatedom_neq: 
  "x\<noteq>l \<Longrightarrow> the ((f(x \<mapsto> the (f x) - s)) l) = the (f l)"
by auto

--"A helper lemma to have map update when domain is updated"
lemma l_insertUpdSpec_aux: "dom f = insert x F \<Longrightarrow> (f0 = (f |` F)) \<Longrightarrow> f = f0 (x \<mapsto> the (f x))"
proof auto
  assume insert: "dom f = insert x F"
  then have "x \<in> dom f" by simp
  then show "f = (f |` F)(x \<mapsto> the (f x))" using insert
         unfolding dom_def
         apply simp
         apply (rule ext)
         apply auto
         done
qed

lemmas upd_simps = l_inmapupd_dom_iff l_inmapupd_dom l_dom_extend
                  l_updatedom_eq l_updatedom_neq

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Map union (VDM-specific) weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* Weaken: munion point-wise update well-definedness condition *)
lemma k_munion_map_upd_wd: 
  "x \<notin> dom f \<Longrightarrow> dom f \<inter> dom [x\<mapsto> y] = {}"
by (metis Int_empty_left Int_insert_left dom_eq_singleton_conv inf_commute)
    (* NOTE: munion updates are often over singleton sets. This weakening rule 
             states that's enough to show x is not in f to enable the application
             of f \<union>m [x \<mapsto> y].
     *)

(* Lemma: munion application *)
lemma l_munion_apply:
	"dom f \<inter> dom g = {} \<Longrightarrow> (f \<union>m g) x = (if x \<in> dom g then (g x) else (f x))"
unfolding munion_def
by (simp add: l_dagger_apply)

(* Lemma: munion domain *)
lemma l_munion_dom:
	"dom f \<inter> dom g = {} \<Longrightarrow> dom(f \<union>m g) = dom f \<union> dom g"
unfolding munion_def
by (simp add: l_dagger_dom)

lemma l_munion_assoc:
  "dom f \<inter> dom g \<inter> dom h = {} \<Longrightarrow> f \<union>m (g \<union>m h) = (f \<union>m g) \<union>m h"
unfolding munion_def
apply (simp add: l_dagger_dom)
apply (intro conjI impI)
apply (metis l_dagger_assoc)
apply (simp_all add: disjoint_iff_not_equal)
apply (erule_tac [1-] bexE)
apply blast
apply blast
apply (erule ballE)
apply blast
apply blast
apply blast
defer
apply (erule ballE)
apply blast
apply blast
apply (erule ballE)
apply (erule_tac [1-] bexE)
apply blast
defer
apply (erule ballE)
apply blast
apply blast
apply (erule ballE)
apply (erule ballE)
apply (erule ballE)
apply blast
apply blast
apply blast
apply (erule ballE)
apply (erule ballE)
apply blast
apply (simp add: l_dagger_dom)
apply (rule ext)
oops

(* Bridge: dagger defined through munion [ZEVES-LEMMA] *)
lemma b_dagger_munion_aux:
	"dom(dom g -\<triangleleft> f) \<inter> dom g = {}"
apply (simp add: l_dom_dom_ar)
by (metis Diff_disjoint inf_commute)

lemma b_dagger_munion:
	"(f \<dagger> g) = (dom g -\<triangleleft> f) \<union>m g"
find_theorems (300) "_ = (_::(_ \<Rightarrow> _))" -name:Predicate -name:Product -name:Quick -name:New -name:Record -name:Quotient
		-name:Hilbert -name:Nitpick -name:Random -name:Transitive -name:Sum_Type -name:DSeq -name:Datatype -name:Enum
		-name:Big -name:Code -name:Divides
thm fun_eq_iff[of "f \<dagger> g" "(dom g -\<triangleleft> f) \<union>m g"]
apply (simp add: fun_eq_iff)
apply (simp add: l_dagger_apply)
apply (cut_tac b_dagger_munion_aux[of g f]) (* TODO: How to make this more automatic? Iain, help? subgoal_tac! Try that. *)
apply (intro allI impI conjI)
apply (simp_all add: l_munion_apply)
unfolding dom_antirestr_def
by simp

lemma l_munion_subsume:
	"x \<in> dom f \<Longrightarrow> the(f x) = y \<Longrightarrow> f = ({x} -\<triangleleft> f) \<union>m [x \<mapsto> y]"
apply (subst fun_eq_iff)
apply (intro allI)
apply (subgoal_tac "dom({x} -\<triangleleft> f) \<inter> dom [x \<mapsto> y] = {}")
apply (simp add: l_munion_apply)
apply (metis domD dom_antirestr_def singletonE the.simps)
by (metis Diff_disjoint Int_commute dom_eq_singleton_conv l_dom_dom_ar)

lemma l_munion_subsumeG: --"Perhaps add g \<subseteq>\<^sub>m f instead?"
	"dom g \<subseteq> dom f \<Longrightarrow> \<forall>x \<in> dom g . f x = g x \<Longrightarrow> f = (dom g -\<triangleleft> f) \<union>m g"
unfolding munion_def
apply (subgoal_tac "dom (dom g -\<triangleleft> f) \<inter> dom g = {}")
apply simp
apply (subst fun_eq_iff)
apply (rule allI)
apply (simp add: l_dagger_apply)
apply (intro conjI impI)+
unfolding dom_antirestr_def
apply (simp)
apply (fold dom_antirestr_def)
by (metis Diff_disjoint inf_commute l_dom_dom_ar)

lemma l_munion_dom_ar_assoc:
	"S \<subseteq> dom f \<Longrightarrow> dom f \<inter> dom g = {} \<Longrightarrow> (S -\<triangleleft> f) \<union>m g = S -\<triangleleft> (f \<union>m g)"
unfolding munion_def
apply (subgoal_tac "dom (S -\<triangleleft> f) \<inter> dom g = {}")
defer 1
apply (metis Diff_Int_distrib2 empty_Diff l_dom_dom_ar)
apply simp
apply (rule l_dagger_dom_ar_assoc)
by (metis equalityE inf_mono subset_empty)

lemma l_munion_empty_rhs: 
  "(f \<union>m empty) = f"
unfolding munion_def
by (metis dom_empty inf_bot_right l_dagger_empty_rhs)

lemma l_munion_empty_lhs: 
  "(empty \<union>m f) = f"
unfolding munion_def
by (metis dom_empty inf_bot_left l_dagger_empty_lhs)

lemma k_finite_munion:
  "finite (dom f) \<Longrightarrow> finite(dom g) \<Longrightarrow> dom f \<inter> dom g = {} \<Longrightarrow> finite(dom(f \<union>m g))" 
by (metis finite_Un l_munion_dom)

lemma l_dom_ar_union:
  "S -\<triangleleft> (f \<union>m g) = (S -\<triangleleft> f) \<union>m (S -\<triangleleft> g)"
apply (rule ext)
unfolding munion_def
apply (split split_if, intro conjI impI)+
apply (simp_all add: l_dagger_apply)
apply (intro conjI impI)
apply (insert f_dom_ar_subset_dom[of S f])
apply (insert f_dom_ar_subset_dom[of S g])
oops

(* IJW: TODO: rename? *)
lemma l_munion_upd: "dom f \<inter> dom [x \<mapsto> y] = {}  \<Longrightarrow> f \<union>m [x \<mapsto> y] = f(x \<mapsto>y)" 
unfolding munion_def
  apply simp
  by (metis dagger_def map_add_empty map_add_upd)

(* IJW: TODO: Do I really need these?! *)
lemma munion_notemp_dagger: "dom f \<inter> dom g = {} \<Longrightarrow> f \<union>m g\<noteq>empty \<Longrightarrow> f \<dagger> g \<noteq> empty" 
by (metis munion_def)

lemma dagger_notemp_munion: "dom f \<inter> dom g = {} \<Longrightarrow> f \<dagger> g\<noteq>empty \<Longrightarrow> f \<union>m g \<noteq> empty" 
by (metis munion_def)

lemma munion_notempty_left: "dom f \<inter> dom g = {} \<Longrightarrow> f \<noteq> empty \<Longrightarrow> f \<union>m g \<noteq> empty"
by (metis dagger_notemp_munion dagger_notemptyL)

lemma munion_notempty_right: "dom f \<inter> dom g = {} \<Longrightarrow> g \<noteq> empty \<Longrightarrow> f \<union>m g \<noteq> empty"
by (metis dagger_notemp_munion dagger_notemptyR)

lemmas munion_simps = k_munion_map_upd_wd l_munion_apply l_munion_dom  b_dagger_munion
l_munion_subsume l_munion_subsumeG l_munion_dom_ar_assoc l_munion_empty_rhs
l_munion_empty_lhs k_finite_munion  l_munion_upd munion_notemp_dagger
dagger_notemp_munion munion_notempty_left munion_notempty_right

lemmas vdm_simps = restr_simps antirestr_simps dagger_simps upd_simps munion_simps

(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
subsubsection {* Map finiteness weakening lemmas [EXPERT] *}
(* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

--"Need to have the lemma options, otherwise it fails somehow"
lemma finite_map_upd_induct [case_names empty insert, induct set: finite]:
  assumes fin: "finite (dom f)"
    and empty: "P Map.empty"
    and insert: "\<And>e r f. finite (dom f) \<Longrightarrow> e \<notin> dom f \<Longrightarrow> P f \<Longrightarrow> P (f(e \<mapsto> r))"
  shows "P f" using fin
proof (induct "dom f" arbitrary: "f" rule:finite_induct) --"arbitrary statement is a must in here, otherwise cannot prove it"
  case goal1 then have "dom f = {}" by simp --"need to reverse to apply rules"
  then have "f = Map.empty" by simp
  thus ?case by (simp add: empty)
next
  case goal2
  --"Show that update of the domain means an update of the map"
  assume domF: "insert x F = dom f" then have domFr: "dom f = insert x F" by simp
  then obtain f0 where f0Def: "f0 = f |` F" by simp
  with domF have domF0: "F = dom f0" by auto
  with goal2 have "finite (dom f0)" and "x \<notin> dom f0" and "P f0" by simp_all
  then have PFUpd: "P (f0(x \<mapsto> the (f x)))" by (rule insert)
  from domFr f0Def have "f = f0(x \<mapsto> the (f x))" by (auto intro: l_insertUpdSpec_aux)
  with PFUpd show ?case by simp
qed

lemma finiteRan: "finite (dom f) \<Longrightarrow> finite (ran f)"
proof (induct rule:finite_map_upd_induct)
  case goal1 thus ?case by simp
next
  case goal2 then have ranIns: "ran (f(e \<mapsto> r)) = insert r (ran f)" by auto
  assume "finite (ran f)" then have "finite (insert r (ran f))" by (intro finite.insertI)
  thus ?case by (subst ranIns) simp
qed

(* IJW: TODO: classify; rename; relocate? *)

lemma l_dom_r_finite: "finite (dom f) \<Longrightarrow> finite (dom ( S \<triangleleft> f))" 
apply (rule_tac B="dom f" in  finite_subset)
apply (simp add: l_dom_r_dom_subseteq)
apply assumption
done

lemma dagger_finite: "finite (dom f) \<Longrightarrow> finite (dom g) \<Longrightarrow> finite (dom (f \<dagger> g))"
     by (metis dagger_def dom_map_add finite_Un)

lemma finite_singleton: "finite (dom [a \<mapsto> b])" 
    by (metis dom_eq_singleton_conv finite.emptyI finite_insert)

end
