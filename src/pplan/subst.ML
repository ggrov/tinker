(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      subst.ML
    Author:     Lucas Dixon, University of Edinburgh
                lucas.dixon@ed.ac.uk
    Date:       29 Nov 2006
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(* 
   Substitution method
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 

(* subst logic specific data *)
signature EQ_LDATA
= sig

exception cannot_mk_eq of Prf.gname * Prf.T
exception bad_term_exp of string;

val mk_meta_eq : Prf.gname -> Prf.T -> (Prf.gname * Prf.T)
val mk_sym_eq : Prf.gname -> Prf.T -> (Prf.gname * Prf.T)

val mlogic_is_equals : Trm.T -> bool

val move_to_concl_eq : Zipper.T -> Zipper.T option
val on_lhs_of_eq : Zipper.T -> Zipper.T
val on_rhs_of_eq : Zipper.T -> Zipper.T

end;


structure Eq_LData_HOL 
: EQ_LDATA
= struct

exception cannot_mk_eq of Prf.gname * Prf.T
exception bad_term_exp of string;

val eq_reflection = @{thm "HOL.eq_reflection"}; (* "?x = ?y ==> ?x == ?y" *)
val eq_sym = @{thm "Pure.symmetric"}; (*"?x == ?y ==> ?y == ?x *)


fun mk_meta_eq gname ffp = 
    case Seq.pull (Prf.apply_frule_thm eq_reflection gname ffp) of 
      NONE => raise cannot_mk_eq (gname,ffp)
    | SOME (h,_) => h; 

fun mk_sym_eq gname ffp =    
    case Seq.pull (Prf.apply_frule_thm eq_sym gname ffp) of
      NONE => raise cannot_mk_eq (gname,ffp)
    | SOME (h,_) => h; 


(* is eq_name a meta-level equality? *)
fun mlogic_is_equals (Const ("==", _) $ t $ u) = true
  | mlogic_is_equals _ = false;


(* Check if this zipper is an equality *)
fun move_to_concl_eq z = 
    (case Zipper.trm z 
      of (Const("HOL.Trueprop",ty)$x) => 
         move_to_concl_eq (Zipper.move_down_right z)
       | ((Const("==>",ty)$lhs)$rhs) => 
         move_to_concl_eq (Zipper.move_down_right z)
 (*      | ((Const("HOL.implies",ty)$lhs)$rhs) => 
         move_to_concl_eq (Zipper.move_down_right z) *)
       | ((Const("==",ty)$lhs)$rhs) => SOME z
       | ((Const("HOL.eq",_)$lhs)$rhs) => SOME z
       | _ => NONE);

fun on_lhs_of_eq z = 
    (case Zipper.trm z
      of (Const("==",ty)$lhs)$rhs => 
         z |> Zipper.move_down_left
            |> Zipper.move_down_right
       | (Const("HOL.eq",_)$lhs)$rhs => 
         z |> Zipper.move_down_left
            |> Zipper.move_down_right
       | _ => raise bad_term_exp "Eq_LData_HOL.on_lhs_of_eq: not an eq");

fun on_rhs_of_eq z = 
    (case Zipper.trm z 
      of (Const("==",ty)$lhs)$rhs => 
         z |> Zipper.move_down_right
       | (Const("HOL.eq",_)$lhs)$rhs => 
         z |> Zipper.move_down_right
       | _ => raise bad_term_exp "Eq_LData_HOL.on_rhs_of_eq: not an eq");

end;


signature EQ_SUBST
= sig

structure LData : EQ_LDATA;

val mk_meta_eq : Prf.gname -> Prf.T -> (Prf.gname * Prf.T)
val mk_sym_eq : Prf.gname -> Prf.T -> (Prf.gname * Prf.T)
val mlogic_is_equals : Trm.T -> bool

val ensure_meq : (Prf.gname * Prf.T) -> (Prf.gname * Prf.T)
val maybe_mk_sym : bool -> (Prf.gname * Prf.T) -> (Prf.gname * Prf.T)
val is_meta_eq : Prf.T -> Prf.gname -> bool

val move_to_concl_eq : Zipper.T -> Zipper.T option
val on_lhs_of_eq : Zipper.T -> Zipper.T
val on_rhs_of_eq : Zipper.T -> Zipper.T
val move_to_lhs_of_eq : Zipper.T -> Zipper.T
val move_to_rhs_of_eq : Zipper.T -> Zipper.T


val apply : Prf.gname (* equation *)
            -> bool (* symmetric flag *)
            -> Prf.gname (* goal/fact *)
            -> Prf.T (* proof plan *)
            -> ((Prf.gname (* new goal/fact *)
                * Prf.gname list) (* subgoals from equation conditions *)
                   * Prf.T) Seq.seq (* new proof plan *)

val apply_at : Prf.gname (* equation *)
            -> bool (* symmetric flag *)
            -> Prf.gname (* goal/fact *)
            -> Zipper.T (* apply subst exactly at this location *)
            -> Prf.T (* proof plan *)
            -> ((Prf.gname (* new goal/fact *)
                * Prf.gname list) (* subgoals from equation conditions *)
                   * Prf.T) Seq.seq (* new proof plan *)

val apply_under : Prf.gname (* equation *)
            -> bool (* symmetric flag *)
            -> Prf.gname (* goal/fact *)
            -> Zipper.T (* apply subst searching under this location  *)
            -> Prf.T (* proof plan *)
            -> ((Prf.gname (* new goal/fact *)
                * Prf.gname list) (* subgoals from equation conditions *)
                   * Prf.T) Seq.seq (* new proof plan *)

val apply_at_lhs :  Prf.gname (* equation *)
                    -> bool (* symmetric flag *)
                    -> Prf.gname (* goal/fact *)
                    -> Prf.T 
                    -> ((Prf.gname 
                         * Prf.gname list) 
                        * Prf.T) Seq.seq 

val apply_at_rhs :  Prf.gname (* equation *)
                    -> bool (* symmetric flag *)
                    -> Prf.gname (* goal/fact *)
                    -> Prf.T 
                    -> ((Prf.gname 
                         * Prf.gname list) 
                        * Prf.T) Seq.seq 

val apply_thm : Thm.thm (* equation *)
                -> bool (* symmetric flag *)
                -> Prf.gname (* goal/fact *)
                -> Prf.T (* proof plan *)
                -> ((Prf.gname 
                     * Prf.gname list) 
                    * Prf.T) Seq.seq 

val apply_thm_at : Thm.thm (* equation *)
                -> bool (* symmetric flag *)
                -> Prf.gname (* goal/fact *)
                -> Zipper.T
                -> Prf.T 
                -> ((Prf.gname 
                     * Prf.gname list) 
                    * Prf.T) Seq.seq 

end;

(* IMPROVE: make into a functor on SUBST_LDATA *)
(* substitution method functor. *)
structure DB_Subst 
= struct

structure Z = Zipper;
structure LData = Eq_LData_HOL;

val is_meta_eq = LData.mlogic_is_equals oo Prf.get_ndname_ctrm;

(* make sure and eq is a meq - change it if you need to *)
fun ensure_meq (eqffp as (eq_name, ffp)) = 
    if is_meta_eq ffp eq_name then eqffp
    else LData.mk_meta_eq eq_name ffp;

(* given meq_gname and prf, if sym then make symmetric version *)
fun maybe_mk_sym sym (eqffp as (meq_name, ffp)) = 
    if sym then LData.mk_sym_eq meq_name ffp
    else eqffp;

fun move_to_rhs_of_eq z = 
    (case LData.move_to_concl_eq z 
      of NONE => 
         raise LData.bad_term_exp "Subst.move_to_rhs_of_eq: not an eq"
       | SOME x => LData.on_rhs_of_eq x);
fun move_to_lhs_of_eq z = 
    (case LData.move_to_concl_eq z 
      of NONE => 
         raise LData.bad_term_exp "Subst.move_to_lhs_of_eq: not an eq"
       | SOME x => LData.on_lhs_of_eq x);

val mlogic_is_equals = LData.mlogic_is_equals;
val mk_meta_eq = LData.mk_meta_eq;
val mk_sym_eq = LData.mk_sym_eq;

val move_to_concl_eq = LData.move_to_concl_eq;
val on_lhs_of_eq = LData.on_lhs_of_eq;
val on_rhs_of_eq = LData.on_rhs_of_eq;

(* move to bottom left leaf - impersonate head-normal form *)
fun bot_left_leaf_of (l $ r) = bot_left_leaf_of l
  | bot_left_leaf_of (Abs(s,ty,t)) = bot_left_leaf_of t
  | bot_left_leaf_of x = x;

(* what zippers are we allowed to look underneath *)
fun valid_match_start z =
    (case bot_left_leaf_of (Z.trm z) of 
       Const _ => true
     | Free _ => true
     | Abs _ => true (* allowed to look inside abs...  *)
     | _ => false); (* avoid vars - always suceeds uninterestingly. *)

(* search from top, left to right, then down, only under valid zippers *)
fun search_lr_valid validf =
    let 
      fun sf_valid_td_lr z = 
          let val here = if validf z then [Z.Here z] else [] in
            case Z.trm z 
             of _ $ _ => [Z.LookIn (Z.move_down_left z)] 
                         @ here 
                         @ [Z.LookIn (Z.move_down_right z)]
              | Abs _ => here @ [Z.LookIn (Z.move_down_abs z)]
              | _ => here
          end;
    in Z.lzy_search sf_valid_td_lr end;
 

(* search from bottom, left to right, then up *)
val search_lr_all = ZipperSearch.all_bl_ur;


(* Search zipper and apply subst to those locations *)
fun search_and_apply eq_name sym gname searchf z ffp = 
    let val (meq2, ffp2) = (eq_name,ffp) |> ensure_meq |> maybe_mk_sym sym
    in Seq.maps (fn z2 => Prf.apply_subst meq2 gname z2 ffp2) (searchf z) end;

(* Apply subst to things exactly at this zipper location *)
fun apply_at eq_name sym gname z ffp = 
    let val (meq2, ffp2) = (eq_name,ffp) |> ensure_meq |> maybe_mk_sym sym
    in Prf.apply_subst meq2 gname z ffp2 end;

(* search and apply wrapped in a compound method *)
fun apply_under eq_name sym gname z ffp = 
    let val closed_goals = if Prf.is_open_goal ffp gname then [gname] else [];
    in
      Seq.map
        (fn ((g,_),subffp) => (* _ should be same as gs in this case *)
         let val (gs,ffp2) = 
                 Prf.end_meth ("subst " ^ eq_name) [g] closed_goals subffp ffp
         in ((g,gs),ffp2) end)
        (search_and_apply eq_name sym gname search_lr_all z
        (Prf.start_meth closed_goals ffp))
    end;

(* search and apply wrapped in a compound method *)
fun apply eq_name sym gname ffp = 
    let val z = Zipper.mktop (Prf.get_ndname_ctrm ffp gname)
    in apply_under eq_name sym gname z ffp end;

(* Apply substitution with a theorem, by first adding it to the proof-plan *)
fun apply_thm thm sym gname ffp = 
    let
      val closed_goals = if Prf.is_open_goal ffp gname then [gname] else [];
      val (eq_name,ffp2) = 
          Prf.insert_thm thm (Prf.start_meth closed_goals ffp)
      val z = Zipper.mktop (Prf.get_ndname_ctrm ffp gname)
    in
      Seq.map
        (fn ((g,_),subffp) => (* _ should be same as gs in this case *)
            let val (gs,ffp3) = 
                    Prf.end_meth ("subst_w_thm: " ^ Thm.get_name_hint thm) 
                                 [g] closed_goals subffp ffp
            in ((g,gs),ffp3) end)
        (search_and_apply eq_name sym gname search_lr_all z ffp2)
    end;

(* apply thm at zipper location *)
fun apply_thm_at thm sym gname z ffp = 
    let
      val closed_goals = if Prf.is_open_goal ffp gname then [gname] else [];
      val (eq_name,ffp2) = 
          Prf.insert_thm thm (Prf.start_meth closed_goals ffp)
    in
      Seq.map
        (fn ((g,_),subffp) => (* _ should be same as gs in this case *)
            let val (gs,ffp3) = 
                    Prf.end_meth ("subst_w_thm: " ^ Thm.get_name_hint thm) 
                                 [g] closed_goals subffp ffp
            in ((g,gs),ffp3) end)
        (apply_at eq_name sym gname z ffp2)
    end;


(* Try to apply substiturion in the LHS of the goal *)
fun apply_at_lhs eq_name sym gname ffp =
    let
      val nd = Prf.get_nd ffp gname
      val z = move_to_lhs_of_eq (Zipper.mktop (APrf.nd_get_trm nd))
    in apply_under eq_name sym gname z ffp end;

(* Try to apply substiturion in the RHS of the goal *)
fun apply_at_rhs eq_name sym gname ffp =
    let
      val nd = Prf.get_nd ffp gname
      val z = move_to_rhs_of_eq (Zipper.mktop (APrf.nd_get_trm nd))
    in apply_under eq_name sym gname z ffp end;

end;  

structure Subst : EQ_SUBST = DB_Subst;
