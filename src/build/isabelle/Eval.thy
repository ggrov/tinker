(* simple test of proof representation *)
theory Eval                                                                                                                                                                                           
imports           
  PSGraph                                                                       
begin         

  ML_file "../../eval/eval_data.sig.ML"                                               
  ML_file "../../eval/eval_data.ML"                                                       


  ML_file "../../eval/eval.sig.ML"                                     
  ML_file "../../eval/eval.ML"                                                         

  (* interactive evaluation *)
  ML_file "../../eval/ieval.sig.ML"                                       
  ML_file "../../eval/ieval.ML"    

  (* socket communication for the tinker gui *)
  ML_file "../../debug_handler.ML"  
  ML_file "../../interface/text_socket.ML"
end

