theory N
imports "../build/HOL_IsaP" 
begin

no_notation Groups.zero ("0")
no_notation Groups.plus (infixl "+" 65)

datatype N = Nzero  ("0")
           | Nsuc N ("suc _" [100] 100)

declare N.inject[wrule]

fun add :: "N => N => N" (infixr "+" 70)
where
  add_0    [wrule]:  "(0 + y) = (y)"
| add_suc  :  "suc x + y = suc (x + y)"

declare add.simps[wrule]

ML {* 
WRulesGCtxt.print @{context};
(* WRules.print @{context} (WRulesGCtxt.wrules_of_ctxt @{context}); *)
*}

(* IMPROVE: use nice notation? *)
fun minus :: "N => N => N"
where
  minus_0    :  "(minus 0 y) = 0"
| minus_suc  :  "(minus (suc x) y) = 
  (case y of (0) => x| (suc y2) => minus x y)"

declare minus.simps[wrule]


no_notation Groups.times (infixl "*" 70)

fun mult :: "N => N => N" (infixl "*" 75)
where 
  mult_0    :  "(0 * y) = 0"
| mult_suc  :  "(suc x) * y = y + (x * y)"

declare mult.simps[wrule]

fun exp :: "N => N => N"            (infixr "^" 80)
where
  exp_0   : "x ^ 0 = suc 0"
| exp_suc : "x ^ (suc y) = x * (x ^ y)"

declare exp.simps[wrule]


(* IMPROVE: add this the following (will nead to remove old syntax)
primrec
  less_0[wrule]   : "x < (0 :: N) = False"
  less_Suc[wrule] : "x < (suc y) = (case x of 0 => True | suc z => z < y)"
*)

end;
