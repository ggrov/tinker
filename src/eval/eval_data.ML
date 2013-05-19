signature EVAL_DATA =
sig 
  (* add sharing constraints *)
  structure Atomic : ATOMIC
  structure PSGraph : PS_GRAPH
  sharing type Atomic.tactic = PSGraph.tactic

  type T
  type active
  
  (* get methods *) 
  val get_pplan : T -> Atomic.pplan
  val get_goals : T -> Atomic.pnode StrName.NTab.T
  val get_active : T -> active

  val get_active_psgraph : T -> PSGraph.T
  val get_active_vertices : T -> V.name list
  val get_active_parent : T -> active option

  (* more get methods *)
  val lookup_goal : T -> string -> Atomic.pnode option
  val get_goal : T -> string -> Atomic.pnode
  val lookup_tactic : T -> string -> Atomic.tactic option
  val get_tactic : T -> string -> Atomic.tactic

  (* set methods *)
  val set_pplan : Atomic.pplan -> T -> T
  val set_goals : Atomic.pnode StrName.NTab.T -> T -> T
  val set_active : active -> T -> T

  val set_active_psgraph : PSGraph.T -> T -> T
  val set_active_vertices : V.name list -> T -> T
  val set_option_active_parent :  active option -> T -> T
  val set_active_parent : active -> T -> T

  (* update methods *)
  val update_pplan : (Atomic.pplan -> Atomic.pplan) -> T -> T
  val update_goals : (Atomic.pnode StrName.NTab.T -> Atomic.pnode StrName.NTab.T)  -> T -> T
  val update_active : (active -> active) -> T -> T

  val update_active_psgraph : (PSGraph.T -> PSGraph.T) -> T -> T
  val update_active_vertices : (V.name list -> V.name list) -> T -> T
  val update_active_parent : (active option -> active option) -> T -> T


  val add_goals : Atomic.pnode list -> T -> T

  (* push and pop methods for parent? *)
  val pop_active : T -> T (* identify if it fails *)
  val push_active :  PSGraph.T -> V.name list -> T -> T

end (* signature *)


functor EData(structure Atomic : ATOMIC
              structure PSGraph : PS_GRAPH
              sharing type Atomic.tactic = PSGraph.tactic) : EVAL_DATA =
struct

  structure Atomic = Atomic;
  structure PSGraph = PSGraph;

  datatype active = Active of {
     psgraph : PSGraph.T, (* maybe change to graph? *)
     vertices : V.name list,
     parent : active option  (* FIXME: should also hold a graph for the match lhs *)
  }

  datatype branch = Branch of {
    b_active : active,
    b_pplan : Atomic.pplan,
    b_goals : Atomic.pnode StrName.NTab.T
 }
    

  (* do we need a stack of graphs for nested evaluation? *)
  datatype T = EData of { 
      (* psgraph : PSGraph.T, *)
      pplan : Atomic.pplan,
      goals : Atomic.pnode StrName.NTab.T,
      active : active
  }

  fun get_pplan (EData rep) = #pplan rep;
  fun get_goals (EData rep) = #goals rep;
  fun get_active (EData rep) = #active rep;

  fun update_pplan f (EData rep) =
    EData {pplan = f (#pplan rep), goals = #goals rep, active = #active rep};
  fun update_goals f (EData rep) =
    EData {pplan = #pplan rep, goals = f (#goals rep),active = #active rep};
  fun update_active f (EData rep) =
    EData {pplan = #pplan rep, goals = #goals rep, active = f (#active rep)};

  val set_pplan = update_pplan o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;

  fun get_active_psgraph' (Active rep) = #psgraph rep;
  fun get_active_vertices' (Active rep) = #vertices rep;
  fun get_active_parent' (Active rep) = #parent rep;

  val get_active_psgraph = get_active_psgraph' o get_active;
  val get_active_vertices = get_active_vertices' o get_active;
  val get_active_parent = get_active_parent' o get_active;

  fun update_active_psgraph' f (Active rep) =
    Active {psgraph = f (#psgraph rep), vertices = #vertices rep, parent = #parent rep};
  fun update_active_vertices' f (Active rep) =
    Active {psgraph = #psgraph rep, vertices = f (#vertices rep), parent = #parent rep};
  fun update_active_parent' f (Active rep) =
    Active {psgraph = #psgraph rep, vertices = #vertices rep, parent = f (#parent rep)};

  val update_active_psgraph =  update_active o update_active_psgraph';
  val update_active_vertices =  update_active o update_active_vertices';
  val update_active_parent =  update_active o update_active_parent';

  val set_active_psgraph = update_active_psgraph o K;
  val set_active_vertices = update_active_vertices o K;
  val set_option_active_parent = update_active_parent o K;
  val set_active_parent = set_option_active_parent o SOME;

  fun init_active_of graph vs =
     Active {psgraph = graph, vertices = vs, parent = NONE}

  fun init_of prf graph gs vs  =
    EData {pplan = prf, goals = gs, active = init_active_of graph vs};
           
  fun ins_tab pnode = StrName.NTab.ins (Atomic.get_pnode_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

  val get_tactics = get_active_psgraph #> PSGraph.get_atomics;
  val lookup_tactic = get_tactics #> StrName.NTab.lookup
  val get_tactic = get_tactics #> StrName.NTab.get


  fun pop_active edata = 
     case get_active_parent edata of 
        NONE => edata
       | SOME p => set_active p edata

  fun push_active graph vnms edata = 
    set_active     
      (Active {psgraph = graph, vertices = vnms, parent = SOME (get_active edata)})
      edata;
      


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


