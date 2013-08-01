theory L
imports N
begin 

(* begin with some setups to ignore list definitions *)
no_translations
  "[x, xs]"     == "x#[xs]"
  "[x]"         == "x#[]"
no_syntax
 "@list" :: "args => 'a list"    ("[(_)]")
no_notation Nil ("[]")
no_notation Cons (infixr "#" 65)
no_notation append (infixr "@" 65)

hide_const (open) Nil Cons length map append rev rotate
hide_type (open) list

datatype 'a List =nil ("[]") 
                 | Cons "'a" "'a List"      (infixr "#" 65)


translations
  "[x, xs]"     == "x#[xs]"
  "[x]"         == "x#[]"

fun append :: "'a List => 'a List => 'a List" (infixr "@" 65)
where
  append_Nil:"[] @ ys = ys"
  | append_Cons: "(x#xs) @ ys = x # xs @ ys"

fun map :: "('a=>'b) => ('a List => 'b List)"
  where
  map_nil: "map f [] = []"
  | map_cons :"map f (x#xs) = f(x)#map f xs"

fun rev :: "'a List => 'a List"
  where 
  rev_nil: "rev([]) = []"
  | rev_cons: "rev(x#xs) = rev(xs) @ [x]"

fun qrev :: "'a List => 'a List => 'a List" 
  where 
  qrev_nil:  "qrev [] l = l" 
 | qrev_cons: "qrev (x # xs) l = qrev xs (x # l)"

fun rot :: "(N \<times> 'a List) => 'a List" 
  where
  rot_0:  "rot (0, x) = x" 
  | rot_nil : "rot (n, []) = []"
  | rot_sucCcons: "rot ((suc n), (h # t)) = (rot (n, t @ [h]))"

fun len :: "'a List => N"   ("len _" [500] 500)
where
  len_nil:     "len [] = 0" |
  len_cons:    "len (h # t) = suc (len t)"


ML{*
  val L_thms =
    [
      ("append_Nil", @{thm "append_Nil"}), 
      ("append_Cons", @{thm "append_Cons"}),  ("append_Cons(sym)", Substset.mk_sym_thm @{thm "append_Cons"}),
      ("map_nil", @{thm "map_nil"}),
      ("map_cons", @{thm "map_cons"}),  ("map_cons(sym)", Substset.mk_sym_thm @{thm "map_cons"}),
      ("rev_nil", @{thm "rev_nil"}),
      ("rev_cons", @{thm "rev_cons"}),  ("rev_cons(sym)", Substset.mk_sym_thm @{thm "rev_cons"}),
      ("len_nil", @{thm "len_nil"}),
      ("len_cons", @{thm "len_cons"}),  ("len_cons(sym)", Substset.mk_sym_thm @{thm "len_cons"}),
      ("qrev_nil", @{thm "qrev_nil"}),
      ("qrev_cons", @{thm "qrev_cons"}),  ("qrev_cons(sym)", Substset.mk_sym_thm @{thm "qrev_cons"}),
      ("rot_0", @{thm "rot_0"}),("rot_nil", @{thm "rot_nil"}),
      ("rot_sucCcons", @{thm "rot_sucCcons"}),  ("rot_sucCcons(sym)", Substset.mk_sym_thm @{thm "rot_sucCcons"})
      ];
*}
end
