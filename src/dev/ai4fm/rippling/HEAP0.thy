(* $Id: HEAP0.thy 1653 2013-06-24 19:23:44Z nljsf $ *)
theory HEAP0
imports Main
begin

chapter {* Heap Level 0*}

text
{* 
We use locales to describe the VDM models of a Heap.  
This increases the modularity and clarity of the POs
we are using Isabelle to prove, given of course the 
locale universally quantifying assumptions and pres.

i.e. lemma (in LOCALE) Op1_FSB:   
 "\<exists> after_state result . inv after_state \<and> post after_state result"

We also use definition to capture VDM features. This
is useful for the folding/unfolding of zooming pattern.

NAMING CONVENTIONS:

* auxiliary functions: capitalised with "\_" in between
   
* VDM operations macros: used shorted names outside locales 

  STATE=F0; N={0} OP={new, dispose}

  definition 
    [STATE][N]_inv :: "[STATE][N] \<Rightarrow> bool"
  where
    "[STATE][N]_inv \<equiv> pred"

  definition 
     [OP][N]_pre :: "[STATE][N] \<Rightarrow> [IN1] ... \<Rightarrow> [INn] \<Rightarrow> bool"
  where
    "[OP][N]_pre \<equiv> pred-without-state-invariant-or-input-subtype"

  definition 
     [OP][N]_post :: "[STATE][N] \<Rightarrow> [IN1] ... \<Rightarrow> [INn] \<Rightarrow> [STATE][N] \<Rightarrow> [Out] \<Rightarrow> bool"
  where
    "[OP][N]_post \<equiv> pred-without-state-invariant-or-IO-subtype"

* Isabelle shortcut for all names involved in a definition

  lemmas [STATE][N]_inv_defs   = [STATE][N]_inv_def  ???
  lemmas [OP][N]_pre_defs      = [OP][N]_pre_def ???
  lemmas [OP][N]_post_defs     = [OP][N]_post_def ???
 
  We also add a version full_defs to contain all operators involved.

* VDM model macros: used longer names inside locales

  locale level[N]_basic =
     fixes f :: [STATE]
     and   s :: [IN1]          common-inputs
    assumes l[N]_input1_[PROP] : pred-input1-subtype
              ...
            l[N]_inputn_[PROP] : pred-inputn-subtype
     and    l[N]_invariant     : "[STATE]_inv f"
  
  locale level[N]_[OP] = level[N]_basic +
      fixes  i :: [IN]                 specific inputs
      assumes [OP]_precondition : [OP]_pre f s i \<and> [STATE]_inv f

  definition (in level[N]_[OP])
     [OP][N]_postcondition :: "[STATE] \<Rightarrow> [Out] \<Rightarrow> bool"
  where
    "[OP][N]_postcondition f' r \<equiv> [OP][N]_post f s f' r \<and> [OP][N]_inv f'"

* VDM POs macros in locales: 

  definition (in level[N]_[OP])
    [OP][N]_feasibility :: "bool"
  where
    "[OP][N]_feasibility \<equiv> (\<exists> f' r' . [OP][N]_postcondition f' r')"

* VDM POs macros out locales:

  definition 
    [OP][N]_fsb :: "bool"
  where
    "[OP][N]_fsb \<equiv> (\<forall> f s . [STATE][N]_inv f \<and> 
                            l[N]_input_[PROP] \<and> 
                            [OP][N]_pre f s \<longrightarrow> 
                              (\<exists> f' r' . [OP][N]_post f s f' r' \<and> 
                                         [STATE][N]_inv f'))"

* Feasibility PO macros for later proof:

  lemma [OP][N]_FSB: "[OP][N]_fsb"
  lemma (in locale[N]_[OP]) [OP][N]_Feasibility: "[OP][N]_feasibility"

*}

(*========================================================================*)
section {* Types and auxiliary functions *}
(*========================================================================*)

type_synonym Loc = nat
type_synonym F0 = "Loc set" 

definition 
  nat1 :: "nat \<Rightarrow> bool"
where
  [iff]: "nat1 n \<equiv> n > 0"

definition 
  locs_of :: "Loc \<Rightarrow> nat \<Rightarrow> (Loc set)"
where
  "locs_of l n \<equiv> (if nat1 n then { i. i \<ge> l \<and> i < (l + n) } else undefined)" 

definition is_block :: "Loc \<Rightarrow> nat \<Rightarrow> (Loc set) \<Rightarrow> bool"
where
	"is_block l n ls \<equiv> nat1 n \<and> locs_of l n \<subseteq> ls"

(*------------------------------------------------------------------------*)
subsection {* Alternative definitions *}
(*------------------------------------------------------------------------*)

fun
  locs_of2 :: "Loc \<Rightarrow> nat \<Rightarrow> (Loc set)"
where
  "locs_of2 l 0 = {}" |
  "locs_of2 l (Suc n) = {l} \<union> locs_of2 (l+1) n"

function (domintros)
  locs_of3 :: "Loc \<Rightarrow> nat \<Rightarrow> (Loc set)"
where
  "locs_of3 l n = (if nat1 n then { i. i \<ge> l \<and> i < (l + n) } else undefined)"
by auto

(*
function (domintros)
  locs_of4 :: "Loc \<Rightarrow> nat \<Rightarrow> (Loc set)"
where
  "locs_of4 l (Suc n) = {l} \<union> locs_of4 (l+1) n"
TODO
*)

find_theorems name:locs_of

(*========================================================================*)
section {* VDM function definitions *}
(*========================================================================*)

text 
{* Definitions in Isabelle will not take type/signature enforcement 
   from VDM into account. That is, new0_pre/post below do not check 
   invariant for f or type constraints for the inputs/outputs. 

   These will be checked sistematically through the locales.
 *}

definition 
  F0_inv :: "F0 \<Rightarrow> bool" 
where
  [intro!]: "F0_inv f \<equiv> finite f"

definition 
  new0_pre :: "F0 \<Rightarrow> nat \<Rightarrow> bool"
where
  "new0_pre f s \<equiv> (\<exists> l. (is_block l s f))"

definition
   new0_post :: "F0 \<Rightarrow> nat \<Rightarrow> F0 \<Rightarrow> Loc \<Rightarrow> bool"
where
   "new0_post f s f' r \<equiv> (is_block r s f) \<and> f' = f - (locs_of r s)"

definition 
   dispose0_pre :: "F0 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> bool"
where
  "dispose0_pre f d s \<equiv> locs_of d s \<inter> f = {}"

definition 
   dispose0_post :: "F0 \<Rightarrow> Loc \<Rightarrow> nat \<Rightarrow> F0 \<Rightarrow> bool"
where
   "dispose0_post f d s f' \<equiv> f' = f \<union> locs_of d s"

text {* Rationale for name selection here is to do with flatenning
        all (or almost) all names within the problem's context. This
        is an important setup for zooming and needs fiddling before
        one gets it right; in particular for complicated definitions
        like NEW1. For NEW1, this isn't that relevant.
      *}
lemmas F0_inv_defs        = F0_inv_def
lemmas new0_pre_defs      = new0_pre_def is_block_def locs_of_def
lemmas new0_post_defs     = new0_post_def is_block_def locs_of_def
lemmas dispose0_pre_defs  = dispose0_pre_def locs_of_def
lemmas dispose0_post_defs = dispose0_post_def locs_of_def

(*========================================================================*)
section {* VDM operation definitions *}
(*========================================================================*)

text
{* VDM operations are defined using locales to keep hold of the stat
   and its invariant as part of the locale assumptions, and similarly
   for inputs. This sistematically checks pre-state type invariants 
   are enforced. We still need to explicitly do that for post-states.

   We use layered locales to avoid repetition of the state invariant
   across each operation of interest.
 *}

locale level0_basic =
   fixes f0 :: F0
   and   s0 :: nat
  assumes l0_input_notempty: "nat1 s0"
   and    l0_invariant     : "F0_inv f0"

locale level0_new = level0_basic +
   assumes new0_precondition: "new0_pre f0 s0"

locale level0_dispose = level0_basic +
    fixes d0 :: Loc
   assumes dispose0_precondition: "dispose0_pre f0 d0 s0"

definition (in level0_new)
  new0_postcondition :: "F0 \<Rightarrow> nat \<Rightarrow> bool"
where
  "new0_postcondition f' r \<equiv> new0_post f0 s0 f' r \<and> F0_inv f'"

definition (in level0_dispose)
  dispose0_postcondition :: "F0 \<Rightarrow> bool"
where
  "dispose0_postcondition f' \<equiv> dispose0_post f0 d0 s0 f' \<and> F0_inv f'"

(*========================================================================*)
section {* VDM proof obligations for Level 0 *}
(*========================================================================*)

text 
{*
  Given totalisation and definedness of VDM model here, only feasibility
  proof obligations per level are needed. We (Leo) are still unsure which
  choice is better / clearer: with or without the locale. The locale version
  is a stronger version of the PO (i.e. for a fixed before state).
*}

definition (in level0_new)
  new0_feasibility :: "bool"
where
  "new0_feasibility \<equiv> (\<exists> f' r' . new0_postcondition f' r')"

definition (in level0_dispose)
  dispose0_feasibility :: "bool"
where
  "dispose0_feasibility \<equiv> (\<exists> f' . dispose0_postcondition f')"

definition 
  new0_fsb :: "bool"
where
  "new0_fsb \<equiv> (\<forall> f s . F0_inv f \<and> nat1 s \<and> new0_pre f s \<longrightarrow> 
                        (\<exists> f' r' . new0_post f s f' r' \<and> F0_inv f'))"

definition
  dispose0_fsb :: "bool"
where
  "dispose0_fsb \<equiv> (\<forall> f d s . F0_inv f \<and> nat1 s \<and> dispose0_pre f d s \<longrightarrow> 
                        (\<exists> f' . dispose0_post f d s f' \<and> F0_inv f'))"

(*------------------------------------------------------------------------*)
subsection {* Sledgehammered proof relating PO shapes *}
(*------------------------------------------------------------------------*)

text
{* Next lemmas show the relationship between the POs shaped with and
   without locales. This is just to clarify what is it we are doing 
   with them for the VDM POs. 

   Incidentally, why is it we need SMT for NEW0 and METIS for DISPOSE0?
*}

lemma (in level0_new)
  locale0_new_FSB_stronger: "new0_fsb \<longrightarrow> new0_feasibility"
by (smt l0_input_notempty 
        l0_invariant 
        new0_feasibility_def 
        new0_fsb_def 
        new0_postcondition_def 
        new0_precondition)

lemma (in level0_dispose)
  locale0_new_FSB_stronger: "dispose0_fsb \<longrightarrow> dispose0_feasibility"
by (metis dispose0_feasibility_def 
          dispose0_fsb_def 
          dispose0_postcondition_def 
          dispose0_precondition 
          l0_input_notempty 
          l0_invariant)

(*------------------------------------------------------------------------*)
subsection {* Alternative coded proofs *}
(*------------------------------------------------------------------------*)

lemma (in level0_new)
  locale0_new_FSB_stronger_coded: "new0_fsb \<longrightarrow> new0_feasibility"
unfolding new0_feasibility_def new0_postcondition_def new0_fsb_def
apply (insert l0_invariant)
apply (insert l0_input_notempty)
apply (insert new0_precondition)
unfolding new0_pre_def
apply (rule impI)
apply (erule_tac x="f0" in allE)
apply (erule_tac x="s0" in allE)
apply (erule exE)
apply safe
apply (rule_tac x=l in exI)
apply assumption
done

lemma (in level0_dispose)
  locale0_dispose_FSB_stronger_coded: "dispose0_fsb \<longrightarrow> dispose0_feasibility"
unfolding dispose0_feasibility_def dispose0_postcondition_def dispose0_fsb_def
apply (insert l0_invariant)
apply (insert l0_input_notempty)
apply (rule impI)
apply (erule_tac x="f0" in allE)
apply (erule_tac x="d0" in allE)
apply (erule_tac x="s0" in allE)
apply (erule impE)
apply (insert dispose0_precondition)
apply safe
done

unused_thms

lemma (in level0_dispose) "False"
nitpick [show_all]
oops
lemma (in level0_new) "False"
nitpick [show_all]
oops

end
