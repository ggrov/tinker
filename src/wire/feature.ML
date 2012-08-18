signature BASIC_FEATURE =
sig
  type feature
  val match : feature -> PNode.gnode -> bool
  val is_subfeature : Proof.context -> feature -> feature -> bool
end (* sig *)

(* for this to work we need to put values in the context!! *)
structure Feature =
struct

  datatype fdata = Terms of term list
                 | Strings of string list
                 | StrCount of int StrTable.table
                 | Ref of string (* to put in context for unknown data : not sure how it'll work*)
                 | NoData

  datatype feature = 
    Feature of { 
       id : string, (* should be unique for type: maybe keep track of this in context? *)
       ftyp : string,
       fdata : fdata,
       is_subfeature : theory -> feature -> bool,
       (* subsumes : theory -> feature -> bool, *)
       matches : PNode.gnode -> PNode.factname -> bool}

  fun set_id v (Feature rep) = Feature {
     id = v, ftyp = #ftyp rep, fdata = #fdata rep,
     is_subfeature = #is_subfeature rep,
     (* subsumes = #subsumes rep, *)
     matches  = #matches rep };

  fun get_id (Feature rep) = #id rep;
  fun get_ftyp (Feature rep) = #ftyp rep;
  fun get_fdata (Feature rep) = #fdata rep;
  fun get_matches (Feature rep) = #matches rep;
  fun get_is_subfeature (Feature rep) = #is_subfeature rep;
  (* fun get_subsumes (Feature rep) = #subsumes rep; *)

  fun match f rst g = (get_matches f) rst g;
  fun subfeature_of th f1 f2 = (get_is_subfeature f1) th f2;
  (* fun subsumes f1 f2 = (get_subsumes f1) f2; *)

  val default_feature = Feature {
     id = "dummy",
     ftyp = "dummy",
     fdata = NoData,
     matches = K (K false),
     is_subfeature = K (K false)
     (* subsumes = (K false) *)
   }

  (* for name set *)
  type name = feature;
  fun suc f = set_id (get_id f ^ "0") f;
  fun pred f = NONE;
  fun ord (f1,f2) = 
    case String.compare (get_ftyp f1,get_ftyp f2) of
     EQUAL => String.compare (get_id f1,get_id f2)
     | v => v;
  fun eq (f1,f2) = (ord(f1,f2) = EQUAL);

  (* can make this a bit better, depending on feature type etc *)
  fun pretty f =  Pretty.block [Pretty.str (get_ftyp f),Pretty.str ": ", Pretty.str (get_id f)];

end (* struct *)

structure F = NameFun(structure Namer = Feature val default_name = Feature.default_feature);


