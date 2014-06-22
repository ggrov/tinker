(* simple test of proof representation *)
theory Graph                                                                                           
imports        
  RTechn                          
  BasicGoalTyp                                                                            
  "~~/contrib/quantomatic/core/isabelle/QuantoCore"                                                           
uses
  "../../debug_handler.ML"

  (* generic for graphs - move to quantomatic? *)
  (* "../../graph/graph_comb.ML" *)

  "../../graph/substdata.ML"                                  
  "../../graph/vertex.ML"                            
  "../../graph/edge.ML"  
  "../../graph/graph.ML"                     
  "../../graph/theory.ML"                                   
begin

 (* changes
    Graph.EData.data -> Graph.edata
    Graph.get_edge -> Graph.get_edge_info
    Graph.get_vnames -> get_vertices 
  *)

end



