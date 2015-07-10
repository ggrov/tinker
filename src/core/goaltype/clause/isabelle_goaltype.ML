structure IsabelleGT=
struct

  (**************** EXAMPLE ATOMIC GOAL TYPES ******************)


  (**************** EXAMPLE "ENV" TACTICS ******************)

  (* split(X) *)
  fun split env _ [Var v]  = 
    case StrName.NTab.lookup env v of
       SOME (Prover.E_L pt) => map (fn e => StrName.NTab.update (v,e) StrName.NTab.empty) pt
       NONE => [env];

  fun top_symbol env pnode (t::var::symbs) = 
    let 
      val top = project_terms env pnode t
              |> map (fn t => (t,Prover.top_symbol t))
      val symbs = map (project_name env) symbs
      val member = filter (fn (_,g) => List.exists (fn x => x = g) symbs) top
    in 
      if (length member = 0) then []
      else 
        case var of
          (Var v) => if (length member = 1) then 
                      [StrName.NTab.ins (v, ET_T (fst (hd member))) StrName.NTab.empty]
                     else
                      [StrName.NTab.ins (v, LT_T (map fst member)) StrName.NTab.empty]
      | Ignore => [StrName.NTab.empty]
    end;

   fun has_symbols env pnode (t::var::symbs) = 
    let 
      val top = project_terms env pnode t
              |> map (fn t => (t,Prover.symbols t))
      val symbs = map (project_name env) symbs
      (* basically sls subsetof symbs *)
      fun check (_,sls) = List.all (fn g => List.exists (fn x => x = g) sls) symbs
      val member = filter check top
    in  
      if (length member = 0) then []
      else 
        case var of
          (Var v) => if (length member = 1) then 
                      [StrName.NTab.ins (v, ET_T (fst (hd member))) StrName.NTab.empty]
                     else
                      [StrName.NTab.ins (v, LT_T (map fst member)) StrName.NTab.empty]
      | Ignore => [StrName.NTab.empty]
    end;
 
   fun register_atomics tab =  
     tab |> StrName.NTab.ins ("top_symbol",top_symbol)
         |> StrName.NTab.ins ("has_symbols",has_symbols)
         |> StrName.NTab.ins ("split",split);
*}
