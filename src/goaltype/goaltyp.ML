(* to hold class features  *)

signature GOALTYP = 
sig
  
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
structure GoalTyp = 
struct 

  datatype T = GoalTyp of 
   { name : G.name,
     link : Link.T,
     facts : Class.T list, (* fixme: turn this into a set *)
     goal : Class.T }

  fun get_name (GoalTyp rep) = #name rep;
  
  fun ord(gt1,gt2) = G.name_ord(get_name gt1,get_name gt2);
  fun eq(gt1,gt2) = (ord(gt1,gt2) = EQUAL);

  val top = GoalTyp { name = G.mk "top", link = Link.top, facts = [], goal = Class.top};

end; (* struct *)


