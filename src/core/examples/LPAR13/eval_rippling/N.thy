theory N 
imports "../../../provers/isabelle/basic/build/ThyRippling"
begin

no_notation Groups.zero ("0")
no_notation Groups.plus (infixl "+" 65)

datatype N = Nzero  ("0")
           | Nsuc N ("suc _" [100] 100)
fun add :: "N => N => N" (infixr "+" 70)
where
  add_0:  "(0 + y) = (y)"
| add_suc :  "suc x + y = suc (x + y)"

no_notation Groups.times (infixl "*" 70)

fun mult :: "N => N => N" (infixl "*" 75)
where 
  mult_0 :  "(0 * y) = 0"
| mult_suc :  "(suc x) * y = y + (x * y)"


fun exp :: "N => N => N"            (infixr "^" 80)
where
  exp_0   : "x ^ 0 = suc 0"
| exp_suc : "x ^ (suc y) = x * (x ^ y)"

declare add.simps  [wrule]
declare mult.simps [wrule]
declare exp.simps [wrule]


end
