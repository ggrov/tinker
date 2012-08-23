structure FeatureEnv =
struct
 structure TF = TermFeatures;
 local open Feature in
  (* should really just use set rather than list! *)
  fun mk_const_feature t = 
   TF.constants t;
 
    
 end (* local *)
end (* struct *)
