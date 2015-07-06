signature LINK_SHARING =
sig
  type T
  (*type lkey*)
  structure GoalTypData : GOALTYP_DATA_SHARING
end

signature LINK = 
sig

  type lkey = L.name * (C.name * C.name)
  structure LKey : KEY

  type T
  
  structure GoalTypData : GOALTYP_DATA
  structure Prover : PROVER
  sharing GoalTypData.Sharing.Prover = Prover.Sharing

  val top : T
  val get_item : lkey -> T -> (GoalTypData.data list list) option
  val set_item: lkey -> (GoalTypData.data list list) -> T -> T
  val del_item : lkey -> T -> T
  val get_keys : T -> lkey list

  val get_name: T -> L.name
  val rename : L.name -> T -> T  
(*  
  val eq : (T * T) -> bool
*)
  structure Sharing : LINK_SHARING
    sharing type Sharing.T = T
    (*sharing type Sharing.lkey = lkey*)
    sharing Sharing.GoalTypData = GoalTypData

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
functor LinkFun (structure GoalTypData : GOALTYP_DATA
                 structure Prover : PROVER
                 sharing GoalTypData.Sharing.Prover = Prover ) : LINK = 
struct 
  structure GoalTypData = GoalTypData;
  structure Prover = Prover;

  type lkey = F.name * (C.name * C.name)
  
  structure LKey =
  struct
    type key = lkey;
    fun ord ((f1,(c1, c3)),(f2, (c2, c4))) = 
       (case F.name_ord (f1,f2)of EQUAL => 
           (case C.name_ord (c1,c2)of EQUAL => C.name_ord (c3,c4)
            | x => x)
        | x => x);
  end;

  structure linkTbl =  Table(LKey);

  type T =  (L.name * (GoalTypData.data list list) linkTbl.table);

  val top = (L.mk "Top", linkTbl.empty)

  exception LINK_EXP of L.name * T

  fun get_item k (_, link) =  linkTbl.lookup link k
  fun set_item k item (g, link) = (g, (linkTbl.update (k, item) link))
  fun del_item k (g, link) = (g, linkTbl.delete k link)
  
  fun get_keys (_, link) = linkTbl.keys link

  val get_name = fst
  fun rename gname (_, link) = (gname, link) 
(* 
  fun eq ((_,a), (_,b)) = if linkTbl.forall (fn (k, xb) => 
                                          (case (linkTbl.lookup a k) of SOME xa =>  GoalTypData.match_data_ll (xa,xb)
                                             | _ => false))
                                       b then (linkTbl.forall (fn (k, xa) => 
                                                             (case (linkTbl.lookup b k) 
                                                              of SOME xb => GoalTypData.match_data_ll (xa,xb)
                                                              | _ => false))
                                                          a)
                                              else false
*)
  structure Sharing = 
  struct
    type T = T
    (*type lkey = lkey*)
    structure GoalTypData = GoalTypData.Sharing
  end
end; (* struct *)


