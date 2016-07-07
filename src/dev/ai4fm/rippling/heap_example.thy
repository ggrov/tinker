theory heap_example
imports "heap/HEAP1Proofs"
begin 

thm F1_inv_def
thm Disjoint_def
thm sep_def
thm nat1_map_def

ML{*
  (*  fun eval_text text = ML_Context.eval ML_Compiler.flags (Position.start) (ML_Lex.read (Position.start) text); *)
    fun eval_text text =(
      writeln ("exec : "^ text);
      Secure.use_text ML_Env.local_context (1, "ML") (false) text  
    ) handle exn => raise exn;
*}
ML{*
Secure.use_text;
eval_text;
val f = fn _ => writeln "this is test for method call in Isabelle"
*}
lemma "finite (dom(f)) \<and> the (f(r)) \<noteq> s \<and> nat1 s \<and> r \<in> dom(f) \<and> s \<le> the(f(r)) \<Longrightarrow> finite(dom({r} -\<triangleleft> f))"
ML_prf{*
eval_text "f()"
*}
by (metis k_finite_dom_ar)
end
