(* simple test of proof representation *)
theory Graph                                                                                             
imports         
  RTechn                          
  GoalTyp                                                            
  "~~/contrib/quantomatic/core/isabelle/QuantoCore"                                                         
uses
  "../../../graph/graph_comb.ML" (* generic for graphs - move to quantomatic? *)

  "../../../goaltype/gnode.ML" (*fixme: should this be functorised over? *)
  "../../../graph/substdata.ML"          
  "../../../graph/vertex.ML"                            
  "../../../graph/edge.ML"  
  "../../../graph/graph.ML"                     
  "../../../graph/theory.ML"       
  (* "../../../graph/io.ML"        *)

  (* auxiliary functions (should be possibly for any graph) *)
 (*  "../graph/graph_util.ML" *) 

(*
  "../../../graph/graph_comb.ML"   
 
*)

  (* proof strategy graphs *)     

(*  "../../../psgraph/psgraph.ML"
  "../../../psgraph/psgraph_comb.ML"            
*) 
begin

end



