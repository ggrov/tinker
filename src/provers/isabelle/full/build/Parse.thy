(* simple test of proof representation *)
theory Parse                                                      
imports
  PreIsaP           
  IsaP  
begin

 ML_file "../../../../parse/whym_tree.ML"  
 ML_file "../../../../parse/whym_parse.ML" 
 ML_file "../../../../parse/proof_term_parse.ML"

end



