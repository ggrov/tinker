(* simple test of proof representation *)
theory GoalTyp
imports                
 "basic/BasicIsaPS"                                            
uses

  "../../../goaltype/goaltyp_data.ML"
  "../../match_param.ML"
  "../../../goaltype/class.ML"  
  "../../../goaltype/link.ML"

(* for full goaltyp *)

  "../../../goaltype/full/goaltyp.ML"  
  "../../../goaltype/full/gnode.ML"  
  "../../../goaltype/full/goaltyp_json.ML"  
  "../../../goaltype/full/goaltyp_match.ML"
  "../../../goaltype/full/goaltyp_i.ML"

(* for simple goaltyp 

  "../../../goaltype/simple/gnode.ML"
  "../../../goaltype/simple/goaltyp_json.ML"  
  "../../../goaltype/simple/goaltyp_match.ML"
  "../../../goaltype/simple/goaltyp_i.ML"
*)
begin

end



