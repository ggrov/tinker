signature PS_GRAPH_PARAM =
sig
  include GRAPH_PARAM
  (* todo : add sharing *)
  structure GraphSubstData : GRAPH_SUBST_DATA
  structure PSEdgeData : PS_EDGE
  structure PSVertexData : PS_VERTEX
  
end

functor PSGraphParamFun(GoalTyp : GOAL_TYP) : PS_GRAPH_PARAM
= struct

  structure GraphSubstData = GraphSubstDataFun(GoalTyp);
  structure PSEdgeData = PSEdgeDataFun(GraphSubstData);
  structure PSVertexData = PSVertexDataFun(GraphSubstData);

  val pretty_theory_name = Pretty.str "strategy_language";

  (* Vertices with string data and prefix-substring matching *)
  structure EData = PSEdgeData;
  structure VData = PSVertexData;

  (* fixme: change to allow substitution in edge and vertex *)
  type subst = GraphSubstData.subst;
  val empty_subst = GraphSubstData.empty_subst;
  fun compose_subst s1 s2 = GraphSubstData.compose_subst (s1,s2);
  fun try_match_vertex d1 d2 subst = PSVertexData.match_data (d1,d2) subst;
  fun try_match_edge e1 e2 subst = PSEdgeData.match_data (e1,e2) subst;
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
  
  val pretty_subst = PSVertexData.pretty_subst;
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

(* structure PS_GraphParam : GRAPH_PARAM = PS_GraphParam_DB; *)


