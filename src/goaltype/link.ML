
signature LINK = 
sig
  type link
  type T 

  val top : T
  val get_data : T -> link -> GTData.data option
  val set_data: (link * GTData.data) -> T -> T
  val del_data : link -> T -> T
  val rename_data : link -> link -> T -> T option

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
structure DB_Link = 
struct 

  type link = (GT_Name.name *  GT_Name.name *  GT_Name.name) (* link name , class name , class name *)
  
  structure LKey =
  struct
    type key = link;
    fun ord ((l1,_, _),(l2, _, _)) = GT_Name.name_ord (l1,l2);
  end;

  structure linkTbl =  Table(LKey);

  type T = GTData.data linkTbl.table;
  val top = linkTbl.empty
  val get_data = linkTbl.lookup
  val set_data = linkTbl.update
  val del_data = linkTbl.delete
  fun rename_data oldN newN l = if (linkTbl.defined l newN) then NONE 
                                else case get_data l oldN of SOME x => (del_data oldN l |> set_data (newN, x) |> SOME)
                                                                | _ => NONE 


end; (* struct *)

structure Link : LINK = DB_Link

