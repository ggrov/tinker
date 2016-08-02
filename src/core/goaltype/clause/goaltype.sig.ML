signature CLAUSE_GOALTYPE =
sig
  include BASIC_GOALTYPE

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
 

end (* struct *)
