(* 
  to be implemented for a prover
 *)
signature PROVER_SHARING =
sig
  type typ
  type term 
  type thm
  type context
  type tactic
  type env_data
  type env_tac
  type pplan
  type pnode
end

signature PROVER =
sig
  type typ
  type term 
  type thm
  type context
  type tactic 

  (* arguments for atomic goal types and tactics *)
  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term | A_Thm of thm | A_Str of string
 
  datatype env_data = 
    E_Str of string | 
    E_Trm of term  | 
    E_Thm of thm |
    E_ML of string | 
    E_L of env_data list
  val pretty_env_data : context -> env_data -> Pretty.T

  
  type env = env_data StrName.NTab.T 
  
  val parse_env_data : 
    context -> (string * string) (* type, def *) 
    -> (string * env_data) list (* env args *)
    -> env_data  
  val pretty_env :  context -> env -> Pretty.T

  type env_tac =  arg_data list -> env -> env list
  exception env_data_exp 

  type pplan
  type pnode
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  (*type gtyp = env -> pnode -> arg_data list -> env list *)
  structure Tac_ML_Exec : ML_EXEC  where type ret_typ = tactic
  structure EnvTac_ML_Exec : ML_EXEC  where type ret_typ = env_tac
  exception gterm_exp
  
  val default_ctxt : context (* used in those places need default general context *)
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val get_thm_by_name : context -> string -> thm
  val trm_of_string : context -> string -> term
  val prop_of_string : context -> string -> term  
  val string_of_trm : context -> term -> string
  val pretty_trm : context -> term -> Pretty.T
  val antiquto_handler : env -> (string * string) -> string

  val concl_of_thm : thm -> term
  val asms_of_thm : thm -> term list

 (* val subst_trm_vars : (string * term) list -> term -> term*)

  val init : context -> term list -> term -> pnode * pplan

  val apply_tactic : arg_data list -> tactic (* name of tactic *) -> appf
  (* tactics that only update env (used to be in the goaltype)
     this will be registered in the pplan object now \<rightarrow> i.e. a new pnode *)
  val apply_env_tactic :  arg_data list  -> env_tac -> appf

  (* pnode related *)
  val get_open_pnodes : pplan -> pnode list
(*  val get_open_pnode_by_name : pplan -> string -> pnode *)
  val get_pnode_name : pnode -> string
  val get_pnode_concl : pnode -> term (* return type concl which would be type term*)
  val get_pnode_hyps : pnode -> term list
  val get_pnode_ctxt : pnode -> context
  val get_pnode_env : pnode -> env
  val get_pnode_env_data : pnode -> StrName.name -> env_data
  val get_pnode_env_data_as_ML : pnode -> StrName.name -> string
  val get_goal_thm : pplan -> thm
  val get_open_pnode_by_name: pplan -> StrName.name -> pnode
  
  val set_pnode_pplan : pnode -> pplan -> pplan
  val set_pnode_env : env -> pnode -> pnode
  val update_pnode_env : (env -> env) -> pnode -> pnode
  
  (* goal type related
    TO DO: remove: this should be a set of "atomic" instead *)
  (*
  val top_symbol : term -> string
  val symbols : term -> string list
  *)
  (* exec the string as ML code *)
  val exec_str : string -> unit

  (* pretty printing *)
  val pretty_pplan : pplan -> Pretty.T
  val pretty_pnode : pnode -> Pretty.T
  val pretty_goal : pnode -> Pretty.T

  (* for display spec symbol in gui *)
  val encode_prover_to_gui : string -> string
  val encode_gui_to_prover : string -> string
  
  structure Sharing : PROVER_SHARING
    sharing type Sharing.typ = typ
    sharing type Sharing.term = term 
    sharing type Sharing.thm = thm
    sharing type Sharing.context = context
    sharing type Sharing.tactic = tactic 
    sharing type Sharing.env_data = env_data
    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode

end;
(*
structure ProverUtils = 
struct
 local open LoggingHandler in
 fun build_tac_code_with_arg tac_code (tac_args : string list list) = 
  let
    fun concat a b = b ^ " " ^ a;
  
    val tac_args' = 
      (* there should not be empty list *)
      map (fn l => case l of [x] => [x] | (x :: xs) => (x :: ":" :: xs)) tac_args;
    val args = 
      case tac_args' of [] => ""
      | _ => map (fn x => "(" ^ (fold concat x "") ^ " )" ) tac_args'
            |> (fn y => fold concat y "")
  in
     tac_code ^ args
  end;
  end
end
*)
