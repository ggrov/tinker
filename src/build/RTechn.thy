(* simple test of proof representation *)
theory RTechn                                                  
imports          
  Wire                                     
uses
  "../rtechn/rtechn.ML"                                     
  "../rtechn/rtechn_env.ML"      
begin
  (* due to XML usage by Quanto - is this still necessary? *)
  ML{*
    structure IsaXML = XML
  *}
  setup {* RTechnEnv.setup *}
end



