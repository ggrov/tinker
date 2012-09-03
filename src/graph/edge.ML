structure DB_EdgeData
= struct

  datatype data =  W of Wire.T
                 | EVar of string (* variable of goalnode *)

  (* ordering is used for building tables, sorting, etc *)
  fun data_ord (EVar v1,EVar v2) = String.compare (v1,v2)
    | data_ord (EVar v1,_) = LESS
    | data_ord (W _,EVar _) = GREATER
    | data_ord (W w1,W w2) = Wire.ord (w1,w2)

  (* equality check (should agree with order):
     data_eq(x,y) <=> data_ord (x,y) = EQUAL *)
  fun data_eq (xy as (x, y)) = 
      (case data_ord xy of EQUAL => true
          | _ => false);
 
  fun pretty_data (W w) = Wire.pretty w
   |  pretty_data (EVar v) = Pretty.str ("?" ^ v)

  val print_data = Pretty.writeln o pretty_data;
  
  fun pretty_node (W w) = Wire.pretty w
   |  pretty_node (EVar v) = Pretty.str ("?" ^ v)


  (* FIXME: allow for substitution *)
  type subst = DB_VertexData.subst;
  val empty_subst = DB_VertexData.empty_subst;
  val compose_subst = DB_VertexData.compose_subst
  fun match_data (EVar v1,e) subst = NONE
   |  match_data (W w1,W w2) subst = if Wire.eq(w1,w2) then SOME subst else NONE
   |  match_data (W w,EVar v) subst = NONE
  fun unify_data xy subst = if data_eq xy then SOME subst else NONE;
  fun subst_in_data subst (W w) = (W w)
   |  subst_in_data subst (EVar v) =  (EVar v);
  
  val pretty_subst = DB_VertexData.pretty_subst;
  val print_subst = Pretty.writeln o pretty_subst; 

(* TO DO: Fix sub to allow substitution in both Vertex and Edge *)
(*
  type subst = data StrName.NTab.T;

  val empty_subst = StrName.NTab.empty;
  
  fun compose_subst (u1,u2) = StrName.NTab.merge_joint data_eq u1 u2;

  fun match_data (EVar v1,e) subst =
      (case StrName.NTab.lookup subst v1 of
            NONE => SOME (StrName.NTab.ins (v1,e) subst)
          | SOME e2 => if data_eq(e,e2) then SOME subst else NONE)
   |  match_data (W w1,W w2) subst = if Wire.eq(w1,w2) then SOME subst else NONE
   |  match_data (W w,EVar v) subst = NONE

  fun unify_data xy subst = if data_eq xy then SOME subst else NONE;


  fun subst_in_data subst (W w) = (W w)
   |  subst_in_data subst (EVar v) = 
        (case StrName.NTab.lookup subst v of
          NONE => (EVar v)
        | (SOME d) => d);
  

  fun pretty_subst subst =
    Pretty.block [Pretty.str "edge subst: ",StrName.NTab.pretty pretty_data subst];
  val print_subst = Pretty.writeln o pretty_subst; 
*)
  val default_data = (W Wire.default_wire);
  
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

  structure ED = DB_EdgeData

  fun type_of (ED.W _) = "W"
    | type_of (ED.EVar _) = "EVar";

  fun cdata_of d = 
    ComponentData.String (Pretty.string_of (DB_EdgeData.pretty_node d));
  
  (* New nodes are by default RTechnNodes *)
  fun default_data "W" = ED.W (Wire.default_wire)
    | default_data "EVar" = ED.EVar "v"
    | default_data s = raise unknown_type_exp s;


  fun update upd (ED.W w) = ED.W w
    | update upd (ED.EVar v)   = ED.EVar v;   

end;
