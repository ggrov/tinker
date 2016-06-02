theory Rippling
imports "../../core/provers/isabelle/clausal/CIsaP" 

begin
(* wrapping trm with name structure *)
  ML_file "../../core/provers/isabelle/lib/rippling/unif_data.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/collection.ML"   
  ML_file "../../core/provers/isabelle/lib/rippling/pregraph.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/rgraph.ML" 
  
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/paramtab.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/trm.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/isa_trm.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/instenv.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/eterm.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/ectxt.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/embed.ML" 
 
(* measure and skeleton *)
  ML_file "../../core/provers/isabelle/lib/rippling/measure_traces.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/measure.ML" 
  (*ML_file "../../provers/isabelle/termlib/rippling/flow_measure.ML"*)
  ML_file "../../core/provers/isabelle/lib/rippling/dsum_measure.ML" 

(* wave rule set *)
  ML_file  "../../core/provers/isabelle/lib/rippling/rulesets/substs.ML"

  ML_file  "../../core/provers/isabelle/lib/induct.ML"

  ML_file  "../../core/provers/isabelle/lib/term_fo_au.ML"  
  ML_file  "../../core/provers/isabelle/lib/term_features.ML"  

  ML_file  "../../core/provers/isabelle/lib//rippling/basic_ripple.ML" 

  
  attribute_setup wrule = {* Attrib.add_del wrule_add wrule_del *} "maintaining a list of wrules"

ML{*
        val sg =  TermFeatures.fix_alls_in_term @{term "\<And> a b. a + (suc b) = suc (a + b) ==> (suc a) + (suc b) = suc ((suc a) + b)"} ;
        val hyps  = Logic.strip_imp_prems sg |> map TermFeatures.fix_alls_as_var  ;
        val goal = Logic.strip_imp_concl sg |> Syntax.pretty_term @{context} |> Pretty.writeln;

TermFeatures.ctxt_embeds @{context} 
@{term "a + (suc b) = suc (a + b)"} 
@{term "\<And> a b. a + (suc b) = suc (a + b) ==> (suc a) + (suc b) = suc ((suc a) + b)"} 
*}

(* tactics for rippling *)

ML{*
(* setup simp tac *) 
 val simp_tac = Simplifier.simp_tac;

(* setup up fertlisation*)
 val (strong_fert : Proof.context -> int -> tactic) = 
   (fn _ => Simplifier.asm_simp_tac (Proof_Context.init_global @{theory "HOL"}));

 fun weak_fert ctxt = Simplifier.safe_asm_full_simp_tac ctxt;

(* setup up induct *)
 val (induct_tac : Proof.context -> int -> tactic)  = 
   fn _ => InductRTechn.induct_tac(*InductRTechn.induct_on_nth_var_tac 1*);
  
(* setup up rippling *)
  val ripple_step = BasicRipple.ripple_tac
*}

(* goaltype for rippling *)
ML{*

 fun bool_to_cl env ret = if ret then [env] else []
 
 fun inductable env pnode [] = 
  TermFeatures.is_inductable_structural 
  (Prover.get_pnode_ctxt pnode |> Proof_Context.theory_of ) 
  (Prover.get_pnode_concl pnode)
  |> bool_to_cl env
 | inductable _ _ _ = [];

 fun hyp_embeds0 env pnode [] = 
  exists (fn hyp => TermFeatures.ctxt_embeds 
   (Prover.get_pnode_ctxt pnode ) 
   hyp
   (Prover.get_pnode_concl pnode))
   (Prover.get_pnode_hyps pnode |> map TermFeatures.fix_alls_as_var)

 fun hyp_embeds env pnode [] = hyp_embeds0 env pnode [] |> bool_to_cl env
 | hyp_embeds _ _ _ = [];
 
 fun no_hyp_embeds env pnode [] = hyp_embeds0 env pnode [] |> not |> bool_to_cl env
 | no_hyp_embeds _ _ _ = [];

 fun measure_reduces0 env pnode [] =
  let
     val goal = Prover.get_pnode_concl pnode
     val ctxt = Prover.get_pnode_ctxt pnode
     val hyps' = map TermFeatures.fix_alls_as_var (Prover.get_pnode_hyps pnode)
     val embedd_hyp =
      filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps' (* use the hyp with no bindings *)
      |> hd (* only get the first embedding *)
     val wrules = BasicRipple.get_matched_wrules ctxt goal
  in
    TermFeatures.has_measure_decreasing_rules ctxt embedd_hyp wrules goal
  end

 fun measure_reduces env pnode [] = measure_reduces0 env pnode [] |> bool_to_cl env
 | measure_reduces _ _ _ = [];
 fun rippled env pnode [] = measure_reduces0 env pnode [] |> not |>  bool_to_cl env
 | rippled _ _ _ = []

 fun hyp_bck_res  env pnode [] = 
  let 
    val ctxt = Prover.get_pnode_ctxt pnode
    val thy =  Proof_Context.theory_of ctxt
    val goal = Prover.get_pnode_concl pnode
    val hyps' = map TermFeatures.fix_alls_in_term (Prover.get_pnode_hyps pnode)
    val embedd_hyp =
      filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps'
      |> hd (* only get the first embedding *)
  in
    TermFeatures.is_subterm thy goal embedd_hyp
    |> bool_to_cl env
  end
 | hyp_bck_res _ _ _ = [];

 fun hyp_subst env pnode []  = 
  let 
    val ctxt = Prover.get_pnode_ctxt pnode
    val thy =  Proof_Context.theory_of ctxt
    val goal = Prover.get_pnode_concl pnode
    val hyps' = map TermFeatures.fix_alls_in_term (Prover.get_pnode_hyps pnode)
    val embedd_hyp =
      filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps'
      |> hd (* only get the first embedding *)
    fun mk_meta_eq_trm thry t = Thm.cterm_of thry t 
      |> Thm.trivial |> safe_mk_meta_eq |> Thm.concl_of;
    fun get_lhs_rhs thry trm = Logic.dest_equals (mk_meta_eq_trm thry trm) |> SOME
    handle _ => NONE;
    fun lhs_rhs_subs trm = 
      case get_lhs_rhs thy trm of NONE => false
         | SOME(l,r) => 
          (TermFeatures.is_subterm thy goal l orelse 
           TermFeatures.is_subterm thy goal r)
  in
    (lhs_rhs_subs embedd_hyp) |> bool_to_cl env         
 end
 | hyp_subst _ _ _ = []

 
 val data = 
   Clause_GT.default_data
  |> Clause_GT.add_atomic "inductable" inductable
  |> Clause_GT.add_atomic "hyp_embeds" hyp_embeds
  |> Clause_GT.add_atomic "no_hyp_embeds" no_hyp_embeds
  |> Clause_GT.add_atomic "measure_reduces" measure_reduces
  |> Clause_GT.add_atomic "rippled" rippled
  |> Clause_GT.add_atomic "hyp_bck_res" hyp_bck_res
  |> Clause_GT.add_atomic "hyp_subst" hyp_subst
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data Prover.default_ctxt "") @ x);

*}
end
