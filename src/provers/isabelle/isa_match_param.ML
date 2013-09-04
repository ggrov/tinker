
structure IsaMatchParam  =
struct
  structure GoalTypData : GOALTYP_DATA = GoalTypData
  structure Atomic : ATOMIC = BIsaAtomic

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

  val add_class_feature = CF_Data.map o F.NTab.ins;
  val get_class_features = CF_Data.get;
  val get_class_feature = F.NTab.lookup o get_class_features;

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

  (* FIXME: why is the Object required as this level?
      - all stuff should have been instantiated by now! *)
  (* F.name -> Atomic.context -> Atomic.Object -> GoalTypData.data list -> bool *)

  fun class_data_match fname ctxt obj data = 
    case get_class_feature (Proof_Context.theory_of ctxt) fname of
       NONE => false
     | SOME f => f ctxt obj data;

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

