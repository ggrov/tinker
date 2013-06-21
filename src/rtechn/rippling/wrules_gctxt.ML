(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      rtechn/rippling/wrules_gctxt.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Created:    18 Feb 2004
    Modified:   Dominic Mulligan
                dpm_edinburgh@yahoo.com
                12 Sept 2007
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Isabelle/Isar theory data and syntax for holding rippling information.
    modelled on 
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature WRULES_GCTXT = 
sig

structure Data : GENERIC_DATA where type T = WRules.T

val wrules_of_ctxt : Proof.context -> WRules.T
val wrule_of_theory : theory -> WRules.T 

val print : Proof.context -> unit
val pretty : Proof.context -> Pretty.T 

val init : WRules.T option -> Context.generic -> Context.generic
val get_from_theory : theory -> WRules.T
val get_from_ctxt : Proof.context -> WRules.T
val get : Context.generic -> WRules.T
val delall_wrule_thm : thm -> Context.generic -> Context.generic
val del_wrule_thm : thm -> Context.generic -> Context.generic
val del_wrule_rl_thm : thm -> Context.generic -> Context.generic
val del_wrule_lr_thm : thm -> Context.generic -> Context.generic
val del_impwrule_thm : thm -> Context.generic -> Context.generic
val del_fwd_impwrule_thm : thm -> Context.generic -> Context.generic
val deafultsearchf : Zipper.T -> Zipper.T Seq.seq
val addall_wrule_thm : thm -> Context.generic -> Context.generic
val add_wrule_thm : thm -> Context.generic -> Context.generic
val add_impwrule_thm : thm -> Context.generic -> Context.generic
val add_fwd_impwrule_thm : thm -> Context.generic -> Context.generic

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure DB_WRulesGCtxt =
struct

val deafultsearchf = EqSubst.search_lr_valid EqSubst.valid_match_start;

structure Data = Generic_Data
(
  type T = WRules.T;
  val empty = WRules.init deafultsearchf;
  val extend = I;
  fun merge (db1,db2) = WRules.merge (db1,db2);
);

(* Easy way to get rid of unwanted rewrites *)
fun init optDB = case optDB of 
                 SOME db => Data.put db | 
                 NONE => Data.put (WRules.init deafultsearchf);

val get_from_ctxt = Data.get o Context.Proof;
val get_from_theory = Data.get o Context.Theory;

val wrules_of_ctxt = Data.get o Context.Proof;
val wrule_of_theory = Data.get o Context.Theory;

val get = Data.get;

fun print ctxt = WRules.print ctxt (get_from_ctxt ctxt);
fun pretty ctxt = WRules.pretty ctxt (get_from_ctxt ctxt);

(* 
val add_thm = Data.map o Thm.add_thm;
val del_thm = Data.map o Thm.del_thm;

val add = Thm.declaration_attribute add_thm;
val del = Thm.declaration_attribute del_thm;
*)

(* adding a wave rule to the theory rules *)
fun add_wrule_thm thm gctxt = 
    let val db = get gctxt;
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt]);
      val db2 = WRules.add_dthms_as_wrules (Context.proof_of gctxt) 
                                           ([DThm.mk thm, dth_sym], db); 
    in Data.put db2 gctxt end;

(* ignore wave rule filters... *)
fun addall_wrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt])
      val db2 = WRules.addall_dthms_as_wrules 
                  (Context.proof_of gctxt) ([DThm.mk thm, dth_sym], db);
    in Data.put db2 gctxt end;

(* deleting a wave rule from the theory rules *)
fun del_wrule_thm thm gctxt = 
    let val db = get gctxt
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt])
      val db2 = WRules.del_dthms_from_wrules ([DThm.mk thm, dth_sym], db)
    in Data.put db2 gctxt end;
val delall_wrule_thm = del_wrule_thm;
fun del_wrule_lr_thm thm gctxt = 
    let val db = get gctxt 
      val db2 = WRules.del_dthms_from_wrules ([DThm.mk thm], db); 
    in Data.put db2 gctxt end;
fun del_wrule_rl_thm thm gctxt = 
    let val db = get gctxt 
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt])
      val db2 = WRules.del_dthms_from_wrules ([dth_sym], db); 
    in Data.put db2 gctxt end;

(* adding a equation wave rule to the theory rules *)
fun add_impwrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth = DThm.mk thm
      val db2 = WRules.add_dthms_as_impwrules 
                  (Context.proof_of gctxt) ([dth], db);
    in Data.put db2 gctxt end;
(* deleting an implication wave rule from the theory rules *)
fun del_impwrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth = DThm.mk thm
      val db2 = WRules.del_dthms_from_impwrules ([dth], db); 
    in Data.put db2 gctxt end;

fun add_fwd_impwrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth = DThm.mk thm
      val db2 = WRules.add_dthms_as_fwd_impwrules 
                  (Context.proof_of gctxt) ([dth], db);
    in Data.put db2 gctxt end;
(* deleting an implication wave rule from the theory rules *)
fun del_fwd_impwrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth = DThm.mk thm
      val db2 = WRules.del_dthms_from_fwd_impwrules ([dth], db); 
    in Data.put db2 gctxt end;

end;

structure WRulesGCtxt : WRULES_GCTXT = DB_WRulesGCtxt;
