
structure IsaMatchParam  =
struct
  structure GoalTypData : GOALTYP_DATA = GoalTypData
  structure Atomic : ATOMIC = IsaAtomic

  exception class_match_exp of string * C.name
  exception link_match_exp of string * L.name


 (* Class Feature in Isabelle context *)
 structure GTD = GoalTyp.Class.GoalTypData;
 structure CF_Data = Theory_Data(
  type T =  (Proof.context 
            -> Atomic.Object  (* or term? *)
            -> GTD.data list (* fixme: not sure current class is correct here*)
            -> bool) F.NTab.T
   val empty = F.NTab.empty
   val extend = I
   val merge = fst);

  (* for this goal assumptions, facts and goal are all thms *)
  fun prj_obj (Atomic.Fact thm) = thm
   |  prj_obj (Atomic.Assm thm) = thm
   |  prj_obj (Atomic.Concl thm) = thm;

  (* to do - should it still be prop_of?  *)
  fun mk_term_match f ctxt obj = f ctxt (Thm.prop_of (prj_obj obj)); 
  fun mk_thm_match f ctxt obj = f ctxt (prj_obj obj);

  val add_class_object_feature = CF_Data.map o F.NTab.ins;
  fun add_class_thm_feature (name,f) = 
    add_class_object_feature (name,mk_thm_match f);
  fun add_class_term_feature (name,f) = 
    add_class_object_feature (name,mk_thm_match f);

  val get_class_features = CF_Data.get;
  val get_class_feature = F.NTab.lookup o get_class_features;

  val print_class_features = 
   get_class_features
   #> F.NTab.keys 
   #> map F.dest
   #> (fn xs => "Class Features: " :: xs)
   #> map Pretty.str
   #> Pretty.separate "\n  "
   #> Pretty.block
   #> Pretty.writeln; 

 structure LF_Data = Theory_Data(
  type T =  (Proof.context 
            -> (Atomic.Object * Atomic.Object) 
            -> GTD.data list (* fixme: not sure current class is correct here*)
            -> bool) F.NTab.T
   val empty = F.NTab.empty
   val extend = I
   val merge = fst);

  val add_link_feature = LF_Data.map o F.NTab.ins;
  val get_link_features = LF_Data.get;
  val get_link_feature = F.NTab.lookup o get_link_features;

  fun class_data_match' fname ctxt obj data = 
    case get_class_feature (Proof_Context.theory_of ctxt) fname of
       NONE => false
     | SOME f => f ctxt obj data;
  
  fun class_data_match fname ctxt obj data =  
  let val tmp =  (class_data_match' fname ctxt obj data)  in
  if tmp then (writeln ((F.string_of_name fname ) ^" - yes!") ; tmp) 
  else (writeln ((F.string_of_name fname ) ^" -  no!");tmp)
  end

  fun link_data_match fname ctxt (obj1, obj2) data = 
    case get_link_feature (Proof_Context.theory_of ctxt) fname of
       NONE => false
     | SOME f => f ctxt (obj1, obj2) data;



  structure Sharing : MATCH_PARAM_SHARING = 
    struct
      structure GoalTypData = GoalTypData.Sharing
      structure Atomic = Atomic.Sharing
    end
end;

(* to avoid structure *)

 val add_cfeature = IsaMatchParam.add_class_thm_feature;
 val print_class_features = IsaMatchParam.print_class_features;

