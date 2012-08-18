(* a single goalnode: contains no information about relational properties *)
structure GNode = 
(* functor GNodeFun (Wire : BASIC_WIRE) = *)
struct
   structure Wire = BWire;

   (* goal can also just be in the facts set?? *)
  datatype goal = Goal of {facts : gmap,
                            gtyp : Wire.name, 
                            goal : PNode.gname, (* or actually the gnode *)
                            prev : PNode.gname option}

  fun get_goal (Goal rep) = #goal rep;
  fun get_facts (Goal rep) = #facts rep;
  fun get_gtyp (Goal rep) = #gtyp rep;
  fun get_prev (Goal rep) = #prev rep;

  fun update_gtyp f (Goal rep) = Goal {facts = #facts rep, gtyp = f (#gtyp rep), goal = #goal rep, prev = #prev rep};
  fun update_facts f (Goal rep) = Goal {facts = f (#facts rep), gtyp = #gtyp rep, goal = #goal rep, prev = #prev rep};
  fun update_goal f (Goal rep) = Goal {facts = #facts rep, gtyp = #gtyp rep, goal = f (#goal rep), prev = #prev rep};
  fun update_prev f (Goal rep) = Goal {facts = #facts rep, gtyp = #gtyp rep, goal = #goal rep, prev = f (#prev rep)};

  val set_prev = update_prev o K;
  val set_goal = update_goal o K;
  val set_gtyp = update_gtyp o K;
  val set_facts = update_facts o K;

  fun set_prev_value name = set_prev (SOME name);

  fun lookup_facts fact gnode = WTab.get (get_facts gnode) fact;

  fun lookup_facts_by_name fact_name gnode = 
   let 
     val fact = (get_facts gnode)
              |> WTab.get_nameset 
              |> W.NSet.filter (fn f => SStrName.name_eq((Wire.get_name f),fact_name))
              |> W.NSet.tryget_singleton
   in case fact of 
          NONE => NONE
       | (SOME f) => SOME (lookup_facts f gnode)
  end;

  fun delete_fact fact = 
    update_facts (WTab.delete fact);

  fun delete_facts facts = 
    update_facts (W.NSet.fold (fn f => fn wt => WTab.delete f wt) facts);

  fun add_facts (fact,gs) gnode = 
     if WTab.contains (get_facts gnode) fact
        then update_facts (WTab.map_entry (GFact.NSet.union_merge gs) fact) gnode
        else update_facts (WTab.ins (fact,gs)) gnode;

  val default_gnode = 
    Goal {facts = WTab.empty, gtyp = Wire.default_wire, goal = GFact.default_name, prev = NONE}; 

  fun mk_goal facts gtyp goal = Goal {facts = facts, gtyp = gtyp, goal = goal, prev = NONE};
  val mk_goal_no_facts = mk_goal WTab.empty;

  (* adds the facts of goal2 into goal1 *)
  (* implicit assumption that we work on same goal.. make it explicit? *)
  fun combine_facts' goal1 goal2 =
   WTab.fold
    (fn (w,gs) => fn res =>
         if WTab.contains res w
            then WTab.map_entry (GFact.NSet.union_merge gs) w res
            else WTab.ins (w,gs) res)
    (get_facts goal2)
    (get_facts goal1);

  fun combine_facts goal1 goal2 =
    set_facts (combine_facts' goal1 goal2) goal1

   type name = goal
   fun suc (Goal rep) = update_goal StrNamer.suc (Goal rep);
   fun pred goal = case StrNamer.pred (get_goal goal) of
                           NONE => NONE
                         | SOME v => SOME (set_goal v goal);
   fun ord (n1,n2) = StrNamer.ord (get_goal n1, get_goal n2);
   fun eq (n1,n2) = StrNamer.eq (get_goal n1, get_goal n2);
  
  (* fixme add remaining *)
   fun pretty goal = Pretty.block
     [Pretty.str "Goal goal: ",
      Pretty.str (get_goal goal)]

end (* struct GNode *)

structure GN = NameFun(structure Namer = GNode val default_name = GNode.default_gnode);

structure GNodeSet =
struct

  fun get_all_goals gnds = 
    GN.NSet.fold
      (fn g => GFact.NSet.ins_fresh (GNode.get_goal g))  (* should only be one! *)
      gnds
      GFact.NSet.empty;

  (* assumption: only 1 goal instance in each set *)
  fun combine_gsets' gset1 gset2 = 
    GN.NSet.fold
     (fn g1 => fn res =>
       let
         val g2s' = GN.NSet.filter (fn g2 => GFact.name_eq (GNode.get_goal g1,GNode.get_goal g2)) gset2
       in case GN.NSet.tryget_singleton g2s' of
             NONE => res (* fail either no singleton or not there *)
           | (SOME g2) => GN.NSet.ins_fresh (GNode.combine_facts g1 g2) res
       end)
     gset1
     GN.NSet.empty;

  (* returns (gset1',gset2',combined) *)
  fun combine_gsets gset1 gset2 =
    let 
      val combined = combine_gsets' gset1 gset2
      val gset1' = gset1 
                |> GN.NSet.filter 
                    (fn g1 => GN.NSet.exists 
                               (fn comb => GFact.name_eq (GNode.get_goal g1,GNode.get_goal comb)) 
                               combined)
      val gset2' = gset2 
                |> GN.NSet.filter 
                    (fn g2 => GN.NSet.exists 
                               (fn comb => GFact.name_eq (GNode.get_goal g2,GNode.get_goal comb)) 
                               combined)
     in
       (gset1',gset2',combined)
     end;

   (* various updates of gnode (to be used in tactics) *)
   fun upd_goal_only new_goal gnode = 
    if GFact.name_eq (GNode.get_goal gnode,new_goal)
     then gnode
     else gnode |> GNode.set_prev_value (GNode.get_goal gnode)
                |> GNode.set_goal new_goal;

   fun upd_hyps_only (to_delete,to_add) =
      GNode.delete_facts to_delete
      #> fold GNode.add_facts to_add;

   fun upd_gnode (new_goal,to_delete,to_add) =
     upd_goal_only new_goal
     #> upd_hyps_only (to_delete,to_add);

   fun upd_hyps_only_single (to_delete,to_add) =
      GNode.delete_fact to_delete
      #> GNode.add_facts to_add;

   fun upd_gnode_single (new_goal,to_delete,to_add) =
     upd_goal_only new_goal
     #> upd_hyps_only_single (to_delete,to_add);

end (* struct *)


