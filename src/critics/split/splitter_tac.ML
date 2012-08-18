(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      theories/HOL/splitter_dtac.ML
    Author:     Moa Johansson, University of Edinburgh
                moa.johansson@ed.ac.uk
    
    Created:    10 Oct 2006
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    DTac for splitting if-statements.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)


(* 
 Why 2 signatures (the same in the rtechn)?
*)

signature ISAP_SPLITTER_DATA =
sig
 val conjI : Thm.thm
 val impI : Thm.thm
 val split_if : Thm.thm
 val if_P : Thm.thm
 val if_not_P : Thm.thm
 val is_if : Trm.T -> (Trm.T list)  option
 val negate : Trm.T -> Trm.T
end;


functor SplitterDTacFUN(Data : ISAP_SPLITTER_DATA) = 
struct

structure Data = Data;
val is_if = Data.is_if;
val negate = Data.negate;    

(*Split an if-statement creating two new subgoals.*)
val split_if_tac = 
    (Splitter.split_tac [Data.split_if] 1)

val conjI_tac =
    Tactic.rtac Data.conjI 1;

val impI_tac =
      Tactic.rtac Data.impI 1;

fun pretty_subst th = 
      Pretty.block [Pretty.str "Subst ", Pretty.str (Thm.name_of_thm th)];

(* The single step of rewriting method *)
 fun subst_thm th gth = 
      EqSubst.eqsubst_tac (ProofContext.init (Thm.theory_of_thm gth)) [0] [th] 1 gth;
(*
 fun subst_thm th = 
     DTac.mk(pretty_subst th, 
             fn gth => (EqSubst.eqsubst_tac 
                          (ProofContext.init 
                             (Thm.theory_of_thm gth)) [0] [th] 1 gth));*)

val if_P_dtac = subst_thm Data.if_P;

(* This will be much better approach, get rid of condition first. This
makes a new goal which instantiates the condition of if_P. Need 
substitution in IsaPlanner's env to complete this*)
(*fun if_P_dtac ppl asms =
    let  
      val split_thms =
          maps (fn asm => Prf.apply_frule_thm Data.if_P asm ppl) asms
    in
      Seq.maps (fn (th_nm, ppl2) => Subst.apply thm_nm false gname ppl2) 
               split_thms
    end;
  *)      
val if_not_P_dtac =  subst_thm Data.if_not_P;
(*fun if_not_P_dtac ppl asms =
  let  
      val split_thms =
          maps (fn asm => Prf.apply_frule_thm Data.if_not_P asm ppl) asms
    in
      Seq.maps subst_thm (Seq.of_list split_thms)
    end;
*)
(*
val split_if_dtac =
    DTac.mk(Pretty.str "Splitting if-statement", 
            split_if_tac)

val impI_dtac = DTac.mk(Pretty.str "rule impI", impI_tac);

val conjI_dtac = DTac.mk(Pretty.str "rule conjI", conjI_tac);
*)

end;
