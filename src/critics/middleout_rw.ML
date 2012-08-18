(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      middleout_rw.ML
    Author:     Moa Johansson, University of Edinburgh
                moa.johansson@ed.ac.uk
    Created:    4/12 -06
*)

(* Middle-Out Rewriting by first finding a matchin non-variable
subterm in the rule, then using the remainign rule to instantiate some
meta-variable in the goal. Fianlly do a step of rewriting.  *) 

(*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure MiddleOutRW  =
struct


exception my_exp of (Zipper.T  * Zipper.T* DB_Prf.T * DB_Prf.gname)
exception NoMetaVars of (PPlan.gname * RState.T)

(* TODO: generalise with zipper repeat fuinction *)
fun top_right_of_zipper z =
    (case (Zipper.omove_up_right z) of 
      NONE => z
    | SOME z' => top_right_of_zipper z');

exception my_exp1 of (Zipper.T * Zipper.T)

(* Move up the goal and rule zippers until we find a meta-variable
that we will try to make match 'the rest' of the rule.*)

(* assuming zipper's at the leaves that we found matching; 
and: rz is a zipper only on the left hand sizde of the rule
*)
fun inst_for_partwrule ppl rule_nm rz gz =
 let val ienv = Prf.get_ienv ppl
     val gt0 = Zipper.trm gz
  in
  if (Zipper.at_top rz) then 
    (* Instantiate stuff below goal-zip with rule*)    
     if (null (Term.loose_bnos gt0)
         andalso MyUnify.unifies (ienv, [(Zipper.trm rz, Zipper.trm gz)]) 
       andalso (not (null (OldTerm.term_vars (Zipper.trm gz))))) 
     then SOME (gz, ppl, rule_nm) 
     else NONE 
  else
    (case Zipper.omove_up gz of
     SOME gz' =>
     let val gt = Zipper.trm gz'
     in
       if (null (Term.loose_bnos gt)) then (* Make sure no dangling bounds*)
         (case Term.head_of gt of 
            Var (n,ty) => 
            (case MetaVarLib.inst_mvar (n,ty) gz' rz ppl 
              of NONE => NONE
               | SOME ppl2 =>
                 let
                 (* Note: probably no exta copies of var in zipper by
                  the way we constructed the term, so maybe could frop
                  below zipper inst. *)
                   val app_zip = InstEnv.inst_zipper 
                                   (Prf.get_ienv ppl2) 
                                   (top_right_of_zipper gz')
                 in 
                   SOME (app_zip, ppl2, rule_nm) 
                 end)
          | _ => inst_for_partwrule ppl rule_nm (Zipper.move_up rz) gz')
     else inst_for_partwrule ppl rule_nm (Zipper.move_up rz) gz'
     end 
   | NONE => NONE)
 end
 handle MyUnify.hounifiers_exp x => raise my_exp (rz, gz, ppl, rule_nm) ;


(* Find and instantiation for a meta-variable that makes a 
   wave-rule applicable, starting to look for matches
   at the leaves of the goal-zipper that are constants.*)
fun inst_metavar ppl goal (gz,rule) =
    let  
      val rule_thm = rule |> Substset.thm_of_rule
      val (rule_nm, ppl2) = Prf.insert_thm rule_thm ppl;
      val ((lifted_rule_name, sgs), ppl3) = Prf.lift_and_show_above rule_nm [] goal ppl2;
      (* Make zipper of lifted version of rule, at same pos as non-lifted*)
      val rule_zip_ctxt = Zipper.ctxt (WRules.zipper_of partrule);
      val rz = (Prf.get_ndname_ctrm ppl3 lifted_rule_name) 
                 |> Zipper.mktop
                 |> Subst.move_to_lhs_of_eq
                 |> Zipper.trm 
                 |> Zipper.mktop
                 |> Zipper.zipto rule_zip_ctxt
    in
      case (inst_for_partwrule ppl3 lifted_rule_name rz gz) of
      NONE => NONE
    | SOME inst => SOME (inst, Thm.get_name_hint rule_thm) 
    end;


fun search_func_leaves zip = 
        let 
          fun is_left_leaf [] = false
            | is_left_leaf ((Zipper.C.D.AppR _)::t) = true
            | is_left_leaf _ = false;

        in
          Seq.filter (fn z => (is_left_leaf(Zipper.ctxt z)) andalso 
                      (Term.is_Const(Zipper.trm z)))
                    (ZipperSearch.leaves_lr zip) 
          (* Think it's OK to use this, as we check for loose lamdas above *)
                  (* (Zipper.lzy_search sf_leaves_lr_above_lam zip) *)
        end;

(* Takes a rst and a goal assumed to contain meta-varaibles.
   First finds a subterm matching some function symbol in a
   waverule, then instantiates the meta-variable above to 
   match the rest of the rule. Finally, the now partially
  instantiated goal is rewritten using the rule. *)


fun has_metavars z =
    (not o null) (OldTerm.term_vars (Zipper.trm z))

exception midout_rw_exp of (PPlan.gname * RState.T);

fun midout_rw goal rst  =
    let
      val ppl0 = RState.get_pplan rst
       val ppl = Prf.start_meth [goal] ppl0

      val ienv = RstPP.get_ienv rst  
                 
      val cx = Prf.get_ndname_cx ppl goal

      val ctxt = RstPP.get_ctxt rst;
      val db =  WRulesGCtxt.wrules_of_ctxt ctxt
      val part_wrulenet = WRules.get_partrule_net db

      val gz = (RstPP.goal_concl rst goal)
                |> Zipper.mktop 
                
      val gz' = case (Subst.move_to_concl_eq gz) of
                  SOME z => 
                       let 
                         val lhs = Subst.move_to_lhs_of_eq gz
                         val rhs = Subst.move_to_rhs_of_eq gz
                       in
                         if (has_metavars lhs) then lhs
                         else if (has_metavars rhs) then rhs
                         else gz 
                       end
                  (* Isn't an equality *)
                  | NONE => if (has_metavars gz) then gz 
                            else raise NoMetaVars (goal,rst)
      (* Note from lucas: this will give back some things that really
      do not match/unify - you need to use MyUnify.unify to get the
      actual real unification and ienv... maybe you already do this? *)
      val maybe_matches = 
          Seq.maps
            (fn z => (Seq.map (pair z) 
                              (Seq.of_list (Net.unify_term part_wrulenet 
                                                           (Zipper.trm z)))))
            (search_func_leaves gz')
            |> print_count_seq "midout_rw:maybe_matches: "

      val part_insts = 
          (Seq.map_filter (inst_metavar ppl goal) maybe_matches)
            |> print_count_seq "midout_rw:part_insts: "

      (* Rewrite at the location where we found a partial match with a
         wave-rule and instantiated a meta-variabel. *)
      (* assume zipper is correctly instantiated and reflects the real goal,
       and that rule_nm refer to a lifted version of the rule.*)
      fun rw ((app_zip, ppl, rule_nm), orig_rule_nm) =
          let
            (*val _ = raise midout_rw_exp (goal, rst) *)
          
            (* Does Prf.apply_subst throw exception if the rule
               can't be applied at the zipper? Here that might be
             possible, and we'd like an empty sequece in that case.*)
            val substs = (Prf.apply_subst rule_nm goal app_zip ppl)
                         (* |> print_count_seq "midout_rw:rw:substs: " *)
          in
            Seq.map (fn ((new_g, gs), newppl0) => 
                          let 
                            val (nw_gs,newppl) = Prf.end_meth ("Middle-Out Rewriting by: "^orig_rule_nm) 
                                                  [new_g] [goal] newppl0 ppl0
                          in                         
                          rst |> RState.set_goalnames nw_gs
                              |> RState.set_pplan newppl
                              |> RState.set_rtechn NONE
                             (* |> pair rule_nm *)
                          end) (* Return new rst paired with rule_nm used to get it*)
                    substs 
          end;

    in
      Seq.maps rw part_insts |> print_count_seq "midout_rw:rw:substs: "
    end;



end
