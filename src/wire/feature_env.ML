structure FeatureEnv =
struct
 structure TF = TermFeatures;
 local open Feature in
  (* should really just use set rather than list! *)
  fun mk_const_goal_feature t =
   if StrName.NSet.is_empty (TF.constants t)
    then []
    else [(Strings (TF.constants t,"consts"))];

  fun mk_top_level t = 
    case TF.top_level_str t of 
       SOME s => [Ref (s,"top-level-const")]
     | NONE => [];

  fun simple_shape t = [Terms ([t],"shape")];

  fun get_features t =
    (mk_top_level t) @ (mk_const_goal_feature t) @ (simple_shape t)
    |> F.NSet.of_list;
    
 end (* local *)
end (* struct *)
