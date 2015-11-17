theory ai4fm
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin

section "Hidden case analysis"


 lemma "P \<Longrightarrow> Q \<Longrightarrow> R \<Longrightarrow> X"
 apply (subgoal_tac "A \<or> B")
apply (erule disjE) (* need an OF *) 
oops

subsection "Atomic tactics"

ML{*
 fun mk_disj A B = Const ("HOL.disj", @{typ "bool \<Rightarrow> bool \<Rightarrow> bool"}) $ A $ B; 
 fun disj_subgoal [Prover.E_Trm A,Prover.E_Trm B] ctxt n = 
   subgoal_tac ctxt (Prover.string_of_trm ctxt (mk_disj A B)) n;
 fun cases [Prover.E_Trm A,Prover.E_Trm B] ctxt n =
  res_inst_tac ctxt  [(("P",0), Prover.string_of_trm ctxt A),(("Q",0), Prover.string_of_trm ctxt B)] @{thm disjE} n; 
*}

-- test
ML{*
val t1 = subgoal_tac @{context} "a | b" 1;
val t = eres_inst_tac @{context}  [(("P",0), "a"),(("Q",0), "b")] @{thm disjE} 1; 
*}

lemma "x \<or> y \<Longrightarrow> c"
 apply (tactic "t1")
 apply (tactic "t")
 oops

subsection "Goal types"

-- "general code to be reused"
ML{*
  structure C = Clause_GT;
  val prj_trms = C.project_terms;
  
  fun env_of_bool c env = if c then [env] else [];
  fun env_of_list [] _ = []
   |  env_of_list (x::xs) env = [env];
  *}

ML{*
 (* project_terms; *)
 fun is_term env pnode [arg] = 
  case prj_trms env pnode arg of
    [] => []
   | _ => [env];

fun matches (t1,t2) ctxt = 
 case Seq.pull(Unify.matchers (Proof_Context.theory_of ctxt) [(t1,t2)]) of
  NONE => false
  | _ => false;
  
fun contains env pnode [parg,targs] = 
 let
   val pts = prj_trms env pnode parg
   val tts = prj_trms env pnode targs
   val ctxt = Prover.get_pnode_ctxt pnode
 in
   case pts of 
     [t] => (case exists (fn t' => matches (t,t') ctxt) tts of
                     true => [env] | false => [])
    | _ => []
 end;
 
 val data = C.add_atomic "is_term" is_term C.default_data
   |> C.add_atomic "contains" contains;

*}

section "Witnessing"

lemma "\<exists> x y z. P \<and> 0 = z"
 apply (subst ex_comm)
 back
 apply (subst ex_comm)
 apply (rule_tac x=0 in exI)
 oops

subsection "Atomic tactics"


-- "witness tactic"
ML{*
 fun witness [Prover.A_Trm t] ctxt n =
  res_inst_tac ctxt  [(("x",0), Prover.string_of_trm ctxt t)] @{thm exI} n;
*} 

-- "substitution tactic"
ML{*
 fun subst [Prover.A_Thm thm] ctxt = 
   EqSubst.eqsubst_tac ctxt [0] [thm];
*}

-- "find and bind existential"
ML{*

 fun interval inter (Const ("HOL.Ex",_) $ Abs (_,_, B)) = interval (inter+1) B
  |  interval inter T = (inter,T);

 val check_dangling = not o Term.is_open;

 fun add_bnd (inter,cnt) ind t = if (ind > cnt) andalso check_dangling t then [(inter+cnt-ind,t)] else [];

 (* *)
 fun check_subtrm (inter,cnt)  ((Const ("HOL.eq", _)) $ (Bound n) $ B) = 
     (add_bnd (inter,cnt) n B) @ check_subtrm (inter,cnt) B
  | check_subtrm (inter,cnt)  ((Const ("HOL.eq", _)) $ B $ (Bound n)) = 
     (add_bnd (inter,cnt) n B) @ check_subtrm (inter,cnt) B
  | check_subtrm (inter,cnt)  (Abs (_,_, B)) = check_subtrm (inter,cnt+1) B
  | check_subtrm (inter,cnt) (A $ B) = (check_subtrm (inter,cnt) A) @ (check_subtrm (inter,cnt) B)
  | check_subtrm _ _ = []

 fun get_res t = 
   let 
     val (inter,t') = interval (0-1) t
   in
    if inter = (0-1) 
     then [] 
     else check_subtrm (inter,0) t'
  end;


 fun ENV_match_exist [Prover.A_Trm t,Prover.A_Var X,Prover.A_Var L] env = 
  let 
    val res = get_res t
    fun update_env (v,t) = 
       env |> StrName.NTab.update (L, Prover.E_Str (Int.toString v))
           |> StrName.NTab.update (X, Prover.E_Trm t)
    in
      map update_env res
    end;
*}

-- "unbinds given variables from env"
ML{*
  fun ENV_unbind xs env = 
   let
     fun unb (Prover.A_Var t) env = StrName.NTab.delete t env
      |  unb _ env = env
   in 
     [fold unb xs env]
   end
*}

subsection "Goal types"

ML{*
  fun check_top str =  
   case Int.fromString str of (SOME 0) => true | _ => false;
    
  fun top_bound env pnode [n] = 
    env_of_bool (exists check_top (C.project_name env pnode n)) env;
  

  fun has_match_exist env pnode [t] =
     env_of_list (maps get_res (prj_trms env pnode t)) env;
      
 val data = C.add_atomic "top_bound" top_bound data
   |> C.add_atomic "has_match_exist" has_match_exist;
*} 
(*
Name of string (* x,y,x *)
                | Var of string (* X,Y,Z *)
                | PVar of string (* ?x,?y,?z ...*)
                | Concl (* turn into name? *)
                | Hyps (* turn into name? *)
                | Ignore (* turn into name? *)
                | Term of Prover.term 
                | Clause of string * (arg list)
                *)


-- "testing"
ML{*
 val t1 = @{term "? x y z. y = (f t)"};
 val t2 = @{term "! x y z. z=e"};
 val t3 = @{term "a = b"};

 check_dangling t3;
 interval 0 t1;
 get_res t1;
*}


ML{*
  fun has_res t = case get_res t of [] => false | _ => true;
  fun has_top t = t |> get_res |> exists (fn (i,_) => i = 0); 
*}


section "Testing in GUI"

ML{*
  (* change this to the location of your local copy *)
  val tinker_path = "/media/sf_GIT/tinker/" 
  val pspath = tinker_path ^ "src/dev/ai4fm/"; (* where all psgraph under dev are located here *)
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}
ML{*-
  (* change this to the location of your local copy *)
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/" 
  val pspath = tinker_path ^ "src/dev/ai4fm/"; (* where all psgraph under dev are located here *)
  val pspath = tinker_path ^ "src/dev/psgraph/";
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}
   
ML{*
(* need to support this in the parser of the clause goaltype *)
C.scan_goaltyp @{context} "shape(concl,?P \<or> ?Q).";
*}
ML{*  
val ps = PSGraph.read_json_file (prj_path ^"hiddenCase.psgraph"); 
     val prop = @{prop "P"};
*} 
  
ML{* val ps = PSGraph.read_json_file (prj_path ^"witnessing.psgraph"); 
     val prop = @{prop "\<exists> x y z. P \<and> 0 = z"};
*}  

ML{*-
Tinker.start_ieval @{context} (SOME ps) (SOME []) (SOME prop);    
*}

ML{*-
  TextSocket.safe_close();  
*}

end

 
