structure DB_VertexData
= struct

  datatype data = RT of RTechn.T
                 | GN of GNode.T
                 | RVar of string (* variable of rtechn *)
                 | GVar of string (* variable of goalnode *)

  (* ordering is used for building tables, sorting, etc *)
  fun data_ord (RVar v1,RVar v2) = String.compare (v1,v2)
    | data_ord (RVar v1,RVar v2) = String.compare (v1,v2)
    | data_ord (RVar _,_) = LESS
    | data_ord (GVar _,_) = LESS
    | data_ord (GN _, RT _) = LESS
    | data_ord (RT _, GN _) = GREATER
    | data_ord (GN g1, GN g2) = GNode.ord (g1,g2)
    | data_ord (RT r1, RT r2) = RTechn.ord (r1,r2);

  (* equality check (should agree with order):
     data_eq(x,y) <=> data_ord (x,y) = EQUAL *)
  fun data_eq (xy as (x, y)) = 
      (case data_ord xy of EQUAL => true
          | _ => false);
 
  fun pretty_data (RT rt) = RTechn.pretty rt
   |  pretty_data (GN gn) = GNode.pretty gn
   |  pretty_data (RVar s) = Pretty.str ("?R_" ^ s)
   |  pretty_data (GVar s) = Pretty.str ("?G_" ^ s);

  val print_data = Pretty.writeln o pretty_data;
  
  fun pretty_node (RT rt) = RTechn.pretty_name rt
   |  pretty_node (GN gn) = GNode.pretty gn
   |  pretty_node (RVar s) = Pretty.str ("?R_" ^ s)
   |  pretty_node (GVar s) = Pretty.str ("?G_" ^ s);

  (* assume that RVar and GVar sets are disjoint! *)
  type subst = data StrName.NTab.T;

  val empty_subst = StrName.NTab.empty;
  
  (* u2 overrides u1 *)
  fun compose_subst (u1,u2) = (StrName.NTab.merge_joint data_eq u1 u2);

  (* shouldn't really be variable on rhs. Matching gets a bit
     complicated due to the two different types of variables *)
  fun match_data (RVar v1,RVar v2) subst =
      (case StrName.NTab.lookup subst v1 of 
            NONE => SOME (StrName.NTab.ins (v1,RVar v2) subst) (* bind vi if not bound - infinite loop?? *)
          | SOME (RVar v3) => if v2=v3 then SOME subst else NONE (* already bound to v2 *)
          | SOME (RT r1) => match_data (RT r1,RVar v2) subst (* bound to RT, check if v2 bound to it *)
          | SOME _ => NONE)
    | match_data (RVar v,RT rt) subst = 
        (case StrName.NTab.lookup subst v of
            NONE => SOME (StrName.NTab.ins (v,RT rt) subst) (* bind vi if not bound *)
          | SOME (RT rt') => if RTechn.eq (rt,rt') then SOME subst else NONE 
          | SOME (RVar v') => match_data (RVar v',RT rt) subst
          | SOME _ => NONE)
   | match_data (GVar v1,GVar v2) subst = 
      (case StrName.NTab.lookup subst v1 of
            NONE => SOME (StrName.NTab.ins (v1,GVar v2) subst) (* bind vi if not bound - infinite loop?? *)
          | SOME (GVar v3) => if v2=v3 then SOME subst else NONE (* already bound to v2 *)
          | SOME (GN g1) => match_data (GN g1,GVar v2) subst (* bound to RT, check if v2 bound to it *)
          | SOME _ => NONE)
    | match_data (GVar v,GN gn) subst = 
        (case StrName.NTab.lookup subst v of
            NONE => SOME (StrName.NTab.ins (v,GN gn) subst) (* bind vi if not bound *)
          | SOME (GN gn') => if GNode.eq (gn,gn') then SOME subst else NONE 
          | SOME (GVar v') => match_data (GVar v',GN gn) subst
          | SOME _ => NONE)
    | match_data (GN g1, GN g2) subst = 
         if GNode.eq (g1,g2) then SOME subst else NONE
    | match_data (RT r1, RT r2) subst = 
         if RTechn.eq (r1,r2) then SOME subst else NONE
    | match_data (RT rt,RVar v) subst = NONE
    | match_data (GN gn,GVar v) subst = NONE
    | match_data (_,_) _ = NONE

  (* FIXME: unification: if x matches y, and y matches x (with the same subst) *) 
  fun unify_data xy subst = if data_eq xy then SOME subst else NONE;

  (* there is not data in a vertex, subst is just the id on the data *)
  fun subst_in_data subst (RT rt) = (RT rt)
   |  subst_in_data subst (GN gn) = (GN gn)
   |  subst_in_data subst (RVar v) = 
        (case StrName.NTab.lookup subst v of
          NONE => (RVar v) (* or should it fail? *)
        | (SOME d) => d)
   |  subst_in_data subst (GVar v) =
        (case StrName.NTab.lookup subst v of
          NONE => (RVar v)
        | (SOME d) => d);
  
  (* pretty printing for subst *)
  fun pretty_subst subst =
    Pretty.block [Pretty.str "vertex subst: ",StrName.NTab.pretty pretty_data subst];
  val print_subst = Pretty.writeln o pretty_subst;  

  val default_data = RVar "v";
  
  structure Sharing = struct type data = data; type subst = subst; end;  
end;

structure Strategy_VertexData : UNIFIABLE_DATA = DB_VertexData;

(*  *)
structure Strategy_VertexComponentData_Param
: ELEMENT_COMPONENT_DATA_PARAM where type data = Strategy_VertexData.data
= struct 
  type data = Strategy_VertexData.data;
  exception unknown_type_exp of string;
  exception unexpected_data_exp;

  structure VD = DB_VertexData

  fun type_of (VD.RT _) = "RT"
    | type_of (VD.GN _) = "GN"
    | type_of (VD.RVar _) = "RVar"
    | type_of (VD.GVar _) = "GVar";

  fun cdata_of d = 
    ComponentData.String (Pretty.string_of (DB_VertexData.pretty_node d));
  
  (* New nodes are by default RTechnNodes *)
  fun default_data "RT" = VD.RT (RTechn.id)
    | default_data "GN" = VD.GN (GNode.default_gnode)
    | default_data "RVar" = VD.RVar "v"
    | default_data "GVar" = VD.GVar "v"
    | default_data s = raise unknown_type_exp s;


  fun update upd (VD.RT rt) = VD.RT rt
    | update upd (VD.GN gn) = VD.GN gn
    | update upd (VD.RVar v)   = VD.RVar v
    | update upd (VD.GVar v)   = VD.GVar v;   

end;



