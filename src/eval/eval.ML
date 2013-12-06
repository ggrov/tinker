signature EVAL =
sig


end

functor EValFun(EData : EVAL_DATA) =
struct
 structure EData = EData;
 structure EGraph = EvalGraphFun(EData);
 structure EAtom = EvalAtomicFun(EData);
 structure Theory = EData.PSGraph.PSTheory.PS_Theory;
 structure GComb = EData.PSGraph.PSTheory.PS_Comb;
 structure GoalTyp = EData.PSGraph.PSTheory.PS_GraphParam.GraphSubstData.GoalTyp;
 structure Prover = GoalTyp.Prover;

 exception evaluate_exp of V.name option * string;

 (* working with evaluation strategy *)

 (* should not be required as you should really only work on first goal node! *)
 fun delete_gnode gnode [] = []
  |  delete_gnode gnode (g::gs) = 
       if GoalTyp.gnode_eq(gnode,g) 
        then delete_gnode gnode gs
        else g::(delete_gnode gnode gs)

  val delete_gnodes = fold delete_gnode;

  (* to do : add this into contxt to allow users to 
      define their own functions, maybe more information required? *)
  fun evalf new old "breath_first" = old @ new
   |  evalf new old "depth_first" = new @ old
   |  evalf new old _ = new @ old;

 (* fixme: may loose goals! *)
 fun init_goal pnode edata  = 
   let
     val _ = DebugHandler.clear_debug_msg ();
     val graph = EData.get_graph edata
     fun to_gt e = [(e,EGraph.Util.gtyp_of graph e)] handle _ => []
     val in_edges = EGraph.Util.input_boundary graph
                  |> maps (fn (_,(e,_),_) => to_gt e)
     fun new_graph (e,gt) = 
       case GoalTyp.init_lift gt pnode of
         NONE => []
         | SOME gn => [(gn,EGraph.Util.insert_node_on_edge 
                           (EGraph.Util.mk_single_gnode gn) e graph)] 
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

 fun init psgraph ctxt goals =
   let
     val _ = DebugHandler.clear_debug_msg ();
     val (pnode,pplan) = Prover.init ctxt goals
     val pnode_tab = 
       StrName.NTab.ins
         (Prover.get_pnode_name pnode,pnode)
         StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goal pnode edata0
   end;


 fun init_of psgraph (pnds,pplan) =
   let
     val _ = DebugHandler.clear_debug_msg ();
     val pnode_tab = 
      fold 
       (fn pnode => StrName.NTab.ins (Prover.get_pnode_name pnode,pnode))
       pnds
       StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goals edata0 pnds
    |> (fn x => case x of [] => (DebugHandler.add_debug_msg (Pretty.str "Fail to init lift") ; DebugHandler.debug_err (); [])
      | _ => x)
   end;

 fun init_with_assm psgraph ctxt assms goals =
   let
     val _ = DebugHandler.clear_debug_msg ();
     val (pnode,pplan) = Prover.init_with_assm ctxt assms goals
     val pnode_tab = 
       StrName.NTab.ins
         (Prover.get_pnode_name pnode,pnode)
         StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goal pnode edata0
    |> (fn x => case x of [] => (DebugHandler.add_debug_msg (Pretty.str "Fail to init lift") ; DebugHandler.debug_err (); [])
      | _ => x)
   end;

 fun mk_atomic_rhs edata rt lhs =
    let
      val out_edges = 
        GComb.boundary_outputs lhs 
        |> map (fn (_,(x,_),_) => x)
      val out_types =  map (EGraph.Util.gtyp_of lhs) out_edges;
      val [gnode_name] = EGraph.Util.all_gnodes lhs;
      val gnode =  EGraph.Util.single_gnode_of lhs gnode_name
      val result_seq = EAtom.apply_atomic edata gnode rt out_types
      fun apply_one (edata',part) = 
           lhs |> EGraph.Util.del_gnode gnode_name
               |> EGraph.add_outs out_edges part 
               |> (fn rhs => (edata',(lhs,rhs)))
      fun apply_all (edata',[]) = (* no subgoals *)
          lhs |> EGraph.Util.del_gnode gnode_name
              |> (fn rhs => (edata',(lhs,rhs)))
              |> Seq.single      
        | apply_all (edata',parts) =
              parts
              |> map EAtom.partition_to_gnodes
              |> Seq.of_list
              |> Seq.map (fn p => apply_one (edata',p));
    in
      Seq.maps apply_all result_seq
    end

  fun eval_atomic edata v rt = 
   let
     val graph = EData.get_graph edata
     val lhs_seq = EGraph.matched_lhs (EData.get_graph edata) v
     fun upd_edata_gnode (lhs,rhs) branch = 
       let
         val left_gs = EGraph.Util.all_single_gnodes lhs
         val right_gs = EGraph.Util.all_single_gnodes rhs
         val current = EData.get_bgnodes branch
         val updated = 
           evalf right_gs 
                 (delete_gnodes left_gs current) 
                 (EData.get_evalf edata)
       in
         EData.set_bgnodes updated branch
       end
      (* delete input node(s) *)
     fun update (branch,(lhs,rhs)) =
       Seq.map (fn g => EData.set_bgraph g branch |> upd_edata_gnode (lhs,rhs))
               (EGraph.Util.rewrite_lazy (Theory.Rule.mk (lhs,rhs)) graph);
   in 
    lhs_seq 
    |> Seq.maps ((mk_atomic_rhs edata rt) o snd) 
    |> Seq.maps update 
   end; 

  val normalise_gnode = EData.update_graph EGraph.normalise_gnode;

   (* allows to step over gnodes *)
   fun try_get_out graph v =
    if EGraph.Util.is_rtechn graph v (* assume no variables *) 
     then NONE
     else 
      case EGraph.Util.out_edges graph v  of
          [] => SOME v (* output *)
       | [e] => try_get_out graph (EGraph.Util.edge_dest graph e) (* gnode or  *)
       |  _  => NONE (* many outputs (shouldn't happen) *);

   (* allows to step over gnodes *)
   fun try_get_in graph v =
    if EGraph.Util.is_rtechn graph v (* assume no variables *) 
     then NONE
     else 
      case EGraph.Util.in_edges graph v  of
          [] => SOME v (* output *)
       | [e] => try_get_in graph (EGraph.Util.edge_src graph e) (* gnode or  *)
       |  _  => NONE (* many outputs (shouldn't happen) *);

   fun has_terminated edata = 
     EGraph.Util.all_gnodes (EData.get_graph edata)
     |> forall (is_some o (try_get_out (EData.get_graph edata)));

  (* to do: set eval properties properties *)
  (* note: input gnode removed from' parent, but will be added on folding *)
  fun unfold_nested edata v rtechn unfrule = 
   let 
     val lhs_seq = EGraph.matched_lhs (EData.get_graph edata) v
     fun update_searchf branch = (* should maybe be removed for or for optimisations *)
       case RTechn.get_searchf rtechn of
         NONE => branch
        | SOME str => EData.set_bsearchf str branch; 
     fun update_evalf branch = (* should maybe be removed for or for optimisations *)
       case RTechn.get_evalf rtechn of
         NONE => branch
        | SOME str => EData.set_bevalf str branch; 
     fun rm_gnodes lhs = 
      EData.update_gnodes 
        (delete_gnodes (EGraph.Util.all_single_gnodes lhs))
     fun upd (_,lhs) = EGraph.Util.rewrite_lazy unfrule lhs
                     |> Seq.map (fn rhs => EData.push_bactive rhs lhs [] (EData.get_current (rm_gnodes lhs edata))
                                           |> update_searchf |> update_evalf)
   in
     Seq.maps upd lhs_seq
   end

  fun eval_nested edata v = 
   let 
     val rtechn = EGraph.Util.rtechn_of (EData.get_graph edata) v
     val name = rtechn
              |> RTechn.get_name
              |> RT.dest
     val unfrule = StrName.NTab.get (EData.PSGraph.get_g_tacs (EData.get_psgraph edata)) name
   in
     unfold_nested edata v rtechn unfrule 
   end

  fun eval_or edata v = 
   let 
     val rtechn = EGraph.Util.rtechn_of (EData.get_graph edata) v
     val name = rtechn
              |> RTechn.get_name
              |> RT.dest
     val unfrules = StrName.NTab.get (EData.PSGraph.get_or_tacs (EData.get_psgraph edata)) name
   in
     Seq.maps (unfold_nested edata v rtechn) (Seq.of_list unfrules)
   end;

  (* assume exact same boundary *)
  fun move_gnode from' v to' =
    let 
      val (SOME b) = try_get_out from' v
      val [edge] = EGraph.Util.in_edges to' b
      val (SOME node) = EGraph.Util.lookup_ivertex_data from' v
    in
      EGraph.Util.insert_node_on_edge node edge to'
    end

  (* assumes nested , terminated and exact same boundary *)
  fun fold_nested edata =
   let  
    val res = EData.get_graph edata |> EGraph.normalise_combine_gnodes;
    val (SOME lhs) = EData.parent_lhs edata;
    val [gnode_name] = EGraph.Util.all_gnodes lhs;
    val lhs' = EGraph.Util.del_gnode gnode_name lhs
    val out_gnodes = EGraph.Util.all_gnodes res
    val rhs = fold (move_gnode res) out_gnodes lhs'
    val rule = EGraph.Theory.Rule.mk (lhs,rhs);
    val branch = EData.pop_bactive (EData.get_current edata);
    fun upd_gnodes branch =
     let
       val gnodes = 
             evalf (EGraph.Util.all_single_gnodes res)   
                   (EData.get_bgnodes branch)
                   (EData.get_bevalf branch)
    in 
      EData.set_bgnodes gnodes branch
    end
   in (* to do: update active? *)
     EGraph.Util.rewrite_lazy rule (EData.get_bgraph branch)
     |> Seq.map (fn g => EData.set_bgraph g branch)
     |> Seq.map upd_gnodes 
   end;

  (* for evaluation *)
  fun next_tactic_vertex graph v = 
    case EGraph.Util.lookup_ivertex_data graph v of
      SOME _ => if EGraph.Util.is_rtechn graph v then SOME v else NONE
      | NONE => (case (EGraph.Util.out_edges graph v) of 
                  [] => (* output edge *) NONE
                  | [e] => next_tactic_edge graph e
                  | _ => (* should never happen *) NONE)
  and next_tactic_edge graph edge =
    next_tactic_vertex graph (EGraph.Util.edge_dest graph edge)

  (* project goal node  and call next_tactic_vertex -
      a lot of optimizations possible: store gnode for one... *)
  fun next_tactic graph node = 
    let 
      fun check_gnode v =
        GoalTyp.gnode_eq (EGraph.Util.single_gnode_of graph v,node)
        handle _ => false
      fun getvertex [] = NONE
       |  getvertex (v::vs) = 
           if check_gnode v
            then SOME v
            else getvertex vs
    in
      case getvertex (EGraph.Util.all_gnodes graph) of
         NONE => NONE
       | SOME v => next_tactic_vertex graph v
    end;
    
  fun evaluate edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) then eval_atomic edata v rt 
       else if (RTechn.is_merge rt) then raise evaluate_exp (SOME v, "merge not supported")
       else if (RTechn.is_identity rt) then raise evaluate_exp (SOME v, "identity not supported")
       else if (RTechn.is_hgraph rt) then eval_nested edata v
       else if (RTechn.is_or rt) then eval_or edata v
       else if (RTechn.is_orelse rt) then raise evaluate_exp (SOME v, "orelse not supported")
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     ;

   (* should check if it is a nested and then move goalnodes back  *)

   datatype result = Good of EData.T | Bad | Cont of EData.T

   (* to do : add this into contxt to allow users to define their own functions *)
   fun searchf new old "breath_first" = old @ new
    |  searchf new old "depth_first" = new @ old
    |  searchf new old _ = new @ old;

   fun update_branches_all edata branches =
     case Seq.list_of branches of
       [] => Bad
     | ys => (* to do: replace by search data *)(DebugHandler.debug_print DebugHandler.EVAL ("Eval number of branches: " ^ (Int.toString (length ys)));
          (case searchf ys (EData.get_branches edata) (EData.get_searchf edata) of
             [] => Bad (* should never happen *)
           | (x::xs) => (* fixme: this should be based on the search strategy *)
               Cont (edata 
                     |> EData.set_current x 
                     |> EData.set_branches xs)));

  fun update_branches_single edata branches =
     case Seq.pull branches of
       NONE => Bad
     | SOME (y,ys) => (* to do: replace by search data *)
     ((case searchf [y] (EData.get_branches edata) (EData.get_searchf edata) of
             [] => Bad (* should never happen *)
           | (x::xs) => (* fixme: this should be based on the search strategy *)
               Cont (edata 
                     |> EData.set_current x 
                     |> EData.set_branches xs)));

  val update_branches = 
    case Prover.psgraph_prover_i 
    of "isabelle" => update_branches_all
     | "proofpower" => update_branches_single
                   
   (* fixme: only normalise goal nodes for picked branched *)
   fun pick_first_branch edata [] = Bad
    |  pick_first_branch edata (x::xs) = 
         case update_branches edata x of 
           Bad => pick_first_branch edata xs
(*         | res => res; *)
         | Good res => Good (normalise_gnode res)
         | Cont res => Cont (normalise_gnode res);

   fun evaluate_backtrack edata = 
     case EData.get_branches edata  
     of [] => Bad
      | branch  => 
          Cont( EData.set_current (hd branch) edata 
                |> EData.set_branches (tl branch) 
                |> normalise_gnode) 
    
   fun evaluate_any edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> Seq.of_list
     |> Seq.maps (evaluate edata)
     |> update_branches edata

   fun get_tactic [] _ = raise evaluate_exp (NONE,"No applicable tactic")
    |  get_tactic (x::xs) edata =
         case next_tactic (EData.get_graph edata) x of
           SOME v => v
         | NONE => get_tactic xs edata;

   (* follows evaluation strategy *)
   fun evaluate_next edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     evaluate edata (get_tactic (EData.get_gnodes edata) edata)
     |> update_branches edata

   (* similar to evaluate_any, but only evaluate a single one *)
   fun evaluate_single edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> map (evaluate edata)
     |> pick_first_branch edata

   (* similar to evaluate_any, but only evaluate a single one *)
   fun evaluate_arbitrary edata =
    if has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ =>  update_branches edata (fold_nested edata))
    else
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> map (evaluate edata)
     |> pick_first_branch edata

   (* depth first search  *)
   fun evaluate_full edata = 
     case evaluate_arbitrary edata of
       Good edata' =>
         (case EData.next_branch edata' of
            NONE => [EData.get_pplan edata']
           | SOME (res,edata'') =>  (EData.get_bpplan res) :: (evaluate_full edata''))
       | Bad => 
         (case EData.next_branch edata of
            NONE => []
           | SOME (_,edata'') => evaluate_full edata'')
       | Cont edata' => evaluate_full edata';

   (* depth first search  *)
   fun evaluate_full_one edata = 
     (case evaluate_arbitrary edata of
       Good edata' => [EData.get_pplan edata']
     | Bad => (case EData.next_branch edata of
            NONE => []
           | SOME (_,edata') => evaluate_full_one (normalise_gnode edata'))
     | Cont edata' => evaluate_full_one edata')    


  (* FOR DEBUGGING PURPOSES *)

  (* should return (atomic,gnode) pairs (for given vertex) *)
  fun debug_get_gnodes_input edata v = 
     EGraph.matched_lhs (EData.get_graph edata) v
     |> Seq.list_of
     |> maps (fn (_,g) =>  EGraph.Util.all_single_gnodes g);

  fun debug_get_appf_gnode_vertex edata v =
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => []
    | SOME rt => 
       if (RTechn.is_atomic rt) 
       then (debug_get_gnodes_input edata v
             |> maps (fn g => [(rt,case (RTechn.get_appf rt) of RTechn.Appf atom => atom ,g)])) 
       else []; 

  fun debug_get_appf_gnode edata = 
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> maps (debug_get_appf_gnode_vertex edata);
 
  fun debug_apply_appf edata = 
    debug_get_appf_gnode edata
    |> Seq.of_list
    |> Seq.maps (fn (_,appf,gn) => (EAtom.apply_appf edata gn appf))
    |> Seq.list_of;


  (*
   fun debug_eval_tac_Vert edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) 
  
then eval_atomic edata v rt 
*)


(* 
  and eval_one edata =
    eval_one_restricted (GraphEnv.get_rtechns_of_graph (EData.get_graph edata)) edata

  and eval_full edata = 
    case eval_one edata of
      NONE => if edata_terminated edata then (Seq.single edata) else Seq.empty
    | SOME edatas => Seq.maps eval_full edatas;
 
  fun eval_any edata =   
     GraphEnv.get_rtechns_of_graph (EData.get_graph edata)
     |> V.NSet.seq_of
     |> Seq.maps (one_step edata);
*)


end (* functor *)


(* OLD STUFF *)

(*
  fun init_prf (th:theory) (pnds,prf) graph = 
    let
       val wset = GraphEnv.get_input_wires graph;
       val ptab = 
         fold
           (fn pnode => StrName.NTab.ins (PNode.get_name pnode,pnode))
            pnds
           (StrName.NTab.empty);
       val edata0 = EData.init_of prf graph ptab [] th;
       val ggraphs = pnds 
                   |> map (EvalOutput.lift_pnode_by_wires (EData.get_fmatch edata0) wset)
                   |> map (fn (w,g) => GraphEnv.lift_gnode g w)
       val g1 = fold GraphComb.then_g ggraphs graph;
    in 
       edata0 
       |> EData.set_graph g1
    end;

  fun init_g (th:theory) trms = 
    init_prf (th:theory) (PPlan.init_gls (Proof_Context.init_global th) trms);

  fun init_f (th:theory) trms graphf = 
    let
       val (g0,th') = graphf th
    in
      init_g th' trms g0
    end;

  fun is_terminated active_rtechns graph =
    let 
      val g' = Strategy_Theory.Graph.minimise graph
      val iedge = Strategy_Theory.Graph.get_in_edges g' #> E.NSet.list_of;
      val inode = (map (Strategy_Theory.Graph.get_edge_source g')) o iedge;
      val inodes = maps inode active_rtechns
      val check = not o (GraphEnv.is_gnode g');
    in
     forall check inodes
    end;

  fun graph_terminated graph = 
     is_terminated (V.NSet.list_of (GraphEnv.get_rtechns_of_graph graph)) graph;

  val edata_terminated = graph_terminated o EData.get_graph;
*)


