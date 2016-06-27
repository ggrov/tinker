theory ai4fm_setup
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin
section "taut"
lemma disjI3: " (\<not> P \<longrightarrow> Q) \<Longrightarrow> (P \<or> Q)" by auto

lemma not_iff: "(\<not>(P \<longleftrightarrow>Q)) = ((P \<and> \<not> Q) \<or> (\<not>P \<and>Q))" by auto

lemma impF: "(P \<longrightarrow> Q) \<Longrightarrow> (\<not> P \<or> Q)" by auto

thm not_not de_Morgan_conj HOL.de_Morgan_disj not_imp not_iff not_True_eq_False not_False_eq_True

lemma not_not_f: "\<not>\<not>P \<Longrightarrow> P" by auto
lemma de_Morgan_conj_f: " (\<not> (P \<and> Q)) \<Longrightarrow> (\<not> P \<or> \<not> Q)" by auto
lemma de_Morgan_disj_f: "(\<not> (P \<or> Q)) \<Longrightarrow> (\<not> P \<and> \<not> Q)" by auto
lemma not_imp_f: "(\<not> (P \<longrightarrow> Q)) \<Longrightarrow> (P \<and> \<not> Q)" by auto
lemma not_iff_f: "(\<not>(P \<longleftrightarrow>Q)) \<Longrightarrow> ((P \<and> \<not> Q) \<or> (\<not>P \<and>Q))" by auto
lemma not_True_eq_False_f: " (\<not> True) \<Longrightarrow> False" by auto
lemma not_False_eq_True_f: "(\<not> False) \<Longrightarrow> True" by auto

thm not_not_f de_Morgan_conj_f de_Morgan_disj_f not_imp_f not_iff_f not_True_eq_False_f not_False_eq_True_f

ML{*
(* Clause GT*)
  val ignore_module = List.last o String.tokens (fn ch => #"." = ch) ;

    fun top_level_str (Const (s,_)) = [ignore_module s]
  | top_level_str ((Const ("all",_)) $ f) = top_level_str f
  | top_level_str ((Const ("prop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("HOL.Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("==>",_)) $ _ $ f) = top_level_str f
  | top_level_str (f $ _) = top_level_str f
  | top_level_str (Abs (_,_,t)) = top_level_str t
  | top_level_str _ = [];
  
 fun to_singleton_list [] = []
 | to_singleton_list (x::xs) = [x] @ (to_singleton_list xs)

 fun is_member env pnode [d, r] = 
  Clause_GT.project_terms env pnode r
  |> maps (fn x => Clause_GT.update_var env (IsaProver.E_Trm x) d)
 | is_member _ _ _ = [];

 fun hack_not n0 = case n0 of "not" => "Not"| _ => n0;
 fun top_symbol env pnode [r,Clause_GT.Var p] : IsaProver.env list= 
          let 

            val tops = Clause_GT.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup env p of
               NONE => map (fn s => StrName.NTab.ins (p,Clause_GT.Prover.E_Str s) env) tops
             | SOME (Clause_GT.Prover.E_Str s) => if member (op =) tops (hack_not s) then [env] else []
             | SOME _ => [])
          end
    |  top_symbol env pnode [r,Clause_GT.Name n0] = 
          let 
            val n = hack_not n0;
            val tops = Clause_GT.project_terms env pnode r
                     |> maps top_level_str
          in 
             if member (op =) tops n then [env] else []
          end
    |  top_symbol env pnode [r,Clause_GT.PVar p] = 
          let 
            val tops = Clause_GT.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) p of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    | top_symbol _ _ [] = []
    | top_symbol _ _ [_,_] = []
    | top_symbol env pnode (x::xs) =
        maps (fn r => top_symbol env pnode [x,r]) xs;   

   fun ignore_true_prop t = 
    case t of 
    ((Const ("HOL.Trueprop",_)) $ f) => ignore_true_prop f
    | _ => t ;

   fun trm_eq (x,y) = (ignore_true_prop x) = (ignore_true_prop y) 
       
   fun eq_term env pnode [r, Clause_GT.PVar p] =
   let val dest = Clause_GT.project_terms env pnode r val ctxt = IsaProver.get_pnode_ctxt pnode in
   (case StrName.NTab.lookup (IsaProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
           (case dest of [] =>[]
           | _ =>  if member trm_eq dest  (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => [])
   end
  | eq_term env pnode [r, Clause_GT.Var p] =
   let val dest = Clause_GT.project_terms env pnode r val ctxt = IsaProver.get_pnode_ctxt pnode in
   (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
                     (case dest of [] =>[]
           | _ =>  if member trm_eq dest (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => []) end
  | eq_term env pnode [r, Clause_GT.Term trm] = 
   let 
    val ctxt = IsaProver.get_pnode_ctxt pnode  
    val dest = Clause_GT.project_terms env pnode r in
   (case dest of [] =>[]
    | _ =>  
     if member trm_eq dest (Syntax.check_term ctxt trm) 
     then [env] else [])
   end
  | eq_term env pnode [r, Clause_GT.Concl] = 
     let val dest = Clause_GT.project_terms env pnode r in
     (case dest of [] =>[]
      | _ =>  
       if member trm_eq dest (IsaProver.get_pnode_concl pnode)
       then [env] else [])
     end
  | eq_term _ _ _ = [];

 fun is_literal0 trm = 
  Term.is_Free trm orelse Term.is_Var trm 
 fun is_literal env pnode [Clause_GT.Concl] = 
  IsaProver.get_pnode_concl pnode
  |> ignore_true_prop
  |> is_literal0
  |> (fn x => if x then [env] else [])
  | is_literal env _ [Clause_GT.Var v] = 
     (case StrName.NTab.lookup env v of
       NONE => []
     | SOME (IsaProver.E_Trm t) => 
            if ((is_literal0 o ignore_true_prop) t)
            then [env]
            else []
     | _ => [] )
  | is_literal env _ [Clause_GT.PVar v] = 
     (case StrName.NTab.lookup env v of
       NONE => []
     | SOME (IsaProver.E_Trm t) => 
            if ((is_literal0 o ignore_true_prop) t)
            then [env]
            else []
      | _ => [])
  | is_literal _ _ _ = []

 exception dest_trm_exp of string 
 fun dest_trm env pnode [trm, p1, p2] = 
  (let 
    val trm' = case Clause_GT.project_terms env pnode trm of [x] => x 
      | _ => raise dest_trm_exp "only one term is expected"
    val (trm1, trm2) = dest_comb trm' 
  in 
     Clause_GT.update_var env (Clause_GT.Prover.E_Trm trm1) p1
    |> maps (fn e => Clause_GT.update_var e (Clause_GT.Prover.E_Trm trm2) p2)
  end handle _ => [] )
  | dest_trm _ _ _ = []

 fun empty_list (env : IsaProver.env) _ [Clause_GT.PVar v] = 
  (case StrName.NTab.lookup env v of SOME (IsaProver.E_L[]) => [env]
  | _ => [])
 | empty_list (env : IsaProver.env) _ [Clause_GT.Var v] = 
  (case StrName.NTab.lookup env v of SOME (IsaProver.E_L[])  => [env]
  | _ => [])
 | empty_list _ _ _ = []

 val data = 
  Clause_GT.default_data
  |> Clause_GT.add_atomic "top_symbol" top_symbol 
  |> Clause_GT.add_atomic "eq_term" eq_term 
  |> Clause_GT.add_atomic "dest_term" dest_trm 
  |> Clause_GT.add_atomic "is_literal" is_literal 
  |> Clause_GT.add_atomic "empty_list" empty_list
  |> Clause_GT.add_atomic "member" is_member;

*}

ML{*
(* tactic definition *)
val simp = safe_asm_full_simp_tac;
fun simp_only_tac thml ctxt= fold Simplifier.add_simp thml (Raw_Simplifier.clear_simpset ctxt) |> simp_tac;

val intro_not_tac = simp_only_tac @{thms not_not de_Morgan_conj HOL.de_Morgan_disj not_imp not_iff not_True_eq_False not_False_eq_True};
val elim_not_tac = fn _ => dresolve_tac @{thms not_not_f de_Morgan_conj_f de_Morgan_disj_f not_imp_f not_iff_f not_True_eq_False_f not_False_eq_True_f}

fun subgoals_tac [IsaProver.A_Trm t] ctxt = subgoal_tac ctxt (IsaProver.string_of_trm ctxt t)

fun rule [IsaProver.A_Thm thm] _  =  rtac thm;
fun erule [IsaProver.A_Thm thm] _  = etac thm;
fun drule [IsaProver.A_Thm thm] _  = dtac thm;
fun simp_only [IsaProver.A_Thm thm] = simp_only_tac [thm];

fun erule_tac1 [IsaProver.A_Str str, IsaProver.A_Trm trm, IsaProver.A_Thm thm] ctxt = 
  eres_inst_tac ctxt  [((str,0), (IsaProver.string_of_trm ctxt trm))] thm

fun erule_tac2 
  [IsaProver.A_Str str1, IsaProver.A_Str str2, 
   IsaProver.A_Trm trm1, IsaProver.A_Trm trm2, IsaProver.A_Thm thm] ctxt = 
  eres_inst_tac ctxt  [((str1,0), (IsaProver.string_of_trm ctxt trm1)), 
                       ((str2,0), (IsaProver.string_of_trm ctxt trm2))] thm
*}

ML{*
exception hyp_match of string
fun ENV_hyp_match ctxt 
      [IsaProver.A_L_Trm hyps, 
       IsaProver.A_Str pat, 
       IsaProver.A_Var v1, 
       IsaProver.A_Var v2] (env : IsaProver.env): IsaProver.env list =
 (let 
  val thy = Proof_Context.theory_of ctxt
  val term_pat = Proof_Context.read_term_pattern ctxt pat 
  val hyp = filter (fn x => Pattern.matches thy (term_pat, x)) (map (snd o dest_comb) hyps)
 in
   case hyp of [] => []
   | _ => (* a bit hack here, only get the head ele*)
    let 
      val tenvir = Pattern.unify thy (term_pat, hd hyp) (Envir.empty 0) |> Envir.term_env
      fun get_v v = 
        case Vartab.lookup tenvir (v, 0) 
          of NONE => raise hyp_match v1
          | (SOME t) => snd t
      val v1_t = get_v v1
      val v2_t = get_v v2
    in 
     StrName.NTab.update (v1, IsaProver.E_Trm v1_t) env
     |> StrName.NTab.update (v2, IsaProver.E_Trm v2_t)
     |> (fn x => [x])
    end
 end 
 handle (hyp_match str) => (LoggingHandler.logging "FAILURE" ("No matching found for " ^ str);[]))
| ENV_hyp_match _ _ _ = []

fun ENV_all_asms _ [IsaProver.A_L_Trm hyps, IsaProver.A_Var name] (env : IsaProver.env): IsaProver.env list = 
   [StrName.NTab.update (name, map IsaProver.E_Trm hyps |> IsaProver.E_L) env]
|   ENV_all_asms _ _ _ = [];

fun ENV_check_ccontr ctxt [IsaProver.A_L_Trm hyps, IsaProver.A_Var v]  (env : IsaProver.env) :  IsaProver.env list= 
 (case (filter(member(fn (a,b) => (dest_comb a |> snd) = ((Const ("HOL.Not", dummyT) $ (dest_comb b |> snd))|> Syntax.check_term ctxt)) hyps) hyps) 
  of [] => [StrName.NTab.update (v, IsaProver.E_Str "None") env]
  | ret => [StrName.NTab.update 
     (v, IsaProver.E_Trm (
      hd ret (* only get one ele *)
      |> dest_comb |> snd (* dest true prop *)
      |> dest_comb |> snd) (* dest Not *)
     ) env])
| ENV_check_ccontr _ _ _ = []
*}

ML{*
structure C = Clause_GT;
   val t = @{prop "B \<Longrightarrow> \<not> B \<Longrightarrow> A"};
   val t = @{prop "a \<ge> (b::nat) \<Longrightarrow>  P"};
   val (pnode,pplan) = IsaProver.init @{context} [] t;

val env = IsaProver.get_pnode_env pnode;
val ctxt = IsaProver.get_pnode_ctxt pnode;
val hyps = IsaProver.get_pnode_hyps pnode;    
*}

ML{*
ENV_check_ccontr ctxt [IsaProver.A_L_Trm hyps, IsaProver.A_Var "negHyp"] env;
C.imatch data pnode (C.scan_goaltyp ctxt "is_term(hyps, concl)");
*}

ML{*
Symbol.is_digit;
val s = Symbol.explode "?g := @{term \"(?x = ?y) \<or> (?x > ?y)\"}";
 Env_Tac_Utils.scan_env_vars s;
val src = s;
    val (var, def_strs) = 
        (scan_var (* scan variable name *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src ;
    
  (scan_antiquto ((*Prover.antiquto_handler env*)snd) def_strs) |>snd
|> Symbol.explode
|>  Env_Tac_Utils.scan_env_vars

*}
ML{*
val env = ENV_hyp_match ctxt [IsaProver.A_L_Trm hyps, IsaProver.A_Str "?x \<ge> ?y", IsaProver.A_Var "x", IsaProver.A_Var "y"] env |>hd;

val input = "?g := @{term \"(?x = ?y)\"}";

*}

ML{*
      
       val src = Symbol.explode input;
       val (var, def_strs) = 
        (scan_var (* scan variable name *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src ;

       (*val def_strs = filter_blank' def_strs*);
       val (typ, def) = 
        if (is_start_with "?" (String.concat def_strs)) 
        (* start with ?, so must be assigning to another env var *)
        then
         scan_env_var def_strs |> fst (* get the name of the var *)
         |> (fn x => (StrName.NTab.get env (String.extract (x, 1, NONE)); ("dummy", String.concat def_strs)))
    
        else if  (is_start_with "\"" (String.concat def_strs)) then
         ("string", (String.concat def_strs))
        else (* otherwise, scan as the antiquto format*)
        (scan_antiquto ((*Prover.antiquto_handler env*)snd) def_strs);

    scan_env_vars ( Symbol.explode def);

        (*val _ = writeln "a"*)
        val env_vars = 
         if (typ = "string") then []
         else
         scan_env_vars ( Symbol.explode def)
         |> map (fn n => (n, StrName.NTab.get env n(*String.extract (n,1,NONE)*)));


        StrName.NTab.update (filter_blank var, Prover.parse_env_data ctxt (filter_blank typ, def) env_vars) env
        |> Prover.id_env_tac_f 
      
*}
end
