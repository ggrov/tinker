(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  Title:      theories/HOL/splitter_HOL_data.ML
    Author:     Moa Johansson, University of Edinburgh
                moa.johansson@ed.ac.uk
    
    Created:    10 Oct 2006
*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *) 
(*  DESCRIPTION:

    Data for splitting if-statements.

*)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
(* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- *)
structure HOLIsaP_SplitterData : ISAP_SPLITTER_DATA =
struct

val conjI = @{thm "conjI"}
val split_if = @{thm  "split_if"}
val impI = @{thm  "impI"}
val if_P = @{thm  "if_P"}
val if_not_P = @{thm  "if_not_P"}

fun negate t = (Const("HOL.Not",HOLogic.boolT-->HOLogic.boolT)$t);

fun is_if t =
    let 
      val z= Zipper.mktop t
      fun find_if z = 
          case Zipper.trm z
           of (Const("HOL.If",_)) => true
            | _ => false
(*FIXME: only need to find one if *)
      val ifs = Seq.filter find_if (ZipperSearch.leaves_lr z)
(*zipper of whole if-stm and its condition trm *)
  (*    val ifstmts = Seq.map 
                    (fn z =>
                        ((Zipper.move_up(Zipper.move_up(Zipper.move_up z))),
                         (Zipper.trm(Zipper.move_down_left(Zipper.move_up z)))))
                    ifs *)
                    
    val conds = Seq.map (Zipper.trm o Zipper.move_down_right o Zipper.move_up) ifs
    val cond_trms = Seq.list_of conds
    in 
      if ((not o null) cond_trms) 
      then (SOME (cond_trms))
      else NONE
    end;
end;
structure SplitterDTac = SplitterDTacFUN(HOLIsaP_SplitterData);
