functor ClauseGTFun(Prover : PROVER) =
struct

  structure Prover = Prover;
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
                | Term of Prover.term (* fix me: should we make this term? *)
                | Clause of string * (arg list)
  datatype clause = Def of string * string list * arg list
                  | Constraint of arg; (* will this be used at all? *)

  (* imports not supported yet *)
  (* to do: add atomics as a field *)

  (* binding environment: term or string *)
  datatype env_data = ET_T of Prover.term
                    | LT_T of Prover.term list 

  type env = env_data StrName.NTab.T
  datatype gnode = GN of { name : string, env : env  }

  type state = env StrName.NTab.T 

  (* This will be very slow : maybe cluster all names and look up list of them? 
       - atomics can then be used as well, giving almost constant lookup...
     datatype newclause = Def of string list * arg list
                        | Atomic of (Prover.arg_data list -> env -> env list)
                        | Constraint of arg list
     data = (newclause list) StrName.NTab.T
  *)

  datatype data = P of {imports : clause list, 
                        defs : clause list,
                        atomics : (Prover.arg_data list -> env -> env list) StrName.NTab.T}  
  type T = (string * (arg list)) list
  
  fun get_gnode_env (GN {env,...}) = env;
  fun update_gnode_env f (GN {name,env}) = GN {name = name, env = f env};
  val set_gnode_env = K update_gnode_env; 


  val default = [];
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
 val scan_letter = Scan.one valid_letter;
 val scan_id  = (scan_letter || $$ "?") -- ((Scan.repeat scan_letter) >> implode) >> op ^ ;
 val scan_name  = (scan_letter) -- ((Scan.repeat scan_letter) >> implode) >> op ^ ;

 (* turn string into list of singleton strings - throw away whitespace etc  *)
 val filter_pred' = member (op =) [" ","\n","\t"];
 val filter_pred = not o filter_pred'; 
 val filter_symbs = filter filter_pred;
 val explode = Symbol.explode #> filter_symbs;
 val scan_empty  = $$ "("  -- $$ ")" >> K ([]);


 (* scan clause *)
 fun scan_term ctxt = $$ "\"" |--  Scan.many (fn s => not(s = "\"")) --| $$ "\"" >> implode >> (Term o (Prover.trm_of_string ctxt));  
 fun scan_clause ctxt xs  =  (scan_name -- ((scan_args ctxt) || scan_empty) >> Clause) xs 
 (* Note does not turn into term *)
 (* note: terms not supported*)
 and scan_arg ctxt xs = ((scan_clause ctxt) || scan_id >> Name || scan_term ctxt) xs
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
  fun scan_goaltyp ctxt = explode #> scan_all (scan_gt_full ctxt); 
  
  (**********************
     JSON/PRETTY PRINTING
  ***********************)

  fun pretty_arg (Name n) = Pretty.str n
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

  fun pretty [] = Pretty.str ""
   |  pretty ((s,[]) :: gts) = Pretty.block [Pretty.str s,pretty gts]
   |  pretty ((s,args) :: gts) =
        Pretty.block 
         [Pretty.str s, 
         Pretty.enclose "(" ")" (Pretty.separate "," (map pretty_arg args)),
         pretty gts] ;
      
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

  fun data_to_json ctxt gn = 
     Json.mk_object [("type", Json.String "GT_Data"), 
                     ("gt_data", Json.String (Pretty.str_of (pretty_data gn)))]; 

  fun data_from_json (Json.Object jobj) = 
        Json.get jobj "gt_data" 
        |> (fn Json.String x => x)
        |> scan_data Prover.default_ctxt
  | data_from_json _ = raise gt_exp "from_json: ill-formed json structure"

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

  fun project_name (Name nm) = nm
(*   |  project_name _         = raise error *)

  (**************** EXAMPLE ATOMIC GOAL TYPES ******************)

  fun top_symbol ctxt args pnode gnode = 
    let 
      val top = project_terms ctxt pnode (hd args)
              |> map Prover.top_symbol
      val symbs = map project_name (tl args)
      val member = List.exists (fn g => List.exists (fn x => x = g) symbs) top
    in  
      if member then SOME gnode else NONE
    end;

   fun has_symbols ctxt args pnode gnode = 
    let 
      val top = project_terms ctxt pnode (hd args)
              |> maps Prover.symbols
      val symbs = map project_name (tl args)
      val member = List.exists (fn g => List.all (fn x => x = g) symbs) top
    in  
      if member then SOME gnode else NONE
    end;
 
   fun atomic_lift ctxt (name,args) pnode gnode =
    case name of 
      "top_symbol" => top_symbol ctxt args pnode gnode
    | "has_symbols" => has_symbols ctxt args pnode gnode;

   (*************** ENVIRONMENTS *********************)

   fun is_var (Var _) = true
    |  is_var _ = false

   fun mk_state env (var::vars) (value::values) = 
     if is_var value (* variables not added to env *)
      then mk_state env vars values
      else mk_state (StrName.NTab.ins (var,value) env) vars values 
    |  mk_state env [] [] = env
    |  mk_state  _ _ _ = raise gt_exp "mk_env: list of different lengths";

  (* not very efficient - creates a new: should be constant by keeping list of active
     maybe add functionality in IsaPlib by updaing names field only of NTAB? *)
  fun restrict_state vars state =  
   fold 
     (fn n => fn env =>  
        case StrName.NTab.lookup state n of
          NONE => env
        | SOME v => StrName.NTab.ins (n,v) env)
     vars
     StrName.NTab.empty

  fun state_to_env_el (Term t) = SOME (ET_T t)
   |  state_to_env_el _ = NONE

  fun override env state = 
     StrName.NTab.fold
       (fn (nm,arg) => fn env' =>
         case state_to_env_el arg of
           NONE => env' (* keep env if not *)
         | (SOME v) => StrName.NTab.update (nm,v) env')
       state
       env;
 
  fun update_env vars old_env state = override old_env (restrict_state vars state);

  (* instantiaties environment -> this can result in multiple results, e.g multiple terms 
     are bound: or for the hypothesis? 
         - alternative: make this list of list ??
         - what about clause? *) 
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
 
   (************** USING DEFINITIONS *********************)


   fun eval_atomic_clause ctxt state (data as (P {atomics,...})) (Clause (name,args)) pnode gnode =
      case StrName.NTab.lookup atomics name of
          NONE => []
        | SOME f => maps (fn arg => f arg state) (inst_state pnode state args); (* why is env required? *)     

   (* no overriding so both atomic and non-atomic *)
   fun eval_arg ctxt (data as P {defs,...}) (cls as Clause (name,args)) pnode gnode (state : arg StrName.NTab.T) =
     (eval_atomic_clause ctxt state data cls pnode gnode) @
     (eval_clauses ctxt state data defs (name,args) pnode gnode)

   and eval_clause ctxt env data (Def (dname,dargs,dbody)) (name,args) pnode gnode =
     if name = dname 
      then 
       let 
          val state = mk_state StrName.NTab.empty dargs args 
          fun evalbody arg = maps (eval_arg ctxt data arg pnode gnode)
       in
          fold evalbody dbody [state] 
          |> map (update_env dargs env)
       end
      else []

   and eval_clauses ctxt env data clauses (name,args) pnode gnode = 
         map (fn c => eval_clause ctxt env data c (name,args) pnode gnode) clauses;
 
   fun eval_goaltyp ctxt (data as P {defs,...}) (name,args) pnode (gnode as GN {env, ...}) = 
     eval_clauses ctxt env data defs (name,args) pnode gnode
     |> map (fn env => set_gnode_env env gnode);
  





 (* TO DO: write type checker *)
 (*
   atomics : should be registered in psgraph
 *)





end (* struct *)
