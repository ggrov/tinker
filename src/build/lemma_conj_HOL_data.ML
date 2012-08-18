(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      libs/lemma_conj_HOL_data.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucasd@dai.ed.ac.uk
    Date:       22 July 2004
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Logic dependent data for the conjecturing library
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
structure HOL_LemmaConjData : LEMMA_CONJ_DATA
= struct

fun dest_eq_term (((c as Const("HOL.eq", ty)) $ l) $ r) = SOME (c, l,r)
  | dest_eq_term (((c as Const("==", ty)) $ l) $ r) = SOME (c, l,r)
  | dest_eq_term _ = NONE;

fun dest_obj_eq_term (((c as Const("HOL.eq", ty)) $ l) $ r) = SOME (c, l,r)
  | dest_obj_eq_term _ = NONE;

fun dest_rw (((Const("==", ty)) $ l) $ r) = SOME (l, r)
  | dest_rw (((Const("HOL.eq", ty)) $ l) $ r) = SOME (l, r)
  | dest_rw (((Const("HOL.implies", ty)) $ r) $ l) = SOME (r, l)
  | dest_rw (((c as Const("==>", ty)) $ r) $ l) = SOME (r, l)
  | dest_rw _ = NONE;

val mk_imp = HOLogic.mk_imp;
val mk_eq = HOLogic.mk_eq;
val mk_meta_eq = Logic.mk_equals;

val mk_Trueprop = HOLogic.mk_Trueprop;
val dest_Trueprop = HOLogic.dest_Trueprop;

fun try_dest_Trueprop (Const("HOL.Trueprop", _) $ T) = T
    | try_dest_Trueprop T = T;
fun try_dest_Goal (Const("prop", _) $ T) = T
    | try_dest_Goal T = T;

fun try_mk_Trueprop t = 
     case Term.type_of t of
       Type("HOL.bool", []) => HOLogic.mk_Trueprop t
     | Type("prop", []) => t
     | _ => t; 


(* try to make an argument congruence generalisation *)
val arg_cong_term = Thm.concl_of (@{thm "HOL.arg_cong"});
(* "(?f :: ?'x => ?'y) ?a = ?f ?b"; *)
val vtab1 = InstEnv.of_trm @{context} arg_cong_term;

fun try_arg_cong_gen ienv (c, l, r) = 
    let 
      val t = ((c $ l) $ r)
      (* merges new vars and instantiates term *)
      val (renaming, arg_cong_term') = 
          InstEnv.rename_trm_vars (InstEnv.init_renaming ienv) 
                                  arg_cong_term;
      val ienv' = InstEnv.avoid_of_renaming renaming;
    in
      (* reversed because of the order in which unifiers are found *)
      (case rev (Seq.list_of 
                   (MyUnify.unifiers (ienv', [(arg_cong_term',t)])))
     of [] => (false, l, r)
      | [a] => (false, l, r) (* one result means we got f = id *)
      | (ienv2 :: _) =>
        (true, InstEnv.inst_trm ienv2 l, InstEnv.inst_trm ienv2 r))
    end;

val arg_cong_attr = IsarAttr.Argcong.dattr;
val symmetric_attr = IsarAttr.Symmetric.dattr;

end;

structure DB_LemmaConjLib = LemmaConjLibFUN(HOL_LemmaConjData);
structure LemmaConjLib : LEMMA_CONJ = DB_LemmaConjLib;
