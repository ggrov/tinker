structure Strategy_GraphParam_DB
= struct
  val pretty_theory_name = Pretty.str "strategy_language";

  (* Vertices with string data and prefix-substring matching *)
  structure VData = Strategy_VertexData;
  structure EData = Strategy_EdgeData;

  (* fixme: change to allow substitution in edge and vertex *)
  type subst = DB_VertexData.subst;
  val empty_subst = DB_VertexData.empty_subst;
  fun compose_subst s1 s2 = DB_VertexData.compose_subst (s1,s2);
  fun try_match_vertex d1 d2 subst = DB_VertexData.match_data (d1,d2) subst;
  fun try_match_edge e1 e2 subst = DB_EdgeData.match_data (e1,e2) subst;
  exception match_exp of unit;
  exception unknown_type_exp of string;
  fun match_vertex d1 d2 u = 
      (case try_match_vertex d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 
  fun match_edge d1 d2 u =
      (case try_match_edge d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 
  fun subst_in_vertex u vd = VData.subst_in_data u vd;
  fun subst_in_edge u ed = EData.subst_in_data u ed;
  
  val pretty_subst = DB_VertexData.pretty_subst;
  val print_subst = Pretty.writeln o pretty_subst; 

  (* 
  type subst = VData.subst * EData.subst;
  val empty_subst = (VData.empty_subst,EData.empty_subst);
  fun compose_subst (vu1,eu1) (vu2,eu2) = 
        (VData.compose_subst (vu1,vu2),EData.compose_subst (eu1,eu2)); 
  fun try_match_vertex d1 d2 (vu,eu) = 
      case VData.match_data (d1,d2) vu of
         NONE => NONE
       | (SOME vu') => SOME (vu',eu);
  fun try_match_edge e1 e2 (vu,eu) =
      case EData.match_data (e1,e2) eu of
         NONE => NONE
       | (SOME eu') => SOME (vu,eu');
  exception match_exp of unit;
  exception unknown_type_exp of string;
  fun match_vertex d1 d2 u = 
      (case try_match_vertex d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 
  fun match_edge d1 d2 u =
      (case try_match_edge d1 d2 u 
         of NONE    => raise match_exp ()
          | SOME u' => u'); 

  fun subst_in_vertex (vu,eu) vd = VData.subst_in_data vu vd;
  fun subst_in_edge (vu,eu) ed = VData.subst_in_data eu ed;

  fun pretty_subst (vu,eu) = 
    Pretty.block [VData.pretty_subst vu,EData.pretty_subst eu];
  val print_subst = Pretty.writeln o pretty_subst;
 *)


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

structure Strategy_GraphParam : GRAPH_PARAM = Strategy_GraphParam_DB;

structure Strategy_OVData = OVertexData(Strategy_GraphParam.VData);
structure Strategy_OGraphParam = OGraphParam(
  structure Param = Strategy_GraphParam 
        and OVData = Strategy_OVData);

structure Strategy_OVertexComponentData_Param = OVertexComponentData_Param(
  structure VertexDataParam = Strategy_VertexComponentData_Param
  structure OVData = Strategy_OVData);

structure Strategy_OVertexComponentData = 
  ElementComponentData(Strategy_OVertexComponentData_Param);

structure Strategy_EdgeComponentData = 
  ElementComponentData(Strategy_EdgeComponentData_Param);
