structure RT_GParam : GRAPH_PARAM  = 
struct

  structure VData = RTData;
  structure EData = EData;

  type subst = VData.subst;
  
  (* structure for internal names; we use string names, but this is a dummy, we don't actually have any internal names, but we have to provide this *)
  structure IName = SStrName;

  val empty_subst = VData.empty_subst;
  fun compose_subst s1 s2 = VData.compose_subst(s1,s2);

  fun try_match_vertex d1 d2 s = VData.match_data (d1,d2) s;
  fun try_match_edge e1 e2 s = (* maybe it should always match?? *)
    if not(EData.data_ord (e1,e2) = GREATER)
     then SOME s
     else NONE;

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

  fun subst_in_vertex _ vd =  vd;
  fun subst_in_edge _ ed = ed;

  fun pretty_subst s = 
    Pretty.str "subst";
  
  val pretty_theory_name = Pretty.str "IsaPlanner Reasoning Techniques";

  val print_subst = Pretty.writeln o pretty_subst;

  (* FIXME *)
  type T = unit; 

  (* empty name-dependency information *)
  val empty = ();

  fun add_vertex vd vn vdep = vdep;
  fun add_edge ed en vdep = vdep;

  fun delete_vertex vn vdep = vdep;
  fun delete_edge en vdep = vdep;

  fun replace_vertex vd vn vdep = vdep; 
  fun replace_edge ed en vdep = vdep;

  fun of_vertex vd vn = empty;
  fun of_edge en ed = empty;
 
  fun rename_vname vn1 vn2 vdep = vdep;
  fun rename_ename en1 en2 vdep = vdep;
  fun replace_vertex vdata vname vdep = vdep;
  fun replace_edge edata ename vdep = vdep;

  (* RENAMING *)
  (* [dummy] Renaming internal names within vertex data *)
  structure VDataCRnmX : COMPOUND_RENAMING
  = EmptyCompoundRenamingFun(structure Nm = X type obj = VData.data);
  (* [dummy] Rename internal names within edge data *)
  structure EDataCRnmX : COMPOUND_RENAMING
  = EmptyCompoundRenamingFun(structure Nm = X type obj = EData.data);
  (* [dummy] Rename vertex-names in the dependency data *)
  structure CRnmV : COMPOUND_RENAMING
  = EmptyCompoundRenamingFun(structure Nm = V type obj = T);
  (* [dummy] Rename edge-names in the dependency data *)
  structure CRnmE : COMPOUND_RENAMING
  = EmptyCompoundRenamingFun(structure Nm = E type obj = T);
  (* [dummy] Rename internal names in T *)
  structure CRnmX : COMPOUND_RENAMING
  = EmptyCompoundRenamingFun(structure Nm = X type obj = T);


  structure Sharing = 
  struct 
    structure VData = VData.Sharing;
    structure EData = EData.Sharing;
    type T = T;
    type inames_renaming = CRnmX.renaming; (* = IName.Rnm.renaming *)
    type subst = subst ;
  end;

end; (* functor Graph_Param *)

structure OVData = OVertexData(RTData);

structure OParam = OGraphParam(
    structure Param = RT_GParam
    structure OVData = OVData);

structure OVComponentData_Param = OVertexComponentData_Param(
  structure VertexDataParam = VComponentData_Param
  structure OVData = OVData);

structure OVComponentData = ElementComponentData(OVComponentData_Param);




