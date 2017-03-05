signature ENV_TAC_UTILS_SHARING = 
sig
  structure Graph: GRAPH_SHARING
end

signature ENV_TAC_UTILS = 
sig
  structure Graph : GRAPH

  val is_abbrv_env_tac : string -> bool
  val scan_abbrv_env_tac :
     Graph.Data.GoalTyp.Prover.context
     -> string
     -> Graph.Data.GoalTyp.Prover.env
     -> Graph.Data.GoalTyp.Prover.env_tac
  
  structure Sharing : ENV_TAC_UTILS_SHARING
    sharing Sharing.Graph = Graph.Sharing
end

functor EnvTacUtilsFunc (structure Graph_Utils : GRAPH_UTILS val struct_name : string) : ENV_TAC_UTILS = 
struct
  structure Graph = Graph_Utils.Graph
  structure Prover = Graph.Data.GoalTyp.Prover
   
  local open LoggingHandler in 
    val env_var_prefix = "PSGRAPH_ENV_VAR_";
    val if_local_debug = false;


    fun parse_env_var_name' name (* raise exception*) =
       case Graph_Utils.parse_env_var_name name 
        of NONE 
          => (logging "ENV_DATA" ("Invalid env variable name: " ^ name); raise tinker_fail true)
        | (SOME n) => n;

  (* scanner for the easier form of env tactic *)
    fun filter_blank str = Symbol.explode str |> filter (not o member (op =) [" ", "\t"]) |> String.concat
    fun filter_blank' str_l =  str_l |> filter (not o member (op =) [" ", "\t"])
    fun append_pair (x,y) = x ^ " " ^ y;
    fun scan_ignore_post_blank pre_scan = pre_scan --| (Scan.many (Symbol.is_blank))
    fun scan_ignore_pre_blank post_scan =  (Scan.many ( Symbol.is_blank)) |-- post_scan
    fun scan_until scan =  
    (Scan.repeat (Scan.unless (scan) (Scan.one Symbol.not_eof))
    |> Scan.finite Symbol.stopper) >> String.concat;
 
  (* detecting by checking if start with ? *)
    fun is_start_with symb  str = 
      (Scan.catch ($$ symb |> scan_ignore_pre_blank) (Symbol.explode str); true) 
    handle _ => false
    val is_abbrv_env_tac = is_start_with "?";

    val scan_var = $$ "?" |-- (Scan.many (not o Symbol.is_blank) >> String.concat);
    val scan_var' = Scan.finite Symbol.stopper ( $$ "?" -- (Scan.many (not o Symbol.is_blank) >> String.concat) |> scan_until)
    val scan_type = (scan_ignore_post_blank (Scan.this_string "term" || Scan.this_string "thm") -- 
      (Scan.finite Symbol.stopper (Scan.repeat (Scan.this_string "list" |> scan_ignore_pre_blank) >> str_blocks " "))
      |> scan_ignore_pre_blank)
      >> append_pair;
    
    fun scan_antiquto' (handler : ( (string * string) -> string)) = 
      scan_ignore_pre_blank (Scan.this_string "@{") |--  scan_until ($$"\"") --| $$"\"" --  
      scan_until (Scan.this_string "\"}") --| 
      (Scan.this_string "\"}") 
      >> handler;

    fun scan_antiquto (handler : ( (string * string) -> string)) src = 
      let 
       val ((typ, def), src') = (scan_ignore_pre_blank (Scan.this_string "@{") |--  scan_until ($$"\"") --| $$"\"" --  
        scan_until ($$ "\"") --| 
        (scan_ignore_post_blank ($$ "\"")) --| $$"}") src 
       val _ = case src' of [] => () | _ => raise RunCallFail "illform"
      in
      (typ, handler (typ,def))
      end
    
    fun scan_def0 handler = 
      Scan.finite Symbol.stopper (Scan.this_string "@{" |> scan_until) -- 
      (fn [] =>  (fn x => ("", x)) []| l => scan_antiquto' handler l ) >> append_pair;
    (* val scan_env_var0 =  *)

    
    fun scan_all _ [] = []
      | scan_all scan xs = let val (ret, res) = scan xs in ret :: scan_all scan res end 
    
    fun scan_def handler src = scan_all (scan_def0 handler) src |> String.concat;
 
    fun scan_until scan =  
      (Scan.repeat (Scan.unless (scan) (Scan.one Symbol.not_eof))
      |> Scan.finite Symbol.stopper) >> String.concat;
  
     fun scan_rest_name [] = ([],[])
     |   scan_rest_name (x :: xs) = 
          if (Symbol.is_blank x) then ([x],xs)
          else let val (a,b) = scan_rest_name xs in (x :: a, b) end;
    
    val scan_env_var = 
      ($$ "?" -- Scan.finite Symbol.stopper (Scan.many (fn x => Symbol.is_letter x orelse Symbol.is_digit x)) -- scan_rest_name)
      >> (fn ((_,y), _) => y |> String.concat (*|> filter_blank*)) (* collapse the parsed string as a var name *)      ;
 
    val scan_env_var0 = 
      ($$ "?" -- (Scan.many (fn x => Symbol.is_letter x orelse Symbol.is_digit x)) -- scan_rest_name)
      >> (fn ((_,y), _) => y |> String.concat (*|> filter_blank*)) (* collapse the parsed string as a var name *)      ;
 

    fun scan_env_vars0 [] = []
      | scan_env_vars0 xs = 
        let 
          val (_, res) = scan_until scan_env_var0 xs 
        in
          case res of [] => []
          | _ =>
            let val (var, rest) =  scan_env_var res in
              case rest of [] => [var]
              | _ => var :: (scan_env_vars0 rest) end 
        end
    fun scan_env_vars args = scan_env_vars0 args |> StrName.NSet.of_list |> StrName.NSet.list_of
(* scan_env_tac' format: ?var_name : type := definition, 
   a more constraint format of scan_env_tac is: ?var_name := @{ type " definition"}
    fun scan_abbrv_env_tac' input env = 
      let
       val src = Symbol.explode input
       val ((var, typ), def_strs) = 
        (scan_var (* scan variable name *) --
        (Scan.optional ((scan_ignore_pre_blank ($$":") |-- scan_type)) "" ) (* scan variable type *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src 
      in
         (var, typ, (scan_def (Prover.antiquto_handler env) def_strs))
      end
     handle _ => (LoggingHandler.logging "FAILURE" ("Fail to parse: " ^ input ); 
    raise LoggingHandler.tinker_fail true); *)

    fun scan_abbrv_env_tac ctxt input env  = 
      let
       val src = Symbol.explode input
       val (var, def_strs) = 
        (scan_var (* scan variable name *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src 
    
       (*val def_strs = filter_blank' def_strs*)
       val (typ, def) = 
        if (is_start_with "?" (String.concat def_strs)) 
        (* start with ?, so must be assigning to another env var *)
        then
        (scan_ignore_pre_blank scan_env_var def_strs) |> fst (* get the name of the var *)
         |> (fn x => (StrName.NTab.get env (*String.extract (x, 1, NONE)*)x; ("dummy", String.concat def_strs)))
         handle StrName.Tab.UNDEF n => 
         (logging "FAILURE" ("the env var " ^ (String.concat def_strs)  ^ " does not exist."); 
          raise tinker_fail true)
        else if  (is_start_with "\"" (String.concat def_strs)) then
         ("string", (String.concat def_strs))
        else (* otherwise, scan as the antiquto format*)
        (scan_antiquto ((*Prover.antiquto_handler env*)snd) def_strs)
        (*val _ = writeln "a"*)
        val env_vars = 
         if (typ = "string") then []
         else
         scan_env_vars ( Symbol.explode def)
         |> map (fn n => (n, StrName.NTab.get env n(*String.extract (n,1,NONE)*)))
         handle StrName.Tab.UNDEF n => 
         (logging "FAILURE" ("the env var " ^ n ^ " does not exist."); raise tinker_fail true)
      in
        StrName.NTab.update (filter_blank var, Prover.parse_env_data ctxt (filter_blank typ, def) env_vars) env
        |> Prover.id_env_tac_f 
      end
     handle _ => (if if_local_debug then writeln ("Fail to parse: " ^ input )
      else (LoggingHandler.logging "FAILURE" ("Fail to parse: " ^ input )); 
    raise LoggingHandler.tinker_fail true);

  end (* end of local open *)

  structure Sharing = 
  struct
    structure Graph = Graph.Sharing
  end
end
