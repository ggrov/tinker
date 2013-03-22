(* to hold class features  *)

signature LINK = 
sig
  
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
structure Link = 
struct 

  type link = L.name * C.name * C.name
  
  structure LKey =
  struct
    type key = link;
    fun ord ((l1,sc1,dc1),(l2,sc2,dc2)) = L.name_ord (l1,l2);
  end;

  structure LTab = Table(LKey);

  type data = Class.data;

  type T = data LTab.table;

  (* or is this bottom? *)
  val top = LTab.empty;

end; (* struct *)


