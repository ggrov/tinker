(* evaluation *)

functor EValFun(EData : EVAL_DATA) : EVAL =
struct
 structure EData = EData;
 structure Theory = EData.PSGraph.Theory;
 structure Graph = Theory.Graph;
 structure GoalTyp = EData.PSGraph.Theory.Data.GoalTyp;
 structure Prover = GoalTyp.Prover;
 structure GData = EData.PSGraph.Theory.Data;
 structure Util =  Theory.Graph_Utils;

  exception apply_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode
  exception node_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode * EData.PSGraph.Theory.Data.nvdata
  exception partition_exp of
    { pnodes :  EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list,
      input :  EData.PSGraph.Theory.Data.GoalTyp.gnode, 
      goaltypes : EData.PSGraph.Theory.Data.GoalTyp.T list } 
  exception Fail = RunCall.Fail

  local open Theory.Graph_Utils LoggingHandler in
  (*******
    Application of tactic - link with TP systems
  *******)   
  fun apply_tactic edata gnode (GData.T_Atomic name) = 
       let 
         val pnode = EData.get_goal edata (GoalTyp.goal_name gnode)
         val pplan = EData.get_pplan edata
         (* string vs facts : what about variables? and list of things bound? *)
         val facts = []
         (* get tactic string from the tactic node, and then eval the tac*)
         val if_env_tac = is_env_tactic_name name
         val (tac_code, arg_list) = 
            EData.PSGraph.get_atomic_tac_code_and_args (EData.get_psgraph edata) name pnode
            (* the actual ml code of the tactic to be evaluated *)
         (* val tac = EData.PSGraph.Tac_ML_Exec.eval_ml tac_code *)
       in 
        if if_env_tac 
        then Prover.apply_env_tactic arg_list tac_code (pnode,pplan)
        else Prover.apply_tactic arg_list tac_code (pnode,pplan)
      end
   | apply_tactic _ gnode node = raise node_exp ("not an atomic tactic node",gnode ,node);

  (* FIXME: can we get a list of failed pnodes *)

  (* need some filtering of empty here *)
  fun partition_one' _ [] _ _ _ [] = [] (* fails to lift for this branch *)
   |  partition_one' gtype_data (gt::gts) gnode pnode bres (r::ares) = 
    (case GoalTyp.check (gtype_data,gt) (SOME gnode,pnode) of
      (* fails to lift *)
      false  => partition_one' gtype_data gts gnode pnode (bres@[r]) ares
      (* succeeds, and check for further successes *)
    | true =>
        (* adds the succeded to the current result *)
        (bres @ [(GoalTyp.lift pnode) :: r] @ ares) ::
        (* goes through and see if more succeeds (thus branching) *)
         partition_one' gtype_data gts gnode pnode (bres@[r]) ares)
  | partition_one' _ _ _ _ _ _ = [];

  (* raises exception if one proof nodes fails *)
  fun partition_one gtype_data goal_typs gnode pnode res =
    case partition_one' gtype_data goal_typs gnode pnode [] res of
       [] => raise partition_exp {input = gnode, pnodes = [pnode], goaltypes = goal_typs} 
     | xs => xs 

  (* return value : outer list - each branch: singleton 
                    middle list - one branch same length as goaltype input list
                    inner list - matching goal nodes for given goaltype
    invariant result = partition goal_typs pplan pnds 
       all res in result: length res  = length goal_typs (and they pairwise match)
                          
       outer list is all the possible options -> should be a singleton list if orthogonal
       length (result) > 0
  *)
  fun partition _ []     _       _     = []
   |  partition gtype_data pnds gnode goal_typs =
        [map (K []) goal_typs] (* empty list to start *)
        |> fold (fn pnd => maps (partition_one gtype_data goal_typs gnode pnd)) pnds;

  val partition_to_gnodes = map (map GData.G);
 
  fun get_next_tnode graph node = 
    if Util.is_gnode graph node
    then
      get_next_tnode graph
        (Util.out_edges graph node
        |> (fn [x] => x) (* raise exception: log if not singleton list *)
        |> Util.edge_dest graph)
    else node

   (* allows to step over gnodes *)
  fun try_get_out graph v =
   if Util.is_tactic graph v (* assume no variables *) 
    then NONE
    else 
     case Util.out_edges graph v  of
         [] => SOME v (* output *)
      | [e] => try_get_out graph (Util.edge_dest graph e) (* gnode or  *)
      |  _  => NONE (* many outputs (shouldn't happen) *);

   (* allows to step over gnodes *)
  fun try_get_in graph v =
   if Util.is_tactic graph v (* assume no variables *) 
    then NONE
    else 
     case Util.in_edges graph v  of
         [] => SOME v (* output *)
      | [e] => try_get_in graph (Util.edge_src graph e) (* gnode or  *)
      |  _  => NONE (* many outputs (shouldn't happen) *);

  fun has_current_graph_terminated edata = 
    Util.all_gnodes (EData.get_graph edata)
    |> forall (is_some o (try_get_out (EData.get_graph edata)));

  fun has_psgraph_terminated edata = 
    has_current_graph_terminated edata andalso (* current graph is terminated *)
    (EData.get_parent edata |> StrName.NTab.list_of) = []

  (* assume exact same boundary *)
  fun move_gnode from' v to' =
    let 
      val (SOME b) = try_get_out from' v
      val [edge] = Util.in_edges to' b
      val (SOME node) = Util.lookup_ivertex_data from' v
    in
      Util.insert_node_on_edge node edge to'
    end

  (* for evaluation *)
  fun next_tactic_vertex graph v = 
    case Util.lookup_ivertex_data graph v of
      SOME _ => if Util.is_tactic graph v then SOME v else NONE
      | NONE => (case (Util.out_edges graph v) of 
                  [] => (* output edge *) NONE
                  | [e] => next_tactic_edge graph e
                  | _ => (* should never happen *) NONE)
  and next_tactic_edge graph edge =
    next_tactic_vertex graph (Util.edge_dest graph edge)

  (* project goal node  and call next_tactic_vertex -
      a lot of optimizations possible: store gnode for one... *)
  fun next_tactic graph node = 
    let 
      fun check_gnode v =
        GoalTyp.gnode_eq (Util.gnode_of graph v,node)
        handle _ => false
      fun getvertex [] = NONE
       |  getvertex (v::vs) = 
           if check_gnode v
            then SOME v
            else getvertex vs
    in
      case getvertex (Util.all_gnodes graph) of
         NONE => NONE
       | SOME v => next_tactic_vertex graph v
    end;
    
(************************************************************
      INITIALISATION
*************************************************************)
 (* fixme: may loose goals! *)
 fun init_goal pnode edata  = 
   let
     val gt_data = GoalTyp.default_data
                (* edata 
                 |> EData.get_psgraph  
                 |> EData.PSGraph.get_goaltype_data*)
     val graph = EData.get_graph edata
     fun to_gt e = [(e,Util.goaltype_of graph e)] handle _ => []
     val in_edges = Util.input_boundary graph
                  |> maps (fn (_,(e,_),_) => to_gt e)
     fun new_graph (e,gt) = 
       case GoalTyp.check (gt_data,gt) (NONE,pnode) of
         false => [] (* not needed *)
         | ture => map (fn gn => (gn, #3 (Util.insert_node_on_edge (Util.mk_gnode gn) e graph))) [GoalTyp.lift pnode] 
     val new_graphs = maps new_graph in_edges
   in  (* fixme: this should be updated according to strategy *)
       map (fn (gn,g) => edata |> EData.update_gnodes (fn gs => gn::gs) 
                               |> EData.set_graph g) 
           new_graphs
   end;

 fun init_goals edata pnodes = 
   fold (fn pnode => fn edatas => maps (init_goal pnode) edatas)
        pnodes
        [edata];

 fun init_of psgraph (pnds,pplan) =
   let
     val pnode_tab = 
      fold 
       (fn pnode => StrName.NTab.ins (Prover.get_pnode_name pnode,pnode))
       pnds
       StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goals edata0 pnds
    |> (fn x => case x of [] => []
      | _ => x)
   end;

 fun init psgraph ctxt assms goals =
   let
     val (pnode,pplan) = Prover.init ctxt assms goals
     val pnode_tab = 
       StrName.NTab.ins
         (Prover.get_pnode_name pnode,pnode)
         StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goal pnode edata0
    |> (fn x => case x of [] => []
      | _ => x)
   end;

(************************************************************
      Gnode evaluation
*************************************************************)
  (* fixme: make this into branch instead *)
  fun apply_atomic edata gnode tac goal_typs = 
   let 
     val gt_data = GoalTyp.default_data (*edata 
                  |> EData.get_psgraph  
                  |> EData.PSGraph.get_goaltype_data*)
     fun apply_one (pnds,pplan) =
       Seq.single (EData.get_current edata
         |> EData.set_bpplan pplan
         |> EData.add_bgoals pnds,
       partition gt_data pnds gnode goal_typs)
    handle partition_exp _ => Seq.empty
   in
     apply_tactic edata gnode tac
     |> Seq.maps apply_one
(*   |> Seq.list_of
     |> map (fn (x,y) => ((EData.get_bpplan x |> Prover.get_open_pnodes |> map Prover.pretty_pnode |> Pretty.chunks |> Pretty.writeln); (x,y)))
     |> Seq.of_list*)
   end

  fun add_gnode n e g =
    let 
      val (from,_,g') = Util.insert_node_on_edge n e g 
    in
      (from,g')
   end

  fun add_gnodes (edge::edges) (res::ress) graph = 
     fold (fn gn => fn (e,gr) => add_gnode (Theory.Data.G gn) e gr) res (edge,graph)
     |> #2
     |> add_gnodes edges ress
  | add_gnodes [] _ graph = graph
  | add_gnodes _ [] graph = graph

  fun eval_apply_atomic gnode_name tnode edata =
   let
     val graph = EData.get_graph edata (* has to be the current one *)
     val out_edges = Util.out_edges graph tnode
     val out_goaltypes = map (Util.goaltype_of graph) out_edges
     val graph' = Util.del_gnode gnode_name graph
     val goal = Util.gnode_of graph gnode_name
     val (SOME tactic) = Util.lookup_ivertex_data graph tnode
     val result = apply_atomic edata goal tactic out_goaltypes
   in
      Seq.maps (fn (b,rs) 
        => (case rs 
             of [] => [(EData.set_bgraph graph' b(*, rs*))] |> Seq.of_list (* no new goal is produced *)
               | _ => (map (fn res => (EData.set_bgraph (add_gnodes out_edges res graph') b(*, rs*))) rs) (* comment out gnode list *) 
                       |> Seq.of_list)) result
     (*|> Seq.list_of
     |> map (fn (x) => ((EData.get_bpplan x |> Prover.get_open_pnodes |> map Prover.pretty_pnode |> Pretty.chunks |> Pretty.writeln); (x)))
     |> Seq.of_list*)
   end

 fun enter_hgraph gnode_name hgraph_nv edata = 
   let
    val graph = EData.get_graph edata
    val goal = Util.gnode_of graph gnode_name
    val pnode = EData.get_goal edata (GoalTyp.goal_name goal)
    val hgraph_name = 
      case hgraph_nv of (GData.T_Graph name) => name 
      | _ => raise GData.node_exp ("expect hgraph, but some other type of nvnode",hgraph_nv);
    val graph_tacs_args = EData.PSGraph.get_graph_tacs_args (EData.get_psgraph edata) hgraph_name
    val cur_name = EData.get_name_current edata
    val cur_idx =  EData.get_index_current edata
    val gt_data = GoalTyp.default_data (*EData.get_psgraph edata |> EData.PSGraph.get_goaltype_data*)
    val graph' = Util.del_gnode gnode_name graph
    fun set_hgraph_idx 0 b = [EData.set_bindex_current 0 b]
    | set_hgraph_idx i b = (EData.set_bindex_current i b) :: (set_hgraph_idx (i-1) b)
    fun insert_gnode b = 
      let 
        fun gen_in_edges g0 = 
          Util.input_boundary g0 
          |> maps (fn (_,(e,_),_) => [(e,Util.goaltype_of g0 e)])
        val g = EData.get_bgraph b
        fun gen_new_graph (e,gt) = 
         if GoalTyp.check (gt_data,gt) (NONE, pnode) 
         then
           [(GoalTyp.lift pnode, #3 (Util.insert_node_on_edge (Util.mk_gnode (GoalTyp.lift pnode)) e g))] 
         else [] 
        fun new_hgraphs g0 = 
          maps gen_new_graph (gen_in_edges g0) 
          |> map snd (* to project graph *)
          |> (fn x => case x of 
                [] => raise Fail ("All edges fail to move goal: " ^  GoalTyp.goal_name goal)

               | _ => x)
      in
        map (fn g0 => EData.set_bgraph g0 b) (new_hgraphs (EData.get_bgraph b))
      end
   in
     (* update and delete the gnode in the current graph *)
     EData.set_bgraph graph' (EData.get_current edata) 
     (* move to the subgraph and save the current grah hie in the parent *)
     |> EData.update_bparent (StrName.NTab.ins (hgraph_name, (cur_name, cur_idx)) handle _ => raise Fail "fail to re insert the hgraph")
     |> EData.push_bcur_hie hgraph_name
     (* get subgraphs, for each subgraph, create a branch *)
     |> (fn b => set_hgraph_idx (EData.get_bgraphs_gen hgraph_name b |> List.length |> (fn x => x -1)) b)
     |> maps insert_gnode
     |> Seq.of_list
   end

 fun move_upto_parent b = 
   let 
    val cur_name = EData.get_bname_current b
    val (name, idx) = StrName.NTab.get  (EData.get_bparent b) cur_name  
   in
     EData.pop_bcur_hie b
     |> EData.set_bindex_current idx  
     |> EData.update_bparent (StrName.NTab.delete cur_name)
   end

 fun exit_hgraph_no_goal_node edata = move_upto_parent (EData.get_current edata) |> Seq.single
 
 fun exit_hgraph gnode_name edata = 
  let 
    val graph = EData.get_graph edata
    val graph' = Util.del_gnode gnode_name graph
    val gt_data = GoalTyp.default_data (*edata |> EData.get_psgraph |> EData.PSGraph.get_goaltype_data*)
    val goal = Util.gnode_of graph gnode_name
    val pnode = EData.get_goal edata (GoalTyp.goal_name goal)
    val cur_b = EData.get_current edata
    val (par_name, par_idx) = StrName.NTab.get (EData.get_parent edata) (EData.get_name_current edata)
    val parent_graph = EData.get_bgraph_gen par_name par_idx cur_b
    val parent_hgraph_node = Util.lookup_hgragh_by_graph_name parent_graph (EData.get_name_current edata)
    val out_edges = Util.out_edges parent_graph parent_hgraph_node
    val out_goaltypes = map (fn e => (e, Util.goaltype_of parent_graph e)) out_edges
    fun gen_new_graph (e,gt) = 
     if GoalTyp.check (gt_data,gt) (NONE, pnode) 
     then [(GoalTyp.lift pnode, #3 (Util.insert_node_on_edge (Util.mk_gnode (GoalTyp.lift pnode)) e parent_graph))] 
     else []
    val new_parent_graphs = 
      maps gen_new_graph out_goaltypes 
      |> map snd (* to project graph *)
      |> (fn x => case x of 
            [] => raise Fail ("All edges fail to move goal: " ^  GoalTyp.goal_name goal)
           | _ => x)
  in
    if List.length (Util.all_gnodes (EData.get_graph edata)) > 1 (* more than one goal node *)
    then (* delete the g; add it in the parent graph; update both graph as a branche *)
      EData.set_bgraph graph' (EData.get_current edata)
      |> (fn b => (map (fn g => EData.set_bgraph_gen par_name par_idx g b) new_parent_graphs)) 
      |> Seq.of_list
    else (* also need to remove the current graph from the parent map, as no goal nodes in this graph *)
      EData.set_bgraph graph' (EData.get_current edata)
      |> (fn b => (map (fn g => EData.set_bgraph_gen par_name par_idx g b) new_parent_graphs)) 
      |> map move_upto_parent
      |> Seq.of_list
  end

 fun eval_apply_id gnode_name id_node edata =
   let
    val gt_data = GoalTyp.default_data (*edata |> EData.get_psgraph |> EData.PSGraph.get_goaltype_data*)
    val graph = EData.get_graph edata
    val goal = Util.gnode_of graph gnode_name
    val pnode = EData.get_goal edata (GoalTyp.goal_name goal)
    val graph' = Util.del_gnode gnode_name graph
    val out_edges = Util.out_edges graph id_node
    val out_goaltypes = map (fn e => (e, Util.goaltype_of graph e)) out_edges
    fun gen_new_graph (e,gt) = 
     if GoalTyp.check (gt_data,gt) (NONE, pnode) 
     then [(GoalTyp.lift pnode, #3 (Util.insert_node_on_edge (Util.mk_gnode (GoalTyp.lift pnode)) e graph'))]
     else []
    val new_graphs = 
      maps gen_new_graph out_goaltypes 
      |> map snd (* to project graph *)
      |> (fn x => case x of 
            [] => raise Fail ("All edges fail to move goal: " ^  GoalTyp.goal_name goal)
           | _ => x)
   in
    EData.set_bgraph graph' (EData.get_current edata)
    |> (fn b => (map (fn g => EData.set_bgraph g b)) new_graphs)
    |> Seq.of_list
   end

 (* evaluates a single goal node *)
  fun eval_goal_gen gname graph_name0 index0 edata = 
   let
     val _ = 
      Util.gnode_of (EData.get_graph edata) gname
      |> (fn x => EData.get_goal edata (GoalTyp.goal_name x))
      |> (fn pnode => Prover.pretty_env (Prover.get_pnode_ctxt pnode) (Prover.get_pnode_env pnode))
      |> (Pretty.string_of )
      |> logging "ENV_DATA" 
     val graph = 
      if is_some graph_name0 then raise Fail "ERR: NOT Support to switch between subgraph yet" 
      else EData.get_graph edata
     val gnode = Util.gnode_of graph gname
   in
     if (is_some o (try_get_out (EData.get_graph edata))) gname
     (* the goal is terminated in the current graph *)
     then (* either exit or raise an exception if it is in the main *)
       if EData.get_name_current edata  = EData.get_main_current edata then raise Fail "ERR: main has already been terminated "
       else (* exit the current hie *) exit_hgraph gname edata
     else (* not terminated, so either apply atomic or apply hgraph*)
     (
      let      
        val tnode = get_next_tnode graph gname
        val (SOME nv) = Util.lookup_ivertex_data graph tnode
      in
        case nv of
           (GData.T_Atomic _) => eval_apply_atomic gname tnode edata
         | (GData.T_Identity) => eval_apply_id gname tnode edata
         | (GData.T_Graph _) => enter_hgraph gname nv edata
         | _ => raise node_exp ("ERR: unexpected node type to apply eval ", gnode, nv)
      end
     )
  end
 
  fun eval_goal_gnodename is_interactive gnode_name edata = eval_goal_gen gnode_name NONE NONE edata

  fun eval_goal_goalname is_interactive gname edata = 
   let
     val graph = EData.get_graph edata
     val gnode_name = Util.all_gnodes graph
               |> filter (fn gn => gname = GoalTyp.goal_name (Util.gnode_of graph gn))
               |> (fn [x] => x) (* raise exception: log if not singleton list *)
   in
     eval_goal_gen gnode_name NONE NONE edata
   end;
  end; (* end of open local graph utils *)
end (* functor *)


