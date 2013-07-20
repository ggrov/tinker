(* simple test of proof representation *)
theory demo2                                          
imports demodefs    
begin

-- "this demo should show how to draw strategies"

setup {* PSGraphMethod.read_graph ("demo2","/Users/ggrov/psgraph/src/examples/AI4FM13/demo2.psgraph") *}     


ML{*

val fname = "/Users/ggrov/psgraph/src/examples/AI4FM13/demo2.psgraph"; 
     val json = Json.read_file fname 
     val graph = PSGraph.PSTheory.in_json json
     val psgraph = PSGraph.empty
                   |> PSGraph.set_graph graph
                   |> PSGraph.load_atomics [("assumption",K atac)];

(* just prints two id boxes after each others. *)
PSGraph.PSTheory.write_dot "/Users/ggrov/test1.dot" graph;   
*}


lemma "A \<longrightarrow> A \<and> A" 
  apply (ipsgraph demo2)    
 oops

end



