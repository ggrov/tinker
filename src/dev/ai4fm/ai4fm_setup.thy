theory ai4fm_setup
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin
section "taut"
lemma strip_disj: "(P \<or> Q) = (\<not> P \<longrightarrow> Q)" by auto

lemma not_iff: "(\<not>(P \<longleftrightarrow>Q)) = ((P \<and> \<not> Q) \<or> (\<not>P \<and>Q))" by auto


lemma iff_def: "(P \<longleftrightarrow> Q) =((P \<longrightarrow> Q) \<and> (Q \<longrightarrow> P))" by auto

lemma iff_def_f: "(P \<longleftrightarrow> Q) \<Longrightarrow> ((P \<longrightarrow> Q) \<and> (Q \<longrightarrow> P))" by auto

lemma imp_f: "(P \<longrightarrow> Q) \<Longrightarrow> (\<not> P \<or> Q)" by auto

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

 fun top_symbol env pnode [r,Clause_GT.Var p] : IsaProver.env list= 
          let 

            val tops = Clause_GT.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup env p of
               NONE => map (fn s => StrName.NTab.ins (p,Clause_GT.Prover.E_Str s) env) tops
             | SOME (Clause_GT.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    |  top_symbol env pnode [r,Clause_GT.Name n] = 
          let 
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
       
   fun is_term env pnode [r, Clause_GT.PVar p] =
   let val dest = Clause_GT.project_terms env pnode r val ctxt = Prover.get_pnode_ctxt pnode in
   (case StrName.NTab.lookup (IsaProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
           (case dest of [] =>[]
           | _ =>  if member trm_eq dest  (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => [])
   end
  | is_term env pnode [r, Clause_GT.Var p] =
   let val dest = Clause_GT.project_terms env pnode r val ctxt = Prover.get_pnode_ctxt pnode in
   (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
                     (case dest of [] =>[]
           | _ =>  if member trm_eq dest (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => []) end
  | is_term env pnode [r, Clause_GT.Term trm] = 
   let 
    val ctxt = IsaProver.get_pnode_ctxt pnode  
    val dest = Clause_GT.project_terms env pnode r in
   (case dest of [] =>[]
    | _ =>  
     if member trm_eq dest (Syntax.check_term ctxt trm) 
     then [env] else [])
   end
  | is_term env pnode [r, Clause_GT.Concl] = 
     let val dest = Clause_GT.project_terms env pnode r in
     (case dest of [] =>[]
      | _ =>  
       if member trm_eq dest (IsaProver.get_pnode_concl pnode)
       then [env] else [])
     end
  | is_term _ _ _ = [];

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

 fun dest_trm env pnode [Clause_GT.Concl, Clause_GT.Var p1, Clause_GT.Var p2] = 
  let 
    val (trm1, trm2) = dest_comb (Prover.get_pnode_concl pnode) 
  in 
     StrName.NTab.update (p1,Clause_GT.Prover.E_Trm trm1) env
     |> StrName.NTab.update (p2,Clause_GT.Prover.E_Trm trm2) 
     |> (fn x => [x])
  handle _ => [] end 
  | dest_trm env _ [Clause_GT.Term t, Clause_GT.Var p1, Clause_GT.Var p2] = 
   let 
    val (trm1, trm2) = dest_comb t
   in 
     StrName.NTab.update (p1,Clause_GT.Prover.E_Trm trm1) env
     |> StrName.NTab.update (p2,Clause_GT.Prover.E_Trm trm2) 
     |> (fn x => [x])
   handle _ => [] end 
  | dest_trm env _ [Clause_GT.Var input, Clause_GT.Var p1, Clause_GT.Var p2] = 
   let 
    val (trm1, trm2) = 
      (case StrName.NTab.lookup env input of
      SOME (Prover.E_Trm t) => dest_comb t
      | _ => raise Fail "fail it on purpose")
   in
      StrName.NTab.update (p1,Clause_GT.Prover.E_Trm trm1) env
     |> StrName.NTab.update (p2,Clause_GT.Prover.E_Trm trm2) 
     |> (fn x => [x])
   handle _ => [] end  
  | dest_trm _ _ _ = []

 val data = 
  Clause_GT.default_data
  |> Clause_GT.add_atomic "top_symbol" top_symbol 
  |> Clause_GT.add_atomic "is_term" is_term 
  |> Clause_GT.add_atomic "dest_trm" dest_trm 
  |> Clause_GT.add_atomic "is_literal" is_literal ;
*}


ML{*
(* tactic definition *)
fun simp_only_tac thml ctxt= fold Simplifier.add_simp thml (Raw_Simplifier.clear_simpset ctxt) |> simp_tac;

val t_tac = fn _ => rtac @{thm"HOL.TrueI"};
val concl_in_asm_tac = fn _ => atac;
val elim_conj_tac = fn _ => etac @{thm "conjE"};
val intro_conj_tac = fn _ =>rtac @{thm"conjI"};
val elim_conj_tac = fn _ =>etac @{thm "conjE"};
val intro_disj_tac = simp_only_tac [@{thm"strip_disj"}];
val elim_disj_tac = fn _ => etac @{thm"disjE"};
val intro_not_tac = simp_only_tac @{thms not_not de_Morgan_conj HOL.de_Morgan_disj not_imp not_iff not_True_eq_False not_False_eq_True};
val elim_not_tac = fn _ => dresolve_tac @{thms  not_not_f de_Morgan_conj_f de_Morgan_disj_f not_imp_f not_iff_f not_True_eq_False_f not_False_eq_True_f}
val intro_iff_tac = simp_only_tac [@{thm"iff_def"}];
val elim_iff_tac = fn _ => etac @{thm"iff_def_f"};
val intro_imp_tac = fn _ => rtac @{thm"impI"} ;
val elim_imp_tac = fn _ => dtac @{thm"imp_f"} ;
*}






end
