(* simple test of proof representation *)
theory Parse                                                      
imports
  PreIsaP           
  IsaP  
begin

 ML_file "../../../parse/whym_tree.ML"  
 ML_file "../../../parse/whym_parse.ML"

 ML_file  "../../../parse/string_transfer.ML"

text "add merge and identify as default"
setup {* StringTransfer.add_rtechn ("merge",RTechn.merge) 
       #> StringTransfer.add_rtechn ("id",RTechn.id)  *}

end



