theory example
imports example_def
begin

-- "Example 1: run in automated mode"
  lemma "A \<Longrightarrow> A" 
  by (psgraph asm)

-- "Example 2: run in interactive mode"
  lemma "A \<Longrightarrow> (A \<and> A)  \<and> (A \<longrightarrow> A)"
  (* apply (psgraph (interactive) conj_impI) *)
  oops

-- "Example 3: run in current mode"
  lemma "A \<longrightarrow> (A \<and> A) " 
  (* apply (psgraph (current)) *)
  oops


end
