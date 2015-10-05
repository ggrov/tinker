structure ClauseGT_Lib = 
struct
 local open LoggingHandler TermFeatures in
 (* use a symbol table to represent those non-standdatd ascii symbols *)
 val symbol_table : string StrName.NTab.T Unsynchronized.ref  = Unsynchronized.ref StrName.NTab.empty;
 fun init_symbol_table l = symbol_table := StrName.NTab.of_list l; 
 
 fun decode_str str = case StrName.NTab.lookup (!symbol_table) str of (SOME str') => str' | _ => str;

 fun top_level_str' trm = 
  case top_level_str trm of
     NONE => []
   | SOME v => [decode_str v];
  
 fun top_symbol env pnode [r,ClauseGoalTyp.Var p] = 
  let 
    val tops = ClauseGoalTyp.project_terms env pnode r
             |> maps top_level_str'
  in 
    (case StrName.NTab.lookup env p of
       NONE => map (fn s => StrName.NTab.ins (p,ClauseGoalTyp.Prover.E_Str s) env) tops
     | SOME (ClauseGoalTyp.Prover.E_Str s) => if member (op =) tops s then [env] else []
     | SOME _ => [])
  end
 | top_symbol env pnode [r,ClauseGoalTyp.Name n] = 
  let 
    val tops = ClauseGoalTyp.project_terms env pnode r
             |> maps top_level_str'
  in 
     if member (op =) tops n then [env] else []
  end 
 | top_symbol env pnode [r,ClauseGoalTyp.PVar p] = 
  let 
    val tops = ClauseGoalTyp.project_terms env pnode r
             |> maps top_level_str'
  in 
    (case StrName.NTab.lookup (ClauseGoalTyp.Prover.get_pnode_env pnode) p of
       NONE => []
     | SOME (ClauseGoalTyp.Prover.E_Str s) => if member (op =) tops s then [env] else []
     | SOME _ => [])
  end
 | top_symbol _ _ [] = []
 | top_symbol _ _ [_,_] = []
 | top_symbol env pnode (x::xs) =
   maps (fn r => top_symbol env pnode [x,r]) xs;
      
  fun is_goal env pnode [ClauseGoalTyp.PVar p] =
   (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (PPProver.E_Trm t) => if t = (PPProver.get_pnode_concl pnode) then [env] else []
           | SOME _ => [])
  | is_goal env pnode [ClauseGoalTyp.Var p] =
   (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (PPProver.E_Trm t) => if t = (PPProver.get_pnode_concl pnode) then [env] else []
           | SOME _ => [])
  | is_goal env pnode [ClauseGoalTyp.Name trm_str] = 
    if (PPProver.trm_of_string PPProver.default_ctxt trm_str) = (PPProver.get_pnode_concl pnode) 
    then [env] 
    else []
  | is_goal _ _ _ = [];

  fun is_not_goal env pnode [ClauseGoalTyp.PVar p] =
     (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p of
               NONE => []
             | SOME (PPProver.E_Trm t) => if not(t = (PPProver.get_pnode_concl pnode)) then [env] else []
             | SOME _ => [])
  | is_not_goal env pnode [ClauseGoalTyp.Var p] =
     (case StrName.NTab.lookup env p of
               NONE => []
             | SOME (PPProver.E_Trm t) => if not(t = (PPProver.get_pnode_concl pnode)) then [env] else []
             | SOME _ => [])
  | is_not_goal env pnode [ClauseGoalTyp.Name trm_str] = 
      if not ((PPProver.trm_of_string PPProver.default_ctxt trm_str) = (PPProver.get_pnode_concl pnode)) 
      then [env] 
      else []
  | is_not_goal _ _ _ = [];
  
  
 fun has_hyp env pnode [ClauseGoalTyp.PVar p] = 
  (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => 
     if member (op =) (PPProver.get_pnode_hyps pnode) t then [env] else []
    |  SOME _ => [])
 | has_hyp env pnode [ClauseGoalTyp.Var p] =
  (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => 
     if member (op =) (PPProver.get_pnode_hyps pnode) t then [env] else []
    |  SOME _ => [])
 | has_hyp env pnode [ClauseGoalTyp.Concl] =
  if member (op =) (PPProver.get_pnode_hyps pnode)(PPProver.get_pnode_concl pnode) 
  then [env] else []    
 | has_hyp env pnode [ClauseGoalTyp.Name str] = 
  if member (op =) (PPProver.get_pnode_hyps pnode)(PPProver.trm_of_string PPProver.default_ctxt str)
  then [env] else []  
 | has_hyp _ _ _ = []
 
 
 fun rand_trm env pnode [ClauseGoalTyp.Concl, ClauseGoalTyp.Var p] = 
  let 
    val trm = dest_app (PPProver.get_pnode_concl pnode) |> snd
  in 
    (case StrName.NTab.lookup env p of
       NONE => [StrName.NTab.ins (p,ClauseGoalTyp.Prover.E_Trm trm) env]
     | SOME _ => [])
  end
  | rand_trm _ _ _ = []
  
 fun is_trm_var env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if is_var t then [env] else []
    |  SOME _ => [])
  | is_trm_var _ _ _ = []
 
  fun is_not_trm_var env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if (not o is_var) t then [env] else []
    |  SOME _ => [])
  | is_not_trm_var _ _ _ = []

  
  val default_gt_data = 
   ClauseGoalTyp.add_atomic "top_symbol" top_symbol ClauseGoalTyp.default_data
   |> ClauseGoalTyp.add_atomic "is_goal" is_goal
   |> ClauseGoalTyp.add_atomic "is_not_goal" is_not_goal
   |> ClauseGoalTyp.add_atomic "has_hyp" has_hyp
   |> ClauseGoalTyp.add_atomic "rand_trm" rand_trm
   |> ClauseGoalTyp.add_atomic "is_trm_var" is_trm_var
   |> ClauseGoalTyp.add_atomic "is_not_trm_var" is_not_trm_var
   
   
end (* end of local *)
end;
open ClauseGT_Lib;
val _ = init_symbol_table 
[("%and%", "conj"), ("%or%", "disj"),
 ("%implies%", "implies"), ("%not%", "not"),
 ("%equiv%", "equiv")];

