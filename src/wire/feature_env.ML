
structure FeatureData = Theory_Data(
  type T = (Feature.T -> Proof.context -> Thm.thm -> bool) StrName.NTab.T
  val empty = StrName.NTab.empty
  val extend = I
  fun merge (f1,f2) = StrName.NTab.merge_disjoint f1 f2);

structure Feature_Ctxt =
struct
  fun ins_tab (n,f) = StrName.NTab.ins (n,f)
  fun try_ins_tab (n,f) tab = case StrName.NTab.try_ins (n,f) tab of
       NONE => tab | SOME tab' => tab';
  val get = StrName.NTab.lookup o FeatureData.get;
  fun try_add nf = FeatureData.map (ins_tab nf)
  fun add nf = FeatureData.map (ins_tab nf)
  fun add_list f = FeatureData.map (fold ins_tab f);
  fun del fname = FeatureData.map (StrName.NTab.delete fname);
end;

structure FeatureEnv =
struct
  exception feature_typ_exp of Feature.T * string

  structure TF = TermFeatures;

 local open Feature in
  (* should really just use set rather than list! *)
  fun mk_const_goal_feature t =
   if StrName.NSet.is_empty (TF.constants t)
    then []
    else [(Strings (TF.constants t,"consts"))];

  fun fmatch_const (Strings (strs,"consts")) (_: Proof.context) thm = 
       let 
        val gstrs = thm 
                  |> Thm.prop_of
                  |> TF.constants
       in
         StrName.NSet.forall (fn t => StrName.NSet.contains gstrs t) strs
       end
   | fmatch_const f _ _ = 
      if get_fdata f = "consts"
       then raise feature_typ_exp (f,"consts has to be with Strings")
       else raise feature_typ_exp (f,"wrong feature type with consts");

  fun mk_top_level t = 
    case TF.top_level_str t of 
       SOME s => [Strings (StrName.NSet.single s,"top-level-const")]
     | NONE => [];

  fun fmatch_top_level (Strings (str,"top-level-const")) (_: Proof.context) thm = 
         (case TF.top_level_str (Thm.prop_of thm) of
            NONE => false
          | (SOME s) => StrName.NSet.contains str s)
   | fmatch_top_level f _ _ = 
      if get_fdata f = "top-level-const"
       then raise feature_typ_exp (f,"consts has to be with Ref")
       else raise feature_typ_exp (f,"wrong feature type with top-level-const");

  fun simple_shape t = [Terms ([t],"shape")];

  (* generalise to one of many shapes *)
  fun fmatch_simple_shape (Terms (ts,"shape")) (ctxt: Proof.context) thm = 
        exists (fn t => TF.is_shape (Proof_Context.theory_of ctxt) t (Thm.prop_of thm))
               ts
   | fmatch_simple_shape f _ _ = 
      if get_fdata f = "shape"
       then raise feature_typ_exp (f,"shape has to be with Terms")
       else raise feature_typ_exp (f,"wrong feature type with shape");

  fun get_features t =
   
     (mk_top_level t) 
      @  (mk_const_goal_feature t)
       (* dangling bounds existing.. needs to be turned into variables... *)
       (* @ (simple_shape t) *)
    |> F.NSet.of_list;

 (* add relevant features to context *)
 val setup =
   Feature_Ctxt.try_add ("top-level-const",fmatch_top_level)
   #> Feature_Ctxt.try_add ("consts",fmatch_const)
   #> Feature_Ctxt.try_add ("shape",fmatch_simple_shape);


    
 end (* local *)
end (* struct *)
