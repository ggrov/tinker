theory ai4fm
imports "../../core/provers/isabelle/clausal/CIsaP"  
begin

section "Atomic tactics"

-- "witness tactic"
ML{*-
 fun witness [Prover.E_Trm t] ctxt n =
  res_inst_tac ctxt  [(("x",0), Prover.string_of_trm ctxt t)] @{thm exI} n;
*} 
ML{*
 fun witness [Prover.A_Trm t] ctxt n =
  res_inst_tac ctxt  [(("x",0), Prover.string_of_trm ctxt t)] @{thm exI} n;
*} 

ML{*
(* TODO: to provide the definition of subs here *)
 fun subst _ _ _ = all_tac;
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

(* GOALTYPES *)
ML{*
  fun check_top str =  
   case Int.fromString str of (SOME 0) => true | _ => false;

  fun top_bound [Prover.A_Str s] env = if check_top s then [env] else []
   |  top_bound [Prover.A_Var s] env = 
         (case StrName.NTab.lookup env s of
           NONE => []
         | SOME s => if check_top s then [env] else []);

  fun has_match_exist [Prover.A_Trm t,Prover.A_Var X,Prover.A_Var L] env =
    case ENV_match_exist [Prover.A_Trm t,Prover.A_Var X,Prover.A_Var L] env of
      [] => [] | _ => [env];
*} 


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

ML{*
  (* change this to the location of your local copy *)
  val tinker_path = "/media/sf_GIT/tinker/" 
  val pspath = tinker_path ^ "src/dev/psgraph/"; (* where all psgraph under dev are located here *)
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}


ML{*
  (* change this to the location of your local copy *)
  val tinker_path = "/Users/yuhuilin/Documents/Workspace/StrategyLang/psgraph/" 
  val pspath = tinker_path ^ "src/dev/psgraph/"; (* where all psgraph under dev are located here *)
  val prj_path = tinker_path ^ "src/dev/ai4fm/" (* the project file *)
*}

ML{*-
  val trm = @{term "\<exists> x y z. P \<and> 0 = z"};
 
 fun witness (Prover.E_Str s) ctxt n =
  res_inst_tac ctxt  [(("x",0),s)] @{thm exI} n;

 fun match_exists t = 

*} 

lemma "\<exists> x y z. P \<and> 0 = z"
 apply (subst ex_comm)
 back
 apply (subst ex_comm)
 apply (tactic testtac)
 apply (rule_tac x=0 in exI)
 oops
thm ex_comm


(* a quick test *)
ML{* val ps = PSGraph.read_json_file (prj_path ^"witnessing.psgraph") *} 


ML{*-   
Tinker.start_ieval @{context} (SOME ps) (SOME []) (SOME @{prop "P\<longrightarrow> P"});
*}
ML{* -
  TextSocket.safe_close();
*}


end

 
