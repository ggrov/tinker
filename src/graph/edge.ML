signature PS_EDGE =
sig
  include UNIFIABLE_DATA;
  structure GraphSubstData : GRAPH_SUBST_DATA
  structure EComponentData_Param : ELEMENT_COMPONENT_DATA_PARAM 
   sharing type data = GraphSubstData.edata

end

functor PSEdgeDataFun(GraphSubstData : GRAPH_SUBST_DATA) : PS_EDGE
= struct
  structure GraphSubstData = GraphSubstData;
  structure GSD = GraphSubstData; 
  structure GoalTyp = GSD.GoalTyp;

  type data = GSD.edata;
  val data_ord = GSD.edata_ord;
  val data_eq = GSD.edata_eq;

  val pretty_data = GSD.pretty_edata;
  val print_data = GSD.print_edata;

  type subst = GSD.subst;
  val empty_subst = GSD.empty_subst;
  val compose_subst = GSD.compose_subst

  fun match_data (GSD.EVar v1,e) subst =
      (case GSD.lookup_esubst subst v1 of
            NONE => SOME (GSD.add_esubst (v1,e) subst)
          | SOME e2 => if GSD.edata_eq(e,e2) then SOME subst else NONE)
   |  match_data (GSD.GT gt1,GSD.GT gt2) subst = if 
         GoalTyp.eq(gt1,gt2) then SOME subst else NONE
   |  match_data (GSD.GT _,GSD.EVar _) _ = NONE

  fun unify_data xy subst = if GSD.edata_eq xy then SOME subst else NONE;

  fun subst_in_data subst (GSD.GT gt) = (GSD.GT gt)
   |  subst_in_data subst (GSD.EVar v) = 
        (case GSD.lookup_esubst subst v of
          NONE => (GSD.EVar v)
        | (SOME d) => d);
  
  (* pretty printing for subst *)
  val pretty_subst = GSD.pretty_subst;
  val print_subst = GSD.print_subst; 

  val default_data = GSD.EVar "v";
  
  structure Sharing = struct type data = data; type subst = subst; end; 

  structure EComponentData_Param 
    : ELEMENT_COMPONENT_DATA_PARAM where type data = GSD.edata
  = struct

     type data = GSD.edata;
     exception unknown_type_exp of string;
     exception unexpected_data_exp;

    fun type_of (GSD.GT _) = "GT"
      | type_of (GSD.EVar _) = "EVar";

    fun cdata_of d = 
      ComponentData.String (Pretty.string_of (pretty_data d));
  
    fun default_data "GT" = GSD.GT (GoalTyp.top)
      | default_data "EVar" = GSD.EVar "v"
      | default_data s = raise unknown_type_exp s;

    fun update upd (GSD.GT gt) = GSD.GT gt
      | update upd (GSD.EVar v)   = GSD.EVar v;     

  end (* struct EComponentData_Param *)
end;

(* structure PS_EdgeData : UNIFIABLE_DATA = DB_EdgeData; *)

(*  
structure PS_EdgeComponentData_Param
: ELEMENT_COMPONENT_DATA_PARAM where type data = PS_EdgeData.data
= struct 
  type data = PS_EdgeData.data;
  exception unknown_type_exp of string;
  exception unexpected_data_exp;

  structure GSD = GraphSubstData;

  fun type_of (GSD.GT _) = "GT"
    | type_of (GSD.EVar _) = "EVar";

  fun cdata_of d = 
    ComponentData.String (Pretty.string_of (DB_EdgeData.pretty_data d));
  
  fun default_data "GT" = GSD.GT (GoalTyp.top)
    | default_data "EVar" = GSD.EVar "v"
    | default_data s = raise unknown_type_exp s;


  fun update upd (GSD.GT gt) = GSD.GT gt
    | update upd (GSD.EVar v)   = GSD.EVar v;   

end;
*)
