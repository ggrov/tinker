signature GT_DATA =
sig
 
  structure GPrf : GPRF
 
  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of string (*GPrf.term*)
    | Position of GPrf.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  val match_data : GPrf.context -> (data * data) -> bool  
  
end (* signature *)

functor GTDataFun (GP: GPRF)  : GT_DATA =
struct

  structure GPrf = GP

  datatype data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of string (*GPrf.term*) (* must be generalised beyond TP system *)(*FIXME : string ?? or term ???*)   
    | Position of GPrf.pos
    | Bool of bool
    | DVar of F.name (* variable: not used at the moment but may be required *)

  fun match_data _ ((Int a), (Int b)) = (a = b)
    | match_data _ ((String a), (String b)) = (case String.compare (a,b) of EQUAL => true | _ => false)
    | match_data ctxt ((Term a), (Term b)) = (case String.compare (a,b) of EQUAL => true | _ => false) (*GPrf.match ctxt (a,b*)
    | match_data _ ((Position a), (Position b)) = GPrf.eq_pos (a,b)
    | match_data _ ((Bool a), (Bool b)) =  (a = b)
    | match_data _ ((DVar a), (DVar b)) = (case F.name_ord (a,b) of EQUAL => true | _ => false)
    | match_data _ (_,_) = false

end (* structure *)


