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
  datatype clause = Def of arg * arg list
                  | Constraint of arg;

  (* imports not supported yet *)
  datatype data = P of {imports : clause list, defs : clause list}  
  type T = (string * (arg list)) list
  
  (* binding environment: term or string *)
  type env_data = Prover.term StrName.NTab.T
  datatype gnode = GN of { name : string,
                           env : env_data  }

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

 (* TODO: need to give context as part of scanner!! *)
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

  fun pretty_arg ctxt (Name n) = Pretty.str n
   |  pretty_arg ctxt (Var n) = Pretty.str ("?" ^ n)
   |  pretty_arg ctxt (Concl) = Pretty.str "Concl"
   |  pretty_arg ctxt (Hyps) = Pretty.str "Hyps"
   |  pretty_arg ctxt (Term trm) = 
        Pretty.block 
         [Pretty.str "\"",
          Prover.pretty_trm ctxt trm,
          Pretty.str "\""]
   |  pretty_arg ctxt (Clause (str,args)) =
       Pretty.block 
        [Pretty.str str, Pretty.str "(",
         Pretty.sep "," (map (pretty_arg ctxt) args),
         Pretty.str ")"]         
  
  fun pretty_clause ctxt (Def (arg,args)) =
       Pretty.block 
        [pretty_arg ctxt arg, Pretty.str "(",
         Pretty.sep "," (map (pretty_arg ctxt) args),
         Pretty.str ").\n"]      
   |  pretty_clause ctxt (Constraint arg) =
       Pretty.block [pretty_arg ctxt arg, Pretty.str ".\n"]  

  fun pretty_data ctxt (P {imports,defs}) =
    Pretty.block (map pretty_clause defs);

  fun pretty ctxt [] = Pretty.str ""
   |  pretty ctxt ((s,[]) :: gts) = Pretty.block [Pretty.str s,pretty ctxt gts]
   |  pretty ctxt ((s,args) :: gts) =
        Pretty.block [Pretty.str s, Pretty.str "(", 
                      Pretty.separate "," (map (pretty_args ctxt) args,
                      Pretty.str ")", pretty ctxt gts] ;
      
  fun pretty_gnode ctxt (GN {name,env}) = Pretty.str name;

  (* JSON on goal types *)
  fun to_json ctxt gt = 
     Json.mk_object [("type", Json.String "GT"), 
                     ("gtype", Json.String (Pretty.str_of (pretty ctxt gt))] 

  fun from_json ctxt (Json.Object jobj) = 
        Json.get jobj "gtyp_name" 
        |> (fn Json.String x => x)
        |> scan_goaltyp ctxt
  | from_json _ = raise gt_exp "from_json: ill-formed json structure"

  (* JSON on goal nodes *)

  fun gnode_to_json ctxt gn = Json.String;
     Json.mk_object [("type", Json.String "G"), 
                     ("goalnode", Json.String (Pretty.str_of (pretty_gnode ctxt gt))] 

  fun gnode_from_json ctxt (Json.Object jobj) = 
        Json.get jobj "goalnode" 
        |> (fn Json.String x => x)
        |> (fn n => GN {name = n, env = StrName.NTab.empty})
  | gnode_from_json _ = raise gt_exp "from_json: ill-formed json structure"

 (* JSON for data (definitions *)

  fun data_to_json ctxt gn = Json.String;
     Json.mk_object [("type", Json.String "GT_Data"), 
                     ("gt_data", Json.String (Pretty.str_of (pretty_data ctxt gt))] 

  fun data_from_json ctxt (Json.Object jobj) = 
        Json.get jobj "gt_data" 
        |> (fn Json.String x => x)
        |> scan_data ctxt
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

   fun composef f ctxt  [] pnode gnode = SOME gnode
    |  composef f ctxt pnode (x::xs) gnode =
         case f ctxt pnode x gnode of
           SOME gnode' => composef f ctxt xs pnode gnode'
         | NONE => NONE
 
  datatype arg = Name of string 
                | Var of string
                | Concl
                | Hyps
                | Term of Prover.term (* fix me: should we make this term? *)
                | Clause of string * (arg list)
  
   fun eval_arg ctxt (Clause (cname,cargs) (name,args) pnode gnode =

   fun eval_clause ctxt (Def (Clause (dname,dargs),dbody)) (name,args) pnode gnode =
     if name = dname 
      then ...
      else []
    

 f ctxt  [] pnode gnode

  datatype arg = Name of string 
                | Var of string
                | Concl
                | Hyps
                | Term of Prover.term (* fix me: should we make this term? *)
                | Clause of string * (arg list)
  datatype clause = Def of arg * arg list
                  | Constraint of arg;

  (* imports not supported yet *)
  datatype data = P of {imports : clause list, defs : clause list}  




 (* TO DO: write type checker *)
 (*
   atomics : should be registered in psgraph
 *)
 (* these will be prover specific! but language using them should be generic *)       
 type atom = Args list -> env -> env list (* empty is failure *)

 (*
   f(X,Y) :- a(X,Y), b(X,Y).
   f(g(X),Y) :- b(X),c(Y).
   f(g(test),h(test2)).
 *)




end (* struct *)
