signature RIPPLE_LEMCALC =
sig
 structure BasicRipple : BASIC_RIPPLE

 val simp_or_calc : RTechnComb.graph
 val fert_calc : RTechnComb.graph
 val endr_lemcalc : RTechnComb.graph
 val ripple_stepcase_lemcalc : RTechnComb.graph
 val induct_ripple_lemcalc : RTechnComb.graph

(* val induct_ripple_lemcalc : PPlan.gname -> RTechn.T *) (* graph *)
(* val induct_ripple_lemcalc_with_rule : PPlan.gname ->  xstring -> RTechn.T (* graph *) *)

end;

(* structure RippleLemCalc *)
functor RippleLemCalcFUN (structure BasicRipple : BASIC_RIPPLE) 
(* : RIPPLE_LEMCALC *)
= struct

 structure BasicRipple = BasicRipple;
 structure RippleCInfo = BasicRipple.RippleCInfo;

 local 
   open RTechnEnv; open RTechn; open RTechnComb;
 in  

 infix 5 th_or;
 infix 6 th_compose;
 infix 6 th_tensor;

 (* NOTE: only works for depth first *)
 (* FIXME: what about solved by rippling?? *)


 (* ATOMIC RTECHN *)
 val id_weak_fert = id_of BasicRipple.not_fully_rippled_wire;

 val simp_base_noout_rtechn = BasicRipple.simp_base_rtechn
                            |> RTechn.set_outputs RState.Wire.NSet.empty;

 (* type: base -> base *)
 val try_simplify_basecase = 
  (lift_rtechn_and_try_bind BasicRipple.id_base)
    th_compose
   (* replace by try_or_else *)
  ((lift_rtechn_and_try_bind simp_base_noout_rtechn) th_or (lift_rtechn_and_try_bind BasicRipple.id_base));

 val weak_fert = 
    (BasicRipple.weak_fert 
       th_compose
    (lift_rtechn_and_try_bind simp_base_noout_rtechn)); 
 
 val try_weak_fert = 
 (* replace by try_or_else *)
   weak_fert
    th_or
  (lift_rtechn_and_try_bind id_weak_fert);

 val end_rippling =
  (lift_rtechn_and_try_bind BasicRipple.fert_split_rtechn)
    th_compose
  ((lift_rtechn_and_try_bind BasicRipple.strong_fert_rtechn) 
     th_tensor 
   try_weak_fert);

 val ripple_stepcase =
   (lift_rtechn_and_try_bind BasicRipple.start_rippling)
     th_compose
   BasicRipple.ripple_step
     th_compose
   end_rippling;

 val induct_and_ripple =
  (lift_rtechn_and_try_bind InductRTechn.induct_rtechn)
   th_compose (* or then *)
  ((try_simplify_basecase
      th_tensor
    ripple_stepcase));

 (* fixme: need to connect the output back into the input again... *)
 val induct_and_ripple_lemcalc =
    induct_and_ripple
      th_compose
    BasicConjRTechn.conj; 

end (* local *)

end; (* struct *)
