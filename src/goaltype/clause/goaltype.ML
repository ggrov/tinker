functor ClauseGTFun(Prover : PROVER) =
struct

  structure Prover = Prover;
  type gt_pred = Prover.context -> Prover.term list -> Prover.term -> bool;
  val exec_buffer : gt_pred option Unsynchronized.ref = Unsynchronized.ref NONE ;
  fun exec_gt_exp (s : string) : gt_pred option = (
    let	val cmd = 
        "ClauseGoalTyp.exec_buffer := ((" ^ s ^ ") |> SOME handle _ => NONE)";
      val _ =  Prover.exec_str cmd;
    in	!exec_buffer
    end
  );
  (**********  data ***********)
  (* grammar: 
       definitions ::= definition [ definitions ]
       definition ::= name [ '(' [ args ] ')' ] [ ':-' body ]
       name ::= low_letter low_letters*
       var ::= cap_letter any_letter*
       args ::= var [',' args]
       body ::= clause [ `.' | `,' body ] 
       single_arg ::= name | var | clause | "term"
       clause ::= name '(' app_args  ')'
       app_args ::= single_arg [`,` app_args ]
   *)
  datatype arg = Name of string 
                | Var of string
                | Concl 
                | Hyps
                | Ignore
                | Term of Prover.term (* fix me: should we make this term? *)
                | Clause of string * (arg list)
  datatype clause = Def of string * string list * arg list
                  | Constraint of arg; (* will this be used at all? *)

  (* imports not supported yet *)
  (* to do: add atomics as a field *)

  (* binding environment: maybe string is sufficient! just use singleton! *)
  datatype env_data = ET_T of Prover.term
                    | LT_T of Prover.term list 
                    | ES_T of string
                    | LS_T of string list

  type env = env_data StrName.NTab.T
  (* I am not sure about env in goalnode - this has to be serialisable! *)
  (* could this be added somewhere else? *)
  datatype gnode = GN of { name : string, env : env }

(*
  type state = env StrName.NTab.T 
*)
  (* This will be very slow : maybe cluster all names and look up list of them? 
       - atomics can then be used as well, giving almost constant lookup...
     datatype newclause = Def of string list * arg list
                        | Atomic of (Prover.arg_data list -> env -> env list)
                        | Constraint of arg list
     data = (newclause list) StrName.NTab.T
  *)

  datatype data = P of {imports : clause list, 
                        defs : clause list,
                        atomics : (env -> Prover.pnode -> arg list -> env list) StrName.NTab.T}  
  type T = string * (arg list);
  
  fun get_gnode_env (GN {env,...}) = env;
  fun goal_name (GN {name,...}) = name;

  fun update_gnode_env f (GN {name,env}) = GN {name = name, env = f env};
  val set_gnode_env = update_gnode_env o K; 

  fun update_gnode_name f (GN {name,env}) = GN {name = f name, env = env};
  val set_gnode_name = update_gnode_name o K; 


  fun update_data_defs f (P {imports,defs,atomics}) =
    P {imports = imports, defs = f defs, atomics = atomics};
  val set_data_defs = update_data_defs o K;

  val default = ("any",[]); (* fixme: does not evaluate *)
  val default_gnode = GN {name = "?", env = StrName.NTab.empty};
  val default_data = P {imports = [], defs = [], atomics = StrName.NTab.empty};

  (* required? *)
  fun eq (t1,t2) = true;
  fun gnode_eq (g1,g2) = true;


  (************************************
    SCAN/PARSE data and goaltype
  *************************************)

 (* scan of letters and identifiers *)
 val valid_id_symbols = ["_"]
 fun valid_letter x = Symbol.is_ascii_identifier x  orelse member (op =) valid_id_symbols x ;
 fun valid_letter_or_digit x = Symbol.is_ascii_identifier x orelse Symbol.is_digit x orelse member (op =) valid_id_symbols x ;
 val scan_letter = Scan.one valid_letter;
 val scan_letter_or_digit =  Scan.one valid_letter_or_digit
 val scan_id  = (scan_letter || $$ "?") -- ((Scan.repeat scan_letter_or_digit) >> implode) >> op ^ ;
 val scan_name  = (scan_letter) -- ((Scan.repeat scan_letter_or_digit) >> implode) >> op ^ ;

 (* turn string into list of singleton strings - throw away whitespace etc  *)
 val filter_pred' = member (op =) [" ","\n","\t"];
 val filter_pred = not o filter_pred'; 
 val filter_symbs = filter filter_pred;
 val explode = Symbol.explode #> filter_symbs;
 val scan_empty  = $$ "("  -- $$ ")" >> K ([]);

 fun scan_arg_name xs =
   let 
     val (str,rest) = scan_id xs 
     fun checkupper () = Symbol.is_ascii_upper (String.substring (str,0,1));
   in 
     case str of 
       "_" => (Ignore,rest)
     | "hyps" => (Hyps,rest)
     | "concl" => (Concl,rest)
     | _ => if checkupper () then (Var str,rest) else (Name str,rest)
   end;

 (* scan clause *)
 fun scan_term ctxt = $$ "\"" |--  Scan.many (fn s => not(s = "\"")) --| $$ "\"" >> implode >> (Term o (Prover.trm_of_string ctxt));  
 fun scan_clause ctxt xs  =  (scan_name -- ((scan_args ctxt) || scan_empty) >> Clause) xs 
 (* Note does not turn into term *)
 (* note: terms not supported*)
 and scan_arg ctxt xs = ((scan_clause ctxt) || scan_arg_name  || scan_term ctxt) xs
 and scan_args ctxt xs = (* gen_scan_para_args scan_arg xs *)
  ($$ "("  |--  (scan_arg ctxt) -- Scan.repeat ($$ "," |-- scan_arg ctxt) --| $$ ")" >> op :: ) xs; 

 fun scan_sig_args xs = 
  ($$ "("  |--  scan_name -- Scan.repeat ($$ "," |-- scan_name) --| $$ ")" >> op :: ) xs; 
 val scan_sig = scan_name -- scan_sig_args;

 (* body *)
 fun scan_body ctxt = 
   (scan_clause ctxt) -- Scan.repeat ($$ "," |-- scan_clause ctxt) --| $$ "." >> op :: ; 
 fun scan_prog ctxt = (* note: should not allow general arguments *)
    (scan_sig --| ($$ ":" -- $$ "-") -- (scan_body ctxt) >> (fn ((n,a),b) => Def (n,a,b)))
    ||
    (scan_clause ctxt --| $$ "." >> Constraint);
  fun scan_all f [] = []
   |  scan_all f xs = 
       let 
          val (result,str) = f xs
       in
          result :: scan_all f str
       end;

  fun scan_data ctxt = explode #> scan_all (scan_prog ctxt); 

  fun scan_gt_single ctxt = scan_name -- (scan_args ctxt || scan_empty)
  fun scan_gt_full ctxt = (scan_gt_single ctxt) -- Scan.repeat ($$ "," |-- (scan_gt_single ctxt)) --| $$ "." >> op :: ; 
  fun scan_goaltyp ctxt = explode #> scan_gt_single ctxt #> #1; 


  (**********************
    EVALUATION
   **********************)

  fun project_terms _ _ (Name nm) = []
   |  project_terms env pnode (Var v) = 
        (case StrName.NTab.lookup env v of
           NONE => [] (* or error? *)
         | SOME (ET_T t) =>  [t]
         | SOME (LT_T ts) => ts)
   |  project_terms _ pnode Concl = [Prover.get_pnode_concl pnode]
   |  project_terms _ pnode Hyps = Prover.get_pnode_hyps pnode
   |  project_terms _ _ (Term t) = [t]
   |  project_terms _ _ (Clause _) = []

  fun project_name _ (Name nm) = nm
  (* |  project_name env (Var v) = *)



   (*************** ENVIRONMENTS *********************)

   fun is_var (Var _) = true
    |  is_var _ = false



  (* not very efficient - creates a new: should be constant by keeping list of active
     maybe add functionality in IsaPlib by updaing names field only of NTAB? *)
  fun restrict_env vars state =  
   fold 
     (fn n => fn env =>  
        case StrName.NTab.lookup state n of
          NONE => env
        | SOME v => StrName.NTab.ins (n,v) env)
     vars
     StrName.NTab.empty

  fun override env new_env = 
     StrName.NTab.fold
       (fn (nm,arg) => fn env' =>
         StrName.NTab.update (nm,arg) env')
       new_env
       env;

  fun return_var a old_env b new_env =
      (case StrName.NTab.lookup new_env b of
           SOME e =>  StrName.NTab.update (a,e) old_env
          | NONE => old_env)

  fun return_vars ((Var a)::args) old_env (d::dargs) new_env =
        return_vars args (return_var a old_env d new_env) dargs new_env
   |  return_vars (_::args) old_env (_::dargs) new_env = 
        return_vars args old_env dargs new_env
   |  return_vars [] old_env [] new_env = old_env;

  fun update_env vars old_env state = override old_env (restrict_env vars state);

  fun inst_single pnode old_env (Name n) v new_env = StrName.NTab.ins (v,ES_T n) new_env
   |  inst_single pnode old_env (Var n) v new_env =  
        (case StrName.NTab.lookup old_env v of
           SOME e =>  StrName.NTab.ins (v,e) new_env
          | NONE => new_env)
   |  inst_single pnode old_env Concl v new_env =   
         StrName.NTab.ins (v, ET_T (Prover.get_pnode_concl pnode)) new_env
   |  inst_single pnode old_env Hyps v new_env = 
         StrName.NTab.ins (v, LT_T (Prover.get_pnode_hyps pnode)) new_env
   |  inst_single pnode old_env Ignore v new_env = new_env
   |  inst_single pnode old_env (Term t) v new_env = StrName.NTab.ins (v,ET_T t) new_env
   |  inst_single pnode old_env (Clause _) v new_env = new_env

  fun inst_env' pnode old_env (a::args) (v::vs) new_env =
         inst_env' pnode old_env args vs (inst_single pnode old_env a v new_env)
   |  inst_env' pnoe _ [] [] env = env;

 fun inst_env pnode env args nms = 
   if (length args = length nms)
    then  inst_env' pnode env args nms StrName.NTab.empty
    else raise error "error";
 
   (************** USING DEFINITIONS *********************)

   fun eval_atomic_clause env (data as (P {atomics,...})) (Clause (name,args)) pnode  =
      case StrName.NTab.lookup atomics name of
          NONE => [] 
        | SOME f => f env pnode args  (* isn't ctxt in pnode? *)

   (* no overriding so both atomic and non-atomic *)
   fun eval_arg  (data as P {defs,...}) (cls as Clause (name,args)) pnode env =
     (eval_atomic_clause env data cls pnode) @
     (eval_clauses env data defs (name,args) pnode)

   and eval_clause env data (Def (dname,dargs,dbody)) (name,args) pnode =
     if name = dname 
      then 
       let 
          val ienv = inst_env pnode env args dargs 
          fun evalbody' arg cenv = 
            eval_arg data arg pnode cenv
          fun evalbody arg = maps (evalbody' arg)
       in
          fold evalbody dbody [ienv] 
          |> (fn nenvs => map (return_vars args env dargs) nenvs) (* updates old env *)
          (* |> map (update_env dargs env) *)
       end
      else []

   and eval_clauses env data clauses (name,args) pnode = 
         maps (fn c => eval_clause env data c (name,args) pnode) clauses;
 
   fun eval_goaltyp (data as P {defs,...}) (name,args) pnode (gnode as GN {env, ...}) = 
     eval_clauses env data defs (name,args) pnode
     |> map (fn env => set_gnode_env env gnode);
  
  (**************** EXAMPLE ATOMIC GOAL TYPES ******************)

  fun split env _ [Var v]  = 
    case StrName.NTab.lookup env v of
       SOME (LT_T pt) => map (fn e => StrName.NTab.update (v, ET_T e) StrName.NTab.empty) pt
      | SOME (LS_T st) => map (fn e => StrName.NTab.update (v, ES_T e) StrName.NTab.empty) st
      | _ => []

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

   val default_data = P {imports = [], defs = [], atomics = register_atomics StrName.NTab.empty};

  (* Lifting / proper evaluation *)
 
  fun init_lift (data,t) pnode =
    eval_goaltyp data t pnode (GN {name = Prover.get_pnode_name pnode, env = StrName.NTab.empty});

  fun lift gnode (data,t) pnode =
    eval_goaltyp data t pnode (set_gnode_name (Prover.get_pnode_name pnode) gnode);

  (**********************
     JSON/PRETTY PRINTING
  ***********************)

  fun pretty_arg (Name n) = Pretty.str n
   |  pretty_arg Ignore = Pretty.str "_"
   |  pretty_arg (Var n) = Pretty.str ("?" ^ n)
   |  pretty_arg (Concl) = Pretty.str "concl"
   |  pretty_arg  (Hyps) = Pretty.str "hyps"
   |  pretty_arg  (Term trm) = 
        Pretty.block 
         [Pretty.str "\"",
          Prover.pretty_trm Prover.default_ctxt trm,
          Pretty.str "\""]
   |  pretty_arg (Clause (str,args)) =
       Pretty.block 
        [Pretty.str str,
         Pretty.enclose "(" ")" (Pretty.separate "," (map pretty_arg args))] 

  fun pretty_clause (Def (nm,args,body)) =
       Pretty.block 
        [Pretty.str nm,
         Pretty.enclose "(" ")" (Pretty.separate "," (map Pretty.str args)),
         Pretty.enclose ":-" ".\n" (Pretty.separate "," (map pretty_arg body))]   
   |  pretty_clause (Constraint arg) =
       Pretty.block [pretty_arg arg, Pretty.str ".\n"]  ;

  fun pretty_data (P {imports,defs,atomics}) =
    Pretty.block (map pretty_clause defs);

  fun pretty (s,args) = 
        Pretty.block 
         [Pretty.str s, 
          Pretty.enclose "(" ")" (Pretty.separate "," (map pretty_arg args))];
(*
  fun pretty [] = Pretty.str ""
   |  pretty ((s,[]) :: gts) = Pretty.block [Pretty.str s,pretty gts]
   |  pretty ((s,args) :: gts) =
        Pretty.block 
         [Pretty.str s, 
         Pretty.enclose "(" ")" (Pretty.separate "," (map pretty_arg args)),
         pretty gts] ; *)
      
  fun pretty_gnode (GN {name,env}) = Pretty.str name;

  exception gt_exp of string;

  (* JSON on goal types *)
  fun to_json gt = 
     Json.mk_object [("type", Json.String "GT"), 
                     ("gtype", Json.String (Pretty.str_of (pretty gt)))] 

  fun from_json (Json.Object jobj) = 
        Json.get jobj "gtyp_name" 
        |> (fn Json.String x => x)
        |> scan_goaltyp Prover.default_ctxt
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"

  (* JSON on goal nodes *)

  fun gnode_to_json gn = 
     Json.mk_object [("type", Json.String "G"), 
                     ("goalnode", Json.String (Pretty.str_of (pretty_gnode gn)))];

  fun gnode_from_json (Json.Object jobj) = 
        Json.get jobj "goalnode" 
        |> (fn Json.String x => x)
        |> (fn n => GN {name = n, env = StrName.NTab.empty})
  | gnode_from_json _ = raise gt_exp "from_json: ill-formed json structure"

 (* JSON for data (definitions *)

  fun data_to_json gn = 
     Json.mk_object [("type", Json.String "GT_Data"), 
                     ("gt_data", Json.String (Pretty.str_of (pretty_data gn)))]; 

  fun data_from_json (Json.Object jobj) = 
        Json.get jobj "gt_data" 
        |> (fn Json.String x => x)
        |> scan_data Prover.default_ctxt
        |> (fn defs => set_data_defs defs default_data)
  | data_from_json _ = raise gt_exp "from_json: ill-formed json structure"

 (* TO DO: write type checker *)

  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
    type data = data
    type gt_pred = gt_pred
  end

end (* struct *)

(*

   fun mk_state env (var::vars) (value::values) = 
     if is_var value (* variables not added to env *)
      then mk_state env vars values
      else mk_state (StrName.NTab.ins (var,value) env) vars values 
    |  mk_state env [] [] = env
    |  mk_state  _ _ _ = raise gt_exp "mk_env: list of different lengths";

  fun inst_state pnode env ((Var x)::xs) =
     (case StrName.NTab.lookup env x of
          NONE => raise gt_exp ("variable " ^ x ^ " not bound") (* should print env too? *)
        | SOME (ET_T t) =>  map (fn xs => (Prover.Trm t)::xs) (inst_state pnode env xs)
        | SOME (LT_T ts) =>
           let 
              val tlist = map Prover.Trm ts (* list *)
              val res = inst_state pnode env xs (* list list *)
           in
             map (fn hyp => maps (fn r => hyp::r) res) tlist
           end)
   |  inst_state pnode env ((Name n)::xs) =
         map (fn xs => (Prover.Str n)::xs) (inst_state pnode env xs)
   |  inst_state pnode env (Concl::xs) =  
         map (fn xs => (Prover.Trm (Prover.get_pnode_concl pnode))::xs)
             (inst_state pnode env xs)
   |  inst_state pnode env (Hyps::xs) = 
        let 
          val hyp_list = Prover.get_pnode_hyps pnode
                         |> map Prover.Trm
          val res = inst_state pnode env xs
        in
          map (fn hyp => maps (fn r => hyp::r) res) hyp_list
        end
   |  inst_state pnode env ((Term t)::xs) = map (fn xs => (Prover.Trm t)::xs)(inst_state pnode env xs)
   |  inst_state pnode env [] = [] 
*)
