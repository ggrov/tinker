structure EvalTac =
struct

 structure Data = Theory_Data(struct 
    type T = Strategy_Theory.Graph.T StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception undefined_strat_exp of string;

 fun get_graph th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise undefined_strat_exp name
    | SOME v => v;

 val add_graph = Data.map o StrName.NTab.ins;
 val add_graph_list =  Data.map o (fold StrName.NTab.ins);

 val strategy = (Attrib.setup_config_string @{binding "strategy"} (K "unknown"));
 val strategy_path = (Attrib.setup_config_string @{binding "strategy_path"} (K ""));

 fun mk_goal ctxt thm =
  let 
    val goal = PNode.mk_goal ("g") ctxt ctxt thm;
    val prf = PPlan.init_prf |> PPlan.add_root goal 
  in
    PPlan.apply_init_prf prf goal thm
  end;

 fun strategy_tac' ctxt thm =
   let
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph
   in
     edata0
     |> RTechnEval.eval_full
     |> Seq.map RTechnEval.EData.get_pplan
     |> Seq.map (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm)
  end;

 fun strategy_tac ctxt thm =
   let
     val trm = Thm.prems_of thm |> hd
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_g th [trm] graph
   in
     edata0
     |> RTechnEval.eval_full
     |> Seq.map RTechnEval.EData.get_pplan
     |> Seq.map (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm |> Goal.conclude)
     |> Seq.maps (ALLGOALS (fn n => TRY (atac n)))
     |> Seq.maps (fn res => rtac res 1 thm)
  end;

 fun interactive_strategy_tac' ctxt thm =
   let
     val gs_prf = mk_goal ctxt thm
     val th = Proof_Context.theory_of ctxt
     val graph = get_graph th (Config.get ctxt strategy)
     val edata0 =  RTechnEval.init_prf th gs_prf graph
   in
     edata0
     |> GUISocket.run
     |> RTechnEval.EData.get_pplan
     |> (fn t => PPExpThm.export_name t "g" |> PPExpThm.prj_thm)
     |> Seq.single
  end;
 
  fun strategy_then_assm_tac ctxt =
    (strategy_tac' ctxt) THEN ALLGOALS (fn n => TRY (atac n));

  fun interactive_strategy_then_assm_tac ctxt =
    (interactive_strategy_tac' ctxt) THEN ALLGOALS (fn n => TRY (atac n));
        
end (* structure *)
