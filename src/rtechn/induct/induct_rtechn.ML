signature INDUCT_RTECHN =
sig

  val hyp_wire : BWire.name
  val induct_wire : WireNode.T
  val stepcase_wire : WireNode.T
  val basecase_wire : WireNode.T

  val induct_rtechn : RTechn.T;
  val induct_from_rule_rtechn : Thm.thm  -> RTechn.T;
  (* FIXME: val induct_from_wire_rtechn : RState.Wire.name  -> RTechn.T; *)
(*  val induct_base_then_step :  RTechn.T -> RTechn.T -> RTechn.T *)

end;

structure InductRTechn : INDUCT_RTECHN
= struct

(*
local
open RTechnEnv;
in
*)

  val induct_mainwire = BWire.of_string "goal.inductable";
  (* val induct_goal_wire = BWire.of_string "goal.has_induct_term"; *)

  val stepcase_mainwire = BWire.of_string "goal.step";
  val hyp_wire = BWire.of_string "result.IH";

  val basecase_mainwire = BWire.of_string "goal.base";  

  val induct_wire = RTechnEnv.mk_default_goal induct_mainwire;
  val basecase_wire = RTechnEnv.mk_default_goal basecase_mainwire;
  val stepcase_wire = RTechnEnv.mk_default_goal stepcase_mainwire
                    ||> FWire.add_fact hyp_wire;



(* with a different wire this could be
 val induct_wire = RState.Wire.of_string "goal.inductable"
   |> add_feature (has_inductable_terms);
*) 

(*
  val stepcase_wire = RState.Wire.of_string "goal.step"
   |> add_feature (has_embedding_in_hyps));
  val basecase_wire = RState.Wire.of_string "goal.base"
   |> add_feature (not(has_embedding_in_hyps));

  matching ~ subset_relation + shape matching

*)
(* gets names/types of possible induction vars *)
fun inductable_things_of g rst = 
    let 
      val pp = RState.get_pplan rst
      val thy = PPlan.get_theory pp
      val gt = Prf.get_ndname_ctrm pp g
    in InductTac.inductable_things_in_term thy gt end;

(* g -> rst -> (base,step,pplan) seq *)
fun apply_induction_on_goal rst g = 
    let val (ithings,_) = inductable_things_of g rst;
        val ind_tacs = map (fn i => InductTac.induct_tac NONE [i]) (map fst ithings);
        val ind_res = Seq.maps (fn t => PPlanTac.apply_localasms_tac ("induct",t) g ([],RState.get_pplan rst)) (Seq.of_list ind_tacs) (* apply all possible induction in g *) 
        val prev_assms = RstPP.lasms_of_goal rst g
        fun split (gs,pplan) =
           let val (base,step) = List.partition (not o PPlan.has_new_asm pplan prev_assms) gs 
           in (base,map (fn g => (PPlan.new_asms pplan prev_assms g,g)) step,pplan) end;
     in Seq.map split ind_res
     end;

(* thm -> g -> rst -> (base,step,pplan) seq *)
fun apply_induction_on_goal_with_rule rule rst g = 
    let val (ithings,_) = inductable_things_of g rst;
        val ind_tacs = map (fn i => InductTac.induct_tac (SOME rule) [i]) (map fst ithings);
        val ind_res = Seq.maps (fn t => PPlanTac.apply_localasms_tac ("induct",t) g ([],RState.get_pplan rst)) (Seq.of_list ind_tacs) (* apply all possible induction in g *) 
        val prev_assms = RstPP.lasms_of_goal rst g
        fun split (gs,pplan) =
           let val (base,step) = List.partition (not o PPlan.has_new_asm pplan prev_assms) gs 
           in (base,map (fn g => (PPlan.new_asms pplan prev_assms g,g)) step,pplan) end;
     in Seq.map split ind_res
     end;
(*
fun apply_induction_from_wire wire rst g = 
  Seq.maps (fn rule => apply_induction_on_goal_with_rule (ProofContext.get_thm (RState.get_ctxt rst) rule) g)  
           (Goaln.NSet.seq_of (RState.get_names_of_wire rst wire));
*)

(* induction goal was OR, now AND - need testing *)
fun mk_induct_rtechn indf =
  let val inwires = WireNode.W.NSet.of_list [induct_wire]
      val outwires = WireNode.W.NSet.of_list [basecase_wire,stepcase_wire]
      fun set_base_gnode goal = GNode.mk_goal_no_facts RTechnEnv.default_goal goal;
      fun mk_facts_map new_facts = GNode.WTab.empty 
                                 |> GNode.WTab.ins (hyp_wire,Goaln.NSet.of_list new_facts);
      fun set_step_gnode (hyps,goal) = GNode.mk_goal_no_facts RTechnEnv.default_goal goal
                                     |> GNode.set_facts (mk_facts_map hyps);
      fun apply_tac g (base,step,rst) = 
               indf rst (GNode.get_goal g)
               |> Seq.map (fn (b',s',pp') => (base @ map set_base_gnode b',
                                              step @ map set_step_gnode s',
                                              RState.set_pplan pp' rst));
      fun bsrst_seq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],rst)); 
      fun set_outputs base step =         
          GoalNode.G.NSet.of_list 
              [(basecase_mainwire,GNode.GoalSet.of_list base),
               (stepcase_mainwire,GNode.GoalSet.of_list step)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (base,step,rst) => rst |> set_outputs base step) 
           (RTechnEnv.tac_appf bsrst_seq rst)
   in RTechn.id |> RTechn.set_name "induct"
                |> RTechn.set_inputs inwires
                |> RTechn.set_outputs outwires
                |> RTechn.set_atomic_appf app
   end;

val induct_rtechn = mk_induct_rtechn apply_induction_on_goal;
fun induct_from_rule_rtechn thm = mk_induct_rtechn (apply_induction_on_goal_with_rule [thm]);

(* induct where rule is thm in wire *)
(* val induct_from_wire_rtechn = mk_induct_rtechn o apply_induction_from_wire; *)

(* fun induct_base_then_step base step = 
   induct_rtechn thenr (base tensor step);
*)
(*end; *) (* local *)

end;
