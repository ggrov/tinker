signature INTERACTIVE_EVAL = 
sig
end

functor InteractiveEvalFun(EVal : EVAL) =
struct
   structure EData = EVal.EData;
   
   

(************************************************************
  
      Evaluation Steps (maybe move to ieval)

*************************************************************)


 datatype result = Good of EData.T | Bad | Cont of EData.T

  fun eval_any edata = 
   let 
    val graph = (EData.get_graph edata) 
    fun update_branches edata branches = 
      let val new_branches = branches @ (EData.get_branches edata) in
        case new_branches of 
          [] => Bad (* should never happen *)
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

(* Theory.Graph.normalise *)
end (* functor *)
