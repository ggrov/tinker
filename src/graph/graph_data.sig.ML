(* to do: all should be in a single file *)

signature PSGRAPH_DATA =
sig
  structure GoalTyp : BASIC_GOALTYPE

  type arg_typ = string list list

  (* note: variables only for evaluation! *)
  datatype nvdata =  T_Atomic of { name : string, args : arg_typ}
             | T_Graph of { name : string, args : arg_typ, is_or : bool}
             | T_Identity 
             | G_Break (* breakpoint *)
             | G of GoalTyp.gnode 
             | T_Var of string (* variable of rtechn *)
             | G_Var of string (* variable of gnode *)
  datatype edata = GT of GoalTyp.T
                 | GT_Var of string (* variable of goalnode *)

  datatype subst = Subst of { tactic : nvdata StrName.NTab.T,
                              gnode : GoalTyp.gnode StrName.NTab.T,
                              edge : edata StrName.NTab.T }

  type psubst = subst

  val nvdata_eq : nvdata * nvdata -> bool
  val edata_eq : edata * edata -> bool

  exception node_exp of string * nvdata;

  (* tactic nodes *)

  val get_name : nvdata -> string 
  val get_args : nvdata -> arg_typ  (* raises rtechn_exp *)
  val get_is_or : nvdata ->  bool (* raises rtechn_exp *)

  val update_name : (string -> string) -> nvdata -> nvdata 
  val update_args : (arg_typ -> arg_typ) -> nvdata -> nvdata  (* raises rtechn_exp *)
  val update_is_or : (bool -> bool) -> nvdata -> nvdata  (* raises rtechn_exp *)

  val set_name : string -> nvdata -> nvdata 
  val set_args : arg_typ -> nvdata -> nvdata  (* raises rtechn_exp *)
  val set_is_or : bool -> nvdata -> nvdata  (* raises rtechn_exp *)

  val identity : nvdata
  val break_point : nvdata

  val is_tactic_node : nvdata -> bool
  val is_atomic : nvdata -> bool
  val is_nested : nvdata -> bool
  val is_identity : nvdata -> bool
  val is_break_point : nvdata -> bool
  val is_or : nvdata -> bool option
  val is_or' : nvdata -> bool (* false if not nested *)
  
  (* substitutions *)

  val empty_subst : subst
  val compose_subst : subst * subst -> subst
  
  val add_vsubst : (string * nvdata) -> subst -> subst
  val add_esubst : (string * edata) -> subst -> subst
  val add_gsubst : (string * GoalTyp.gnode) -> subst -> subst

  val lookup_tsubst : subst -> string -> nvdata option
  val lookup_esubst : subst -> string -> edata option
  val lookup_gsubst : subst -> string -> GoalTyp.gnode option

  val pretty_theory_name : Pretty.T

  (* A partial substitution contains a collection of constraints on pattern
   * variables. It is initialised by passing in a table containing node/edge
   * data from the pattern and target graphs. This can be used e.g. to ensure that names
   * introduced in the pattern are fresh. *)
  val init_psubst_from_data :
    nvdata VTab.T * edata ETab.T ->
    nvdata VTab.T * edata ETab.T -> psubst

  (* The match_xxx functions update a psubst or return NONE if
   * no match is possible. *)
  val match_nvdata : nvdata * nvdata -> psubst -> psubst option
  val match_edata : edata * edata -> psubst -> psubst option

  (* default vertex and edge data *)
  val default_nvdata : nvdata
  val default_edata : edata

  (* COMPAT: needed for old controller *)
  val default_nvdata_of_typestring : string -> nvdata
  (* COMPAT: needed for old controller *)
  val default_edata_of_typestring  : string -> edata

  val pretty_nvdata : nvdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T

  (* For cases where node/edge data cannot be unified greedily (or uniquely),
   * this is called just before the match is finalised. One match will be
   * produced for each subst returned. In the case where this hook isn't
   * needed, let "type subst = psubst", and "solve_psubst = Seq.single". *)
  val solve_psubst : psubst -> subst Seq.seq

  (* Apply substitutions to data. *)
  val subst_in_nvdata : subst -> nvdata -> subst * nvdata
  val subst_in_edata : subst -> edata -> subst * edata


end


