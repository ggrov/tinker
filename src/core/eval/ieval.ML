
functor InteractiveEvalFun (EVal : EVAL) : IEVAL =
struct
  local open LoggingHandler in
  structure EVal= EVal
  structure EData = EVal.EData;

  datatype result = Good of EData.T | Bad | Cont of EData.T

  structure EVal= EVal
  structure EData = EVal.EData;
   
(************************************************************
  
      Evaluation options

*************************************************************)
  datatype result = Good of EData.T | Bad | Cont of EData.T

  fun update_branches edata branches = 
   let 
    val if_backtrack = 
      case branches of [] => (logging "EVAL" "Err: No new branch is successful, backtrack";true) 
                      | _ => false;
    val new_branches = branches @ (EData.get_branches edata) 
   in
    case new_branches of 
      [] => (logging "FAILURE" "Err: All branches fail";Bad) (* no more branches *)
      | (x::xs) => (* fixme: this should be based on the search strategy *)
          ((if if_backtrack then EData.PSGraph.Graph.Data.GoalTyp.Prover.restore_pplan (EData.get_bpplan x) 
            else ());
           Cont (edata 
                |> EData.set_current x 
                |> EData.set_branches xs))
   end

  fun eval_goal0 if_debug node_name edata = 
   let 
    val graph = (EData.get_graph edata) 
    val g = EVal.EData.PSGraph.Graph_Utils.gnode_of graph (V.mk node_name) 
            |> EData.PSGraph.Graph.Data.GoalTyp.goal_name
   in
     if EVal.has_psgraph_terminated edata then Good edata
     else
      (* do nothing, if reaching the top level and the current goal is on edge *)
       if EVal.is_top_level_psgraph edata andalso EVal.is_gn_on_boundary edata g 
       then Cont edata
       else
         EVal.eval_goal_goalname if_debug g edata
         |> Seq.list_of (* get a list of eval results *)
         (*|> map fst  map out branches *)
         |> update_branches edata
   end
   handle EVal.EData.PSGraph.Graph.no_such_vertex_exp (f, v) => 
     (logging "FAILURE" ("Exception in " ^ f ^ " for node " ^ (V.string_of_name v) ^ ": no such vertex");
       raise tinker_fail true)

   fun eval_any0 if_debug edata = 
   let 
    val graph = (EData.get_graph edata) 
    val cur_gnodenames = EVal.EData.PSGraph.Graph_Utils.all_gnodes graph
   in
    if EVal.has_psgraph_terminated edata then Good edata
    else
    if (*EVal.is_all_gns_on_boundary edata  andalso*) (List.null cur_gnodenames)
    then EVal.exit_hgraph_no_goal_node edata |> Seq.list_of |> update_branches edata
    else
   (* todo: hierichecal one *)
     cur_gnodenames
       |> map (EVal.EData.PSGraph.Graph_Utils.gnode_of graph)
       |> map (EVal.EData.PSGraph.Graph.Data.GoalTyp.goal_name)
       |> (fn x => 
            (((Pretty.str "all goals in the current graph: " ::
              (map (fn y => Pretty.block [Pretty.str y, Pretty.str " "] ) x)) |> Pretty.block 
              |> Pretty.unformatted_string_of |> logging "EVAL");
            x))
       |> (fn gl => (* filter out those on the edges when at the top level,shoule never reach here if the current graph is finished *)
           if EVal.is_top_level_psgraph edata 
           then (filter (fn g => (not (EVal.is_gn_on_boundary edata g)))gl) 
           else gl)
       |> hd(* pick the first one *)
       |> (fn g => EVal.eval_goal_goalname if_debug g edata
                       |> Seq.list_of
                       (*|> map fst*))
       |> update_branches edata
  end;

  val eval_goal = eval_goal0 false;
  val eval_any = eval_any0 false;

  fun eval_backtrack edata = 
   case EData.get_branches edata  
   of [] => (logging "FAILURE" "All branches fail, no branch available for backtracking" ; Bad)
    | branch  => 
        (EData.PSGraph.Graph.Data.GoalTyp.Prover.restore_pplan (EData.get_bpplan (hd branch));
        Cont( EData.set_current (hd branch) edata |> EData.set_branches (tl branch)))

  fun eval_complete0 if_debug (* if debug mode, i.e. breakpoint *) edata = 
   let val ret = eval_any0 if_debug edata in
   case ret 
   of Cont e => eval_complete0 if_debug e
    | _ => ret end
    handle tinker_fail false => 
      case eval_backtrack edata of Cont e => eval_complete0 if_debug e | x => x;

  val eval_complete = eval_complete0 false;

  fun eval_until_graph edata graph_name  =
   let val ret = eval_any0 false edata in
   case ret of Cont e => 
    if (EData.get_name_current e |> fst) = graph_name
    then ret
    else eval_until_graph e graph_name  | _ => ret end;
   
  fun eval_step_over node_name edata =      
  let val ret = eval_goal0 false node_name edata 
  val cur_graph_name = EData.get_name_current edata |> fst in
  case ret
    of Cont edata' => eval_until_graph edata' cur_graph_name 
    | _  => ret end

 fun eval_finish edata = 
  let val dest_graph_name = EData.get_name_current edata |> fst in
  if dest_graph_name = EData.get_main_current edata then eval_complete edata
  else(
    StrName.NTab.get (EData.get_parent edata) dest_graph_name |> fst
    |> eval_until_graph edata)
  end

 
 fun eval_until_break0 edata (bs : EData.branch list) = 
  let 
    fun get_ret ed = eval_complete0 true ed 
     handle EVal.Breakpoint e => Cont e
    fun debug_branches ret = 
     let 
      val (e, newbs) = 
       case ret of Good e0 => (e0, bs @ [EData.get_current e0])
       | Bad => (EData.set_branches [] edata, bs)
       | Cont e0  => (e0 , bs @ [EData.get_current e0] )
     in
      case EData.get_branches e
       of [] => 
       (* no more branches to evaluate, then restore pplan and update branches *)
       (EData.PSGraph.Graph.Data.GoalTyp.Prover.restore_pplan (EData.get_bpplan (hd newbs));
        update_branches e newbs)
       | _ => (case eval_backtrack e of Cont e0 => eval_until_break0 e0 newbs) 
     end
  in
    debug_branches (get_ret edata)
  end

 fun eval_until_break edata = eval_until_break0 edata []
  
(************************************************************
     JSON output
*************************************************************)
  fun output_json cmd args_list_json edata = 
    Json.mk_object[
      ("cmd", Json.String cmd),
      ("eval_options", args_list_json),
      ("eval_psgraph",
        EData.get_psgraph edata
        |> (fn e => EData.PSGraph.output_eval_json
                    (map fst (EData.get_name_current_hie edata))
                    (EData.get_index_current edata) 
                    e)
           ),
      ("log_info", (*buffer_to_json () |> EData.PSGraph.from_prover_json*) LH.check_perform (EData.PSGraph.from_prover_json) (buffer_to_json ()) "from_prover_json")
    ]

  fun mk_cmd_str_arg_json args_str_list = 
     Json.Array (map (fn x => Json.String x) args_str_list)

  fun output_cmd_only_json cmd  = 
    Json.mk_object[
     ("cmd",  Json.String cmd)
    ]

  fun output_string cmd args_list_json edata = 
   if (Option.isSome edata)
   then 
    output_json cmd args_list_json (Option.valOf edata) 
    |> Json.encode
   else
    output_cmd_only_json cmd 
    |> Json.encode


(* FIXME: need to check that all the goal nodes are available in the open goal,
 also this only works for the current branch *)
 fun update_psgraph x = x


  end (* end of local open *)
   structure Sharing =
   struct
     type result = result
     structure EData = EData.Sharing
   end


end (* functor *)
