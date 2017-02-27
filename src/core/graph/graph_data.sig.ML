(* to do: all should be in a single file *)
signature GRAPH_DATA_SHARING = 
sig
  type nvdata
  type edata
  structure GoalTyp : BASIC_GOALTYPE_SHARING
end

signature GRAPH_DATA =
sig
  structure GoalTyp : CLAUSE_GOALTYPE

  type arg_typ = string list list 
  (*e.g. [[trm, A_Trm], [ml_str, A_ML]] = (trm : A_Trm) (ml_str : A_ML), eventually,
    this should be parsed into the arg_data in prover, which is [A_Trm trm, A_ML ml_str]*)
  val arg_typ_to_json : arg_typ -> Json.json 
  val arg_typ_from_json : Json.json -> arg_typ


(* note: variables only for evaluation! *)
  datatype nvdata =  T_Atomic of  (string * arg_typ)
             | T_Graph of (string * arg_typ)
             | T_Identity 
             | G_Break (* breakpoint *)
             | G of GoalTyp.gnode 
             | T_Var of string (* variable of rtechn *)
             | G_Var of string (* variable of gnode *)

  datatype edata = GT of GoalTyp.T
                 | GT_Var of string (* variable of goal node *)
  
  exception gdata_json_exp of string * Json.json
  val get_nvdata_name : nvdata -> string
  val get_nvdata_args : nvdata -> arg_typ
  val nvdata_to_json : nvdata -> Json.json
  val nvdata_from_json : Json.json -> nvdata
  val edata_to_json : edata -> Json.json
  val edata_from_json : Json.json -> edata

  val nvdata_eq : nvdata * nvdata -> bool
  val edata_eq : edata * edata -> bool

  exception node_exp of string * nvdata;

  val identity : nvdata
  val break_point : nvdata

  val is_tactic_node : nvdata -> bool
  val is_atomic : nvdata -> bool
  val is_nested : nvdata -> bool
  val is_identity : nvdata -> bool
  val is_break_point : nvdata -> bool

  val pretty_theory_name : Pretty.T

  (* default vertex and edge data *)
  val default_nvdata : nvdata
  val default_edata : edata

  val pretty_nvdata : nvdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T
  val print_nvdata : nvdata -> unit
  val print_edata : edata -> unit

  structure Sharing : GRAPH_DATA_SHARING
    sharing type Sharing.nvdata = nvdata
    sharing type Sharing.edata = edata
    sharing Sharing.GoalTyp = GoalTyp.BasicSharing

end


