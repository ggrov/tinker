

(* structure RTName : SSTR_NAME = struct open SStrName; val default_name = mk "RTa"; end; *)
structure RTechnKey : NAME where type name = string = StrName;

(********************************************)
(* VERTEX *)
(********************************************)
signature RT_UNIFIABLE_DATA =    
sig

  datatype node =  RTechnNode of RTechnKey.name 
                 | GoalNode of  StrIntName.name  (* goal/wire type *)
                              * StrIntName.NSet.T; (* goal names of this type *)
                  (* was GoalNode.T  *)

  exception node_exp of string*node
  
  include UNIFIABLE_DATA
    sharing type node = data

  val is_rtechn : data -> bool
  val is_goalnode : data -> bool
  val empty_goalnode : StrIntName.name -> data
  val is_empty_goalnode : data -> bool (* raises node_ex *)

  val data_to_rtechn : data -> RTechnKey.name (* raises node_ex *)
  val data_to_goalnode : data -> StrIntName.name * StrIntName.NSet.T (* raises node_ex *)

  val update_goalnode : 
     (StrIntName.name * StrIntName.NSet.T -> StrIntName.name * StrIntName.NSet.T) 
      -> data 
      -> data (* raises node_ex *)
  val add_to_goalnode : StrIntName.NSet.T -> data -> data (* raises node_ex *)

end (* RT_UNIFIABLE_DATA sig *)

structure RTData : RT_UNIFIABLE_DATA  = 
struct

  datatype node =  RTechnNode of RTechnKey.name 
                 | GoalNode of  StrIntName.name  (* goal/wire type *)
                              * StrIntName.NSet.T; (* goal names of this type *)

  type data = node;

  exception node_exp of string*node

  fun is_rtechn (RTechnNode _) = true
   |  is_rtechn   _        = false;

  fun is_goalnode (GoalNode _) = true
   |  is_goalnode   _      = false;

  fun empty_goalnode w = GoalNode (w,StrIntName.NSet.empty);

  fun is_empty_goalnode (GoalNode (_,gs)) = StrIntName.NSet.is_empty gs
   |  is_empty_goalnode rt  = raise node_exp("not a goal node",rt);

  fun data_to_goalnode (GoalNode l) = l
   |  data_to_goalnode  rt  = raise node_exp("not a goal node",rt);

  fun data_to_rtechn (RTechnNode rt) = rt
   |  data_to_rtechn rt  = raise node_exp("not a reasoning technique",rt);

  fun update_goalnode f (GoalNode l) = GoalNode (f l)
   |  update_goalnode _ rt = raise node_exp("not a link",rt);

  fun add_to_goalnode gs' (GoalNode (w,gs)) = GoalNode (w,StrIntName.NSet.union_merge gs gs')
   |  add_to_goalnode _ rt  = raise node_exp("cannot add to goalnode - element not a goalnode",rt);;

 fun pretty_data (RTechnNode rt) = Pretty.str rt
  |  pretty_data (GoalNode (w,gs)) =
      Pretty.block
        [Pretty.str "wire: ",
         StrIntName.pretty_name w,
         Pretty.str "\n goals: ",
         StrIntName.NSet.pretty_full gs];
       
 val print_data = Pretty.writeln o pretty_data;

 fun data_ord (RTechnNode _,GoalNode _) = GREATER 
  |  data_ord (GoalNode _,RTechnNode _) = LESS
  |  data_ord (RTechnNode r1,RTechnNode r2) = RTechnKey.name_ord(r1,r2) 
  |  data_ord (GoalNode (w1,gs1),GoalNode (w2,gs2)) =
      case StrIntName.name_ord (w1,w2) of
         EQUAL =>  StrIntName.NSet.ord(gs1,gs2)
        | x => x;

 fun data_eq (x,y) = (data_ord(x,y) = EQUAL)
(*
 fun data_eq (RTechnNode _,GoalNode _) = false 
  |  data_eq (GoalNode _,RTechnNode _) = false
  |  data_eq (RTechnNode r1,RTechnNode r2) = RTechnKey.name_eq(r1,r2) 
  |  data_eq (GoalNode v1,GoalNode v2) = GoalNode.GInfo.eq (v1,v2);
*)

 val default_data = RTechnNode "id";

 type subst = unit 
 val empty_subst = ();
 val compose_subst = K ();
 val pretty_subst = K (Pretty.str "vertex subst: ()");
 val print_subst = Pretty.writeln o pretty_subst;

 fun match_data (d1,d2) s = 
    if data_eq(d1,d2) then SOME s else NONE;

 fun unify_data xy subst = if data_eq xy then SOME subst else NONE;

 fun subst_in_data _ d = d;

 structure Sharing = struct type data = data; type subst = subst end;

end; (* struct VData *)

structure VComponentData_Param : ELEMENT_COMPONENT_DATA_PARAM where type data = RTData.data =
struct
    type data = RTData.data;
    exception unknown_type_exp of string;

    fun type_of (RTData.RTechnNode _) = "RT"
     |  type_of (RTData.GoalNode _) = "Gs"

    fun cdata_of (RTData.RTechnNode r) = ComponentData.String r
     |  cdata_of (RTData.GoalNode wgs) = 
            ComponentData.String (Pretty.string_of (RTData.pretty_data (RTData.GoalNode wgs)));

    fun default_data "RT" = RTData.RTechnNode "id"
     | default_data "Gs" = RTData.GoalNode (("goal",0),StrIntName.NSet.empty)
     | default_data n = raise unknown_type_exp n;

    fun update _ = I;
end; (* struct VComponentData_Param *)
















