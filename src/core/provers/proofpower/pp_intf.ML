  
 structure PPIntf = 
  struct
  
  fun set_psg_goal g ps_opt = 
    let 
      val (assms, goal) = case g of NONE => (NONE, NONE) | SOME (x, y) => (SOME x, SOME y)
      val ctxt = get_current_pc() 
    in
      Tinker.start_ieval ctxt ps_opt assms goal 
    end
    
  fun apply_ps_i ps = set_psg_goal (SOME ([], %<%false%>%)) (SOME ps) (* use a dummy goal to represnet a mode to use the current goal *)
  fun apply_ps ps = Tinker.start_eval (get_current_pc()) ps (PPProver.G_TERM([], %<%false%>%))

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
	