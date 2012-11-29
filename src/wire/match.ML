structure WMatch =
struct

(* move elsewhere *)
  exception feature_exp of Feature.T * string
  exception goal_exp of GNode.T * string
 
  fun feature_match fmap ctxt thm feature =
    case StrName.NTab.lookup fmap (Feature.get_fdata feature) of
      NONE => raise feature_exp (feature,"feature not in map")
    | (SOME fm) => fm feature ctxt thm;

  fun bwire_match fmap ctxt bw thm =
    F.NSet.forall (feature_match fmap ctxt thm) (BWire.get_pos bw)
    andalso 
    not (F.NSet.exists (feature_match fmap ctxt thm) (BWire.get_neg bw))
;

  (* FIXME: add support for facts and props *)
  fun wire_match fmap ctxt w goalmap gnode =
    (* match goal *)
    (case StrName.NTab.lookup goalmap (GNode.get_goal gnode) of
       NONE => raise goal_exp (gnode,"goal not in goalmap")
     | SOME g => bwire_match fmap ctxt (Wire.get_goal w) g);


end


