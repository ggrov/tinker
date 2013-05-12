signature LINK = 
sig

  type lkey = L.name * (C.name * C.name) 
  type T
  
  structure class : CLASS
  val top : T
  val get_item : lkey -> T -> (class.GTData.data list list) option
  val set_item: lkey -> (class.GTData.data list list) -> T -> T
  val del_item : lkey -> T -> T
  val get_keys : T -> lkey list

  val get_name: T -> L.name
  val rename : L.name -> T -> T  
  
  val match_item : class.GTData.gPrf.context -> (class.GTData.data list list * class.GTData.data list list) -> bool
  val eq : class.GTData.gPrf.context -> (T * T) -> bool

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
functor LinkFun (Cls : CLASS) : LINK = 
struct 
  structure class  = Cls

  type lkey = L.name * (C.name * C.name)
  
  structure LKey =
  struct
    type key = lkey;
    fun ord ((l1,(c1, c3)),(l2, (c2, c4))) = 
       (case L.name_ord (l1,l2)of EQUAL => 
           (case C.name_ord (c1,c2)of EQUAL => C.name_ord (c3,c4)
            | x => x)
        | x => x);
  end;

  structure linkTbl =  Table(LKey);

  type T =  (L.name * (class.GTData.data list list) linkTbl.table);

  val top = (L.mk "Top", linkTbl.empty)

  exception LINK_EXP of L.name * T

  fun get_item k (_, link) =  linkTbl.lookup link k
  fun set_item k item (g, link) = (g, (linkTbl.update (k, item) link))
  fun del_item k (g, link) = (g, linkTbl.delete k link)
  
  fun get_keys (_, link) = linkTbl.keys link

  val get_name = fst
  fun rename gname (_, link) = (gname, link) 
  
  val match_item = class.match_item

  fun eq ctxt ((_,a), (_,b)) = if linkTbl.forall (fn (k, xb) => 
                                          (case (linkTbl.lookup a k) of SOME xa => match_item ctxt (xa,xb)
                                             | _ => false))
                                       b then (linkTbl.forall (fn (k, xa) => 
                                                             (case (linkTbl.lookup b k) of SOME xb => match_item ctxt (xa,xb)
                                                              | _ => false))
                                                          a)
                                              else false

end; (* struct *)


