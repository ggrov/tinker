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
 structure Atomic = GoalTyp.Atomic;

 exception evaluate_exp of V.name option * string;

 (* fixme: may loose goals! *)
 fun init_goal pnode edata  = 
   let
     val graph = EData.get_graph edata
     fun to_gt e = [(e,EGraph.Util.gtyp_of graph e)] handle _ => []
     val in_edges = EGraph.Util.input_boundary graph
                  |> maps (fn (_,(e,_),_) => to_gt e)
     fun new_graph (e,gt) = 
       case GoalTyp.init_lift gt pnode of
         NONE => []
         | SOME gn => [EGraph.Util.insert_node_on_edge 
                           (EGraph.Util.mk_single_gnode gn) e graph] 
     val new_graphs = maps new_graph in_edges
   in
       map (fn g => EData.set_graph g edata) new_graphs
   end;

 fun init_goals edata pnodes = 
   fold (fn pnode => fn edatas => maps (init_goal pnode) edatas)
        pnodes
        [edata];

 fun init psgraph ctxt goals =
   let
     val (pnode,pplan) = Atomic.init ctxt goals
     val pnode_tab = 
       StrName.NTab.ins
         (Atomic.get_pnode_name pnode,pnode)
         StrName.NTab.empty;
     val edata0 = EData.init psgraph pplan pnode_tab []
   in
    init_goal pnode edata0
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
     fun update (edata,(lhs,rhs)) =
       Seq.map (fn g => EData.set_graph g edata)
               (EGraph.Util.rewrite_lazy (Theory.Rule.mk (lhs,rhs)) graph);
   in 
    lhs_seq 
    |> Seq.maps ((mk_atomic_rhs edata rt) o snd) 
    |> Seq.maps update 
   end;   

  (* for now we only unfold *)
  fun evaluate edata v = 
    case EGraph.Util.lookup_rtechn (EData.get_graph edata) v of
      NONE => raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    | SOME rt =>
       if (RTechn.is_atomic rt) then eval_atomic edata v rt 
       else if (RTechn.is_merge rt) then raise evaluate_exp (SOME v, "merge not supported")
       else if (RTechn.is_identity rt) then raise evaluate_exp (SOME v, "identity not supported")
       else if (RTechn.is_hgraph rt) then raise evaluate_exp (SOME v, "hierarchies not supported")
       else if (RTechn.is_or rt) then raise evaluate_exp (SOME v, "or not supported")
       else if (RTechn.is_orelse rt) then raise evaluate_exp (SOME v, "orelse not supported")
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     ;

   fun evaluate_any edata =
     EGraph.Util.all_rtechns (EData.get_graph edata)
     |> Seq.of_list
     |> Seq.maps (evaluate edata);

  val normalise_gnode = EData.update_graph EGraph.normalise_gnode;

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


