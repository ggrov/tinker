signature GOAL_TYP_SHARING = 
sig
  type T
  structure Link : LINK_SHARING
  structure Class : CLASS_SHARING
end

signature GOAL_TYP = 
sig
  type T
  structure Link : LINK
  structure Class : CLASS
  sharing Class.Sharing.GoalTypData = Link.Sharing.GoalTypData
   
  val top : T
  val get_name : T -> G.name
  val get_link : T -> Link.T
  val get_facts: T -> Class.T list
  val get_gclass : T -> Class.T

  val set_name : G.name -> T -> T
  val set_link : Link.T -> T -> T
  val set_facts : Class.T list -> T -> T
  val set_gclass: Class.T -> T -> T

  val ord : (T * T) -> order
  val eq : (T * T) -> bool

  structure Sharing : GOAL_TYP_SHARING
    sharing type Sharing.T = T
    sharing Sharing.Link = Link.Sharing
    sharing Sharing.Class = Class.Sharing

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
functor GoalTypFun (structure Link : LINK
                    structure Class : CLASS
                    sharing Class.Sharing.GoalTypData = Link.Sharing.GoalTypData) : GOAL_TYP = 
struct 
  structure Link = Link;
  structure Class = Class;

  datatype T = GoalTyp of 
   { name : G.name,
     link : Link.T,
     facts : Class.T list,
     goal : Class.T} 

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

  val top = GoalTyp {name = G.mk "top", link = Link.top, facts = [Class.top], goal = Class.top};

  structure Sharing = 
  struct
    type T = T
    structure Link = Link.Sharing
    structure Class = Class.Sharing
  end
end; (* struct *)

