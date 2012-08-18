functor GNodeFun (Wire : BASIC_WIRE) =
struct

  structure Wire = Wire;

  structure WTab = BasicNameTabFun(structure NSet = Wire.NSet ;
                                      structure Namer = Wire);
  type gmap = Goaln.NSet.T WTab.T;

   (* goal can also just be in the facts set?? *)
  datatype goal = Goal of {facts : gmap,
                            gtyp : Wire.name, 
                            goal : Goaln.name,
                            prev : Goaln.name option}

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

  fun delete_fact fact = 
    update_facts (WTab.delete fact);

  fun delete_facts facts = 
    update_facts (Wire.NSet.fold (fn f => fn wt => WTab.delete f wt) facts);

  fun add_facts (fact,gs) gnode = 
     if WTab.contains (get_facts gnode) fact
        then update_facts (WTab.map_entry (Goaln.NSet.union_merge gs) fact) gnode
        else update_facts (WTab.ins (fact,gs)) gnode;

  val default_goal = 
    Goal {facts = WTab.empty, gtyp = Wire.default_wire, goal = Goaln.default_name, prev = NONE};

 (* application: just keep wire as it is: when looking up all wires are matched! *)
 fun get_matching_facts wire gnode =
   WTab.fold
    (fn (fw,gs) => fn res => 
       if Wire.wire_match wire fw then Goaln.NSet.union_merge gs res else res)
    (get_facts gnode)
    Goaln.NSet.empty;

  fun remove_matching_facts wire goal =
   Wire.NSet.fold
    (fn fw => fn res => 
       if Wire.wire_match wire fw then WTab.delete fw res else res)
    (WTab.get_nameset (get_facts goal))
    (get_facts goal);   

  fun mk_goal facts gtyp goal = Goal {facts = facts, gtyp = gtyp, goal = goal, prev = NONE};
  val mk_goal_no_facts = mk_goal WTab.empty;

  (* adds the facts of goal2 into goal1 *)
  (* implicit assumption that we work on same goal.. make it explicit? *)
  fun combine_facts' goal1 goal2 =
   WTab.fold
    (fn (w,gs) => fn res =>
         if WTab.contains res w
            then WTab.map_entry (Goaln.NSet.union_merge gs) w res
            else WTab.ins (w,gs) res)
    (get_facts goal2)
    (get_facts goal1);

  fun combine_facts goal1 goal2 =
    set_facts (combine_facts' goal1 goal2) goal1

  (* This is purely based upon the goalname so assumes that
     there will always be only one instance of a goal in a set *)
  structure SeqNamer =
  struct
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
  end; (* struct Namer *)

  structure Basic_GoalName = 
    BasicNameFun(struct structure Namer = SeqNamer val default_name = default_goal end);

  structure GoalSet = NameSetFun(Basic_GoalName);

  fun get_all_goals gnds = 
    GoalSet.fold
      (fn g => Goaln.NSet.ins_fresh (get_goal g))  (* should only be one! *)
      gnds
      Goaln.NSet.empty;

  (* assumption: only 1 goal instance in each set *)
  fun combine_gsets' gset1 gset2 = 
    GoalSet.fold
     (fn g1 => fn res =>
       let
         val g2s' = GoalSet.filter (fn g2 => Goaln.name_eq (get_goal g1,get_goal g2)) gset2
       in case GoalSet.tryget_singleton g2s' of
             NONE => res (* fail either no singleton or not there *)
           | (SOME g2) => GoalSet.ins_fresh (combine_facts g1 g2) res
       end)
     gset1
     GoalSet.empty;

  (* returns (gset1',gset2',combined) *)
  fun combine_gsets gset1 gset2 =
    let 
      val combined = combine_gsets' gset1 gset2
      val gset1' = gset1 
                |> GoalSet.filter 
                    (fn g1 => GoalSet.exists 
                               (fn comb => Goaln.name_eq (get_goal g1,get_goal comb)) 
                               combined)
      val gset2' = gset2 
                |> GoalSet.filter 
                    (fn g2 => GoalSet.exists 
                               (fn comb => Goaln.name_eq (get_goal g2,get_goal comb)) 
                               combined)
     in
       (gset1',gset2',combined)
     end;

   (* various updates of gnode (to be used in tactics) *)
   fun upd_goal_only new_goal gnode = 
    if Goaln.name_eq (get_goal gnode,new_goal)
     then gnode
     else gnode |> set_prev_value (get_goal gnode)
                |> set_goal new_goal;

   fun upd_hyps_only (to_delete,to_add) =
      delete_facts to_delete
      #> fold add_facts to_add;

   fun upd_gnode (new_goal,to_delete,to_add) =
     upd_goal_only new_goal
     #> upd_hyps_only (to_delete,to_add);

   fun upd_hyps_only_single (to_delete,to_add) =
      delete_fact to_delete
      #> add_facts to_add;

   fun upd_gnode_single (new_goal,to_delete,to_add) =
     upd_goal_only new_goal
     #> upd_hyps_only_single (to_delete,to_add);

end (* functor *)

structure GNode = GNodeFun(BWire);

structure GoalNode =
struct
  exception goaltype_exp of string
 (* we should maybe have more than string here? *)
  type T = GNode.Wire.name * GNode.GoalSet.T;

  fun get_wire (w,_) = w;
  fun get_gnodes (_,gnds) = gnds;

  val get_all_goals = GNode.get_all_goals o get_gnodes;

  structure GInfo =
  struct
   type name = T
   fun suc (wire,gs) = (GNode.Wire.suc wire,gs);
   fun pred (wire,gs) = case GNode.Wire.pred (wire) of
                           NONE => NONE
                         | (SOME v) => SOME (v,gs);
   fun ord ((w1,_),(w2,_)) = GNode.Wire.ord (w1,w2);
   fun eq  ((w1,_),(w2,_)) = GNode.Wire.eq (w1,w2);
   fun pretty (wire,_) = GNode.Wire.pretty wire;
  end;

 fun empty_goalnode w = (w,GNode.GoalSet.empty);
 val default_goalnode = empty_goalnode GNode.Wire.default_wire;
 fun is_empty (_,gs) = GNode.GoalSet.is_empty gs;

 fun merge (w1,ws1) (w2,ws2) = 
   if GNode.Wire.eq (w1,w2) 
    then (w1,GNode.GoalSet.union_merge ws1 ws2)
    else raise goaltype_exp "not the same wires";

  structure G = 
    BasicNameFun(struct structure Namer = GInfo val default_name = default_goalnode end);

  fun get_matching_gnodes wire gs =
    G.NSet.fold
       (fn (w,gs) => fn res => 
          if BWire.wire_match wire w
           then GNode.GoalSet.union_merge gs res
           else res)
       gs
       GNode.GoalSet.empty;

  (* structure WireGSet = NameSetFun(Basic_GoalName);*) 

end (* structure *)


