signature ENV_TAC_UTILS_SHARING = 
sig
  structure PS_Theory : PS_THEORY_SHARING
end

signature ENV_TAC_UTILS = 
sig
  structure PS_Theory : PS_THEORY
  val ENV_new_var : 
    string (* var name *) 
    -> PS_Theory.GoalTyp.Prover.env_data  
    -> PS_Theory.GoalTyp.Prover.env 
    -> PS_Theory.GoalTyp.Prover.env list
  val ENV_del_var : 
    string (* var name *) 
    -> PS_Theory.GoalTyp.Prover.env  
    -> PS_Theory.GoalTyp.Prover.env list
  val ENV_update_var : 
    ('a -> PS_Theory.GoalTyp.Prover.env_data -> PS_Theory.GoalTyp.Prover.env_data list) 
    -> string -> 'a
    -> PS_Theory.GoalTyp.Prover.env -> PS_Theory.GoalTyp.Prover.env list

  val is_abbrv_env_tac : string -> bool
  val scan_abbrv_env_tac : 
     PS_Theory.GoalTyp.Prover.context
     -> string 
     -> PS_Theory.GoalTyp.Prover.env -> PS_Theory.GoalTyp.Prover.env list

  structure Sharing : ENV_TAC_UTILS_SHARING
    sharing Sharing.PS_Theory = PS_Theory.Sharing
end

functor EnvTacUtilsFunc (structure Theory : PS_THEORY val struct_name : string) (*: ENV_TAC_UTILS *)= 
struct
  structure PS_Theory = Theory
  structure Prover = PS_Theory.GoalTyp.Prover
  local open LoggingHandler in 
    val env_var_prefix = "PSGRAPH_ENV_VAR_";

    fun parse_env_var_name' name (* raise exception*) =
       case PS_Theory.Graph_Utils.parse_env_var_name name 
        of NONE 
          => (logging "ENV_DATA" ("Invalid env variable name: " ^ name); raise tinker_fail true)
        | (SOME n) => n;
  
    fun ENV_new_var name data env = 
      [StrName.NTab.ins ((parse_env_var_name' name), data) env]
     handle StrName.NSet.duplicate_exp _
      => (logging "ENV_DATA" ("The env variable name already exists " ^ name); raise tinker_fail true)

    fun ENV_del_var name env = 
     let 
      val _ = 
       if StrName.NTab.contains env (parse_env_var_name' name) then ()
       else logging "ENV_DATA" ("The env variable name to be deleted doesn't exist " ^ name) in
    [StrName.NTab.delete (parse_env_var_name' name) env] end

  fun ENV_update_var f name arg env = 
    let val _ = 
        if StrName.NTab.contains env (parse_env_var_name' name) then ()
        else logging "ENV_DATA" ("The env variable name to be updated doesn't exist " ^ name) in
   map (fn x =>  StrName.NTab.update (name, x) env) 
     (f arg (StrName.NTab.get env (parse_env_var_name' name))) end

(*
  structure ENV_UTILS_ML_Exec = ML_Exec_Func (val exec_str = Prover.exec_str type ret = string val struct_name = struct_name ^ ".ENV_UTILS_ML_Exec");
*)

  (* scanner for the easier form of env tactic *)
    fun filter_blank str = Symbol.explode str |> filter (not o member (op =) [" ", "\t"]) |> String.concat
    fun append_pair (x,y) = x ^ " " ^ y;
    fun scan_ignore_post_blank pre_scan = pre_scan --| (Scan.many (Symbol.is_blank))
    fun scan_ignore_pre_blank post_scan =  (Scan.many ( Symbol.is_blank)) |-- post_scan
    fun scan_until scan =  
    (Scan.repeat (Scan.unless (scan) (Scan.one Symbol.not_eof))
    |> Scan.finite Symbol.stopper) >> String.concat;
 
  (* detecting by checking if start with ? *)
    fun is_abbrv_env_tac str = 
      (Scan.catch ($$ "?"|> scan_ignore_pre_blank) (Symbol.explode str); true) 
    handle _ => false

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
       val _ = case src' of [] => () | _ => raise RunCall.Fail "illform"
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
      ($$ "?" -- Scan.one (Symbol.is_letter) -- scan_rest_name)
      >> (fn ((x,y), l) => [x,y] @ l |> String.concat |> filter_blank) (* collapse the parsed string as a var name *)      ;
 
    fun scan_env_vars0 [] = []
      | scan_env_vars0 xs = 
        let 
          val (_, res) = scan_until scan_env_var xs 
        in
          case res of [] => []
          | _ =>
            let val (var, rest) =  scan_env_var res in
              case rest of [] => [var]
              | _ => var :: (scan_env_vars0 rest) end 
        end
    fun scan_env_vars args = scan_env_vars0 args |> StrName.NSet.of_list |> StrName.NSet.list_of
(* scan_env_tac' format: ?var_name : type := definition, 
   a more constraint format of scan_env_tac is: ?var_name := @{ type " definition"}*)
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
    raise LoggingHandler.tinker_fail true);

    fun scan_abbrv_env_tac ctxt input env  = 
      let
       val src = Symbol.explode input
       val (var, def_strs) = 
        (scan_var (* scan variable name *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src 
        val (typ, def) = (scan_antiquto ((*Prover.antiquto_handler env*)snd) def_strs)
        val _ = writeln "a"
        val env_vars = 
         scan_env_vars ( Symbol.explode def)
         |> map (fn n => (n, StrName.NTab.get env (String.extract (n,1,NONE))))
         handle StrName.Tab.UNDEF n => 
         (logging "FAILURE" ("the env var " ^ n ^ " does not exist."); raise tinker_fail true)
      in
        [StrName.NTab.update (filter_blank var, Prover.parse_env_data ctxt (filter_blank typ, def) env_vars) env]
      end
     handle _ => (LoggingHandler.logging "FAILURE" ("Fail to parse: " ^ input ); 
    raise LoggingHandler.tinker_fail true);

  end (* end of local open *)

  structure Sharing = 
  struct
    structure PS_Theory = PS_Theory.Sharing
  end
end
