theory sttt_setup
imports "../../core/provers/isabelle/clausal/CIsaP"  

begin

section onepoint

section rippling
(* wrapping trm with name structure *)
  ML_file "../../core/provers/isabelle/lib/rippling/unif_data.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/collection.ML"   
  ML_file "../../core/provers/isabelle/lib/rippling/pregraph.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/rgraph.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/paramtab.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/trm.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/isa_trm.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/instenv.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/typ_unify.ML"   
(* embeddings *)
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/eterm.ML"  
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/ectxt.ML" 
  ML_file "../../core/provers/isabelle/lib/rippling/embedding/embed.ML"
(* measure and skeleton *)
  ML_file "../../core/provers/isabelle/lib/rippling/measure_traces.ML"
  ML_file "../../core/provers/isabelle/lib/rippling/measure.ML" 
  (*ML_file "../../provers/isabelle/termlib/rippling/flow_measure.ML"*)
  ML_file "../../core/provers/isabelle/lib/rippling/dsum_measure.ML" 
  (* wave rule set *)
  ML_file  "../../core/provers/isabelle/lib/rippling/rulesets/substs.ML"
  ML_file  "../../core/provers/isabelle/lib/induct.ML"
  ML_file  "../../core/provers/isabelle/lib/term_fo_au.ML"  
  ML_file  "../../core/provers/isabelle/lib/term_features.ML"  
  ML_file  "../../core/provers/isabelle/lib//rippling/basic_ripple.ML" 

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

*}


section "general defs"
ML{*
(* Clause GT*)
  fun dbg_lookup tab name = case StrName.NTab.lookup tab name of 
     NONE => (writeln (*"WARNING" *) (name ^ " is not in the table"); NONE)
    | x => x;

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

 fun member_of env pnode [r,d] = 
  Clause_GT.project_terms env pnode r
  |> maps (fn x => Clause_GT.update_var env (IsaProver.E_Trm x) d)
 | member_of _ _ _ = [];

 fun hack_not n0 = case n0 of "not" => "Not"| _ => n0;
 fun top_symbol env pnode [r,Clause_GT.Var p] : IsaProver.env list= 
          let 

            val tops = Clause_GT.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case dbg_lookup env p of
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
            (case dbg_lookup (Clause_GT.Prover.get_pnode_env pnode) p of
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

   fun trm_eq thy (x,y) = Pattern.matches thy ((ignore_true_prop x), (ignore_true_prop y) )
       
   fun eq_term env pnode [r, Clause_GT.PVar p] =
   let val dest = Clause_GT.project_terms env pnode r 
   val ctxt = IsaProver.get_pnode_ctxt pnode 
   val thy = Proof_Context.theory_of ctxt in
   (case dbg_lookup (IsaProver.get_pnode_env pnode) p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
           (case dest of [] =>[]
           | _ =>  if member (trm_eq thy) dest (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => [])
   end
  | eq_term env pnode [r, Clause_GT.Var p] =
   let val dest = Clause_GT.project_terms env pnode r val ctxt = IsaProver.get_pnode_ctxt pnode 
   val thy = Proof_Context.theory_of ctxt in
   (case dbg_lookup env p of
             NONE => []
           | SOME (IsaProver.E_Trm t) => 
                     (case dest of [] =>[]
           | _ =>  if member (trm_eq thy) dest (Syntax.check_term ctxt t) then [env] else [])
           | SOME _ => []) end
  | eq_term env pnode [r, Clause_GT.Term trm] = 
   let 
    val ctxt = IsaProver.get_pnode_ctxt pnode  
    val thy = Proof_Context.theory_of ctxt
    val dest = Clause_GT.project_terms env pnode r in
   (case dest of [] =>[]
    | _ =>  
     if member (trm_eq thy) dest (Syntax.check_term ctxt trm) 
     then [env] else [])
   end
  | eq_term env pnode [r, Clause_GT.Concl] = 
     let val dest = Clause_GT.project_terms env pnode r 
     val ctxt = IsaProver.get_pnode_ctxt pnode 
     val thy = Proof_Context.theory_of ctxt in
     (case dest of [] =>[]
      | _ =>  
       if member (trm_eq thy) dest (IsaProver.get_pnode_concl pnode)
       then [env] else [])
     end
  | eq_term _ _ _ = [];

 fun is_term env pnode [r] = (case Clause_GT.project_terms env pnode r of [] => [] |_ => [env])
 |  is_term _ _ _ = LH.log_undefined "GOALTYPE" "is_term" []

 fun is_var0 trm = Term.is_Free trm orelse Term.is_Var trm 
 fun is_var env pnode [Clause_GT.Concl] = 
  IsaProver.get_pnode_concl pnode
  |> ignore_true_prop
  |> is_var0
  |> (fn x => if x then [env] else [])
  | is_var env _ [Clause_GT.Var v] = 
     (case dbg_lookup env v of
       NONE => []
     | SOME (IsaProver.E_Trm t) => 
            if ((is_var0 o ignore_true_prop) t)
            then [env]
            else []
     | _ => [] )
  | is_var env _ [Clause_GT.PVar v] = 
     (case dbg_lookup env v of
       NONE => []
     | SOME (IsaProver.E_Trm t) => 
            if ((is_var0 o ignore_true_prop) t)
            then [env]
            else []
      | _ => [])
  | is_var _ _ _ = []

 exception dest_trm_exp of string 
 fun dest_trm env pnode [trm, p1, p2] = 
  (let 
    val trm' = case Clause_GT.project_terms env pnode trm of [x] => ignore_true_prop x 
      | _ => raise dest_trm_exp "only one term is expected"
    val (trm1, trm2) = dest_comb trm' 
  in 
     Clause_GT.update_var env (Clause_GT.Prover.E_Trm trm1) p1
    |> maps (fn e => Clause_GT.update_var e (Clause_GT.Prover.E_Trm trm2) p2)
  end handle _ => [] )
  | dest_trm _ _ _ = []

 fun empty_list (env : IsaProver.env) _ [Clause_GT.PVar v] = 
  (case dbg_lookup env v of SOME (IsaProver.E_L[]) => [env]
  | _ => [])
 | empty_list (env : IsaProver.env) _ [Clause_GT.Var v] = 
  (case dbg_lookup env v of SOME (IsaProver.E_L[])  => [env]
  | _ => [])
 | empty_list _ _ _ = []


 fun bound (env : IsaProver.env) _ [Clause_GT.PVar v] = 
  (case dbg_lookup env v of (SOME _) => [env]
  | _ => [])
 | bound (env : IsaProver.env) _ [Clause_GT.Var v] = 
 (case dbg_lookup env v of (SOME _) => [env]  | _ => [])
 | bound _ _ _ = LH.log_undefined "GOALTYPE" "bound" []

*}

ML{*
structure Sledgehammer_Tactics =
struct

open Sledgehammer_Util
open Sledgehammer_Fact
open Sledgehammer_Prover
open Sledgehammer_Prover_ATP
open Sledgehammer_Prover_Minimize
open Sledgehammer_MaSh
open Sledgehammer_Commands

fun run_prover override_params fact_override i n ctxt goal =
  let
    val thy = Proof_Context.theory_of ctxt
    val mode = Normal
    val params as {provers, max_facts, ...} = default_params thy override_params
    val name = hd provers
    val prover = get_prover ctxt mode name
    val default_max_facts = default_max_facts_of_prover ctxt name
    val (_, hyp_ts, concl_t) = ATP_Util.strip_subgoal goal i ctxt
    val ho_atp = exists (is_ho_atp ctxt) provers
    val reserved = reserved_isar_keyword_table ()
    val css_table = clasimpset_rule_table_of ctxt
    val facts =
      nearly_all_facts ctxt ho_atp fact_override reserved css_table [] hyp_ts concl_t
      |> relevant_facts ctxt params name
             (the_default default_max_facts max_facts) fact_override hyp_ts
             concl_t
      |> hd |> snd
    val problem =
      {comment = "", state = Proof.init ctxt, goal = goal, subgoal = i, subgoal_count = n,
       factss = [("", facts)]}
  in
    (case prover params (K (K (K ""))) problem of
      {outcome = NONE, used_facts, ...} => used_facts |> map fst |> SOME
    | _ => NONE)
    handle ERROR message => (warning ("Error: " ^ message ^ "\n"); NONE)
  end

fun sledgehammer_with_metis_tac ctxt override_params fact_override i th =
  let val override_params = override_params @ [("preplay_timeout", "0")] in
    case run_prover override_params fact_override i i ctxt th of
      SOME facts =>
      Metis_Tactic.metis_tac [] ATP_Problem_Generate.combs_or_liftingN ctxt
          (maps (thms_of_name ctxt) facts) i th
    | NONE => Seq.empty
  end

end;

  fun sledgehammer ctxt i = 
    Sledgehammer_Tactics.sledgehammer_with_metis_tac ctxt []  {add = [], del = [], only = false} i
*}

ML{*
(* tactic definition *)
fun unfolding [IsaProver.A_L thml] ctxt _ = map (fn (IsaProver.A_Thm th) => th) thml |> unfold_tac ctxt
| unfolding _ _ _ = LH.log_undefined "TACTIC" "unfolding" no_tac;

fun simp ctxt = 
  safe_asm_full_simp_tac (Raw_Simplifier.clear_simpset ctxt
  |> (Simplifier.add_simp (List.nth (Proof_Context.get_fact ctxt (Facts.named "simp_thms"), 10)))
  |> (Simplifier.add_simp (List.nth (Proof_Context.get_fact ctxt (Facts.named "simp_thms"), 11))))

fun simp_only_tac thml ctxt= fold Simplifier.add_simp thml (Raw_Simplifier.clear_simpset ctxt) |> simp_tac;


fun subgoals_tac [IsaProver.A_Trm t] ctxt = subgoal_tac ctxt (IsaProver.string_of_trm ctxt t)
| subgoals_tac _ _ =  K no_tac

fun rule [IsaProver.A_Thm thm] _  =  rtac thm
| rule  _ _ =  K no_tac;
fun erule [IsaProver.A_Thm thm] _  = etac thm
| erule  _ _ =  K no_tac;
fun drule [IsaProver.A_Thm thm] _  = dtac thm
| drule  _ _ =  K no_tac;
fun simp_only [IsaProver.A_Thm thm] = simp_only_tac [thm]
| simp_only _  =  K (K no_tac);

fun rule_tac [IsaProver.A_Trm trm, IsaProver.A_Thm thm] ctxt = 
let val _ = writeln "in rule tac" in
  res_inst_tac ctxt  [(("x",0), (IsaProver.string_of_trm ctxt trm))] thm end
|  rule_tac  _ _ = let val _ = writeln "in rule tac2" in
 K no_tac end; 

fun rule_tac1 [IsaProver.A_Str str, IsaProver.A_Trm trm, IsaProver.A_Thm thm] ctxt = 
  res_inst_tac ctxt  [((str,0), (IsaProver.string_of_trm ctxt trm))] thm
|  rule_tac1  _ _ =  K no_tac;


fun erule_tac1 [IsaProver.A_Str str, IsaProver.A_Trm trm, IsaProver.A_Thm thm] ctxt = 
  eres_inst_tac ctxt  [((str,0), (IsaProver.string_of_trm ctxt trm))] thm
|  erule_tac1  _ _ =  K no_tac;

fun erule_tac2 
  [IsaProver.A_Str str1, IsaProver.A_Str str2, 
   IsaProver.A_Trm trm1, IsaProver.A_Trm trm2, IsaProver.A_Thm thm] ctxt = 
  eres_inst_tac ctxt  [((str1,0), (IsaProver.string_of_trm ctxt trm1)), 
                       ((str2,0), (IsaProver.string_of_trm ctxt trm2))] thm
| erule_tac2  _ _ = LH.log_undefined "TACTIC" "erule_tac2" (K no_tac);

fun subst_tac [IsaProver.A_Str thmn] ctxt = 
  let val thms =  Find_Theorems.find_theorems ctxt NONE NONE false 
    [(true, Find_Theorems.Name thmn)] |> snd |> map snd in
  EqSubst.eqsubst_tac ctxt [0] thms  end
|  subst_tac [IsaProver.A_Thm thm] ctxt = 
  EqSubst.eqsubst_tac ctxt [0] [thm]  
| subst_tac  _ _ =  K no_tac;
 
fun asm_subst_tac [IsaProver.A_Str thmn] ctxt = 
  let val thms =  Find_Theorems.find_theorems ctxt NONE NONE false 
    [(true, Find_Theorems.Name thmn)] |> snd |> map snd in
  EqSubst.eqsubst_asm_tac ctxt [0] thms  end
|  asm_subst_tac [IsaProver.A_Thm thm] ctxt =  
  EqSubst.eqsubst_asm_tac ctxt [0] [thm]
| asm_subst_tac  _ _ =  K no_tac;
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
  of [] => [StrName.NTab.update (v, IsaProver.E_L []) env]
  | ret => [StrName.NTab.update 
     (v, IsaProver.E_Trm (
      hd ret (* only get one ele *)
      |> dest_comb |> snd (* dest true prop *)
      |> dest_comb |> snd) (* dest Not *)
     ) env])
| ENV_check_ccontr _ _ _ = []

fun ENV_bind _ [IsaProver.A_Trm t, IsaProver.A_Var v] env :  IsaProver.env list = 
  [StrName.NTab.update (v, IsaProver.E_Trm t) env]
 | ENV_bind _ _ _ = [];  
*}

section "one point rules"
(* Definitions for the one point rule, from GG *)
-- "number of top-level exists and the rest"
ML{*
  fun top_exists' n (Const ("HOL.Ex",_) $ Abs(_,_,t)) = top_exists' (n+1) t
   |  top_exists' n t = (n,t);
  val top_exists = top_exists' 0;
   *}
   
-- "returns bound term and De-Bruijn (relative to top-level insts)"   
(* TO DO: should maybe check t as well, .e.g if term t has any existentials *)
ML{*
    fun check_bound new n = n >= new;

    fun onep_match newbinders (Const ("HOL.eq",_) $ Bound n $ t) =
      if check_bound newbinders n then SOME (t,n-newbinders) else NONE
     |  onep_match newbinders (Const ("HOL.eq",_) $ t $ Bound n) = 
           if check_bound newbinders n then SOME (t,n-newbinders) else NONE
     |  onep_match newbinders (Abs(_,_,t)) = onep_match (newbinders+1) t
     |  onep_match newbinders (t1 $ t2) = 
         let  val res = onep_match newbinders t1
         in case res of 
             SOME _ => res
           | NONE   =>  onep_match newbinders t2 
         end
     |  onep_match _ _ = NONE
     
    fun allp_match newbinders (Const ("HOL.eq",_) $ Bound n $ t) =
      if check_bound newbinders n then [(t,n-newbinders+1)] else []
     |  allp_match newbinders (Const ("HOL.eq",_) $ t $ Bound n) = 
           if check_bound newbinders n then [(t,n-newbinders+1)] else []
     |  allp_match newbinders (Abs(_,_,t)) = allp_match (newbinders+1) t
     |  allp_match newbinders (t1 $ t2) = 
         (allp_match newbinders t1) @ (allp_match newbinders t2)
     |  allp_match _ _ = []     
*}

-- "the matching term"
ML {*
 fun matching_term t = 
   let
     val (n,t') = top_exists  (ignore_true_prop t);
   in
     if n = 0 then NONE
     else 
        case onep_match 0 t' of
           NONE => NONE
         | SOME (t,_) => SOME t
   end  
*}


ML{*

val t = @{prop "\<exists>y x . ((y > x) \<and> (y = (1::int)) \<and> (x + y = 5))"};
(* get the number of ex quantifier at the top, as well as the term bound by quantifier *)
val (n,t') = top_exists (ignore_true_prop t);

val ms =  allp_match 0 t';

Syntax.pretty_term @{context} t' |> Pretty.writeln
*}
-- depth
ML{*
 fun tdepth k t =
   let
     val (n,t') = top_exists (ignore_true_prop t);
     val ms =  allp_match 0 t'
     fun get [] = NONE
      | get ((nt,d)::ls) = 
         if nt = k then SOME (n-d) else get ls 
   in
     get ms 
   end 
   
 fun tless str1 str2 = 
   case (Int.fromString str1,Int.fromString str2) of
     (SOME v1,SOME v2) => SOME (v1 < v2)
    | (_,_) => NONE
*}

ML{*
  
  val t1 = @{term "? b1 b2 b3. P b1 \<and> b2 = 0"};
  val t2 = @{term "? b2. b2 = 0"};
  val t3 = @{term "? b2. ! x. ? b3. b3 = 0"};
*}

ML{*
 val (SOME v) =  matching_term t1;
 tdepth v t1
*}

section "Atomic environment tactics"
ML{*
  fun ENV_onep_match 
         _ [IsaProver.A_Trm t, IsaProver.A_Var v] 
        (env : IsaProver.env): IsaProver.env list =
    (case matching_term t of
      NONE => []
     | SOME t' => [StrName.NTab.update (v, IsaProver.E_Trm t') env])
   | ENV_onep_match _ _ _ = [];
     
  fun ENV_exists_depth 
         _ [IsaProver.A_Trm t, IsaProver.A_Trm k, IsaProver.A_Var v] 
        (env : IsaProver.env): IsaProver.env list =
    (case tdepth k t of
      NONE => []
     | SOME (n) => [StrName.NTab.update (v, IsaProver.E_Str (Int.toString n)) env])
   | ENV_exists_depth _ _ _ = LH.log_undefined "TACTIC" "ENV_exists_depth" []
*}

section "Atomic goal types"

-- "checks if it is one point rule"
(* also add support for variable? *)
ML{*
 fun is_one_point env pnode [v] = 
   (case Clause_GT.project_terms env pnode v of
    [t] =>
      (case matching_term t of
        NONE => []
       | _ => [env])
    | _ => [])
  | is_one_point _ _ _ = [];
*}

-- "check if it is less than"
ML{*
(* note that, isabelle bind order is reversed, EX x, y, BOUND $1 $2*)
 fun less env _ [Clause_GT.Name l,Clause_GT.Name r] = 
      (case (Int.fromString l,Int.fromString r) of
        (SOME li,SOME ri) => if li < ri then [env] else []
       | _ => [])
  | less env pnode [Clause_GT.PVar l,r] = 
      (case dbg_lookup (Clause_GT.Prover.get_pnode_env pnode) l of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str ls) => 
                 less env pnode [Clause_GT.Name ls,r]
             | SOME _ => [])       
  | less env pnode [l,Clause_GT.PVar r] = 
      (case dbg_lookup (Clause_GT.Prover.get_pnode_env pnode) r of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str rs) => 
                 less env pnode [l,Clause_GT.Name rs]
             | SOME _ => [])   
  | less env pnode [Clause_GT.Var l,r] = 
      (case dbg_lookup env l of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str ls) => 
                 less env pnode [Clause_GT.Name ls,r]
             | SOME _ => [])       
  | less env pnode [l,Clause_GT.Var r] = 
      (case dbg_lookup env r of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str rs) => 
                 less env pnode [l,Clause_GT.Name rs]
             | SOME _ => [])   
  | less _ _ _ = []      
*} 

-- "checks depth  "
ML{*
 fun depth env _ [Clause_GT.Term k,Clause_GT.Term t,Clause_GT.Var s] =
      (case tdepth k t of
          NONE => []
        | SOME (v) => 
           (case dbg_lookup env s of (* check if var bound *)
               NONE => [StrName.NTab.ins (s,Clause_GT.Prover.E_Str (Int.toString v)) env]
             | SOME (IsaProver.E_Str s) => 
                 (case (Int.fromString s) of
                    NONE => []
                  | SOME n => if v = n then [env] else [])
             | SOME _ => []))
  | depth env _ [Clause_GT.Term k,Clause_GT.Term t,Clause_GT.Name s] =
     (case tdepth k t of
       NONE => []
     | SOME (v) => 
        (case Int.fromString s of 
          NONE => []
         | (SOME n) => if v = n then [env] else []))  
(*  | depth env pnode [k,Clause_GT.PVar t,y] = (* PVar in second *)
      (case dbg_lookup (Clause_GT.Prover.get_pnode_env pnode) t of
               NONE => []
             | SOME (Clause_GT.Prover.E_Trm te) => 
                 depth env pnode [k,Clause_GT.Term te,y]
             | SOME _ => [])   *)
 | depth env pnode [v1, v2, y] = (* PVar in first *)
      (case Clause_GT.project_terms env pnode v1 of
               [] => []
             | [t1] =>
              (case Clause_GT.project_terms env pnode v2 of
               [] => []
               | [t2] => depth env pnode [Clause_GT.Term t1, Clause_GT.Term t2,y]
               | _ => [])
             |  _ => [])  
  | depth _ _ _ = LH.log_undefined "GOALTYPE" "ENV_exists_depth" [];
*}

-- "check if term is top-level"

ML{*
 val debug_msg = (*writeln;*) K;
 fun is_top env _ [Clause_GT.Term k,Clause_GT.Term t] = 
      ( case tdepth k t of
         NONE => ((debug_msg "got non in is_top");[])
       | SOME 0 => [env]
       | SOME x =>(debug_msg ("got some other in is_top: "^(Int.toString x)); []))
   (* the two variable cases (assumes bound) *)
   | is_top env pnode [Clause_GT.Term k,r] = 
     (case Clause_GT.project_terms env pnode r of 
       [x] => is_top env pnode [Clause_GT.Term k , Clause_GT.Term x]
     | _ => [])
   | is_top env pnode [l, r] = 
     (case Clause_GT.project_terms env pnode l of 
       [x] => is_top env pnode [Clause_GT.Term x ,  r]
     | _ => [])
   | is_top _ _ _ = [];

*}



section "setup"
(* Add all atomics and GT defs *)
ML{*
val clause_cls = 
 "is_goal(Z) :- eq_term(concl, Z)." ^
 "is_not_goal(Z) :- not(is_goal(Z))." ^
 "c(X) :- top_symbol(concl, X)." ^
 "h(Z) :- member_of(hyps,X), top_symbol(X,Z)." ^
(* rippling *)
 "hyp_embeds() :- member_of(hyps,X),embeds(X,concl)." ^
 "hyp_bck_res() :- member_of(hyps,X),sub_term(X,concl)." ^
 "match_lr (X,Y,Z) :- sub_term(Y, X)." ^
 "match_lr (X,Y,Z) :- sub_term(Z, X)." ^
 "hyp_subst() :- member_of(hyps,X),top_symbol(X,eq),dest_term(X,Y,R),dest_term(Y,_,L),match_lr(concl,L,R)." ^
 "measure_reduces(X) :- member_of(hyps,Y),embeds(Y,concl),measure_reduced(Y,X,concl)." ^
 "rippled() :- hyp_bck_res(). " ^ "rippled() :- hyp_subst()." ^
 "can_ripple(X) :- has_wrules(X), !hyp_bck_res()." ^
(* structure *)
 "pre_post(X,Y) :- bound(X), bound(Y)."^
(* hca *)
 "has_cases(X,Y) :- is_term(X), is_term(Y)." ^
(* one point *)
 "reduced(X,N) :- !is_top(X,concl),depth(X,concl,D),less(D,N)."
(* end of rippling *)
;

 val data_atom = 
  Clause_GT.default_data
(* general atomics *)
  |> Clause_GT.add_atomic "top_symbol" top_symbol 
  |> Clause_GT.add_atomic "eq_term" eq_term 
  |> Clause_GT.add_atomic "is_term" is_term 
  |> Clause_GT.add_atomic "dest_term" dest_trm 
  |> Clause_GT.add_atomic "is_var" is_var 
  |> Clause_GT.add_atomic "empty_list" empty_list
  |> Clause_GT.add_atomic "bound" bound
  |> Clause_GT.add_atomic "member_of" member_of
(* one point rule *)
  |> Clause_GT.add_atomic "is_one_point" is_one_point
  |> Clause_GT.add_atomic "is_top" is_top
  |> Clause_GT.add_atomic "depth" depth
  |> Clause_GT.add_atomic "less" less
(* rippling *)
  |> Clause_GT.add_atomic "inductable" inductable
  |> Clause_GT.add_atomic "has_wrules" has_wrules
  |> Clause_GT.add_atomic "embeds"
    (cl_is_f (cl2_wraper TermFeatures.ctxt_embeds))
  |> Clause_GT.add_atomic "sub_term" (cl_is_f (cl2_wraper (TermFeatures.is_subterm o Proof_Context.theory_of)))
  |> Clause_GT.add_atomic  "measure_reduced" (cl_is_f (cl3_wraper (TermFeatures.is_measure_decreased)))
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data Prover.default_ctxt "") @ x);

  val data =  
  data_atom 
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_cls) @ x);

*}


section "steup psgraph files"
ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/sttt/psgraph/"
  val dist_file = "dist.psgraph"
  val onep0_file = "onepoint0.psgraph"
  val onep_file = "onepoint.psgraph"
  val rippling_file = "rippling.psgraph"; 
*}
 
ML{*
  val onep0 = PSGraph.read_json_file (SOME data) (pspath ^ onep0_file);
*}


setup {* PSGraphIsarMethod.add_graph ("onep0", onep0) *}
(*setup {* PSGraphIsarMethod.add_graph ("onep", onep) *}*)






end
