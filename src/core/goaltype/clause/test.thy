theory test
imports
  "../../build/isabelle/BasicGoalTyp"  
  "../../provers/isabelle/basic/build/BIsaP"    
begin

  ML_file "goaltype.sig.ML"
  ML_file "goaltype.ML"                                                                                                                          
  
  section "Test for Isabelle"

  -- "instantiating with prover"
  ML{*
    structure ClauseGoalTyp = ClauseGTFun(structure Prover = IsaProver val struct_name = "ClauseGoalTyp");  
    structure C = ClauseGoalTyp;
    C.Var;
  *}


  ML{*
    structure C2 : CLAUSE_GOALTYPE = C;       
  *}

  ML{*
    structure C2 : BASIC_GOALTYPE = C;       
  *}

  (* TO DO: generalise to lists: and handle cases with multiple results (e.g. all_symbols) *)
  ML{*
    fun LEFT_T (A $ _) = SOME A
     |  LEFT_T _ = NONE

    fun RIGHT_T (_ $ B) = SOME B
     |  RIGHT_T _ = NONE

    (* not sure about this *)
    fun CONST_T (Const (s,_)) = SOME s            
     |  CONST_T (Var ((s,_),_)) = SOME s
     |  CONST_T (Free (s,_)) = SOME s
     |  CONST_T _ = NONE;
  *}


 ML{*
   (* schema to simplify term to term (partial) functions *)
  
   (* FIXME: handle all cases with trms *)
   (* note assumes existential reading *)
   fun trm_schema trm_eq f env pnode [r,C.Var v] = 
     let 
       val t1 = C.project_terms env pnode r
       fun app_one t = 
            (case f t of 
              NONE => []         
            | SOME t' => [StrName.NTab.ins (v,C.Prover.E_Trm t') env])
     in 
         (case StrName.NTab.lookup env v of
             NONE => maps app_one t1
           | SOME _ => []) (* not sure what the semantics here should be: only a single trm? *)
          end
    |  trm_schema trm_eq f env pnode [t1,t2] = 
     let 
       val t1 = C.project_terms env pnode t1
       val t2 = C.project_terms env pnode t2
     in
       if exists (fn et1 => exists (fn et2 => 
              case f et1 of NONE => false | SOME res => trm_eq (res,et2)) t2) t1 
       then [env] else []
     end
    |  trm_schema _ _ _ _ [] = []
    |  trm_schema trm_eq f env pnode (x::xs) =
        maps (fn r => trm_schema trm_eq f env pnode [x,r]) xs; 
                 
   val LEFT = trm_schema (K false) LEFT_T;
   val RIGHT = trm_schema (K false) RIGHT_T;
     

 *}

  ML{*
   (* schema to simplify term to term (partial) functions *)
  
   (* FIXME: handle all cases with trms *)
   (* note assumes existential reading *)
   fun trm_str_schema f env pnode [r,C.Var v] : env list = 
     let 
       val t1 = C.project_terms env pnode r
       fun app_one t =  
            (case f t of 
              NONE => [] 
            | SOME t' => [StrName.NTab.ins (v,C.Prover.E_Str t') env])
     in 
         (case StrName.NTab.lookup env v of
             NONE => maps app_one t1
           | SOME _ => []) (* not sure what the semantics here should be: only a single var? *)
          end
    |  trm_str_schema f env pnode [t1,t2] = 
     let 
       val r1 = C.project_terms env pnode t1
       val r2 = C.project_name env pnode t2
     in
       if exists (fn et1 => exists (fn et2 => 
              case f et1 of NONE => false | SOME res => res = et2) r2) r1 
       then [env] else []
     end
    |  trm_str_schema _ _ _ [] = []
    |  trm_str_schema f env pnode (x::xs) =
        maps (fn r => trm_str_schema f env pnode [x,r]) xs; 

  val CONST = trm_str_schema CONST_T;

  *}

  ML{*
  val ignore_module = List.last o String.tokens (fn ch => #"." = ch) ;

    fun top_level_str (Const (s,_)) =  SOME (ignore_module s)
  | top_level_str ((Const ("all",_)) $ f) = top_level_str f
  | top_level_str ((Const ("prop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("HOL.Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("Trueprop",_)) $ f) = top_level_str f
  | top_level_str ((Const ("==>",_)) $ _ $ f) = top_level_str f
  | top_level_str (f $ _) = top_level_str f
  | top_level_str (Abs (_,_,t)) = top_level_str t
  | top_level_str _ = NONE;

  val top_level_new = trm_str_schema top_level_str;
*}
 
  (* to do: update to use above combinators *)
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

   fun top_symbol env pnode [r,C.Var p] : env list= 
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

 ML{*
   val res = IsaProver.E_Str "t";
   val pnode = IsaProver.update_pnode_env (StrName.NTab.ins ("x",res)) pnode;
 *}

 -- "should work"

 ML{*
   C.imatch data pnode ("topconcl",[C.PVar "x"]);   
 *}

 -- "should fail - y not bound"
 ML{*
   C.imatch data pnode ("topconcl",[C.PVar "y"]);   
 *}

 -- "hypothesis"
  ML{*
   val data = C.add_atomic "top_symbol" top_symbol C.default_data; 
   val t = @{prop "A \<Longrightarrow> B \<Longrightarrow> A \<and> B \<Longrightarrow> B \<and> A"}; 
   val (pnode,pplan) = IsaProver.init @{context} [] t;                         
  *}


  ML{*
   C.imatch data pnode ("top_symbol",[C.Concl,C.Name "conj"]);
   C.type_check data pnode ("top_symbol",[C.Hyps,C.Name "conj"]);
  *}        

 ML{*
   val fdef1 = "mtop(X) :- top_symbol(X,conj).";
   val data = C.add_defs ((scan_def fdef1)) data;
   val fdef2 = "mfilter(X) :- filter(mtop,hyps,X).";
   val data = C.add_defs ((scan_def fdef2)) data;
   C.imatch data pnode ("mfilter",[C.Var "Y"]);
 *}

 -- "recursion"
 ML{*
   val left_def = "leftmost(X,Y) :- LEFT(X,Z), leftmost(Z,Y).\n"
              ^ "leftmost(X,Y) :- CONST(X,Y).";
   val right_def = "rightmost(X,Y) :- RIGHT(X,Z), rightmost(Z,Y).\n"
              ^ "rightmost(X,Y) :- CONST(X,Y).";
   val data = data 
           |> C.add_atomic "LEFT" LEFT  
           |> C.add_atomic "RIGHT" RIGHT  
           |> C.add_atomic "CONST" CONST  
           |> C.add_defs ((scan_def left_def))
           |> C.add_defs ((scan_def right_def));
*}
ML{*
   C.imatch data pnode ("leftmost",[C.Concl,C.Var "Y"]);
*}

ML{*
   C.imatch data pnode ("rightmost",[C.Concl,C.Var "Y"]);
*}

ML{*
   C.imatch data pnode ("any",[]);
*}
  

 -- "Parsing"
 ML{*
   C.scan_body @{context} (C.explode "topsymbol(forall.HOL,?x).");
   C.scan_name (C.explode "A(x,y)");
   C.scan_prog  @{context} (C.explode "f(A) :- f(x),g(X,Y)."); 
   C.scan_prog  @{context} (C.explode "f(A) :- filter(top_symbol,X,Y)."); 
 *}

 ML{*
   val def1 = "f(Z) :- top_symbol(concl,_,conj) , has_symbols(hyps,T,conj), has_symbols(T,Z,implies).";
   val def2 = "f(Z) :- top_symbol(concl,Z,conj).";
   val data = C.scan_data @{context} def1;
 *}



end
