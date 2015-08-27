(* simple test of proof representation *)
theory Graph                                                                                           
imports                            
  BasicGoalTyp                                                                                                                        
begin

  ML_file "../../graph/graph_data.sig.ML"          
  ML_file "../../graph/graph_data.ML"                                           
  ML_file "../../graph/io.ML"
  ML_file "../../graph/theory.ML"
  ML_file "../../graph/env_tac_utils.ML"
  ML_file "../../graph/theory_io.sig.ML"    
  ML_file "../../graph/theory_io.ML"
       

  (* generic for graphs - move to quantomatic? *)
  (* ML_file "../../graph/graph_comb.ML" *)

(*
  "../../graph/substdata.ML"                                  
  "../../graph/vertex.ML"                            
  "../../graph/edge.ML"  
  "../../graph/graph.ML"                     
  "../../graph/theory.ML"    
*)                               

 (* changes
    Graph.EData.data -> Graph.edata
    Graph.get_edge -> Graph.get_edge_info
    Graph.get_vnames -> get_vertices 
  *)

end



