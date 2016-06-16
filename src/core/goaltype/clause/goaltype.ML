functor ClauseGTFun(structure Prover : PROVER  
                    val struct_name : string)  (*: CLAUSE_GOALTYPE *)=
struct

  structure Prover = Prover;
  local open LoggingHandler in 
(* note that this has to be turned off in isabelle, 
as pretty printing contains some non-standard chars which breaks the protocal *)
  val DEBUG_ON = true;
  val if_gui_mode = false;

  val tab = Unsynchronized.ref 0;
  fun inctab() = (tab := !tab +1);
  fun dectab() = if !tab >= 0 then (tab := !tab -1) else ();
  fun tabs () = 
      let fun p 0 = ""
           |  p n = " " ^ p (n-1)
      in p (!tab) end;
  fun dbg msg = 
  let val f = if if_gui_mode then logging "GOALTYPE" else writeln in
  if DEBUG_ON then f  (tabs() ^ msg) else () end;
  fun dbg_res res = 
      ((case res of 
         [] => dbg "FAILURE" 
        | _ => dbg "SUCCESS"); res);

  exception eval_exp of string;
  exception gt_exp of string; (* used by JSON *)

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

  type env = Prover.env (* provided by prover *)

  type gtyp = Prover.env -> Prover.pnode -> arg list -> Prover.env list 
  
  structure GoalTyp_ML_Exec = ML_Exec_Func (val exec_str = Prover.exec_str 
                                            type ret = gtyp 
                                            val struct_name =  struct_name ^".GoalTyp_ML_Exec");
  
  datatype gnode = G of {name: string, pretty: Pretty.T}
                                                            
  datatype data = P of {imports : clause list, 
                        defs : clause list,
                        atomics : (*Prover.*)gtyp StrName.NTab.T}  
  type T = string * (arg list);

  fun goal_name (G {name, ...}) = name;
  fun goal_pretty (G {pretty, ...}) = pretty

  val default = ("any",[]); (* fixme: does not evaluate *)
  fun any env _ _ = [env]
  val default_gnode = G {name = "?", pretty = Pretty.str "?"};
  val default_data = P {imports = [], defs = [], atomics = StrName.NTab.ins ("any", any) StrName.NTab.empty};

  (* required? *)
  fun eq _ = true;
  fun gnode_ord (g1, g2) = String.compare (goal_name g1, goal_name g2);
  fun gnode_eq (g1,g2) = case gnode_ord(g1,g2) of EQUAL => true | _ => false;

  (**********************
     PRETTY PRINTING
  ***********************)

  fun pretty_arg (Name n) = Pretty.str n
   |  pretty_arg Ignore = Pretty.str "_"
   |  pretty_arg (Var n) = Pretty.str (n)
   |  pretty_arg (PVar n) = Pretty.str ("?" ^ n)
   |  pretty_arg (Concl) = Pretty.str "concl"
   |  pretty_arg  (Hyps) = Pretty.str "hyps"
   |  pretty_arg  (Term trm) = 
      str_blocks "" ["\"",
       Prover.string_of_trm Prover.default_ctxt trm,
       "\""] |> Pretty.str
        (*Pretty.block 
         [Pretty.str "\"",
          Prover.pretty_trm Prover.default_ctxt trm,
          Pretty.str "\""]*)
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

  fun pretty_data (P {defs,...}) =
    Pretty.block (map pretty_clause defs);

  fun pretty (s,args) = 
        Pretty.block 
         [Pretty.str s, 
          Pretty.enclose "(" ")" (Pretty.separate "," (map pretty_arg args))];
      
  val pretty_gnode = Pretty.str o goal_name;

  val pretty_env = StrName.NTab.pretty (Prover.pretty_env_data Prover.default_ctxt);

  val str_env = pretty_env #> Pretty.string_of;
  (* val dbg_env = str_env #> dbg; *)
  val str_cls = pretty_clause #> Pretty.string_of;
  val str_arg = pretty_arg #> Pretty.string_of;

  (**********************
     Record GET/SET/UPDATE methods
  ***********************)


  fun get_imports (P {imports,...}) = imports;
  fun get_data_defs (P {defs,...}) = defs;
  fun get_atomics (P {atomics,...}) = atomics;

  fun update_imports f (P data) = P {imports = f (#imports data), defs = #defs data, atomics = #atomics data};
  fun update_data_defs f (P data) = P {imports = #imports data, defs = f (#defs data), atomics = #atomics data};
  fun update_atomics f (P data) = P {imports = #imports data, defs = #defs data, atomics = f (#atomics data)};

  val set_imports = update_imports o K;
  val set_data_defs = update_data_defs o K;
  val set_atomics = update_atomics o K;

  fun add_atomic name atom = update_atomics (StrName.NTab.ins (name,atom));
  fun add_defs new_defs = update_data_defs (fn defs => defs @ new_defs);          

  (**********************
    HELPER METHODS
   **********************)

  fun project_env_terms (Prover.E_Trm t) = [t]
   |  project_env_terms (Prover.E_Thm t) = [Prover.concl_of_thm t]
   |  project_env_terms (Prover.E_L xs) = maps project_env_terms xs
   |  project_env_terms _ = []

  fun project_env_str (Prover.E_Str s) = [s]
   |  project_env_str (Prover.E_ML s) = [s]
   |  project_env_str (Prover.E_L xs) = maps project_env_str xs
   |  project_env_str _ = []

  (* projects terms *)
  fun project_terms _ _ (Name _) = []
   |  project_terms env _ (Var v) = 
        (case StrName.NTab.lookup env v of
           NONE => [] (* or error? *)
         | SOME xs => project_env_terms xs)
   |  project_terms _ pnode (PVar v) = 
          (case StrName.NTab.lookup (Prover.get_pnode_env pnode) v of
               NONE => []
             | SOME xs => project_env_terms xs)
   |  project_terms _ pnode Concl = [Prover.get_pnode_concl pnode]
   |  project_terms _ _ Ignore = []
   |  project_terms _ pnode Hyps = Prover.get_pnode_hyps pnode
   |  project_terms _ _ (Term t) = [t]
   |  project_terms _ _ (Clause _) = []

  fun project_name _ _ (Name nm) = [nm]
   |  project_name env _ (Var v) = 
        (case StrName.NTab.lookup env v of
           NONE => [] (* or error? *)
         | SOME xs => project_env_str xs)
   |  project_name _ pnode (PVar v) = 
          (case StrName.NTab.lookup (Prover.get_pnode_env pnode) v of
               NONE => []
             | SOME xs => project_env_str xs)
   |  project_name _ _ Concl = []
   |  project_name _ _ Ignore = []
   |  project_name _ _ Hyps = []
   |  project_name _ _ (Term _) = []
   |  project_name _ _ (Clause _) = []


  (**********************
    EVALUATION
   **********************)

  fun lookup _ _  (Name nm) = SOME (Prover.E_Str nm)
   |  lookup _ gtenv (Var v) = 
      (case StrName.NTab.lookup gtenv v of
           NONE => NONE
         | SOME res => SOME res)
   |  lookup pnode _ (PVar v) = 
        (case StrName.NTab.lookup (Prover.get_pnode_env pnode) v of
           NONE =>  raise eval_exp ("Variable " ^ v ^ " not bound in environment") 
         | SOME res => SOME res)
   |  lookup pnode _ Concl = SOME (Prover.E_Trm (Prover.get_pnode_concl pnode))
   |  lookup pnode _ Hyps = SOME (map Prover.E_Trm (Prover.get_pnode_hyps pnode) |> Prover.E_L)
   |  lookup _ _ Ignore = NONE
   |  lookup _ _ (Term t) = SOME (Prover.E_Trm t)
   |  lookup _ _ (Clause _) = NONE


  (* assumes: length f_args = length a_args
               each f_args is unique! and in capital letters?
  *)
  fun inst_gtenv pnode f_args a_args gtenv = 
    let 
      fun add fv arg =
       case lookup pnode gtenv arg of
         SOME v => [(fv,v)]
        | NONE => []
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
   fun eval_atomic_clause (data as (P {atomics,...})) pnode (cls as Clause (f,args)) gtenv  =
      case StrName.NTab.lookup atomics f of
          NONE => (dbg ("ERROR: no atomic definition found for " ^ f);[]) 
        | SOME f_a =>  ((dbg ("evaluating " ^ str_arg cls ^ " with  " ^ str_env gtenv ));
                        dbg_res (f_a gtenv pnode args));

   (* no overriding so both atomic and non-atomic *)
   fun eval_arg  (data as P {defs,...}) pnode (cls as Clause (name,args)) gtenv =
     (eval_atomic_clause data pnode cls gtenv) @
     (eval_filter_clause data pnode cls gtenv) @
     (eval_not_clause data pnode cls gtenv) @
     (eval_clauses data pnode defs (name,args) gtenv)

  (* hardcoded filter function: cannot give empty list and v has to be fresh*)
  (* assumes first argument is name that takes single (term) arg *)
  and  eval_filter_clause (data as P {defs,...}) pnode (cls as Clause ("filter",[Name nf,arg,Var v])) gtenv =
    let 
      val trms = project_terms gtenv pnode arg
      val _ = dbg ("filtering " ^ nf ^ " : ") 
      fun apply_one t = (case eval_arg data pnode (Clause (nf,[Term t])) gtenv of
                          [] => []
                         | _ => [Prover.E_Trm t])
      val res = maps apply_one trms;
    in 
       (case (res,StrName.NTab.lookup gtenv v) of
           ([],_) => []
         | (xs,NONE) => [StrName.NTab.ins (v,Prover.E_L res) gtenv]
         | _ => [])
    end
   |   eval_filter_clause _ _ _ _ = []

   and  eval_not_clause (data as P {defs,...}) pnode (cls as Clause ("not",[Clause (nf,args)])) gtenv =
    let 
      val _ = dbg ("Negating " ^ nf ^ " : ") 
    
    in 
      case eval_arg data pnode (Clause (nf,args)) gtenv of 
          [] => [Prover.get_pnode_env pnode]
        | _  => []
    end
   |   eval_not_clause _ _ _ _ = []
   and eval_clause data pnode (d as Def (f',f_args,body)) (f,a_args) gtenv =
     if f = f'  
      then 
        (dbg ("evaluating " ^  (str_cls d)  ^ " with " ^ str_env gtenv);
        if length f_args = length a_args
         then
           let 
             val gtenv0 = inst_gtenv pnode f_args a_args gtenv
             val _ = (dbg ("evaluating " ^ f ^ " body with " ^ str_env gtenv0); inctab())
             fun evalbody arg = maps (eval_arg data pnode arg)
             val res = (fold evalbody body [gtenv0] 
                 |> (map (res_gtenv f_args a_args)))
           in
             dectab();dbg_res res
          end
       else (dbg "ERROR: wrong number of args";[]))
      else []

   (* TO DO: is this reflected in formal semantics? *)
   and eval_clauses data pnode clauses (name,args) gtenv = 
         maps (fn c => eval_clause data pnode c (name,args) gtenv handle eval_exp msg => (dbg ("ERROR: " ^ msg);[])) clauses;
 
  fun eval_defs (data as P {defs,...}) pnode (name,args) gtenv = 
     eval_clauses data pnode defs (name,args) gtenv

  (* 
    Goaltype evaluation / goaltype checking
  *)
  fun lift pn = G {name = (Prover.get_pnode_name pn), pretty = Prover.pretty_goal pn}

  (* note that this is when atomic on edge *)
  fun match_atomic (data as (P {atomics,...}))  pnode (t as (f,args):T) gtenv = 
    case StrName.NTab.lookup atomics f of
     NONE => []
    | SOME f_a => 
        ((dbg ("evaluating " ^  (str_arg (Clause t))  ^ " with " ^ str_env gtenv ));
        dbg_res (f_a gtenv pnode args));

  fun match data pnode ((f,args):T) gtenv =
     (match_atomic data pnode (f,args) gtenv) 
   @ (eval_defs data pnode (f,args) gtenv);
  
  fun imatch data pnode (t as (gtnm,gtargs)) = 
    ((dbg ("evaluating goaltype " ^ (str_arg (Clause t)) ^ " with pnode " ^ Prover.get_pnode_name pnode ^ " env " ^ str_env (Prover.get_pnode_env pnode) ); inctab());
    let val res = match data pnode (gtnm,gtargs) (Prover.get_pnode_env pnode) in dectab(); dbg_res res end);

  fun type_check data pnode gtype = 
    case imatch data pnode gtype of
       [] => false
     | _  => true;

  (* lifting/proper eval *)
  fun check (gt_data,gtype) (_,pnode) = type_check gt_data pnode gtype;

                             
                             

  (************************************
    SCAN/PARSE data and goaltype
  *************************************)

 (* scan of letters and identifiers *)
 val valid_id_symbols = ["_"]
 val valid_follow_symbols = ["."]
 fun valid_letter x = Symbol.is_ascii_identifier x  orelse member (op =) valid_id_symbols x ;
 fun valid_letter_or_digit x = Symbol.is_ascii_identifier x orelse Symbol.is_digit x orelse 
                                  member (op =) valid_id_symbols x orelse member (op =) valid_follow_symbols x ;
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
     fun checkvar () = Symbol.is_ascii_upper (String.substring (str,0,1));
     fun checkpvar () = (String.substring (str,0,1)) = "?";
     fun skipfirst s  = String.substring (s,1,String.size(s)-1)
   in 
     case str of 
       "_" => (Ignore,rest)
     | "hyps" => (Hyps,rest)
     | "concl" => (Concl,rest)
     | _ => if checkvar () then (Var str,rest) else if checkpvar() then (PVar (skipfirst str),rest) else (Name str,rest)
   end;

 (* scan clause *)
 fun scan_term ctxt = $$ "\"" |--  Scan.many (fn s => not(s = "\"")) --| $$ "\"" >> implode >> (Term o (Prover.trm_of_string ctxt));  
 fun scan_clause ctxt xs  =  (scan_name -- ((scan_args ctxt) || scan_empty) >> Clause) xs 
 (* Note: does not turn into term *)
 (*       terms not supported*)
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
  fun scan_goaltyp0 ctxt = explode #> scan_gt_single ctxt #> #1; 
  fun scan_goaltyp ctxt str = 
    case str of "any" =>  scan_goaltyp0 ctxt "any()" 
    | _ => scan_goaltyp0 ctxt str
  (* add to defs *)
  fun add_parse_def new_def = add_defs (scan_data Prover.default_ctxt new_def);
  (************************************
    JSON export/import
  *************************************)

  (* JSON on goal types *)
  fun to_json gt =
   let 
    val args = snd gt |> map pretty_arg |> map Pretty.string_of
    fun app_args [] = ""
        | app_args [x] =  x
        | app_args (x::xs)  =  x ^ "," ^ (app_args xs);
   in 
     Json.String (fst gt ^ "(" ^ (app_args ( args))  ^ ")")
   end

  fun from_json (Json.String str) = scan_goaltyp Prover.default_ctxt str
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"

  (* JSON on goal nodes *)
  fun gnode_to_json g = 
   Json.mk_object[
    ("name", Json.String (goal_name g)),
    ("goal", Json.String (Pretty.string_of (goal_pretty g)))];

  fun gnode_from_json (Json.Object obj) = 
    G {name = JsonInputUtils.get_string obj "name", 
       pretty = Pretty.str (JsonInputUtils.get_string obj "goal")}
  | gnode_from_json _ = raise gt_exp "gnode_from_json: ill-formed json structure"

 (* JSON for data (definitions *)
(*
  fun data_to_json gn = 
     Json.mk_object [("type", Json.String "GT_Data"), 
                     ("gt_data", Json.String (Pretty.str_of (pretty_data gn)))]; 

  fun data_from_json (Json.Object jobj) = 
        Json.get jobj "gt_data" 
        |> (fn Json.String x => x)
        |> scan_data Prover.default_ctxt
        |> (fn defs => set_data_defs defs default_data)
  | data_from_json _ = raise gt_exp "from_json: ill-formed json structure"
*)
  fun data_to_json gn = Json.String (Pretty.str_of (pretty_data gn)); 

  fun data_from_json (Json.String str) = 
    let val _ = debug_json ("Json parsing: GoalType data - " ^ str) ()in 
         scan_data Prover.default_ctxt str
        |> (fn defs => set_data_defs defs default_data) end
  | data_from_json _ = raise gt_exp "from_json: ill-formed json structure"

(* TODO: need a proper fix, only merge def here *)
  fun merge_data src dest =  update_data_defs (fn x => (get_data_defs src) @ x) dest
  
 end (* end of local open *)
  structure BasicSharing =
  struct
    type T = T
    type gnode = gnode
    type data = data
    type gtyp = gtyp
    structure Prover = Prover.Sharing
  end

end (* struct *)

