(*  Title:      now: isaplanner/src/libs/safe_object.ML
                was: Pure/General/object.ML
    ID:         $Id: safe_object.ML 2575 2010-06-26 13:17:40Z lucasd $
    Author:     A copy of code by Markus Wenzel, TU Muenchen
    License:    GPL (GNU GENERAL PUBLIC LICENSE)

Generic objects of arbitrary type -- fool the ML type system via
exception constructors.
*)

signature SAFE_OBJECT =
sig
  type T
  type kind
  val kind: string -> kind
  val name_of_kind: kind -> string
  val eq_kind: kind * kind -> bool
  val kind_error: kind -> 'a
end;

structure SafeObject: SAFE_OBJECT =
struct


(* anytype values *)

type T = exn;


(* kinds *)

datatype kind = Kind of string * stamp;

fun kind name = Kind (name, stamp ());

fun name_of_kind (Kind (name, _)) = name;

fun eq_kind (Kind (_, s1), Kind (_, s2)) = s1 = s2;

fun kind_error k =
  error ("## RUNTIME TYPE ERROR ##\nFailed to access " ^ quote (name_of_kind k) ^ " object");


end;
