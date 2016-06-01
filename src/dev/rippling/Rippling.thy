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

(* tactics for rippling *)

ML{*
(* setup simp tac *) 
 val simp_tac = Simplifier.simp_tac;

(* setup up fertlisation*)
 val (strong_fert_tac : Proof.context -> int -> tactic) = 
   (fn _ => Simplifier.asm_simp_tac (Proof_Context.init_global @{theory "HOL"}));

 fun weak_fert_tac ctxt = Simplifier.safe_asm_full_simp_tac ctxt;

(* setup up induct *)
 val (induct_tac : Proof.context -> int -> tactic)  = 
   fn _ => InductRTechn.induct_tac(*InductRTechn.induct_on_nth_var_tac 1*);
  
(* setup up rippling *)
  val ripple_tac = BasicRipple.ripple_tac
*}

(* goaltype for rippling *)
end
