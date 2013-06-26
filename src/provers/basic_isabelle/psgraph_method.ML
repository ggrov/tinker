structure PSGraphMethod =
struct

 structure Data = Theory_Data(struct 
    type T = PSGraph.T StrName.NTab.T
    val empty =  StrName.NTab.empty;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 exception no_psgraph_exp of string;
 
  fun get_graph th name =
    case StrName.NTab.lookup (Data.get th) name of 
      NONE => raise no_psgraph_exp name
    | SOME v => v;

  val add_graph = Data.map o StrName.NTab.ins;
  val add_graph_list =  Data.map o (fold StrName.NTab.ins);

  val psgraph = (Attrib.setup_config_string @{binding "psgraph"} (K "unknown"));

 local open BIsaAtomic_DB in
    fun thm_of_pplan (pplan:pplan) = #goal pplan;
    val init_prf = init_of_thm;
 end;

 fun psgraph_tac ctxt thm  =
  let 
    val (ps,pp) = init_prf ctxt thm
    val th = Proof_Context.theory_of ctxt
    val psgraph = get_graph th (Config.get ctxt psgraph)
    val get_thm_seq = Seq.of_list o map thm_of_pplan o maps (EVal.evaluate_full)
  in
   EVal.init_of psgraph (ps,pp)
   |> get_thm_seq
  end

end (* structure *)
