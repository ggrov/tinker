(* $Id: HEAP1.thy 1653 2013-06-24 19:23:44Z nljsf $ *)
theory HEAP1
imports HEAP0 VDMMaps
begin

chapter {* Heap Level 1 *}


(*========================================================================*)
section {* Types and auxiliary functions *}
(*========================================================================*)

type_synonym F1 = "Loc \<rightharpoonup> nat"

definition 
  nat1_map :: "F1 \<Rightarrow> bool"
where
  "nat1_map f \<equiv> (\<forall> x. x \<in> dom f \<longrightarrow> nat1 (the (f x)))"

definition
  nat1_set :: "(nat set) \<Rightarrow> bool"
where
  "nat1_set f \<equiv> (\<forall> x. x \<in> f \<longrightarrow> nat1 x)"

definition
  Locs_of :: "F1 \<Rightarrow> Loc \<Rightarrow> (Loc set)"
where
  "Locs_of f l \<equiv> (if (l \<in> dom f) then 
                    locs_of l (the (f l))
                  else
                    undefined)"  (* TODO: or {}? *)

definition 
  disjoint :: "'a set \<Rightarrow> 'a set \<Rightarrow> bool"
where
 "disjoint A B \<equiv> A \<inter> B = {}"

definition 
  Disjoint :: "F1 \<Rightarrow> bool"
where
 "Disjoint f \<equiv> 
      (\<forall> a \<in> dom f. \<forall> b \<in> dom f . a \<noteq> b \<longrightarrow> disjoint (Locs_of f a) (Locs_of f b))"

definition 
  sep :: "F1 \<Rightarrow> bool" 
where
  "sep f \<equiv> (\<forall> l \<in> dom f . l + the(f l) \<notin> dom f)"

definition 
  locs :: "(Loc \<rightharpoonup> nat) \<Rightarrow> Loc set "
where
  "locs sm \<equiv> (if nat1_map sm then 
                \<Union> s \<in> dom sm. locs_of s (the (sm s)) 
               else 
                 undefined)" (* TODO: or {}?*)
              
term "foldl min (dom f) x"

definition
   min_loc :: "(Loc \<rightharpoonup> nat) \<Rightarrow> nat"
where
   "min_loc sm = (if sm \<noteq> empty then 
                      Min (dom sm) 
                  else 
                      undefined)" 

definition 
  sum_size :: "(Loc \<rightharpoonup> nat) \<Rightarrow> nat"
where
  "sum_size sm = (if sm \<noteq> empty then 
                      (\<Sum> x\<in>(dom sm) . the (sm x)) 
                  else 
                      undefined)" (*TODO: or 0? *)

(*------------------------------------------------------------------------*)
subsection {* Alternative definitions *}
(*------------------------------------------------------------------------*)

definition
  Locs_of2 :: "F1 \<Rightarrow> Loc \<Rightarrow> (Loc set)"
where
  "l \<in> dom f \<Longrightarrow> nat1 (the(f l)) \<Longrightarrow> Locs_of2 f l \<equiv> locs_of l (the (f l))"

definition 
  Disjoint2 :: "F1 \<Rightarrow> bool"
where
 "Disjoint2 f \<equiv> 
      (\<forall> a \<in> dom f. \<forall> b \<in> dom f . a \<noteq> b \<longrightarrow> 
        disjoint (locs_of a (the(f a))) (locs_of b (the(f b))))"
code_type F1(Scala)

(*========================================================================*)
section {* VDM function definitions *}
(*========================================================================*)

definition 
  F1_inv :: "F1 \<Rightarrow> bool" 
where
  [intro!]: "F1_inv f \<equiv> Disjoint f \<and> sep f \<and> nat1_map f \<and> finite(dom f)"
    (* TODO: explain. This is like a ZEves grule (i.e. F1_inv info is an eager/Pure intro rule) *)
  
definition 
  new1_pre :: "F1 \<Rightarrow> nat \<Rightarrow> bool"
where
  "new1_pre f s \<equiv> (\<exists> l \<in> dom f . the(f l) \<ge> s)"

definition
   new1_post_eq :: "F1 \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> Loc \<Rightarrow> bool"
where
   "new1_post_eq f s f' r \<equiv> r \<in> dom f \<and> the(f r) = s \<and> f' = {r} -\<triangleleft> f"

definition
   new1_post_gr :: "F1 \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> Loc \<Rightarrow> bool"
where
   "new1_post_gr f s f' r \<equiv> r \<in> dom f \<and> the(f r) > s \<and> 
                            f' = ({r} -\<triangleleft> f) \<union>m [r + s \<mapsto> the(f r) - s]"
      (* { 0 \<mapsto> 4, 6 \<mapsto> 11 } = map with 15 free locations; ask NEW(5); return 6
              0..3,  6..16
         { 0 \<mapsto> 4, 11 \<mapsto> 6 } = map with 10 free locations    
              0..3, 11..16
              
         This brings some issues: (r+s) \<notin> dom f
       *)
definition
   new1_post :: "F1 \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> Loc \<Rightarrow> bool"
where
   "new1_post f s f' r \<equiv> new1_post_eq f s f' r \<or> new1_post_gr f s f' r"

definition 
   dispose1_pre :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> bool"
where
  "dispose1_pre f d s \<equiv> disjoint (locs_of d s) (locs f)"

definition 
   dispose1_post :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> bool"
where
   "dispose1_post f d s f' \<equiv> 
      (\<exists> below above ext . 
        below = { x \<in> dom f . x + the(f x) = d } \<triangleleft> f \<and>
        above = { x \<in> dom f . x = d + s } \<triangleleft> f \<and>
        ext   = (above \<union>m below) \<union>m [d \<mapsto> s] \<and>
        f' = ((dom below \<union> dom above) -\<triangleleft> f) \<union>m ([min_loc(ext) \<mapsto> sum_size(ext)]))
      "
      (*
      	  { 0 \<mapsto> 4, 5 \<mapsto> 11 } = 15 free;  NEW(5) = 5
      	  =
      	  { 0 \<mapsto> 4, 10 \<mapsto> 6 } = 10 free; DISPOSE(20, 2) 
      	  =
      	  { 0 \<mapsto> 4, 10 \<mapsto> 6, 20 \<mapsto> 2 } = 12 free; 
      	  									
      	  	DISPOSE(16, 3) = { 0 \<mapsto> 4, 10 \<mapsto> 9, 20 \<mapsto> 2 } = 15 free
      	  	DISPOSE(16, 4) = { 0 \<mapsto> 4, 10 \<mapsto> 12 } 		 =  16 free
      	  
       *)
       
definition 
  dispose1_below :: "F1 \<Rightarrow> Loc \<Rightarrow> F1"
where
  "dispose1_below f d \<equiv>  { x \<in> dom f . x + the(f x) = d } \<triangleleft> f" 

definition 
  dispose1_above :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1"
where
  "dispose1_above f d s \<equiv>  { x \<in> dom f . x = d + s } \<triangleleft> f" 

definition 
  dispose1_ext :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1"
where
  "dispose1_ext f d s \<equiv>  (dispose1_above f d s  \<union>m dispose1_below f d) \<union>m [d \<mapsto> s] "

definition 
   dispose1_post2 :: "F1 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F1 \<Rightarrow> bool"
where
   "dispose1_post2 f d s f' \<equiv> 
        (f' = ((dom (dispose1_below f d) \<union> dom (dispose1_above f d s)) -\<triangleleft> f) 
        \<union>m ([min_loc(dispose1_ext f d s) \<mapsto> sum_size(dispose1_ext f d s)]))"


lemmas F1_inv_defs = F1_inv_def Disjoint_def nat1_def
                     Locs_of_def sep_def nat1_map_def
                     disjoint_def locs_of_def

lemmas new1_pre_defs      = new1_pre_def 
lemmas new1_post_defs     = new1_post_def new1_post_eq_def new1_post_gr_def
lemmas dispose1_pre_defs  = dispose1_pre_def disjoint_def nat1_def
                            locs_def nat1_map_def locs_of_def
lemmas dispose1_post_defs = dispose1_post_def 

lemmas dispose1_post2_defs = dispose1_post2_def dispose1_below_def 
							 dispose1_above_def dispose1_ext_def

lemma dispose1_equiv:
	"dispose1_post f d s f' = dispose1_post2 f d s f'"
unfolding dispose1_post_defs dispose1_post2_defs
by auto

(*========================================================================*)
section {* VDM operation definitions *}
(*========================================================================*)

locale level1_basic =
   fixes f1 :: F1
   and   s1 :: nat
  assumes l1_input_notempty: "nat1 s1"
   and    l1_invariant     : "F1_inv f1"

locale level1_new = level1_basic +
   assumes new1_precondition: "new1_pre f1 s1"

locale level1_dispose = level1_basic +
    fixes d1 :: Loc
   assumes dispose1_precondition: "dispose1_pre f1 d1 s1"

definition (in level1_new)
  new1_postcondition :: "F1 \<Rightarrow> nat \<Rightarrow> bool"
where
  "new1_postcondition f' r \<equiv> new1_post f1 s1 f' r \<and> F1_inv f'"

definition (in level1_dispose)
  dispose1_postcondition :: "F1 \<Rightarrow> bool"
where
  "dispose1_postcondition f' \<equiv> dispose1_post f1 d1 s1 f' \<and> F1_inv f'"

locale level1_complete = level1_new + level1_dispose

(*========================================================================*)
section {* VDM proof obligations for Level 1 *}
(*========================================================================*)

definition (in level1_new)
  new1_feasibility :: "bool"
where
  "new1_feasibility \<equiv> (\<exists> f' r' . new1_postcondition f' r')"

definition (in level1_dispose)
  dispose1_feasibility :: "bool"
where
  "dispose1_feasibility \<equiv> (\<exists> f' . dispose1_postcondition f')"

definition 
  new1_fsb :: "bool"
where
  "new1_fsb \<equiv> (\<forall> f s . F1_inv f \<and> nat1 s \<and> new1_pre f s \<longrightarrow> 
                        (\<exists> f' r' . new1_post f s f' r' \<and> F1_inv f'))"

definition
  dispose1_fsb :: "bool"
where
  "dispose1_fsb \<equiv> (\<forall> f d s . F1_inv f \<and> nat1 s \<and> dispose1_pre f d s \<longrightarrow> 
                        (\<exists> f' . dispose1_post f d s f' \<and> F1_inv f'))"


unused_thms

lemma (in level1_dispose) "False"
nitpick [show_all]
oops
lemma (in level1_new) "False"
nitpick [show_all]
oops
(* NOTE: Nitpick trick to see if any axiom involved in the locales is inconsistent.
         i.e. if axioms are inconsistent, then we shouldn't be able to find a mode
         for False. If we do, then the axioms are conistent (i.e. it's unprovable 
         as it should be).
 *)

end