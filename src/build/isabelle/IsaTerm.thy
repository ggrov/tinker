(* simple test of proof representation *)
theory IsaTerm                                                                                                                                                                                            
imports         
 "~~/contrib/isaplib/isabelle/isaplib/isaplib"                                                                          
begin         
ML{*
  val isar_tracing = (*tracing*) (fn _ => ());
*}

(* wrapping trm with name structure *)
  ML_file "../../provers/isabelle/termlib/rippling/embedding/paramtab.ML" 
  ML_file "../../provers/isabelle/termlib/rippling/embedding/trm.ML"  
  ML_file "../../provers/isabelle/termlib/rippling/embedding/isa_trm.ML"
  ML_file "../../provers/isabelle/termlib/rippling/embedding/instenv.ML"
  ML_file "../../provers/isabelle/termlib/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../provers/isabelle/termlib/rippling/embedding/eterm.ML"  
  ML_file "../../provers/isabelle/termlib/rippling/embedding/ectxt.ML" 
  ML_file "../../provers/isabelle/termlib/rippling/embedding/embed.ML" 
 
(* measure and skeleton *)
  ML_file "../../provers/isabelle/termlib/rippling/measure_traces.ML"
  ML_file "../../provers/isabelle/termlib/rippling/measure.ML" 
  (*ML_file "../../provers/isabelle/termlib/rippling/flow_measure.ML"*)
  ML_file "../../provers/isabelle/termlib/rippling/dsum_measure.ML" 

(* wave rule set *)
  ML_file  "../../provers/isabelle/termlib/rippling/rulesets/substs.ML"

(* don't think this is the right place to place them ? 
   need to further refactor the rippling and induct, i.e. seperate the feature with tac*)
                         
  ML_file "../../provers/isabelle/termlib/term_fo_au.ML"  
  ML_file "../../provers/isabelle/termlib/term_features.ML"   

end
