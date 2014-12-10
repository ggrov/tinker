(* simple test of proof representation *)
theory PSGraph                                                                               
imports         
  Graph                   
begin 
  ML_file "../../psgraph/psgraph.sig.ML"        
  ML_file "../../psgraph/psgraph.ML"      
  ML_file "../../psgraph/psgraph_comb.ML" 
end



