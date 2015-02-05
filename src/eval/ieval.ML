
functor InteractiveEvalFun (EVal : EVAL) =
struct
  structure EVal= EVal
  structure EData = EVal.EData;

  datatype result = Good of EData.T | Bad | Cont of EData.T

  structure EVal= EVal
  structure EData = EVal.EData;
   
(************************************************************
  
      Evaluation options

*************************************************************)
  datatype result = Good of EData.T | Bad | Cont of EData.T

  fun eval_goal node_name edata = 
   let 
    val graph = (EData.get_graph edata) 
    val g = EVal.Util.gnode_of graph (V.mk node_name) 
            |> EData.PSGraph.Theory.Data.GoalTyp.goal_name
    fun update_branches edata branches = 
      let val new_branches = branches @ (EData.get_branches edata) in
        case new_branches of 
          [] => Bad (* this is because tactic fails szx *)
          | (x::xs) => (* fixme: this should be based on the search strategy *)
              Cont (edata 
                    |> EData.set_current x 
                    |> EData.set_branches xs)
      end
    in
     if EVal.has_terminated edata then
      (case EData.parent_lhs edata of
        NONE => Good edata
        | _ => Good edata) (* fixme: this should be hie one *)
     else
     (* todo: hierichecal one *)
       EVal.eval_goal_atomic true g edata
       |> Seq.list_of (* get a list of eval results *)
       |> map fst (* map out branches *)
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
    fun update_branches edata branches = 
      let val new_branches = branches @ (EData.get_branches edata) in
        case new_branches of 
          [] => Bad (* this is because tactic fails szx *)
          | (x::xs) => (* fixme: this should be based on the search strategy *)
              Cont (edata 
                    |> EData.set_current x 
                    |> EData.set_branches xs)
      end
   in
    if EVal.has_terminated edata then
     (case EData.parent_lhs edata of
       NONE => Good edata
       | _ => Good edata) (* fixme: this should be hie one *)
    else
   (* todo: hierichecal one *)
     EVal.Util.all_gnodes graph
       |> map (EVal.Util.gnode_of graph)
       |> map (EVal.Theory.GoalTyp.goal_name)
       |> map (fn g => EVal.eval_goal_atomic true g edata
                       |> Seq.list_of
                       |> map fst)
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
        EData.get_graph edata
        |> EData.PSGraph.of_graph
        |> EData.PSGraph.output_json_as_eval_field)      
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

   structure Sharing =
   struct
     type result = result
     structure EData = EData.Sharing
   end


end (* functor *)
