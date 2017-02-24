signature BASIC_GOALTYPE_SHARING =
sig
  type T
  type gnode
  type data
  type gtyp
  structure Prover : PROVER_SHARING
end

signature CLAUSE_GOALTYPE =
sig
 structure Prover : PROVER

  exception eval_exp of string;
  exception gt_exp of string; 

  type T
  type gnode
  type data
  type gtyp
  structure GoalTyp_ML_Exec : ML_EXEC
  sharing type GoalTyp_ML_Exec.ret_typ = gtyp
   
  val default : T
  val default_gnode : gnode
  val default_data : data

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
  
  (**********************
    Order and comparing
   **********************)
  val eq : (T * T) -> bool
  val gnode_eq : (gnode * gnode) -> bool
  val goal_name : gnode -> string

  (**********************
    JSON IO
   **********************)
  val gnode_to_json : gnode -> Json.json 
  val gnode_from_json : Json.json -> gnode 

  val merge_data : data -> data -> data
  val data_to_json : data -> Json.json
  val data_from_json : Json.json -> data

  val to_json : T -> Json.json 
  val from_json : Json.json -> T 

  (**********************
    Pretty
   **********************)
  val pretty_gnode : gnode -> Pretty.T
  val pretty_data :  data -> Pretty.T
  val pretty :  T -> Pretty.T
  
  val goal_pretty : gnode -> Pretty.T
 
  val pretty_arg : arg -> Pretty.T
  val pretty_clause : clause -> Pretty.T
  val pretty_env : env -> Pretty.T

  val get_imports : data -> clause list 
  val get_data_defs : data -> clause list
  val get_atomics : data -> gtyp StrName.NTab.T

  val update_imports : (clause list -> clause list) -> data -> data
  val update_data_defs : (clause list -> clause list) -> data -> data
  val update_atomics  : (gtyp StrName.NTab.T -> gtyp StrName.NTab.T) -> data -> data

  val set_imports : clause list -> data -> data
  val set_data_defs : clause list -> data -> data
  val set_atomics : gtyp StrName.NTab.T -> data -> data

  val add_atomic : string -> gtyp -> data -> data
  val add_defs : clause list -> data -> data

  (**********************
    HELPER METHODS
   **********************)
  val dbg_arg_typ : arg -> unit
  val project_env_terms : Prover.env_data -> Prover.term list
  val project_env_str : Prover.env_data -> string list

  val project_terms : Prover.env -> Prover.pnode -> arg -> Prover.term list
  val project_name : Prover.env -> Prover.pnode -> arg -> string list
  val update_var : Prover.env ->  Prover.env_data -> arg -> env list

  (**********************
    EVALUATION
   **********************)
   val check : data * T -> (gnode option * Prover.pnode) -> bool
   val lift : Prover.pnode -> gnode

   val eval_arg : data -> Prover.pnode -> arg -> env -> env list
   val eval_filter_clause : data -> Prover.pnode -> arg -> env -> env list
   val eval_clause : data -> Prover.pnode -> clause -> T -> env -> env list
   val eval_clauses : data -> Prover.pnode -> clause list -> T -> env -> env list
   val eval_defs : data -> Prover.pnode -> T -> env -> env list

   val match_atomic : data -> Prover.pnode -> T -> env -> env list
   val match :  data -> Prover.pnode -> T -> env -> env list 
   val imatch :  data -> Prover.pnode -> T -> env list
   val type_check : data -> Prover.pnode -> T -> bool


  (************************************
    SCAN/PARSE data and goaltype
  *************************************)

  val scan_name : string list -> string * string list
  val scan_term : Prover.context -> string list -> arg * string list
  val scan_clause : Prover.context -> string list -> arg * string list
  val scan_arg : Prover.context -> string list -> arg * string list
  val scan_args : Prover.context -> string list -> arg list * string list
  val scan_body : Prover.context -> string list -> arg list * string list
  val scan_prog :  Prover.context -> string list -> clause * string list 
  val scan_data :  Prover.context -> string -> clause list
  val scan_gt_single :  Prover.context -> string list -> T * string list
  val scan_gt_full :  Prover.context -> string list -> T list * string list
  val scan_goaltyp :  Prover.context -> string -> T

  val add_parse_def : string -> data -> data
 


  structure BasicSharing : BASIC_GOALTYPE_SHARING
    sharing type BasicSharing.T = T
    sharing type BasicSharing.gnode = gnode
    sharing type BasicSharing.data = data    
    sharing type BasicSharing.gtyp = gtyp    
    sharing BasicSharing.Prover = Prover.Sharing

end (* struct *)
