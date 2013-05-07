signature GT_MATCH =
sig

  exception lmatch_exp of string * L.name (* links *)
  exception fmatch_exp of string * F.name (* classes *)

  val fmatch : F.name -> GTData.data -> Thm.thm -> bool
  val lmatch : L.name -> GTData.data -> Thm.thm -> Thm.thm -> bool
 
end (* signature *)

structure GTMatch : GT_MATCH =
struct

  exception lmatch_exp of string * L.name 
  exception fmatch_exp of string * F.name

  fun fmatch fname data thm = raise fmatch_exp ("class feature not supported",fname);
  fun lmatch lname data thm1 thm2 = raise lmatch_exp ("link not supported",lname);
end (* structure *)


