theory rippling
imports "../build/BIsaP"
begin
  ML_file "../../isabelle/rtechn/rippling/eqsubst.ml"
(* wrapping trm with name structure *)
  ML_file "../../isabelle/rtechn/rippling/embedding/paramtab.ML" 
  ML_file "../../isabelle/rtechn/rippling/embedding/trm.ML"  
  ML_file "../../isabelle/rtechn/rippling/embedding/isa_trm.ML"
  ML_file "../../isabelle/rtechn/rippling/embedding/instenv.ML"
  ML_file "../../isabelle/rtechn/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../isabelle/rtechn/rippling/embedding/eterm.ML"  
  ML_file "../../isabelle/rtechn/rippling/embedding/ectxt.ML" 
  ML_file "../../isabelle/rtechn/rippling/embedding/embed.ML" 
  
(* measure and skeleton *)
  ML_file "../../isabelle/rtechn/rippling/measure_traces.ML"
  ML_file "../../isabelle/rtechn/rippling/measure.ML" 
  ML_file "../../isabelle/rtechn/rippling/flow_measure.ML"
 (* ML_file "../../../rtechn/rippling/dsum_measure.ML" 
  ML_file "../../../rtechn/rippling/skel.ML" 
  ML_file "../../../rtechn/rippling/skel_mes_traces.ML"*) 

(* wave rule set *)
  ML_file  "../../isabelle/rtechn/rippling/rulesets/substs.ML"

(* some utils for rippling*)
  ML_file "../../isabelle/rtechn/rippling/basic_ripple.ML"

section "example of how to use eqsust_tac with occL "

lemma test2: "((M & True) & (M & True)) = (M & True)"
by auto

lemma test0 : "(A & False) = False"
by auto
lemma test1 : "(A & True) = (A)"
by auto

(* test tactic *)
ML {*
  (*foo_tac -- the payload of what you want to do,
    note the dependency on ctxt: Proof.context*)
  fun foo_tac ctxt = EqSubst.eqsubst_tac ctxt [0] [@{thm test1}] 1
*}

method_setup foo = {*
  (*concrete syntax like "clarsimp", "auto" etc.*)
  Method.sections Clasimp.clasimp_modifiers >>
    (*Isar method boilerplate*)
    (fn _ => fn ctxt => SIMPLE_METHOD (CHANGED (foo_tac ctxt)))  
*}

lemma test: "((M0 & True) & (M1 & True)) = (M2 & True)"
apply foo
oops

section "wrule sets -> matching seq -> eqsubst -> measure"

(* some tests for substset: embedding; add rule from thm; get matched wrules *)
ML{*
 val skel = @{prop "((M0) & (M1)) = (M2 & True)"};
 val hyps = [skel, @{prop "M = N"}];
 val gt =  @{prop "((M0 & True) & (M1 & True)) = (M2 & True)"};
 val gt' =  @{prop "((M0 & True)) = (M0)"};

BasicRipple.is_hyps_embedd @{context} (tl hyps) gt;
BasicRipple.is_hyps_embedd @{context} hyps gt;

 val substset = Substset.empty;
 val thms = [("test1",@{thm "test1"}), ("test0", @{thm "test0"})];
 val rules = map (fn m => Substset.rule_of_thm m |> (fn SOME x => x)) thms;
 val substset = fold (Substset.add) rules substset;

 val matched = Substset.match @{theory} substset gt;
*}

(* check whether exists measure decreasing rule, with given goal term and matched rules *)
ML{*
BasicRipple.has_measure_decreasing_rules @{context} skel matched gt;
BasicRipple.get_subst_params ();
*}

(* apply rippling tactic *)
ML{*
val gthm = Thm.cterm_of @{theory} gt |> Thm.trivial;
BasicRipple.ripple_tac @{context} 1 gthm |> Seq.list_of;
*}

(* more debug codes *)
ML{*
(* func to get teh symmetric thm, see thm0 as belows *)
Thm.symmetric;
mk_meta_eq;

val thy = @{theory};
val ctxt = @{context};
val thm = @{thm "test1"};
val thm0 = Thm.symmetric (mk_meta_eq thm);
val concl = @{term "((M \<and> N) \<and> M \<and> N) = (M \<and> N)"};
val z = Zipper.mktop concl;
Syntax.pretty_term @{context} concl |> Pretty.writeln;

(* strip lhs *)
val (lhs,rhs) = Substset.strip_lhs_rhs thm;

*}

ML{*
  EqSubst.eqsubst_tac @{context} [0] [@{thm "rippling.test2"}];
  val deafultsearchf = EqSubst.search_lr_valid EqSubst.valid_match_start;
  val t = @{term "(M & N) & (P & Q)"};
  val t_zip = Zipper.mktop t;
  val t_zip_seq = deafultsearchf t_zip;
  Seq.list_of t_zip_seq |> List.length;
  val search_seq = Seq.map (fn z => (@{theory}, 1, z)) t_zip_seq;
  EqSubst.searchf_lr_unify_valid;
  
  tracing "hello";
*}


end
