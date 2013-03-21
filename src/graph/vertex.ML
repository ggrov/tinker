structure DB_VertexData
= struct
  
  structure GSD = GraphSubstData;

  type data = GSD.vdata;
  val data_ord = GSD.vdata_ord;
  val data_eq = GSD.vdata_eq;
 
  val pretty_data = GSD.pretty_vdata;
  val print_data = GSD.print_vdata;

  type subst = GSD.subst;
  val empty_subst = GSD.empty_subst;
  val compose_subst = GSD.compose_subst;

  (* inv: esubst' = esubst *)
  fun match_data (GSD.TVar v1,GSD.TVar v2) (vsubst,esubst) =
      (case StrName.NTab.lookup vsubst v1 of 
            NONE => SOME (StrName.NTab.ins (v1,GSD.TVar v2) vsubst,esubst) (* bind vi if not bound - infinite loop?? *)
          | SOME (GSD.TVar v3) => if v2=v3 then SOME (vsubst,esubst) else NONE (* already bound to v2 *)
          | SOME (GSD.RT r1) => match_data (GSD.RT r1,GSD.TVar v2) (vsubst,esubst) (* bound to RT, check if v2 bound to it *)
          | SOME _ => NONE)
    | match_data (GSD.TVar v,GSD.RT rt) (vsubst,esubst) = 
        (case StrName.NTab.lookup vsubst v of
            NONE => SOME (StrName.NTab.ins (v,GSD.RT rt) vsubst,esubst) (* bind vi if not bound *)
          | SOME (GSD.RT rt') => if RTechn.eq (rt,rt') then SOME (vsubst,esubst) else NONE 
          | SOME (GSD.TVar v') => match_data (GSD.TVar v',GSD.RT rt) (vsubst,esubst)
          | SOME _ => NONE)
   | match_data (GSD.GVar v1,GSD.GVar v2) (vsubst,esubst) = 
      (case StrName.NTab.lookup vsubst v1 of
            NONE => SOME (StrName.NTab.ins (v1,GSD.GVar v2) vsubst,esubst) (* bind vi if not bound - infinite loop?? *)
          | SOME (GSD.GVar v3) => if v2=v3 then SOME (vsubst,esubst) else NONE (* already bound to v2 *)
          | SOME (GSD.GN g1) => match_data (GSD.GN g1,GSD.GVar v2) (vsubst,esubst) (* bound to RT, check if v2 bound to it *)
          | SOME _ => NONE)
    | match_data (GSD.GVar v,GSD.GN gn) (vsubst,esubst) = 
        (case StrName.NTab.lookup vsubst v of
            NONE => SOME (StrName.NTab.ins (v,GSD.GN gn) vsubst,esubst) (* bind vi if not bound *)
          | SOME (GSD.GN gn') => if gn = gn' then SOME (vsubst,esubst) else NONE 
          | SOME (GSD.GVar v') => match_data (GSD.GVar v',GSD.GN gn) (vsubst,esubst)
          | SOME _ => NONE)
    | match_data (GSD.GN g1, GSD.GN g2) subst = 
         if g1 = g2 then SOME subst else NONE
    | match_data (GSD.RT r1, GSD.RT r2) subst = 
         if RTechn.eq (r1,r2) then SOME subst else NONE
    | match_data (GSD.RT rt,GSD.TVar v) subst = NONE
    | match_data (GSD.GN gn,GSD.GVar v) subst = NONE
    | match_data (_,_) _ = NONE

  (* FIXME: unification: if x matches y, and y matches x (with the same subst) *) 
  fun unify_data xy subst = if data_eq xy then SOME subst else NONE;

  (* there is not data in a vertex, subst is just the id on the data *)
  fun subst_in_data (subst,_) (GSD.RT rt) = (GSD.RT rt)
   |  subst_in_data (subst,_) (GSD.GN gn) = (GSD.GN gn)
   |  subst_in_data (subst,_) (GSD.TVar v) = 
        (case StrName.NTab.lookup subst v of
          NONE => (GSD.TVar v) (* or should it fail? *)
        | (SOME d) => d)
   |  subst_in_data (subst,_) (GSD.GVar v) =
        (case StrName.NTab.lookup subst v of
          NONE => (GSD.TVar v)
        | (SOME d) => d);
  
  (* pretty printing for subst *)
  val pretty_subst = GSD.pretty_subst;
  val print_subst = GSD.print_subst; 

  val default_data = GSD.TVar "v";
  
  structure Sharing = struct type data = data; type subst = subst; end;  
end;

structure Strategy_VertexData : UNIFIABLE_DATA = DB_VertexData;

(* I think this is now replaced by JSON STUFF *)
structure Strategy_VertexComponentData_Param
: ELEMENT_COMPONENT_DATA_PARAM where type data = Strategy_VertexData.data
= struct 
  type data = Strategy_VertexData.data;
  exception unknown_type_exp of string;
  exception unexpected_data_exp;

  structure VD = DB_VertexData
  structure GSD = GraphSubstData;

  fun type_of (GSD.RT _) = "RT"
    | type_of (GSD.GN _) = "GN"
    | type_of (GSD.TVar _) = "TVar"
    | type_of (GSD.GVar _) = "GVar";

  fun cdata_of d = 
    ComponentData.String (Pretty.string_of (DB_VertexData.pretty_data d));
  
  (* New nodes are by default RTechnNodes *)
  fun default_data "RT" = GSD.RT (RTechn.id)
    | default_data "GN" = GSD.GN ([])
    | default_data "TVar" = GSD.TVar "v"
    | default_data "GVar" = GSD.GVar "v"
    | default_data s = raise unknown_type_exp s;


  fun update upd (GSD.RT rt) = GSD.RT rt
    | update upd (GSD.GN gn) = GSD.GN gn
    | update upd (GSD.TVar v)   = GSD.TVar v
    | update upd (GSD.GVar v)   = GSD.GVar v;   

end;



