signature GNODE = 
sig
  type T

  val get_parent : T -> T option 
  val get_goal : T -> StrName.name 
  val get_facts : T -> StrName.NSet.T C.NTab.T

  val get_fact_names : C.NTab.name -> T -> StrName.NSet.T  
  val lookup_fact_names : C.NTab.name -> T -> StrName.NSet.T option
  val delete_fact : C.NTab.name -> T -> T 
  val add_facts : C.NTab.name * StrName.NSet.T -> T -> T
 
  val update_parent : (T option -> T option) -> T -> T 
  val update_goal : (StrName.name -> StrName.name) -> T -> T
  val update_facts : (StrName.NSet.T C.NTab.T -> StrName.NSet.T C.NTab.T) -> T -> T 

  val set_parent_none : T -> T
  val set_parent : T -> T -> T
  val set_parent' : T option -> T -> T
  val set_goal : StrName.name -> T -> T
  val set_facts : StrName.NSet.T C.NTab.T -> T -> T 
  val delete_facts : C.NSet.T -> T -> T

  val pretty : T -> Pretty.T (* FIXME : implement this*)

  val mk_goal_no_facts : StrName.name -> T
  val mk_goal : StrName.NSet.T C.NTab.T -> StrName.name -> T 
  val eq : T * T -> bool
  val ord : T * T -> order

end

structure GNode : GNODE = 
struct
(*  structure GoalTyp = GTyp *)
  datatype T = Goal of {facts : StrName.NSet.T C.NTab.T, (* map from class to a set of assumption *)
                        goal : StrName.name, (* the name of the goal node *) (* ??? name of pnode ? *)
                        (* ??? link: ((C.Name * C.Name) * (StrName * StrName) list) C.NTab.T   tbale from (lkey to set of pair of StrName) Table(lKey)*)
                        parent : T option}

  fun get_goal (Goal rep) = #goal rep;
  fun get_facts (Goal rep) = #facts rep;
  fun get_parent (Goal rep) = #parent rep;

  fun update_facts f (Goal rep) = Goal {facts = f (#facts rep), goal = #goal rep, parent = #parent rep};
  fun update_goal f (Goal rep) = Goal {facts = #facts rep, goal = f (#goal rep), parent = #parent rep};
  fun update_parent f (Goal rep) = Goal {facts = #facts rep, goal = #goal rep, parent = f (#parent rep)};

  val set_parent' = update_parent o K;
  val set_goal = update_goal o K;
  val set_facts = update_facts o K;

  fun set_parent name = set_parent' (SOME name);
  val set_parent_none = set_parent' NONE;

  fun lookup_fact_names fact gnode = C.NTab.lookup (get_facts gnode) fact;
  fun get_fact_names fact gnode = C.NTab.get (get_facts gnode) fact;

  fun delete_fact fact = 
    update_facts (C.NTab.delete fact);

  fun delete_facts facts = 
    update_facts (C.NSet.fold C.NTab.delete facts);

  fun add_facts (fact,gs) gnode = 
     if C.NTab.contains (get_facts gnode) fact
        then update_facts (C.NTab.map_entry (StrName.NSet.union_merge gs) fact) gnode
        else update_facts (C.NTab.ins (fact,gs)) gnode;

 
  
  fun eq (gnode1,gnode2) = (get_goal gnode1 = get_goal gnode2);
  fun ord (gnode1,gnode2) = String.compare(get_goal gnode1, get_goal gnode2);
(*
  val default_gnode = 
    Goal {facts = C.NTab.empty, goal = PNode.default_name, prev = NONE}; 
*)

  fun mk_goal facts goal = Goal {facts = facts, goal = goal, parent = NONE};
  val mk_goal_no_facts = mk_goal C.NTab.empty;

   fun pretty gnode = Pretty.str (get_goal gnode);

end (* struct GNode *)

