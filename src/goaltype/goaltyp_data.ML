signature GT_DATA =
sig

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of StrName.name (* variable: not used at the moment but may be required *)
  
  type data (* list/set of list/set of data *)
  
  val to_list : data -> feature list list
  val from_list : feature list list -> data
  val single_list : feature list -> data

end (* signature *)

structure GTData =
struct

  datatype feature = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of general_term(*must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of StrName.name (* variable: not used at the moment but may be required *)



end (* structure *)
