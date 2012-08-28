(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Substring graph matching: vertices have string data and matching is by
    substring. *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure RTechn_GraphParam
: GRAPH_PARAM
= struct
  val pretty_theory_name = Pretty.str "strategy_language";

  (* Vertices with string data and prefix-substring matching *)
  structure VData = RTechn_VertexData;
  structure EData = StringData;

  (* substitutions for variables in vertex/edge data 
     (usually, we only have data on vertices) *)
  type subst = VData.subst * EData.subst;

  val empty_subst = (VData.empty_subst,EData.empty_subst);
  fun compose_subst (vu1,eu1) (vu2,eu2) = 
        (VData.compose_subst (vu1,vu2),EData.compose_subst (eu1,eu2)); 
  fun try_match_vertex d1 d2 (vu,eu) = 
      case VData.match_data (d1,d2) vu of
         NONE => NONE
       | (SOME vu') => SOME (vu',eu);
  fun try_match_edge e1 e2 (vu,eu) =
      case EData.match_data (d1,d2) eu of
         NONE => NONE
       | (SOME eu') => SOME (vu,eu');

  (* IMPROVE: what data do we want here? should it be add_exp *)
  exception match_exp of unit;
  exception unknown_type_exp of string;
  (* raises match_exp *)
  fun match_vertex d1 d2 u = 
      (case try_match_vertex d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 
  fun match_edge d1 d2 u =
      (case try_match_edge d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 

  fun subst_in_vertex u vd = vd;
  fun subst_in_edge u ed = ed;

  val pretty_subst = VData.pretty_subst;
  val print_subst = Pretty.writeln o pretty_subst;

  structure NoInternalData = NoInternalDataGraphParam(
    type vdata = VData.data type edata = EData.data);
  open NoInternalData;
  
  (* convenient syntax for sharing types *)
  structure Sharing = 
  struct 
    structure VData = VData.Sharing;
    structure EData = EData.Sharing;
    type T = T;
    type subst = subst;
  end;
end;


structure RTechn_OVData = OVertexData(RTechn_GraphParam.VData);
structure RTechn_OGraphParam = OGraphParam(
  structure Param = RTechn_GraphParam 
        and OVData = RTechn_OVData);

structure RTechn_OVertexComponentData_Param = OVertexComponentData_Param(
  structure VertexDataParam = RTechn_VertexComponentData_Param
  structure OVData = RTechn_OVData);

structure RTechn_OVertexComponentData = 
  ElementComponentData(RTechn_OVertexComponentData_Param);

structure RTechn_EdgeComponentData = 
  ElementComponentData(Str_ComponentData_Param);
