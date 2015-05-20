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
  datatype arg_data =  A_Const of string | A_Var of string | A_Trm of term 
  datatype env_data = E_Str of string | E_Trm of term | E_Trms of term list |  E_Thm of thm | E_L of env_data list
  type env = env_data StrName.NTab.T 

  type pplan
  type pnode
  type appf = pnode * pplan -> (pnode list * pplan) Seq.seq

  type gtyp = env -> pnode -> arg_data list -> env list

  exception gterm_exp
  
  val default_ctxt : context (* used in those place need context in general *)
  val typ_of : term -> typ
  val match : context -> (term * term) -> bool

  val trm_of_string : context -> string -> term
  val string_of_trm : context -> term -> string
  val pretty_trm : context -> term -> Pretty.T

  val concl_of_thm : thm -> term
  val asms_of_thm : thm -> term list

  val init : context -> term list -> term -> pnode * pplan

  val apply_tactic : arg_data list -> tactic -> appf
  (* tactics that only update env (used to be in the goaltype)
     this will be registered in the pplan object now \<rightarrow> i.e. a new pnode *)
  val apply_env_tactic : arg_data list -> (arg_data list -> env -> env) -> appf

  (* pnode related *)
  val get_open_pnodes : pplan -> pnode list
  val get_pnode_name : pnode -> string
  val get_pnode_concl : pnode -> term (* return type concl which would be type term*)
  val get_pnode_hyps : pnode -> term list
  val get_pnode_ctxt : pnode -> context
  val get_pnode_env : pnode -> env
 
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
  (* for display spec symbol in gui *)
  val encode_prover_to_gui : string -> string
  val encode_gui_to_prover : string -> string
  
  structure Sharing : PROVER_SHARING
    sharing type Sharing.typ = typ
    sharing type Sharing.term = term 
    sharing type Sharing.thm = thm
    sharing type Sharing.context = context
    sharing type Sharing.tactic = tactic 

    sharing type Sharing.pplan = pplan
    sharing type Sharing.pnode = pnode

end;

