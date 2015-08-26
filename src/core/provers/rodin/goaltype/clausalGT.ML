(* Clausal Goal Type function:
  type : env -> pnode -> arg list
  arg =
   Name of string (* x,y,x *)
 | Var of string (* X,Y,Z *)
 | PVar of string (* ?x,?y,?z ...*)
 | Concl (* turn into name? *) 
 | Hyps (* turn into name? *)
 | Ignore (* turn into name? *)
 | Term of Prover.term 
 | Clause of string * (arg list)

 *)

structure C = Clause_GT

  open RodinHelper RJP
  fun is_top_symbol env pnode [C.Var p, C.Name symb] = 

  (writeln ("Var="^p );
    let val temp = StrName.NTab.lookup env p
        val {pname = nodename , env=_} = pnode
    in
      (case StrName.NTab.lookup env p of 
          NONE => []
         |SOME (C.Prover.E_Str s) => 
            let val reply = execute ("GET_TOP_SYMBOL",[("TERM",symb),("NODE", nodename)]) 
                val topsymb= getParam reply "TOPSYMB"
            in
              if symb=topsymb then [env] else []
            end
         |SOME _ => [] 
          )
    end)
            
  fun has_hyp_with_topsymbol env pnode [C.Name n] = 
      let
        val reply = execute ("HAS_HYP_WITH_TOPSYMBOL",[("SYMB",n),("NODE",pnode)])
        val result= getParam reply "RESULT"
      in
        case result of "true" => [env] | _ =>[]
      end
      | has_hyp_with_topsymbol _ _ _ = []

            
  fun no_hyp_with_topsymbol env  (pnode: C.Prover.pnode) [C.Name n] = 
      let
        val reply = execute ("HAS_HYP_WITH_TOPSYMBOL",[("SYMB",n),("NODE",#pname pnode)])
        val result= getParam reply "RESULT"
      in
        case result of "false" => [env] | _ =>[]
      end
      | no_hyp_with_topsymbol _ _ _ = []

  fun auto_provable env (pnode: C.Prover.pnode) [C.Name bool] = 
      let
        val reply = execute ("AUTO_PROVABLE",[("NODE",#pname pnode),("TACTIC","newPP")])
        val result= getParam reply "RESULT"
      in
        if  result = bool then [env] else []
      end
      | auto_provable env pnode [C.Name bool, C.Name tactic] = 
       (let
        val reply = execute ("AUTO_PROVABLE",[("NODE",#pname pnode),("TACTIC",tactic)])
        val result= getParam reply "RESULT"
      in
        if  result = bool then [env] else []
      end)
      | auto_provable _ _ _ = []


  fun top_symbol env pnode [r,C.Var p] = 
          let 
            val tops = C.project_terms env pnode r
          in 
            (case StrName.NTab.lookup env p of
               NONE => map (fn s => StrName.NTab.ins (p,C.Prover.E_Str s) env) tops
             | SOME (C.Prover.E_Str s) => if member (op =) tops s then [env] else []
             | SOME _ => [])
          end
    |  top_symbol env pnode [r,C.Name n] = 
          let 
            val tops = C.project_terms env pnode r
          in 
             if member (op =) tops n then [env] else []
          end
    | top_symbol _ _ [] = []
    | top_symbol _ _ [_,_] = []
    | top_symbol env pnode (x::xs) =
        maps (fn r => top_symbol env pnode [x,r]) xs;   

   val data = C.add_atomic "is_top_symbol" is_top_symbol C.default_data; 
   val data = C.add_atomic "top_symbol" top_symbol data; 
   val data = C.add_atomic "auto_provable" auto_provable data; 
   val data = C.add_atomic "no_hyp_with_topsymbol" no_hyp_with_topsymbol data; 
