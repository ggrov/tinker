typ_unify.ML was written by hand, after looking at Type.unify in
type.ML. It uses instantiation env and a set of new vars to do the
type unification.

These files are essentially copies from Isabelle which have been
adapted. this is what I did/do when Isabelle is updated:

1. copy over my files with the new Isabelle ones. 

2. Replace:
 "Envir." with "MyEnvir."
 "Pattern." with "MyPattern."
 "Unify." with "MyUnify."
as well as update the signature names. 

3. Use an old copy of my code to help replace the few modified
function calls. 

the commented lines marked with "(** **)"  tell me which bits I modified. 

In Summary this involves: 

For Envir I need to modify the datatype, add in my name tables, and
propegate their use throughout. 

For Pattern I need to replace a unify_types with my version -
separately copied from Sign.unify_types to MyTypeUnify.unify_types.

For Unify I throw away the pattern matching stuff. Also add code to
unify types (then re-inst term args) before trying to unify terms.

NOTE: using InstEnv instead of Isabelle environments has a strange
painful side effect: it means that we force the instantiations to be
well-typed where Isabelle does not. This means that where, in some
cases Isabelle finds infinite number of unifiers, we get a type
exception that then becomes a hounifiers_exp.
