signature MATCH_PARAM =
sig
  structure GData : GT_DATA

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name

  val class_match : 
    C.name (* name of class *)
    -> GData.Prover.context 
    -> GData.Prover.term (* one element of the class *)
    -> GData.data 
    -> bool (* raises link_match_exp *)

  val link_match : 
     L.name 
     -> GData.Prover.context 
     -> GData.Prover.term * GData.Prover.term 
     -> GData.data 
     -> bool (* raises link_match_exp *)
end;

functor ProverMatchFun(structure Prover : PROVER
                       structure Atomic : ATOMIC) : MATCH_PARAM =
struct

  structure GData = ??

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name

  fun 


end (* *)

