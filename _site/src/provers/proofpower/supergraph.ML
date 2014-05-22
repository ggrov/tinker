structure SuperGraph = 
struct
 
 local open 
   Supertac_11_1a7 
 in
 local open subprog_call rsg_preds cz_blocks fp_utils hol_term_utils hol_rule_utils
     z_term_utils z_rule_utils setmem conversionals_tacticals annotations
     end_proof cn_cz_thms cn_cz_utils structure_proof
 in

 (* some ps combinators *)
   infixr 6 PS_THEN;
   val op PS_THEN = PSComb.THENG;
   val PS_LIFT =  PSComb.LIFT; 
   val PS_NEST = PSComb.NEST;
  (* fun PS_NEST _ a = a ;*)

    (* setup debug printing *)
    val _ = DebugHandler.set_debug_flag DebugHandler.SUPERGRAPH;
    val SG_debug = DebugHandler.debug_print DebugHandler.SUPERGRAPH;
    val _ = SG_debug "supergraph is super";
    


   (* structure_tac *)
   (*
   structure_proof.structure_tac
   review_structure_tac_result_tac
   end_proof.end_proof_tac
   hints_to_top_tac)
   
   
   - initial_strip_tac NEXT
   - insert_vc_origin_hint_tac NEXT  
   - structure_tac0 NEXT
   - remove_block_pred_asms_tac;
   
   Combinator: t1 NEXT t2, both t1 and t2 are ROBUST, 
   but requires at least one of them succeed and result in changes of goal.
   also remove redundent asms and true in the hyp list.
   

   code:
   if the top_symnol is => 
   	strip => and /\ in the asm, e.g. A /\ B => C |- [A, B] C
   or  z_forall, then rewrite z-forall to A /\ B => C, then strip => and /\
   
   - insert_vc_origin_hint_tac
     insert some term into hyps list, as scheme predicate    
     
   - remove_block_pred_asms_tac
   
   *)

 (* tactics in supertacs *)

 (* section: structure_tac 
  Classified types: A, C, E, F, G, D, B, psedo D; but i think TYPE B and psedo D are NOT captured.
 
  A: true, should be terminated
 *)
   
 (* 
   please note that this file can only be loaded in the top ml level, as it might cause some weired problems 
   when use_files is called nestly
 *)
  
     val _ = PPIntf.add_default_tacs 
     	[("super_tac", super_tac)
     	 ];


(* predicate for goaltypes in supertacs *)
   fun top_symb_z_true (_,g) = is_z_true g;
   fun top_symb_z_forall (_, g) = is_z_%forall% g;
   fun top_symb_imp (_, g) = is_%implies% g;
   fun has_vc_orgin_hints (ps, g) =  is_non_empty(structure_proof0.vc_block_types (ps,g));

   val gt = "any"
   val gt_top_z_forall  = "top_symb_z_forall"
   val gt_top_imp       = "top_symb_imp"
   val gt_top_z_true    = "top_symb_z_true"

   val gt_has_vc_orgin_hints  = "has_vc_orgin_hints"
   val gt_has_no_vc_orgin_hints = "not has_vc_orgin_hints"
  
   val gt_is_C_conjecture0 = "is_C_conjecture0"
   val gt_is_D_conjecture0 = "is_D_conjecture0"
   val gt_is_E_conjecture0 = "is_E_conjecture0"
   val gt_is_F_conjecture0 = "is_F_conjecture0"
   val gt_is_G_conjecture0 = "is_G_conjecture0"
(* these gts are not registered *)
   val gt_is_PD_conjecture0 = "_is_C_conjecture0"
   val gt_is_B_conjecture0 = "is_B_conjecture0"

   val _ = SimpleGoalTyp.add_default_GTs
        [(gt_top_z_true, top_symb_z_true),
         (gt_top_z_forall, top_symb_z_forall),
         (gt_top_imp, top_symb_imp),
         (gt_has_vc_orgin_hints, has_vc_orgin_hints),
         
         (gt_is_C_conjecture0, structure_proof0.is_C_conjecture0),
         (gt_is_D_conjecture0, structure_proof0.is_D_conjecture0),
         (gt_is_E_conjecture0, fn x => (structure_proof0.is_E_conjecture0 x) andalso (not ((structure_proof0.is_A_conjecture0 x)))),
         (gt_is_F_conjecture0, structure_proof0.is_F_conjecture0),
         (gt_is_G_conjecture0, structure_proof0.is_G_conjecture0)
        ]

   val str_id_tac                = "id_tac"
   val str_merger_tac            = "merger"
   val str_splitter_tac          = "splitter"

   val str_initial_strip_tac     = "initial_strip_tac"
   val str_z_forall_tac          = "z_forall_tac"
   val str_and_split_implies_tac = "and_split_implies_tac"
   val str_insert_vc_origin_hint_tac = "insert_vc_origin_hint_tac"
   val str_insert_dummy_hint_tac =  "insert_dummy_hint_tac"
   val str_insert_vc_hint_tac = "insert_vc_hint_tac"
   val str_structure_tac0 = "structure_tac0"
   val str_A_tac0 = "A_tac0"
   val str_E_tac0 = "E_tac0"
   val str_C_tac0 = "C_tac0"
   val str_D_tac0 = "D_tac0"
   val str_F_tac0 = "F_tac0"
   val str_G_tac0 = "G_tac0"
   val str_CDFG_tac0 = "CDFG_tac0"
   val str_z_strip_tac = "z_strip_tac"

 (* refactor tactics in supertacs *)
  val insert_dummy_hint_tac = insert_clawz_hint1_tac "Supertac:VC_Origin:Empty_Block_List"
  fun insert_vc_hint_tac (ps, g)=  
    let val Tys =  structure_proof0.vc_block_types (ps,g) in
      insert_clawz_hint2_tac ("Supertac:VC_Origin:Block_List", mk_z_tuple Tys) (ps, g) end

   val _ = PPIntf.add_default_tacs 
      [
       (str_id_tac, id_tac),
       	(str_splitter_tac,id_tac),
       	(str_merger_tac, id_tac),
(*  initial_strip_tac
   
   describtion:
   top_symbol ==> and forall_z quantifier 
   |- rewite forall_z to  hyp /\ ... /\ hyp => concl then [hyp,.. hyp], concl
   please note if there are nested => or z-forall in the conclusion, it won't handle the nested part *)
       (str_initial_strip_tac, initial_strip_tac),
(* instaintiate the z forall quantifier  and put the all the type and conds as implication *)
       (str_z_forall_tac, z_%forall%_tac),
(* split the top imp then elim /\ in the hyps *)
       (str_and_split_implies_tac, %and%_split_%implies%_tac),
(* Inserts a hint for the analyst, indicating which Simulink blocks are       *)
(* covered by the current VC.  This is done by subtracting the blocks         *)
(* mentioned in the VC's asms (after 'initial_strip_tac') from those          *)
(* mentioned in the VC's concl.                                               *)
       (str_insert_vc_origin_hint_tac, insert_vc_origin_hint_tac),
       (str_insert_dummy_hint_tac, insert_dummy_hint_tac),
       (str_insert_vc_hint_tac, insert_vc_hint_tac),
       (str_z_strip_tac, z_strip_tac),
       (str_E_tac0, structure_proof0.E_tac0),
       (str_CDFG_tac0, structure_proof0.CDFG_tac0)
      ]

   val id_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_id_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_id_tac));

   val splitter_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_splitter_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_splitter_tac));

   val merger_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_merger_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_merger_tac));
  
   val z_forall_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_z_forall_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_z_forall_tac));
  
   val and_split_implies_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_and_split_implies_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_and_split_implies_tac));

   val insert_dummy_hint_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_insert_dummy_hint_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_insert_dummy_hint_tac));

   val insert_vc_hint_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_insert_vc_hint_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_insert_vc_hint_tac));

   val initial_strip_ps = 
    ((PS_LIFT ([gt],[gt_top_z_forall, gt_top_imp]) splitter_rt) 
      PS_THEN
    (PS_LIFT ([gt_top_imp],[gt]) (and_split_implies_rt))
      PS_THEN
    (PS_LIFT ([gt_top_z_forall],[gt_top_imp]) (z_forall_rt))
      PS_THEN
    (PS_LIFT ([gt_top_imp],[gt]) (and_split_implies_rt))
      PS_THEN
    (PS_LIFT ([gt,gt],[gt]) merger_rt))
    |> PS_NEST str_initial_strip_tac

  val insert_vc_origin_hint_ps = 
    ((PS_LIFT ([gt], [gt_has_vc_orgin_hints, gt_has_no_vc_orgin_hints]) splitter_rt)
      PS_THEN
    (PS_LIFT ([gt_has_vc_orgin_hints], [gt]) insert_vc_hint_rt)
      PS_THEN
    (PS_LIFT ([gt_has_no_vc_orgin_hints], [gt]) insert_dummy_hint_rt)
      PS_THEN
    (PS_LIFT ([gt, gt], [gt]) merger_rt))
     |> PS_NEST str_insert_vc_origin_hint_tac

   val z_strip_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_z_strip_tac)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_z_strip_tac));
  
   val E_tac0_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_E_tac0)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_E_tac0));

   val CDFG_tac0_rt = RTechn.id
            |> RTechn.set_name (RT.mk str_CDFG_tac0)
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_CDFG_tac0));

   val dummy_D_pseudo_tac0_rt = RTechn.id
            |> RTechn.set_name (RT.mk "dummy_D_pseudo_tac0")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_id_tac));
  
   val dummy_B_tac0_rt = RTechn.id
            |> RTechn.set_name (RT.mk "dummy_B_tac0")
            |> RTechn.set_atomic_appf (RTechn.Tactic (RTechn.TAllAsm, str_id_tac));

  val A0_ps = (PS_LIFT ([gt_top_z_true], []) z_strip_rt)|> PS_NEST str_A_tac0
  val B0_ps = (PS_LIFT ([gt_is_B_conjecture0], [gt]) dummy_B_tac0_rt)
  val PD0_ps = (PS_LIFT ([gt_is_PD_conjecture0], [gt]) dummy_D_pseudo_tac0_rt)
  val E0_ps =  (PS_LIFT ([gt_is_E_conjecture0], [gt]) E_tac0_rt)|> PS_NEST str_E_tac0

 (* to be refined, not true *)
  val C0_ps =  (PS_LIFT ([gt_is_C_conjecture0], [gt]) CDFG_tac0_rt)|> PS_NEST str_C_tac0
  val D0_ps =  (PS_LIFT ([gt_is_D_conjecture0], [gt]) CDFG_tac0_rt)|> PS_NEST str_D_tac0
  val F0_ps =  (PS_LIFT ([gt_is_F_conjecture0], [gt]) CDFG_tac0_rt)|> PS_NEST str_F_tac0
  val G0_ps =  (PS_LIFT ([gt_is_G_conjecture0], [gt]) CDFG_tac0_rt)|> PS_NEST str_G_tac0

  val structure_ps = 
    ((PS_LIFT ([gt], [gt_top_z_true, gt_is_C_conjecture0, gt_is_D_conjecture0,
                      gt_is_F_conjecture0, gt_is_G_conjecture0,
                      gt_is_B_conjecture0, gt_is_PD_conjecture0, gt_is_E_conjecture0]) 
               splitter_rt)
      PS_THEN
(* in the case of A type, it should be sloved immediately *)
    A0_ps
      PS_THEN
(* C *)
    C0_ps
      PS_THEN
(* E *)
    E0_ps
      PS_THEN
(* F *)
    F0_ps
      PS_THEN
(* G *)
    G0_ps
      PS_THEN
(* D *)
    D0_ps
      PS_THEN
(* B, don't think it's usefull *)
    B0_ps
      PS_THEN
(* pseudo D, don't think it's usefull *)
    PD0_ps
      PS_THEN
    (PS_LIFT ([gt,gt,gt,gt,gt,gt,gt], [gt]) merger_rt))
     |> PS_NEST str_structure_tac0

  val top_ps = initial_strip_ps PS_THEN insert_vc_origin_hint_ps PS_THEN structure_ps
  
  val test_ps1 = (PS_LIFT ([gt],[gt]) splitter_rt) 
  val test_ps2 = (PS_LIFT ([gt],[gt_top_imp]) splitter_rt) 

   val path = "/Users/yuhuilin/Desktop/"
   fun write_dot ps name = PSGraph.PSTheory.write_dot (path ^ name) ( PSGraph.get_graph (ps PSGraph.empty));
  (* 
   val _ = write_dot latest "graph.dot";

   val _ = write_dot initial_strip_ps "grainitial_strip_psph.dot";
   val _ = write_dot insert_vc_origin_hint_ps "insert_vc_origin_hint_ps.dot";
   val _ = write_dot structure_ps "structure_ps.dot";
   *)
   
 end (* end of local open the second level supertac *)
 end (* end of local open the top level supertac *)
end; (* end of struct *)

