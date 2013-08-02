signature RTECHN_ENV =
sig

  type wire = WireNode.T
  type bwire = BWire.name

  val mk_default_goal : bwire -> wire
  val default_goal : bwire
  val add_fact_wire : bwire -> wire -> wire
  val simp_goal : bwire

  val apply_localasms_tac_to_each_goal_rtechn : 
      wire -> wire -> (string*string) -> 
      (GNode.goal -> Prf.gname -> GNode.goal) -> 
      (RState.T -> Thm.thm -> Thm.thm Seq.seq) -> 
      RTechn.T
  val apply_allasms_tac_to_each_goal_rtechn :
      wire -> wire -> (string*string) -> 
      (GNode.goal -> Prf.gname -> GNode.goal) -> 
      (RState.T -> Thm.thm -> Thm.thm Seq.seq) -> 
      RTechn.T

  val tac_appf : (GNode.GoalSet.T -> RState.T -> 'a Seq.seq) -> 
                 RState.T -> 
                 'a Seq.seq

  val simp_all_asm_full_on : wire -> RTechn.T
  val simp_asm_full_on : wire -> RTechn.T
  val simp_asm_full : RTechn.T
  val simp_no_asm : RTechn.T
  val simp_no_asm_changes_on : wire -> RTechn.T
  val simp_no_asm_changes : RTechn.T
  val simp_no_asm_use : RTechn.T
  val simp_asm_lr : RTechn.T

  val unfold_rtechn : wire -> wire -> thm list -> RTechn.T
  val auto_on : wire -> RTechn.T
  val blast : wire -> RTechn.T
  val safe : RTechn.T

  (* Backwards resolution *)
  val rule_wire : wire -> wire -> Thm.thm -> RTechn.T
  val rule_dthm_wire : wire -> wire -> DThm.T -> RTechn.T
  val erule_dthm_wire : bwire * wire -> bwire * wire -> DThm.T -> RTechn.T

  (* forward resolution *) 
  val frule_dthm_wire: bwire -> bwire -> wire -> wire -> DThm.T -> RTechn.T

  (* resolution backwards from name *)
  val bck_res_wire : bwire -> wire -> wire -> RTechn.T

  (* substitutions *)
  val subst_thm_from_wire : string -> wire -> wire -> wire -> Thm.thm -> bool -> RTechn.T
  val subst_result_thm_from_wire : string -> bwire*wire -> bwire*wire -> wire -> Thm.thm -> bool -> RTechn.T
  val subst_eq_from_wire : string -> bwire -> wire -> wire -> wire -> bool -> RTechn.T
  val subst_in_lhs_from_wire : string -> bwire -> wire -> wire -> wire -> bool -> RTechn.T
  val subst_in_rhs_from_wire : string -> bwire -> wire -> wire -> wire -> bool -> RTechn.T

end; (* signature *)

structure RTechnEnv_DB
= struct

  type wire = WireNode.T
  type bwire = BWire.name
  val single = WireNode.W.NSet.single;
  val id = RTechn.id;

  (* update of results... *)

  fun update_main_wire (_,ws) wire = (wire,ws);
   
  fun update_goal_wire fwire wire = fwire ||> FWire.set_goal wire;

  fun update_and_del_fact_wire fwire factwire new_factwire = 
    fwire ||> FWire.delete_matching_facts factwire 
          ||> FWire.add_fact new_factwire;

  fun add_fact_wire new_factwire fwire = 
    fwire ||> FWire.add_fact new_factwire;

  (* change this to change default *)
  val default_bck_update = update_goal_wire;

  val mk_default = (BWire.default_wire,FWire.default_wire);
  fun mk_default_main_wire wire = mk_default ||> FWire.set_goal wire;
  fun mk_default_goal_wire wire = (wire,FWire.default_wire);
  (* change this to change default *)
  val mk_default_goal = mk_default_goal_wire;
  fun mk_default_result wire = mk_default |> add_fact_wire wire;

  val subst_goal = BWire.of_string "goal.subst";
  val subst_result = BWire.of_string "result.subst";
  val simp_goal = BWire.of_string "goal.simp";
  val auto_goal = BWire.of_string "goal.auto";
  val safe_goal = BWire.of_string "goal.safe";
  val cond_goal = BWire.of_string "goal.cond";
  val simp_result = BWire.of_string "result.simp";
  val eq_result = BWire.of_string "result.eq";
  val default_goal = BWire.of_string "goal";
  val default_result = BWire.of_string "result";


(* simple goal/result to goal/result tech with given name *)
  fun goal_to_goal_rtech name = id
    |> RTechn.set_name name
    |> RTechn.set_inputs (single (mk_default_goal default_goal))
    |> RTechn.set_outputs (single (mk_default_goal default_goal));

  fun result_to_result_rtech name = id
    |> RTechn.set_name name
    |> RTechn.set_inputs (single (mk_default_result default_result))
    |> RTechn.set_outputs (single (mk_default_result default_result));

  fun apply_localasms_tac_to_each_goal_app (wname,f) (tacnf,tac) gnodes rst = 
    let
      (* give a sequence of (new_goal_node list,pplan) *)
      fun update_goal gnds gnode (gs,pp) = (gnds @ (map (f gnode) gs),pp) 
      fun apply_tac gnode (gnds,pplan) =
          PPlanTac.apply_localasms_tac (tacnf,tac) (GNode.get_goal gnode) ([],pplan)
         |> Seq.map (update_goal gnds gnode)
      val gnds_ppseq = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs
    in Seq.map 
         (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
         gnds_ppseq 
    end;

  fun apply_localasms_tac_to_each_goal_rtechn in_wire out_wire (rt_name,tac_name) out_f tacf =
    let
      val (out_w,_) = out_wire;
      fun tac_appf rst0 = 
       case RState.get_inputs rst0 of 
          NONE => Seq.empty
        | SOME (_,gs) => apply_localasms_tac_to_each_goal_app (out_w,out_f) (tac_name,tacf rst0) gs rst0
    in id |> RTechn.set_name rt_name
          |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
          |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
          |> RTechn.set_atomic_appf tac_appf
    end;

  fun apply_allasms_tac_to_each_goal_app (wname,f) (tacnf,tac) gnodes rst = 
    let
      (* give a sequence of (new_goal_node list,pplan) *)
      fun update_goal gnds gnode (gs,pp) = (gnds @ (map (f gnode) gs),pp) 
      fun apply_tac gnode (gnds,pplan) =
          PPlanTac.apply_allasms_tac (tacnf,tac) (GNode.get_goal gnode) ([],pplan)
         |> Seq.map (update_goal gnds gnode)
      val gnds_ppseq = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs
    in Seq.map 
         (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
         gnds_ppseq 
    end;

  fun apply_allasms_tac_to_each_goal_rtechn in_wire out_wire (rt_name,tac_name) out_f tacf =
    let
      val (out_w,_) = out_wire;
      fun tac_appf rst0 = 
       case RState.get_inputs rst0 of 
          NONE => Seq.empty
        | SOME (_,gs) => apply_allasms_tac_to_each_goal_app (out_w,out_f) (tac_name,tacf rst0) gs rst0
    in id |> RTechn.set_name rt_name
          |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
          |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
          |> RTechn.set_atomic_appf tac_appf
    end;


  (* SOME STANDARD ISABELLE TACTICS AS TECHNIQUES *)

  fun simp_all_asm_full_on iw = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.asm_full_simp_tac (simpset rst) 1
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_allasms_tac_to_each_goal_rtechn iw ow ("simp_asm_full","simp_full (asm)") f simp_tacf
     end;

  fun simp_asm_full_on iw = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.asm_full_simp_tac (simpset rst) 1
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_asm_full","simp_full (asm)") f simp_tacf
     end;

  val simp_asm_full = simp_asm_full_on (mk_default_goal default_goal);

  val simp_no_asm = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.simp_tac (simpset rst) 1
         val iw = mk_default_goal default_goal
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_no_asm","simp (no_asm)") f simp_tacf
     end;

  fun simp_no_asm_changes_on iw = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = CHANGED (Simplifier.simp_tac (simpset rst) 1)
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_no_asm_changes","simp (no_asm)") f simp_tacf
     end;

  val simp_no_asm_changes = simp_no_asm_changes_on (mk_default_goal default_goal);

  val simp_no_asm_use = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.full_simp_tac (simpset rst) 1
         val iw = mk_default_goal default_goal
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_no_asm_use","simp (no_asm_use)") f simp_tacf
     end;

  val simp_asm_lr = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.asm_lr_simp_tac (simpset rst) 1
         val iw = mk_default_goal default_goal
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_no_asm_lr","simp (no_asm_lr)") f simp_tacf
     end;

  val simp_no_asm_simp = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = Simplifier.asm_simp_tac (simpset rst) 1
         val iw = mk_default_goal default_goal
         val ow = mk_default_goal simp_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("simp_no_asm_simp","simp (no_asm_simp)") f simp_tacf
     end;

  fun unfold_rtechn iw ow thms = 
     let fun simpset rst = (Simplifier.simpset_of (RstPP.get_ctxt rst))
         fun simp_tacf rst = unfold_tac thms (simpset rst)
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp simp_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("unfold","unfold") f simp_tacf
     end;

  fun auto_on iw = 
     let 
         fun auto_tac rst = Clasimp.auto_tac (RstPP.get_ctxt rst) 
         val ow = mk_default_goal auto_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp auto_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("auto","auto") f auto_tac
     end;

  val auto = auto_on (mk_default_goal default_goal);

  (* no output should be possible - should be handled by the evaluation *)
  fun blast inp_wire = 
     let 
         fun blast_tac rst = Blast.blast_tac (RstPP.get_ctxt rst) 1
         val ow = mk_default_goal default_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp safe_goal;
         val rtechn = apply_allasms_tac_to_each_goal_rtechn inp_wire ow ("blast","blast") f blast_tac
     in 
       rtechn |> RTechn.set_outputs WireNode.W.NSet.empty
     end;

  val safe = 
     let 
         fun safe_tac rst = Classical.safe_tac (RstPP.get_ctxt rst)
         val iw = mk_default_goal default_goal
         val ow = mk_default_goal safe_goal
         fun f old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                  |> GNode.set_gtyp safe_goal;
     in 
        apply_localasms_tac_to_each_goal_rtechn iw ow ("safe","safe") f safe_tac
     end;

  (* RESOLUTION *)

  fun tac_appf tacf rst0 = 
    case RState.get_inputs rst0 of 
          NONE => Seq.empty
        | SOME (_,gs) => tacf gs rst0

  (* gnodef :: GNode.T -> PPlan.T ->  (GNode.T list,PPlan.T) Seq.seq *)
  fun apply_tac wname gnodef rst =
    let
      fun apply_tac gnode (gnds,pplan) =
          gnodef gnode pplan
         |> Seq.map (fn (gs',pplan') => (gnds @ gs',pplan'))
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs
     in 
         Seq.map 
           (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
           (tac_appf gnds_ppseq rst)
     end;


  fun rule_wire in_wire out_wire th = 
    let
      val (wname,_) = out_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      fun set_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
      fun update_goal gnds gnode (gs,pp) = (gnds @ map (set_gnode gnode) gs,pp) 
      fun apply_tac gnode (gnds,pplan) =
          PPlan.apply_rule_thm th (GNode.get_goal gnode) pplan
         |> Seq.map (update_goal gnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name ("Resolution backward using thm " ^ (Thm.get_name_hint th))
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
         |> RTechn.set_atomic_appf app
    end;


  fun rule_dthm_wire in_wire out_wire dthm =
     rule_wire in_wire out_wire (DThm.finalthm_of dthm)
     |> RTechn.set_name ("Resolution backward using dthm " ^ (DThm.long_name_of dthm));


  fun new_asms old_goal new_goal pplan = 
    PPlan.new_asms pplan (PPlan.get_lasms pplan old_goal) new_goal
   |> Goaln.NSet.of_list;

  fun erule_dthm_wire (prem_wire,in_wire) (out_prem_wire,out_wire) dthm = 
    let
      val (wname,_) = out_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      fun set_gnode pp old_gnode new_goal = 
            GNode.upd_goal_only new_goal old_gnode
            |> GNode.set_gtyp gwire
            |> GNode.add_facts (out_prem_wire,new_asms (GNode.get_goal old_gnode) new_goal pp);
      fun update_goal gnds gnode (gs,pp) = (gnds @ map (set_gnode pp gnode) gs,pp) 

      fun apply_erule' fact goal (gs,pplan) =
        PPlan.apply_erule_thm (DThm.finalthm_of dthm) fact goal pplan
        |> Seq.map (fn (gs',pplan') => (gs' @ gs,pplan'))
      fun apply_erule fact (goals,pplan) = (* returns goal-list * pplan seq *)
        fold
         (fn g => Seq.maps (apply_erule' fact g))
         goals (* should really just be one *)
         (Seq.single ([],pplan))
      fun apply_tac gnode (gnds,pplan) =
        Goaln.NSet.fold
           (fn fact => Seq.maps (apply_erule fact))
           (GNode.lookup_facts prem_wire gnode)
           (Seq.single ([GNode.get_goal gnode],pplan))
         |> Seq.map (update_goal gnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name ("Resolution backward (erule) using dthm " ^ (DThm.long_name_of dthm))
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
         |> RTechn.set_atomic_appf app
    end;

  (* in_fact is an treated as an AND! *)
  fun frule_dthm_wire in_fact out_fact in_wire out_wire dthm = 
    let
      val (wname,_) = out_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      (* just add new facts *)
      fun set_gnode old_gnode new_facts = 
            GNode.upd_hyps_only_single (in_fact,(out_fact,Goaln.NSet.of_list new_facts))
                                        old_gnode
      fun update_goal gnds gnode (g,pp) = (gnds @ [set_gnode gnode g],pp) 
      fun apply_frule fact (gs,pplan) =
        PPlan.apply_frule_thm (DThm.finalthm_of dthm) fact pplan
        |> Seq.map (fn (g,pplan') => (g::gs,pplan'))
      fun apply_tac gnode (gnds,pplan) =
        (Goaln.NSet.fold
           (fn fact => Seq.maps (apply_frule fact))
           (GNode.lookup_facts in_fact gnode)
           (Seq.single ([],pplan)))
        |> Seq.map (update_goal gnds gnode)

      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name ("Resolution (frule) (restricted) backward using dthm " ^ (DThm.long_name_of dthm))
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
         |> RTechn.set_atomic_appf app
    end;


  (* resolve backwards from existing result *)
  (* prem_wire is OR wire *)
  fun bck_res_wire prem_wire in_wire out_wire  = 
    let
      val (wname,_) = out_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      (* may want to revisit this! *)
      fun set_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                       |> GNode.set_gtyp gwire
      fun update_goal gnds gnode (gs,pp) = (gnds @ map (set_gnode gnode) gs,pp) 
      fun apply_tac gnode (gnds,pplan) =
          Seq.maps
           (fn fact => PPlan.apply_res_bck fact (GNode.get_goal gnode) pplan)
           (Goaln.NSet.seq_of (GNode.lookup_facts prem_wire gnode))
         |> Seq.map (update_goal gnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],RState.get_pplan rst)); 
      fun set_output gnds = 
           (wname,GNode.GoalSet.of_list gnds) 
           |> GoalNode.G.NSet.single
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,pp) => RState.set_pplan pp rst |> set_output gnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name ("Resolution backward from fact")
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.single out_wire)
         |> RTechn.set_atomic_appf app
    end;

  (* SUBSTITUTIONS *)

  fun subst_thm_from_wire name in_wire out_wire cond_wire thm sym =
    let
      val (wname,_) = out_wire;
      val (cname,_) = cond_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      val cgwire = cond_wire |> snd |> FWire.get_goal;
      fun set_out_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                          |> GNode.set_gtyp gwire;
      fun set_cond_gnode old_gnode new_cond = GNode.upd_goal_only new_cond old_gnode
                                            |> GNode.set_gtyp cgwire;
      fun update_goal gnds cgnds gnode ((g,conds),pp) = 
           (gnds @ [set_out_gnode gnode g], cgnds @ map (set_cond_gnode gnode) conds,pp) 
      fun apply_tac gnode (gnds,cgnds,pplan) =
          Subst.apply_thm thm sym (GNode.get_goal gnode) pplan
         |> Seq.map (update_goal gnds cgnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],RState.get_pplan rst)); 
      fun set_output gnds cgnds =         
          GoalNode.G.NSet.of_list 
              [(wname,GNode.GoalSet.of_list gnds),
               (cname,GNode.GoalSet.of_list cgnds)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,cgnds,pp) => RState.set_pplan pp rst |> set_output gnds cgnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name name
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.of_list [out_wire,cond_wire])
         |> RTechn.set_atomic_appf app
    end;

  (* subst in fact *)
  fun subst_result_thm_from_wire name (prem_wire,in_wire) (new_facts_wire:BWire.name,out_wire) cond_wire thm sym =
    let
      val (cname,_) = cond_wire;
      val (iname,iws) = in_wire;
      val (out_name,_) = out_wire;
      (* val out_wire = (out_name,iws |> FWire.delete_fact prem_wire |> FWire.add_fact new_facts_wire); *)
      val cgwire = cond_wire |> snd |> FWire.get_goal;

      fun set_out_facts old_gnode new_facts = GNode.add_facts (new_facts_wire,Goaln.NSet.of_list new_facts) old_gnode;
      fun set_cond_gnode old_gnode new_cond = GNode.upd_goal_only new_cond old_gnode
                                            |> GNode.set_gtyp cgwire;
      fun update_goal gnds cgnds gnode ((facts,conds),pp) = 
           (gnds @ [set_out_facts gnode facts], cgnds @ map (set_cond_gnode gnode) conds,pp) 

      fun apply_one fact ((res,conds),pplan) = 
         Subst.apply_thm thm sym fact pplan
         |> Seq.map (fn ((nres,nconds),pplan') => ((nres::res,nconds @ conds),pplan'))        

      fun apply_tac gnode (gnds,cgnds,pplan) =
        (Goaln.NSet.fold
          (fn fact => Seq.maps (apply_one fact))
          (GNode.lookup_facts prem_wire gnode)
          (Seq.single (([],[]),pplan)))
         |> Seq.map (update_goal gnds cgnds gnode)

      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],RState.get_pplan rst)); 
      fun set_output gnds cgnds =         
          GoalNode.G.NSet.of_list 
              [(out_name,GNode.GoalSet.of_list gnds),
               (cname,GNode.GoalSet.of_list cgnds)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,cgnds,pp) => RState.set_pplan pp rst |> set_output gnds cgnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name name
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.of_list [out_wire,cond_wire])
         |> RTechn.set_atomic_appf app
    end;


  (* eq_wire is OR wire *)
  fun subst_eq_from_wire name eq_wire in_wire out_wire conds_wire sym = 
    let
      val (wname,_) = out_wire;
      val (cname,_) = conds_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      val cgwire = conds_wire |> snd |> FWire.get_goal;
      fun set_out_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                          |> GNode.set_gtyp gwire;
      fun set_cond_gnode old_gnode new_cond = GNode.upd_goal_only new_cond old_gnode
                                            |> GNode.set_gtyp cgwire;
      fun update_goal gnds cgnds gnode ((g,conds),pp) = 
          let (* (sometimes it seems) conds also include goal! *)
            val just_conds = filter (fn c => not (c=g)) conds
          in
           (gnds @ [set_out_gnode gnode g], cgnds @ map (set_cond_gnode gnode) just_conds,pp)
          end;
      fun apply_tac gnode (gnds,cgnds,pplan) =
          Seq.maps
           (fn eqname => Subst.apply eqname sym (GNode.get_goal gnode) pplan)
           (Goaln.NSet.seq_of (GNode.lookup_facts eq_wire gnode))
         |> Seq.map (update_goal gnds cgnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],RState.get_pplan rst)); 
      fun set_output gnds cgnds =         
          GoalNode.G.NSet.of_list 
              [(wname,GNode.GoalSet.of_list gnds),
               (cname,GNode.GoalSet.of_list cgnds)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,cgnds,pp) => RState.set_pplan pp rst |> set_output gnds cgnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name name
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.of_list [out_wire,conds_wire])
         |> RTechn.set_atomic_appf app
    end;

  fun subst_in_lhs_from_wire name eq_wire in_wire out_wire conds_wire sym = 
    let
      val (wname,_) = out_wire;
      val (cname,_) = conds_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      val cgwire = conds_wire |> snd |> FWire.get_goal;
      fun set_out_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                          |> GNode.set_gtyp gwire;
      fun set_cond_gnode old_gnode new_cond = GNode.upd_goal_only new_cond old_gnode
                                            |> GNode.set_gtyp cgwire;
      fun update_goal gnds cgnds gnode ((g,conds),pp) = 
           (gnds @ [set_out_gnode gnode g], cgnds @ map (set_cond_gnode gnode) conds,pp) 
      fun apply_tac gnode (gnds,cgnds,pplan) =
          Seq.maps
           (fn eqname => Subst.apply_at_lhs eqname sym (GNode.get_goal gnode) pplan)
           (Goaln.NSet.seq_of (GNode.lookup_facts eq_wire gnode))
         |> Seq.map (update_goal gnds cgnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],RState.get_pplan rst)); 
      fun set_output gnds cgnds =         
          GoalNode.G.NSet.of_list 
              [(wname,GNode.GoalSet.of_list gnds),
               (cname,GNode.GoalSet.of_list cgnds)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,cgnds,pp) => RState.set_pplan pp rst |> set_output gnds cgnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name name
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.of_list [out_wire,conds_wire])
         |> RTechn.set_atomic_appf app
    end;

  fun subst_in_rhs_from_wire name eq_wire in_wire out_wire conds_wire sym = 
    let
      val (wname,_) = out_wire;
      val (cname,_) = conds_wire;
      val gwire = out_wire |> snd |> FWire.get_goal;
      val cgwire = conds_wire |> snd |> FWire.get_goal;
      fun set_out_gnode old_gnode new_goal = GNode.upd_goal_only new_goal old_gnode
                                          |> GNode.set_gtyp gwire;
      fun set_cond_gnode old_gnode new_cond = GNode.upd_goal_only new_cond old_gnode
                                            |> GNode.set_gtyp cgwire;
      fun update_goal gnds cgnds gnode ((g,conds),pp) = 
           (gnds @ [set_out_gnode gnode g], cgnds @ map (set_cond_gnode gnode) conds,pp) 
      fun apply_tac gnode (gnds,cgnds,pplan) =
          Seq.maps
           (fn eqname => Subst.apply_at_rhs eqname sym (GNode.get_goal gnode) pplan)
           (Goaln.NSet.seq_of (GNode.lookup_facts eq_wire gnode))
         |> Seq.map (update_goal gnds cgnds gnode)
      fun gnds_ppseq gnodes rst = 
        GNode.GoalSet.fold 
          (fn gn => Seq.maps (apply_tac gn))
          gnodes
          (Seq.single ([],[],RState.get_pplan rst)); 
      fun set_output gnds cgnds =         
          GoalNode.G.NSet.of_list 
              [(wname,GNode.GoalSet.of_list gnds),
               (cname,GNode.GoalSet.of_list cgnds)]
           |> RState.set_outputs 
      fun app rst =   
         Seq.map 
           (fn (gnds,cgnds,pp) => RState.set_pplan pp rst |> set_output gnds cgnds) 
           (tac_appf gnds_ppseq rst)
    in 
      id |> RTechn.set_name name
         |> RTechn.set_inputs (WireNode.W.NSet.single in_wire)
         |> RTechn.set_outputs (WireNode.W.NSet.of_list [out_wire,conds_wire])
         |> RTechn.set_atomic_appf app
    end;
end;

structure RTechnEnv : RTECHN_ENV = RTechnEnv_DB;

