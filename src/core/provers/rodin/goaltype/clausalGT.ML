(* Clausal Goal Type function:
  type : env -> pnode -> arg list
  arg =
   Name of string (* x,y,x *)
 | Var of string (* X,Y,Z *)
 | PVar of string (* ?x,?y,?z ...*)
 | Concl (* turn into name? *) 
 | Hyps (* turn into name? *)
 | Ignore (* turn into name? *)
 | Term of Prover.term 
 | Clause of string * (arg list)

 *)

fun top_symbol env pnode [r,C.Name p] 
