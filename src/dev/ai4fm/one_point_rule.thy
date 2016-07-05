theory one_point_rule
imports ai4fm_setup
begin

section "Utils"

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
     val (n,t') = top_exists t;
   in
     if n = 0 then NONE
     else 
        case onep_match 0 t' of
           NONE => NONE
         | SOME (t,_) => SOME t
   end  
*}

-- depth
ML{*
 fun tdepth k t =
   let
     val (n,t') = top_exists t;
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
     | SOME n => [StrName.NTab.update (v, IsaProver.E_Str (Int.toString n)) env])
   | ENV_exists_depth _ _ _ = [];
*}

section "Atomic goal types"

-- "checks if it is one point rule"
(* also add support for variable? *)
ML{*
 fun is_one_point _ _ [Clause_GT.Term t] = 
   (case matching_term t of
     NONE => []
     | _ => [env])
  | is_one_point _ _ _ = [];
*}

-- "check if it is less than"
ML{*
 fun less env _ [Clause_GT.Name l,Clause_GT.Name r] = 
      (case (Int.fromString l,Int.fromString r) of
        (SOME li,SOME ri) => if li < ri then [env] else []
       | _ => [])
  | less env pnode [Clause_GT.PVar l,r] = 
      (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) l of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str ls) => 
                 less env pnode [Clause_GT.Name ls,r]
             | SOME _ => [])       
  | less env pnode [l,Clause_GT.PVar r] = 
      (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) r of
               NONE => []
             | SOME (Clause_GT.Prover.E_Str rs) => 
                 less env pnode [l,Clause_GT.Name rs]
             | SOME _ => [])   
  | less _ _ _ = []      
*} 

-- "checks depth  "
(* to do: add other cases where term is Var? I am not sure if this makes any sense though*)
ML{*
 fun depth env _ [Clause_GT.Term k,Clause_GT.Term t,Clause_GT.Var s] =
      (case tdepth k t of
          NONE => []
        | SOME v => 
           (case StrName.NTab.lookup env s of (* check if var bound *)
               NONE => [StrName.NTab.ins (s,Clause_GT.Prover.E_Str (Int.toString v)) env]
             | SOME (IsaProver.E_Str s) => 
                 (case (Int.fromString s) of
                    NONE => []
                  | SOME n => if v = n then [env] else [])
             | SOME _ => []))
  | depth env _ [Clause_GT.Term k,Clause_GT.Term t,Clause_GT.Name s] =
     (case tdepth k t of
       NONE => []
     | SOME v => 
        (case Int.fromString s of 
          NONE => []
         | (SOME n) => if v = n then [env] else []))  
  | depth env pnode [Clause_GT.PVar k,x,y] = (* PVar in first *)
      (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) k of
               NONE => []
             | SOME (Clause_GT.Prover.E_Trm t) => 
                 depth env pnode [Clause_GT.Term t,x,y]
             | SOME _ => [])  
  | depth env pnode [k,Clause_GT.PVar t,y] = (* PVar in second *)
      (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) t of
               NONE => []
             | SOME (Clause_GT.Prover.E_Trm te) => 
                 depth env pnode [k,Clause_GT.Term te,y]
             | SOME _ => [])              
  | depth _ _ _ = [];
*}

            
-- "check if term is top-level"
(* TO DO: what about variable? *)
ML{*
 fun is_top env _ [Clause_GT.Term k,Clause_GT.Term t] = 
      ( case tdepth t k of
         NONE => []
       | SOME 0 => [env]
       | SOME _ => [])
   (* the two variable cases (assumes bound) *)
   | is_top env gnode [Clause_GT.PVar kv,t] =
       (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) kv of
               NONE => []
             | SOME (Clause_GT.Prover.E_Trm k) => 
                 is_top env gnode [Clause_GT.Term k,t]
             | SOME _ => [])  
   | is_top env gnode [k,Clause_GT.PVar tv] =
       (case StrName.NTab.lookup (Clause_GT.Prover.get_pnode_env pnode) tv of
               NONE => []
             | SOME (Clause_GT.Prover.E_Trm t) => 
                 is_top env gnode [k,Clause_GT.Term t]
             | SOME _ => [])     
   | is_top _ _ _ = [];
*}




ML{*
  (* define your local path here *)
  val pspath = OS.FileSys.getDir() ^ "/Workspace/StrategyLang/psgraph/src/dev/ai4fm/"
  val ps_file = "hiddenCase.psgraph";
*}

ML{*
  val clause_def = 
 "is_goal(Z) :- is_term(concl, Z)." ^
 "is_not_goal(Z) :- not(is_goal(Z))." ;

  val data =  
  data 
  |> Clause_GT.update_data_defs (fn x => (Clause_GT.scan_data IsaProver.default_ctxt clause_def) @ x);

  val hca = PSGraph.read_json_file (SOME data) (pspath ^ ps_file);

*}


ML{*-
TextSocket.safe_close();*}  

ML{*-
val g = @{prop "m \<ge> (2::nat) \<Longrightarrow>  P"};
val thm = Tinker.start_ieval @{context} (SOME hca) (SOME []) (SOME g) (* prove the goal *)
          |> EData.get_pplan |> IsaProver.get_goal_thm(* get the theorem *)
*}


ML{*
val g = @{prop "m \<ge> (2::nat) \<Longrightarrow>  P"};
val e = EVal.init hca @{context} [] g |> hd; *}

ML{*
IEVal.eval_any e; 
*}
end
