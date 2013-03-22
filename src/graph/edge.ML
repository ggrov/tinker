structure DB_EdgeData
= struct
  structure GSD = GraphSubstData; 

  type data = GSD.edata;
  val data_ord = GSD.edata_ord;
  val data_eq = GSD.edata_eq;

  val pretty_data = GSD.pretty_edata;
  val print_data = GSD.print_edata;

  type subst = GSD.subst;
  val empty_subst = GSD.empty_subst;
  val compose_subst = GSD.compose_subst

  fun match_data (GSD.EVar v1,e) (vsubst,esubst) =
      (case StrName.NTab.lookup esubst v1 of
            NONE => SOME (vsubst,StrName.NTab.ins (v1,e) esubst)
          | SOME e2 => if GSD.edata_eq(e,e2) then SOME (vsubst,esubst) else NONE)
   |  match_data (GSD.GT gt1,GSD.GT gt2) (vsubst,esubst) = if 
         GoalTyp.eq(gt1,gt2) then SOME (vsubst,esubst) else NONE
   |  match_data (GSD.GT gt,GSD.EVar v) (vsubst,esubst) = NONE

  fun unify_data xy subst = if GSD.edata_eq xy then SOME subst else NONE;

  fun subst_in_data (_,esubst) (GSD.GT gt) = (GSD.GT gt)
   |  subst_in_data (_,esubst) (GSD.EVar v) = 
        (case StrName.NTab.lookup esubst v of
          NONE => (GSD.EVar v)
        | (SOME d) => d);
  
  (* pretty printing for subst *)
  val pretty_subst = GSD.pretty_subst;
  val print_subst = GSD.print_subst; 

  val default_data = GSD.EVar "v";
  
  structure Sharing = struct type data = data; type subst = subst; end;  
end;

structure Strategy_EdgeData : UNIFIABLE_DATA = DB_EdgeData;

(*  *)
structure Strategy_EdgeComponentData_Param
: ELEMENT_COMPONENT_DATA_PARAM where type data = Strategy_EdgeData.data
= struct 
  type data = Strategy_EdgeData.data;
  exception unknown_type_exp of string;
  exception unexpected_data_exp;

  structure GSD = GraphSubstData;

  fun type_of (GSD.GT _) = "GT"
    | type_of (GSD.EVar _) = "EVar";

  fun cdata_of d = 
    ComponentData.String (Pretty.string_of (DB_EdgeData.pretty_data d));
  
  (* New nodes are by default RTechnNodes *)
  fun default_data "GT" = GSD.GT (GoalTyp.top)
    | default_data "EVar" = GSD.EVar "v"
    | default_data s = raise unknown_type_exp s;


  fun update upd (GSD.GT gt) = GSD.GT gt
    | update upd (GSD.EVar v)   = GSD.EVar v;   

end;
