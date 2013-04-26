(* to hold class features  *)

signature GOALTYP = 
sig
  type T
  val top : T
  val get_name : T -> GT_Name.name
  val get_link : T -> Link.T
  val get_facts_classes : T -> Class.classTab
  val get_goal_class: T -> (GT_Name.name * Class.T)

  val set_name : GT_Name.name -> T -> T
  val set_link : Link.T -> T -> T
  val set_facts_classes : Class.classTab -> T -> T
  val set_goal_class: (GT_Name.name * Class.T) -> T -> T

  val ord : (T * T) -> order
  val eq : (T * T) -> bool

end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

  (* to do: generalise, by creating a term structure and a functor over this *)
structure DB_GoalTyp = 
struct 
  datatype T = GoalTyp of 
   { name : GT_Name.name,
     link : Link.T,
     facts : Class.classTab,
     goal : (GT_Name.name * Class.T) } (* Notice that the name here should not be used in classTba*)

  fun get_name (GoalTyp rep) = #name rep;
  fun get_link (GoalTyp rep) = #link rep;
  fun get_facts_classes (GoalTyp rep) = #facts rep;
  fun get_goal_class (GoalTyp rep) = #goal rep;

  fun set_name n (GoalTyp rep) = GoalTyp {name = n, link = (#link rep), facts = (#facts rep), goal = (#goal rep)}
  fun set_link l (GoalTyp rep) = GoalTyp {name = (#name rep), link = l, facts = (#facts rep), goal = (#goal rep)}
  fun set_facts_classes fc (GoalTyp rep) = GoalTyp {name = (#name rep), link = (#link rep), facts = fc, goal = (#goal rep)}
  fun set_goal_class gc (GoalTyp rep) = GoalTyp {name = (#name rep), link = (#link rep), facts = (#facts rep), goal = gc}


  fun ord(gt1,gt2) = GT_Name.name_ord(get_name gt1,get_name gt2);
  fun eq(gt1,gt2) = (ord(gt1,gt2) = EQUAL);

  val top = GoalTyp { name = GT_Name.mk "top", link = Link.top, facts = Class.empty_classtab, goal = (GT_Name.mk "default" , Class.top)};

end; (* struct *)

structure GoalTyp : GOALTYP = DB_GoalTyp;
