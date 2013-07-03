(* simple test of proof representation *)
theory IsaTerm                                                                                                                                                                                             
imports           
 "~~/contrib/isaplib/isabelle/isaplib/isaplib"                                                                            
begin         
(* wrapping trm with name structure *)
  ML_file "../../rtechn/rippling/embedding/paramtab.ML" 
  ML_file "../../rtechn/rippling/embedding/trm.ML"  
  ML_file "../../rtechn/rippling/embedding/isa_trm.ML"
  ML_file "../../rtechn/rippling/embedding/instenv.ML"
  ML_file "../../rtechn/rippling/embedding/typ_unify.ML"   

(* embeddings *)
  ML_file "../../rtechn/rippling/embedding/eterm.ML"  
  ML_file "../../rtechn/rippling/embedding/ectxt.ML" 
  ML_file "../../rtechn/rippling/embedding/embed.ML" 
  
(* measure and skeleton *)
  ML_file "../../rtechn/rippling/measure_traces.ML"
  ML_file "../../rtechn/rippling/measure.ML" 
  ML_file "../../rtechn/rippling/flow_measure.ML"

(* wave rule set *)
  ML_file  "../../rtechn/rippling/rulesets/substs.ML"

(* rippling *)
  ML_file "../../rtechn/rippling/basic_ripple.ML"
                          
  ML_file "../../termlib/term_fo_au.ML"
  ML_file "../../termlib/term_features.ML"              

end
