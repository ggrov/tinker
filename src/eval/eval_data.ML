
functor EDataFun(PSGraph : PS_GRAPH) : EVAL_DATA  =
struct

  structure PSGraph = PSGraph;
  structure Prover = PSGraph.Theory.Data.GoalTyp.Prover;

  type gnode = PSGraph.Theory.Data.GoalTyp.gnode


  datatype active = Active of {
     graph : PSGraph.Theory.Graph.T, 
     gnodes : gnode list, (* should change to gnodes *)
     searchf : string,
     evalf : string, 
     parent : (active * PSGraph.Theory.Graph.T) option  
  }
  datatype branch = Branch of {
    active : active,
    pplan : Prover.pplan,
    goals : Prover.pnode StrName.NTab.T
  }
  (* todo : should we keep the previous Edata  too?*)
  datatype T = EData of { 
      psgraph : PSGraph.T,
      current : branch,
      branches : branch list
  }

  fun get_agraph (Active rep) = #graph rep;
  fun get_agnodes (Active rep) = #gnodes rep;
  fun get_aparent (Active rep) = #parent rep;
  fun get_asearchf (Active rep) = #searchf rep;
  fun get_aevalf (Active rep) = #evalf rep;

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
  val get_gnodes = get_agnodes o get_active;
  val get_searchf = get_asearchf o get_active;
  val get_evalf = get_aevalf o get_active;

  val get_bparent = get_aparent o get_bactive;
  val get_bgnodes = get_agnodes o get_bactive;
  val get_bgraph = get_agraph o get_bactive;
  val get_bsearchf = get_asearchf o get_bactive;
  val get_bevalf = get_aevalf o get_bactive;

  fun update_agraph f (Active rep) =
    Active {graph = f (#graph rep), gnodes = #gnodes rep, 
            searchf = #searchf rep, evalf = #evalf rep, parent = #parent rep};
  fun update_agnodes f (Active rep) =
    Active {graph = (#graph rep), gnodes = f (#gnodes rep),
            searchf = #searchf rep, evalf = #evalf rep, parent = #parent rep};
  fun update_aparent f (Active rep) =
    Active {graph = (#graph rep), gnodes = #gnodes rep, 
            searchf = #searchf rep, evalf = #evalf rep, parent = f (#parent rep)};
  fun update_asearchf f (Active rep) =
    Active {graph = #graph rep, gnodes = #gnodes rep, 
            searchf = f (#searchf rep), evalf = #evalf rep, parent = #parent rep};
  fun update_aevalf f (Active rep) =
    Active {graph = #graph rep, gnodes = #gnodes rep, 
            searchf = #searchf rep, evalf = f (#evalf rep), parent = #parent rep};

  val set_agraph = update_agraph o K;
  val set_agnodes = update_agnodes o K;
  val set_aparent = update_aparent o K;
  val set_asearchf = update_asearchf o K;
  val set_aevalf = update_aevalf o K;

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
  val update_gnodes =  update_active o update_agnodes;
  val update_searchf =  update_active o update_asearchf;
  val update_evalf =  update_active o update_aevalf;
  val update_parent =  update_active o update_aparent;
  val update_graph = update_active o update_agraph;

  val set_gnodes = update_gnodes o K;
  val set_searchf = update_searchf o K;
  val set_evalf = update_evalf o K;
  val set_graph = update_graph o K;
  val set_pplan = update_pplan o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;
  val set_option_parent = update_parent o K;
  val set_parent = set_option_parent o SOME;

  val update_bgraph =  update_bactive o update_agraph;
  val set_bgraph = update_bgraph o K;
  val update_bparent = update_bactive o update_aparent;
  val set_option_bparent = update_bparent o K;
  val set_bparent = set_option_bparent o SOME;
  val update_bgnodes =  update_bactive o update_agnodes;
  val set_bgnodes = update_bgnodes o K;
  val update_bsearchf =  update_bactive o update_asearchf;
  val set_bsearchf = update_bsearchf o K;
  val update_bevalf =  update_bactive o update_aevalf;
  val set_bevalf = update_bevalf o K;

  fun init_active graph vs =
     Active {graph = graph, gnodes = vs, searchf = "depth_first", evalf = "depth_first", parent = NONE}

  fun init_branch prf graph goals vs  =
    Branch {active = init_active graph vs, pplan = prf, goals = goals};

  fun init psgraph prf goals vs  =
    EData {psgraph = psgraph, current = init_branch prf (PSGraph.get_graph psgraph) goals vs, branches = []};

  fun ins_tab pnode = StrName.NTab.ins (Prover.get_pnode_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun add_bgoals pnods = update_bgoals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

  val get_tactics = get_psgraph #> PSGraph.get_atomic_tactics;
  val lookup_tactic = get_tactics #> StrName.NTab.lookup
  fun get_tactic data tac = StrName.NTab.get (get_tactics data) tac
  handle x => (DebugHandler.add_debug_msg (Pretty.str ("No such a tac : " ^ tac) );raise x )

  (* push and pop of hierarchies *)

  fun parent_lhs edata =
     case get_parent edata of 
        NONE => NONE
       | SOME (_,lhs) => SOME lhs

  fun pop_active edata = 
     case get_parent edata of 
        NONE => edata
       | SOME (p,_) => set_active p edata

  fun push_active graph lhs (vnms:gnode list) edata = 
    edata |> set_parent (get_active edata,lhs)
          |> set_graph graph
          |> set_gnodes vnms;
  
  (* for working with branches *)
  fun pop_bactive branch = 
     case get_bparent branch of 
        NONE => branch
       | SOME (p,_) => set_bactive p branch

  fun push_bactive graph lhs (vnms:gnode list) branch = 
    branch |> set_bparent (get_bactive branch,lhs)
           |> set_bgraph graph
           |> set_bgnodes vnms;

  fun next_branch edata =
    case get_branches edata of
         []    => NONE
     | (x::xs) => SOME (get_current edata,edata |> set_current x |> set_branches xs);

  fun pretty_goals edata = 
    Pretty.chunks
      ([Pretty.str "Open goals in the current psgraph :{"] @
      (get_pplan edata |> Prover.get_open_pnodes |> map Prover.pretty_pnode) @
      [Pretty.str "}"])
     
   structure Sharing =
   struct
     type branch = branch
     type active = active
     type T = T
     type gnode = gnode
     structure PSGraph = PSGraph.Sharing
   end

end; (* functor *)


