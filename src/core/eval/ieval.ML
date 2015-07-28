
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
    val _ = case branches of [] => logging "EVAL" "Err: No new branch is successful, backtrack" | _ => ();
    val new_branches = branches @ (EData.get_branches edata) 
   in
    case new_branches of 
      [] => Bad (* this is because tactic fails szx *)
      | (x::xs) => (* fixme: this should be based on the search strategy *)
          Cont (edata 
                |> EData.set_current x 
                |> EData.set_branches xs)
   end

  fun eval_goal0 if_debug node_name edata = 
   let 
    val graph = (EData.get_graph edata) 
    val g = EVal.EData.PSGraph.Theory.Graph_Utils.gnode_of graph (V.mk node_name) 
            |> EData.PSGraph.Theory.Data.GoalTyp.goal_name
   in
     if EVal.has_psgraph_terminated edata then Good edata
     else
     (* todo: hierichecal one *)
       EVal.eval_goal_goalname if_debug g edata
       |> Seq.list_of (* get a list of eval results *)
       (*|> map fst  map out branches *)
       |> update_branches edata
   end
   handle EVal.EData.PSGraph.Theory.Graph.no_such_vertex_exp (f, v, _) => 
      raise logging_exp ("Exception in " ^ f ^ " for node " ^ (V.string_of_name v));
  
  val eval_goal = eval_goal0 false;
(* need to restore pom depends on provers *)
  fun eval_backtrack edata = 
   case EData.get_branches edata  
   of [] => Bad
    | branch  => 
        Cont( EData.set_current (hd branch) edata 
              |> EData.set_branches (tl branch)) 

  fun eval_any0 if_debug edata = 
   let 
    val graph = (EData.get_graph edata) 
    val cur_gnodenames = EVal.EData.PSGraph.Theory.Graph_Utils.all_gnodes graph
   in
    if EVal.has_psgraph_terminated edata then Good edata
    else
    if EVal.has_current_graph_terminated edata andalso (List.null cur_gnodenames)
    then EVal.exit_hgraph_no_goal_node edata |> Seq.list_of |> update_branches edata
    else
   (* todo: hierichecal one *)
     cur_gnodenames
       |> map (EVal.EData.PSGraph.Theory.Graph_Utils.gnode_of graph)
       |> map (EVal.EData.PSGraph.Theory.GoalTyp.goal_name)
       |> (fn x => 
            (((Pretty.str "all goals in the current graph: " ::
              (map (fn y => Pretty.block [Pretty.str y, Pretty.str " "] ) x)) |> Pretty.block 
              |> Pretty.str_of |> logging "EVAL");
            x))
       |> hd(* pick the first one *)
       |> (fn g => EVal.eval_goal_goalname if_debug g edata
                       |> Seq.list_of
                       (*|> map fst*))
       |> update_branches edata
  end;
 
  val eval_any = eval_any0 false;

  fun eval_complete0 if_debug edata = 
   let val ret = eval_any0 if_debug edata in
   case ret 
   of Cont e => eval_complete0 if_debug e
    | _ => ret end;

  val eval_complete = eval_complete0 false;

  fun eval_until_graph edata graph_name  =
   let val ret = eval_any0 false edata in
   case ret of Cont e => 
    if (EData.get_name_current e) = graph_name
    then ret
    else eval_until_graph e graph_name  | _ => ret end;
   
  fun eval_step_over node_name edata =      
  let val ret = eval_goal0 false node_name edata val cur_graph_name = EData.get_name_current edata in
  case ret
    of Cont edata' => eval_until_graph edata' cur_graph_name 
    | _  => ret end

 fun eval_finish edata = 
  let val dest_graph_name = EData.get_name_current edata in
  if dest_graph_name = EData.get_main_current edata then eval_complete edata
  else(
    StrName.NTab.get (EData.get_parent edata) dest_graph_name |> fst
    |> eval_until_graph edata)
  end

 fun eval_until_break edata = eval_complete0 true edata
 handle EVal.Breakpoint e => Cont e;

(*
 fun eval_until_breakpoint
 fun eval_ignore_breakpoint 
*) 

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
                    (EData.get_name_current_hie edata) 
                    (EData.get_index_current edata) 
                    e)
           ),
      ("log_info", buffer_to_json ())
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
