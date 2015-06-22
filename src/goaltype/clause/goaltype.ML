functor ClauseGTFun(structure Prover : PROVER  
                    val struct_name : string) =
struct

  structure Prover = Prover;

  type gtyp = Prover.env -> Prover.pnode -> Prover.env_data list -> Prover.env list 
  structure GoalTyp_ML_Exec = ML_Exec_Func (val exec_str = Prover.exec_str type ret = gtyp val struct_name = struct_name);

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
  datatype arg = Name of string (* x,y,x *)
                | Var of string (* X,Y,Z *)
                | PVar of string (* ?x,?y,?z ...*)
                | Concl (* turn into name? *) 
                | Hyps (* turn into name? *)
                | Ignore (* turn into name? *)
                | Term of Prover.term 
                | Clause of string * (arg list)
  datatype clause = Def of string * string list * arg list
                  | Constraint of arg; (* will this be used at all? *)

  (* imports not supported yet *)
  (* to do: add atomics as a field *)

  (* binding environment: maybe string is sufficient! just use singleton! *)
(*
  datatype env_data = ET_T of Prover.term
                    | LT_T of Prover.term list 
                    | ES_T of string
                    | LS_T of string list
*)

  type env = Prover.env (* provided by prover *)

  type gnode = string;
                                                            
  datatype data = P of {imports : clause list, 
                        defs : clause list,
                        atomics : (*Prover.*)gtyp StrName.NTab.T}  
  type T = string * (arg list);
 
 val goal_name = I;
(* 
  fun get_gnode_env (GN {env,...}) = env;
  fun goal_name (GN {name,...}) = name;

  fun update_gnode_env f (GN {name,env}) = GN {name = name, env = f env};
  val set_gnode_env = update_gnode_env o K; 

  fun update_gnode_name f (GN {name,env}) = GN {name = f name, env = env};
  val set_gnode_name = update_gnode_name o K; 
*)

  fun update_data_defs f (P {imports,defs,atomics}) =
    P {imports = imports, defs = f defs, atomics = atomics};
  val set_data_defs = update_data_defs o K;

  val default = ("any",[]); (* fixme: does not evaluate *)
  val default_gnode = "?" (* GN {name = "?", env = StrName.NTab.empty}; *)
  val default_data = P {imports = [], defs = [], atomics = StrName.NTab.empty};

  (* required? *)
  fun eq (t1,t2) = true;
  fun gnode_eq (g1,g2) = (g1 = g2);


  (************************************
    SCAN/PARSE data and goaltype
  *************************************)

  (* FIXME: PVar ?x -> var X *)

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

  exception eval_exp of string;

  (* helper functions : needs rethink! *)

  fun get pnode gtenv (Name nm) = Prover.E_Str nm
   |  get pnode gtenv (Var v) = 
      (case StrName.NTab.lookup gtenv v of
           NONE => Prover.E_Str v
         | SOME res => res)
   |  get pnode gtenv (PVar v) = 
        (case StrName.NTab.lookup (Prover.get_pnode_env pnode) v of
           NONE => Prover.E_Str ("?" ^ v) (* or we should raise exception? *)
         | SOME res => res)
   |  get pnode gtenv Concl = Prover.E_Trm (Prover.get_pnode_concl pnode)
   |  get pnode gtenv Hyps = map Prover.E_Trm (Prover.get_pnode_hyps pnode) |> Prover.E_L
   |  get pnode gtenv (Term t) = Prover.E_Trm t
   |  get pnode gtenv (Clause _) = raise eval_exp ("clause not supported in goal type")

  fun isVar (Var _) = true
   |  isVar (PVar _) = true
   |  isVar _ = false;

  fun isProverString (Prover.E_Str _) = true
   |  isProverString _ = false;

  (* assumes: length f_args = length a_args
               each f_args is unique! and in capital letters?
  *)
  fun inst_gtenv pnode f_args a_args gtenv = 
    let 
      fun add fv arg =
        let
          val res = get pnode gtenv arg
          val notvar = not(isVar arg) orelse not(isProverString res)
        in
           if notvar then [(fv,res)] else []
        end handle _ => [];
     fun addall (x::xs) (y::ys) = (add x y) @ (addall xs ys)
      |  addall [] [] = []
    in 
      addall f_args a_args 
      |> (fn args => fold (fn e => fn tab => StrName.NTab.ins e tab) args  StrName.NTab.empty)
    end;       

    
  (* assumes: length f_args = length a_args
               each arg is unique in a_args!
  *)
  fun res_gtenv f_args a_args gtenv =
    let 
      fun add (Var av) fv = 
         (case StrName.NTab.lookup gtenv fv of
            NONE => []
          | SOME v => [(av,v)])
       | add _  _ = [];
     fun addall (x::xs) (y::ys) = (add x y) @ (addall xs ys)
      |  addall [] [] = []
    in 
      addall a_args f_args 
      |> (fn args => fold (fn e => fn tab => StrName.NTab.ins e tab) args  StrName.NTab.empty)
    end;       


   (************** USING DEFINITIONS *********************)
   fun eval_atomic_clause (data as (P {atomics,...})) pnode (Clause (f,args)) gtenv  =
      case StrName.NTab.lookup atomics f of
          NONE => [] 
        | SOME f_a => f_a gtenv pnode (map (get pnode gtenv) args);  (* isn't ctxt in pnode? *)

   (* no overriding so both atomic and non-atomic *)
   fun eval_arg  (data as P {defs,...}) pnode (cls as Clause (name,args)) gtenv =
     (eval_atomic_clause data pnode cls gtenv) @
     (eval_clauses data pnode defs (name,args) gtenv)

   and eval_clause data pnode (Def (f',f_args,body)) (f,a_args) gtenv =
     if f = f'  
      then 
        if length f_args = length a_args
         then
           let 
             val gtenv0 = inst_gtenv pnode f_args a_args gtenv
             fun evalbody arg = maps (eval_arg data pnode arg)
           in
             fold evalbody body [gtenv0] 
             |> (map (res_gtenv f_args a_args))
          end
       else []
      else []

   and eval_clauses data pnode clauses (name,args) gtenv = 
         maps (fn c => eval_clause data pnode c (name,args) gtenv) clauses;
 
  fun eval_defs (data as P {defs,...}) pnode (name,args) gtenv = 
     eval_clauses data pnode defs (name,args) gtenv

  (* 
    Goaltype evaluation / goaltype checking
  *)
  val lift = Prover.get_pnode_name
  (* note that this is when atomic on edge *)
  fun match_atomic (data as (P {atomics,...}))  pnode ((f,args):T) gtenv = 
    case StrName.NTab.lookup atomics f of
     NONE => []
    | SOME f_a => f_a gtenv pnode (map (get pnode gtenv) args);

  fun match data pnode ((f,args):T) gtenv =
     (match_atomic data pnode (f,args) gtenv) 
   @ (eval_defs data pnode (f,args) gtenv);
  
  fun imatch data pnode gtype = 
    match data pnode gtype StrName.NTab.empty;

  fun type_check data pnode gtype = 
    case imatch data pnode gtype of
       [] => false
     | _  => true;

  (* other stuff *)

  fun project_terms _ _ (Name nm) = []
   |  project_terms env pnode (Var v) = 
        (case StrName.NTab.lookup env v of
           NONE => [] (* or error? *)
         | SOME (Prover.E_Trm t) =>  [t]
         | SOME _ => [])
   |  project_terms _ pnode Concl = [Prover.get_pnode_concl pnode]
   |  project_terms _ pnode Hyps = Prover.get_pnode_hyps pnode
   |  project_terms _ _ (Term t) = [t]
   |  project_terms _ _ (Clause _) = []

  fun project_name _ (Name nm) = nm
  (* |  project_name env (Var v) = *)


  val default_data = P {imports = [], defs = [], atomics = StrName.NTab.empty};

  (* Lifting / proper evaluation *)
 
  fun check (gt_data,gtype) (_,pnode) = type_check gt_data pnode gtype;


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
      
  fun pretty_gnode name = Pretty.str name;

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
    type gtyp = gtyp
    structure Prover = Prover.Sharing
  end

end (* struct *)

