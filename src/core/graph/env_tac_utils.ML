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
  val scan_env_tac : PS_Theory.GoalTyp.Prover.env -> string -> (string * string * string)

  structure Sharing : ENV_TAC_UTILS_SHARING
    sharing Sharing.PS_Theory = PS_Theory.Sharing
end

functor EnvTacUtilsFunc (structure Theory : PS_THEORY val struct_name : string) : ENV_TAC_UTILS = 
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
    fun append_pair (x,y) = x ^ " " ^ y;
    fun scan_ignore_post_blank pre_scan = pre_scan --| (Scan.many (Symbol.is_blank))
    fun scan_ignore_pre_blank post_scan =  (Scan.many ( Symbol.is_blank)) |-- post_scan
    fun scan_until scan =  (Scan.repeat (Scan.unless (scan) (Scan.one Symbol.not_eof))) >> String.concat
    
  (* detecting by checking if start with ? *)
    fun is_abbrv_env_tac str = 
      (Scan.catch ($$ "?"|> scan_ignore_pre_blank) (Symbol.explode str); true) 
    handle _ => false

    val scan_var = $$ "?" |-- (Scan.many (not o Symbol.is_blank) >> String.concat);
    val scan_type = (scan_ignore_post_blank (Scan.this_string "term" || Scan.this_string "thm") -- 
      (Scan.finite Symbol.stopper (Scan.repeat (Scan.this_string "list" |> scan_ignore_pre_blank) >> str_blocks " "))
      |> scan_ignore_pre_blank)
      >> append_pair;
    
    fun scan_antiquto' (handler : ( (string * string) -> string)) = 
      Scan.this_string "@{" |--  scan_until ($$"\"") --| $$"\"" --  
      scan_until (Scan.this_string "\"}") --| 
      (Scan.this_string "\"}") 
      >> handler;

    fun scan_antiquto (handler : ( (string * string) -> string)) src = 
      let 
       val ((typ, def), src') = (Scan.this_string "@{" |--  scan_until ($$"\"") --| $$"\"" --  
        scan_until (Scan.this_string "\"}") --| 
        (Scan.this_string "\"}")) src 
       val _ = case src' of [] => () | _ => raise Fail "illform"
      in
      (typ, handler (typ,def))
      end
    
    fun scan_def0 handler = 
      Scan.finite Symbol.stopper (Scan.this_string "@{" |> scan_until) -- 
      (fn [] =>  (fn x => ("", x)) []| l => scan_antiquto' handler l ) >> append_pair;
    
    fun scan_all _ [] = []
      | scan_all scan xs = let val (ret, res) = scan xs in ret :: scan_all scan res end 
    
    fun scan_def handler src = scan_all (scan_def0 handler) src |> String.concat;
    
(* scan_env_tac' format: ?var_name : type := definition, 
   a more constraint format of scan_env_tac is: ?var_name := @{ type " definition"}*)
    fun scan_env_tac' env input = 
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
     handle _ => (LoggingHandler.logging "Faillure" ("Fail to parse: " ^ input ); 
    raise LoggingHandler.tinker_fail true);

    fun scan_env_tac env input = 
      let
       val src = Symbol.explode input
       val (var, def_strs) = 
        (scan_var (* scan variable name *) --|
        (scan_ignore_pre_blank (Scan.this_string ":=")))
        src 
        val (typ, def) = (scan_antiquto (Prover.antiquto_handler env) def_strs)
      in
         (var, typ, def)
      end
     handle _ => (LoggingHandler.logging "Faillure" ("Fail to parse: " ^ input ); 
    raise LoggingHandler.tinker_fail true);

  end (* end of local open *)

  structure Sharing = 
  struct
    structure PS_Theory = PS_Theory.Sharing
  end
end
