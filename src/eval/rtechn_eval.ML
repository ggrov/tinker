
structure EvalStrat =
struct
 fun depth_first new old = [old]
   (* what about duplicates *)

 fun breadh_first new old = [old]
end

structure RTechnEval =
struct

  structure EData = EvalD_DF;

  exception evaluate_exp of V.name option * string;
  exception graph_exp of string * Strategy_Theory.Graph.T

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
    in (* fixme: find all active techniques *)
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
  
  (* termination condition for evaluation *)

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
  
  (* evaluation *)

  (* begin eval identity *)

  fun mk_eval_identity_lhs edata v = 
     v |> EvalGraph.mk_match_graph (EData.get_graph edata)
       |> Seq.of_list
       |> Seq.maps (EvalGraph.eval_var_mk_rule_aux (EData.get_graph edata))
       |> Seq.list_of;

  fun mk_eval_identity_delete_input lhs = 
    let 
      val gn_v = (case V.NSet.tryget_singleton (GraphEnv.get_goalnodes_of_graph lhs)
                    of NONE => raise graph_exp ("graph does not contain exactly 1 goalnode",lhs)
                     | SOME v => v)
      val wire = case E.NSet.tryget_singleton (Strategy_Theory.Graph.out_enames lhs gn_v)
                    of NONE => raise EvalOutput.gnode_exp ("gnode does not have single output")
                    | SOME e => GraphEnv.e_to_wire lhs e;
     in
       (GraphEnv.v_to_gnode lhs gn_v,EvalGraph.delete_inputvar_rule wire)
     end;

  fun mk_eval_identity_add_outputs edata gnode graph =
   let
     val pnode = case StrName.NTab.lookup (EData.get_goals edata) (GNode.get_goal gnode) of
                    NONE => raise EvalOutput.gnode_exp ("Goal " ^ GNode.get_goal gnode ^ " not present in pplan")
                  | (SOME pn) => pn
   in 
     EvalGraph.add_outputs gnode [pnode] edata graph
   end;

  fun mk_eval_identity_rhs edata lhs =
    let 
       val (gnode,del_rule) = mk_eval_identity_delete_input lhs
    in
      EvalGraph.rewrite del_rule lhs
      |> maps (mk_eval_identity_add_outputs edata gnode)
    end;

  fun mk_eval_identity_rule edata v =
   mk_eval_identity_lhs edata v
   |> maps (fn lhs => 
             map (fn rhs => Strategy_Theory.Rule.mk 
                              (Strategy_Theory.Graph.minimise lhs,
                               Strategy_Theory.Graph.minimise rhs)) 
                 (mk_eval_identity_rhs edata lhs));

  fun eval_identity edata v =
   mk_eval_identity_rule edata v
   |> Seq.of_list
   |> Seq.maps (fn rule => EvalGraph.rewrite_lazy rule (EData.get_graph edata))
   |> Seq.map (fn g => EData.set_graph g edata);

  (* end eval identity *)

  fun eval_merge_rule graph v = 
    let 
      val wire = case E.NSet.tryget_singleton (GraphEnv.get_out_edges graph v) of
                   NONE => raise evaluate_exp (SOME v, "Evaluation of merge: multiple outputs")
                 | SOME e => GraphEnv.edge_data graph e
      val size = E.NSet.cardinality (Strategy_Theory.Graph.in_enames graph v)
    in
      EvalGraph.mk_eval_merge_rule_of_size wire size
      (* uses !-box but gives an error: EvalGraph.mk_eval_merge_rule_of wire *)
    end;

  fun eval_merge edata v =
      EData.get_graph edata
      |> (fn g => EvalGraph.rewrite_lazy (eval_merge_rule g v) g)
      (* this is a hack: problem is one match per "non-goal edge" - for now just pick one
          but should check substitution done! *)
      |> (fn s => case Seq.pull s of (SOME (v,_)) => Seq.single v | NONE => Seq.empty)
      |> Seq.map (fn g => EData.set_graph g edata) 

  (* for now we only unfold *)
  fun one_step edata v = 
    if GraphEnv.is_gnode (EData.get_graph edata) v
     then raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    else 
      let val rt = (GraphEnv.v_to_rtechn (EData.get_graph edata) v)
     in
       if (RTechn.is_atomic rt) then EvalAtomic.eval_atomic edata v
       else if (RTechn.is_merge rt) then eval_merge edata v
       else if (RTechn.is_identity rt) then eval_identity edata v
       else if (RTechn.is_hgraph rt) then EvalNested.eval_nested eval_full (SOME (TagName.mk "unfold")) edata v
       else if (RTechn.is_or rt) then EvalNested.eval_nested eval_full (SOME (TagName.mk "or_unfold")) edata v
       else if (RTechn.is_try rt) then 
         case Seq.pull (EvalNested.eval_nested eval_full (SOME (TagName.mk "try")) edata v) of
            SOME (v,vs) => Seq.cons v vs
           | NONE => EvalNested.eval_nested eval_full (SOME (TagName.mk "else")) edata v
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     end
 
  and eval_one_restricted vs edata =
    let 
       fun get_first [] = NONE
        |  get_first (x::xs) = if (Option.isSome o Seq.pull) x then SOME x else get_first xs;
    in
      vs |> V.NSet.list_of
         |> map (one_step edata)
         |> get_first
    end  

  and eval_one edata =
    eval_one_restricted (GraphEnv.get_rtechns_of_graph (EData.get_graph edata)) edata

  (* maybe give some useful error messages? *)
  (* could also empose a search strategy... *)
  and eval_full edata = 
    case eval_one edata of
      NONE => if edata_terminated edata then (Seq.single edata) else Seq.empty
    | SOME edatas => Seq.maps eval_full edatas;
 
  fun eval_any edata =   
     GraphEnv.get_rtechns_of_graph (EData.get_graph edata)
     |> V.NSet.seq_of
     |> Seq.maps (one_step edata);

  
  (* evaluation ignoring evaluation strategy *)

 

end (* struct *)


