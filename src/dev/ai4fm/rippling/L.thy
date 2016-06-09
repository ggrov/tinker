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
  append_Nil :"[] @ ys = ys"
  | append_Cons : "(x#xs) @ ys = x # xs @ ys"

declare append.simps [wrule]

fun rev :: "'a List => 'a List"
  where 
  rev_nil: "rev([]) = []"
  | rev_cons : "rev(x#xs) = rev(xs) @ [x]"

declare rev.simps[wrule]

fun qrev :: "'a List => 'a List => 'a List" 
  where 
  qrev_nil :  "qrev [] l = l" 
 | qrev_cons : "qrev (x # xs) l = qrev xs (x # l)"

declare qrev.simps[wrule]

fun rot :: "(N \<times> 'a List) => 'a List" 
  where
  rot_0 :  "rot (0, x) = x" 
  | rot_nil  : "rot (n, []) = []"
  | rot_sucCcons: "rot ((suc n), (h # t)) = (rot (n, t @ [h]))"

declare rot.simps[wrule]

fun len :: "'a List => N"   ("len _" [500] 500)
where
  len_nil:     "len [] = 0" |
  len_cons:    "len (h # t) = suc (len t)"

declare len.simps[wrule]
end
