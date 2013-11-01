  
 structure PPIntf = 
  struct
  
   val (default_tacs : (string * TACTIC) list Unsynchronized.ref) = Unsynchronized.ref [("step_strip_any_tac", step_strip_tac), ("step_strip_conj", step_strip_tac), 
   		      ("step_strip_imp", step_strip_tac), ("step_assm", step_strip_tac)];

   fun add_default_tacs ntacs = default_tacs := (!default_tacs) @ ntacs;
   
   fun print_default_tacs _ = 
     map (fn x => Pretty.str (fst x)) (!default_tacs) 
     |> (fn x => [Pretty.str "{-------- default tactic names"] @ x @ [Pretty.str "----------------}"] |> Pretty.chunks)
     |> Pretty.string_of
     |> DebugHandler.debug_print DebugHandler.TACTIC;
  
   fun set_psg_goal (assms, goal) mode psg searchf goalf = 
     let
       val ctxt = get_current_pc()
       fun set_goalf edata =
         case goalf of 
           "dummy" => edata
         | str =>  EData.set_evalf str edata
       fun  set_searchf edata =
         case searchf of 
           "dummy" => edata
         | str =>  EData.set_searchf str edata
       fun init_edata psgraph = 
         EVal.init_with_assm (PSGraph.load_atomics (!default_tacs) psgraph) ctxt assms goal 
         |> map (set_goalf o set_searchf)
         |> hd (* FIXME: only handle the first branch *);
       fun init_edata_with_graph graph = 
         PSGraph.empty
         |> PSGraph.set_graph graph 
         |> init_edata
       val edata = 
         case mode
           of "current" => NONE
           |  _  => init_edata psg |> SOME
     in
       UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata init_edata_with_graph ;
       print_goal_state (top_goal_state()) 
    end
  end (* end of struct PPIntf*)
