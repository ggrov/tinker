(* simple test of proof representation *)
theory RTechn                                               
imports        
  Wire                                     
uses
  "../rtechn/rtechn.ML"                                 
begin
  ML {*
   prod_ord;
   prod_ord oo prod_ord
  *}
  (* due to XML usage by Quanto *)
  ML{*
    structure IsaXML = XML
  *}
end



