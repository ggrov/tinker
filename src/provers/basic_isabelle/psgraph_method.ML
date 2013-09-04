structure PSGraphMethod =
struct
  (* Tactics *)

  val default_tacs = 
    [("assumption",K atac),("atac",K atac), (* assumption *)
     ("simp",Simplifier.simp_tac o Simplifier.simpset_of), (* simp *) 
     ("clarsimp",clarsimp_tac), (* clarsimp *)
     ("all",K (K all_tac)), (* always succeeds *)
     ("no",K (K all_tac)) (* always fails *)
    ];

 structure TacticData = Theory_Data(struct 
    type T = (Proof.context -> int -> tactic) StrName.NTab.T
    val empty =  StrName.NTab.of_list default_tacs;
    val extend = I;
    fun merge (m1,_) = m1; (* or fail? *)
  end);

 val add_tac = TacticData.map o StrName.NTab.ins;
 val get_tacs = TacticData.get;

 (* Graphs *)

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

  fun add_tacs th =
   PSGraph.update_atomics 
     (StrName.NTab.merge_joint  
       (K false) (* ignores equality *)
       (get_tacs th));

  fun of_graph th graph = 
        PSGraph.empty
        |> PSGraph.set_graph graph
        |> add_tacs th (* loads tactics in theory *)

  fun read_graph (gname,fname) th =
   let 
     val json = Json.read_file fname
     val graph = PSGraph.PSTheory.in_json json
     val psgraph = of_graph th graph 
   in
      add_graph (gname,psgraph) th
   end;

  val psgraph = (Attrib.setup_config_string @{binding "psgraph"} (K "unknown"));
  
  local open IsaProver in
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
      val th = Proof_Context.theory_of ctxt
      fun init_edata psgraph = 
        EVal.init_of psgraph (ps,pp) 
        |> hd (* FIXME: only handle the first goal *);
      fun init_edata_with_graph graph = 
        of_graph th graph
        |> init_edata
      val edata = 
        case name 
          of "current" => NONE
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

  fun psgraph_tac' ((name, goalf), searchf) ctxt thm  =
   let 
     (*val _ = tracing (goalf ^ " & " ^ searchf^" in psgraph")*)
     val (ps,pp) = init_prf ctxt thm
     val th = Proof_Context.theory_of ctxt
     val psgraph = 
       case name 
        of "default" 
          => get_graph th (Config.get ctxt psgraph)
        | _ => get_graph th name
      fun set_goalf edata =
        case goalf of 
          "dummy" => edata
        | str =>  EData.set_evalf str edata
      fun set_searchf edata =
        case searchf of 
          "dummy" => edata
        | str =>  EData.set_searchf str edata
     (* to do: very slow so no backtracking! *)
     val get_thm_seq = Seq.of_list o map thm_of_pplan o maps (EVal.evaluate_full_one)
   in
     EVal.init_of psgraph (ps,pp)
     |> map (set_goalf o set_searchf)
     |> get_thm_seq
   end
 
  (* to do: check that goalf and searchf are defined *)
  fun ipsgraph_tac'  (((mode, name), goalf), searchf) ctxt thm = 
    let
      (*val _ = tracing (eval ^ " & " ^ search ^ "in ipsgraph")*)
      val (ps,pp) = init_prf ctxt thm
      val th = Proof_Context.theory_of ctxt
      fun set_goalf edata =
        case goalf of 
          "dummy" => edata
        | str =>  EData.set_evalf str edata
      fun set_searchf edata =
        case searchf of 
          "dummy" => edata
        | str =>  EData.set_searchf str edata
      fun init_edata psgraph = 
        EVal.init_of psgraph (ps,pp) 
        |> map (set_goalf o set_searchf)
        |> hd (* FIXME: only handle the first branch *);
      fun init_edata_with_graph graph = 
        of_graph th graph
        |> init_edata
      val edata = 
        case (mode,name) 
          of ("current", _) => NONE
            (* request psgraph, parse psgraph *)
          |  (_, "default") => (get_graph th (Config.get ctxt psgraph) |> init_edata |> SOME)
          |  _  => (get_graph th name |> init_edata |> SOME)
             
    in
      UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata init_edata_with_graph
      |> EVal.EData.get_pplan 
      |> thm_of_pplan 
      |> Seq.single
   end
   
  fun full_psgraph_tac (((mode, name), goalf), searchf)= 
    case mode
    of "auto" => psgraph_tac' ((name, goalf), searchf)
    | _  => ipsgraph_tac' (((mode, name), goalf), searchf)

  fun full_psgraph_method arg ctxt =  SIMPLE_METHOD (full_psgraph_tac arg ctxt);

(* a dummy tac for test use *)
  fun dummy_tac str  _ thm = 
    let val _ = if str = "dummy" then writeln "yes" else writeln "no" 
    in Seq.single thm end

  fun dummy_method str ctxt = SIMPLE_METHOD (dummy_tac str ctxt);

  val str_parser : string context_parser = (Scan.lift (Args.name));
  val opt_str_parser : string context_parser = Scan.lift (Scan.optional (Args.name) "default");

  val mode_str_parser: (string * string) context_parser = 
    Scan.lift (
      (fn m => (Args.$$$ "(" |-- Args.$$$ "current" --|  Args.$$$ ")") m 
            |> (fn x => ( (fst x, "dummy"), snd x)))
      || (Args.$$$ "(" |-- Args.$$$ "interactive" --|  Args.$$$ ")" -- Scan.optional Args.name "default") 
      || (fn m => Scan.optional Args.name "default" m
          |> (fn x => ( ("auto", fst x), snd x))
      ));

  val args_str_parser: (((string * string) * string) * string) context_parser = 
    Scan.lift (
      ((fn m => (Args.$$$ "(" |-- Args.$$$ "current" --|  Args.$$$ ")") m 
            |> (fn x => ( (fst x, "dummy"), snd x)))
      || (Args.$$$ "(" |-- Args.$$$ "interactive" --|  Args.$$$ ")" -- Scan.optional Args.name "default") 
      || (fn m => Scan.optional Args.name "default" m
          |> (fn x => ( ("auto", fst x), snd x))))
      -- Scan.optional (Args.$$$ "searchf" -- Args.$$$ ":" |-- Args.name) "dummy_searchf"
      -- Scan.optional (Args.$$$ "goalf" -- Args.$$$ ":"  |-- Args.name) "dummy_goalf"
      );

(* setup methods in isabelle *)
  val _ = Context.>> (Context.map_theory
    ((Method.setup (Binding.name "dummy") (str_parser >> dummy_method) "this is a dummy one") #> 
     (Method.setup (Binding.name "ipsgraph") (opt_str_parser >> ipsgraph_method) "interactive psgraph tactic")#>
     (Method.setup (Binding.name "psgraph") (args_str_parser >> full_psgraph_method) "full psgraph tactic")));

end (* structure *)
