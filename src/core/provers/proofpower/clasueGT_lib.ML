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
  

fun is_member env pnode [d, r] = 
  ClauseGoalTyp.project_terms env pnode r
  |> maps (fn x => ClauseGoalTyp.update_var env (PPProver.E_Trm x) d)
 | is_member _ _ _ = [];

 fun top_symbol env pnode [r,ClauseGoalTyp.Var p] = 
  let 
    val tops = ClauseGoalTyp.project_terms env pnode r
             |> maps top_level_str'
  in 
    (case StrName.NTab.lookup env p of
       NONE => [](*map (fn s => StrName.NTab.ins (p,ClauseGoalTyp.Prover.E_Str s) env) tops*)
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
 | top_symbol env pnode [r, ClauseGoalTyp.Var n, ClauseGoalTyp.Var p] =
  let 
    val tops = ClauseGoalTyp.project_terms env pnode r
             |> map (fn x => (x, top_level_str' x))
             |> filter (fn (_, []) => false | (_,_) => true)
             |> map (fn (a,l) => (a, hd l)) 
  in 
    (case StrName.NTab.lookup env n of
      SOME (ClauseGoalTyp.Prover.E_Str name) =>           
       (case (filter (fn (a, s) => (s = name)) tops)
        of [] => []
         | l => map fst l |> map ClauseGoalTyp.Prover.E_Trm 
                |> ClauseGoalTyp.Prover.E_L
                |> (fn x => [StrName.NTab.ins (p,x) env]))
     | _ => [])
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
  
   fun print_trm trm = 
   String.concat (PrettyPrinter.format_term true trm) 
   |> writeln; 
   
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
 
 fun has_no_hyp env pnode [ClauseGoalTyp.PVar p] = 
  (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => 
     if member (op =) (PPProver.get_pnode_hyps pnode) t then [] else [env]
    |  SOME _ => [])
 | has_no_hyp env pnode [ClauseGoalTyp.Var p] =
  (case StrName.NTab.lookup (PPProver.get_pnode_env pnode) p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => 
     if member (op =) (PPProver.get_pnode_hyps pnode) t then [] else [env]
    |  SOME _ => [])
 | has_no_hyp env pnode [ClauseGoalTyp.Concl] =
  if member (op =) (PPProver.get_pnode_hyps pnode)(PPProver.get_pnode_concl pnode) 
  then [] else [env]    
 | has_no_hyp env pnode [ClauseGoalTyp.Name str] = 
  if member (op =) (PPProver.get_pnode_hyps pnode)(PPProver.trm_of_string PPProver.default_ctxt str)
  then [] else [env]  
 | has_no_hyp _ _ _ = []
 
exception dest_trm_exp of string 
fun dest_trm env pnode [trm, p1, p2] = 
 (let 
    val trm' = case ClauseGoalTyp.project_terms env pnode trm of [x] => x
      | _ => raise dest_trm_exp "only one term is expected"
    val (trm1, trm2) = dest_app trm'
 in 
     ClauseGoalTyp.update_var env (ClauseGoalTyp.Prover.E_Trm trm1) p1
    |> maps (fn e => ClauseGoalTyp.update_var e (ClauseGoalTyp.Prover.E_Trm trm2) p2)
 end handle _ => [] )
  | dest_trm _ _ _ = []

fun const_str env pnode [trm, p] = 
 (let 
    val trm' = case ClauseGoalTyp.project_terms env pnode trm of [x] => x
      | _ => raise dest_trm_exp "only one term is expected"
    val str = case ClauseGoalTyp.project_name env pnode p of [x] => x
      | _ => raise dest_trm_exp "only one string is expected"
 in 
    case get_const_str trm'
      of NONE => []
      | (SOME cstr) => if (decode_str cstr) = str then [env] else []
 end handle _ => [] )
  | const_str _ _ _ = []

  
 fun trm_const env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if is_const t then [env] else []
    |  SOME (PPProver.E_L l) => 
        (map (fn (PPProver.E_Trm t) => t) l 
        |> filter (is_const) 
        |> (fn x => case x of [] => [] | _ => [env]))
    |  SOME _ => [])
  | trm_const _ _ _ = []
  
 fun not_trm_const env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if (not o is_const) t then [env] else []
    |  SOME (PPProver.E_L l) => map (fn (PPProver.E_Trm t) => t) l 
        |> filter (not o is_const) |> (fn x => case x of [] => [] | _ => [env])
    |  SOME _ => [])
  | not_trm_const _ _ _ = []

 fun trm_var env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if is_var t then [env] else []
    |  SOME (PPProver.E_L l) => map (fn (PPProver.E_Trm t) => t) l 
        |> filter (is_var) |> (fn x => case x of [] => [] | _ => [env])
    |  SOME _ => [])
  | trm_var _ _ _ = []
 
  fun not_trm_var env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if (not o is_var) t then [env] else []
    |  SOME (PPProver.E_L l) => map (fn (PPProver.E_Trm t) => t) l 
        |> filter (not o is_var) |> (fn x => case x of [] => [] | _ => [env])
    |  SOME _ => [])
  | not_trm_var _ _ _ = []

  fun trm_var_or_const env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if (is_var t orelse is_const t) then [env] else []
    |  SOME (PPProver.E_L l) => map (fn (PPProver.E_Trm t) => t) l 
        |> filter (fn t => (is_var t orelse is_const t))  
        |> (fn x => case x of [] => [] | _ => [env])
    |  SOME _ => [])
  | trm_var_or_const _ _ _ = []
 
  fun not_trm_var_nor_const env pnode [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p 
    of NONE => []
    |  SOME (PPProver.E_Trm t) => if ((not o is_var) t andalso (not o is_const) t) then [env] else []
    |  SOME (PPProver.E_L l) => map (fn (PPProver.E_Trm t) => t) l 
        |> filter (fn t => ((not o is_var) t andalso (not o is_const) t))
        |> (fn x => case x of [] => [] | _ => [env])
    |  SOME _ => [])
  | not_trm_var_nor_const _ _ _ = []
  
  fun literal env pnode args = 
   let 
    fun is_literal trm = 
     is_var trm orelse is_const trm orelse 
     (((dest_app trm |> fst) =$ %<% $%not% %>%) andalso (is_var (snd (dest_app trm)))) orelse
     (((dest_app trm |> fst) =$ %<% $%not% %>%) andalso (is_const (snd (dest_app trm))))
     handle _ => false
    fun is_all_literal trm_l = 
     filter (not o is_literal) trm_l |> List.null
   in
    case args 
    of [ClauseGoalTyp.Concl] => 
        if is_literal (PPProver.get_pnode_concl pnode) then [env]
        else []
     | [ClauseGoalTyp.Hyps] => 
        if is_all_literal (PPProver.get_pnode_hyps pnode) then [env]
        else []
     | _ => []
   end
   
  fun is_empty env pnode [ClauseGoalTyp.Hyps] = 
   if List.null  (PPProver.get_pnode_hyps pnode) then [env]
   else []
  | is_empty _ _ _ = []

  fun is_term env _ [ClauseGoalTyp.Var p] = 
   (case StrName.NTab.lookup env p of
       NONE => []
     | SOME (ClauseGoalTyp.Prover.E_Trm _) => [env]
     | SOME _ => [])
  | is_term env _ [ClauseGoalTyp.PVar p] = 
   (case StrName.NTab.lookup env p of
       NONE => []
     | SOME (ClauseGoalTyp.Prover.E_Trm _) => [env]
     | SOME _ => [])
   | is_term _ _ _ = []
  
  val default_gt_data = 
   ClauseGoalTyp.add_atomic "top_symbol" top_symbol ClauseGoalTyp.default_data
   |> ClauseGoalTyp.add_atomic "is_goal" is_goal
   |> ClauseGoalTyp.add_atomic "is_not_goal" is_not_goal
   |> ClauseGoalTyp.add_atomic "has_hyp" has_hyp
   |> ClauseGoalTyp.add_atomic "has_no_hyp" has_no_hyp
   |> ClauseGoalTyp.add_atomic "dest_trm" dest_trm
   |> ClauseGoalTyp.add_atomic "trm_var" trm_var
   |> ClauseGoalTyp.add_atomic "not_trm_var" not_trm_var
   |> ClauseGoalTyp.add_atomic "trm_const" trm_const
   |> ClauseGoalTyp.add_atomic "not_trm_const" not_trm_const 
   |> ClauseGoalTyp.add_atomic "trm_var_or_const" trm_var_or_const
   |> ClauseGoalTyp.add_atomic "not_trm_var_nor_const" not_trm_var_nor_const
   |> ClauseGoalTyp.add_atomic "literal" literal
   |> ClauseGoalTyp.add_atomic "is_empty" is_empty 
   |> ClauseGoalTyp.add_atomic "member" is_member 
   |> ClauseGoalTyp.add_atomic "is_term" is_term 
   |> ClauseGoalTyp.add_atomic "const_str" const_str
   
   
end (* end of local *)
end;
open ClauseGT_Lib;
val _ = init_symbol_table 
[("%and%", "conj"), ("%or%", "disj"),
 ("%implies%", "implies"), ("%not%", "not"), ("%forall%", "forall"), ("%exists%", "exists"),
 ("%equiv%", "equiv"),("Cond", "if_then_else"), ("%mem%", "member")];

