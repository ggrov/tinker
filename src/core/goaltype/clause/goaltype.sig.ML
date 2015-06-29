signature CLAUSE_GT =
struct
  structure Prover : PROVER
  datatype A = E of Prover.term | L of Prover.term list (* or facts? *)
  type env = A StrName.NTab.T
  

end (* struct *)
