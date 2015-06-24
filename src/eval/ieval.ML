
functor InteractiveEvalFun (EVal : EVAL) =
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

  fun eval_goal node_name edata = 
   let 
    val graph = (EData.get_graph edata) 
    val g = EVal.EData.PSGraph.Theory.Graph_Utils.gnode_of graph (V.mk node_name) 
            |> EData.PSGraph.Theory.Data.GoalTyp.goal_name
   in
     if EVal.has_psgraph_terminated edata then Good edata
     else
     (* todo: hierichecal one *)
       EVal.eval_goal_goalname true g edata
       |> Seq.list_of (* get a list of eval results *)
       (*|> map fst  map out branches *)
       |> update_branches edata
   end

 fun eval_backtrack edata = 
   case EData.get_branches edata  
   of [] => Bad
    | branch  => 
        Cont( EData.set_current (hd branch) edata 
              |> EData.set_branches (tl branch)) 

  fun eval_any edata = 
   let 
    val graph = (EData.get_graph edata) 
    val cur_gnodenames = EVal.EData.PSGraph.Theory.Graph_Utils.all_gnodes graph
   in
    if EVal.has_psgraph_terminated edata then Good edata
    else
    if EVal.has_current_graph_terminated edata andalso (List.null cur_gnodenames)
    then EVal.exit_hgraph_no_goal_node edata |> Seq.list_of |>update_branches edata
    else
   (* todo: hierichecal one *)
     cur_gnodenames
       |> map (EVal.EData.PSGraph.Theory.Graph_Utils.gnode_of graph)
       |> map (EVal.EData.PSGraph.Theory.GoalTyp.goal_name)
       |> (fn x => 
            (((Pretty.str "[[- all goals in the current graph: " ::
              (map (fn y => Pretty.block [Pretty.str y, Pretty.str " "] ) x)) |> Pretty.block 
              |> Pretty.str_of |> logging "EVAL");
            x))
       |> map (fn g => EVal.eval_goal_goalname true g edata
                       |> Seq.list_of
                       (*|> map fst*))
       |> List.concat
       |> update_branches edata
  end;


(************************************************************
  
     JSON output

*************************************************************)
  fun output_json cmd args_list_json edata ps = 
    Json.mk_object[
      ("cmd", 
        Json.mk_object[
           ("name", Json.String cmd),
           ("args", args_list_json)]),
      ("psgraph", 
       (* FIXME: very hacky, do not get psgrapph from edata, as this one contains the goal node *)
       (case ps of (SOME ps0) => EData.PSGraph.output_json ps0
       | NONE => Json.Null)
       (*EData.get_psgraph edata 
       |> EData.PSGraph.output_json*)),
      ("eval_psgraph",
        EData.get_psgraph edata
        |> (fn e => EData.PSGraph.output_json_as_eval_field 
                    (EData.get_name_current_hie edata) 
                    (EData.get_index_current edata) 
                    e)
           )      
    ]

  fun mk_cmd_str_arg_json args_str_list = 
     Json.Array[Json.Array (map (fn x => Json.String x) args_str_list)]

  fun output_cmd_only_json cmd args_list_json = 
    Json.mk_object[
     ("cmd", 
           Json.mk_object[
           ("name", Json.String cmd),
           ("args", args_list_json)]),     
      ("psgraph", Json.Null),
      (* FIXME: hacky *)
      ("eval_psgraph", Json.Null)      
    ]

  fun output_string cmd args_list_json edata ps = 
   if (Option.isSome edata)
   then 
    output_json cmd args_list_json (Option.valOf edata) ps
    |> Json.encode
   else
    output_cmd_only_json cmd args_list_json
    |> Json.encode

(* Theory.Graph.normalise *)

(*
 val step_into : V.name option -> EData.T -> EData.T
 val step_over : V.name option -> EData.T -> EData.T
 val backtrack : EData.T -> EData.T 
 val complete : EData.T -> EData.T  *)
(* FIXME: to be implmented *)
 fun update_graph x = x
 fun eval_step_into _ _ = Bad
 fun eval_step_over _ _ = Bad

  end (* end of local open *)
   structure Sharing =
   struct
     type result = result
     structure EData = EData.Sharing
   end


end (* functor *)
