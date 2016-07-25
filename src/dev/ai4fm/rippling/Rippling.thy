theory Rippling
imports "../ai4fm_setup"  

begin
(* wrapping trm with name structure *)
  ML_file "../../../core/provers/isabelle/lib/rippling/unif_data.ML" 
  ML_file "../../../core/provers/isabelle/lib/rippling/collection.ML"   
  ML_file "../../../core/provers/isabelle/lib/rippling/pregraph.ML"  
  ML_file "../../../core/provers/isabelle/lib/rippling/rgraph.ML" 
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/paramtab.ML" 
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/trm.ML"  
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/isa_trm.ML"
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/instenv.ML"
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/typ_unify.ML"   
(* embeddings *)
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/eterm.ML"  
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/ectxt.ML" 
  ML_file "../../../core/provers/isabelle/lib/rippling/embedding/embed.ML"
(* measure and skeleton *)
  ML_file "../../../core/provers/isabelle/lib/rippling/measure_traces.ML"
  ML_file "../../../core/provers/isabelle/lib/rippling/measure.ML" 
  (*ML_file "../../../provers/isabelle/termlib/rippling/flow_measure.ML"*)
  ML_file "../../../core/provers/isabelle/lib/rippling/dsum_measure.ML" 
  (* wave rule set *)
  ML_file  "../../../core/provers/isabelle/lib/rippling/rulesets/substs.ML"
  ML_file  "../../../core/provers/isabelle/lib/induct.ML"
  ML_file  "../../../core/provers/isabelle/lib/term_fo_au.ML"  
  ML_file  "../../../core/provers/isabelle/lib/term_features.ML"  
  ML_file  "../../../core/provers/isabelle/lib//rippling/basic_ripple.ML" 

  attribute_setup wrule = {* Attrib.add_del wrule_add wrule_del *} "maintaining a list of wrules"

(* tactics for rippling *)
ML{*
(* setup auto and simp tac *)  
 val auto_tac = clarsimp_tac;
 val simp_tac = Simplifier.simp_tac;

(* setup up fertlisation*)
 val (strong_fert : Proof.context -> int -> tactic) = 
   (fn ctxt => Simplifier.asm_simp_tac ctxt);
 fun weak_fert ctxt = Simplifier.safe_asm_full_simp_tac ctxt;

(* setup up induct *)
 val (induct_tac : Proof.context -> int -> tactic)  = 
   fn _ => InductRTechn.induct_tac(* InductRTechn.induct_on_nth_var_tac 1 *);

(* setup up rippling *)
 val ripple_step = BasicRipple.ripple_subst_tac;

*}

(* goaltype for rippling *)
ML{*
 fun bool_to_cl env ret = if ret then [env] else []
 fun all_singleton [] = true
   | all_singleton [x] = (case x of [i] => true | _ => false)
   | all_singleton (x ::xs) = case x of [i] => all_singleton (xs) | _ => false

 fun inductable env pnode [] = 
  TermFeatures.is_inductable_structural 
  (Prover.get_pnode_ctxt pnode |> Proof_Context.theory_of ) 
  (Prover.get_pnode_concl pnode)
  |> bool_to_cl env
 | inductable _ _ _ = [];

 fun cl_is_f f env pnode args  = 
  let val args' = map (Clause_GT.project_terms env pnode) args in
   if all_singleton args'
   then
      f (Prover.get_pnode_ctxt pnode) (map hd args') 
      |> bool_to_cl env
   else [] end;

 fun cl2_wraper f ctxt [x,y] = f ctxt x y 
 |   cl2_wraper _ _ _ = false;
 fun cl3_wraper f ctxt [x,y,z] = f ctxt x y z
 |   cl3_wraper _ _ _ = false;

 fun measure_reduces0 env pnode [] =
  let
     val goal = Prover.get_pnode_concl pnode
     val ctxt = Prover.get_pnode_ctxt pnode
     val hyps' = map TermFeatures.fix_alls_as_var (Prover.get_pnode_hyps pnode)
     val embedd_hyp =
      filter (fn hyp => TermFeatures.ctxt_embeds ctxt hyp goal) hyps' (* use the hyp with no bindings *)
      |> hd (* only get the first embedding *)
     val wrules = BasicRipple.get_matched_wrules ctxt goal
  in
    TermFeatures.has_measure_decreasing_rules ctxt embedd_hyp wrules goal
  end
 | measure_reduces0 _ _ _ = false

 fun measure_reduces env pnode [] = measure_reduces0 env pnode [] |> bool_to_cl env
 | measure_reduces _ _ _ = [];
 fun rippled env pnode [] = measure_reduces0 env pnode [] |> not |>  bool_to_cl env
 | rippled _ _ _ = [];

 fun has_wrules env pnode [r] = 
  let val t =  Clause_GT.project_terms env pnode r in
  case t of [gtrm] => 
    (if (BasicRipple.get_matched_wrules (Prover.get_pnode_ctxt pnode) gtrm |> List.null)
    then []
    else [env])
  | _ => []
  end
  | has_wrules _ _ _ = [];
 
 fun ENV_bind _ [IsaProver.A_Trm trm, IsaProver.A_Var d] (env: IsaProver.env) : IsaProver.env list =
  [StrName.NTab.update (d, IsaProver.E_Trm trm) env]
 | ENV_bind  _ _ _ = [];

 val data = 
  Clause_GT.default_data
  |> Clause_GT.add_atomic "inductable" inductable
  |> Clause_GT.add_atomic "member_of" member_of
  |> Clause_GT.add_atomic "top_symbol" top_symbol
  |> Clause_GT.add_atomic "dest_term" dest_trm 
  |> Clause_GT.add_atomic "has_wrules" has_wrules
  |> Clause_GT.add_atomic "embeds"
    (cl_is_f (cl2_wraper TermFeatures.ctxt_embeds))
  |> Clause_GT.add_atomic "sub_term" (cl_is_f (cl2_wraper (TermFeatures.is_subterm o Proof_Context.theory_of)))
  |>  Clause_GT.add_atomic  "measure_reduced" (cl_is_f (cl3_wraper (TermFeatures.is_measure_decreased)))
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data Prover.default_ctxt "") @ x);

  val clause_def = 
  "h(Z) :- member_of(hyps,X), top_symbol(X,Z)." ^
  "hyp_embeds() :- member_of(hyps,X),embeds(X,concl)." ^
  "hyp_bck_res() :- member_of(hyps,X),sub_term(X,concl)." ^
  "match_lr (X,Y,Z) :- sub_term(Y, X)." ^
  "match_lr (X,Y,Z) :- sub_term(Z, X)." ^
  "hyp_subst() :- member_of(hyps,X),top_symbol(X,eq),dest_term(X,Y,R),dest_term(Y,_,L),match_lr(concl,L,R)." ^
  "measure_reduces(X) :- member_of(hyps,Y),embeds(Y,concl),measure_reduced(Y,X,concl)." ^
  "rippled() :- hyp_bck_res(). " ^ "rippled() :- hyp_subst()." ^
  "can_ripple(X) :- has_wrules(X), !hyp_bck_res().";

  val data =  
  data  
  |> Clause_GT.update_data_defs 
    (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);
*}

end
