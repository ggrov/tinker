(* 
val _ = System.use "test/trm_renaming.ML";
val _ = System.use "test/prf_resol.ML";
(* use "dbg/inductive-sets/prf-isets.ML"; *)
val _ = System.use "test/prf_subst.ML";
val _ = System.use "test/prf_fwdmeth.ML";
val _ = System.use "test/prf_bckmeth.ML";
val _ = System.use "test/relations/rr_proof.ML";
val _ = System.use "test/embed.ML";
val _ = System.use "test/rippling_in.ML";
val _ = System.use "test/rippling_core.ML";
val _ = writeln "All tests completed.";
(* System.use "test/relations/relational_full_test.ML"; *)
*)

use_thy "src/test/tests";
