theory test                                                 
imports         
  Main        
  "../../build/PPlan"                                                                    
  "../../build/HOL_IsaP" (* needed for induction stuff *)
uses
  "../features/term_fo_au.ML"  
  "../features/term_features.ML"      
  "../features/feature.ML"               
  "../features/feature_util.ML"     
  "../features/bwire.ML" 
  "../features/gnode.ML"
  "../features/rel_feature.ML"                                        
  "../features/full_wire.ML" 
  "../features/goal_node.ML"                                                                                                                                        
begin




ML{* 

val w1features =
F.NSet.empty
|> F.NSet.ins_fresh (FeatureUtil.name_feature_all "test1")
|> F.NSet.ins_fresh (FeatureUtil.single_const_feature "forall");

val w1 = 
BWire.default_wire
|> BWire.set_name (SStrName.mk "w1")
|> BWire.set_pos w1features;

val w2features =
F.NSet.empty
|> F.NSet.ins_fresh (FeatureUtil.name_feature_all "test1");

val w2 = 
BWire.default_wire
|> BWire.set_name (SStrName.mk "w2")
|> BWire.set_pos w2features;

BWire.sub_wire @{theory} w2 w1;
*}

(* shape feature *)

ML{*
val t1 = @{term "\<forall> x. A x \<and> B"} |> Logic.varify_global;
val t2 = @{term "\<forall> x. A \<and> (B \<or> C)"} |> Logic.varify_global;

val f1 = FeatureUtil.shape_feature ("and",t1);
val f2 = FeatureUtil.shape_feature ("andor",t2);

Feature.subfeature_of @{theory} f1 f2;

*}



(*
  For reasoning state - make a file in feature dir!!

*)
 


(* of shape - note this is normal HO matching, if we want to use special anti-unification
    then a different matcher is required  *)
ML{*
fun match_shape rst shape g = 
  let
    (* FIXME: varified or not? should we use instantiation environment? *)
    val t = PPlan.get_varified_ltrm (RState.get_pplan rst) g |> Logic.unvarify_global 
    val th = (RState.get_ctxt rst) |> ProofContext.theory_of
  in
    Pattern.matches th (shape,t)
  end;
*}

ML{*
fun has_shape rst shape g = 
  let
    (* FIXME: varified or not? should we use instantiation environment? *)
    val t = PPlan.get_varified_ltrm (RState.get_pplan rst) g |> Logic.unvarify_global 
    val th = (RState.get_ctxt rst) |> ProofContext.theory_of
    fun match st =  Pattern.matches th (shape,st)
  in
   Term.exists_subterm match t
  end;
*}


(* embedding *)
ML{*
fun embeds rst t1 t2 =
  let
   val ienv = rst |> RState.get_pplan |> PPlan.get_ienv;
   val emb_ext = Embed.Ectxt.init ienv ParamRGraph.empty
   fun is_empty_seq ss = case Seq.pull ss of NONE => true | _ => false;
  in 
    Embed.embed emb_ext t1 t2 |> is_empty_seq
  end
*}


(* generalise type *)

(* generalise sort if different *) 
ML{*

*}

(* generalise type *)
ML{*

*}

ML{*
val t1 = @{term "t1::nat"};
val t2 = @{term "t2::nat"};
val t2b = @{term "t2"};
val t3 = @{term "0::nat"};


FirstOrderAU.generalise (@{term "t1::nat"}, @{term "t2::nat"})
*}

end



