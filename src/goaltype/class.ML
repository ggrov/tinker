(* to hold class features  *)

signature CLASS = 
sig
  
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
structure Class = 
struct 

  (* fixme: could be term dependent *)
  type position = int list

  datatype element_data = 
      Int of int
    | String of string (* not in paper, but simplifies across TPs (e.g. to hold function name) *)
    | Term of term (* must be generalised beyond TP system *)         
    | Position of position
    | Bool of bool
    | DVar of string (* variable: not used at the moment but may be required *)

  type data = element_data list list

  (* fixme: should we include a name? *)
  datatype T = Class of { name : C.name,
                          map : data F.NTab.T }

  val top = Class { name = C.mk "top", map = F.NTab.empty }; (* or this this bottom *)

  (* FIXME: to do make order *)
  fun ord (c1,c2) = EQUAL

end; (* struct *)


