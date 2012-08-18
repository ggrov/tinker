(* testing issue with rippling *)

structure RippleSkel_flow = RippleSkelMesTracesFUN(FlowMeasure);
structure RippleCInfo = BasicRippleCInfoFUN(RippleSkel_flow);

structure BasicRippleRTechn
= struct

structure RippleCInfo = RippleCInfo;
local 
  open RTechn; open RTechnEnv; open RTechnComb;
in


(* FIXME: move to Nameset.ML *)
  (* partition: like filter but also returns false elements *)
(* val partition : (name -> bool) -> T -> T*T *)
fun partition f s = let val pos = Goaln.NSet.filter f s in (pos,Goaln.NSet.subtract s pos) end;

exception rippling_rtechn_exp of string;

(* wires *)
val mkw = RState.Wire.of_string;
(* maybe use renaming instead? *)
fun wappend w s = mkw ((RState.Wire.string_of w) ^ s);

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


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Fertilisation                                                      *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* Strong Fertilisation *)

(* FIXME: this is wrong!!! *)
val strong_fert_rtechn = 
  RTechnEnv.bck_res_gfn 
     fully_rippled_wire 
     cond_wire (* or should it be some cond wire??? *)
     (fn rst => fn goal => Seq.of_list (RippleCInfo.skeleton_names_of rst goal));

(* Weak fertilisation *)

fun is_eq_term t = 
    is_some (Subst.move_to_concl_eq (Zipper.mktop t));

(* what happens with goal where we fail? *)
val get_and_filter_is_eq_skel_rtechn = 
  let fun check_skel (skelnm,skel) = is_eq_term skel
      fun valid_skelnms_of_goal rst goal =
         filter check_skel (RippleCInfo.skeleton_namedterms_of rst goal)
        |> map fst
      fun skels rst = 
           maps (valid_skelnms_of_goal rst)
                (Goaln.NSet.list_of (RState.get_names_of_wire rst not_fully_rippled_wire))
      fun appf rst0 =
         rst0 |> RState.add_names_to_wire skel_wire (Goaln.NSet.of_list (skels rst0))
              |> RState.set_rtechn NONE
              |> Seq.single
  in RTechn.id |> RTechn.set_name "get and filter equality skeletons"
               |> RTechn.set_inputs (RState.Wire.NSet.single not_fully_rippled_wire)
               |> RTechn.set_outputs (RState.Wire.NSet.of_list [not_fully_rippled_wire,skel_wire])
               |> RTechn.set_atomic_appf appf
  end;

val filter_is_eq_goal_rtechn =
   let fun check_goal rst goal = is_eq_term (RstPP.goal_concl rst goal)
       fun appf rst = 
          let val (eq,neq) = partition (check_goal rst) 
                                       (RState.get_names_of_wire rst not_fully_rippled_wire) 
          in rst |> RState.remove_names_of_wire not_fully_rippled_wire
                 |> RState.add_names_to_wire not_fully_rippled_eq_wire eq
                 |> RState.add_names_to_wire not_fully_rippled_noteq_wire neq
                 |> RState.set_rtechn NONE
                 |> Seq.single 
          end
    in RTechn.id |> RTechn.set_name "filter equality goals"
               |> RTechn.set_inputs (RState.Wire.NSet.single not_fully_rippled_wire)
               |> RTechn.set_outputs (RState.Wire.NSet.of_list [not_fully_rippled_eq_wire,not_fully_rippled_noteq_wire])
               |> RTechn.set_atomic_appf appf
    end;

val weak_fert_eq_rtechn =
  (lift_rs (subst_in_lhs_from_wire "subst in lhs" skel_wire not_fully_rippled_eq_wire out_wire cond_wire false))
 orr
  (lift_rs (subst_in_rhs_from_wire "subst in rhs" skel_wire not_fully_rippled_eq_wire out_wire cond_wire true));

val weak_fert_neq_rtechn = 
  lift_rs (RTechnEnv.subst_eq_from_wire "subst eq sym" skel_wire not_fully_rippled_noteq_wire out_wire cond_wire true)
  orr
  lift_rs (RTechnEnv.subst_eq_from_wire "subst eq sym" skel_wire not_fully_rippled_noteq_wire out_wire cond_wire false);

val weak_fert_rtechn  =
  lift_rs get_and_filter_is_eq_skel_rtechn (* can be moved to after thenr to reduce comp *)
  compose 
    (lift_rs filter_is_eq_goal_rtechn 
     compose (* weak fert also need skeleton so additional input! *)
     ( weak_fert_eq_rtechn tensor weak_fert_neq_rtechn))
  (* FIXME: this should really by an evaluation isssue!!!
     ((not_fully_rippled_eq_wire,weak_fert_eq_rtechn) tensor_and_wire (not_fully_rippled_noteq_wire,weak_fert_neq_rtechn))); *)


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Start Rippling                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* given an reasoning state which is being use to explore, then we can
setup rippling with the give skeleton terms and theorems. *)

(* TO DO: check wire names *)
(* what is input/output of the technique? *)
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
                  (Seq.single (RState.set_rtechn NONE rst0)))
   in RTechn.id |> RTechn.set_name "start rippling"
                |> RTechn.set_inputs (RState.Wire.NSet.single start_ripple_wire)
                |> RTechn.set_outputs (RState.Wire.NSet.single ripple_wire)
                |> RTechn.set_atomic_appf appf
   end;

(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Rippling Steps                                                     *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

(* NOTE on difference from before
    - before: rippled one goal to completion then rippled the next goal
    - now: ripple all goals in parallel?
         - fits best with the "wire" idea here...
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

fun update_goal_ripple_wires goal ((ripple,non_ripple),rst) =
   rst |> RState.remove_single_name goal 
       |> RState.add_names_to_wire ripple_wire (Goaln.NSet.of_list ripple)
       |> RState.add_names_to_wire out_wire (Goaln.NSet.of_list non_ripple)

(* what if it is empty? *)
fun do_step goal rst = 
       RippleCInfo.apply_rules_of_goal goal rst
    |> Seq.maps (update_and_sort goal)
    |> Seq.maps filter_ripple_goals (* if empty then what? done rippling or something else? *)
    |> Seq.map (update_goal_ripple_wires goal);

fun ripple_step_goal goal rst =
  let 
     val possibleL = rst |> do_step goal
                         |> Seq.list_of
     val possibleSeq = Seq.of_list possibleL
    in
      if RippleCInfo.blocked_chk rst ripple_wire goal possibleL
      then 
        Seq.cons (rst |> RState.remove_single_name goal
                      |> RState.add_names_to_wire end_ripple_wire (Goaln.NSet.single goal))
                 possibleSeq
      else possibleSeq
    end;

(* DELETE!!! *)
fun ripple_step_goal_old goal rst0 =
  let 
    (* val pplan = RState.get_pplan rst0; *)
    (* remove previous rippling goal from wire - should it be something else if failure? *)
    val rst1 = RState.remove_single_name goal rst0 
    val apprules = RippleCInfo.apply_rules_of_goal goal rst1
    fun upd_cinfo_newgoal newgoal rst = 
      let val cinfoseq = RippleCInfo.update goal newgoal rst
      in case Seq.pull cinfoseq of
          NONE => Seq.single (rst |> RState.add_names_to_wire out_wire (Goaln.NSet.single newgoal)) (* is out_wire correct? *)
        | SOME _ => Seq.map (RState.add_names_to_wire ripple_wire (Goaln.NSet.single newgoal)) cinfoseq
      end;
    (* FIXME: what about cases where there are no rippling goals: return Seq.single rst? *)
    (* what happend to *)
    fun upd_cinfo_goal (gs,rst) = 
       let val new_rsts = fold (fn g => Seq.maps (upd_cinfo_newgoal g)) gs (Seq.single rst)
           val goal_set = Goaln.NSet.of_list gs
           fun ripple_goals rst = RState.get_names_of_wire rst ripple_wire
           fun is_ripple_step rst = (Goaln.NSet.intersect goal_set (ripple_goals rst)) (* intersection of ripple wire and new goals *)
                                    |> Goaln.NSet.is_empty (* meaning no new ripple goals, i.e. fail *)
        in
          Seq.filter is_ripple_step new_rsts 
        end
  in
     case Seq.pull (Seq.maps upd_cinfo_goal apprules) of
            NONE => Seq.single (rst1 |> RState.add_names_to_wire end_ripple_wire (Goaln.NSet.single goal)) (* no more rippling possible *)
          | SOME (x,xs) => Seq.cons x xs (* still rippling -- add check for blocked? *)
  end;

(* need to check if blocked!! - or will this be "discovered" next step? *)
(* blocked_chk rst ripple_wire goal new_seqence *)
(* probably put it in end_ripple if blocked too -- can this be ignored? *)

(* no loop *)
val ripple_step' =
  let val appf_goal = ripple_step_goal
      fun appf rst =  (* add check for when rippling is completed *)
        Goaln.NSet.fold
           (fn g => Seq.maps (appf_goal g))
           (RState.get_names_of_wire rst ripple_wire)
           (Seq.single rst)        
   in RTechn.id |> RTechn.set_name "ripple step"
                |> RTechn.set_inputs (RState.Wire.NSet.single ripple_wire)
                |> RTechn.set_outputs (RState.Wire.NSet.of_list [ripple_wire,end_ripple_wire,out_wire])
                |> RTechn.set_atomic_appf (Seq.map (RState.set_rtechn NONE) o appf)
   end;

(* with loop *)
val ripple_step = loop_wire true ripple_wire (lift_rs ripple_step');


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Simplify Base Case                                                 *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* Simplify the base case *)
(*
fun simplify_basecase g = 
(*     givename basecaseN (DTacRTechn.simp_asm_full g);  *)
    givename basecaseN (DTacRTechn.simp_no_asm_simp_changes g);
*)

(* fixme: I don't think renaming is necessary any more since goals
   are now sent down a wire *)
val simplify_basecase_rtechn = 
 lift_rs (RTechnComb.rename_wire_rtechn ripple_base_case goal_wire)
 thenr
 lift_rs RTechnEnv.simp_no_asm_simp_changes; (* should fail if cannot be proven *)


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(*  Induction and Rippling: no conjecturing                            *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val fert_split_rtechn =
  let fun appf rst = (* empty input/output means that rippling succeeded *)
               RState.get_names_of_wire rst end_ripple_wire
            |> partition (RippleCInfo.success_chk rst)
            |> (fn (full,nfull) => rst
                                |> RState.remove_names_of_wire end_ripple_wire
                                |> RState.add_names_to_wire fully_rippled_wire full 
                                |> RState.add_names_to_wire not_fully_rippled_wire nfull)
            (* restrict wire? *) 
            |> RState.set_rtechn NONE
            |> Seq.single
   in RTechn.id |> RTechn.set_name "fertilisation split"
                |> RTechn.set_inputs (RState.Wire.NSet.single end_ripple_wire)
                |> RTechn.set_outputs (RState.Wire.NSet.of_list [fully_rippled_wire,not_fully_rippled_wire])
                |> RTechn.set_atomic_appf appf
   end;

val endr_rthecn =
  (lift_rs fert_split_rtechn)
  thenr
  (lift_rs strong_fert_rtechn tensor (weak_fert_rtechn thenr lift_rs RTechnEnv.simp_no_asm_simp_changes));

 (* FIXME should then compose out_wire with simp *)    

(*
fun endr rst = 
    rstif (null o RState.get_goalnames) 
          (dummy solved_by_ripplingN)
          (split_then (RippleCInfo.success_chk rst) 
                      (map_then strong_fert_goal)
                      ((map_then weak_fert_goal)
                         try1_then 
                         ((map_then DTacRTechn.simp_noasm)
                            try1_orelse 
                            (dummy (RstName.str "Step case stuck")))))
      rst;
*)

val ripple_stepcase_rthecn =
   lift_rs start_rippling 
   thenr
   ripple_step
   compose
   endr_rthecn;

val induct_and_ripple_rtechn =
  lift_rs InductRTechn.induct_rtechn
  thenr (* or then *)
  ((simplify_basecase_rtechn
   tensor
  ripple_stepcase_rthecn));

val test =
  lift_rs InductRTechn.induct_rtechn
  compose (* or then *)
(*  simplify_basecase_rtechn ;
   tensor *)
  ripple_stepcase_rthecn; 
  
end; (* RTechnEnv local *) 
end; (* struct *)


