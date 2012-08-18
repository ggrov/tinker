structure PologifyIsabelleTerm = 
struct 

fun pretty_typelist [] f = ""
  | pretty_typelist [(h: typ)] (f : typ -> string) = (f h)
  | pretty_typelist ((h: typ) :: t) (f : typ -> string) = 
      (f h) ^ ", " ^ (pretty_typelist t f);


(* pretty_sort s = print a sort 
   s = sort to print : string list
*)
fun pretty_sort [] = ""
  | pretty_sort ([h])  = "'" ^ h ^ "'"
  | pretty_sort (h :: t)  = "'" ^ h ^ "'," ^ (pretty_sort t);


(* pretty_type t = print a type
   t = type to print : type
*)
fun pretty_type (Type (n, l)) = 
      "type('" ^ n ^ "', [" ^ (pretty_typelist l pretty_type) ^ "])"
  | pretty_type (TFree (n, s)) = 
      "tfree('" ^ n ^ "', [" ^ (pretty_sort s) ^ "])"
  | pretty_type (TVar ((n, i), s)) = 
      "tvar( ('" ^ n ^ "', " ^ (string_of_int i) ^ "), [" ^ (pretty_sort s) ^ "])";


(* pretty_term t = print a term prints types and sorts too.
   t = term to print : term
*)
fun pretty_term (Const (s, t)) = 
      "const('" ^ s ^ "', " ^ (pretty_type t) ^ ")"
  | pretty_term (Free (s, t)) = 
      "free('" ^ s ^ "', " ^ (pretty_type t) ^ ")"
  | pretty_term (Var ((n, i), t)) = 
      "var( ('" ^ n ^ "'," ^ (string_of_int i) ^ "), " ^ (pretty_type t) ^ ")"
  | pretty_term (Bound i) = 
      "bound(" ^ (string_of_int i) ^ ")"
  | pretty_term (Abs (s, t, r)) = 
      "abs('" ^ s ^ "'," ^ (pretty_type t) ^ ", \n  " ^ (pretty_term r) ^ ")"
  | pretty_term (op $ (t1, t2)) = 
      "app(" ^ (pretty_term t1) ^ ", " ^ (pretty_term t2) ^ ")";


end;