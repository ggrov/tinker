theory IsapLib                        
imports    
 (* change to import isaplib/ML-shrubbery *)
 "~~/contrib/isaplib/isabelle/isaplib/isaplib"   
uses

(* *** Isabelle extra *** *)
(* replacement for changed Isabelle version *)
(* "../libs/polym_table.ML" *)
"../libs/safe_object.ML" (* FIXME: remove and replace with polym table stuff *)
(* term debugging tools such as writeterm... *)
(* "../libs/term/termdbg.ML" *)


(* generic measure traces *)
"../libs/measure_traces.ML"

(* *** proof *** *)

(* abstract notion of terms *)
"../libs/term/paramtab.ML" (* named, ordered, counted, parameter tables *)
"../libs/term/trm.ML" (* genericish terms *)
"../libs/term/isa_trm.ML" (* Isabelle instantiation of generic-ish terms  *)
"../libs/term/fterm.ML" (* Flattened Isabelle terms  *)
"../libs/term/fzipper.ML" (* Zipper for Flattened Isabelle terms  *)
(* "../gproof/prf/trm_rename.ML" *) (* renaming of terms *) 

(* abstract notion of instantiation and variable dependencies *)
"../libs/term/instenv.ML"
"../libs/term/lifting.ML"

(* copies of unification from Isabelle that track new generated
variable names, and goal names from which flex-flexes have come from *)
"../libs/term/unif/norm.ML"
"../libs/term/unif/typ_unify.ML"
"../libs/term/unif/pattern.ML"
"../libs/term/unif/unify.ML"

(* declarative tactics which can record instantiations *)
"../libs/term/flexes.ML" (* for doing stuff with flex-flex pairs *)

(* Term Related Libraries *)
"../libs/term/prologify_terms.ML"
"../libs/term/term_const_lib.ML"
"../libs/term/typed_terms_lib.ML"
"../libs/term/subsumption_net.ML"
(* "libs/term_tree_handler_lib.ML" *)

(* embeddings *)
"../libs/term/embedding/eterm.ML"
"../libs/term/embedding/ectxt.ML"
"../libs/term/embedding/embed.ML"

(* generalisation *)
"../libs/term/generalise_lib.ML"

(* make minimal names for frees vars etc *)
"../libs/term/minimal_rename_lib.ML"

(* FROM HOL_ISAP *)
(* recursive path orders *)
  "../libs/term/termination.ML"

(* AC-matching *)
  "../libs/term/ac_eq.ML"

(* *)
"../pplan/cx.ML" (* abstract context *)

(* wires *)
"../wire/basic_wire.ML"   
"../wire/goal_node.ML"   
"../wire/full_wire.ML"   

begin

end;
