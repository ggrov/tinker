
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

  fun eval_rule edata v rule = rule;
  (*
     let 
         val g' = unfold graph rule
         -- not sure if I need renaming here!
         val active = V(g') - V (g)
         
  
  *)

  (* should be trivial *)
  fun eval_merge _ v = raise evaluate_exp (SOME v, "Evaluation of merge not yet supported");
  fun eval_hgraph _ v = raise evaluate_exp (SOME v, "Evaluation of hierarchies not yet supported");
  fun eval_or _ v = raise evaluate_exp (SOME v, "Evaluation of OR not yet supported");
  fun eval_try _ v = raise evaluate_exp (SOME v, "Evaluation of TRY_ORELSE not yet supported");

  (* for now we only unfold *)
  fun one_step edata v = 
    if GraphEnv.is_gnode (EData.get_graph edata) v
     then raise evaluate_exp (SOME v, "Vertex not a reasoning technique")
    else 
      let val rt = (GraphEnv.v_to_rtechn (EData.get_graph edata) v)
     in
       if (RTechn.is_atomic rt) then EvalAtomic.eval_atomic edata v
       else if (RTechn.is_merge rt) then eval_merge edata v
       else if (RTechn.is_hgraph rt) then
           (* need an evaluation stack!
              unfold hgraph |> eval only hgraph |> fold in hgraph *)
           eval_hgraph edata v
       else if (RTechn.is_or rt) then eval_or edata v
       else if (RTechn.is_try rt) then eval_try edata v
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     end;

  fun eval_any edata =   
     GraphEnv.get_rtechns_of_graph (EData.get_graph edata)
     |> V.NSet.seq_of
     |> Seq.maps (one_step edata);

  
  (* evaluation ignoring evaluation strategy *)

  fun eval_one_restricted vs edata =
    let 
       fun get_first [] = NONE
        |  get_first (x::xs) = if (Option.isSome o Seq.pull) x then SOME x else get_first xs;
    in
      vs |> V.NSet.list_of
         |> map (one_step edata)
         |> get_first
    end;  

  fun eval_one edata =
    eval_one_restricted (GraphEnv.get_rtechns_of_graph (EData.get_graph edata)) edata;

  (* maybe give some useful error messages? *)
  (* could also empose a search strategy... *)
  fun eval_full edata = 
    case eval_one edata of
      NONE => if edata_terminated edata then (Seq.single edata) else Seq.empty
    | SOME edatas => Seq.maps eval_full edatas;  

end (* struct *)


