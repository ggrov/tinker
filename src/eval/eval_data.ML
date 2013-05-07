structure EData =
struct

  (* also ruleset *)
  datatype T = EData of { 
      pplan : PPlan.T,
      graph : PSGraph.T, (* psgraph *)
      goals : PNode.T StrName.NTab.T,
      active : V.name list
  }

  fun get_pplan (EData rep) = #pplan rep;
  fun get_graph (EData rep) = #graph rep;
  fun get_goals (EData rep) = #goals rep;
  fun get_active (EData rep) = #active rep;

  fun update_pplan f (EData rep) =
    EData {pplan = f (#pplan rep), graph = #graph rep, goals = #goals rep, active = #active rep};
  fun update_graph f (EData rep) =
    EData {pplan = #pplan rep, graph = f (#graph rep), goals = #goals rep,active = #active rep};
  fun update_goals f (EData rep) =
    EData {pplan = #pplan rep, graph = #graph rep, goals = f (#goals rep),active = #active rep};
  fun update_active f (EData rep) =
    EData {pplan = #pplan rep, graph = #graph rep, goals = #goals rep, active = f (#active rep)};

  val set_pplan = update_pplan o K;
  val set_graph = update_graph o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;

  fun init_of prf graph gs active  =
    EData {pplan = prf, graph = graph, goals = gs, active = active};
           
  fun ins_tab pnode = StrName.NTab.ins (PNode.get_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

  val get_tactics = get_graph #> PSGraph.get_atomics;

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
end; (* structure *)


