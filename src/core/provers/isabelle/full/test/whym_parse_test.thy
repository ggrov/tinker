(* simple test of combinators *)
theory whym_parse_test                                              
imports               
 "../build/Parse"                                                                  
begin

 -- "attempt 1 - note that K[] implies that no goal features are lifted"
 ML{*
   val whymtree = WhyMTree.parse_file "/u1/staff/gg112/psgraph/src/parse/examples/attempt_lem1.yxml";
   val graph =  WhyMParse.graph_of_goal @{context} (K[]) whymtree;
*}

-- "write to file (path has to be changed)"
ML {*
   PSGraph.PSTheory.write_dot "/u1/staff/gg112/attempt1.dot" graph
 *}

 -- "attempt 2"
 ML{*
   val whymtree = WhyMTree.parse_file "/u1/staff/gg112/psgraph/src/parse/examples/attempt_lem2.yxml";
   val graph =  WhyMParse.graph_of_goal @{context} (K[]) whymtree;
*}

-- "write to file (path has to be changed)"
ML {*
   PSGraph.PSTheory.write_dot "/u1/staff/gg112/attempt2.dot" graph 
 *}






end



