(* simple test of proof representation *)
theory Parse                                                      
imports
  PreIsaP           
  IsaP  
begin

 ML_file "../../../parse/whym_tree.ML"  
 ML_file "../../../parse/whym_parse.ML" 

 -- "simple test"
 ML{*
   val whymtree = WhyMTree.parse_file "/u1/staff/gg112/psgraph/src/parse/examples/simple2.yxml";
   val graph =  WhyMParse.graph_of_goal @{context} (K[]) whymtree;
   PSGraph.PSTheory.write_dot "/u1/staff/gg112/pptest.dot" graph
 *}
end



