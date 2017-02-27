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


  
  ML_file "../../graph/graph_io.sig.ML"    
  ML_file "../../graph/graph_io.ML"
  
    
ML{*

  type arg_typ = string list list


  datatype nvdata = T_Atomic of (string * arg_typ)
                  | T_Graph of (string * arg_typ) 
                  | T_Identity 
                  | G_Break (* breakpoint *)
                  | G of GoalTyp.gnode 
                  | T_Var of string (* variable of rtechn *)
                  | G_Var of string (* variable of gnode *)

*}
end



