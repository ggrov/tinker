(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      fterm.ML
    Authors:    Lucas Dixon, ldixon@inf.ed.ac.uk
                12 May 2008
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Flattened Terms: don't use app tree, instead have head and tail list. 

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
signature FTERM 
= sig

exception impossible_exp of string;

(* A version of terms where the Application strutcutre puts the head
   term first for constant time access to head of a term. *)
datatype atomic = 
         aConst of string * Trm.typ
       | aBound of int
       | aVar of Trm.Var.name * Trm.typ
       | aFree of Trm.Free.name * Trm.typ
       | aAbs of string * Trm.typ * T
and T = 
    App of atomic * T list
  | Atomic of atomic;

val of_isaterm : Term.term -> T
val isaterm_of : T -> Term.term

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure FTerm : FTERM 
= struct

exception impossible_exp of string;

(* A version of terms where the Application strutcutre puts the head
   term first for constant time access to head of a term. *)
datatype atomic = 
         aConst of string * Trm.typ
       | aBound of int
       | aVar of Trm.Var.name * Trm.typ
       | aFree of Trm.Free.name * Trm.typ
       | aAbs of string * Trm.typ * T
and T = 
    App of atomic * T list
  | Atomic of atomic;

(* only works on beta-contracted terms *)
fun of_isaterm (Const x) = Atomic (aConst x)
  | of_isaterm (Bound x) = Atomic (aBound x)
  | of_isaterm (Var x) = Atomic (aVar x)
  | of_isaterm (Free x) = Atomic (aFree x)
  | of_isaterm (Abs (s,ty,t)) = Atomic (aAbs(s,ty,of_isaterm t))
  | of_isaterm (t as a $ b) = 
    let val (h,t) = strip_comb t 
    in 
      App
        (case h of 
           Const x => aConst x
         | Bound x => aBound x
         | Var x => aVar x
         | Free x => aFree x
         | Abs (s,ty,t) => aAbs(s,ty, of_isaterm t)
         | (a $ b) => raise impossible_exp "of_isaterm",
         map of_isaterm t)
    end;

fun isaterm_of_atom (aConst x) = Const x
  | isaterm_of_atom (aBound x) = Bound x
  | isaterm_of_atom (aVar x) = Var x
  | isaterm_of_atom (aFree x) = Free x
  | isaterm_of_atom (aAbs (s,ty,t)) = Abs(s,ty,isaterm_of t)
and isaterm_of (Atomic a) = isaterm_of_atom a
  | isaterm_of (App (a,l))  = Term.list_comb (isaterm_of_atom a, map isaterm_of l);


end;

