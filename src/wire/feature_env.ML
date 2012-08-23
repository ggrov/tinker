structure FeatureEnv =
struct
 structure TF = TermFeatures;
 local open Feature in
  (* should really just use set rather than list! *)
  fun mk_const_goal_feature t =
   let 
     val consts = TF.constants t
     fun match gnode _ = gnode
                       |> GNode.get_goal
                       |> Thm.prop_of
                       |> TF.constants
                       |> (fn cs => StrName.NSet.subset (consts,cs))
     fun sub _ f = if get_ftyp f = "consts" then 
                     case get_fdata f of
                        (Strings cs) => StrName.NSet.eq (consts,cs)
                       | _ => false 
                   else false
   in 
    default_feature 
    |> set_fdata (Strings consts);
    |> set_id "goal-consts"
    |> set_ftyp "consts"
    |> set_match match
    |> set_sub sub
  end (* fun *)
    
 end (* local *)
end (* struct *)
