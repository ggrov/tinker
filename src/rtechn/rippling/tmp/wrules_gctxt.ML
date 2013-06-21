(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Isabelle/Isar theory data and syntax for holding rippling information.
    modelled on 
*)   
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)

signature WRULES_GCTXT = 
sig

(* structure Data : GENERIC_DATA where type T = WRules.T  *)
(* should be replaced by rule-set -- should we have 3 different sets???
   or a record of three elements? *)

structure DataSub : GENERIC_DATA where type T = Substset.T 
structure DataBck : GENERIC_DATA where type T = Bckimpset.T 
structure DataFwd : GENERIC_DATA where type T = Fwdimpset.T 

type T = Substset.T * Bckimpset.T * Fwdimpset.T
val wrules_of_ctxt : Proof.context -> T
val wrule_of_theory : theory -> T 

val print : Proof.context -> unit
val pretty : Proof.context -> Pretty.T 

(*
val init : T option -> Context.generic -> Context.generic
val get_from_theory : theory -> T
val get_from_ctxt : Proof.context -> T
val get : Context.generic -> T
*)

val init_sub : Substset.T option -> Context.generic -> Context.generic
val get_sub_from_theory : theory -> Substset.T
val get_sub_from_ctxt : Proof.context -> Substset.T
val get_sub : Context.generic -> Substset.T

val init_bck : Bckimpset.T option -> Context.generic -> Context.generic
val get_bck_from_theory : theory -> Bckimpset.T
val get_bck_from_ctxt : Proof.context -> Bckimpset.T
val get_bck : Context.generic -> Bckimpset.T

val init_fwd : Fwdimpset.T option -> Context.generic -> Context.generic
val get_fwd_from_theory : theory -> Fwdimpset.T
val get_fwd_from_ctxt : Proof.context -> Fwdimpset.T
val get_fwd : Context.generic -> Fwdimpset.T

(* val delall_wrule_thm : thm -> Context.generic -> Context.generic *)
val del_wrule_thm : thm -> Context.generic -> Context.generic
val del_wrule_rl_thm : thm -> Context.generic -> Context.generic
val del_wrule_lr_thm : thm -> Context.generic -> Context.generic
val del_impwrule_thm : thm -> Context.generic -> Context.generic
val del_fwd_impwrule_thm : thm -> Context.generic -> Context.generic
val deafultsearchf : Zipper.T -> Zipper.T Seq.seq

(* val addall_wrule_thm : thm -> Context.generic -> Context.generic *)
val add_wrule_thm : thm -> Context.generic -> Context.generic
val add_impwrule_thm : thm -> Context.generic -> Context.generic
val add_fwd_impwrule_thm : thm -> Context.generic -> Context.generic

end;


(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure DB_WRulesGCtxt =
struct

val deafultsearchf = EqSubst.search_lr_valid EqSubst.valid_match_start;

type T = Substset.T * Bckimpset.T * Fwdimpset.T

structure DataSub = Generic_Data
(
  type T = Substset.T;
  val empty = Substset.empty;
  val extend = I;
  fun merge (db1,db2) = Substset.merge (db1,db2);
);

structure DataBck = Generic_Data
(
  type T = Bckimpset.T;
  val empty = Bckimpset.empty;
  val extend = I;
  fun merge (db1,db2) = Bckimpset.merge (db1,db2);
);

structure DataFwd = Generic_Data
(
  type T = Fwdimpset.T;
  val empty = Fwdimpset.empty;
  val extend = I;
  fun merge (db1,db2) = Fwdimpset.merge (db1,db2);
);

(* Easy way to get rid of unwanted rewrites *)
fun init_sub optDB = case optDB of 
                 SOME db => DataSub.put db | 
                 NONE => DataSub.put (Substset.empty);
val get_sub_from_ctxt = DataSub.get o Context.Proof;
val get_sub_from_theory = DataSub.get o Context.Theory;
val get_sub = DataSub.get;

fun init_bck optDB = case optDB of 
                 SOME db => DataBck.put db | 
                 NONE => DataBck.put (Bckimpset.empty);
val get_bck_from_ctxt = DataBck.get o Context.Proof;
val get_bck_from_theory = DataBck.get o Context.Theory;
val get_bck = DataBck.get;

fun init_fwd optDB = case optDB of 
                 SOME db => DataFwd.put db | 
                 NONE => DataFwd.put (Fwdimpset.empty);
val get_fwd_from_ctxt = DataFwd.get o Context.Proof;
val get_fwd_from_theory = DataFwd.get o Context.Theory;
val get_fwd = DataFwd.get;

(* fix me: needs to be a combination of the three others *)
fun wrules_of_ctxt ctx = (get_sub_from_ctxt ctx, get_bck_from_ctxt ctx, get_fwd_from_ctxt ctx);
fun wrule_of_theory ctx = (get_sub_from_theory ctx, get_bck_from_theory ctx, get_fwd_from_theory ctx);

fun pretty_of_wruledbs (substdb , bckdb , fwddb) = 
    Pretty.chunks 
      [Pretty.str "Equality Wave Rules: ",
       Substset.pretty substdb,
       Pretty.str "Backward Implication Wave Rules: ",
       Bckimpset.pretty bckdb,
       Pretty.str "Forward Implication Wave Rules: ",
       Fwdimpset.pretty fwddb
      ];

fun pretty ctx =  pretty_of_wruledbs (wrules_of_ctxt ctx);
val print = Pretty.writeln o pretty;

(* 
val add_thm = Data.map o Thm.add_thm;
val del_thm = Data.map o Thm.del_thm;

val add = Thm.declaration_attribute add_thm;
val del = Thm.declaration_attribute del_thm;
*)

(* adding a wave rule to the theory rules *)
fun add_wrule_thm thm gctxt = 
    let val db = get_sub gctxt;
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt]);
      val dth_sym_rule = Substset.rule_of_thm (Context.proof_of gctxt) (DThm.finalthm_of dth_sym); (* not sure if this is okey to do... *)
      val dth_rule = Substset.rule_of_thm (Context.proof_of gctxt) thm;
      val db2 = Substset.add dth_rule db
             |> Substset.add dth_sym_rule
    in DataSub.put db2 gctxt end;

(* ignore wave rule filters... *)
(* fun addall_wrule_thm thm gctxt = 
    let val db = get gctxt 
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt])
      val db2 = Substset.addall_dthms_as_wrules 
                  (Context.proof_of gctxt) ([DThm.mk thm, dth_sym], db);
    in DataSub.put db2 gctxt end;
*)

(* deleting a wave rule from the theory rules *)
fun del_wrule_thm thm gctxt = 
    let val db = get_sub gctxt;
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt]);
      val dth_sym_rule = Substset.rule_of_thm (Context.proof_of gctxt) (DThm.finalthm_of dth_sym); (* not sure if we can do this *)
      val dth_rule = Substset.rule_of_thm (Context.proof_of gctxt) thm;
      val db2 = Substset.remove dth_sym_rule (Substset.remove dth_rule db)
    in DataSub.put db2 gctxt end;

(* val delall_wrule_thm = del_wrule_thm; *)

fun del_wrule_lr_thm thm gctxt = 
    let val db = get_sub gctxt;
      val dth_rule = Substset.rule_of_thm (Context.proof_of gctxt) thm;
      val db2 = Substset.remove dth_rule db
    in DataSub.put db2 gctxt end;
fun del_wrule_rl_thm thm gctxt = 
    let val db = get_sub gctxt;
      val dth_sym = DThm.mk_a (thm, [IsarAttr.Symmetric.dattr gctxt]);
      val dth_sym_rule = Substset.rule_of_thm (Context.proof_of gctxt) (DThm.finalthm_of dth_sym);
      val db2 = Substset.remove dth_sym_rule db
    in DataSub.put db2 gctxt end;

(* adding a equation wave rule to the theory rules *)
fun add_impwrule_thm thm gctxt = 
    let val db = get_bck gctxt 
      val dth = DThm.mk thm
      val db2 = Bckimpset.add (Bckimpset.rule_of_dthm dth) db;
    in DataBck.put db2 gctxt end;
(* deleting an implication wave rule from the theory rules *)
fun del_impwrule_thm thm gctxt = 
    let val db = get_bck gctxt 
      val dth = DThm.mk thm
      val db2 = Bckimpset.remove (Bckimpset.rule_of_dthm dth) db;
    in DataBck.put db2 gctxt end;

fun add_fwd_impwrule_thm thm gctxt = 
    let val db = get_fwd gctxt 
      val dth = DThm.mk thm
      val fwdrules = Fwdimpset.rules_of_dthm dth
      val db2 = fold Fwdimpset.add fwdrules db
    in DataFwd.put db2 gctxt end;

(* deleting an implication wave rule from the theory rules *)
fun del_fwd_impwrule_thm thm gctxt = 
    let val db = get_fwd gctxt 
      val dth = DThm.mk thm
      val fwdrules = Fwdimpset.rules_of_dthm dth
      val db2 = fold Fwdimpset.remove fwdrules db
    in DataFwd.put db2 gctxt end;

end;

structure WRulesGCtxt : WRULES_GCTXT = DB_WRulesGCtxt;
