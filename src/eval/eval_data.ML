signature EVAL_DATA =
sig 
  (* add sharing constraints *)
  structure Atomic : ATOMIC
  structure PSGraph : PS_GRAPH
  sharing type Atomic.tactic = PSGraph.tactic

  type branch
  type active
  type T

   (* initialisations *)
  val init : 
    PSGraph.T 
    -> Atomic.pplan 
    -> Atomic.pnode StrName.NTab.T 
    -> V.name list
    -> T

  (* get methods *)
  val get_psgraph : T -> PSGraph.T  
  val get_pplan : T -> Atomic.pplan
  val get_goals : T -> Atomic.pnode StrName.NTab.T
  val get_vertices : T -> V.name list
  val get_graph : T -> PSGraph.PSTheory.PS_Theory.Graph.T

  (* more get methods *)
  val lookup_goal : T -> string -> Atomic.pnode option
  val get_goal : T -> string -> Atomic.pnode
  val lookup_tactic : T -> string -> Atomic.tactic option
  val get_tactic : T -> string -> Atomic.tactic

  (* set methods *)
  val set_psgraph : PSGraph.T -> T -> T
  val set_pplan : Atomic.pplan -> T -> T
  val set_goals : Atomic.pnode StrName.NTab.T -> T -> T
  val set_vertices : V.name list -> T -> T
  val set_graph : PSGraph.PSTheory.PS_Theory.Graph.T -> T -> T

  (* update methods *)
  val update_psgraph : (PSGraph.T -> PSGraph.T) -> T -> T
  val update_pplan : (Atomic.pplan -> Atomic.pplan) -> T -> T
  val update_goals : (Atomic.pnode StrName.NTab.T -> Atomic.pnode StrName.NTab.T)  -> T -> T
  val update_graph : (PSGraph.PSTheory.PS_Theory.Graph.T -> PSGraph.PSTheory.PS_Theory.Graph.T) -> T -> T
  val update_vertices : (V.name list -> V.name list) -> T -> T

  val add_goals : Atomic.pnode list -> T -> T

  (* push and pop methods for parent? *)

  val parent_lhs : T -> PSGraph.PSTheory.PS_Theory.Graph.T option
  val pop_active : T -> T (* identify if it fails *)
  val push_active : PSGraph.PSTheory.PS_Theory.Graph.T -> PSGraph.PSTheory.PS_Theory.Graph.T -> V.name list -> T -> T

end (* signature *)



functor EDataFun(structure Atomic : ATOMIC
                 structure PSGraph : PS_GRAPH
                 sharing type Atomic.tactic = PSGraph.tactic) : EVAL_DATA  =
struct

  structure Atomic = Atomic;
  structure PSGraph = PSGraph;

  datatype active = Active of {
     graph : PSGraph.PSTheory.PS_Theory.Graph.T, 
     vertices : V.name list,
     parent : (active * PSGraph.PSTheory.PS_Theory.Graph.T) option  
  }
  datatype branch = Branch of {
    active : active,
    pplan : Atomic.pplan,
    goals : Atomic.pnode StrName.NTab.T
  }
  (* todo : should we keep the previous Edata  too?*)
  datatype T = EData of { 
      psgraph : PSGraph.T,
      current : branch,
      branches : branch list
  }

  fun get_agraph (Active rep) = #graph rep;
  fun get_avertices (Active rep) = #vertices rep;
  fun get_aparent (Active rep) = #parent rep;

  fun get_bactive (Branch rep) = #active rep;
  fun get_bpplan (Branch rep) = #pplan rep;
  fun get_bgoals (Branch rep) = #goals rep;

  fun get_psgraph (EData rep) = #psgraph rep;
  fun get_current (EData rep) = #current rep;
  fun get_branches (EData rep) = #branches rep;

  val get_pplan = get_bpplan o get_current;
  val get_goals = get_bgoals o get_current;
  val get_active = get_bactive o get_current;

  val get_graph = get_agraph o get_active;
  val get_parent = get_aparent o get_active;
  val get_vertices = get_avertices o get_active;

  fun update_agraph f (Active rep) =
    Active {graph = f (#graph rep), vertices = #vertices rep, parent = #parent rep};
  fun update_avertices f (Active rep) =
    Active {graph = (#graph rep), vertices = f (#vertices rep), parent = #parent rep};
  fun update_aparent f (Active rep) =
    Active {graph = (#graph rep), vertices = #vertices rep, parent = f (#parent rep)};

  val set_agraph = update_agraph o K;
  val set_avertices = update_avertices o K;
  val set_aparent = update_aparent o K;

  fun update_bactive f (Branch rep) =
    Branch {active = f (#active rep), pplan = #pplan rep, goals = #goals rep};
  fun update_bpplan f (Branch rep) =
    Branch {active = (#active rep), pplan = f (#pplan rep), goals = #goals rep};
  fun update_bgoals f (Branch rep) =
    Branch {active = (#active rep), pplan = #pplan rep, goals = f (#goals rep)};

  val set_bactive = update_bactive o K;
  val set_bpplan = update_bpplan o K;
  val set_bgoals = update_bgoals o K;

  fun update_psgraph f (EData rep) =
    EData {psgraph = f (#psgraph rep), current = #current rep, branches = #branches rep};
  fun update_current f (EData rep) =
    EData {psgraph = (#psgraph rep), current = f (#current rep), branches = #branches rep};
  fun update_branches f (EData rep) =
    EData {psgraph = #psgraph rep, current = #current rep, branches = f (#branches rep)};

  val set_psgraph = update_psgraph o K;
  val set_current = update_current o K;
  val set_branches = update_branches o K;

  val update_active = update_current o update_bactive; 
  val update_goals = update_current o update_bgoals;
  val update_pplan = update_current o update_bpplan;
  val update_vertices =  update_active o update_avertices;
  val update_parent =  update_active o update_aparent;
  val update_graph = update_active o update_agraph;

  val set_vertices = update_vertices o K;
  val set_graph = update_graph o K;
  val set_pplan = update_pplan o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;
  val set_option_parent = update_parent o K;
  val set_parent = set_option_parent o SOME;

  fun init_active graph vs =
     Active {graph = graph, vertices = vs, parent = NONE}

  fun init_branch prf graph goals vs  =
    Branch {active = init_active graph vs, pplan = prf, goals = goals};

  fun init psgraph prf goals vs  =
    EData {psgraph = psgraph, current = init_branch prf (PSGraph.get_graph psgraph) goals vs, branches = []};

  fun ins_tab pnode = StrName.NTab.ins (Atomic.get_pnode_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

  val get_tactics = get_psgraph #> PSGraph.get_atomics;
  val lookup_tactic = get_tactics #> StrName.NTab.lookup
  val get_tactic = get_tactics #> StrName.NTab.get

  (* push and pop of hierarchies *)

  fun parent_lhs edata =
     case get_parent edata of 
        NONE => NONE
       | SOME (_,lhs) => SOME lhs

  fun pop_active edata = 
     case get_parent edata of 
        NONE => edata
       | SOME (p,_) => set_active p edata

(* give active cannot be unified with active error *)

  fun push_active graph lhs (vnms:V.name list) edata = 
    edata |> set_parent (get_active edata,lhs)
          |> set_graph graph
          |> set_vertices vnms;
     
end; (* functor *)


