(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      gproof/trm.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
                Initially written Oct 2005, Updated 10 Mar 2006        *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Abstract Term information 
*)

(* basic term *)
signature TRM =
sig
  (* names of type vars, type frees, vars and frees *)
  structure TVar : NAME
  structure TFree : NAME
  structure Var : NAME
  structure Free : NAME

  (* name conversions *)
  val var_of_free_name : Free.name -> Var.name
  val tvar_of_tfree_name : TFree.name -> TVar.name
  val free_of_var_name : Var.name -> Free.name
  val tfree_of_tvar_name : TVar.name -> TFree.name

  (* sorts *)
  type sort
  val eq_sort : sort * sort -> bool
  val pretty_sort : Proof.context -> sort -> Pretty.T

  (* types *)
  type typ
  val eq_typ : typ * typ -> bool
  val pretty_typ : Proof.context -> typ -> Pretty.T

  (* free/meta-level-bound parameters *)
  structure TypParams : PARAM_TAB 
    sharing TypParams.NTab.Sharing = TFree.NTab.Sharing
    sharing type TypParams.kind = sort

  structure TrmParams : PARAM_TAB 
    sharing TrmParams.NTab.Sharing = Free.NTab.Sharing
    sharing type TrmParams.kind = typ

  (* terms *)
  type T

  (* full internal equality *)
  val eq : T * T -> bool

  exception exp of string

  (* basic term consturction/deconsturction *)
  val opt_dest_var : T -> (Var.name * typ) option
  val dest_var : T -> (Var.name * typ)
  val opt_dest_tvar : typ -> (TVar.name * sort) option
  val dest_tvar : typ -> (TVar.name * sort)
  val mk_var : (Var.name * typ) -> T
  val mk_abs : (Free.name * typ * T) -> T
  val mk_app : (T * T) -> T
  val mk_tvar : (TVar.name * sort) -> typ
  val mk_tfree : (TFree.name * sort) -> typ
  val mk_free : (Free.name * typ) -> T
  val list_abs: (string * typ) list * T -> T

  (* structural info *)
  val is_abs : T -> bool
  val is_app : T -> bool
  val is_leaf : T -> bool

  (* vars and frees of a term *)
  val vars_of : T -> (Var.name * typ) list
  val tvars_of : T -> (TVar.name * sort) list
  val typ_tvars_of : typ -> (TVar.name * sort) list

  val frees_of : T -> (Free.name * typ) list
  val term_frees : T -> T list
  val tfrees_of : T -> (TFree.name * sort) list
  val typ_tfrees_of : typ -> (TFree.name * sort) list

  (* constants in a term, including duplicates *)
  val constnames_of : T -> string list
  val consts_of : T -> (string * typ) list

  val atomic_typconsts_of_typ : typ -> string list

  (* get tables of vars from terms *)
  val trm_var_tab_of : T -> typ Var.NTab.T
  val typ_var_tab_of : T -> sort TVar.NTab.T


  (* Parameter Tables (frees/fixed things) *)
  val addto_params (* ignores existing params *)
      : T -> TrmParams.T
        -> (Free.name * typ) list (* new params *)
           * TrmParams.T (* all params *)
  val addto_tparams (* ignores existing params, only adds new ones *)
      : T -> TypParams.T
        -> (TFree.name * sort) list (* new params *)
           * TypParams.T (* all params *)

  (* making all frees fresh... *)
  val addfresh_in_params' (* renames params to be fresh *)
      : TrmParams.T -> T 
        -> ((Free.name * typ) list (* new params *)
            * Free.name TrmParams.NTab.T) (* renaming *)
           * TrmParams.T (* all params *)
  val addfresh_in_params : TrmParams.T -> T -> TrmParams.T (* renamed to be fresh *)
  val params_of : T -> TrmParams.T

  val addfresh_in_tparams' (* renames params to be fresh *)
      : TypParams.T -> T 
        -> ((TFree.name * sort) list (* new params *)
            * TFree.name TypParams.NTab.T) (* renamings *)
           * TypParams.T (* all params *)
  val addfresh_in_tparams : TypParams.T -> T -> TypParams.T (* renamed to be fresh *)
  val tparams_of : T -> TypParams.T

  (* change all meta-level alls to frees, avoiding given params *)
  val fix_all_params' : TrmParams.T -> T -> 
                    (T * ((Free.name * typ) list * (* new + old *)
                          TrmParams.T)) (* new *)
  (* ignore new ones *)
  val fix_all_params : TrmParams.T -> T -> (T * TrmParams.T) 
  (* only new params are added to paramtab in refix_params *)
  val refix_all_params' : TrmParams.T -> T 
                          -> (T * ((Free.name * typ) list * 
                                   TrmParams.T)) 

  (* change frees to lambdas on the outside *)
  val absify_params : TrmParams.T -> T -> T (* for flexes *)
  (* change frees to meta level alls *)
  val allify_params : TrmParams.T -> T -> T (* for goals *)

  (*  *)
  val fix_params : TrmParams.T -> T -> T


  (* mapping over term vars *)
  val map_typ_tvars : ((TVar.name * sort) * typ -> typ) 
                      -> typ -> typ
  val map_typ_tfrees : ((TFree.name * sort) * typ -> typ) 
                      -> typ -> typ
  val map_trm_tvars : ((TVar.name * sort) * typ -> typ) 
                       -> T -> T
  val map_trm_vars : ((Var.name * typ) * T -> T) -> T -> T
  val map_trm_frees : ((Free.name * typ) * T -> T) -> T -> T
  val map_trm_types : (typ -> typ) -> T -> T

  (* foldmapping over term vars *)
  val foldmap_typ_tvars : 
      ('a -> (TVar.name * sort) * typ -> 'a * typ) ->
      'a -> typ -> 'a * typ
  val foldmap_trm_tvars :  
      ('a -> (TVar.name * sort) * typ -> 'a * typ) ->
      'a -> T -> 'a * T
  val foldmap_trm_vars : 
      ('a -> (Var.name * typ) * T -> 'a * T) ->
      'a -> T -> 'a * T
  val foldmap_trm_vars_and_tvars : 
      ('a -> (TVar.name * sort) * typ -> 'a * typ) ->
      ('a -> (Var.name * typ) * T -> 'a * T) -> 
      'a -> T -> 'a * T

  (* foldmapping over frees (fixed vars) *)
  val foldmap_typ_tfrees : 
      ('a -> (TFree.name * sort) * typ -> 'a * typ) ->
      'a -> typ -> 'a * typ
  val foldmap_trm_tfrees :  
      ('a -> (TFree.name * sort) * typ -> 'a * typ) ->
      'a -> T -> 'a * T
  val foldmap_trm_frees : 
      ('a -> (Free.name * typ) * T -> 'a * T) ->
      'a -> T -> 'a * T
  val foldmap_trm_frees_and_tfrees : 
      ('a -> (TFree.name * sort) * typ -> 'a * typ) ->
      ('a -> (Free.name * typ) * T -> 'a * T) -> 
      'a -> T -> 'a * T

  (* changing frees and vars, 
     given set of used stuff (to avoid), 
     changed names so far, and term to be changed.  *)
   val change_vars_to_fresh_frees' : 
      ((TypParams.NSet.T * TFree.name TVar.NTab.T)
       * (TrmParams.NSet.T * Free.name Var.NTab.T)) -> T 
      -> 
      ((TypParams.NSet.T * TFree.name TVar.NTab.T)
       * (TrmParams.NSet.T * Free.name Var.NTab.T)) * T 
  val change_frees_to_fresh_vars' : 
      ((TVar.NSet.T * TVar.name TypParams.NTab.T) 
       * (Var.NSet.T * Var.name TrmParams.NTab.T)) -> T 
      -> 
      ((TVar.NSet.T * TVar.name TypParams.NTab.T) 
       * (Var.NSet.T * Var.name TrmParams.NTab.T)) * T 

  val change_vars_to_fresh_frees : T -> T
  val change_frees_to_fresh_vars : T -> T

  (* instantiations *)
  val inst1_typ_typ : TVar.name * typ -> typ -> typ
  val inst1_trm_typ : TVar.name * typ -> T -> T
  val inst1_trm_trm : Var.name * T -> T -> T

  (* calc things *)
  val beta_norm : T -> T
  val eta_contract : T -> T

  (* terms are the same upto free-var (Free.name) renaming *)
  val typ_name_eq' : typ -> typ -> TFree.renaming -> TFree.renaming option
  val typ_name_eq : typ -> typ -> bool
  val trm_name_eq' : T -> T -> Free.renaming * TFree.renaming 
                    -> (Free.renaming * TFree.renaming) option
  val trm_name_eq : T -> T -> bool

  (* logic stuff, no? *)
  val prems_of : T -> T list
  val concl_of : T -> T
  val list_implies : T list -> T -> T

  (* pretty printing *)
  val drop_var_args_flag : bool Unsynchronized.ref; (* drop var args in pretty printing *)
  val pretty : Proof.context -> T -> Pretty.T
  val print : Proof.context -> T -> unit

  structure MLSerialise : sig
    val string_of_term : T -> string 
    val string_of_type : typ -> string 
    val string_of_sort : sort -> string
    val print_term : T -> unit
    val print_type : typ -> unit
    val print_sort : sort -> unit
  end;
end;
