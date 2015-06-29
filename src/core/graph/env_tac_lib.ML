signature ENV_TAC_LIB_SHARING = 
sig
  structure PS_Theory : PS_THEORY_SHARING
end

signature ENV_TAC_LIB = 
sig
  structure PS_Theory : PS_THEORY
  val ENV_new_var : 
    string (* var name *) 
    -> PS_Theory.GoalTyp.Prover.env_data  
    -> PS_Theory.GoalTyp.Prover.env 
    -> PS_Theory.GoalTyp.Prover.env
  val ENV_del_var : 
    string (* var name *) 
    -> PS_Theory.GoalTyp.Prover.env  
    -> PS_Theory.GoalTyp.Prover.env
  val ENV_update_var : 
    string -> 
    (PS_Theory.GoalTyp.Prover.env_data -> PS_Theory.GoalTyp.Prover.env_data) 
    -> PS_Theory.GoalTyp.Prover.env -> PS_Theory.GoalTyp.Prover.env

  structure Sharing : ENV_TAC_LIB_SHARING
    sharing Sharing.PS_Theory = PS_Theory.Sharing
end

functor EnvTacLibFunc (Theory : PS_THEORY) = 
struct
  structure PS_Theory = Theory
  local open LoggingHandler in 

    fun parse_env_var_name' name (* raise exception*) =
       case PS_Theory.Graph_Utils.parse_env_var_name name 
        of NONE 
          => (logging "ENV_DATA" ("Invalid env variable name: " ^ name); raise tinker_fail)
        | (SOME n) => n;
  
    fun ENV_new_var name data env = 
      StrName.NTab.ins ((parse_env_var_name' name), data) env 
     handle StrName.NSet.duplicate_exp _
      => (logging "ENV_DATA" ("The env variable name already exists " ^ name); raise tinker_fail)

    fun ENV_del_var name env = 
      let val _ = 
          if StrName.NTab.contains env (parse_env_var_name' name) then ()
          else logging "ENV_DATA" ("The env variable name to be deleted doesn't exist " ^ name) in
      StrName.NTab.delete (parse_env_var_name' name) env end

    fun ENV_update_var name f env = 
      let val _ = 
          if StrName.NTab.contains env (parse_env_var_name' name) then ()
          else logging "ENV_DATA" ("The env variable name to be updated doesn't exist " ^ name) in
      StrName.NTab.update (f (StrName.NTab.get env (parse_env_var_name' name))) env end
  end (* end of local open *)

  structure Sharing = 
  struct
    structure PS_Theory = PS_Theory.Sharing
  end
end
