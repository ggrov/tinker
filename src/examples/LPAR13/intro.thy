theory intro
imports   "../../provers/basic_isabelle/build/BIsaMeth"  
begin
ML{*
 val path = "/u1/staff/gg112/" (* /Users/ggrov/" *)
*}
setup {* PSGraphMethod.read_graph ("intro",path ^ "psgraph/src/examples/LPAR13/intro.psgraph") *}      

(* manual evaluation *)
ML{*
val ps = PSGraphMethod.get_graph @{theory} "intro";
val [e0] = EVal.init ps @{context} @{prop "A --> B --> (! x. P x \<and> (? y. Q x y))"};
*}






ML{*
val g = PSGraphMethod.get_graph @{theory} "intro" |> PSGraph.get_graph;

PSGraph.PSTheory.write_dot "/Users/ggrov/test1.dot" g;
*}


lemma "A --> B --> (! x. P x \<and> (? y. Q x y))"
 apply (psgraph intro)
  (* apply (psgraph (passive)) *)  

end
