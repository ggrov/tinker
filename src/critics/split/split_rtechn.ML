signature ISAP_SPLITTER_DATA =
sig
 val conjI : Thm.thm
 val impI : Thm.thm
 val split_if : Thm.thm
 val if_P : Thm.thm
 val if_not_P : Thm.thm
 val is_if : Trm.T -> bool
 val subst_bool : Thm.thm
end;

structure HOLIsaP_SplitData : ISAP_SPLITTER_DATA =
struct

val conjI = @{thm "HOL.conjI"};
val split_if = @{thm "IsaPHOLUtils.IsaP_split_if"};
val impI = @{thm "HOL.impI"};
val if_P = @{thm "HOL.if_P"};
val if_not_P = @{thm "HOL.if_not_P"};
val subst_bool = @{thm "IsaPHOLUtils.subst_bool"};

fun is_if t =
    let val ifs = Seq.filter (fn z => case (Zipper.trm z) of (Const("HOL.If",_)) => true | _ => false) 
                             (ZipperSearch.leaves_lr (Zipper.mktop t))
    in not (null (Seq.list_of ifs)) end;

end;


(* TO DO: Tidy up and add signature *)

structure  SplitterRTechn =
struct

local 
  open RTechnEnv; 
in


fun is_if goal rst = 
    HOLIsaP_SplitData.is_if (RstPP.goal_concl goal rst);

(* fixme: this should be a parameterized rtechn *)
(* 3 branches  (if P then G1 else G2):
     - conditions on if always holds (i.e. G1)
     - condition on if always fails (i.e. G2)
     - case split where P -> G1, not P -> G2 
  now, how should we deal with goals? 2 options (at least):
     - they all must follow the same branch (e.g. P holds for all goals)
     - they can follow different branches
  however, not sure how to encode the later using combinators since we
  abstract over goals...
   - maybe by threading goals that fails, first two techniques have output wires
     for failed goals -- while the last doesn't?
      - can we write a generic such technique?
*)


(* input : goal
   output : conds, goals.subst, goal.simp
   but inv should ensure: that goal -> goal.subst !!!! 
*)

(*
fun try_if_branch branch_thm = 
  (subst_thm branch_thm false) 
  compose
  (RTechn.id_of (RState.Wire.of_string "goal.conds"))
    compose (* FIXME: should be thenr but raises compose_exp *)
    filter_wrap ("empty goal.conds wire",fn rst => Goaln.NSet.is_empty (RState.get_names_of_wire rst (RState.Wire.of_string "goal.conds"))) (* alt. filter_wire *)
                (bck_res_gfn (RState.Wire.of_string "goal.conds") (RState.Wire.of_string "goal.conds") (fn rst => fn goal => Seq.of_list (PPlan.get_lasms (RState.get_pplan rst) goal))
                   try1_orelse
                   simp_no_asm_changes);   (* should be multi_simp *)
*)

(* fixme: need to change wire names *)
(* fixme: pretty naive as I think all goals has to be solved the
same way. Maybe best to try each technique using filtering technique
and at the end all has to be split?
*)   


(* FIXME once branching and try works *)
(*
val split_if_rtechn =
  (try_if_branch HOLIsaP_SplitData.if_P)
    try1_orelse
  (try_if_branch HOLIsaP_SplitData.if_not_P)
    try1_orelse
  restr_rule_dthm (DThm.mk HOLIsaP_SplitData.split_if); (* fixme: wire names *)
*)
val split_if_rtechn = RTechn.id;
  (* due to restr_rule_dthm_wire we cannot split between true and false branch *)

(*
val splitN = RstName.str "Case-split if-statement";
val ifTrueN = RstName.str "then-branch of if-statement"
val ifFalseN = RstName.str "else-branch of if-statement" 
*)


(* If there are case-statements, try and identify them by 
cheking if they match the "case-name" for any of our known datatypes *)

(* IMPROVE: don't go through every element in thelist - do a
   lookup directly based on the names in datatype names the goal 
   (This involves a table of const-names to case stuff about them.)
*)
fun get_cases_of pp goal = 
    let  
      val thry = PPlan.get_theory pp;
      val t = Prf.get_ndname_ctrm pp goal;
      val dtypestab = Datatype.get_all thry;

      (* Pairs type-string * datatype_info.*)
      val datatypes = Symtab.dest dtypestab;
      val z = Zipper.mktop t;
  
      val cases = Seq.map_filter 
                    (fn z => case (Zipper.trm z) of 
                               (Const(constnm,_)) => 
                               let 
                                 val dt = List.find (fn (tynm,dtinfo) => 
                                                     constnm=(#case_name dtinfo)) 
                                                       datatypes
                               in
                                case dt of
                                  SOME dt => SOME (z,dt)
                                | NONE => NONE
                               end

                             | _ => NONE) 
                    (ZipperSearch.leaves_lr (Zipper.mktop t));
    in Seq.list_of cases end;

fun goal_in_rst_has_case rst goal = 
    not (null (get_cases_of (RState.get_pplan rst) goal));


fun get_case_rws_for rst goal = 
  let val pp = RState.get_pplan rst;
      (* IMPROVE: we compute the caseinfos twice if we check this is applicable first *)
      val caseinfos = get_cases_of pp goal;
  in  Seq.of_list (maps (fn (z,(tynm,dt)) => (#case_rewrites dt)) caseinfos) end;

fun get_split_thms_for rst goal = 
  let val pp = RState.get_pplan rst;
      val thry = PPlan.get_theory pp;
      (* IMPROVE: we compute the caseinfos twice if we check this is applicable first *)
      val caseinfos = get_cases_of pp goal;
  (* Put the split theorem into a form that can be used by our restricted version of resolution *)
  in Seq.of_list (map (fn (z,(tynm,dt)) => Global_Theory.get_thm thry (tynm^".split")) caseinfos) end;


(* could maybe stick stuff on wires too? *)
val branch_case_stms_rtechn = 
  subst_thm_of_gfn "subst with branch of case-statements"
                   (RState.Wire.of_string "goal.splitable")  
                   (RState.Wire.of_string "goal.split") (RState.Wire.of_string "goal.conds") 
                   get_case_rws_for
                   false;

val split_case_stms_rtechn = 
  restr_rule_wire_of_gfn "Resolution (restricted) backward with split_case_statement"
                   (RState.Wire.of_string "goal.splitable")  
                   (RState.Wire.of_string "goal.split") 
                   get_split_thms_for;

(* FIXME once choice fixed *)
val split_case_rthecn = RTechn.id;
(* val split_case_rthecn = branch_case_stms_rtechn try1_orelse split_case_stms_rtechn; *)
 
 end  (*local*)
end;
