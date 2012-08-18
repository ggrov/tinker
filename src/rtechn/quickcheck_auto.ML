(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/quickcheck_auto.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    created:    30 Jun 2005
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    quick check followed by auto

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

signature QCHECK_AUTO_RTECHN =
sig
    val quickcheck' : RState.Wire.name -> RState.Wire.name -> RState.Wire.name -> RTechn.T
    val quickcheck : RTechn.T
    val quickcheck_and_auto : theory -> RTechnComb.graph * theory

    val cc_ok_wire : RState.Wire.name;
    val cc_fail_wire : RState.Wire.name;
end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure QCheckAutoRTechn : QCHECK_AUTO_RTECHN
= struct 


local open RTechn; open RTechnEnv; open RTechnComb in

fun quickcheck' inp_wire ok_wire fail_wire =
  let fun do_quickcheck rst = 
            Goaln.NSet.fold
              (fn g => fn (good,bad) => if CounterExCInfo.has_counterex g rst 
                                           then (good,g::bad) else (g::good,bad))
              (RState.get_names_of_wire rst inp_wire)
              ([],[]) 
      fun quickcheck_app rst = 
         let val (good,bad) = do_quickcheck rst in
             rst |> RState.add_names_to_wire ok_wire (Goaln.NSet.of_list good)
                 |> RState.add_names_to_wire fail_wire (Goaln.NSet.of_list bad)
         end
  in RTechn.id |> RTechn.set_name "quickcheck"
               |> RTechn.set_inputs (RState.Wire.NSet.single inp_wire)
               |> RTechn.set_outputs (RState.Wire.NSet.of_list [ok_wire,fail_wire])
               |> RTechn.set_atomic_appf (Seq.single o quickcheck_app)
  end;

   val cc_ok_wire = RState.Wire.of_string "goal.not_trivial";
   val cc_fail_wire = RState.Wire.of_string "goal.counter_example";
   val quickcheck = quickcheck' (RState.Wire.of_string "goal") cc_ok_wire cc_fail_wire;

infixr 6 th_compose;
infixr 6 th_tensor;
infixr 5 th_or;

(* fix me: auto/simp etc  *)
val quickcheck_and_auto =
  (lift_rtechn_and_try_bind quickcheck)
   th_compose 
  (lift_rtechn_and_try_bind (id_of cc_ok_wire))
    th_compose 
  (lift_rtechn_and_try_bind auto);

end; end; (* local; struct *)
