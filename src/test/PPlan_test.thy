theory PPlan_test                                                 
imports         
  Main                              
  "../build/PPlan"                                                                                                                                                                  
begin


ML{*
val (g,pp) = PPlan.conj_string_at_top ("g1","P ==> (Q \<longrightarrow> P)") (PPlan.init @{context});
val (g',pp') = PPlan.apply_rule_thm @{thm "impI"} "g1" pp |> Seq.list_of |> hd;
PPlan.print pp';
*}

ML{*
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
      val writelist = map writeln
      val _ = writelist g_lasms
    in
      Seq.maps (fn (subgoals, p2) => (writelist subgoals;compose (([]) @ L) p2))
               (Prf.apply_resol_bck f g p)
    end;



(* th is a theorem that concludes in proving g within the same context
as G (or a unifyable one). This function integrates the theorem's
result into the proof plan by inserting the theorem, applying it, and
resolving away the common context. Common context is figured out by
goal ordering. IMPROVE: does not fail gracefully! raises
subscript, or empty seq if context is incorrect. *)
exception bug_exp of string * (Prf.gname * Prf.T * Thm.thm);


(* for composition with results from all assumptions *)
fun compose_all_result_th g p2 th = 
    let 
      val th2 = th |> Thm.forall_elim_vars 0
                   |> Thm.forall_intr_frees
                   |> Drule.forall_intr_vars
                   |> Thm.put_name_hint g;

      val (f,p3) = Prf.insert_thm th2 p2;
      val _ = Syntax.string_of_term (PPlan.get_context p2) (prop_of th2) |> writeln
          
      val (f_r as (_,(f_cxn,f_cx))) = Prf.get_result p3 f;
      val (g_r as (_,(g_cxn,g_cx))) = Prf.get_result p3 g;
      
      val g_aasms = Goaln.NSet.list_of (Cx.get_aasms g_cx);
      val f_aasms = Goaln.NSet.list_of (Cx.get_aasms f_cx);
      
      val f_asms = List.drop (f_aasms, (length f_aasms) - (length g_aasms));
      val ((f2,sgs),p4) = Prf.lift_and_show_above f f_asms g p3;
      fun comp_list [] x = []
       |  comp_list x [] = []
       |  comp_list a b = a ~~ b;
    in
      (* (Seq.of_list o Seq.list_of) *)
        (Seq.maps 
           (fn (subgoals,p5) => (Seq.map (pair subgoals)
                                         (compose (comp_list g_aasms sgs) p5)))
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
*}

ML{*
apply_allasms_tac ("dummy",(fn th => Seq.single th)) "d" (["e"],pp') |> Seq.pull |> the |> fst;
*}
ML{*
val (g'',pp'') = PPlanTac.apply_allasms_tac ("dummy",(fn th => Seq.single th)) "d" (["e"],pp') |> Seq.pull |> the |> fst;
*}

ML{*
val (g'',pp'') = apply_allasms_tac ("assume",assume_tac 1) "d" (["g1a","e"],pp') |> Seq.list_of |> hd; 
PPlan.print pp';
*}



end



