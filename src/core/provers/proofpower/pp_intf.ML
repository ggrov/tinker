  
 structure PPIntf = 
  struct
  
  fun set_psg_goal (assms, goal) ps = 
    let 
      val ctxt = get_current_pc() 
    in
      Tinker.start_ieval ctxt ps assms goal 
    end
 (*    
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
         |> hd;
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
*)
(* 
  fun psgraph_auto (assms, goal) psg searchf goalf  =
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
         |> hd;
         
   in
     init_edata psg
     |> EVal.evaluate_full_one ; print_goal_state (top_goal_state()) 
   end
 
    
    fun run_psg_goal g mode psg = 
      	case mode of "auto" => psgraph_auto g psg "dummy" "dummy"	
      	| _ => set_psg_goal g mode psg "dummy" "dummy"
*)     			
 
  end (* end of struct PPIntf*)