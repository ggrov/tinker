(* Steup the taut case study *)
  use_file (OS.FileSys.getDir()  ^ "/psgraph/src/dev/JFR/taut_setup.ML");

 val g1 : GOAL = ([],¬T®);
 val g2 : GOAL = ([¬B®, ¬³ (A ± B)®],¬³ (A ± B)®);
 val g3 : GOAL = ([],¬if a then F else T®);
 val g4 : GOAL = ([¬F®],¬A ´ B´A®);
 val g5 : GOAL = ([],¬³ (B)®);
 
 val g6 : GOAL = ([],¬(A ± B) ´ (B ± A)®);
 val g7 : GOAL = ([],¬ A ´ (A ± A)®);
 val g8 : GOAL = ([],¬(A ± B ± C) ´ (C ± B ± A)®);
 val g9 : GOAL = ([¬A : BOOL®,¬(B ± C)®],¬(C ± B ± A)®);
(* Version 1, just a loop *)
 val taut_v1 = PSGraph.read_json_file NONE (pspath ^"simple_taut_tac_V1.psgraph");
 PPIntf.set_psg_goal (SOME ([],¬(A ± B) ´ (B ± A)®)) (SOME taut_v1);

(* Version 2, only arbitrary goaltype, i.e. any *)
(* Version 3, add goaltype *)
(* Version 4, better hierachicy *)
(* Version 5, the loop error *)
(* Version 6, the skip error, the final version *)
 val taut_v6 = PSGraph.read_json_file NONE (pspath ^"simple_taut_tac_V6.psgraph") |> PSGraph.set_goaltype_data data; 

 PPIntf.set_psg_goal (SOME g8) (SOME taut_v6);

 TextSocket.safe_close();

(*********** TEST ONLY ********)
val ctxt = PPProver.default_ctxt;
val (pnode,pplan) = PPProver.init PPProver.default_ctxt (fst g9) (snd g9);

ClauseGoalTyp.imatch data pnode (ClauseGoalTyp.scan_goaltyp ctxt "literal (hyps)");

val trm =  ¬%not% B®;
(dest_app trm |> fst) =$ ¬$%not%®;
 (snd (dest_app trm)));
set_goal g2;
undo 1;
a (t2 ¬B ¤ A®);
drop_main_goal();