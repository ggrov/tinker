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
                  | Constraint of arg;

  (* imports not supported yet *)
  (* to do: add atomics as a field *)

  (* binding environment: term or string *)
  datatype env_data = ET_T of Prover.term
                    | LT_T of Prover.term list 

  type env = env_data StrName.NTab.T
  datatype gnode = GN of { name : string, env : env  }

  type state = env StrName.NTab.T 
  datatype data = P of {imports : clause list, 
                        defs : clause list,
                        atomics : (string list -> state -> state list) StrName.NTab.T}  
  type T = (string * (arg list)) list
  
  fun get_gnode_env (GN {env,...}) = env;
  fun update_gnode_env f (GN {name,env}) = GN {name = name, env = f env};
  val set_gnode_env = K update_gnode_env; 


  val default = [];
  val default_gnode = GN {name = "?", env = StrName.NTab.empty};
  val default_data = P {imports = [], defs = []};

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

 (* some generic rules (did not work though so not used below *)
 val scan_empty  = $$ "("  -- $$ ")" >> K ([]:Args list);
 fun gen_scan_list sep f =  f -- Scan.repeat ($$ sep |-- f)  >> op ::;
 val gen_scan_comma_list = gen_scan_list "," ;
 fun gen_scan_para f = $$ "("  |--  gen_scan_comma_list f --| $$ ")" ;
 (* type restricted *)
 fun gen_scan_para_args (f:string list -> Args * string list) = gen_scan_para_args f;

 (* scan clause *)
 fun scan_term ctxt = $$ "\"" |--  Scan.many (fn s => not(s = "\"")) --| $$ "\"" >> implode >> (Term o (Prover.trm_of_string ctxt));  
 fun scan_clause ctxt xs  =  (scan_name -- ((scan_args ctxt) || scan_empty) >> Clause) xs 
 (* Note does not turn into term *)
 (* note: terms not supported*)
 and scan_arg ctxt xs = ((scan_clause ctxt) || scan_id >> Name || scan_term ctxt) xs
 and scan_args ctxt xs = (* gen_scan_para_args scan_arg xs *)
  ($$ "("  |--  (scan_arg ctxt) -- Scan.repeat ($$ "," |-- scan_arg ctxt) --| $$ ")" >> op :: ) xs; 

 (* body *)
 val scan_body ctxt = 
   (scan_clause ctxt) -- Scan.repeat ($$ "," |-- scan_clause ctxt) --| $$ "." >> op :: ; 
 fun scan_prog ctxt = (* note: should not allow general arguments *)
    ((scan_clause ctxt) --| ($$ ":" -- $$ "-") -- (scan_body ctxt) >> Def)
    ||
    (scan_clause --| $$ "." >> Constraint);
  fun scan_all f [] = []
   |  scan_all f xs = 
       let 
          val (result,str) = f xs
       in
          result :: scan_all f str
       end;

  fun scan_data ctxt = explode #> scan_all (scan_prog ctxt); 

  fun scan_gt_single ctxt = scan_name -- (scan_args || scan_empty)
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
          Prover.pretty_trm Prover.default_context trm,
          Pretty.str "\""]
   |  pretty_arg (Clause (str,args)) =
       Pretty.block 
        [Pretty.str str, Pretty.str "(",
         Pretty.sep "," (map pretty_arg args),
         Pretty.str ")"]         
  
  fun pretty_clause (Def (arg,args)) =
       Pretty.block 
        [pretty_arg arg, Pretty.str "(",
         Pretty.sep "," (map pretty_arg args),
         Pretty.str ").\n"]      
   |  pretty_clause (Constraint arg) =
       Pretty.block [pretty_arg arg, Pretty.str ".\n"]  

  fun pretty_data (P {imports,defs}) =
    Pretty.block (map pretty_clause defs);

  fun pretty [] = Pretty.str ""
   |  pretty ((s,[]) :: gts) = Pretty.block [Pretty.str s,pretty gts]
   |  pretty ((s,args) :: gts) =
        Pretty.block [Pretty.str s, Pretty.str "(", 
                      Pretty.separate "," (map pretty_args args,
                      Pretty.str ")", pretty gts] ;
      
  fun pretty_gnode (GN {name,env}) = Pretty.str name;

  (* JSON on goal types *)
  fun to_json gt = 
     Json.mk_object [("type", Json.String "GT"), 
                     ("gtype", Json.String (Pretty.str_of (pretty gt))] 

  fun from_json ctxt (Json.Object jobj) = 
        Json.get jobj "gtyp_name" 
        |> (fn Json.String x => x)
        |> scan_goaltyp ctxt
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"

  (* JSON on goal nodes *)

  fun gnode_to_json gn = Json.String;
     Json.mk_object [("type", Json.String "G"), 
                     ("goalnode", Json.String (Pretty.str_of (pretty_gnode gt))] 

  fun gnode_from_json ctxt (Json.Object jobj) = 
        Json.get jobj "goalnode" 
        |> (fn Json.String x => x)
        |> (fn n => GN {name = n, env = StrName.NTab.empty})
  | gnode_from_json _ = raise gt_exp "from_json: ill-formed json structure"

 (* JSON for data (definitions *)

  fun data_to_json ctxt gn = Json.String;
     Json.mk_object [("type", Json.String "GT_Data"), 
                     ("gt_data", Json.String (Pretty.str_of (pretty_data gt))] 

  fun data_from_json ctxt (Json.Object jobj) = 
        Json.get jobj "gt_data" 
        |> (fn Json.String x => x)
        |> scan_data Prover.default_context
  | gnode_from_json _ = raise gt_exp "from_json: ill-formed json structure"

  (**********************
    EVALUATION
   **********************)

  fun project_terms _ (Name nm) = []
   |  project_terms pnode (Var v) = lookup 
   |  project_terms pnode Concl = Prover.concl_of pnode
   |  project_terms pnode Hyps = Prover.hyps_of pnode
   |  project_terms _ (Term t) = [t]
   |  project_terms (Clause _) = []

  fun project_name (Name nm) = nm
   |  project_name _         = raise error

  (**************** EXAMPLE ATOMIC GOAL TYPES ******************)

  fun top_symbol ctxt args pnode gnode = 
    let 
      val top = project_terms pnode (hd args)
              |> map Prover.top_symbol
      val symbs = map project_name (tl args)
      val member = List.exists (fn g => List.exists (fn g => x = g) g symbs) top
    in  
      if member then SOME gnode else NONE
    end;

   fun has_symbols ctxt args pnode gnode = 
    let 
      val top = project_terms pnode (hd args)
              |> map Prover.symbols
      val symbs = map project_name (tl args)
      val member = List.exists (fn g => List.forall (fn g => x = g) g symbs) top
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

   fun mk_env env (var::vars) (value::values) = 
     if is_var value (* variables not added to env *)
      then mk_env env vars values
      else mk_env (StrName.NTab.ins (var,value) env) vars values 
    |  mk_env env [] [] = env
    |  mke_env  _ _ _ = raise error

  (* not very efficient - creates a new: should be constant by keeping list of active
     maybe add functionality in IsaPlib by updaing names field only of NTAB? *)
  fun restrict_env vars ienv =  
   fold 
     (fn n => fn env =>  
        case StrName.NTab.lookup ienv n of
          NONE => env
        | SOME v => StrName.NTab.ins (n,v) env)
     vars
     StrName.NTab.empty

  val override = StrName.NTab.merge_joint (K true);
 
  fun update_env vars old_env new_env = override old_env (restrict_env vars new_env);

  (* FIXME: there will be multiple ones here!! when Hyps so should be list of list*)

  (* name ? clause? *) 
  fun inst_env pnode env ((Var x)::xs) = map (fn xs => x::xs) (inst_env pnode env xs)
   |  inst_env pnode env (Concl::xs) = 
   |  inst_env pnode env (Hyps::xs) = 
   |  inst_env pnode env ((Term t)::xs) = 
   |  inst_env pnode env [] = [] 
 
   (************** USING DEFINITIONS *********************)

   fun composef f ctxt  [] pnode gnode = SOME gnode
    |  composef f ctxt (x::xs) pnode gnode =
         case f ctxt pnode x gnode of
           SOME gnode' => composef f ctxt xs pnode gnode'
         | NONE => NONE
 
  datatype arg = Name of string 
                | Var of string
                | Concl
                | Hyps
                | Term of Prover.term (* fix me: should we make this term? *)
                | Clause of string * (arg list)

   fun eval_atomic_clause ctxt env defs (Clause (name,args)) pnode gnode =

   (* no overloading so both atomic and non-atomic *)
   fun eval_arg ctxt env defs (Clause (name,args)) pnode gnode =

    if is_atomic name 
     then


   (* to do : merge with eval_clause *)
   fun eval_body ctxt env defs dbody pnode gnode =
     fold 


   fun eval_clause ctxt env defs (Def (Clause (dname,dargs),dbody)) (name,args) pnode gnode =
     if name = dname 
      then 
       let 
          val new_env = mk_env StrName.NTab.empty dargs args 
       in
          eval_body ctxt new_env defs dbody pnode gnode
          |> map (update_env dargs env)
       end
      else []

   (* what about atomics? *)    
   fun eval_goaltyp ctxt defs (name,args) pnode gnode = 
     defs 
     |> map (fn d => eval_clause ctxt defs (get_gnode_env gnode) d (name,args) pnode gnode) 
     |> map (fn env => set_gnode_env env gnode);
  





 (* TO DO: write type checker *)
 (*
   atomics : should be registered in psgraph
 *)
 (* these will be prover specific! but language using them should be generic *)       
 type atom =  (* empty is failure *)

 (*
   f(X,Y) :- a(X,Y), b(X,Y).
   f(g(X),Y) :- b(X),c(Y).
   f(g(test),h(test2)).
 *)




end (* struct *)
