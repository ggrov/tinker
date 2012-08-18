(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/term_const_lib.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Code to handle constants in terms, in particular to retrieve a
    list of constnats from a term/theorem.

    The idea is that a the multiset of constants in a term is a
    generalisation of the term that can be used to help proof search
    (both pruning, by extended loop checking - see lemma speculation -
    and guidance by looking up terms that have useful constants,
    although this isn't implemented yet.)

*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

infix mem

signature TERMCONST_LIB =
sig

  (* type of a term constants abstraction of a term 
     (multiset of constants) *)
  type T

  val string_of : T -> string
  val pretty_of : T -> Pretty.T
  val consts_list_of : T -> string list
  val consts_of : Term.term -> T
  val consts_of_thm : Thm.thm -> T

  val extra_const_chk : T * T -> bool
  val extra_const_from_term_chk : T -> Term.term -> bool
  val extra_const_terms_chk : Term.term * Term.term -> bool

  val mem: ''a * ''a list -> bool

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure TermConstLib : TERMCONST_LIB =
struct

(* constant multisets are expressed as a list of strings, where the
string is the string associated with the constant. THINK: would having
types help? can we aslo store the type? ie to distinguish between
polymophic stuff, like addition for different types. *)
type T = string list;

(* pretty stuff *)
fun pretty_of ms = Pretty.str_list "[" "]" ms;
val string_of = Pretty.string_of o pretty_of;

(* get the list of consts as strings *)
fun consts_list_of (ms : T) = ms;

(* shortcut for term of a theorem. *)
fun term_of_thm t = term_of (cprop_of t);

(* pull the constants out of a term. *)
fun consts_of trm =
    let fun consts_of_aux (Const (s, t)) l = (s :: l)
          | consts_of_aux (Free (s, t)) l = l
          | consts_of_aux (Var ((n, i), t)) l = l
          | consts_of_aux (Bound i) l = l
          | consts_of_aux (Abs (s, ty, r)) l = 
            consts_of_aux r l
          | consts_of_aux (op $ (t1, t2)) l = 
            consts_of_aux t1 (consts_of_aux t2 l)
    in
      consts_of_aux trm []
    end;
    
(* pull the constants out of a theorem. *)
fun consts_of_thm thm = consts_of (term_of_thm thm);

(* Removed from Library in Isabelle 2009-2 *)
fun x mem xs = member (op =) xs x;
(* Removed from Library in Isabelle 2009-2 *)

local 
  fun diffmemchk _ [] = false
    | diffmemchk l (h::t) = not (h mem l) orelse (diffmemchk l t)
in

fun string_eq x = Library.string_ord x = EQUAL;

(* m1 > m2 *)
fun extra_const_chk (m1, m2) = (* note: use of distinct is for efficieny *)
    diffmemchk (Library.distinct string_eq m2) m1;

(* special version for efficiency submuption checking *)
(* implicit arg: t2 : Term.term
   (m < t2)
 *)
fun extra_const_from_term_chk m = 
    (diffmemchk (Library.distinct string_eq m)) o consts_of;

(* t1 > t2 *)
fun extra_const_terms_chk (t1, t2) =
    extra_const_chk (consts_of t1, consts_of t2);

end; (* local *)



end; (* struct *)

(* 
open LucasListUtils;

(thms_containing ["HOL.plus_class.plus"]) @ (thms_containing ["HOL.eq"]) @ (thms_containing ["Nat.Suc"]);

remove_dups (map (fn (s,t) => s) ((thms_containing ["HOL.plus_class.plus"]) @ (thms_containing ["Nat.Suc"])));
*)
