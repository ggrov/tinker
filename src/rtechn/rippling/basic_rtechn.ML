(*
   Basic reasoning technique for rippling
   FIXME: why is conjecturing needed?
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature BASIC_RIPPLE (* RIPPLE_RTECHN *)=
sig
  exception rippling_rtechn_exp of string
  structure RippleCInfo : BASIC_RIPPLE_CINFO 

 val cond_fwire : WireNode.T
 val out_fwire : WireNode.T
 val ripple_fwire : WireNode.T
 val ripple_end_fwire : WireNode.T
 val strong_fert_fwire : WireNode.T
 val weak_fert_fwire : WireNode.T
 val weak_fert_eq_fwire : WireNode.T
 val weak_fert_neq_fwire : WireNode.T


  (* ATOMIC TECHNIQUES *)
  val fert_split_rtechn : RTechn.T
  val ripple_step' : RTechn.T
  val start_rippling : BWire.name -> WireNode.T -> RTechn.T
  val filter_is_eq_goal_rtechn : RTechn.T
  val filter_eq_skel_rtechn : RTechn.T
  val strong_fert_rtechn : RTechn.T
  val weak_fert_subst_in_lhs : RTechn.T
  val weak_fert_subst_in_rhs : RTechn.T
  val weak_fert_subst_eq_sym_true : RTechn.T
  val weak_fert_subst_eq_sym_false : RTechn.T
  val simp_base_rtechn : RTechn.T
  val id_base : RTechn.T

  (* GRAPHS *)

  val ripple_step : theory -> RTechnComb.graph * theory
  val end_rippling: theory -> RTechnComb.graph * theory
  val ripple_stepcase : BWire.name * WireNode.T ->  theory -> RTechnComb.graph * theory
  val simplify_basecase : theory -> RTechnComb.graph * theory
  val weak_fert : theory -> RTechnComb.graph * theory
  val induct_and_ripple : theory -> RTechnComb.graph * theory

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
functor BasicRippleRTechnFUN
          (structure RippleCInfo : BASIC_RIPPLE_CINFO
           structure ConjRTechn : BASIC_CONJ_RTECHN) (*NOTE: simple version *)
: BASIC_RIPPLE
= struct

structure RippleCInfo = RippleCInfo;
local 
  open RTechn; open RTechnEnv; open RTechnComb;
in

(* FIXME: move to nameset.ML *)
(* val partition : (name -> bool) -> T -> T*T *)
fun goal_partition f s = let val pos = Goaln.NSet.filter f s in (pos,Goaln.NSet.subtract s pos) end;
fun gnode_partition f s =  let val pos = GNode.GoalSet.filter f s in (pos,GNode.GoalSet.subtract s pos) end;

exception rippling_rtechn_exp of string;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Wires                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val mkw = BWire.of_string;
(* maybe use renaming instead? *)
fun wappend w s = mkw ((BWire.string_of w) ^ s);

val start_ripple_wire = InductRTechn.stepcase_wire;
val ripple_base_case = InductRTechn.basecase_wire;

val ripple_wire = mkw "goal.rippling.active"; (* could it be result? *)
val end_ripple_wire = mkw "goal.rippling.end"; (* post rippling *)

val skel_wire = mkw "result.skeleton"; (*?? *)
val fully_rippled_wire = wappend ripple_wire ".fully"; (* strong fert *)
val not_fully_rippled_wire = wappend ripple_wire ".not_fully"; (* weak fert *)

val not_fully_rippled_eq_wire = wappend not_fully_rippled_wire ".eq";
val not_fully_rippled_noteq_wire = wappend not_fully_rippled_wire ".noteq";

val cond_wire = mkw "goal.conds"; (* move somewhere else *)
val out_wire = mkw "goal.unknown"; (* move somewhere else *)
val goal_wire = mkw "goal";


(* FULL WIRES *)

fun mk_ripple_wire rwire = 
  RTechnEnv.mk_default_goal rwire
  |> RTechnEnv.add_fact_wire skel_wire;

val cond_fwire = RTechnEnv.mk_default_goal cond_wire;
val out_fwire = RTechnEnv.mk_default_goal out_wire;

val ripple_fwire = mk_ripple_wire ripple_wire;
val ripple_end_fwire = mk_ripple_wire end_ripple_wire;
val strong_fert_fwire = mk_ripple_wire fully_rippled_wire;
val weak_fert_fwire = mk_ripple_wire not_fully_rippled_wire;
val weak_fert_eq_fwire = mk_ripple_wire not_fully_rippled_eq_wire;
val weak_fert_neq_fwire = mk_ripple_wire not_fully_rippled_noteq_wire;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  ATOMIC TECHNIQUES                                                  *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Fertilisation                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* Strong Fertilisation *)

val strong_fert_rtechn = RTechnEnv.bck_res_wire skel_wire strong_fert_fwire cond_fwire
                       |> RTechn.set_name "rippling.strong_fert" ;

(*
val strong_fert_rtechn = 
  RTechnEnv.bck_res_gfn 
     fully_rippled_wire 
     cond_wire 
     (fn rst => fn goal => Seq.of_list (RippleCInfo.skeleton_names_of rst goal))
  |> RTechn.set_name "rippling.strong_fert" ;
*)

(* Weak fertilisation *)
 val weak_fert_subst_in_lhs = subst_in_lhs_from_wire "subst in lhs" skel_wire weak_fert_eq_fwire out_fwire cond_fwire false
                            |> RTechn.set_name "rippling.weak_fert_subst_in_lhs";
 val weak_fert_subst_in_rhs = subst_in_rhs_from_wire "subst in rhs" skel_wire weak_fert_eq_fwire out_fwire cond_fwire true
                            |> RTechn.set_name "rippling.weak_fert_subst_in_rhs";
 val weak_fert_subst_eq_sym_true = subst_eq_from_wire "subst eq sym" skel_wire weak_fert_neq_fwire out_fwire cond_fwire true
                            |> RTechn.set_name "rippling.weak_fert_subst_eq_sym_true";
 val weak_fert_subst_eq_sym_false = subst_eq_from_wire "subst eq sym" skel_wire weak_fert_neq_fwire out_fwire cond_fwire false
                            |> RTechn.set_name "rippling.weak_fert_subst_eq_sym_false";

fun is_eq_term t = 
    is_some (Subst.move_to_concl_eq (Zipper.mktop t));

(* what happens with goal where we fail? *)

val filter_eq_skel_rtechn = 
  let fun check_skel rst g = is_eq_term (RstPP.goal_concl rst g)
      fun filter_skel rst gnode = GNode.lookup_facts skel_wire gnode
                              |> Goaln.NSet.filter (check_skel rst)
      fun filter_gnode rst gnode gnds = gnode 
           |> GNode.set_facts GNode.WTab.empty
           |> GNode.add_facts (skel_wire,filter_skel rst gnode)
           |> (fn g => GNode.GoalSet.ins_fresh g gnds)
      fun app_tac' gnds rst = 
          GNode.GoalSet.fold
            (filter_gnode rst)
            gnds
            (GNode.GoalSet.empty);
      fun app_tac gnds rst = 
        RState.set_outputs (GoalNode.G.NSet.single (not_fully_rippled_wire,app_tac' gnds rst)) rst;
      fun appf gnds rst0 =
         rst0 |> app_tac gnds
              |> Seq.single
  in RTechn.id |> RTechn.set_name "rippling.get_and_filter_equality_skeletons"
               |> RTechn.set_inputs (WireNode.W.NSet.single weak_fert_fwire)
               |> RTechn.set_outputs (WireNode.W.NSet.single weak_fert_fwire)
               |> RTechn.set_atomic_appf (tac_appf appf)
  end;

val filter_is_eq_goal_rtechn =
   let fun check_goal rst nd = is_eq_term (RstPP.goal_concl rst (GNode.get_goal nd))
       fun appf gnds rst = 
          let val (eq,neq) = gnode_partition (check_goal rst) gnds
              val outputs = [(not_fully_rippled_eq_wire,eq),(not_fully_rippled_noteq_wire,neq)]
                          |> GoalNode.G.NSet.of_list
          in rst |> RState.set_outputs outputs
                 |> Seq.single 
          end
    in RTechn.id |> RTechn.set_name "rippling.filter_equality_goals"
               |> RTechn.set_inputs (WireNode.W.NSet.single weak_fert_fwire)
               |> RTechn.set_outputs (WireNode.W.NSet.of_list [weak_fert_eq_fwire,weak_fert_neq_fwire])
               |> RTechn.set_atomic_appf (tac_appf appf)
    end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Start Rippling                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* given an reasoning state which is being use to explore, then we can
setup rippling with the give skeleton terms and theorems. *)

(* TO DO: check wire names --  what is input/output of the technique? *)


(* slight generalisation *)
fun start_rippling pos_skel_wire in_fwire =
   let fun startr_on_goal gnode (gnds,rst) = 
         let val skels = (GNode.lookup_facts pos_skel_wire gnode)
                       |> Goaln.NSet.list_of
                       |> map (fn g => (g,PPlan.get_varified_ltrm (RState.get_pplan rst) g))
             fun mk_node rst = 
                  GNode.mk_goal_no_facts (GNode.get_gtyp gnode) (GNode.get_goal gnode)
                |> GNode.add_facts (skel_wire,Goaln.NSet.of_list (RippleCInfo.skeleton_names_of rst (GNode.get_goal gnode)))
             val new_rsts = RippleCInfo.start skels ParamRGraph.empty (GNode.get_goal gnode) rst
                          |> Seq.map (fn rst => (mk_node rst::gnds,rst))    
         in 
            new_rsts
         end   
       fun app_start gnds rst = 
          GNode.GoalSet.fold
            (fn gnd => Seq.maps (startr_on_goal gnd))
            gnds
            (Seq.single ([],rst))
       fun appf gnds rst =
          app_start gnds rst
        |> Seq.map (fn (gs,rst) => RState.set_outputs (GoalNode.G.NSet.single (ripple_wire,GNode.GoalSet.of_list gs)) rst)
   in RTechn.id |> RTechn.set_name "rippling.start_rippling"
                |> RTechn.set_inputs (WireNode.W.NSet.single in_fwire)
                |> RTechn.set_outputs (WireNode.W.NSet.single ripple_fwire)
                |> RTechn.set_atomic_appf (tac_appf appf)
   end;  

(*
val start_rippling =
   let fun startr_on_goal goal rst = 
         let val skels = PPlan.get_varified_lasm_nctrms (RState.get_pplan rst) goal;
         in rst |> (RippleCInfo.start skels ParamRGraph.empty goal) end;
       fun appf rst0 = 
         Seq.map
            (RState.move_wire_to_wire start_ripple_wire ripple_wire) 
            (Goaln.NSet.fold
                  (fn goal  => Seq.maps (startr_on_goal goal))
                  (RState.get_names_of_wire rst0 start_ripple_wire)
                  (Seq.single rst0))
   in RTechn.id |> RTechn.set_name "rippling.start_rippling"
                |> RTechn.set_inputs (WireNode.W.NSet.single start_ripple_wire)
                |> RTechn.set_outputs (WireNode.W.NSet.single ripple_wire)
                |> RTechn.set_atomic_appf appf
   end;
*)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Rippling Steps                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(*
  FIXME: I think this is wrong. When there is no rippling proof, the last step
  is not measure reducing / skeleton preserving in many cases.
*)


(* it should be possible to split up further into many rtechn *)
fun update_and_sort_goal_cinfo' oldgoal newgoal ((ripple,non_ripple),rst) =
   let val cinfos = RippleCInfo.update oldgoal newgoal rst 
   in case Seq.pull cinfos of
          NONE => Seq.single ((ripple,newgoal::non_ripple),rst)
        | SOME (x,xs) => Seq.map (fn rst => ((newgoal::ripple,non_ripple),rst)) (Seq.cons x xs)
   end;

fun update_and_sort_goal_cinfo oldgoal newgoal gsrst =
  Seq.maps (update_and_sort_goal_cinfo' oldgoal newgoal) gsrst;

fun update_and_sort oldgoal (ngs,rst) = 
  fold 
    (update_and_sort_goal_cinfo oldgoal)
    ngs
    (Seq.single (([],[]),rst));

fun filter_ripple_goals ((ripple,non_ripple),rst) =
   (* should we separate non-ripple goals from "unvalid state" goals*)
   let val (true_ripple,false_ripple) = List.partition (RippleCInfo.is_valid_ripple_state_goal rst) ripple
   in 
     if null true_ripple then Seq.empty
     else Seq.single ((true_ripple,non_ripple @ false_ripple),rst) (* fixme: or update the wires there?, fixme: or separate non_ripple and false_ripple *)
   end;

(*
fun update_goal_ripple_wires goal ((ripple,non_ripple),rst) =
   rst |> RState.remove_single_name goal 
       |> RState.add_names_to_wire ripple_wire (Goaln.NSet.of_list ripple)
       |> RState.add_names_to_wire out_wire (Goaln.NSet.of_list non_ripple)
*)

fun mk_ripple_goal gnode rst goal =
     GNode.mk_goal_no_facts (GNode.get_gtyp gnode) goal
     |> GNode.add_facts (skel_wire,Goaln.NSet.of_list (RippleCInfo.skeleton_names_of rst (GNode.get_goal gnode)));

fun mk_ripple_out_goal gnode goal = GNode.mk_goal_no_facts (GNode.get_gtyp gnode) goal;

fun mk_nds gnode ((ripple_gs,out_gs),rst) = 
    ((map (mk_ripple_goal gnode rst) ripple_gs,
      [],
      map (mk_ripple_out_goal gnode) out_gs),
     rst);

(* what if it is empty? *)
fun do_step gnode rst = 
       RippleCInfo.apply_rules_of_goal (GNode.get_goal gnode) rst
    |> Seq.maps (update_and_sort (GNode.get_goal gnode))
    |> Seq.maps filter_ripple_goals (* if empty then what? done rippling or something else? *)
    |> Seq.map (mk_nds gnode);
(*    |> Seq.map (update_goal_ripple_wires goal); *)


fun ripple_step_gnode gnode ((ripple,end_ripple,out),rst) =
  let 
     val possibleL = rst |> do_step gnode
                         |> Seq.list_of
     val possibleL_ripple = map (fn ((ripple,_,_),rst) => (map GNode.get_goal ripple,rst)) possibleL
     val possibleSeq = Seq.of_list possibleL
    in
      if RippleCInfo.blocked_chk rst (GNode.get_goal gnode) possibleL_ripple
      then 
        Seq.cons ((ripple,gnode::end_ripple,out),rst)
                 possibleSeq
      else possibleSeq
    end;

(* FIXME! need to check if blocked!! - or will this be "discovered" next step? *)
(* blocked_chk rst ripple_wire goal new_seqence *)
(* probably put it in end_ripple if blocked too -- can this be ignored? *)

(* note: no loop (need a combinator!) *)
val ripple_step' =
  let val appf_goal = ripple_step_gnode
      fun app_tac gnds rst =  (* add check for when rippling is completed *)
        GNode.GoalSet.fold
           (fn g => Seq.maps (appf_goal g))
           gnds
           (Seq.single (([],[],[]),rst))        
      fun set_output ((ripple,end_ripple,out),rst) =
           [(ripple_wire,GNode.GoalSet.of_list ripple),
            (end_ripple_wire,GNode.GoalSet.of_list end_ripple),
            (out_wire,GNode.GoalSet.of_list out)]
           |> GoalNode.G.NSet.of_list
           |> (fn gs => RState.set_outputs gs rst)
      fun appf gnds rst0 = app_tac gnds rst0 |> Seq.map set_output
   in RTechn.id |> RTechn.set_name "rippling.ripple_step"
                |> RTechn.set_inputs (WireNode.W.NSet.single ripple_fwire)
                |> RTechn.set_outputs (WireNode.W.NSet.of_list [ripple_fwire,ripple_end_fwire,out_fwire])
                |> RTechn.set_atomic_appf (tac_appf appf)
   end;

(* move to fertilisation section? *)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Induction and Rippling: no conjecturing                            *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


val fert_split_rtechn =
  let 
     fun update rst (fully,nfully) =
          [(fully_rippled_wire, fully),
           (not_fully_rippled_wire, nfully)]
           |> GoalNode.G.NSet.of_list
           |> (fn gs => RState.set_outputs gs rst)
     fun appf gnds rst = gnds
            |> gnode_partition (fn gnode => RippleCInfo.success_chk rst (GNode.get_goal gnode))
            |> update rst
            |> Seq.single
   in RTechn.id |> RTechn.set_name "rippling.fertilisation_split"
                |> RTechn.set_inputs (WireNode.W.NSet.single ripple_end_fwire)
                |> RTechn.set_outputs (WireNode.W.NSet.of_list [strong_fert_fwire,weak_fert_fwire])
                |> RTechn.set_atomic_appf (tac_appf appf)
   end;

val id_base = (id_of ripple_base_case)
            |> RTechn.set_name "rippling.id_base"

val simp_base_rtechn = simp_no_asm_changes_on InductRTechn.basecase_wire;

;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Graphs (compound techniques)                                       *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Fertilisation                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

 (* in theory context *)
 val weak_fert_eq_rtechn = 
   ((lift_rtechn_and_try_bind weak_fert_subst_in_lhs)
     orr
   (lift_rtechn_and_try_bind weak_fert_subst_in_rhs))
   (*
   compose 
   (lift_merge 2 out_fwire) tensor (lift_merge 2 cond_fwire) *);

 val weak_fert_neq_rtechn = 
  ((lift_rtechn_and_try_bind weak_fert_subst_eq_sym_true)
    orr
  (lift_rtechn_and_try_bind weak_fert_subst_eq_sym_false))
  (* compose 
  (lift_merge 2 out_fwire) tensor (lift_merge 2 cond_fwire) *);

 val weak_fert'  =
  (lift_rtechn_and_try_bind filter_eq_skel_rtechn) 
  compose 
    ((lift_rtechn_and_try_bind filter_is_eq_goal_rtechn)
       compose (* weak fert also need skeleton so additional input! *)
     (weak_fert_eq_rtechn tensor weak_fert_neq_rtechn))
   compose 
   (lift_merge 2 out_fwire) tensor (lift_merge 2 cond_fwire);

 fun weak_fert th = 
    let 
      val (wg,th') = weak_fert' th
      val (wh,th'') = collapse_graph RTechn.set_hgraph_appf "weak_fert" wg th'
      val rule = RTechn_Theory.Rule.mk (wh,wg);
      val th''' = RTechn_RS.Theory.add_nested rule th''
    in
       (wh,th''')
    end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Ripple steps                                                       *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

 fun ripple_step'' th = 
   let val (g',th') = ((lift_merge 2 ripple_fwire) compose (lift ripple_step')) th
       val r = GraphComb.get_boundary_outputs g' 
             |> map (fn (v,_,_) => v)
             |> hd;
       val m = GraphComb.get_boundary_inputs g'
             |> map (fn (_,_,v) => v)
             |> hd;
   in 
     (GraphComb.plug_rtechns th' r m g',th')
   end;

 fun ripple_step th = 
    let 
      val (rg,th') = ripple_step'' th
      val (rh,th'') = collapse_graph RTechn.set_hgraph_appf "rippling.rippling" rg th'
      val rule = RTechn_Theory.Rule.mk (rh,rg);
      val th''' = RTechn_RS.Theory.add_nested rule th''
    in
       (rh,th''')
    end;



 val end_rippling =
  (lift_rtechn_and_try_bind fert_split_rtechn)
    compose
  ((lift_rtechn_and_try_bind strong_fert_rtechn) 
     tensor 
       (weak_fert
         compose
       (lift_rtechn_and_try_bind (RTechnEnv.simp_no_asm_changes_on out_fwire))));

 fun ripple_stepcase (ind_hyp,inp_wire) =
   (lift_rtechn_and_try_bind (start_rippling ind_hyp inp_wire))
     compose
   ripple_step
     compose
   end_rippling
     compose 
   (lift_merge 2 cond_fwire);

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Simplify Base Case                                                 *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


val simplify_basecase = lift simp_base_rtechn;
(* (lift_rtechn_and_try_bind id_base) 
   compose
 (lift_rtechn_and_try_bind simp_base_rtechn); *)

val induct_and_ripple =
  (lift_rtechn_and_try_bind InductRTechn.induct_rtechn)
   compose (* or then *)
  ((simplify_basecase
      tensor
    ripple_stepcase (InductRTechn.hyp_wire,InductRTechn.stepcase_wire)))
  compose 
  (lift_merge 2 (mk_default_goal simp_goal));



  
end; (* RTechnEnv local *) 
end; (* struct *)

  
