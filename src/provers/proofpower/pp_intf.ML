  
  val default_tacs = [("step_strip_any_tac", step_strip_tac), ("step_strip_conj", step_strip_tac), 
  		      ("step_strip_imp", step_strip_tac), ("step_assm", step_strip_tac)(*,  "super_tac", super_tac*)];
  
  fun set_psg_goal (assms, goal) mode psg searchf goalf = 
    let
      val ctxt = get_current_pc()
      fun set_goalf edata =
        case goalf of 
          "dummy" => edata
        | str =>  EData.set_evalf str edata
      fun set_searchf edata =
        case searchf of 
          "dummy" => edata
        | str =>  EData.set_searchf str edata
      fun init_edata psgraph = 
        EVal.init_with_assm (PSGraph.load_atomics default_tacs psgraph) ctxt assms goal 
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
