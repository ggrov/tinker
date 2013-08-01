theory demo2                                          
imports demodefs    
begin

setup {* PSGraphMethod.read_graph ("mydemo","/Users/ggrov/demo.psgraph") *}      


lemma "A \<longrightarrow> A \<and> A"
  apply (ipsgraph mydemo)
  (* apply (ipsgraph mydemo) *)
  oops



setup {* PSGraphMethod.read_graph ("demo2","/Users/ggrov/psgraph/src/examples/AI4FM13/demo2.psgraph") *}     


lemma "A \<longrightarrow> A \<and> A" 
  (* apply (ipsgraph demo2) *)   
 oops

setup {* PSGraphMethod.read_graph ("demo3","/Users/ggrov/psgraph/src/examples/AI4FM13/demo2v2.psgraph") *}      






lemma "A \<longrightarrow> (B \<longrightarrow> (C \<longrightarrow> A \<and> B \<and> C))" 
  (* apply (ipsgraph demo3) *)
 oops

end

(* debug stuff 

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
*)


