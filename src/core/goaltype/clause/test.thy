theory test
imports
  "../../build/isabelle/BasicGoalTyp"  
  "../../provers/isabelle/basic/build/BIsaP"    
begin

  ML_file "goaltype.ML"                                                                                                                          
  
  section "Test for Isabelle"

  -- "instantiating with prover"
  ML{*
    structure ClauseGoalTyp = ClauseGTFun(structure Prover = IsaProver val struct_name = "ClauseGoalTyp");  
    structure C = ClauseGoalTyp;
  *}

  ML{*
    structure C2 : BASIC_GOALTYPE = C;       
  *}


  ML{*
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

   fun top_symbol env pnode [r,C.Var p] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup env p of
               NONE => map (fn s => StrName.NTab.ins (p,C.Prover.E_Str s) env) tops
             | SOME (C.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    |  top_symbol env pnode [r,C.Name n] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
             if member (op =) tops n then [env] else []
          end
    |  top_symbol env pnode [r,C.PVar p] = 
          let 
            val tops = C.project_terms env pnode r
                     |> maps top_level_str
          in 
            (case StrName.NTab.lookup (C.Prover.get_pnode_env pnode) p of
               NONE => []
             | SOME (C.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    | top_symbol _ _ [] = []
    | top_symbol _ _ [_,_] = []
    | top_symbol env pnode (x::xs) =
        maps (fn r => top_symbol env pnode [x,r]) xs;   
*}

  consts t :: bool

  ML{*
   val data = C.add_atomic "top_symbol" top_symbol C.default_data; 
   val t = @{prop "t"}; 
   top_level_str t;
   val (pnode,pplan) = IsaProver.init @{context} [] t;                         
  *}

  ML{*
   val env1 = top_symbol StrName.NTab.empty pnode [C.Term t,C.Var "X"];
   val env2 = top_symbol StrName.NTab.empty pnode [C.Term t,C.Name "t"];
   val env3 = top_symbol StrName.NTab.empty pnode [C.Term t,C.Name "test.t"]; 
  *} 

  ML{*
   C.imatch data pnode ("top_symbol",[C.Concl,C.Name "test.t"]);
   C.type_check data pnode ("top_symbol",[C.Concl,C.Name "test.t"]);
  *}        


  ML{*
   val scan_def = C.scan_data @{context};
   val def1 = "topconcl(Z) :- top_symbol(concl,Z).";
   val pdef1 = scan_def def1;
   val data = C.update_data_defs (K pdef1) data;
  *}

  ML{*
   C.imatch data pnode ("topconcl",[C.Name "t"]);
   C.imatch data pnode ("topconcl",[C.Var "X"]);
  *}
  
  ML{*
      val def2 = "atopconcl(X,Y) :- top_symbol(concl,X),top_symbol(concl,Y).";
      val data = C.add_defs ((scan_def def2)) data;
      C.imatch data pnode ("atopconcl",[C.Var "Z",C.Var "Y"]);
  *}

 -- "environment in pnode"
 (* This is wrong! *)
 ML{*
  C.pretty_env;
  Pretty.string_of;
   val res = IsaProver.E_Str "t";
   val pnode = IsaProver.update_pnode_env (StrName.NTab.ins ("x",res)) pnode;
   C.imatch data pnode ("topconcl",[C.PVar "x"]);   
 *}


 -- "OLD STUFF"

 ML{*
   C.scan_body @{context} (C.explode "topsymbol(forall.HOL,?x).");
   C.scan_name (C.explode "A(x,y)");
   C.scan_prog  @{context} (C.explode "f(A) :- f(x),g(X,Y)."); 
 *}

 ML{*
   val def1 = "f(Z) :- top_symbol(concl,_,conj) , has_symbols(hyps,T,conj), has_symbols(T,Z,implies).";
   val def2 = "f(Z) :- top_symbol(concl,Z,conj).";
   val data = C.scan_data @{context} def1;
   val prog = C.set_data_defs data C.default_data;
   val gt = C.scan_goaltyp @{context}  "f(Y)";
   val t = @{prop "(True \<longrightarrow> True \<and> True) \<Longrightarrow> ( True \<and> False) \<Longrightarrow> True \<and> False"};
   val ht = @{prop "True \<longrightarrow> True \<and> False"};
   val (pnode,pplan) = C.Prover.init @{context} [] t;
   C.Prover.get_pnode_hyps pnode;
 *}

-- "JSON test"
ML{*
  val fjson = C.data_to_json prog;
  val tjson = C.data_from_json fjson
*}


ML{*
val env = StrName.NTab.empty;
val d1 = hd data;
val (C.Def (nm,dargs,body)) = d1;
val nenv = C.inst_env pnode env [C.Var "Y"] dargs; 
val [res] = C.top_symbol StrName.NTab.empty pnode [C.Concl, C.Var "Y", C.Name "conj"];
C.override nenv res;
*}

ML{*
val [nenv] =  C.eval_arg prog (hd body) pnode env;
C.return_vars [C.Var "Y"] env dargs nenv;

*}

(*
   fun has_symbols env pnode (t::var::symbs) = 
    let 
      val top = project_terms env pnode t
              |> map (fn t => (t,Prover.symbols t))
      val symbs = map (project_name env) symbs
      (* basically sls subsetof symbs *)
      fun check (_,sls) = List.all (fn g => List.exists (fn x => x = g) symbs) sls
      val member = filter check top
    in  
      case var of
        (Var v) => map (fn (t,_) => StrName.NTab.ins (v,ET_T t) StrName.NTab.empty) member
      | Ignore => [StrName.NTab.empty]
    end;
)*)
ML{*
val top =
C.project_terms env pnode C.Hyps
|> map (fn t => (t,C.Prover.symbols t));
val symbs = map (C.project_name env) [C.Name "conj"];
      fun check (_,sls) = List.all (fn g => List.exists (fn x => x = g) sls) symbs
      val member = filter check top
*}
ML{*
val cl = (hd (tl body));
 C.has_symbols StrName.NTab.empty pnode [C.Hyps, C.Var "Y", C.Name "conj"];;
C.eval_atomic_clause env prog (hd (tl body)) pnode;
C.eval_arg prog (hd body) pnode env;
C.eval_clause StrName.NTab.empty prog d1 gt pnode;
val z = C.eval_clauses (StrName.NTab.empty) prog data gt pnode;

*}

ML{*
val env = hd z;
val args = [C.Var "Y", C.Var "T", C.Name "implies"];
 C.has_symbols env pnode args

*}
(* problems: split + using variables *)
ML{*
 C.split (hd z) env [C.Var "Y"]
*}

 (*
   f(X,Y) :- a(X,Y), b(X,Y).
   f(g(X),Y) :- b(X),c(Y).
   f(g(test),h(test2)).
 *)

(*
  top_symbol(Concl,X) := case lookup(X) of  get_top(Concl)
  top_symbol(X) :- top_symbol(Concl,X).
*)

  

end
