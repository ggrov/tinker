(* simple test of proof representation *)
theory Interface                                                      
imports
  PreIsaP           
  IsaP  
begin
 ML_file  "../../../parse/string_transfer.ML"

text "add merge and identify as default"
setup {* StringTransfer.add_rtechn ("merge",RTechn.merge) 
       #> StringTransfer.add_rtechn ("id",RTechn.id)  *}

end



