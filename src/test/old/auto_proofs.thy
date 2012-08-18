theory auto_proofs
imports Main IsaP
begin
-- "This line sets the tests to use the simple theory of Peano
    arithmetic without any lemmas proved."

use_thy "src/examples/N"
ML {* val thry = theory "N"; *}

-- "ML function to automatically prove goals in Peano arithematic using
    with Rippling and Lemma Calculation "
ML {*
fun a_rippling goals = 
  PPInterface.init_rst_of_strings thry goals
   |> RState.set_rtechn (SOME (RTechnEnv.map_then RippleLemCalc.induct_ripple_lemcalc))
   |> GSearch.depth_fs (fn rst => is_none (RState.get_rtechn rst)) RState.unfold
   |> Seq.pull;
*}

-- "Regression tests to make sure we can still prove things we should be able to"
ML {* val SOME (myrst, more) = a_rippling ["a + b = b + (a::N)"]; *}



end;