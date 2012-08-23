structure Feature =
struct

  datatype fdata = Terms of term list
                 | Strings of StrName.NSet.T
                 | StrCount of int StrTable.table
                 | Count of int
                 | Ref of string (* to put in context for unknown data : not sure how it'll work*)
                 | NoData

  datatype feature = 
    Feature of { 
       id : string, (* should be unique for type: maybe keep track of this in context? *)
       ftyp : string,
       fdata : fdata,
       sub : theory -> feature -> bool,
       match : PNode.gnode -> PNode.factname -> bool}

  fun update_id f (Feature rep) = Feature {
     id = f (#id rep), ftyp = #ftyp rep, fdata = #fdata rep,
     sub = #sub rep,
     match  = #match rep };
  fun update_ftyp f (Feature rep) = Feature {
     id = #id rep, ftyp = f (#ftyp rep), fdata = #fdata rep,
     sub = #sub rep,
     match  = #match rep };
  fun update_fdata f (Feature rep) = Feature {
     id = #id rep, ftyp = #ftyp rep, fdata = f (#fdata rep),
     sub = #sub rep,
     match  = #match rep };
  fun update_sub f (Feature rep) = Feature {
     id = #id rep, ftyp = #ftyp rep, fdata = #fdata rep,
     sub = f (#sub rep),
     match  = #match rep };
  fun update_match f (Feature rep) = Feature {
     id = #id rep, ftyp = #ftyp rep, fdata = #fdata rep,
     sub = #sub rep,
     match  = f (#match rep)};

  val set_id = update_id o K;
  val set_ftyp = update_ftyp o K;
  val set_fdata = update_fdata o K;
  val set_sub = update_sub o K;
  val set_match = update_match o K;

  fun get_id (Feature rep) = #id rep;
  fun get_ftyp (Feature rep) = #ftyp rep;
  fun get_fdata (Feature rep) = #fdata rep;
  fun get_match (Feature rep) = #match rep;
  fun get_sub (Feature rep) = #sub rep;

  fun match f rst g = (get_match f) rst g;
  fun subfeature_of th f1 f2 = (get_sub f1) th f2;

  val default_feature = Feature {
     id = "dummy",
     ftyp = "dummy",
     fdata = NoData,
     match = K (K false),
     sub = K (K false)
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


