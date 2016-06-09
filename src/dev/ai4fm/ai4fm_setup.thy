theory ai4fm_setup
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin
lemma strip_disj: "P \<or> Q = (\<not> P \<longrightarrow> Q)"
by auto

lemma not_iff: "\<not>(P \<longleftrightarrow>Q) = (P \<and> \<not> Q) \<or> (\<not>P \<and>Q)"
by auto

lemma iff_def: "(P \<longleftrightarrow> Q) =((P \<longrightarrow> Q) \<and> (Q \<longrightarrow> P))"
by auto


find_theorems "True"
thm not_not  de_Morgan_conj HOL.de_Morgan_disj not_imp not_iff not_True_eq_False not_False_eq_True

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
   let val dest = Clause_GT.project_terms env pnode r in
   (case StrName.NTab.lookup (IsaProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
           (case dest of [] =>[]
           | _ =>  if member trm_eq dest t then [env] else [])
           | SOME _ => [])
   end
  | is_term env pnode [r, Clause_GT.Var p] =
   let val dest = Clause_GT.project_terms env pnode r in
   (case StrName.NTab.lookup env p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
                     (case dest of [] =>[]
           | _ =>  if member trm_eq dest t then [env] else [])
           | SOME _ => []) end
  | is_term env pnode [r, Clause_GT.Name trm_str] = 
   let 
    val trm_str' = case trm_str of "true" => "True" | _ => trm_str
    val ctxt = IsaProver.get_pnode_ctxt pnode  
    val dest = Clause_GT.project_terms env pnode r in
   (case dest of [] =>[]
    | _ =>  
     if member trm_eq dest (Syntax.check_term ctxt (IsaProver.trm_of_string ctxt trm_str')) 
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
  Term.is_Const trm  orelse Term.is_Free trm orelse Term.is_Var trm 
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
*}

ML{*
Term.dest_trm;
val t = @{term "B \<longleftrightarrow> A"};
   val data = Clause_GT.add_atomic "is_literal" is_literal Clause_GT.default_data; 

   val t = @{prop "A \<Longrightarrow> B \<Longrightarrow> A \<and> B \<Longrightarrow> A \<and> B"}; 
   val (pnode,pplan) = IsaProver.init @{context} [] t;                         
   Clause_GT.match data pnode (Clause_GT.scan_goaltyp @{context} "is_literal(concl)")   
   (IsaProver.get_pnode_env pnode);
  *}    

ML{*
  val clause_def = 
 "c(Z) :- top_symbol(concl,Z)." ^
 "h(Z) :- top_symbol(hyps,Z). " ^
 "c_not_literal(X) :- c(X), rand_trm(concl, Y), not_trm_var_nor_const(Y)." ^
 "h_not_literal(X) :- top_symbol(hyps,X,Y), rand_trm(Y, Z), not_trm_var_nor_const(Z)." ^
 "taut_simp(concl) :- is_goal(true)." ^
 "taut_simp(concl) :- has_hyp(concl)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c(conj)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c(disj)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c(if_then_else)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c(eq)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c(implies)." ^
 "taut_simp(concl) :- has_no_hyp(concl), c_not_literal(not)." ^
 "asm_to_strip(hyps) :- h(conj)." ^
 "asm_to_strip(hyps) :- h(disj)." ^
 "asm_to_strip(hyps) :- h(equiv)." ^
 "asm_to_strip(hyps) :- h(implies)." ^
 "asm_to_strip(hyps) :- h_not_literal(not).";


  val default_gt_data = 
   Clause_GT.add_atomic "top_symbol" top_symbol Clause_GT.default_data;

 val data = 
  default_gt_data
  |> Clause_GT.add_atomic "no_asm_to_strip" literal
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);


*}
ML{*
(* tactic definition *)
val t_tac = rtac @{thm"HOL.TrueI"} |> K;
val concl_in_asm_tac =  K atac;
val conj_tac = rtac @{thm"conjI"} |> K;
fun simp_only_tac thml ctxt= fold Simplifier.add_simp thml (Raw_Simplifier.clear_simpset ctxt) |> simp_tac;
val disj_tac = simp_only_tac [@{thm"strip_disj"}];
val not_tac = simp_only_tac @{thms not_not de_Morgan_conj HOL.de_Morgan_disj not_imp not_iff not_True_eq_False not_False_eq_True};
val iff_tac = simp_only_tac [@{thm"iff_def"}];
*}
end
