(* simple test of proof representation *)
theory Wire                                                  
imports        
  Prf                                                     
uses          
  "../wire/term_fo_au.ML"   
  "../wire/term_features.ML"               
  "../wire/feature.ML"                          
  "../wire/bwire.ML"                    
  "../wire/gnode.ML"
  "../wire/rel_feature.ML"                                             
  "../wire/wire.ML"            
 
  "../wire/feature_env.ML"   
begin
 (* adds the features to theory *) 
 setup {* FeatureEnv.setup *}  
end



