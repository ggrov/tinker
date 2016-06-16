theory taut_tac_setup
imports ai4fm_setup
begin

ML{*
  val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z)." ^
 "is_goal(Z) :- is_term(concl, Z)." ^
 "has_hyp(Z) :- is_term(hyps, Z)." ^
 "not_literal(X) :- not(is_literal(X))." ^
 "c_and_non_literal(X) :- c(X), dest_trm(concl, Y1, Y2), not_literal(Y2)." ^
 "h_and_non_literal(X) :- top_symbol(hyps,X,Y), dest_trm(Y, Z1, Z2), not_literal(Z2)." ^
 "asm_to_elim(hyps) :- h(conj)." ^
 "asm_to_elim(hyps) :- h(disj)." ^
 "asm_to_elim(hyps) :- h(eq)." ^
 "asm_to_elim(hyps) :- h(implies)." ^
 "asm_to_elim(hyps) :- h_and_non_literal(not)." ^
 "no_asm_to_elim(X) :- not(asm_to_elim(X)).";

  val data =  
  data 
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);
*}

end
