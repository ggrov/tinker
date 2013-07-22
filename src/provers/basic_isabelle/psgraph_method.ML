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

  fun of_graph graph = 
        PSGraph.empty
        |> PSGraph.set_graph graph
        |> PSGraph.load_atomics [("assumption",K atac)]; (* need to load more default tactics *)

  fun read_graph (gname,fname) =
   let 
     val json = Json.read_file fname
     val graph = PSGraph.PSTheory.in_json json
     val psgraph = of_graph graph
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


  fun ipsgraph_tac name ctxt thm = 
    let
      val (ps,pp) = init_prf ctxt thm
      fun init_edata psgraph = 
        EVal.init_of psgraph (ps,pp) 
        |> hd (* FIXME: only handle the first goal *);
      fun init_edata_with_graph graph = 
        of_graph graph
        |> init_edata
      val th = Proof_Context.theory_of ctxt
      val edata = 
        case name 
          of "passive" => NONE
            (* request psgraph, parse psgraph *)
          |  "default" => (get_graph th (Config.get ctxt psgraph) |> init_edata |> SOME)
          |   _ => (get_graph th name |> init_edata |> SOME)
             
    in
      UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata init_edata_with_graph
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end
  (* handle _ => raise no_psgraph_exp ("Err: no such a strategy: " ^ name))*)

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
