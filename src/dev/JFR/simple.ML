open_theory "z_library";

use (OS.FileSys.getDir() ^ "/psgraph/src/core/build/proofpower/tinker");
val tinker_path = OS.FileSys.getDir()  ^ "/psgraph/";

val pspath = tinker_path ^ "src/dev/JFR/psgraph/";

(*=====  GoalTyp definitions *)
 val clause_def = 
 "not_top_symbol(X,Y) :- not(top_symbol(X, Y)).";

 val data = 
  default_gt_data
  |> ClauseGoalTyp.update_data_defs (fn x => (ClauseGoalTyp.scan_data PPProver.default_ctxt clause_def) @ x);


val simple = PSGraph.read_json_file (SOME data) (pspath^"simple.psgraph");

set_goal([], ¨µx∑ (1, x) ç {(a, b) | a = 1 ≤ b æ 2} ± (x æ 3 ≤ x º 4)Æ);
PPIntf.apply_ps_i simple;
top_thm();
drop_main_goal();