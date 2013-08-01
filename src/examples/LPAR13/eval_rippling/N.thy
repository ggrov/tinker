theory N 
imports "../../../provers/basic_isabelle/build/BIsaMeth"
begin

no_notation Groups.zero ("0")
no_notation Groups.plus (infixl "+" 65)

datatype N = Nzero  ("0")
           | Nsuc N ("suc _" [100] 100)
fun add :: "N => N => N" (infixr "+" 70)
where
  add_0    :  "(0 + y) = (y)"
| add_suc  :  "suc x + y = suc (x + y)"


no_notation Groups.times (infixl "*" 70)

fun mult :: "N => N => N" (infixl "*" 75)
where 
  mult_0    :  "(0 * y) = 0"
| mult_suc  :  "(suc x) * y = y + (x * y)"


ML{* 
  val N_thms = 
    [
      ("add_0", @{thm "add_0"}), 
      ("add_suc", @{thm "add_suc"}),  ("add_suc(sym)", Substset.mk_sym_thm @{thm "add_suc"}),
      ("mult_0", @{thm "mult_0"}),  
      ("mult_suc", @{thm "mult_suc"}),  ("mult_suc(sym)", Substset.mk_sym_thm @{thm "mult_suc"})
    ];
*}

end
