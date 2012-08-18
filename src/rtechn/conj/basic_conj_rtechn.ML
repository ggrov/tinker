(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
  Basic conjecturing -- no handling of proven conjectures 
*)   

signature BASIC_CONJ_RTECHN =
sig
  val goal_wire : WireNode.T
  val goal_conj_wire : WireNode.T

  val conj_rtechn : RTechn.T
  val ccex_rtechn : RTechn.T
  val app_rtechn : RTechn.T

  val conj : theory -> RTechnComb.graph * theory 

  (* val rtechn_tab : RTechn.T RTab.T *)
end;

structure BasicConjRTechn : BASIC_CONJ_RTECHN
= struct 

  (* input *)
  val goal_wire = RTechnEnv.mk_default_goal RTechnEnv.default_goal;

  (* conj *)
  val goal_conj_mainwire = BWire.of_string "goal.conj"
  val goal_conj_to_resolve_mainwire = BWire.of_string "goal.conjectured"
  val goal_conj_to_resolve_wire = 
    RTechnEnv.mk_default_goal goal_conj_to_resolve_mainwire
    ||> FWire.add_fact goal_conj_mainwire;

  (* output: conjecture *)
  val goal_conj_wire = RTechnEnv.mk_default_goal goal_conj_mainwire;

  (* ATOMIC TECHNIQUES *)

  fun conj_from_gname gname rst = 
      let 
        val ptab = Cx.get_fixed_trm_ps (RstPP.get_cx rst gname);
        val sgterm = RstPP.goal_concl rst gname;
        fun mk_out_conj new_goal = 
           (goal_conj_mainwire,
            GNode.GoalSet.single 
              (GNode.mk_goal_no_facts RTechnEnv.default_goal new_goal))
        fun mk_out_res_goal conj_goal old_goal = 
           (goal_conj_to_resolve_mainwire,
            GNode.GoalSet.single 
              (GNode.mk_goal_no_facts RTechnEnv.default_goal old_goal
               |> GNode.add_facts (goal_conj_mainwire,Goaln.NSet.single conj_goal)))
        fun mk_out conj_goal old_goal =
          GoalNode.G.NSet.of_list
            [mk_out_conj conj_goal,mk_out_res_goal conj_goal old_goal];
        fun add_conj t = RstPP.new_conj_at_top ("lem_a", t) rst
                     |> (fn (conj_g,rst') => RState.set_outputs (mk_out conj_g gname) rst')
      in LemmaConjLib.conjs (RState.get_pplan rst) ptab sgterm
         |> Seq.map (fn (_,(_,t)) => add_conj t)
      end;

  fun conj_app' gs rst =
    GNode.GoalSet.fold 
      (fn n => Seq.maps (conj_from_gname (GNode.get_goal n)))
      gs
      (Seq.single rst);

  val conj_app = RTechnEnv.tac_appf conj_app';

  val conj_rtechn = 
    RTechn.id |> RTechn.set_name "bconj.conj_rtechn"
              |> RTechn.set_inputs (WireNode.W.NSet.single goal_wire)
              |> RTechn.set_outputs (WireNode.W.NSet.of_list [goal_conj_wire,goal_conj_to_resolve_wire])
              |> RTechn.set_atomic_appf conj_app;

  (* counter example *)
 fun count_ex_app' gnds rst = 
  let
    fun get_term gname = RstPP.goal_concl rst gname 
    fun check_goal gname = 
       is_some (CounterExCInfo.timed_quickcheck_term 
                     (RstPP.get_ctxt rst) (CounterExCInfo.default_codegen_params, []) 
                     (Trm.change_vars_to_fresh_frees (get_term gname)) (Time.fromSeconds 1))
    val check_all = Goaln.NSet.forall (not o check_goal) (GNode.get_all_goals gnds)
   in 
      if check_all 
       then Seq.single rst
       else Seq.empty
   end;

 val count_ex_app = RTechnEnv.tac_appf count_ex_app';

 (* fails if counter-example exists for any goal*)
 val ccex_rtechn =
  RTechn.id 
     |> RTechn.set_name "bconj.counter_example_check"
     |> RTechn.set_inputs (WireNode.W.NSet.single goal_conj_wire)
     |> RTechn.set_outputs (WireNode.W.NSet.single goal_conj_wire)
     |> RTechn.set_atomic_appf count_ex_app;

  val app_rtechn = 
    RTechnEnv.bck_res_wire 
      goal_conj_mainwire 
      goal_conj_to_resolve_wire
      goal_conj_to_resolve_wire (* dummy should not happen *)
    |> RTechn.set_outputs WireNode.W.NSet.empty
    |> RTechn.set_name "bconj.resolve_goal_with_conj";


 (* GRAPHS *)
  val conj = 
    (RTechnComb.lift_rtechn_and_try_bind conj_rtechn)
      compose
     (RTechnComb.lift_rtechn_and_try_bind ccex_rtechn)
        tensor
     (RTechnComb.lift_rtechn_and_try_bind app_rtechn);

(*
   ((lift_rtechn_and_try_bind conj_rtechn) th_compose (lift_rtechn_and_try_bind rename_goal_wire_rtechn))
     th_compose
   ((lift_rtechn_and_try_bind ccex_rtechn)
     th_compose
   (app_graph th_tensor (lift_rtechn_and_try_bind id_goal_conj_wire_rtechn)));
*)


(*
  val app_rtechn = RTechnEnv.bck_res_wire goal_conj_wire goal_not_triv_wire goal_not_triv_wire 
                 |> RTechn.set_name "bconj.resolve_goal_with_conj";

  val rename_goal_wire_rtechn = RTechnComb.rename_wire_rtechn goal_wire goal_not_triv_wire 
                             |> RTechn.set_name "bconj.rename_goal";

  val id_goal_conj_wire_rtechn = RTechn.id_of goal_conj_wire
                              |> RTechn.set_name "bconj.id_conj_goal";
*)
  (* val rtechn_tab = RTab.empty 
        |> RTab.ins (RTName.mk "bconj.resolve_goal_with_conj",app_rtechn)
        |> RTab.ins (RTName.mk "bconj.counter_example_check",ccex_rtechn)
        |> RTab.ins (RTName.mk "bconj.conj_rtechn",conj_rtechn)
        |> RTab.ins (RTName.mk "bconj.rename_goal",rename_goal_wire_rtechn)
        |> RTab.ins (RTName.mk "bconj.id_conj_goal",id_goal_conj_wire_rtechn)
  *)
end (* structure *)

