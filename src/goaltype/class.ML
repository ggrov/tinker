(* to hold class features  *)

signature CLASS = 
sig

  type T

  structure GTData : GT_DATA
  val top : T
  
  val get_item : F.name -> T -> (GTData.data list list) option
  val set_item: F.name -> (GTData.data list list) -> T -> T
  val del_item : F.name -> T -> T
  val get_keys : T -> F.name list

  val get_name: T -> C.name
  val rename : C.name -> T -> T  
  

  val match_item : GTData.gPrf.context -> (GTData.data list list * GTData.data list list) -> bool
  val eq : GTData.gPrf.context -> (T * T) -> bool
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* TODO: generalise, by creating a term structure and a functor over this *)
functor ClassFun (GTD : GT_DATA) : CLASS = 
struct

  structure GTData = GTD

  type T = (C.name * (GTData.data list list) F.NTab.T);
  val top = (C.mk "Top",  F.NTab.empty)


  exception CLASS_EXP of F.name * T
  fun get_item gname (_, class) =  F.NTab.lookup class gname
  fun set_item gname item (g, class) = (g, (F.NTab.update (gname, item) class))
  fun del_item gname (g, class) = (g, F.NTab.delete gname class)
  
  fun get_keys (_, class) = F.NTab.keys class

  val get_name = fst
  fun rename gname (_, class) = (gname, class) 

  fun match_item ctxt ((a : GTData.data list list),b) =
    let 
      fun zip [] [] = []
        | zip (x :: xs) (y :: ys) = (x,y) :: (zip xs ys);
      fun match_flist ctxt ((l1 : GTData.data list),l2) = 
        (if (List.length l1 = List.length l2)
        then
           not (List.exists (fn (x,y) => if GTData.match_data ctxt (x,y) then false else true) (zip l1 l2))
        else false);
      fun member e s = List.filter (fn x => match_flist ctxt (e,x)) s |> List.length |> (fn x => (x > 0))
      fun insert e s = (if member e s then s else e :: s)
      fun remove e (m :: s) = (if match_flist ctxt (e,m) then remove e s else [m] @ (remove e s))
        | remove _ [] = []
      fun union (a, s) = fold insert s a
      fun inter (a, (m::b)) = if member m a then [m] @ (inter (a, b)) else inter (a, b)
        | inter (_, []) = []
      fun size (m :: a) = (1 : int) + size(remove m a) 
        | size [] = 0
    in
      size (union (a,b)) = size (inter (a,b))
    end

  fun eq ctxt ((_,a), (_,b)) = if F.NTab.forall (fn (name, xb) => 
                                          (case (F.NTab.lookup a name) of SOME xa => match_item ctxt (xa,xb)
                                             | _ => false))
                                       b then (F.NTab.forall (fn (name, xa) => 
                                                             (case (F.NTab.lookup b name) of SOME xb => match_item ctxt (xa,xb)
                                                              | _ => false))
                                                          a)
                                              else false
end; (* struct *)

