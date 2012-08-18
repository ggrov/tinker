(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      induct_and_simp.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Reasoning Techniques - stuff working towards proof planning 
    with hi-proofs.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature INDUCT_AND_SIMP (* RIPPLE_RTECHN *)=
sig
  val simp_and_conj 
      :  RTechn.T (* technique to prove conjectures after simp *)
        -> RTechn.T
  val induct_and_simp : RTechn.T
  (* hmm.. should it get a theorem maybe - or need to fix induction rthecn  *)
  (* val induct_and_simp_with_rule :  xstring -> RTechn.T *)
end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor InductAndSimpRTechnFUN(ConjRTechn : CONJ_RTECHN)
        : INDUCT_AND_SIMP
= struct
local open RTechnEnv; in

fun simp_and_conj lemma_techn = 
    ConjRTechn.conj_critic lemma_techn simp_asm_full;

(* must be a better way *)
fun induct_and_simp' () = 
   InductRTechn.induct_rtechn (* hmm is this correct *)
     thenr (* implicit join of input and output *)
   (simp_and_conj (induct_and_simp' ()));

val induct_and_simp = induct_and_simp' (); 

(*
fun induct_and_simp_with_rule rule = 
           (InductRTechn.induction_on_goal_with 
           
              (ProofContext.get_thm (RState.get_ctxt rst) rule)
              (simp_and_conj induct_and_simp)
              (simp_and_conj induct_and_simp) )
      rst; 
*)
end; (* RTechnEnv local *) 
end; (* struct *)
