theory test
imports
  "../../build/isabelle/BasicGoalTyp"  
  "../../provers/isabelle/basic/build/BIsaP"    
begin

  ML_file "goaltype.ML"                                                                                                                        
  
 section "Test for Isabelle"

  -- "instantiating with prover"
  ML{*
    structure ClauseGoalTyp = ClauseGTFun(IsaProver);  
    structure C = ClauseGoalTyp;
  *}

  ML{*
    structure C2 : BASIC_GOALTYPE = C;       
  *}


 ML{*
   C.scan_body @{context} (C.explode "f(a,b).");
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
