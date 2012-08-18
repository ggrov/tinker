(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      ROOT.ML
    Author:     Dominic Mulligan, University of Edinburgh
                dpm_edinburgh@yahoo.com
    Created:    Sept 2007
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Brings all relational rippling files in.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

set quick_and_dirty;
Trm.drop_var_args_flag := false;

use_thy "test/relations/Relations";

(* if not (!flag) then
  let
    val _ = (use_thy "~/IsaPlanner/src/dbg/inductive-sets/Relations2")
  in
    ()
  end
else
  (); *)


fun myuse s = use ("rtechn/rrippling/" ^ s);

myuse "rr_table.ML"; (* Contains the definition of the rtable. Solves order-of-inclusion problem. *)
myuse "rr_linkinfo.ML"; (* Perhaps move these functions into rr_cinfo? May camyuse problems with order-of-inclusion! *)
myuse "rr_embeddinglib.ML";
myuse "rr_aterms.ML";
myuse "rr_trmutil.ML"; (* Functions that don't really belong anywhere else. Debug output for terms and eterms, etc. *)
myuse "rr_measure.ML"; (* Relational measure: (functional wave-fronts * relational wave-fronts). *)
myuse "rr_measure_tabs.ML"; (* The tables for type and positions of wave-fronts. *)
myuse "rr_skel.ML";
myuse "rr_cinfo.ML";
myuse "rr_proof_new.ML"; (* Our test proof.  This one corresponds to the Isabelle proof.  rr_proof.ML is the old proof
                            (possibly no longer works, due to bug fix in IsaPlanner/Isabelle). *)
myuse "rr_techn.ML"; (* Relational rippling reasoning technique implementation proper. *)

(* Various structures and functors for rippling: *)

structure RRippleMeasure = RRippleMeasureFUN(val name = "Hybrid ripple measure, version 1.0."
                                             val atermifier = RRipplingATerms.r_aterms_of_eterm
                                             val measuref = RRipplingATerms.relational_measure_of);

structure RRippleSkel = RRippleSkelOneMeasureFUN (RRippleMeasure);

structure RRippleCInfo = RRippleCInfoFUN (RRippleSkel);

structure RRippleTechn = RRippleTechnFUN (structure RRippleCInfo = RRippleCInfo);

(* NOTE: make sure ipp line in above file is commented out for auto-testing using quicktest.ML *)
