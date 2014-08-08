theory test
imports
  "../../build/isabelle/BasicGoalTyp" 
  (* "../../build/isabelle/Eval"
  "../../provers/isabelle/basic/build/BIsaMeth"
  *)
begin

  ML_file "goaltype.ML"                                                               

 (*
   f(X,Y) :- a(X,Y), b(X,Y).
   f(g(X),Y) :- b(X),c(Y).
   f(g(test),h(test2)).
 *)

(*
  top_symbol(Concl,X) := case lookup(X) of  get_top(Concl)
  top_symbol(X) :- top_symbol(Concl,X).
*)

  

end
