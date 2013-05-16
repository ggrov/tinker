signature EVAL_DATA =
sig 
  (* add sharing constraints *)
  structure Atomic : ATOMIC
  structure PSGraph : PS_GRAPH
  sharing type Atomic.tactic = PSGraph.tactic

  type T
  
  (* get methods *) 
  val get_pplan : T -> Atomic.pplan
  val get_psgraph : T -> PSGraph.T
  val get_goals : T -> Atomic.pnode StrName.NTab.T
  val get_active : T -> V.name list

  (* more get methods *)
  val lookup_goal : T -> string -> Atomic.pnode option
  val get_goal : T -> string -> Atomic.pnode
  val lookup_tactic : T -> string -> Atomic.tactic option
  val get_tactic : T -> string -> Atomic.tactic

  (* set methods *)
  val set_pplan : Atomic.pplan -> T -> T
  val set_psgraph : PSGraph.T -> T -> T
  val set_goals : Atomic.pnode StrName.NTab.T -> T -> T
  val set_active : V.name list -> T -> T

  (* update methods *)
  val update_pplan : (Atomic.pplan -> Atomic.pplan) -> T -> T
  val update_psgraph : (PSGraph.T -> PSGraph.T) -> T -> T
  val update_goals : (Atomic.pnode StrName.NTab.T -> Atomic.pnode StrName.NTab.T)  -> T -> T
  val update_active : (V.name list -> V.name list) -> T -> T

end (* signature *)


functor EData(structure Atomic : ATOMIC
              structure PSGraph : PS_GRAPH
              sharing type Atomic.tactic = PSGraph.tactic) : EVAL_DATA =
struct

  structure Atomic = Atomic;
  structure PSGraph = PSGraph;

  (* do we need a stack of graphs for nested evaluation? *)
  datatype T = EData of { 
      pplan : Atomic.pplan,
      psgraph : PSGraph.T, (* psgraph *)
      goals : Atomic.pnode StrName.NTab.T,
      active : V.name list
  }

  fun get_pplan (EData rep) = #pplan rep;
  fun get_psgraph (EData rep) = #psgraph rep;
  fun get_goals (EData rep) = #goals rep;
  fun get_active (EData rep) = #active rep;

  fun update_pplan f (EData rep) =
    EData {pplan = f (#pplan rep), psgraph = #psgraph rep, goals = #goals rep, active = #active rep};
  fun update_psgraph f (EData rep) =
    EData {pplan = #pplan rep, psgraph = f (#psgraph rep), goals = #goals rep,active = #active rep};
  fun update_goals f (EData rep) =
    EData {pplan = #pplan rep, psgraph = #psgraph rep, goals = f (#goals rep),active = #active rep};
  fun update_active f (EData rep) =
    EData {pplan = #pplan rep, psgraph = #psgraph rep, goals = #goals rep, active = f (#active rep)};

  val set_pplan = update_pplan o K;
  val set_psgraph = update_psgraph o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;

  fun init_of prf graph gs active  =
    EData {pplan = prf, psgraph = graph, goals = gs, active = active};
           
  fun ins_tab pnode = StrName.NTab.ins (Atomic.get_pnode_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

  val get_tactics = get_psgraph #> PSGraph.get_atomics;
  val lookup_tactic = get_tactics #> StrName.NTab.lookup
  val get_tactic = get_tactics #> StrName.NTab.get

(*
  fun pretty_goals edata nameset =
    edata
    |> get_graph
    |> GraphEnv.get_goalnodes_of_graph 
    |> V.NSet.list_of
    |> map (GraphEnv.v_to_gnode (get_graph edata))
    |> filter ((StrName.NSet.contains nameset) o GNode.get_goal)
    |> map GNode.pretty
    |> Pretty.chunks;

  fun pretty edata = 
     [ Pretty.block [Pretty.str "Goals: ", pretty_goals edata (StrName.NTab.get_nameset (get_goals edata))],
       Pretty.block [Pretty.str "Proof plan: ", PPlan.pretty (get_pplan edata)] ]
     |> Pretty.chunks

  val print = Pretty.writeln o pretty;
*)
end; (* functor *)


