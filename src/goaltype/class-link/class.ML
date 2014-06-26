(* to hold class features  *)
signature CLASS_SHARING =
sig
  type T
  structure GoalTypData : GOALTYP_DATA_SHARING
end

signature CLASS = 
sig
  structure GoalTypData : GOALTYP_DATA

  type T
  val top : T
  
  val get_item : F.name -> T -> (GoalTypData.data list list) option
  val add_item: F.name -> (GoalTypData.data list list) -> T -> T
  val del_item : F.name -> T -> T
  val get_keys : T -> F.name list

  val get_name: T -> C.name
  val rename : C.name -> T -> T  
(*
  val eq : GoalTypData.Prover.context -> (T * T) -> bool
*)
  structure Sharing : CLASS_SHARING
    sharing type Sharing.T = T
    sharing Sharing.GoalTypData = GoalTypData
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* TODO: generalise, by creating a term structure and a functor over this *)
functor ClassFun (GoalTypData : GOALTYP_DATA) : CLASS = 
struct

  structure GoalTypData = GoalTypData

  type T = (C.name * (GoalTypData.data list list) F.NTab.T);
  val top = (C.mk "Top",  F.NTab.empty)


  exception CLASS_EXP of F.name * T
  fun get_item gname (_, class) =  F.NTab.lookup class gname
  fun add_item gname item (g, class) = (g, (F.NTab.update (gname, item) class))
  fun del_item gname (g, class) = (g, F.NTab.delete gname class)



  
  fun get_keys (_, class) = F.NTab.keys class

  val get_name = fst
  fun rename gname (_, class) = (gname, class) 
(*
  fun eq ctxt ((_,a), (_,b)) = if F.NTab.forall (fn (name, xb) => 
                                          (case (F.NTab.lookup a name) of SOME xa => GoalTypData.match_data_ll (xa,xb)
                                             | _ => false))
                                       b then (F.NTab.forall (fn (name, xa) => 
                                                             (case (F.NTab.lookup b name) 
                                                              of SOME xb => GoalTypData.match_data_ll (xa,xb)
                                                              | _ => false))
                                                          a)
                                              else false
*)
  structure Sharing =
  struct
    type T = T
    structure GoalTypData = GoalTypData
  end                                           
  
end; (* struct *)

