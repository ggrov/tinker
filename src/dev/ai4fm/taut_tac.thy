theory taut_tac
imports ai4fm_setup
begin
ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val ps_file = "simple_taut.psgraph";
*}

ML{*
  val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- member(X,hyps), top_symbol(X,Z)." ^
 "is_goal(Z) :- eq_term(concl, Z)." ^
 "has_hyp(Z) :- eq_term(hyps, Z)." ^
 "not_literal(X) :- not(is_literal(X))." ^
 "c_and_non_literal(X) :- c(X), dest_term(concl, _, Y2), not_literal(Y2)." ^
 "h_and_non_literal(X) :- member(X,hyps), top_symbol(X,Z), dest_term(Y, _, Z2), not_literal(Z2)." ^
 "asm_to_elim() :- h(conj)." ^
 "asm_to_elim() :- h(disj)." ^
 "asm_to_elim() :- h(eq)." ^
 "asm_to_elim() :- h(implies)." ^
 "asm_to_elim() :- h_and_non_literal(not)." ^
 "no_asm_to_elim(X) :- not(asm_to_elim(X))." ^
 "not_empty_list(X) :- not(empty_list(X)).";

  val data =  
  data 
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val taut = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);

*}

ML{*-
TextSocket.safe_close();*}  

ML{*-
val g = @{prop "(A \<and> A \<and> B) \<longrightarrow> (B \<and> A \<and> True)"};
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

ML{*-
val g =  @{prop "\<not> ( False \<and> (\<not>True))"};
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}

ML{* -
val g = @{prop "(A \<or> B) \<longrightarrow> (B \<or> A)"};
val thm = Tinker.start_ieval @{context} (SOME taut) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}
end
