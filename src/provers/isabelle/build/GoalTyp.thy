(* simple test of proof representation *)
theory GoalTyp 
imports                
 "basic/BasicIsaPS"                                               
begin

 ML_file  "../../../goaltype/full/goaltyp_data.ML"
 ML_file "../../match_param.ML"
 ML_file  "../../../goaltype/full/class.ML"  
 ML_file "../../../goaltype/full/link.ML"
 
(* for full goaltyp *)
 ML_file "../../../goaltype/full/goaltyp.ML"  
 ML_file  "../../../goaltype/full/gnode.ML"  
 ML_file  "../../../goaltype/full/goaltyp_json.ML"  
 ML_file  "../../../goaltype/full/goaltyp_match.ML"
 ML_file  "../../../goaltype/full/goaltyp_i.ML"
 ML_file  "../../../goaltype/full/full_goaltyp.ML"

end



