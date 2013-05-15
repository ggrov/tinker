(* to hold class features  *)

signature GOAL_TYP = 
sig

  type T
  structure Link : LINK
   
  val top : T
  val get_name : T -> G.name
  val get_link : T -> Link.T
  val get_facts: T -> Link.Class.T list
  val get_gclass : T -> Link.Class.T

  val set_name : G.name -> T -> T
  val set_link : Link.T -> T -> T
  val set_facts : Link.Class.T list -> T -> T
  val set_gclass: Link.Class.T -> T -> T

  val ord : (T * T) -> order
  val eq : (T * T) -> bool

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
functor GoalTypFun (Link : LINK) : GOAL_TYP = 
struct 
  structure Link = Link;

  datatype T = GoalTyp of 
   { name : G.name,
     link : Link.T,
     facts : Link.Class.T list,
     goal : Link.Class.T} 

  fun get_name (GoalTyp rep) = #name rep;
  fun get_link (GoalTyp rep) = #link rep;
  fun get_facts (GoalTyp rep) = #facts rep;
  fun get_gclass (GoalTyp rep) = #goal rep;

  fun set_name n (GoalTyp rep) = GoalTyp {name = n, link = (#link rep), facts = (#facts rep), goal = (#goal rep)}
  fun set_link l (GoalTyp rep) = GoalTyp {name = (#name rep), link = l, facts = (#facts rep), goal = (#goal rep)}
  fun set_facts fc (GoalTyp rep) = GoalTyp {name = (#name rep), link = (#link rep), facts = fc, goal = (#goal rep)}
  fun set_gclass gc (GoalTyp rep) = GoalTyp {name = (#name rep), link = (#link rep), facts = (#facts rep), goal = gc}


  fun ord(gt1,gt2) = G.name_ord (get_name gt1,get_name gt2);
  fun eq(gt1,gt2) = (ord(gt1,gt2) = EQUAL);

  val top = GoalTyp {name = G.mk "top", link = Link.top, facts = [Link.Class.top], goal = Link.Class.top};

end; (* struct *)

