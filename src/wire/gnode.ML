(* a single goalnode: contains no information about relational properties *)
structure GNode = 
(* functor GNodeFun (Wire : BASIC_WIRE) = *)
struct
   structure Wire = BWire;

   (* goal can also just be in the facts set?? *)
  datatype T = Goal of {facts : GFact.NSet.T BW.NTab.T, (* map from BWire to a set of assumption *)
                        goal : PNode.gname, (* or actually the gnode *)
                        prev : T option}

  fun get_goal (Goal rep) = #goal rep;
  fun get_facts (Goal rep) = #facts rep;
  fun get_prev (Goal rep) = #prev rep;

 fun update_facts f (Goal rep) = Goal {facts = f (#facts rep), goal = #goal rep, prev = #prev rep};
  fun update_goal f (Goal rep) = Goal {facts = #facts rep, goal = f (#goal rep), prev = #prev rep};
  fun update_prev f (Goal rep) = Goal {facts = #facts rep, goal = #goal rep, prev = f (#prev rep)};

  val set_prev = update_prev o K;
  val set_goal = update_goal o K;
  val set_facts = update_facts o K;

  fun set_prev_value name = set_prev (SOME name);

  fun lookup_facts fact gnode = BW.NTab.get (get_facts gnode) fact;

  fun lookup_facts_by_name fact_name gnode = 
   let 
     val fact = (get_facts gnode)
              |> BW.NTab.get_nameset 
              |> BW.NSet.filter (fn f => SStrName.name_eq((Wire.get_name f),fact_name))
              |> BW.NSet.tryget_singleton
   in case fact of 
          NONE => NONE
       | (SOME f) => SOME (lookup_facts f gnode)
  end;

  fun delete_fact fact = 
    update_facts (BW.NTab.delete fact);

  fun delete_facts facts = 
    update_facts (BW.NSet.fold (fn f => fn wt => BW.NTab.delete f wt) facts);

  fun add_facts (fact,gs) gnode = 
     if BW.NTab.contains (get_facts gnode) fact
        then update_facts (BW.NTab.map_entry (GFact.NSet.union_merge gs) fact) gnode
        else update_facts (BW.NTab.ins (fact,gs)) gnode;

  val default_gnode = 
    Goal {facts = BW.NTab.empty, goal = GFact.default_name, prev = NONE}; 

  fun mk_goal facts goal = Goal {facts = facts, goal = goal, prev = NONE};
  val mk_goal_no_facts = mk_goal BW.NTab.empty;

  (* adds the facts of goal2 into goal1 *)
  (* implicit assumption that we work on same goal.. make it explicit? *)
  fun combine_facts' goal1 goal2 =
   BW.NTab.fold
    (fn (w,gs) => fn res =>
         if BW.NTab.contains res w
            then BW.NTab.map_entry (GFact.NSet.union_merge gs) w res
            else BW.NTab.ins (w,gs) res)
    (get_facts goal2)
    (get_facts goal1);

  fun combine_facts goal1 goal2 =
    set_facts (combine_facts' goal1 goal2) goal1

  (* fixme add remaining *)
   fun pretty goal = Pretty.block
     [Pretty.str "Goal goal: ",
      Pretty.str (get_goal goal)]

  (* Note: ignores wire since I think this should be removed *)
  fun ord (g1,g2) = 
    prod_ord 
       StrName.name_ord 
       BW.NSet.ord 
       ((get_goal g1,(BW.NTab.get_nameset o get_facts) g1),
        (get_goal g2,(BW.NTab.get_nameset o get_facts) g2));

  fun eq (g1,g2) = (ord(g1,g2) = EQUAL);

end (* struct GNode *)

