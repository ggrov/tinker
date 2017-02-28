(* to do: all should be in a single file *)
signature GRAPH_DATA_SHARING = 
sig
  type vdata
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
  datatype vdata =  
     T_Atomic of  (string * arg_typ)
   | T_Graph of (string * arg_typ)
   | T_Identity 
   | G_Break (* breakpoint *)
   | G of GoalTyp.gnode 
   | T_Var of string (* variable of rtechn *)
   | G_Var of string (* variable of gnode *)
   | Boundary (* boundary of a graph *)

  datatype edata = GT of GoalTyp.T
                 | GT_Var of string (* variable of goal node *)
  
  exception gdata_json_exp of string * Json.json
  val get_vdata_name : vdata -> string
  val get_vdata_args : vdata -> arg_typ
  val vdata_to_json : vdata -> Json.json
  val vdata_from_json : Json.json -> vdata
  val edata_to_json : edata -> Json.json
  val edata_from_json : Json.json -> edata

  val vdata_eq : vdata * vdata -> bool
  val edata_eq : edata * edata -> bool

  exception node_exp of string * vdata;

  val identity : vdata
  val break_point : vdata

  val is_tactic_node : vdata -> bool
  val is_atomic : vdata -> bool
  val is_nested : vdata -> bool
  val is_identity : vdata -> bool
  val is_break_point : vdata -> bool
  val is_boundary  : vdata -> bool

  val pretty_theory_name : Pretty.T

  (* default vertex and edge data *)
  val default_vdata : vdata
  val default_edata : edata

  val pretty_vdata : vdata -> Pretty.T
  val pretty_edata : edata -> Pretty.T
  val print_vdata : vdata -> unit
  val print_edata : edata -> unit

  structure Sharing : GRAPH_DATA_SHARING
    sharing type Sharing.vdata = vdata
    sharing type Sharing.edata = edata
    sharing Sharing.GoalTyp = GoalTyp.BasicSharing

end


