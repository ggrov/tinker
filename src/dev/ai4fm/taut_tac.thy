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
 "h(Z) :- top_symbol(hyps,Z)." ^
 "is_goal(Z) :- is_term(concl, Z)." ^
 "has_hyp(Z) :- is_term(hyps, Z)." ^
 "not_literal(X) :- not(is_literal(X))." ^
 "c_and_non_literal(X) :- c(X), dest_term(concl, Y1, Y2), not_literal(Y2)." ^
 "h_and_non_literal(X) :- top_symbol(hyps,X,Y), dest_term(Y, Z1, Z2), not_literal(Z2)." ^
 "asm_to_elim(hyps) :- h(conj)." ^
 "asm_to_elim(hyps) :- h(disj)." ^
 "asm_to_elim(hyps) :- h(eq)." ^
 "asm_to_elim(hyps) :- h(implies)." ^
 "asm_to_elim(hyps) :- h_and_non_literal(not)." ^
 "no_asm_to_elim(X) :- not(asm_to_elim(X))." ^
 "no_ccontr(X) :- not(is_ccontr(X)).";

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
