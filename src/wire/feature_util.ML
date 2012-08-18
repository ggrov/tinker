signature FEATURE_UTIL =
sig

end (* sig *)

(* for this to work we need to put values in the context!! *)
structure FeatureUtil =
struct
  local open Feature in

  fun th_rstate rst = RState.get_ctxt rst |> Proof_Context.theory_of;

  fun get_term rst g = (* will this also give assumptions?? *)
    PPlan.get_varified_ltrm (RState.get_pplan rst) g |> Logic.unvarify_global; 

  fun single_const_gen str _ f = 
    if get_ftyp f = "constant" 
      then (case get_fdata f of Strings [fs] => str = fs | _ => false)
      else false;

  fun single_const_feature str = Feature {
     id = str,
     ftyp = "constant",
     fdata = Strings [str],
     matches = (fn rst => fn g => get_term rst g |> TermFeatures.has_constant str),
     is_subfeature = single_const_gen str
     (* subsumes = single_const_gen str *)
   }

   (* should check for single element? *)
   fun const_min_times_gen (str,times) _ f = 
    if get_ftyp f = "constant_min_times" 
      then (case get_fdata f of
         StrCount tab => 
             times <= TermFeatures.get_numconstants_table str tab
        | _ =>  false)
      else false;

   (* should check for single element? *)     
 (*  fun const_min_times_sub (str,times) f = 
    if get_ftyp f = "constant_min_times" 
      then (case get_fdata f of
         StrCount tab => 
             TermFeatures.get_numconstants_table str tab <= times
        | _ =>  false)
      else false; *)

  fun more_than_const_feature (str,times) = Feature {
     id = str,
     ftyp = "constant_min_times",
     fdata = StrCount (StrTable.empty |> StrTable.update (str,times)),
     matches = (fn rst => fn g => get_term rst g |> TermFeatures.has_constant_min_times (str,times)),
     is_subfeature = const_min_times_gen (str,times)
    (*  subsumes = const_min_times_sub (str,times) *)
   }

  (* used to just separate two wires without meaning (need to think this through),
      e.g. as an or box introducing branching *)
  (* fixme: should really be used with additional info in context *)
  fun name_feature_all name = Feature {
     id = name,
     ftyp = "name",
     fdata = NoData,
     matches = K (K true),
     is_subfeature = K (fn f => get_ftyp f = "name" andalso get_id f = name)
     (* subsumes = (fn f => get_ftyp f = "name" andalso get_id f = name) *)
   }

  fun get_single_term f = 
    case get_fdata f of 
      Terms [t] => SOME t
    | _ => NONE;

  fun shape_feature (name,shape) =  
   let
    fun match rst g = Pattern.matches (th_rstate rst) (shape,(get_term rst g));
    (* is this right? just matching? *)
    fun subfeat th ft = case get_single_term ft of
      NONE => false
     | SOME t => Pattern.matches th (shape,t);
   in 
    Feature {
     id = name,
     ftyp = "shape",
     fdata = Terms [shape],
     matches = match,
     is_subfeature = subfeat}
  end;
 
  
 end (* local *)
end (* struct *)

structure F = NameFun(structure Namer = Feature val default_name = Feature.default_feature);


