(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:
    Reasoning techniques for the managing of proving lemmas, including
    conjecturing and notions of subspace. Corresponds to lemma
    calculation.
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

val g_counter_examples_flag = Unsynchronized.ref false;

signature CONJ_RTECHN =
sig
  exception conj_exp of string
  (* val prove_as_lemma : RTechn.ruleset * RTechn.T -> RTechn.ruleset * RTechn.T *)
  val prove_as_lemma : (theory -> RTechnComb.graph * theory) -> theory -> RTechnComb.graph * theory

(*  val conj_critic : RTechnEnv.RTechn.T -> (* prove this method *)
                    RTechnEnv.RTechn.T -> (* then this on failure *)
                    RTechnEnv.RTechn.T (* resulting method *)
*)
end;

structure ConjRTechn : CONJ_RTECHN
= struct 

  structure Wire = RState.Wire;

  exception conj_exp of string

  type appinfo = LemmaConjLib.appinfo

(*  local open RTechnEnv; in *)

  (* for use between direct proof and counter example *)
  structure CEx_Appinfo_Ctx = 
  struct
    type conjd = (appinfo * Term.term) Symtab.table 

    exception no_appinfo_ex of string; (* not sure is required *)

    fun get_el g tab = case Symtab.lookup tab g of
                        NONE => raise no_appinfo_ex ("goal not in cex_appdata: " ^ g)
                      | SOME v => v
    val add_el = Symtab.update ;
    val delete_el =  Symtab.delete_safe;

    structure Ctxt = Proof_Data(struct type T = conjd fun init _ = Symtab.empty end)
    
    fun get g rst = get_el g (Ctxt.get (RState.get_ctxt rst));

    val add = RState.update_ctxt o Ctxt.map o add_el;

    val del = RState.update_ctxt o Ctxt.map o delete_el;

  end (* structure *);

  (* For use when details on pplan *)
  structure Appinfo_Ctx = 
  struct
    type conjd = (appinfo * PPlan.gname * bool Unsynchronized.ref) Symtab.table 

    exception no_appinfo_ex of string; (* not sure is required *)
    fun get_el g tab = case Symtab.lookup tab g of
                        NONE => raise no_appinfo_ex ("goal not in appdata: " ^ g)
                      | SOME v => v
    val add_el = Symtab.update ;
    val delete_el =  Symtab.delete_safe;

    structure Ctxt = Proof_Data(struct type T = conjd fun init _ = Symtab.empty end)
    
    fun get g rst = get_el g (Ctxt.get (RState.get_ctxt rst));

    val add = RState.update_ctxt o Ctxt.map o add_el;

    val del = RState.update_ctxt o Ctxt.map o delete_el;

    fun get_proved_var g rst = let val (_,_,p) = get g rst in p end;

  end (* structure *);


(*
   The wires
*)

val goal_not_cc = RState.Wire.of_string "goal.not_cc";
val goal_conj = RState.Wire.of_string "goal.conj";
val goal_cond = RState.Wire.of_string "goal.cond";
val goal_not_trivial = RState.Wire.of_string "goal.not_trival";
val goal_wire = RState.Wire.of_string "goal";
val result_conj = RState.Wire.of_string "result.conj";


(* 
   Prove lemma directly reasoning technique (which actually includes conjecturing!)
*)

 (* fails if any conditions *)
 fun apply_lemmathm appinfo conj_name_thm g rst = 
    let val dthm = LemmaConjLib.mk_dthm (RstPP.get_ctxt rst) appinfo conj_name_thm
        val newseq = PPlan.apply_rule_thm (DThm.finalthm_of dthm) g (RState.get_pplan rst) (* (ng,pplan) sequence *)
        (* ensures no subgoals: alternative is to allow conditions (and prove separately) *)
        fun no_gs ([],_) = true
          | no_gs   _    = false
    in 
      Seq.map (fn (_,ppl) => rst |> RState.set_pplan ppl 
                                 |> RState.remove_single_name g) 
              (Seq.filter no_gs newseq) 
    end;

  (* make conjectures from a goal *)
  fun conj_from_gname rst gname = 
      let 
        val ptab = Cx.get_fixed_trm_ps (RstPP.get_cx rst gname);
        val sgterm = RstPP.goal_concl rst gname;
      in LemmaConjLib.conjs (RState.get_pplan rst) ptab sgterm end;

  (* conjecture and try direct proof for one goal *)
  fun conj_and_try_proof_one_goal g rst = 
      Seq.maps 
        (fn (appinfo, (ptab2,t)) => 
              let 
                val (prfs,status) = Conjdb_CtxtInfo.lookup_rst rst t
              in case status of 
                   ConjecturedbLib.ConjStatus_false _ => Seq.empty
                 | ConjecturedbLib.ConjStatus_failed => Seq.empty
                 | ConjecturedbLib.ConjStatus_in_progress => 
                   (* FIXME: register as delayed proof *)
                   raise conj_exp "not re-implemented at the moment"
                   (* the lookup function may actually have found a proof *)
                 | ConjecturedbLib.ConjStatus_unknown => 
                      let val app = Seq.maps (fn (n,(th,_)) => apply_lemmathm appinfo (n,th) g rst) (Seq.of_list prfs) in
                         case (Seq.pull app) of
                           NONE => rst |> RState.remove_single_name g
                                       |> RState.add_names_to_wire goal_not_trivial (Goaln.NSet.single g)
                                       |> CEx_Appinfo_Ctx.add (g,(appinfo,t))
                                       |> Seq.single
                         | SOME _ => app
                      end
              end)
          (conj_from_gname rst g);

fun apply_direct_proof_goal_app rst = 
      Goaln.NSet.fold
        (fn g => Seq.maps (conj_and_try_proof_one_goal g))
        (RState.get_names_of_wire rst goal_wire)
        (Seq.single rst);

val direct_proof_rtechn =
  RTechn.id 
     |> RTechn.set_name "apply direct proof"
     |> RTechn.set_inputs (RState.Wire.NSet.single goal_wire)
     |> RTechn.set_outputs (RState.Wire.NSet.single goal_not_trivial)
     |> RTechn.set_atomic_appf apply_direct_proof_goal_app;  

(*
  conjecturing technique (not really actually) 
   FIXME: this will only work when applied after direct proof!
     - alternative: redo work from conjecturing (and fail if direct proof succeeds?
     - then apply 
*)
fun conj_one_goal g rst =
  let 
     val (a,t) = CEx_Appinfo_Ctx.get g rst
     val (conjname,rst2) = RstPP.new_conj_at_top ("lem_a", t) rst
  in 
     rst2 |> RState.add_names_to_wire goal_conj (Goaln.NSet.single conjname)
          |> CEx_Appinfo_Ctx.del g
          |> Appinfo_Ctx.add (g,(a,conjname,Unsynchronized.ref false))
  end;

fun conj_app rst = 
     rst |> Goaln.NSet.fold conj_one_goal (RState.get_names_of_wire rst goal_not_trivial) 
         |> Seq.single;

(* not really - only adds to gname *)
val conjecture_rtechn =
  RTechn.id 
     |> RTechn.set_name "conjecture added to pplan"
     |> RTechn.set_inputs (RState.Wire.NSet.single goal_not_trivial)
     |> RTechn.set_outputs (RState.Wire.NSet.of_list [goal_not_trivial,goal_conj])
     |> RTechn.set_atomic_appf conj_app;    
 

(*
  counter example reasoning technique
*)

(* fixme: note sure if this is really the case 
   -> should this also apply when we cannot prove it? *) 
fun note_failed_lemma t rst = 
      let val _ = (* for debugging print out lemmas we are thinking about *)
              if !Toplevel.debug then
                    Pretty.writeln 
                    (Pretty.block [Pretty.str "Failed to prove: ", 
                                   Trm.pretty (RstPP.get_ctxt rst) t,
                                   Pretty.str ""])
              else ()
                    (* we have failed, so make a note not to try again *)
      in (Conjdb_CtxtInfo.insert_failed_rst t rst; Seq.empty) end;

fun note_failed_goal rst g = 
  note_failed_lemma (RstPP.goal_concl rst g) rst;

fun count_ex_app rst = 
  let
    fun get_term gname = RstPP.goal_concl rst gname 
    fun check_goal gname = 
       is_some (CounterExCInfo.timed_quickcheck_term 
                     (RstPP.get_ctxt rst) (CounterExCInfo.default_codegen_params, []) 
                     (Trm.change_vars_to_fresh_frees (get_term gname)) (Time.fromSeconds 1))
    val check_all = 
      Goaln.NSet.fold
        (fn g => fn (good,bad) => 
            if check_goal g
              then (g::good,bad)
              else (good,bad))
        (RState.get_names_of_wire rst goal_conj)
        ([],[])  
   in 
      if (null o snd) check_all
       then rst |> RState.move_wire_to_wire goal_conj goal_not_cc
                |> Seq.single
       else (* fail and *) ((map (note_failed_goal rst) (snd check_all)) ; Seq.empty) 
   end;

val counter_example_check_rtechn =
  RTechn.id 
     |> RTechn.set_name "counter_example checker"
     |> RTechn.set_inputs (RState.Wire.NSet.single goal_conj)
     |> RTechn.set_outputs (RState.Wire.NSet.single goal_not_cc)
     |> RTechn.set_atomic_appf count_ex_app;

(* 
  apply conjecture (to prove goal) reasoning technique 
*)

  (* side effect is to record the proof in conj DB cinfo *)
  fun note_proved_lemma conjname rst = 
      let 
        val conj_thm = (* make the theorem to store in the lemma db *)
            (Prf.mk_thm (RState.get_pplan rst) conjname)
              |> fst
              |> Thm.forall_elim_vars 0;
        val (absolute_conjname, rst2) = 
              Conjdb_CtxtInfo.insert_proved_rst 
                conjname (conj_thm, (conjname, (RState.get_pplan rst))) rst
      in ((absolute_conjname,conj_thm), rst2) end;

  fun apply_conj_one_goal g rst = 
    let 
       val (appinfo,conjname,provedQ) = Appinfo_Ctx.get g rst
       val conj_is_input = Goaln.NSet.contains (RState.get_names_of_wire rst result_conj) conjname
       val (conj_name_thm,rst2) = note_proved_lemma conjname rst (* adds to conj DB *)
       val res_seq = apply_lemmathm appinfo conj_name_thm g rst2 (* apply the lemma *)
       val _ = (* for debugging print out lemmas we are thinking about - FIXME: maybe remove due to additional constraints *)
            if !Toplevel.debug then
            Pretty.writeln 
            (Pretty.block [Pretty.str "Proved: ", 
                           Pretty.str conjname,
                           Pretty.str ""
                          ])
            else ()
    in
       if conj_is_input 
         then Seq.empty (* fail if not valid input *)
         else case Seq.pull res_seq of
                NONE    => Seq.empty (* fail if application fails *)
             | (SOME _) => ((provedQ := true) (* so other branches knows *);
                             Seq.map (RState.remove_single_name conjname) res_seq) (* fixme: also remove Appinfo? from context - ref variable should still be accessable?? *)
    end;

  fun apply_conj_app rst = 
      Goaln.NSet.fold
        (fn g => Seq.maps (apply_conj_one_goal g))
        (RState.get_names_of_wire rst goal_not_trivial)
        (Seq.single rst);

  val apply_conj_rtechn = 
    RTechn.id 
       |> RTechn.set_name "apply conjecture"
       |> RTechn.set_inputs (RState.Wire.NSet.of_list [result_conj,goal_not_trivial])
       |> RTechn.set_atomic_appf apply_conj_app;


(* 
  prove as lemmas reasoning technique
*)


(* FIXME: will fail when direct proof solves the goal *)

local open RTechn; open RTechnComb in

infix 6 th_compose;
infix 6 th_tensor;
infix 5 th_or;

fun prove_as_lemma prove_conj = 
   (lift_rtechn_and_try_bind direct_proof_rtechn) 
     th_compose
   (lift_rtechn_and_try_bind conjecture_rtechn)
    th_compose
   (lift_rtechn_and_try_bind counter_example_check_rtechn)
    th_compose
   prove_conj
    th_compose
   (lift_rtechn_and_try_bind apply_conj_rtechn);

(* fun conj_critic critic techn = 
   techn compose (prove_as_lemma critic);
*)

 end; 

(*   FIXME: 
       - should add this to cut search space when lemmas has been proven.
*)

(*
  fun cut_if_proved provedref rst = 
      if !provedref 
      then 
        case RState.get_rtechn rst 
         of NONE => rst
          | SOME _ => RState.set_rtechn (SOME RTechn.fail) rst
      else rst;

  fun cut_if_wire_proved wire rst = 
      if forall ! (* (fn provedref => !provedref) *)
                (map (fn g => Appinfo_Ctx.get_proved_var g rst)
                     (Goaln.NSet.list_of (RState.get_names_of_wire rst wire)))
      then 
        case RState.get_rtechn rst 
         of NONE => rst
          | SOME _ => RState.set_rtechn (SOME RTechn.fail) rst
      else rst;
*)

 (* end; *) (* local *)
end (* structure *)

