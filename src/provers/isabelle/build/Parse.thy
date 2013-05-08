(* simple test of proof representation *)
theory Parse                                                      
imports           
  Eval                                                        
uses 
  "../../../parse/parsetree.ML"
  "../../../parse/graph_transfer.ML"
  "../../../parse/string_transfer.ML"           
begin

text "add merge and identify as default"
setup {* StringTransfer.add_rtechn ("merge",RTechn.merge) 
       #> StringTransfer.add_rtechn ("id",RTechn.id)  *}

end



