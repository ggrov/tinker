  
  
  fun set_psg_goal (assms, goal) mode psg searchf goalf = 
    let
      fun set_goalf edata =
        case goalf of 
          "dummy" => edata
        | str =>  EData.set_evalf str edata
      fun set_searchf edata =
        case searchf of 
          "dummy" => edata
        | str =>  EData.set_searchf str edata
      fun init_edata psgraph = 
        EVal.init_with_assm psgraph ctxt assms goal 
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
      val (SOME edata') = edata
      val _ = PSGraph.PSTheory.write_dot ("/Users/yuhuilin/Desktop/eval_ui.dot") (EData.get_graph edata') ;
    in
      UISocket.ui_eval JsonControllerProtocol'.run_in_textstreams edata init_edata_with_graph ;
      print_goal_state (top_goal_state()) 
   end
