signature GNODE = 
sig
  type T

  val get_parent : T -> T option 
  val get_goal : T -> StrName.name 
  val get_goaltyp : T -> G.name

 
  val update_parent : (T option -> T option) -> T -> T 
  val update_goal : (StrName.name -> StrName.name) -> T -> T
  val update_goaltyp : (G.name -> G.name) -> T -> T 

  val set_parent_none : T -> T
  val set_parent : T -> T -> T
  val set_parent' : T option -> T -> T
  val set_goal : StrName.name -> T -> T
  val set_goaltyp : G.name -> T -> T

  val pretty : T -> Pretty.T (* FIXME : implement this*)

  val mk_goal : G.name -> StrName.name -> T 
  val eq : T * T -> bool
  val ord : T * T -> order

end

structure GNode : GNODE = 
struct
(*  structure GoalTyp = GTyp *)
  datatype T = Goal of {goaltyp : G.name,
                        goal : StrName.name, (* the name of the goal node *) (* ??? name of pnode ? *)
                        parent : T option}

  fun get_goal (Goal rep) = #goal rep;
  fun get_goaltyp (Goal rep) = #goaltyp rep;
  fun get_parent (Goal rep) = #parent rep;

  fun update_goaltyp f (Goal rep) = Goal {goaltyp = f (#goaltyp rep), goal = #goal rep, parent = #parent rep};
  fun update_goal f (Goal rep) = Goal {goaltyp = #goaltyp rep, goal = f (#goal rep), parent = #parent rep};
  fun update_parent f (Goal rep) = Goal {goaltyp = #goaltyp rep, goal = #goal rep, parent = f (#parent rep)};

  val set_parent' = update_parent o K;
  val set_goal = update_goal o K;
  val set_goaltyp = update_goaltyp o K;

  fun set_parent name = set_parent' (SOME name);
  val set_parent_none = set_parent' NONE;
  
  fun eq (gnode1,gnode2) = (get_goal gnode1 = get_goal gnode2);
  fun ord (gnode1,gnode2) = String.compare(get_goal gnode1, get_goal gnode2);

  fun mk_goal goaltyp goal = Goal {goaltyp = goaltyp, goal = goal, parent = NONE};

   fun pretty gnode = Pretty.str (get_goal gnode);

end (* struct GNode *)

