(* simple test of proof representation *)
theory Graph                                                                                          
imports                            
  GoalTyp                                                                                                                      
begin 

ML_file "../../graph/graph_data.sig.ML"          
ML_file "../../graph/graph_data.ML" 
                              
ML_file "../../graph/graph.sig.ML"
ML_file "../../graph/graph.ML"  
              
ML_file "../../graph/graph_utils.ML"    
ML_file "../../graph/env_tac_utils.ML"

end



