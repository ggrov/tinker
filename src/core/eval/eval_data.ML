
functor EDataFun(PSGraph : PS_GRAPH) : EVAL_DATA  =
struct
local open LoggingHandler in
  structure PSGraph = PSGraph;
  structure Prover = PSGraph.Theory.Data.GoalTyp.Prover;

  type gnode = PSGraph.Theory.Data.GoalTyp.gnode


  datatype active = Active of {
     (*graph : PSGraph.Theory.Graph.T current graph *)
     index_current: int,
     name_current_hie: StrName.NTab.name list,
     parent: (StrName.NTab.name * int) StrName.NTab.T, (* record eval hierechy: child nanme -> parent name *)
     gnodes : gnode list, (* not updated, used to work with evalf for the order of the goal node *)
     searchf : string, (* not support *)
     evalf : string (* not support *)
  }
  datatype branch = Branch of {
    active : active,
    psgraph : PSGraph.T, (* each brach should have a psgraph. as gnodes differ *)
    pplan : Prover.pplan,
    goals : Prover.pnode StrName.NTab.T
  }
  (* todo : should we keep the previous Edata  too?*)
  datatype T = EData of { 
      current : branch,
      branches : branch list
  }
                                                               
  fun get_agnodes (Active rep) = #gnodes rep;
  fun get_aparent (Active rep) = #parent rep;
  fun get_asearchf (Active rep) = #searchf rep;
  fun get_aevalf (Active rep) = #evalf rep;
  fun get_aname_current_hie (Active rep) = #name_current_hie rep;
  fun get_aname_current rep = get_aname_current_hie rep |> hd 
  handle Empty => (logging "HIERARCHY" "Try entering parent graph but already at the top"; raise tinker_fail)
  fun get_aindex_current (Active rep) = #index_current rep;
  
  fun get_bactive (Branch rep) = #active rep;
  fun get_bpplan (Branch rep) = #pplan rep;
  fun get_bgoals (Branch rep) = #goals rep;
  fun get_bpsgraph (Branch rep) = #psgraph rep;

  fun get_current (EData rep) = #current rep;
  fun get_branches (EData rep) = #branches rep;

  val get_psgraph = get_bpsgraph o get_current;
  val get_pplan = get_bpplan o get_current;
  val get_goals = get_bgoals o get_current;
  val get_active = get_bactive o get_current;

  val get_graph = (fn x => PSGraph.get_graph (get_psgraph x) ((get_aname_current o get_active) x) ((get_aindex_current o get_active) x));
  val get_parent = get_aparent o get_active;
  val get_name_current = get_aname_current o get_active;
  val get_name_current_hie = get_aname_current_hie o get_active;
  val get_main_current = PSGraph.get_main o get_bpsgraph o get_current;
  val get_index_current = get_aindex_current o get_active;
  val get_gnodes = get_agnodes o get_active;
  val get_searchf = get_asearchf o get_active;
  val get_evalf = get_aevalf o get_active;

  val get_bparent = get_aparent o get_bactive;
  val get_bgnodes = get_agnodes o get_bactive;
  val get_bsearchf = get_asearchf o get_bactive;
  val get_bevalf = get_aevalf o get_bactive;
  val get_bname_current = get_aname_current o get_bactive;
  val get_bname_current_hie = get_aname_current_hie o get_bactive;
  val get_bindex_current = get_aindex_current o get_bactive;
  val get_bgraph =  (fn x => PSGraph.get_graph (get_bpsgraph x) (get_bname_current x) (get_bindex_current x));
  fun get_bgraph_gen name idx b =  PSGraph.get_graph (get_bpsgraph b) name idx;
  fun get_bgraphs_gen name b = PSGraph.get_graphs (get_bpsgraph b) name;


  fun update_agnodes f (Active rep) =
    Active {gnodes = f (#gnodes rep), name_current_hie = #name_current_hie rep, index_current = #index_current rep,
            searchf = #searchf rep, evalf = #evalf rep, parent = #parent rep};
  fun update_aparent f (Active rep) =
    Active {gnodes = #gnodes rep, name_current_hie = #name_current_hie rep, index_current = #index_current rep,
            searchf = #searchf rep, evalf = #evalf rep, parent = f (#parent rep)};
  fun update_asearchf f (Active rep) =
    Active {gnodes = #gnodes rep, name_current_hie = #name_current_hie rep, index_current = #index_current rep,
            searchf = f (#searchf rep), evalf = #evalf rep, parent = #parent rep};
  fun update_aevalf f (Active rep) =
    Active {gnodes = #gnodes rep,  name_current_hie = #name_current_hie rep, index_current = #index_current rep,
            searchf = #searchf rep, evalf = f (#evalf rep), parent = #parent rep};

  fun update_aname_current_hie f (Active rep) =
    Active {gnodes = #gnodes rep,  name_current_hie = f (#name_current_hie rep), index_current = #index_current rep,
            searchf = #searchf rep, evalf = #evalf rep, parent = #parent rep};

  fun update_aindex_current f (Active rep) =
    Active {gnodes = #gnodes rep,  name_current_hie = #name_current_hie rep, index_current = f (#index_current rep),
            searchf = #searchf rep, evalf = #evalf rep, parent = #parent rep};


  val set_agnodes = update_agnodes o K;
  val set_aparent = update_aparent o K;
  val set_asearchf = update_asearchf o K;
  val set_aevalf = update_aevalf o K;
  val set_aname_current_hie = update_aname_current_hie o K
  val set_aindex_current = update_aindex_current o K

  val pop_acur_hie = update_aname_current_hie tl
  handle Empty => (logging "HIERARCHY" "Try entering parent graph but already at the top"; raise tinker_fail)
  fun push_acur_hie n = update_aname_current_hie (fn x => n :: x)

  fun update_bactive f (Branch rep) =
    Branch {active = f (#active rep), pplan = #pplan rep, goals = #goals rep, psgraph = #psgraph rep};
  fun update_bpplan f (Branch rep) =
    Branch {active = #active rep, pplan = f (#pplan rep), goals = #goals rep, psgraph = #psgraph rep};
  fun update_bgoals f (Branch rep) =
    Branch {active = #active rep, pplan = #pplan rep, goals = f (#goals rep),  psgraph = #psgraph rep};
  fun update_bpsgraph f (Branch rep) =
    Branch {active = #active rep, pplan = #pplan rep, goals = #goals rep,  psgraph = f (#psgraph rep)};

  val set_bactive = update_bactive o K;
  val set_bpplan = update_bpplan o K;
  val set_bgoals = update_bgoals o K;
  val set_bpsgraph = update_bpsgraph o K
  fun set_bgraph g b =     
    set_bpsgraph 
      (PSGraph.set_graph 
        (get_bname_current b) 
        (get_bindex_current b) 
        g
        (get_bpsgraph b)) b

  fun set_bgraph_gen name idx g b =     
    set_bpsgraph 
      (PSGraph.set_graph name idx g
        (get_bpsgraph b)) b


  fun update_current f (EData rep) =
    EData {current = f (#current rep), branches = #branches rep};
  fun update_branches f (EData rep) =
    EData {current = #current rep, branches = f (#branches rep)};

  val set_current = update_current o K;
  val set_branches = update_branches o K;

  val update_psgraph = update_current o update_bpsgraph;
  val update_active = update_current o update_bactive; 
  val update_goals = update_current o update_bgoals;
  val update_pplan = update_current o update_bpplan;
  val update_gnodes =  update_active o update_agnodes;
  val update_searchf =  update_active o update_asearchf;
  val update_evalf =  update_active o update_aevalf;
  val update_parent =  update_active o update_aparent;
  
  val pop_cur_hie = update_active pop_acur_hie;
  val push_cur_hie = update_active o push_acur_hie;
  val set_gnodes = update_gnodes o K;
  val set_searchf = update_searchf o K;
  val set_evalf = update_evalf o K;
  val set_pplan = update_pplan o K;
  val set_psgraph = update_psgraph o K;
  val set_goals = update_goals o K;
  val set_active = update_active o K;
  val set_parent = update_parent o K;
  fun set_graph g ps = 
    set_psgraph 
      (PSGraph.set_graph 
        ((get_aname_current o get_active) ps) 
        ((get_aindex_current o get_active) ps) 
        g
        (get_psgraph ps)) 
    ps 
  val update_bparent = update_bactive o update_aparent;
  val set_bparent = update_bparent o K;
  val update_bgnodes =  update_bactive o update_agnodes;
  val set_bgnodes = update_bgnodes o K;
  val update_bsearchf =  update_bactive o update_asearchf;
  val set_bsearchf = update_bsearchf o K;
  val update_bevalf =  update_bactive o update_aevalf;
  val set_bevalf = update_bevalf o K;
  val update_bname_current_hie = update_bactive o update_aname_current_hie;
  val set_bname_current_hie = update_bname_current_hie o K
  val pop_bcur_hie = update_bname_current_hie tl 
  handle Empty => (logging "HIERARCHY" "Try entering parent graph but already at the top"; raise tinker_fail)
  fun push_bcur_hie n = update_bname_current_hie  (fn x => n :: x)

  val update_bindex_current = update_bactive o update_aindex_current;
  val set_bindex_current = update_bindex_current o K

  fun init_active  vs main =
     Active {gnodes = vs, searchf = "depth_first", 
     name_current_hie = [main], index_current = 0,
     evalf = "depth_first", parent = StrName.NTab.empty}

  fun init_branch prf psgraph goals vs  =
    Branch {active = init_active  vs (PSGraph.get_main psgraph), pplan = prf, goals = goals, psgraph = psgraph};

  fun init psgraph prf goals vs  =
    EData {current = init_branch prf psgraph goals vs, branches = []};

  fun ins_tab pnode = StrName.NTab.ins (Prover.get_pnode_name pnode,pnode);
  val lookup_goal = StrName.NTab.lookup o get_goals;
  val get_goal = StrName.NTab.get o get_goals;
  fun add_goal pnode = update_goals (ins_tab pnode)
  fun add_goals pnods = update_goals (fold ins_tab pnods);
  fun add_bgoals pnods = update_bgoals (fold ins_tab pnods);
  fun del_goal pname = update_goals (StrName.NTab.delete pname);

(*  val get_tactics = get_psgraph #> PSGraph.get_tactics;
  val lookup_tactic = get_tactics #> StrName.NTab.lookup
  fun get_tactic data tac = StrName.NTab.get (get_tactics data) tac
  handle x => (DebugHandler.add_debug_msg (Pretty.str ("No such a tac : " ^ tac) );raise x ) *)
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
end (* end of local *)
end; (* functor *)


