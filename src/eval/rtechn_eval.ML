
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

  fun init (th:theory) trms graphf = 
    let
       val (g0,th') = graphf th
       val wset = GraphEnv.get_input_wires g0;
       val (pnds,prf) = PPlan.init_gls (Proof_Context.init_global th') trms 
       val ptab = 
         fold
           (fn pnode => StrName.NTab.ins (PNode.get_name pnode,pnode))
            pnds
           (StrName.NTab.empty);
       val edata0 = EData.init_of prf g0 ptab [] th';
       val ggraphs = pnds 
                   |> map (EvalOutput.lift_pnode_by_wires (EData.get_fmatch edata0) wset)
                   |> map (fn (w,g) => GraphEnv.lift_gnode g w)
       val g1 = fold GraphComb.then_g ggraphs g0;
    in (* fixme: find all active techniques *)
       edata0 
       |> EData.set_graph g1
    end;
  
  fun eval_merge _ v = raise evaluate_exp (SOME v, "Evaluation of merge not yet supported");
  val eval_atomic = EvalAtomic.eval_atomic;
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
       if (RTechn.is_atomic rt) then eval_atomic edata v
       else if (RTechn.is_merge rt) then eval_merge edata v
       else if (RTechn.is_hgraph rt) then eval_hgraph edata v
       else if (RTechn.is_or rt) then eval_or edata v
       else if (RTechn.is_try rt) then eval_try edata v
       else raise evaluate_exp (SOME v, "Unknown reasoning technique type")
     end;

  fun eval_any edata =   
     GraphEnv.get_rtechns_of_graph (EData.get_graph edata)
     |> V.NSet.seq_of
     |> Seq.maps (one_step edata);




end (* struct *)


