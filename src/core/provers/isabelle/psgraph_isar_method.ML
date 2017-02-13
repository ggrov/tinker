structure PSGraphIsarMethod =
struct
  local open IsaProver in
    fun thm_of_pplan (pplan:pplan) = #goal pplan;
  end;

 structure Data = Theory_Data(struct 
    type T = PSGraph.T StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception no_psgraph_exp of string;
 val psgraph = (Attrib.setup_config_string @{binding "psgraph"} (K "unknown"));

 fun get_graph th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise no_psgraph_exp name
    | SOME v => v;

  val add_graph = Data.map o StrName.NTab.ins;
  val add_graph_list =  Data.map o (fold StrName.NTab.ins);

  fun tinker_tac name ctxt i st = 
  case SOME (Thm.cprem_of st i) handle THM _ => NONE of
  NONE => Seq.empty
  |SOME _ =>
    (let
      val ps = get_graph (Proof_Context.theory_of ctxt) name
    in
      Tinker.start_eval ctxt ps (IsaProver.G_THM (st,i))
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end)

  fun itinker_tac name ctxt i st = 
  case SOME (Thm.cprem_of st i) handle THM _ => NONE of
  NONE => Seq.empty
  |SOME _ =>
    (let
      val ps = get_graph (Proof_Context.theory_of ctxt) name
    in
      Tinker.start_ieval ctxt (SOME ps) (SOME []) (SOME (Thm.cprem_of st i |> Thm.term_of))
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end)

  fun tinker_method str ctxt = 
   SIMPLE_METHOD' (tinker_tac str ctxt);

  fun itinker_method str ctxt = 
   SIMPLE_METHOD' (itinker_tac str ctxt);


  val str_parser : string context_parser = (Scan.lift (Args.name)); 
  val _ = Context.>> (Context.map_theory
     (Method.setup (Binding.name "tinker") (str_parser >> tinker_method) "apply Tinker tactic"));
  val _ = Context.>> (Context.map_theory
     (Method.setup (Binding.name "itinker") (str_parser >> itinker_method) "debug tactic with the Tinker GUI"));
 
end

open PSGraphIsarMethod
