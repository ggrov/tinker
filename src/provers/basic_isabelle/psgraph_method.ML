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

  fun read_graph (gname,fname) =
   let 
     val json = Json.read_file fname
     val graph = PSGraph.PSTheory.in_json json
     val psgraph = PSGraph.empty
                   |> PSGraph.set_graph graph
                   |> PSGraph.load_atomics [("atac",K atac)];
   in
     add_graph (gname,psgraph)
   end;

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


  fun ic_psgraph_tac ctxt thm = 
    let
      val (ps,pp) = init_prf ctxt thm
      val th = Proof_Context.theory_of ctxt
      val psgraph = get_graph th (Config.get ctxt psgraph)
      val edata = EVal.init_of psgraph (ps,pp) |> hd (*FIXME: only handle the first goal *)
    in
      UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end

  fun ipsgraph_tac name ctxt thm = 
    let
      val (ps,pp) = init_prf ctxt thm
      val th = Proof_Context.theory_of ctxt
      val psgraph = 
        if name = "default"
        then get_graph th (Config.get ctxt psgraph)
        else get_graph th name
      val edata = EVal.init_of psgraph (ps,pp) |> hd (* FIXME: only handle the first goal *)
    in
      UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end

  fun ipsgraph_method str ctxt =  SIMPLE_METHOD (ipsgraph_tac str ctxt);

(* a dummy tac for test use *)
  fun dummy_tac str  _ thm = 
    let val _ = if str = "dummy" then writeln "yes" else writeln "no" 
    in Seq.single thm end

  fun dummy_method str ctxt = SIMPLE_METHOD (dummy_tac str ctxt);

  val str_parser : string context_parser = (Scan.lift (Args.name));
  val opt_str_parser : string context_parser = Scan.lift (Scan.optional (Args.name) "default");

(* setup methods in isabelle *)
  val _ = Context.>> (Context.map_theory
    ((Method.setup (Binding.name "dummy") (str_parser >> dummy_method) "this is a dummy one") #> 
     (Method.setup (Binding.name "ipsgraph") (opt_str_parser >> ipsgraph_method) "interactive psgraph tactic")));

end (* structure *)
