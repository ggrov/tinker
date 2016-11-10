(* evaluation *)

functor EValFun(EData : EVAL_DATA) : EVAL  =
struct
 structure EData = EData;
 structure Theory = EData.PSGraph.Theory;
 structure Graph = Theory.Graph;
 structure Env_Tac_Utils = EData.PSGraph.Env_Tac_Utils;
 structure GoalTyp = EData.PSGraph.Theory.Data.GoalTyp;
 structure Prover = GoalTyp.Prover;
 structure GData = EData.PSGraph.Theory.Data;
 structure Util =  Theory.Graph_Utils;

  exception apply_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode
  exception node_exp of string * EData.PSGraph.Theory.Data.GoalTyp.gnode * EData.PSGraph.Theory.Data.nvdata
  exception partition_exp of
    { pnodes :  EData.PSGraph.Theory.Data.GoalTyp.Prover.pnode list,
      input :  EData.PSGraph.Theory.Data.GoalTyp.gnode option, 
      goaltypes : EData.PSGraph.Theory.Data.GoalTyp.T list } 
  exception Fail = RunCall.Fail
  exception Breakpoint of EData.T;

  local open Theory.Graph_Utils LoggingHandler in
  (*******
    Application of tactic - link with TP systems
  *******)   
  fun apply_tactic edata gnode (GData.T_Atomic atom) = 
       let 
         val ps = EData.get_psgraph edata
         val pplan = EData.get_pplan edata
         val pnode = Prover.get_open_pnode_by_name pplan  (GoalTyp.goal_name gnode)
         val env = Prover.get_pnode_env pnode
         val ctxt = Prover.get_pnode_ctxt pnode
         val name = (GData.get_nvdata_name (GData.T_Atomic atom))
         val arg_list = (GData.get_nvdata_args (GData.T_Atomic atom)) |> parse_arg_data ctxt pnode
       in  
        if is_env_tactic_name name 
        then 
        let val env_tac = if Env_Tac_Utils.is_abbrv_env_tac name
        then Env_Tac_Utils.scan_abbrv_env_tac ctxt name env
        else EData.PSGraph.get_atomic_env_tac_by_name ps name in
        Prover.apply_env_tactic arg_list env_tac (pnode,pplan) end
        else 
        let val tac = EData.PSGraph.get_atomic_tac_by_name ps name in
        Prover.apply_tactic arg_list tac (pnode,pplan) end
      end
   | apply_tactic _ gnode node = raise node_exp ("not an atomic tactic node",gnode ,node);

  (* need some filtering of empty here *)
  fun partition_one' _ [] _ _ _ _  [] = [] (* fails to lift for this branch *)
   |  partition_one' gtype_data (gt::gts) pnode gnode_opt pplan bres (r::ares) = 
     if not (GoalTyp.check (gtype_data,gt) (gnode_opt,pnode))
      (* fails to lift *)
    then  partition_one' gtype_data gts pnode gnode_opt pplan (bres@[r]) ares
      (* succeeds, and check for further successes *)
    else
        let
         val new_branch =  (pplan, (bres @ [(GoalTyp.lift pnode) :: r] @ ares))
        in
        (* adds the succeded to the current result *)
        [new_branch] @ 
        (* goes through and see if more succeeds (thus branching) *)
         partition_one' gtype_data gts pnode gnode_opt pplan (bres@[r]) ares end
  | partition_one' _ _ _ _ _ _ _ = [];

  (* raises exception if one proof nodes fails *)
  fun partition_one gtype_data goal_typs pnode gnode_opt (pplan,res) =
    case partition_one' gtype_data goal_typs pnode gnode_opt pplan [] res of
       [] => raise partition_exp {input = gnode_opt, pnodes = [pnode], goaltypes = goal_typs} 
     | xs => xs 

  (*
  type: 
   GoalTyp.data ->
   Prover.pnode list ->
   GoalTyp.gnode option -> pplan -> GoalTyp.T list -> (pplan * GoalTyp.gnode list list) list 

  return value : outer list - each branch: singleton 
                    middle list - one branch same length as goaltype input list
                    inner list - matching goal nodes for given goaltype
    invariant result = partition goal_typs pplan pnds 
       all res in result: length res  = length goal_typs (and they pairwise match)
                          
       outer list is all the possible options -> should be a singleton list if orthogonal
       length (result) > 0
  *)
  fun partition _ [] _  _ _ = []
   |  partition gtype_data pnds gnode_opt pplan goal_typs =
(* empty list to start, mk an empty list for each output edges, each 
branch should have a pplan, as goaltype will change the env so that the gnode in the pplan need to be updated *)
        [(pplan, map (K []) goal_typs)]
        |> fold (fn pnd => maps (partition_one gtype_data goal_typs pnd gnode_opt)) pnds;

(*
  val partition_to_gnodes = map (map GData.G);
*) 
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
(*
  fun try_get_in graph v =
   if Util.is_tactic graph v (* assume no variables *) 
    then NONE
    else 
     case Util.in_edges graph v  of
         [] => SOME v (* output *)
      | [e] => try_get_in graph (Util.edge_src graph e) (* gnode or  *)
      |  _  => NONE (* many outputs (shouldn't happen) *);
*)
  fun is_top_level_psgraph edata = 
   (EData.get_parent edata |> StrName.NTab.list_of) = []
  
  fun is_gn_on_boundary edata goal_name =
   let
    val graph = EData.get_graph edata
    val gnode = Util.all_gnodes graph
               |> filter (fn gn => goal_name = GoalTyp.goal_name (Util.gnode_of graph gn))
               |> (fn [x] => x) (* raise exception: log if not singleton list *)
   in
     (is_some o try_get_out graph) gnode
   end

  fun is_all_gns_on_boundary edata = 
    Util.all_gnodes (EData.get_graph edata)
    |> forall (is_some o (try_get_out (EData.get_graph edata))); 

  fun has_psgraph_terminated edata = 
    is_all_gns_on_boundary edata andalso
    is_top_level_psgraph edata
  

(*  (* assume exact same boundary *)
  fun move_gnode from' v to' =
    let 
      val (SOME b) = try_get_out from' v
      val [edge] = Util.in_edges to' b
      val (SOME node) = Util.lookup_ivertex_data from' v
    in
      Util.insert_node_on_edge node edge to'
    end
*)
(*  (* for evaluation *)
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
*)    
(************************************************************
      INITIALISATION
*************************************************************)
 (* fixme: may lose goals! *)
 fun init_goal pnode edata  = 
   let
     val gt_data = edata 
                 |> EData.get_psgraph  
                 |> EData.PSGraph.get_goaltype_data
     val graph = EData.get_graph edata
     fun to_gt e = [(e,Util.goaltype_of graph e)] handle _ => []
     val in_edges = Util.input_boundary graph
                  |> maps (fn (_,(e,_),_) => to_gt e)
     fun new_graph (e,gt) = 
       case GoalTyp.check (gt_data,gt) (NONE,pnode) of
         false => [] (* not needed *)
         | true => map (fn gn => (gn, #3 (Util.insert_node_on_edge (Util.mk_gnode gn) e graph))) [GoalTyp.lift pnode] 
     val new_graphs = maps new_graph in_edges
   in  (* fixme: this should be updated according to strategy *)
       map (fn (gn,g) => edata |> EData.update_gnodes (fn gs => gn::gs) 
                               |> EData.set_graph g) 
           new_graphs
   end;

 fun init psgraph ctxt st =
   let
     val (pnode,pplan) = Prover.init ctxt st
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
  fun print_outedges (r : GoalTyp.gnode list list) = 
   let fun print_one gs =  map GoalTyp.goal_name gs |> str_blocks ", " in
   logging "EVAL"  ("Branch (goals on the ouput edges): | " ^((map print_one r) |> str_blocks " | ") ^ " |") end

  fun mk_ngs_to_branch  gt_data gnode_opt goal_typs  (ngs :( Prover.pnode list * Prover.pplan) Seq.seq) 
    : (Prover.pplan * GoalTyp.gnode list list) Seq.seq =
   let 
     fun apply_one (pnds,pplan) =
      let
        val res = partition gt_data pnds gnode_opt pplan goal_typs  
      in
       case pnds of [] => Seq.single (pplan, [])
       | _ =>  (map (print_outedges o snd) res ; Seq.of_list res)
      end
    handle partition_exp {pnodes,...}  => 
      (logging "GOAL" ("Discard the result due to no matched goaltype for the output goal pnode :\n" ^ 
       ((hd pnodes) |> Prover.pretty_pnode |> Pretty.string_of)); 
       (*raise tinker_fail false*) Seq.empty)
   in
    Seq.maps apply_one ngs
   end
  fun apply_atomic edata gnode tac goal_typs =
   let  
    val gt_data = edata 
                  |> EData.get_psgraph  
                  |> EData.PSGraph.get_goaltype_data 
    val res = apply_tactic edata gnode tac  
   in
      mk_ngs_to_branch gt_data (SOME gnode) goal_typs res
      |> Seq.map (fn (pp, res) => (EData.set_bpplan pp (EData.get_current edata) , res))
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
   (*
      case Seq.pull result of SOME ((b,[]),_)  =>
        Seq.single (
         EData.set_bgraph graph' b)
      | _ => Seq.map 
       (fn (b,rs) => (EData.set_bgraph (add_gnodes out_edges rs graph')) b) 
      result
    *)
      Seq.map 
       (fn (b,rs) => (EData.set_bgraph (add_gnodes out_edges rs graph')) b) 
      result
   end

 fun enter_hgraph gnode_name hgraph_nv tnode edata = 
   let
    val graph = EData.get_graph edata
    val goal = Util.gnode_of graph gnode_name
    val pplan = EData.get_pplan edata
    val pnode = Prover.get_open_pnode_by_name pplan  (GoalTyp.goal_name goal)
    val hgraph_name = 
      case hgraph_nv of (GData.T_Graph _) => GData.get_nvdata_name hgraph_nv 
      | _ => raise GData.node_exp ("expect hgraph, but some other type of nvnode",hgraph_nv);
    val graph_tacs_args = GData.get_nvdata_args hgraph_nv
    val cur_name = EData.get_name_current edata |> fst
    val cur_idx =  EData.get_index_current edata
    val gt_data = EData.get_psgraph edata |> EData.PSGraph.get_goaltype_data
    val graph' = Util.del_gnode gnode_name graph
    fun set_hgraph_idx 0 b = [EData.set_bindex_current 0 b]
    | set_hgraph_idx i b = (EData.set_bindex_current i b) :: (set_hgraph_idx (i-1) b) 
    fun insert_gnode b = 
     let 
      val g0 = EData.get_bgraph b
      val (in_es, in_gtypes) = Util.input_boundary g0
        |> map (fn (_,(e,_),_) =>(e, Util.goaltype_of g0 e))
        |> (fn x => (map fst x, map snd x))
     in 
      mk_ngs_to_branch gt_data NONE in_gtypes (Seq.single([pnode], pplan))
      |> Seq.list_of
      |> map (fn (pp, res) => (EData.set_bpplan pp b , res))
      |> map (fn (b,rs) => 
         (EData.set_bgraph (add_gnodes in_es rs (EData.get_bgraph b))) b) 
     end
(*
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
*)
   in
     (* update and delete the gnode in the current graph *)
     EData.set_bgraph graph' (EData.get_current edata) 
     (* move to the subgraph and save the current grah hie in the parent *)
     |> EData.update_bparent (StrName.NTab.ins (hgraph_name, (cur_name, cur_idx)) 
        handle _ => (logging "FAILURE" "Fail to re-insert the hgraph"; raise tinker_fail true))
     |> EData.push_bcur_hie (hgraph_name, tnode)
     (* get subgraphs, for each subgraph, create a branch *)
     |> (fn b => set_hgraph_idx (EData.get_bgraphs_gen hgraph_name b |> List.length |> (fn x => x -1)) b)
     |> maps insert_gnode 
     |> Seq.of_list
   end

 fun move_upto_parent b = 
   let 
    val cur_name = EData.get_bname_current b |> fst
    val (_, idx) = StrName.NTab.get  (EData.get_bparent b) cur_name  
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
    val gt_data = edata |> EData.get_psgraph |> EData.PSGraph.get_goaltype_data
    val goal = Util.gnode_of graph gnode_name
    val pplan = EData.get_pplan edata
    val pnode = Prover.get_open_pnode_by_name pplan  (GoalTyp.goal_name goal)
    val cur_b = EData.get_current edata
    val (par_name, par_idx) = StrName.NTab.get (EData.get_parent edata) (EData.get_name_current edata |> fst)
    val parent_graph = EData.get_bgraph_gen par_name par_idx cur_b
    val parent_hgraph_node = EData.get_name_current edata |> snd
    val out_edges = Util.out_edges parent_graph parent_hgraph_node
    val out_goaltypes = map (fn e => (Util.goaltype_of parent_graph e)) out_edges
(*     fun insert_gnode b = 
     let 
      val g0 = EData.get_bgraph b
      val (in_es, in_gtypes) = Util.input_boundary g0
        |> map (fn (_,(e,_),_) =>(e, Util.goaltype_of g0 e))
        |> (fn x => (map fst x, map snd x))
     in 
      mk_ngs_to_branch b gt_data NONE in_gtypes (Seq.single([pnode], pplan))
      |> Seq.list_of
      |> map (fn (b,rs) => 
         (EData.set_bgraph (add_gnodes in_es rs (EData.get_bgraph b))) b) 
     end *)
     val new_parent_graphs_with_pplan = 
       mk_ngs_to_branch gt_data NONE out_goaltypes (Seq.single([pnode], pplan))
       |> Seq.list_of
       |> map (fn (pp,rs) => (pp, (add_gnodes out_edges rs parent_graph)))
(*
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
*)

  in
    if List.length (Util.all_gnodes (EData.get_graph edata)) > 1 (* more than one goal node *)
    then (* delete the g; add it in the parent graph; update both graph as a branch *)
      EData.set_bgraph graph' (EData.get_current edata)
      |> (fn b => 
          (map 
           (fn (pp,g) => 
             (EData.set_bgraph_gen par_name par_idx g b
             |> EData.set_bpplan pp))
           new_parent_graphs_with_pplan)) 
      |> Seq.of_list
    else (* also need to remove the current graph from the parent map, as no goal nodes in this graph *)
      EData.set_bgraph graph' (EData.get_current edata)
      |> (fn b => 
          (map 
           (fn (pp,g) => 
             (EData.set_bgraph_gen par_name par_idx g b
             |> EData.set_bpplan pp))
           new_parent_graphs_with_pplan)) 
      |> map move_upto_parent
      |> Seq.of_list
  end

 fun eval_apply_id gnode_name id_node edata =
   let
    val gt_data = edata |> EData.get_psgraph |> EData.PSGraph.get_goaltype_data
    val graph = EData.get_graph edata
    val goal = Util.gnode_of graph gnode_name
    val pplan = EData.get_pplan edata
    val pnode = Prover.get_open_pnode_by_name pplan  (GoalTyp.goal_name goal)
    val graph' = Util.del_gnode gnode_name graph
    val out_edges = Util.out_edges graph id_node
    val out_goaltypes = map (fn e => (Util.goaltype_of graph e)) out_edges
(* 
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
 *)
     val new_parent_graphs_with_pplan = 
       mk_ngs_to_branch  gt_data NONE out_goaltypes (Seq.single([pnode], pplan))
       |> Seq.list_of
       |> map (fn (pp,rs) => (pp, (add_gnodes out_edges rs graph')))

   in
    EData.set_bgraph graph' (EData.get_current edata)
      |> (fn b => 
          (map 
           (fn (pp,g) => 
             (EData.set_bgraph g b
             |> EData.set_bpplan pp))
           new_parent_graphs_with_pplan))     |> Seq.of_list
   end

 (* evaluates a single goal node *)
  fun eval_goal_gen if_debug gname graph_name0 index0 edata = 
   let
     val _ = 
      Util.gnode_of (EData.get_graph edata) gname
      |> (fn x =>  Prover.get_open_pnode_by_name (EData.get_pplan edata) (GoalTyp.goal_name x))
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
       if fst (EData.get_name_current edata)  = EData.get_main_current edata then raise Fail "ERR: main has already been terminated "
       else (* exit the current hie *) exit_hgraph gname edata
     else (* not terminated, so either apply atomic or apply hgraph*)
     (
      let      
        val tnode = get_next_tnode graph gname
        val (SOME nv) = Util.lookup_ivertex_data graph tnode
      in
        case nv of
           (GData.T_Atomic (name, _)) => 
            (debug_tracing ("apply tac " ^ name ^ " in " ^ "graph_name0"); 
            eval_apply_atomic gname tnode edata)
         | (GData.T_Identity) => 
          (debug_tracing ("apply id  in " ^ "graph_name0"); 
          eval_apply_id gname tnode edata)
         | (GData.T_Graph (name,_)) => 
          (debug_tracing ("enter hie graph " ^ name ^ " in " ^ "graph_name0"); 
            enter_hgraph gname nv tnode edata )
         | (GData.G_Break) => 
            if if_debug then raise Breakpoint edata
            else eval_apply_id gname tnode edata
         | _ => raise node_exp ("ERR: unexpected node type to apply eval ", gnode, nv)
      end
     )
  end
 
  fun eval_goal_gnodename is_debug gnode_name edata = eval_goal_gen is_debug gnode_name NONE NONE edata

  fun eval_goal_goalname is_debug gname edata = 
   let
     val graph = EData.get_graph edata
     val gnode_name = Util.all_gnodes graph
               |> filter (fn gn => gname = GoalTyp.goal_name (Util.gnode_of graph gn))
               |> (fn [x] => x) (* raise exception: log if not singleton list *)
   in
     eval_goal_gen is_debug gnode_name NONE NONE edata
   end

(**)
  end; (* end of open local graph utils *)
end (* functor *)


