functor MyClasimp(Data: CLASIMP_DATA) =
struct

structure Splitter = Data.Splitter;
structure Classical = Data.Classical;
structure Blast = Data.Blast;


(* simp as classical wrapper *)

fun clasimp f name tac ctxt =
  Classical.map_claset (fn cs => f (cs, (name, CHANGED o tac (simpset_of ctxt)))) ctxt;

(*Add a simpset to the claset!*)
(*Caution: only one simpset added can be added by each of addSss and addss*)
val addSss = clasimp Classical.addSafter "safe_asm_full_simp_tac" Simplifier.safe_asm_full_simp_tac;
val addss = clasimp Classical.addbefore "asm_full_simp_tac" Simplifier.asm_full_simp_tac;


(* iffs: addition of rules to simpsets and clasets simultaneously *)

local

(*Takes (possibly conditional) theorems of the form A<->B to
        the Safe Intr     rule B==>A and
        the Safe Destruct rule A==>B.
  Also ~A goes to the Safe Elim rule A ==> ?R
  Failing other cases, A is added as a Safe Intr rule*)

fun add_iff safe unsafe =
  Thm.declaration_attribute (fn th =>
    let
      val n = nprems_of th;
      val (elim, intro) = if n = 0 then safe else unsafe;
      val zero_rotate = zero_var_indexes o rotate_prems n;
    in
      Thm.attribute_declaration intro (zero_rotate (th RS Data.iffD2)) #>
      Thm.attribute_declaration elim (Tactic.make_elim (zero_rotate (th RS Data.iffD1)))
      handle THM _ =>
        (Thm.attribute_declaration elim (zero_rotate (th RS Data.notE))
          handle THM _ => Thm.attribute_declaration intro th)
    end);

fun del_iff del = Thm.declaration_attribute (fn th =>
  let val zero_rotate = zero_var_indexes o rotate_prems (nprems_of th) in
    Thm.attribute_declaration del (zero_rotate (th RS Data.iffD2)) #>
    Thm.attribute_declaration del (Tactic.make_elim (zero_rotate (th RS Data.iffD1)))
    handle THM _ =>
      (Thm.attribute_declaration del (zero_rotate (th RS Data.notE))
        handle THM _ => Thm.attribute_declaration del th)
  end);

in

val iff_add =
  Thm.declaration_attribute (fn th =>
    Thm.attribute_declaration (add_iff
      (Classical.safe_elim NONE, Classical.safe_intro NONE)
      (Classical.haz_elim NONE, Classical.haz_intro NONE)) th
    #> Thm.attribute_declaration Simplifier.simp_add th);

val iff_add' =
  add_iff
    (Context_Rules.elim_query NONE, Context_Rules.intro_query NONE)
    (Context_Rules.elim_query NONE, Context_Rules.intro_query NONE);

val iff_del =
  Thm.declaration_attribute (fn th =>
    Thm.attribute_declaration (del_iff Classical.rule_del) th #>
    Thm.attribute_declaration (del_iff Context_Rules.rule_del) th #>
    Thm.attribute_declaration Simplifier.simp_del th);

end;


(* tactics *)

fun clarsimp_tac ctxt =
  Simplifier.safe_asm_full_simp_tac (simpset_of ctxt) THEN_ALL_NEW
  Classical.clarify_tac (addSss ctxt);


(* auto_tac *)

(* a variant of depth_tac that avoids interference of the simplifier
   with dup_step_tac when they are combined by auto_tac *)
local

fun slow_step_tac' ctxt =
  Classical.appWrappers ctxt
    (Classical.instp_step_tac ctxt APPEND' Classical.haz_step_tac ctxt);

in

fun nodup_depth_tac ctxt m i st =
  SELECT_GOAL
    (Classical.safe_steps_tac ctxt 1 THEN_ELSE
      (DEPTH_SOLVE (nodup_depth_tac ctxt m 1),
        Classical.inst0_step_tac ctxt 1 APPEND COND (K (m = 0)) no_tac
          (slow_step_tac' ctxt 1 THEN DEPTH_SOLVE (nodup_depth_tac ctxt (m - 1) 1)))) i st;

end;

(*Designed to be idempotent, except if Blast.depth_tac instantiates variables
  in some of the subgoals*)
fun mk_auto_tac ctxt m n =
  let
    val main_tac =
      Blast.depth_tac ctxt m  (* fast but can't use wrappers *)
      ORELSE'
      (CHANGED o nodup_depth_tac (addss ctxt) n);  (* slower but more general *)
  in
    PARALLEL_GOALS (ALLGOALS (Simplifier.asm_full_simp_tac (simpset_of ctxt))) THEN
    TRY (Classical.safe_tac ctxt) THEN
    REPEAT_DETERM (FIRSTGOAL main_tac) THEN
    TRY (Classical.safe_tac (addSss ctxt)) THEN
    prune_params_tac
  end;

fun auto_tac ctxt = mk_auto_tac ctxt 4 2;


(* force_tac *)

(* aimed to solve the given subgoal totally, using whatever tools possible *)
fun force_tac ctxt =
  let val ctxt' = addss ctxt in
    SELECT_GOAL
     (Classical.clarify_tac ctxt' 1 THEN
      IF_UNSOLVED (Simplifier.asm_full_simp_tac (simpset_of ctxt) 1) THEN
      ALLGOALS (Classical.first_best_tac ctxt'))
  end;


(* basic combinations *)

val fast_force_tac = Classical.fast_tac o addss;
val slow_simp_tac = Classical.slow_tac o addss;
val best_simp_tac = Classical.best_tac o addss;


end;

structure AInt = MyClasimp
(
  structure Simplifier = Simplifier
    and Splitter = Splitter
    and Classical  = Classical
    and Blast = Blast
  val iffD1 = @{thm iffD1}
  val iffD2 = @{thm iffD2}
  val notE = @{thm notE}
);
