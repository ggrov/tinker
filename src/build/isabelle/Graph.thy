(* simple test of proof representation *)
theory Graph                                                                                           
imports                            
  BasicGoalTyp                                                                           
(*  "~~/contrib/quantomatic/core/isabelle/QuantoCore"  *)
(*  "~~/contrib/quantomatic/core/quanto"       quanto new core, require Isabelle 2014*)                                                
begin
 
  ML_file "../../debug_handler.ML"
  ML_file "../../graph/graph_data.sig.ML"          
  ML_file "../../graph/graph_data.ML"                                           
  ML_file "../../graph/io.ML"
  ML_file "../../graph/theory.ML"
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



