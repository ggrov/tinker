signature GNODE = 
sig
  structure GoalTyp : GOAL_TYP
  type T
end

(* goal type not needed anywhere *)
(* functor GNodeFun (GTyp: GOAL_TYP) : GNODE = *)
structure GNode =
struct

(*  structure GoalTyp = GTyp *)

  datatype T = Goal of {facts : StrName.NSet.T C.NTab.T, (* map from class to a set of assumption *)
                        goal : string, (* the name of the goal node *)
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

  fun lookup_facts fact gnode = C.NTab.get (get_facts gnode) fact;

  fun delete_fact fact = 
    update_facts (C.NTab.delete fact);

  fun delete_facts facts = 
    update_facts (C.NSet.fold C.NTab.delete facts);

  fun add_facts (fact,gs) gnode = 
     if C.NTab.contains (get_facts gnode) fact
        then update_facts (C.NTab.map_entry (StrName.NSet.union_merge gs) fact) gnode
        else update_facts (C.NTab.ins (fact,gs)) gnode;

  fun pretty gnode = Pretty.str (get_goal gnode);
  
  fun eq (gnode1,gnode2) = (get_goal gnode1 = get_goal gnode2);

(*
  val default_gnode = 
    Goal {facts = C.NTab.empty, goal = PNode.default_name, prev = NONE}; 
*)

  fun mk_goal facts goal = Goal {facts = facts, goal = goal, parent = NONE};
  val mk_goal_no_facts = mk_goal C.NTab.empty;

end (* struct GNode *)

