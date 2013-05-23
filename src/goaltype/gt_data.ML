signature GT_DATA =
sig
 
  structure Prover : PROVER
 
  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of Prover.term (*Prover.term*)
    | Position of Prover.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  val match_data : (data * data) -> bool  
  
end (* signature *)

functor GTDataFun (Prover: PROVER)  : GT_DATA =
struct

  structure Prover = Prover

  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of Prover.term (* must be generalised beyond TP system *) 
    | Position of Prover.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  fun match_data ((Int a), (Int b)) = (a = b)
    | match_data ((String a), (String b)) = (case String.compare (a,b) of EQUAL => true | _ => false)
    | match_data ((Term a), (Term b)) =  Prover.match Prover.globe_ctxt (a,b) (*(case String.compare (a,b) of EQUAL => true | _ => false)*)
    | match_data ((Position a), (Position b)) = Prover.eq_pos (a,b)
    | match_data ((Bool a), (Bool b)) =  (a = b)
    | match_data ((DVar a), (DVar b)) = (case F.name_ord (a,b) of EQUAL => true | _ => false)
    | match_data (_,_) = false

end (* structure *)


