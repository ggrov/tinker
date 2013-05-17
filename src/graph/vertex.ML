signature PS_VERTEX =
sig
  include UNIFIABLE_DATA;
  structure GraphSubstData : GRAPH_SUBST_DATA
  structure VComponentData_Param : ELEMENT_COMPONENT_DATA_PARAM 
   sharing type data = GraphSubstData.vdata
end

functor PSVertexDataFun(GraphSubstData : GRAPH_SUBST_DATA) : PS_VERTEX
= struct
  structure GraphSubstData = GraphSubstData;
  structure GSD = GraphSubstData;

  type data = GSD.vdata;
  val data_ord = GSD.vdata_ord;
  val data_eq = GSD.vdata_eq;
 
  val pretty_data = GSD.pretty_vdata;
  val print_data = GSD.print_vdata;

  type subst = GSD.subst;
  val empty_subst = GSD.empty_subst;
  val compose_subst = GSD.compose_subst;


  fun match_gnode (GSD.GN_Node g1,GSD.GN_Node g2) subst =
         if GNode.eq(g1,g2) then SOME subst else NONE
   |  match_gnode (GSD.GN_Node _,_) _ = NONE
   |  match_gnode (GSD.GN_Var v,GSD.GN_Node g) subst = 
        (case GSD.lookup_gsubst subst v of
          NONE => SOME (GSD.add_gsubst (v,g) subst)
        | (SOME g') => if GNode.eq(g,g') then SOME subst else NONE)
   |  match_gnode (GSD.GN_Var v1,GSD.GN_Var v2) subst = NONE

  fun match_gnodel ([],[]) subst = SOME subst
   |  match_gnodel ([],_) _ = NONE
   |  match_gnodel (_,[]) _ = NONE
   |  match_gnodel (g1::gs1,g2::gs2) subst =
       case match_gnode (g1,g2) subst of
        NONE => NONE
       | SOME subst' => match_gnodel (gs1,gs2) subst';

  (* inv: esubst' = esubst *)
  fun match_data (GSD.TVar v1,GSD.TVar v2) subst = NONE
    | match_data (GSD.TVar v,GSD.RT rt) subst = 
        (case GSD.lookup_vsubst subst v of
            NONE => SOME (GSD.add_vsubst (v,GSD.RT rt) subst) (* bind vi if not bound *)
          | SOME (GSD.RT rt') => if RTechn.eq (rt,rt') then SOME subst else NONE 
          | SOME _ => NONE)
   | match_data (GSD.GVar v1,GSD.GVar v2) subst = NONE
   | match_data (GSD.GVar v,GSD.GN gn) subst = 
        (case GSD.lookup_vsubst subst v of
            NONE => SOME (GSD.add_vsubst (v,GSD.GN gn) subst) (* bind vi if not bound *)
          | SOME (GSD.GN gn') => match_gnodel (gn,gn') subst
          | SOME _ => NONE)
    | match_data (GSD.GN gn1, GSD.GN gn2) subst = match_gnodel (gn1,gn2) subst
    | match_data (GSD.RT r1, GSD.RT r2) subst = 
         if RTechn.eq (r1,r2) then SOME subst else NONE
    | match_data (_,_) subst = NONE


  (* FIXME: unification: if x matches y, and y matches x (with the same subst) *) 
  fun unify_data xy subst = if data_eq xy then SOME subst else NONE;

  fun subst_in_gdata subst [] = []
   |  subst_in_gdata subst ((GSD.GN_Node gn)::gs) = 
       (GSD.GN_Node gn)::subst_in_gdata subst gs
   |  subst_in_gdata subst ((GSD.GN_Var v)::gs) =
        (case StrName.NTab.lookup subst v of
          NONE => (GSD.GN_Var v)
        | (SOME d) => (GSD.GN_Node d))
       :: subst_in_gdata subst gs;

  fun subst_in_data _ (GSD.RT rt) = (GSD.RT rt)
   |  subst_in_data (GSD.Subst {gnode, ...}) (GSD.GN gn) = GSD.GN (subst_in_gdata gnode gn)
   |  subst_in_data (GSD.Subst {vertex, ...}) (GSD.TVar v) = 
        (case StrName.NTab.lookup vertex v of
          NONE => (GSD.TVar v) (* or should it fail? *)
        | (SOME d) => d)
   |  subst_in_data (GSD.Subst {vertex,...}) (GSD.GVar v) =
        (case StrName.NTab.lookup vertex v of
          NONE => (GSD.TVar v)
        | (SOME d) => d);
  
  (* pretty printing for subst *)
  val pretty_subst = GSD.pretty_subst;
  val print_subst = GSD.print_subst; 

  val default_data = GSD.TVar "v";
  
  structure Sharing = struct type data = data; type subst = subst; end;  

  structure VComponentData_Param 
    : ELEMENT_COMPONENT_DATA_PARAM where type data = GSD.vdata
  = struct

     type data = GSD.vdata;
     exception unknown_type_exp of string;
     exception unexpected_data_exp;

     fun type_of (GSD.RT _) = "RT"
      | type_of (GSD.GN _) = "GN"
      | type_of (GSD.TVar _) = "TVar"
      | type_of (GSD.GVar _) = "GVar";

     fun cdata_of d = 
       ComponentData.String (Pretty.string_of (pretty_data d));
  
     fun default_data "RT" = GSD.RT (RTechn.id)
       | default_data "GN" = GSD.GN ([])
       | default_data "TVar" = GSD.TVar "v"
       | default_data "GVar" = GSD.GVar "v"
       | default_data s = raise unknown_type_exp s;

    fun update upd (GSD.RT rt) = GSD.RT rt
       | update upd (GSD.GN gn) = GSD.GN gn
       | update upd (GSD.TVar v)   = GSD.TVar v
       | update upd (GSD.GVar v)   = GSD.GVar v;   

   end (* struct VComponentData_Param *)
end; (* functor *)

