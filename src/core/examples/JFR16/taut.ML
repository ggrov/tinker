(* Steup the taut case study *)
  use_file (OS.FileSys.getDir()  ^ "/psgraph/src/core/examples/JFR16/taut_setup.ML");

 val g1 : GOAL = ([],¬T®);
 val g2 : GOAL = ([¬B®, ¬³ (A ± B)®],¬³ (A ± B)®);
 val g3 : GOAL = ([],¬if a then F else T®);
 val g4 : GOAL = ([¬F®],¬A ´ B´A®);
 val g5 : GOAL = ([],¬³ (B)®);
 val g6 : GOAL = ([],¬(A ± B ± C) ´ (C ± B ± A)®);
 val g7 : GOAL = ([],¬ A ´ (A ± A)®);
 val g8 : GOAL = ([],¬(A ± B ± C) ´ (C ± B ± A)®);
 val g9 : GOAL = ([¬A : BOOL®,¬(B ± C)®],¬(C ± B ± A)®);

(* Version 1, just a loop *)
 val taut_v1 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V1.psgraph");
(* Version 2, only arbitrary goaltype, i.e. any *)
 val taut_v2 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V2.psgraph");
(* Version 3, hierarchicy *)
 val taut_v3 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V3.psgraph");
(* Version 4, add goaltype *)
 val taut_v4 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V4.psgraph");

(* Version 5, fixing the loop error *)
 val taut_v4_debug = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V5_pre.psgraph");
 PPIntf.set_psg_goal (SOME g6) (SOME taut_v4_debug);
 val taut_v5 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V5.psgraph");
 PPIntf.set_psg_goal (SOME g6) (SOME taut_v5);

(* Version 6, fixing the skip error, the final version *)
 val taut_v5_debug = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V6_pre.psgraph"); 
 PPIntf.set_psg_goal (SOME g7) (SOME taut_v6_pre);

 val taut_v6 = PSGraph.read_json_file (SOME data) (pspath ^"simple_taut_tac_V6.psgraph"); 
 PPIntf.set_psg_goal (SOME g7) (SOME taut_v6);
 pop_thm();
 TextSocket.safe_close();
