
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

  fun eval_goal g  edata = 
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
  fun output_json cmd  args_list_json edata = 
    Json.mk_object[
      ("cmd", 
        Json.mk_object[
           ("name", Json.String cmd),
           ("args", args_list_json)]),
      ("psgraph", 
       EData.get_psgraph edata 
       |> EData.PSGraph.output_json),
      (* FIXME: hacky *)
      ("eval_psgraph",
        EData.get_graph edata
        |> EData.PSGraph.of_graph
        |> EData.PSGraph.output_json_as_eval_field)      
    ]

  fun mk_cmd_str_arg_json args_str_list = 
     Json.Array (map (fn x => Json.String x) args_str_list)

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

  fun output_string cmd args_list_json edata = 
   if (Option.isSome edata)
   then 
    output_json cmd args_list_json (Option.valOf edata)
    |> Json.encode
    |> (fn x => x ^ " \n")
   else
    output_cmd_only_json cmd args_list_json
    |> Json.encode
    |> (fn x => x ^ " \n")

(* Theory.Graph.normalise *)

(*
 val step_into : V.name option -> EData.T -> EData.T
 val step_over : V.name option -> EData.T -> EData.T
 val backtrack : EData.T -> EData.T 
 val complete : EData.T -> EData.T  *)

   structure Sharing =
   struct
     type result = result
     structure EData = EData.Sharing
   end


end (* functor *)
