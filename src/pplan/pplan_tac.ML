(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  
    Tactics lifted to operations on proof plans. 
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
signature PPLAN_TAC
= sig

exception bug_exp of string * (Prf.gname * Prf.T * Thm.thm);

(* basic tools *)
val apply_allasms_tac : (* include all asms *)
    (* this is a description of the tactic, so that it can be 
       parsed and re-applied if needed *)
    string
    * (Thm.thm -> Thm.thm Seq.seq) (* this is the tactic *)
    -> Prf.gname -> (Prf.gname list * Prf.T) -> (Prf.gname list * Prf.T) Seq.seq

val apply_localasms_tac : (* include local asms *)
    string * (Thm.thm -> Thm.thm Seq.seq) ->
    Prf.gname -> (Prf.gname list * Prf.T) -> (Prf.gname list * Prf.T) Seq.seq

(* internal functions for recursive resolution *)
val compose :
    (Prf.gname * Prf.gname) list -> Prf.T -> Prf.T Seq.seq
val compose_local_result_th :
    Prf.gname ->
    Prf.T -> Thm.thm -> (Prf.gname list * Prf.T) Seq.seq

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure DB_PPlanTac =
struct

(* f has the same context as g, so do recursive resolution to prove g
by f, solving the subgoals of f against the assumptions of g. *)
(* IMRPOVE: does not fail gracefully! : raises exception or gives empty seq *)
fun compose [] p = Seq.single p
  | compose ((f, g)::L) p = 
    let 
      val (f_r as (_,(f_cxn,f_cx))) = Prf.get_result p f; (* asms *)
      val (g_r as (_,(g_cxn,g_cx))) = Prf.get_result p g; (* new subgoals *)

      (* f_lasms are the further assumptions to be composed with subgoals, 
         if in the same context as assumption, there will be none. *)
      (* g_lasms are used to solve the subgoals coming from f's assms *)
      val (f_lasms,g_lasms) = 
          if Cx.cxname_eq (f_cxn,g_cxn) then ([],[])
          else 
            (Goaln.NSet.list_of (Cx.get_lasms f_cx), 
             Goaln.NSet.list_of (Cx.get_lasms g_cx))
      (* hack by GG - not sure if it is correct *)
      fun comp_list [] x = []
       |  comp_list x [] = []
       |  comp_list a b = a ~~ b;
    in
(*      Seq.maps (fn (subgoals, p2) => compose ((g_lasms ~~ subgoals) @ L) p2)
               (Prf.apply_resol_bck f g p) *)
      Seq.maps (fn (subgoals, p2) => compose ((comp_list g_lasms subgoals) @ L) p2)
               (Prf.apply_resol_bck f g p)
    end;

(* remove all assumptions of subgoal i *)
fun thin_all i th = 
    let 
      val th2 = Thm.forall_elim_vars 0 th;
      val t = Logic.get_goal (Thm.prop_of th2) i;
    in (Logic.mk_implies (t, Logic.strip_imp_concl t)) 
         |> Thm.cterm_of (Thm.theory_of_thm th)
         |> Thm.trivial
         |> Thm.assumption 1
         |> Seq.hd 
         |> Drule.forall_intr_vars
    end;

(* th is a theorem that concludes in proving g within the same context
as G (or a unifyable one). This function integrates the theorem's
result into the proof plan by inserting the theorem, applying it, and
resolving away the common context. Common context is figured out by
goal ordering. IMPROVE: does not fail gracefully! raises
subscript, or empty seq if context is incorrect. *)
exception bug_exp of string * (Prf.gname * Prf.T * Thm.thm);

(* for composing results from only local assumptions *)
fun compose_local_result_th g p2 th = 
    let 
      val th2 = th |> Thm.forall_elim_vars 0
                   |> Thm.forall_intr_frees
                   |> Drule.forall_intr_vars
                   |> Thm.put_name_hint g;

      val (f,p3) = Prf.insert_thm th2 p2; 
          
      val (f_r as (_,(f_cxn,f_cx))) = Prf.get_result p3 f;
      val (g_r as (_,(g_cxn,g_cx))) = Prf.get_result p3 g;
      
      val g_lasms = Goaln.NSet.list_of (Cx.get_lasms g_cx);
      val f_lasms = Goaln.NSet.list_of (Cx.get_lasms f_cx);
      
      val f_asms = List.drop (f_lasms, (length f_lasms) - (length g_lasms));
      val ((f2,sgs),p4) = Prf.lift_and_show_above f f_asms g p3;
    in
      (* (Seq.of_list o Seq.list_of) *)
        (Seq.maps 
           (fn (subgoals,p5) => (Seq.map (pair subgoals)
                                         (compose (g_lasms ~~ sgs) p5)))
           (Prf.apply_resol_bck f2 g p4))
    end;

(* for composition with results from all assumptions *)
fun compose_all_result_th g p2 th = 
    let 
      val th2 = th |> Thm.forall_elim_vars 0
                   |> Thm.forall_intr_frees
                   |> Drule.forall_intr_vars
                   |> Thm.put_name_hint g;

      val (f,p3) = Prf.insert_thm th2 p2; 
          
      val (f_r as (_,(f_cxn,f_cx))) = Prf.get_result p3 f;
      val (g_r as (_,(g_cxn,g_cx))) = Prf.get_result p3 g;
      
      val g_aasms = Goaln.NSet.list_of (Cx.get_aasms g_cx);
      val f_aasms = Goaln.NSet.list_of (Cx.get_aasms f_cx);
      
      val f_asms = List.drop (f_aasms, (length f_aasms) - (length g_aasms));
      val ((f2,sgs),p4) = Prf.lift_and_show_above f f_asms g p3;
    in
      (* (Seq.of_list o Seq.list_of) *)
        (Seq.maps 
           (fn (subgoals,p5) => (Seq.map (pair subgoals)
                                         (compose (g_aasms ~~ sgs) p5)))
           (Prf.apply_resol_bck f2 g p4))
    end;

(* apply a non-assumption affecting Isabelle tactic *)
fun apply_allasms_tac (str, tac) g (ns,p) = 
    let 
      val p2 = Prf.start_meth [g] p;
      val goalthm = Prf.get_fixed_full_goal_thm p g;
    in (tac goalthm)
       |> Seq.map (fn th => th RS Drule.protectD)
       |> Seq.maps (compose_all_result_th g p2)
       |> Seq.map (fn (_,p3) => Prf.end_meth 
          str [] [g] p3 p)
       |> Seq.map (fn (ns',p4) => (ns' @ ns,p4))
    end;

(* Apply to a theorem, but give only local assumptions *)
fun apply_localasms_tac (str, tac) g (ns,p) = 
    let 
      val p2 = Prf.start_meth [g] p;
      val goalthm = Prf.get_fixed_local_goal_thm p g;
    in (tac goalthm)
       |> Seq.map (fn th => th RS Drule.protectD)
       |> Seq.maps (compose_local_result_th g p2)
       |> Seq.map (fn (_,p3) => Prf.end_meth
          str [] [g] p3 p)
       |> Seq.map (fn (ns',p4) => (ns' @ ns,p4))
    end;

end; (* struct dtac *)

structure PPlanTac : PPLAN_TAC = DB_PPlanTac;

(*
(* apply the resulting theorem from a tactic that affects
assumptions. Will recreate the new context/assumtions.  Note: this
will bloat the context and mangle the meta-variable - not dangerously,
but certainly confusingly. *)
fun res_asm_result_th g p2 th = 
    let 
      val th2 = th |> Drule.forall_elim_vars 0
                   (* remove assumptions - we only care about final result *)
                   |> (Seq.hd o (REPEAT (Tactic.etac Drule.thin_rl 1)))
                   |> Drule.forall_intr_frees
                   |> Drule.forall_intr_vars
                   |> Thm.put_name g;
      val (f,p3) = Prf.insert_thm th2 p2; 
    in Prf.apply_resol_bck f g p3 end;

(* apply an assumption affecting Isabelle tactic (will re-create the 
   context) *)
fun apply_asm_tac (pretty, tac) g p = 
    let 
      val p2 = Prf.start_meth [g] p;
      val goalthm = Prf.get_fixed_full_goal_thm p g;
    in (tac goalthm)
       |> Seq.maps (fn th => th RS Drule.protectD)
       |> Seq.maps (res_asm_result_th g p2)
       |> Seq.map (fn (_,p3) => Prf.end_meth (Pretty.string_of pretty) 
                                             [] [g] p3 p)
    end;
*)
