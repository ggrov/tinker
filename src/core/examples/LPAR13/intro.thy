theory intro
imports   "../../provers/isabelle/basic/build/BIsaMeth"  
begin
ML{*
 val path = "" (* set your path of Proof Strategy language first !! *)
*}
setup {* PSGraphMethod.read_graph ("intro",path ^ "psgraph/src/examples/LPAR13/intro.psgraph") *}      

(* manual evaluation *)
ML{*
val ps = PSGraphMethod.get_graph @{theory} "intro";
val [e0] = EVal.init ps @{context} @{prop "A --> B --> (! x. P x \<and> (? y. Q x y))"};
*}


lemma "A --> B --> (! x. P x \<and> (? y. Q x y))"
(* apply (psgraph intro) *)
(* apply (psgraph (interactive) intro) *) 
(* apply (psgraph (current)) *)
 oops

end
