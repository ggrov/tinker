
(****************************************************)
(* some required definitions in 083 and 067 *)
fun all_µ_intro1 (pat_vars : TERM list) (tm : TERM) (thm : THM) : THM = (
  let val fvs = frees tm diff pat_vars;
    val bvs = thm_frees thm diff fvs;
  in  list_µ_intro bvs thm
  end
);

val continuity_fact_thms : THM list = [
  product_topology_thm,
  _space_t_product_thm,
  fst_continuous_thm,
  snd_continuous_thm,
  i_continuous_thm,
  k_continuous_thm,
  pair_continuous_thm,
  o_continuous_thm];

val continuity_pats = {
  object_pat = ¬(Á, Á  Topology)®,
  unary_pat = ¬(x, x  (Á, Â) Continuous)®,
  binary_pat = ¬(x, Uncurry x  (Á, Â) Continuous)®,
  parametrized_pat = ¬(h, (Ì x· h x p)  (Á, Â) Continuous)®};

val fst_snd : TERM list = [¬Fst®,  ¬Snd®];

val product_t_const : TERM = ¬$¸‰T®;

val continuity_params = morphism_params
    continuity_pats
    fst_snd
    [([], product_t_const)]
    ¶_object_by_type_tac
    continuity_fact_thms;


(***************************************************
(* definition of tactic *)
val i_conv = simple_eq_match_conv i_rule_thm;
val k_conv = simple_eq_match_conv k_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;

val simp_conv = simple_eq_match_conv o_i_rule_thm;
val pair_conv = simple_ho_eq_match_conv pair_rule_thm;
*)


(****************************************************)
(* definition of gt 
 fun strip_E_Thm (PPProver.E_Thm th) = th;

 fun pred_of_conv conv : ClauseGoalTyp.gtyp = 
  fn env => fn pnode => fn _ => (conv (PPProver.get_pnode_concl pnode); [env])
 handle BasicError.Fail msg => [];
 fun neg_pred_of_conv conv : ClauseGoalTyp.gtyp = 
  fn env => fn pnode => fn _ =>(conv (PPProver.get_pnode_concl pnode); [])
 handle BasicError.Fail msg => [env];*)
(*
 val is_left_eta_conv = pred_of_conv (LEFT_C È_expand_conv);
 val not_left_eta_conv = neg_pred_of_conv(LEFT_C È_expand_conv);

 fun is_unpair env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_L th) => 
              (unpair_rewrite_tac (map strip_E_Thm th) (PPProver.get_pnode_hyps pnode, PPProver.get_pnode_concl pnode);[env])
  handle _ => [])
| is_unpair _ _ _ = [];

 fun not_unpair env pnode [ClauseGoalTyp.PVar p] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_L th) => 
              (unpair_rewrite_tac (map strip_E_Thm th) (PPProver.get_pnode_hyps pnode, PPProver.get_pnode_concl pnode);[])
  handle _ => [env])
| not_unpair _ _ _ = [];

val is_lambda_pair = pred_of_conv Ì_unpair_conv;
val not_lambda_pair = neg_pred_of_conv Ì_unpair_conv;
*)


(*
fun is_some_conv env pnode [ClauseGoalTyp.PVar pc, ClauseGoalTyp.PVar pcc] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pcc of
             NONE => []
           | SOME (PPProver.E_L cc) => 
            (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pc of
              NONE => []
              | SOME (PPProver.E_Conv c) =>
              (map strip_E_CC cc) 
              |> List.foldr (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env])))
  handle _ => [])
| is_some_conv env pnode [ClauseGoalTyp.Var pc, ClauseGoalTyp.Var pcc] = 
 (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pcc of
             NONE => []
           | SOME (PPProver.E_L cc) => 
            (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) pc of
              NONE => []
              | SOME (PPProver.E_Conv c) =>
              (map strip_E_CC cc) 
              |> List.foldr (op o) (fn x => x) 
              |> (fn x => (((x c) (PPProver.get_pnode_concl pnode));[env])))
  handle _ => [])
| is_some_conv _ _ _ = [];
*)





