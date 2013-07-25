theory intro
imports   "../../provers/basic_isabelle/build/BIsaMeth"  
begin
ML{*
 val path = "/Users/ggrov/"
*}
setup {* PSGraphMethod.read_graph ("intro",path ^ "psgraph/src/examples/LPAR13/intro.psgraph") *}      

lemma "A --> B --> (! x. P x \<and> Q x)"
  apply (psgraph (interactive) intro) 

end
